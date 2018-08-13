module LowComp

open HighComp
open FStar.HyperStack
open FStar.HyperStack.ST
open LowStar.Buffer
open LowStar.BufferOps
open LowStar.Modifies
open Mem_eq

module H = FStar.Monotonic.Heap
module B = LowStar.Buffer
module ST = FStar.HyperStack.ST
module HS = FStar.HyperStack
module U32 = FStar.UInt32
module Map = FStar.Map
module M = LowStar.Modifies


type lstate = pointer mint * pointer mint

val well_formed : HS.mem -> lstate -> GTot Type0
let well_formed h = fun (r1, r2) -> live h r1 /\ live h r2 /\ disjoint r1 r2

// To and from high- and low-level state coercions

val lstate_as_state : HS.mem -> lstate -> GTot state
let lstate_as_state h  = fun (b1, b2) -> (B.get h b1 0, B.get h b2 0)

val state_as_lstate : h:HS.mem -> ls:lstate{well_formed h ls} -> state -> GTot HS.mem 
let state_as_lstate h =
  fun (r1, r2) (v1, v2) ->
    let h' = g_upd r1 0 v1 h in
    let p = g_upd_preserves_live h r1 r2 v1 in
    g_upd r2 0 v2 h'


val state_as_lstate_inv : h:HS.mem -> ls:lstate{well_formed h ls} -> bs:state ->
   Lemma (lstate_as_state (state_as_lstate h ls bs) ls = bs)
let state_as_lstate_inv h ls bs = 
  let (b1, b2) = ls in 
  let (s1, s2) = bs in
  let h1 = g_upd b1 0 s1 h in 
  let l1 = g_upd_preserves_live h b1 b2 s1 in
  let h2 = g_upd b2 0 s2 h1 in
  let l2 = g_upd_preserves_live h1 b2 b1 s2 in
    
  let p1 = get_upd_same h b1 s1 in  
  assert (get h1 b1 0 == s1);
  let p1' = get_upd_other h1 b2 b1 s2 s1 in
  assert (get h2 b1 0 == get h1 b1 0); 
  let p2 = get_upd_same h1 b2 s2 in
  assert (get h2 b2 0 == s2);
  ()

// Low type variations

