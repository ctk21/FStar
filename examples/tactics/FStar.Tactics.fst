module FStar.Tactics

assume type binder
assume type term
assume type env

type typ     = term
type binders = list binder
type goal    = env * term
type goals   = list goal
type state   = goals  //active goals 
             * goals  //goals that have to be dispatched to SMT
noeq type formula = 
  | True_  : formula
  | False_ : formula  
  | Eq     : typ -> term -> term -> formula
  | And    : term -> term -> formula
  | Or     : term -> term -> formula
  | Not    : term -> formula
  | Implies: term -> term -> formula
  | Iff    : term -> term -> formula  
  | Forall : binders -> term -> formula
  | Exists : binders -> term -> formula

assume val term_as_formula: term -> option formula

noeq type result (a:Type) =
  | Success: a -> state -> result a
  | Failed: string -> state -> result a

let tac (a:Type) = state -> M (result a)

(* monadic return *)
val ret : a:Type -> x:a -> tac a
let ret a x = fun (s:state) -> Success x s

(* monadic bind *)
let bind (a:Type) (b:Type) 
         (t1:tac a)
         (t2:a -> tac b)
    : tac b
    = fun p ->
        let r = t1 p in
        match r with
        | Success a q  -> t2 a q
        | Failed msg q -> Failed msg q

(* Actions *)
let get () : tac state = fun s0 -> Success s0 s0 

assume val forall_intros_: unit -> tac binders
assume val focus_: tac unit -> tac unit

(* total  *) //disable the termination check, although it remains reifiable
reifiable reflectable new_effect_for_free {
  TAC : a:Type -> Effect
  with repr     = tac
     ; bind     = bind
     ; return   = ret
  and effect_actions
       get      = get
}

(* working around #885 *)
let fail_ (a:Type) (msg:string) : tac a = fun s0 -> Failed #a "No message for now" s0
let fail (#a:Type) (msg:string) = TAC?.reflect (fail_ a msg)

effect Tac (a:Type) = TAC a (fun i post -> forall j. post j)
let tactic = unit -> Tac unit

abstract 
let by_tactic (t:state -> result unit) (a:Type) : Type = a

let reify_tactic (t:tactic) : tac unit =
  fun s -> reify (t ()) s

let forall_intros () :Tac binders = TAC?.reflect (forall_intros_ ())
let focus (f:tactic) : Tac unit = TAC?.reflect (focus_ (reify_tactic f))

let assert_by_tactic (t:tactic) (p:Type)
  : Pure unit 
         (requires (by_tactic (reify_tactic t) p))
         (ensures (fun _ -> p))
  = ()

(* Primitives provided natively by the tactic engine *)
//assume val forall_intros: unit -> Tac binders
assume val implies_intro: unit -> Tac binder
assume val revert  : unit -> Tac unit
assume val clear   : unit -> Tac unit
assume val split   : unit -> Tac unit
assume val merge   : unit -> Tac unit
assume val rewrite : binder -> Tac unit
assume val smt     : unit -> Tac unit
(* assume val focus   : (unit -> Tac unit) -> Tac unit *)
assume val visit   : (unit -> Tac unit) -> Tac unit