type lcomp 'a (c : comp 'a) =
    (ls:lstate) ->
    Stack 'a
      (requires (fun h -> well_formed h ls))
      (ensures  (fun h r h' ->
                   well_formed h' ls /\
                   //modifies (loc_union (loc_buffer (fst ls)) (loc_buffer (snd ls))) h h' /\
                   (let s0 = lstate_as_state h ls in
                    let (x, s1) = c s0 in
                    Map.equal (get_hmap h') (get_hmap (state_as_lstate h ls s1)) /\ x == r )))



// This type uses the coercion from high state to low state. Verification of DSL fails with a first try. 
let lcomp_wp1 (a:Type) (wp : state -> (a * state -> Type) -> Type) (c : comp_wp a wp) =
     (ls:lstate) ->
     Stack a
       (requires (fun h -> well_formed h ls))
       (ensures  (fun h r h' ->
                    well_formed h' ls /\
                    (let s0 = lstate_as_state h ls in
                     wp s0 (fun _ -> True) ==> 
                     (let tls = state_as_lstate h ls in // XXX fails otherwise
                      let (x, s1) = c s0 in 
                      h' == tls s1 /\ x == r ))))

let lcomp_wp2 (a:Type) (wp : state -> (a * state -> Type) -> Type) (c : comp_wp a wp) =
     (ls:lstate) ->
     Stack a
       (requires (fun h -> well_formed h ls))
       (ensures  (fun h r h' ->
                    well_formed h' ls /\
                    (let s0 = lstate_as_state h ls in
                      wp s0 (fun _ -> True) ==> 
                      (let tls = state_as_lstate h ls in // XXX fails otherwise
                       let (x, s1) = c s0 in 
                       h' == tls s1 /\ x == r ))))


// This is the variation currenlty used
let lcomp_wp (a:Type) (wp : state -> (a * state -> Type) -> Type) (c : comp_wp a wp) =
     (ls:lstate) ->
     Stack a
       (requires (fun h -> well_formed h ls))
       (ensures  (fun h r h' ->
                    well_formed h' ls /\
                    modifies (loc_union (loc_buffer (fst ls)) (loc_buffer (snd ls))) h h' /\
                    (let s0 = lstate_as_state h ls in
                     wp s0 (fun _ -> True) ==>
                     (let res = c s0 in
                      snd res == lstate_as_state h' ls /\ fst res == r))))


let lcomp_wp' (a:Type) (wp : state -> (a * state -> Type) -> Type) (c : comp_wp a wp) =
    (ls:lstate) ->
    Stack a
      (requires (fun h -> well_formed h ls))
      (ensures  (fun h r h' ->
      well_formed h' ls /\
      modifies (loc_union (loc_buffer (fst ls)) (loc_buffer (snd ls))) h h' /\
      (let s0 = lstate_as_state h ls in
       wp s0 (fun _ -> True) ==>
       (let res = c s0 in
       snd res == lstate_as_state h' ls /\ fst res == r))))


let lcomp_p (a:Type) pre post (c : comp_p a pre post) =
    (ls:lstate) ->
    Stack a
      (requires (fun h -> well_formed h ls))
      (ensures  (fun h r h' ->
                   well_formed h' ls /\
                   modifies (loc_union (loc_buffer (fst ls)) (loc_buffer (snd ls))) h h' /\

                   (let s0 = lstate_as_state h ls in
                     pre s0 /\
                     (let res = c s0 in
                     snd res == lstate_as_state h' ls /\ fst res == r))))


let reif (#a:Type) (wp:state -> (a * state -> Type) -> Type) (c : unit -> HIGH a wp) :
  comp_wp a wp = reify (c ())


let lcomp_r (a:Type) (wp:state -> (a * state -> Type) -> Type) (c : unit -> HIGH a wp) =
  (ls:lstate) ->
  Stack a
    (requires (fun h -> well_formed h ls))
    (ensures  (fun h r h' ->
                 well_formed h' ls /\
                 modifies (loc_union (loc_buffer (fst ls)) (loc_buffer (snd ls))) h h' /\
                 (let s0 = lstate_as_state h ls in
                  wp s0 (fun _ -> True) /\
                  (let res = reif wp c s0 in
                  // let res = reify (c ()) s0 in XXX using reify directly fails
                  snd res == lstate_as_state h' ls /\ fst res == r))))


(* DSL for low computations *)

let lreturn (#a:Type) (x:a) : lcomp_wp1 a (return_wp x) (hreturn' x) = 
  fun (b1, b2) -> 
    let h0 = ST.get () in 
    let p1 = get_upd_eq h0 b1 0 (get h0 b1 0) in
    let p2 = get_upd_eq h0 b2 0 (get h0 b2 0) in
    x


// Not sure why this doesn't verify. Result type should follow from the assertions
val lwrite : i:nat{ i < 2 } -> v:mint -> lcomp_wp1 unit (write_wp i v) (hwrite' i v)
let lwrite i v = fun (b1, b2) -> 
   let h0 = ST.get () in
    if i = 0 then 
      let p = 
        let p = g_upd_preserves_live h0 b1 b2 v in // Shows: live h1 b
        let g = get_upd_other h0 b1 b2 v (get h0 b2 0) in // Shows: get (g_upd b1 v h0) b2 = get h0 b2 
        assert (get (g_upd b1 0 v h0) b2 0 == get h0 b2 0);
        get_upd_eq (g_upd b1 0 v h0) b2 0 (get h0 b2 0) // Shows: g_upd b2 0 (get h0 b2 0) h1 == h1
      in
      assert (g_upd b2 0 (get h0 b2 0) (g_upd b1 0 v h0) == g_upd b1 0 v h0);
      b1.(0ul) <- v 
    else 
      let p1 = get_upd_eq h0 b1 0 (get h0 b1 0) in
      assert (g_upd b2 0 v (g_upd b1 0 (get h0 b1 0) h0) == g_upd b2 0 v h0);
      b2.(0ul) <- v

val lread : i:nat{ i < 2 } -> lcomp_wp1 mint (read_wp i) (hread' i)
let lread i = fun (b1, b2) -> 
  let h0 = ST.get () in 
  let p1 = get_upd_eq h0 b1 0 (get h0 b1 0) in
  let p2 = get_upd_eq h0 b2 0 (get h0 b2 0) in
  if i = 0 then 
     b1.(0ul) 
  else 
    b2.(0ul)

let monotonic (#a: Type) (wp: hwp a) = 
    forall (s: state) p1 p2. (forall x. p1 x ==> p2 x) ==> wp s p1 ==> wp s p2

let lbind (#a:Type) (#b:Type)
  (#wp1: state -> (a * state -> Type) -> Type)
  (#wp2: a -> state -> (b * state -> Type) -> Type)
  (#c1:comp_wp a wp1) (#c2:(x:a -> comp_wp b (wp2 x)))
  (m: lcomp_wp a wp1 c1) (f: (x:a) -> lcomp_wp b (wp2 x) (c2 x)):
  lcomp_wp b (bind_wp wp1 wp2) (hbind' c1 c2) =
  fun (b1, b2) ->
    assume (monotonic wp1);
    let h0 = ST.get () in  // Initial heap
    let a = m (b1, b2) in 
    let h1 = ST.get () in // Intermediate heap
    assume (monotonic (wp2 a));

    let p1 =
      let s1 = lstate_as_state h0 (b1, b2) in
//      (wp1 s1 (fun _ -> True)) ==> 
      (let (r, s2) = c1 s1 in
       get_upd_eq h0 b1 0 (get h0 b1 0))
    in 
    
    // let p = 
    //    let (r, s2) = c1 (lstate_as_state h0 ls) in 
    //    let h1' = state_as_lstate h0 ls s2 in 
    //    assert (h1 == h1');
    //    assert (r == a);
    //    state_as_lstate_inv h0 ls (lstate_as_state h0 ls)
    // in
    // assert (let s0 = lstate_as_state h0 ls in
    //         let (r, s1) = c1 s0 in
    //         let h1' = state_as_lstate h0 ls s1 in 
    //         lstate_as_state h1' ls == s1);
            
    let r = f a (b1, b2) in r


// Versions of [lread] and [lwrite] with reif in spec

val lwrite' : i:nat{ i < 2 } -> v:mint -> lcomp_wp unit (write_wp i v) (reify (HIGH?.put i v))
let lwrite' i v = fun (b1, b2) -> 
  if i = 0 then 
    b1.(0ul) <- v 
  else     
    b2.(0ul) <- v

val lread' : i:nat{ i < 2 } -> lcomp_wp1 mint (read_wp i) (reify (HIGH?.get i))
let lread' i = fun (b1, b2) -> 
  let h0 = ST.get () in 
  let p1 = get_upd_eq h0 b1 0 (get h0 b1 0) in
  let p2 = get_upd_eq h0 b2 0 (get h0 b2 0) in
  if i = 0 then b1.(0ul) else b2.(0ul)


let lcomp_respects_h_eq (a : Type) (wp1 : hwp a) (wp2 : hwp a) (hc1 : comp_wp a wp1) (hc2 : comp_wp a wp2)  
  (lc : lcomp_wp a wp1 hc1) (p : h_eq wp1 wp2 hc1 hc2) : lcomp_wp' a wp2 hc2 = // 660 requires the lcomp_wp'
   lc 
  