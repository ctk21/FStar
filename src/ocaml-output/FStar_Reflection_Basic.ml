open Prims
let (env_hook :
  FStar_TypeChecker_Env.env FStar_Pervasives_Native.option FStar_ST.ref) =
  FStar_Util.mk_ref FStar_Pervasives_Native.None
let (inspect_aqual :
  FStar_Syntax_Syntax.aqual -> FStar_Reflection_Data.aqualv) =
  fun aq ->
    match aq with
    | FStar_Pervasives_Native.Some (FStar_Syntax_Syntax.Implicit uu____12) ->
        FStar_Reflection_Data.Q_Implicit
    | FStar_Pervasives_Native.Some (FStar_Syntax_Syntax.Meta
        (FStar_Syntax_Syntax.Arg_qualifier_meta_tac t)) ->
        FStar_Reflection_Data.Q_Meta t
    | FStar_Pervasives_Native.Some (FStar_Syntax_Syntax.Meta
        (FStar_Syntax_Syntax.Arg_qualifier_meta_attr t)) ->
        FStar_Reflection_Data.Q_Meta_attr t
    | FStar_Pervasives_Native.Some (FStar_Syntax_Syntax.Equality) ->
        FStar_Reflection_Data.Q_Explicit
    | FStar_Pervasives_Native.None -> FStar_Reflection_Data.Q_Explicit
let (pack_aqual : FStar_Reflection_Data.aqualv -> FStar_Syntax_Syntax.aqual)
  =
  fun aqv ->
    match aqv with
    | FStar_Reflection_Data.Q_Explicit -> FStar_Pervasives_Native.None
    | FStar_Reflection_Data.Q_Implicit ->
        FStar_Pervasives_Native.Some (FStar_Syntax_Syntax.Implicit false)
    | FStar_Reflection_Data.Q_Meta t ->
        FStar_Pervasives_Native.Some
          (FStar_Syntax_Syntax.Meta
             (FStar_Syntax_Syntax.Arg_qualifier_meta_tac t))
    | FStar_Reflection_Data.Q_Meta_attr t ->
        FStar_Pervasives_Native.Some
          (FStar_Syntax_Syntax.Meta
             (FStar_Syntax_Syntax.Arg_qualifier_meta_attr t))
let (inspect_fv : FStar_Syntax_Syntax.fv -> Prims.string Prims.list) =
  fun fv ->
    let uu____41 = FStar_Syntax_Syntax.lid_of_fv fv in
    FStar_Ident.path_of_lid uu____41
let (pack_fv : Prims.string Prims.list -> FStar_Syntax_Syntax.fv) =
  fun ns ->
    let lid = FStar_Parser_Const.p2l ns in
    let fallback uu____60 =
      let quals =
        let uu____64 = FStar_Ident.lid_equals lid FStar_Parser_Const.cons_lid in
        if uu____64
        then FStar_Pervasives_Native.Some FStar_Syntax_Syntax.Data_ctor
        else
          (let uu____71 =
             FStar_Ident.lid_equals lid FStar_Parser_Const.nil_lid in
           if uu____71
           then FStar_Pervasives_Native.Some FStar_Syntax_Syntax.Data_ctor
           else
             (let uu____78 =
                FStar_Ident.lid_equals lid FStar_Parser_Const.some_lid in
              if uu____78
              then FStar_Pervasives_Native.Some FStar_Syntax_Syntax.Data_ctor
              else
                (let uu____85 =
                   FStar_Ident.lid_equals lid FStar_Parser_Const.none_lid in
                 if uu____85
                 then
                   FStar_Pervasives_Native.Some FStar_Syntax_Syntax.Data_ctor
                 else FStar_Pervasives_Native.None))) in
      let uu____92 = FStar_Parser_Const.p2l ns in
      FStar_Syntax_Syntax.lid_as_fv uu____92
        (FStar_Syntax_Syntax.Delta_constant_at_level (Prims.of_int (999)))
        quals in
    let uu____94 = FStar_ST.op_Bang env_hook in
    match uu____94 with
    | FStar_Pervasives_Native.None -> fallback ()
    | FStar_Pervasives_Native.Some env ->
        let qninfo = FStar_TypeChecker_Env.lookup_qname env lid in
        (match qninfo with
         | FStar_Pervasives_Native.Some (FStar_Util.Inr (se, _us), _rng) ->
             let quals = FStar_Syntax_DsEnv.fv_qual_of_se se in
             let uu____174 = FStar_Parser_Const.p2l ns in
             FStar_Syntax_Syntax.lid_as_fv uu____174
               (FStar_Syntax_Syntax.Delta_constant_at_level
                  (Prims.of_int (999))) quals
         | uu____176 -> fallback ())
let rec last : 'a . 'a Prims.list -> 'a =
  fun l ->
    match l with
    | [] -> failwith "last: empty list"
    | x::[] -> x
    | uu____195::xs -> last xs
let rec init : 'a . 'a Prims.list -> 'a Prims.list =
  fun l ->
    match l with
    | [] -> failwith "init: empty list"
    | x::[] -> []
    | x::xs -> let uu____225 = init xs in x :: uu____225
let (inspect_const :
  FStar_Syntax_Syntax.sconst -> FStar_Reflection_Data.vconst) =
  fun c ->
    match c with
    | FStar_Const.Const_unit -> FStar_Reflection_Data.C_Unit
    | FStar_Const.Const_int (s, uu____235) ->
        let uu____250 = FStar_BigInt.big_int_of_string s in
        FStar_Reflection_Data.C_Int uu____250
    | FStar_Const.Const_bool (true) -> FStar_Reflection_Data.C_True
    | FStar_Const.Const_bool (false) -> FStar_Reflection_Data.C_False
    | FStar_Const.Const_string (s, uu____254) ->
        FStar_Reflection_Data.C_String s
    | FStar_Const.Const_range r -> FStar_Reflection_Data.C_Range r
    | FStar_Const.Const_reify -> FStar_Reflection_Data.C_Reify
    | FStar_Const.Const_reflect l ->
        let uu____259 = FStar_Ident.path_of_lid l in
        FStar_Reflection_Data.C_Reflect uu____259
    | uu____260 ->
        let uu____261 =
          let uu____263 = FStar_Syntax_Print.const_to_string c in
          FStar_Util.format1 "unknown constant: %s" uu____263 in
        failwith uu____261
let rec (inspect_ln :
  FStar_Syntax_Syntax.term -> FStar_Reflection_Data.term_view) =
  fun t ->
    let t1 = FStar_Syntax_Util.unascribe t in
    let t2 = FStar_Syntax_Util.un_uinst t1 in
    let t3 = FStar_Syntax_Util.unlazy_emb t2 in
    match t3.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_meta (t4, uu____276) -> inspect_ln t4
    | FStar_Syntax_Syntax.Tm_name bv -> FStar_Reflection_Data.Tv_Var bv
    | FStar_Syntax_Syntax.Tm_bvar bv -> FStar_Reflection_Data.Tv_BVar bv
    | FStar_Syntax_Syntax.Tm_fvar fv -> FStar_Reflection_Data.Tv_FVar fv
    | FStar_Syntax_Syntax.Tm_app (hd, []) ->
        failwith "inspect_ln: empty arguments on Tm_app"
    | FStar_Syntax_Syntax.Tm_app (hd, args) ->
        let uu____334 = last args in
        (match uu____334 with
         | (a, q) ->
             let q' = inspect_aqual q in
             let uu____362 =
               let uu____367 =
                 let uu____368 = init args in
                 FStar_Syntax_Util.mk_app hd uu____368 in
               (uu____367, (a, q')) in
             FStar_Reflection_Data.Tv_App uu____362)
    | FStar_Syntax_Syntax.Tm_abs ([], uu____387, uu____388) ->
        failwith "inspect_ln: empty arguments on Tm_abs"
    | FStar_Syntax_Syntax.Tm_abs (b::bs, t4, k) ->
        let body =
          match bs with
          | [] -> t4
          | bs1 ->
              FStar_Syntax_Syntax.mk
                (FStar_Syntax_Syntax.Tm_abs (bs1, t4, k))
                t4.FStar_Syntax_Syntax.pos in
        FStar_Reflection_Data.Tv_Abs (b, body)
    | FStar_Syntax_Syntax.Tm_type uu____480 ->
        FStar_Reflection_Data.Tv_Type ()
    | FStar_Syntax_Syntax.Tm_arrow ([], k) ->
        failwith "inspect_ln: empty binders on arrow"
    | FStar_Syntax_Syntax.Tm_arrow uu____501 ->
        let uu____516 = FStar_Syntax_Util.arrow_one_ln t3 in
        (match uu____516 with
         | FStar_Pervasives_Native.Some (b, c) ->
             FStar_Reflection_Data.Tv_Arrow (b, c)
         | FStar_Pervasives_Native.None -> failwith "impossible")
    | FStar_Syntax_Syntax.Tm_refine (bv, t4) ->
        FStar_Reflection_Data.Tv_Refine (bv, t4)
    | FStar_Syntax_Syntax.Tm_constant c ->
        let uu____541 = inspect_const c in
        FStar_Reflection_Data.Tv_Const uu____541
    | FStar_Syntax_Syntax.Tm_uvar (ctx_u, s) ->
        let uu____560 =
          let uu____565 =
            let uu____566 =
              FStar_Syntax_Unionfind.uvar_id
                ctx_u.FStar_Syntax_Syntax.ctx_uvar_head in
            FStar_BigInt.of_int_fs uu____566 in
          (uu____565, (ctx_u, s)) in
        FStar_Reflection_Data.Tv_Uvar uu____560
    | FStar_Syntax_Syntax.Tm_let ((false, lb::[]), t21) ->
        if lb.FStar_Syntax_Syntax.lbunivs <> []
        then FStar_Reflection_Data.Tv_Unknown
        else
          (match lb.FStar_Syntax_Syntax.lbname with
           | FStar_Util.Inr uu____598 -> FStar_Reflection_Data.Tv_Unknown
           | FStar_Util.Inl bv ->
               FStar_Reflection_Data.Tv_Let
                 (false, (lb.FStar_Syntax_Syntax.lbattrs), bv,
                   (lb.FStar_Syntax_Syntax.lbdef), t21))
    | FStar_Syntax_Syntax.Tm_let ((true, lb::[]), t21) ->
        if lb.FStar_Syntax_Syntax.lbunivs <> []
        then FStar_Reflection_Data.Tv_Unknown
        else
          (match lb.FStar_Syntax_Syntax.lbname with
           | FStar_Util.Inr uu____626 -> FStar_Reflection_Data.Tv_Unknown
           | FStar_Util.Inl bv ->
               FStar_Reflection_Data.Tv_Let
                 (true, (lb.FStar_Syntax_Syntax.lbattrs), bv,
                   (lb.FStar_Syntax_Syntax.lbdef), t21))
    | FStar_Syntax_Syntax.Tm_match (t4, brs) ->
        let rec inspect_pat p =
          match p.FStar_Syntax_Syntax.v with
          | FStar_Syntax_Syntax.Pat_constant c ->
              let uu____681 = inspect_const c in
              FStar_Reflection_Data.Pat_Constant uu____681
          | FStar_Syntax_Syntax.Pat_cons (fv, ps) ->
              let uu____702 =
                let uu____714 =
                  FStar_List.map
                    (fun uu____738 ->
                       match uu____738 with
                       | (p1, b) ->
                           let uu____759 = inspect_pat p1 in (uu____759, b))
                    ps in
                (fv, uu____714) in
              FStar_Reflection_Data.Pat_Cons uu____702
          | FStar_Syntax_Syntax.Pat_var bv ->
              FStar_Reflection_Data.Pat_Var bv
          | FStar_Syntax_Syntax.Pat_wild bv ->
              FStar_Reflection_Data.Pat_Wild bv
          | FStar_Syntax_Syntax.Pat_dot_term (bv, t5) ->
              FStar_Reflection_Data.Pat_Dot_Term (bv, t5) in
        let brs1 =
          FStar_List.map
            (fun uu___0_810 ->
               match uu___0_810 with
               | (pat, uu____832, t5) ->
                   let uu____850 = inspect_pat pat in (uu____850, t5)) brs in
        FStar_Reflection_Data.Tv_Match (t4, brs1)
    | FStar_Syntax_Syntax.Tm_unknown -> FStar_Reflection_Data.Tv_Unknown
    | uu____855 ->
        ((let uu____857 =
            let uu____863 =
              let uu____865 = FStar_Syntax_Print.tag_of_term t3 in
              let uu____867 = FStar_Syntax_Print.term_to_string t3 in
              FStar_Util.format2
                "inspect_ln: outside of expected syntax (%s, %s)\n" uu____865
                uu____867 in
            (FStar_Errors.Warning_CantInspect, uu____863) in
          FStar_Errors.log_issue t3.FStar_Syntax_Syntax.pos uu____857);
         FStar_Reflection_Data.Tv_Unknown)
let (inspect_comp :
  FStar_Syntax_Syntax.comp -> FStar_Reflection_Data.comp_view) =
  fun c ->
    let get_dec flags =
      let uu____891 =
        FStar_List.tryFind
          (fun uu___1_896 ->
             match uu___1_896 with
             | FStar_Syntax_Syntax.DECREASES uu____898 -> true
             | uu____902 -> false) flags in
      match uu____891 with
      | FStar_Pervasives_Native.None -> FStar_Pervasives_Native.None
      | FStar_Pervasives_Native.Some (FStar_Syntax_Syntax.DECREASES t) ->
          FStar_Pervasives_Native.Some t
      | uu____909 -> failwith "impossible" in
    match c.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Total (t, uu____916) ->
        FStar_Reflection_Data.C_Total (t, FStar_Pervasives_Native.None)
    | FStar_Syntax_Syntax.GTotal (t, uu____928) ->
        FStar_Reflection_Data.C_GTotal (t, FStar_Pervasives_Native.None)
    | FStar_Syntax_Syntax.Comp ct ->
        let uu____940 =
          FStar_Ident.lid_equals ct.FStar_Syntax_Syntax.effect_name
            FStar_Parser_Const.effect_Lemma_lid in
        if uu____940
        then
          (match ct.FStar_Syntax_Syntax.effect_args with
           | (pre, uu____944)::(post, uu____946)::(pats, uu____948)::uu____949
               -> FStar_Reflection_Data.C_Lemma (pre, post, pats)
           | uu____1008 ->
               failwith "inspect_comp: Lemma does not have enough arguments?")
        else
          (let uu____1022 =
             FStar_Ident.lid_equals ct.FStar_Syntax_Syntax.effect_name
               FStar_Parser_Const.effect_Tot_lid in
           if uu____1022
           then
             let md = get_dec ct.FStar_Syntax_Syntax.flags in
             FStar_Reflection_Data.C_Total
               ((ct.FStar_Syntax_Syntax.result_typ), md)
           else
             (let uu____1032 =
                FStar_Ident.lid_equals ct.FStar_Syntax_Syntax.effect_name
                  FStar_Parser_Const.effect_GTot_lid in
              if uu____1032
              then
                let md = get_dec ct.FStar_Syntax_Syntax.flags in
                FStar_Reflection_Data.C_GTotal
                  ((ct.FStar_Syntax_Syntax.result_typ), md)
              else
                (let inspect_arg uu____1059 =
                   match uu____1059 with
                   | (a, q) ->
                       let uu____1078 = inspect_aqual q in (a, uu____1078) in
                 let uu____1081 =
                   let uu____1094 =
                     FStar_Ident.path_of_lid
                       ct.FStar_Syntax_Syntax.effect_name in
                   let uu____1095 =
                     FStar_List.map inspect_arg
                       ct.FStar_Syntax_Syntax.effect_args in
                   ([], uu____1094, (ct.FStar_Syntax_Syntax.result_typ),
                     uu____1095) in
                 FStar_Reflection_Data.C_Eff uu____1081)))
let (pack_comp : FStar_Reflection_Data.comp_view -> FStar_Syntax_Syntax.comp)
  =
  fun cv ->
    match cv with
    | FStar_Reflection_Data.C_Total (t, FStar_Pervasives_Native.None) ->
        FStar_Syntax_Syntax.mk_Total t
    | FStar_Reflection_Data.C_Total (t, FStar_Pervasives_Native.Some d) ->
        let ct =
          {
            FStar_Syntax_Syntax.comp_univs = [FStar_Syntax_Syntax.U_zero];
            FStar_Syntax_Syntax.effect_name =
              FStar_Parser_Const.effect_Tot_lid;
            FStar_Syntax_Syntax.result_typ = t;
            FStar_Syntax_Syntax.effect_args = [];
            FStar_Syntax_Syntax.flags = [FStar_Syntax_Syntax.DECREASES d]
          } in
        FStar_Syntax_Syntax.mk_Comp ct
    | FStar_Reflection_Data.C_GTotal (t, FStar_Pervasives_Native.None) ->
        FStar_Syntax_Syntax.mk_GTotal t
    | FStar_Reflection_Data.C_GTotal (t, FStar_Pervasives_Native.Some d) ->
        let ct =
          {
            FStar_Syntax_Syntax.comp_univs = [FStar_Syntax_Syntax.U_zero];
            FStar_Syntax_Syntax.effect_name =
              FStar_Parser_Const.effect_GTot_lid;
            FStar_Syntax_Syntax.result_typ = t;
            FStar_Syntax_Syntax.effect_args = [];
            FStar_Syntax_Syntax.flags = [FStar_Syntax_Syntax.DECREASES d]
          } in
        FStar_Syntax_Syntax.mk_Comp ct
    | FStar_Reflection_Data.C_Lemma (pre, post, pats) ->
        let ct =
          let uu____1152 =
            let uu____1163 = FStar_Syntax_Syntax.as_arg pre in
            let uu____1172 =
              let uu____1183 = FStar_Syntax_Syntax.as_arg post in
              let uu____1192 =
                let uu____1203 = FStar_Syntax_Syntax.as_arg pats in
                [uu____1203] in
              uu____1183 :: uu____1192 in
            uu____1163 :: uu____1172 in
          {
            FStar_Syntax_Syntax.comp_univs = [];
            FStar_Syntax_Syntax.effect_name =
              FStar_Parser_Const.effect_Lemma_lid;
            FStar_Syntax_Syntax.result_typ = FStar_Syntax_Syntax.t_unit;
            FStar_Syntax_Syntax.effect_args = uu____1152;
            FStar_Syntax_Syntax.flags = []
          } in
        FStar_Syntax_Syntax.mk_Comp ct
    | FStar_Reflection_Data.C_Eff (us, ef, res, args) ->
        let pack_arg uu____1273 =
          match uu____1273 with
          | (a, q) -> let uu____1292 = pack_aqual q in (a, uu____1292) in
        let ct =
          let uu____1296 = FStar_Ident.lid_of_path ef FStar_Range.dummyRange in
          let uu____1297 = FStar_List.map pack_arg args in
          {
            FStar_Syntax_Syntax.comp_univs = [];
            FStar_Syntax_Syntax.effect_name = uu____1296;
            FStar_Syntax_Syntax.result_typ = res;
            FStar_Syntax_Syntax.effect_args = uu____1297;
            FStar_Syntax_Syntax.flags = []
          } in
        FStar_Syntax_Syntax.mk_Comp ct
let (pack_const : FStar_Reflection_Data.vconst -> FStar_Syntax_Syntax.sconst)
  =
  fun c ->
    match c with
    | FStar_Reflection_Data.C_Unit -> FStar_Const.Const_unit
    | FStar_Reflection_Data.C_Int i ->
        let uu____1323 =
          let uu____1335 = FStar_BigInt.string_of_big_int i in
          (uu____1335, FStar_Pervasives_Native.None) in
        FStar_Const.Const_int uu____1323
    | FStar_Reflection_Data.C_True -> FStar_Const.Const_bool true
    | FStar_Reflection_Data.C_False -> FStar_Const.Const_bool false
    | FStar_Reflection_Data.C_String s ->
        FStar_Const.Const_string (s, FStar_Range.dummyRange)
    | FStar_Reflection_Data.C_Range r -> FStar_Const.Const_range r
    | FStar_Reflection_Data.C_Reify -> FStar_Const.Const_reify
    | FStar_Reflection_Data.C_Reflect ns ->
        let uu____1355 = FStar_Ident.lid_of_path ns FStar_Range.dummyRange in
        FStar_Const.Const_reflect uu____1355
let (pack_ln : FStar_Reflection_Data.term_view -> FStar_Syntax_Syntax.term) =
  fun tv ->
    match tv with
    | FStar_Reflection_Data.Tv_Var bv -> FStar_Syntax_Syntax.bv_to_name bv
    | FStar_Reflection_Data.Tv_BVar bv -> FStar_Syntax_Syntax.bv_to_tm bv
    | FStar_Reflection_Data.Tv_FVar fv -> FStar_Syntax_Syntax.fv_to_tm fv
    | FStar_Reflection_Data.Tv_App (l, (r, q)) ->
        let q' = pack_aqual q in FStar_Syntax_Util.mk_app l [(r, q')]
    | FStar_Reflection_Data.Tv_Abs (b, t) ->
        FStar_Syntax_Syntax.mk
          (FStar_Syntax_Syntax.Tm_abs ([b], t, FStar_Pervasives_Native.None))
          t.FStar_Syntax_Syntax.pos
    | FStar_Reflection_Data.Tv_Arrow (b, c) ->
        FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_arrow ([b], c))
          c.FStar_Syntax_Syntax.pos
    | FStar_Reflection_Data.Tv_Type () -> FStar_Syntax_Util.ktype
    | FStar_Reflection_Data.Tv_Refine (bv, t) ->
        FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_refine (bv, t))
          t.FStar_Syntax_Syntax.pos
    | FStar_Reflection_Data.Tv_Const c ->
        let uu____1444 =
          let uu____1445 = pack_const c in
          FStar_Syntax_Syntax.Tm_constant uu____1445 in
        FStar_Syntax_Syntax.mk uu____1444 FStar_Range.dummyRange
    | FStar_Reflection_Data.Tv_Uvar (u, ctx_u_s) ->
        FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_uvar ctx_u_s)
          FStar_Range.dummyRange
    | FStar_Reflection_Data.Tv_Let (false, attrs, bv, t1, t2) ->
        let lb =
          FStar_Syntax_Util.mk_letbinding (FStar_Util.Inl bv) []
            bv.FStar_Syntax_Syntax.sort FStar_Parser_Const.effect_Tot_lid t1
            attrs FStar_Range.dummyRange in
        FStar_Syntax_Syntax.mk
          (FStar_Syntax_Syntax.Tm_let ((false, [lb]), t2))
          FStar_Range.dummyRange
    | FStar_Reflection_Data.Tv_Let (true, attrs, bv, t1, t2) ->
        let lb =
          FStar_Syntax_Util.mk_letbinding (FStar_Util.Inl bv) []
            bv.FStar_Syntax_Syntax.sort FStar_Parser_Const.effect_Tot_lid t1
            attrs FStar_Range.dummyRange in
        FStar_Syntax_Syntax.mk
          (FStar_Syntax_Syntax.Tm_let ((true, [lb]), t2))
          FStar_Range.dummyRange
    | FStar_Reflection_Data.Tv_Match (t, brs) ->
        let wrap v =
          {
            FStar_Syntax_Syntax.v = v;
            FStar_Syntax_Syntax.p = FStar_Range.dummyRange
          } in
        let rec pack_pat p =
          match p with
          | FStar_Reflection_Data.Pat_Constant c ->
              let uu____1517 =
                let uu____1518 = pack_const c in
                FStar_Syntax_Syntax.Pat_constant uu____1518 in
              FStar_All.pipe_left wrap uu____1517
          | FStar_Reflection_Data.Pat_Cons (fv, ps) ->
              let uu____1535 =
                let uu____1536 =
                  let uu____1550 =
                    FStar_List.map
                      (fun uu____1574 ->
                         match uu____1574 with
                         | (p1, b) ->
                             let uu____1589 = pack_pat p1 in (uu____1589, b))
                      ps in
                  (fv, uu____1550) in
                FStar_Syntax_Syntax.Pat_cons uu____1536 in
              FStar_All.pipe_left wrap uu____1535
          | FStar_Reflection_Data.Pat_Var bv ->
              FStar_All.pipe_left wrap (FStar_Syntax_Syntax.Pat_var bv)
          | FStar_Reflection_Data.Pat_Wild bv ->
              FStar_All.pipe_left wrap (FStar_Syntax_Syntax.Pat_wild bv)
          | FStar_Reflection_Data.Pat_Dot_Term (bv, t1) ->
              FStar_All.pipe_left wrap
                (FStar_Syntax_Syntax.Pat_dot_term (bv, t1)) in
        let brs1 =
          FStar_List.map
            (fun uu___2_1637 ->
               match uu___2_1637 with
               | (pat, t1) ->
                   let uu____1654 = pack_pat pat in
                   (uu____1654, FStar_Pervasives_Native.None, t1)) brs in
        FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_match (t, brs1))
          FStar_Range.dummyRange
    | FStar_Reflection_Data.Tv_AscribedT (e, t, tacopt) ->
        FStar_Syntax_Syntax.mk
          (FStar_Syntax_Syntax.Tm_ascribed
             (e, ((FStar_Util.Inl t), tacopt), FStar_Pervasives_Native.None))
          FStar_Range.dummyRange
    | FStar_Reflection_Data.Tv_AscribedC (e, c, tacopt) ->
        FStar_Syntax_Syntax.mk
          (FStar_Syntax_Syntax.Tm_ascribed
             (e, ((FStar_Util.Inr c), tacopt), FStar_Pervasives_Native.None))
          FStar_Range.dummyRange
    | FStar_Reflection_Data.Tv_Unknown ->
        FStar_Syntax_Syntax.mk FStar_Syntax_Syntax.Tm_unknown
          FStar_Range.dummyRange
let (compare_bv :
  FStar_Syntax_Syntax.bv -> FStar_Syntax_Syntax.bv -> FStar_Order.order) =
  fun x ->
    fun y ->
      let n = FStar_Syntax_Syntax.order_bv x y in
      if n < Prims.int_zero
      then FStar_Order.Lt
      else if n = Prims.int_zero then FStar_Order.Eq else FStar_Order.Gt
let (is_free :
  FStar_Syntax_Syntax.bv -> FStar_Syntax_Syntax.term -> Prims.bool) =
  fun x -> fun t -> FStar_Syntax_Util.is_free_in x t
let (lookup_attr :
  FStar_Syntax_Syntax.term ->
    FStar_TypeChecker_Env.env -> FStar_Syntax_Syntax.fv Prims.list)
  =
  fun attr ->
    fun env ->
      let uu____1815 =
        let uu____1816 = FStar_Syntax_Subst.compress attr in
        uu____1816.FStar_Syntax_Syntax.n in
      match uu____1815 with
      | FStar_Syntax_Syntax.Tm_fvar fv ->
          let ses =
            let uu____1825 =
              let uu____1827 = FStar_Syntax_Syntax.lid_of_fv fv in
              FStar_Ident.string_of_lid uu____1827 in
            FStar_TypeChecker_Env.lookup_attr env uu____1825 in
          FStar_List.concatMap
            (fun se ->
               let uu____1831 = FStar_Syntax_Util.lid_of_sigelt se in
               match uu____1831 with
               | FStar_Pervasives_Native.None -> []
               | FStar_Pervasives_Native.Some l ->
                   let uu____1837 =
                     FStar_Syntax_Syntax.lid_as_fv l
                       (FStar_Syntax_Syntax.Delta_constant_at_level
                          (Prims.of_int (999))) FStar_Pervasives_Native.None in
                   [uu____1837]) ses
      | uu____1839 -> []
let (all_defs_in_env :
  FStar_TypeChecker_Env.env -> FStar_Syntax_Syntax.fv Prims.list) =
  fun env ->
    let uu____1850 = FStar_TypeChecker_Env.lidents env in
    FStar_List.map
      (fun l ->
         FStar_Syntax_Syntax.lid_as_fv l
           (FStar_Syntax_Syntax.Delta_constant_at_level (Prims.of_int (999)))
           FStar_Pervasives_Native.None) uu____1850
let (defs_in_module :
  FStar_TypeChecker_Env.env ->
    FStar_Reflection_Data.name -> FStar_Syntax_Syntax.fv Prims.list)
  =
  fun env ->
    fun modul ->
      let uu____1871 = FStar_TypeChecker_Env.lidents env in
      FStar_List.concatMap
        (fun l ->
           let ns =
             let uu____1879 =
               let uu____1882 = FStar_Ident.ids_of_lid l in
               FStar_All.pipe_right uu____1882 init in
             FStar_All.pipe_right uu____1879
               (FStar_List.map FStar_Ident.string_of_id) in
           if ns = modul
           then
             let uu____1895 =
               FStar_Syntax_Syntax.lid_as_fv l
                 (FStar_Syntax_Syntax.Delta_constant_at_level
                    (Prims.of_int (999))) FStar_Pervasives_Native.None in
             [uu____1895]
           else []) uu____1871
let (lookup_typ :
  FStar_TypeChecker_Env.env ->
    Prims.string Prims.list ->
      FStar_Syntax_Syntax.sigelt FStar_Pervasives_Native.option)
  =
  fun env ->
    fun ns ->
      let lid = FStar_Parser_Const.p2l ns in
      FStar_TypeChecker_Env.lookup_sigelt env lid
let (sigelt_attrs :
  FStar_Syntax_Syntax.sigelt -> FStar_Syntax_Syntax.attribute Prims.list) =
  fun se -> se.FStar_Syntax_Syntax.sigattrs
let (set_sigelt_attrs :
  FStar_Syntax_Syntax.attribute Prims.list ->
    FStar_Syntax_Syntax.sigelt -> FStar_Syntax_Syntax.sigelt)
  =
  fun attrs ->
    fun se ->
      let uu___423_1946 = se in
      {
        FStar_Syntax_Syntax.sigel = (uu___423_1946.FStar_Syntax_Syntax.sigel);
        FStar_Syntax_Syntax.sigrng =
          (uu___423_1946.FStar_Syntax_Syntax.sigrng);
        FStar_Syntax_Syntax.sigquals =
          (uu___423_1946.FStar_Syntax_Syntax.sigquals);
        FStar_Syntax_Syntax.sigmeta =
          (uu___423_1946.FStar_Syntax_Syntax.sigmeta);
        FStar_Syntax_Syntax.sigattrs = attrs;
        FStar_Syntax_Syntax.sigopts =
          (uu___423_1946.FStar_Syntax_Syntax.sigopts)
      }
let (rd_to_syntax_qual :
  FStar_Reflection_Data.qualifier -> FStar_Syntax_Syntax.qualifier) =
  fun uu___3_1952 ->
    match uu___3_1952 with
    | FStar_Reflection_Data.Assumption -> FStar_Syntax_Syntax.Assumption
    | FStar_Reflection_Data.New -> FStar_Syntax_Syntax.New
    | FStar_Reflection_Data.Private -> FStar_Syntax_Syntax.Private
    | FStar_Reflection_Data.Unfold_for_unification_and_vcgen ->
        FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen
    | FStar_Reflection_Data.Visible_default ->
        FStar_Syntax_Syntax.Visible_default
    | FStar_Reflection_Data.Irreducible -> FStar_Syntax_Syntax.Irreducible
    | FStar_Reflection_Data.Abstract -> FStar_Syntax_Syntax.Abstract
    | FStar_Reflection_Data.Inline_for_extraction ->
        FStar_Syntax_Syntax.Inline_for_extraction
    | FStar_Reflection_Data.NoExtract -> FStar_Syntax_Syntax.NoExtract
    | FStar_Reflection_Data.Noeq -> FStar_Syntax_Syntax.Noeq
    | FStar_Reflection_Data.Unopteq -> FStar_Syntax_Syntax.Unopteq
    | FStar_Reflection_Data.TotalEffect -> FStar_Syntax_Syntax.TotalEffect
    | FStar_Reflection_Data.Logic -> FStar_Syntax_Syntax.Logic
    | FStar_Reflection_Data.Reifiable -> FStar_Syntax_Syntax.Reifiable
    | FStar_Reflection_Data.Reflectable l ->
        FStar_Syntax_Syntax.Reflectable l
    | FStar_Reflection_Data.Discriminator l ->
        FStar_Syntax_Syntax.Discriminator l
    | FStar_Reflection_Data.Projector (l, i) ->
        FStar_Syntax_Syntax.Projector (l, i)
    | FStar_Reflection_Data.RecordType (l1, l2) ->
        FStar_Syntax_Syntax.RecordType (l1, l2)
    | FStar_Reflection_Data.RecordConstructor (l1, l2) ->
        FStar_Syntax_Syntax.RecordConstructor (l1, l2)
    | FStar_Reflection_Data.Action l -> FStar_Syntax_Syntax.Action l
    | FStar_Reflection_Data.ExceptionConstructor ->
        FStar_Syntax_Syntax.ExceptionConstructor
    | FStar_Reflection_Data.HasMaskedEffect ->
        FStar_Syntax_Syntax.HasMaskedEffect
    | FStar_Reflection_Data.Effect -> FStar_Syntax_Syntax.Effect
    | FStar_Reflection_Data.OnlyName -> FStar_Syntax_Syntax.OnlyName
let (syntax_to_rd_qual :
  FStar_Syntax_Syntax.qualifier -> FStar_Reflection_Data.qualifier) =
  fun uu___4_1991 ->
    match uu___4_1991 with
    | FStar_Syntax_Syntax.Assumption -> FStar_Reflection_Data.Assumption
    | FStar_Syntax_Syntax.New -> FStar_Reflection_Data.New
    | FStar_Syntax_Syntax.Private -> FStar_Reflection_Data.Private
    | FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen ->
        FStar_Reflection_Data.Unfold_for_unification_and_vcgen
    | FStar_Syntax_Syntax.Visible_default ->
        FStar_Reflection_Data.Visible_default
    | FStar_Syntax_Syntax.Irreducible -> FStar_Reflection_Data.Irreducible
    | FStar_Syntax_Syntax.Abstract -> FStar_Reflection_Data.Abstract
    | FStar_Syntax_Syntax.Inline_for_extraction ->
        FStar_Reflection_Data.Inline_for_extraction
    | FStar_Syntax_Syntax.NoExtract -> FStar_Reflection_Data.NoExtract
    | FStar_Syntax_Syntax.Noeq -> FStar_Reflection_Data.Noeq
    | FStar_Syntax_Syntax.Unopteq -> FStar_Reflection_Data.Unopteq
    | FStar_Syntax_Syntax.TotalEffect -> FStar_Reflection_Data.TotalEffect
    | FStar_Syntax_Syntax.Logic -> FStar_Reflection_Data.Logic
    | FStar_Syntax_Syntax.Reifiable -> FStar_Reflection_Data.Reifiable
    | FStar_Syntax_Syntax.Reflectable l ->
        FStar_Reflection_Data.Reflectable l
    | FStar_Syntax_Syntax.Discriminator l ->
        FStar_Reflection_Data.Discriminator l
    | FStar_Syntax_Syntax.Projector (l, i) ->
        FStar_Reflection_Data.Projector (l, i)
    | FStar_Syntax_Syntax.RecordType (l1, l2) ->
        FStar_Reflection_Data.RecordType (l1, l2)
    | FStar_Syntax_Syntax.RecordConstructor (l1, l2) ->
        FStar_Reflection_Data.RecordConstructor (l1, l2)
    | FStar_Syntax_Syntax.Action l -> FStar_Reflection_Data.Action l
    | FStar_Syntax_Syntax.ExceptionConstructor ->
        FStar_Reflection_Data.ExceptionConstructor
    | FStar_Syntax_Syntax.HasMaskedEffect ->
        FStar_Reflection_Data.HasMaskedEffect
    | FStar_Syntax_Syntax.Effect -> FStar_Reflection_Data.Effect
    | FStar_Syntax_Syntax.OnlyName -> FStar_Reflection_Data.OnlyName
let (sigelt_quals :
  FStar_Syntax_Syntax.sigelt -> FStar_Reflection_Data.qualifier Prims.list) =
  fun se ->
    FStar_All.pipe_right se.FStar_Syntax_Syntax.sigquals
      (FStar_List.map syntax_to_rd_qual)
let (set_sigelt_quals :
  FStar_Reflection_Data.qualifier Prims.list ->
    FStar_Syntax_Syntax.sigelt -> FStar_Syntax_Syntax.sigelt)
  =
  fun quals ->
    fun se ->
      let uu___502_2054 = se in
      let uu____2055 = FStar_List.map rd_to_syntax_qual quals in
      {
        FStar_Syntax_Syntax.sigel = (uu___502_2054.FStar_Syntax_Syntax.sigel);
        FStar_Syntax_Syntax.sigrng =
          (uu___502_2054.FStar_Syntax_Syntax.sigrng);
        FStar_Syntax_Syntax.sigquals = uu____2055;
        FStar_Syntax_Syntax.sigmeta =
          (uu___502_2054.FStar_Syntax_Syntax.sigmeta);
        FStar_Syntax_Syntax.sigattrs =
          (uu___502_2054.FStar_Syntax_Syntax.sigattrs);
        FStar_Syntax_Syntax.sigopts =
          (uu___502_2054.FStar_Syntax_Syntax.sigopts)
      }
let (e_optionstate_hook :
  FStar_Options.optionstate FStar_Syntax_Embeddings.embedding
    FStar_Pervasives_Native.option FStar_ST.ref)
  = FStar_Util.mk_ref FStar_Pervasives_Native.None
let (sigelt_opts :
  FStar_Syntax_Syntax.sigelt ->
    FStar_Syntax_Syntax.term FStar_Pervasives_Native.option)
  =
  fun se ->
    match se.FStar_Syntax_Syntax.sigopts with
    | FStar_Pervasives_Native.None -> FStar_Pervasives_Native.None
    | FStar_Pervasives_Native.Some o ->
        let uu____2088 =
          let uu____2089 =
            let uu____2096 =
              let uu____2099 = FStar_ST.op_Bang e_optionstate_hook in
              FStar_All.pipe_right uu____2099 FStar_Util.must in
            FStar_Syntax_Embeddings.embed uu____2096 o in
          uu____2089 FStar_Range.dummyRange FStar_Pervasives_Native.None
            FStar_Syntax_Embeddings.id_norm_cb in
        FStar_Pervasives_Native.Some uu____2088
let (inspect_sigelt :
  FStar_Syntax_Syntax.sigelt -> FStar_Reflection_Data.sigelt_view) =
  fun se ->
    match se.FStar_Syntax_Syntax.sigel with
    | FStar_Syntax_Syntax.Sig_let ((r, lb::[]), uu____2149) ->
        let fv =
          match lb.FStar_Syntax_Syntax.lbname with
          | FStar_Util.Inr fv -> fv
          | FStar_Util.Inl uu____2160 ->
              failwith "impossible: global Sig_let has bv" in
        let uu____2162 =
          FStar_Syntax_Subst.univ_var_opening lb.FStar_Syntax_Syntax.lbunivs in
        (match uu____2162 with
         | (s, us) ->
             let typ =
               FStar_Syntax_Subst.subst s lb.FStar_Syntax_Syntax.lbtyp in
             let def =
               FStar_Syntax_Subst.subst s lb.FStar_Syntax_Syntax.lbdef in
             FStar_Reflection_Data.Sg_Let
               (r, fv, (lb.FStar_Syntax_Syntax.lbunivs),
                 (lb.FStar_Syntax_Syntax.lbtyp),
                 (lb.FStar_Syntax_Syntax.lbdef)))
    | FStar_Syntax_Syntax.Sig_inductive_typ
        (lid, us, bs, ty, uu____2190, c_lids) ->
        let nm = FStar_Ident.path_of_lid lid in
        let uu____2201 = FStar_Syntax_Subst.univ_var_opening us in
        (match uu____2201 with
         | (s, us1) ->
             let bs1 = FStar_Syntax_Subst.subst_binders s bs in
             let ty1 = FStar_Syntax_Subst.subst s ty in
             let uu____2222 =
               let uu____2239 = FStar_List.map FStar_Ident.path_of_lid c_lids in
               (nm, us1, bs1, ty1, uu____2239) in
             FStar_Reflection_Data.Sg_Inductive uu____2222)
    | FStar_Syntax_Syntax.Sig_datacon
        (lid, us, ty, uu____2251, n, uu____2253) ->
        let uu____2260 = FStar_Syntax_Subst.univ_var_opening us in
        (match uu____2260 with
         | (s, us1) ->
             let ty1 = FStar_Syntax_Subst.subst s ty in
             let ty2 = FStar_Syntax_Util.remove_inacc ty1 in
             let uu____2281 =
               let uu____2286 = FStar_Ident.path_of_lid lid in
               (uu____2286, ty2) in
             FStar_Reflection_Data.Sg_Constructor uu____2281)
    | uu____2287 -> FStar_Reflection_Data.Unk
let (pack_sigelt :
  FStar_Reflection_Data.sigelt_view -> FStar_Syntax_Syntax.sigelt) =
  fun sv ->
    match sv with
    | FStar_Reflection_Data.Sg_Let (r, fv, univs, typ, def) ->
        let s = FStar_Syntax_Subst.univ_var_closing univs in
        let typ1 = FStar_Syntax_Subst.subst s typ in
        let def1 = FStar_Syntax_Subst.subst s def in
        let lb =
          FStar_Syntax_Util.mk_letbinding (FStar_Util.Inr fv) univs typ1
            FStar_Parser_Const.effect_Tot_lid def1 []
            def1.FStar_Syntax_Syntax.pos in
        let uu____2313 =
          let uu____2314 =
            let uu____2321 =
              let uu____2324 = FStar_Syntax_Syntax.lid_of_fv fv in
              [uu____2324] in
            ((r, [lb]), uu____2321) in
          FStar_Syntax_Syntax.Sig_let uu____2314 in
        FStar_All.pipe_left FStar_Syntax_Syntax.mk_sigelt uu____2313
    | FStar_Reflection_Data.Sg_Constructor uu____2330 ->
        failwith "packing Sg_Constructor, sorry"
    | FStar_Reflection_Data.Sg_Inductive uu____2336 ->
        failwith "packing Sg_Inductive, sorry"
    | FStar_Reflection_Data.Unk -> failwith "packing Unk, sorry"
let (inspect_bv : FStar_Syntax_Syntax.bv -> FStar_Reflection_Data.bv_view) =
  fun bv ->
    let uu____2361 = FStar_Ident.string_of_id bv.FStar_Syntax_Syntax.ppname in
    let uu____2363 = FStar_BigInt.of_int_fs bv.FStar_Syntax_Syntax.index in
    {
      FStar_Reflection_Data.bv_ppname = uu____2361;
      FStar_Reflection_Data.bv_index = uu____2363;
      FStar_Reflection_Data.bv_sort = (bv.FStar_Syntax_Syntax.sort)
    }
let (pack_bv : FStar_Reflection_Data.bv_view -> FStar_Syntax_Syntax.bv) =
  fun bvv ->
    let uu____2370 =
      FStar_Ident.mk_ident
        ((bvv.FStar_Reflection_Data.bv_ppname), FStar_Range.dummyRange) in
    let uu____2372 =
      FStar_BigInt.to_int_fs bvv.FStar_Reflection_Data.bv_index in
    {
      FStar_Syntax_Syntax.ppname = uu____2370;
      FStar_Syntax_Syntax.index = uu____2372;
      FStar_Syntax_Syntax.sort = (bvv.FStar_Reflection_Data.bv_sort)
    }
let (inspect_binder :
  FStar_Syntax_Syntax.binder ->
    (FStar_Syntax_Syntax.bv * FStar_Reflection_Data.aqualv))
  =
  fun b ->
    let uu____2388 = b in
    match uu____2388 with
    | (bv, aq) -> let uu____2399 = inspect_aqual aq in (bv, uu____2399)
let (pack_binder :
  FStar_Syntax_Syntax.bv ->
    FStar_Reflection_Data.aqualv -> FStar_Syntax_Syntax.binder)
  = fun bv -> fun aqv -> let uu____2411 = pack_aqual aqv in (bv, uu____2411)
let (moduleof : FStar_TypeChecker_Env.env -> Prims.string Prims.list) =
  fun e -> FStar_Ident.path_of_lid e.FStar_TypeChecker_Env.curmodule
let (env_open_modules :
  FStar_TypeChecker_Env.env -> FStar_Reflection_Data.name Prims.list) =
  fun e ->
    let uu____2438 =
      FStar_Syntax_DsEnv.open_modules e.FStar_TypeChecker_Env.dsenv in
    FStar_List.map
      (fun uu____2456 ->
         match uu____2456 with
         | (l, m) ->
             let uu____2466 = FStar_Ident.ids_of_lid l in
             FStar_List.map FStar_Ident.string_of_id uu____2466) uu____2438
let (binders_of_env :
  FStar_TypeChecker_Env.env -> FStar_Syntax_Syntax.binders) =
  fun e -> FStar_TypeChecker_Env.all_binders e
let (term_eq :
  FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.bool) =
  fun t1 ->
    fun t2 ->
      let uu____2488 = FStar_Syntax_Util.un_uinst t1 in
      let uu____2489 = FStar_Syntax_Util.un_uinst t2 in
      FStar_Syntax_Util.term_eq uu____2488 uu____2489
let (term_to_string : FStar_Syntax_Syntax.term -> Prims.string) =
  fun t -> FStar_Syntax_Print.term_to_string t
let (comp_to_string : FStar_Syntax_Syntax.comp -> Prims.string) =
  fun c -> FStar_Syntax_Print.comp_to_string c
let (implode_qn : Prims.string Prims.list -> Prims.string) =
  fun ns -> FStar_String.concat "." ns
let (explode_qn : Prims.string -> Prims.string Prims.list) =
  fun s -> FStar_String.split [46] s
let (compare_string : Prims.string -> Prims.string -> FStar_BigInt.t) =
  fun s1 -> fun s2 -> FStar_BigInt.of_int_fs (FStar_String.compare s1 s2)
let (push_binder :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.binder -> FStar_TypeChecker_Env.env)
  = fun e -> fun b -> FStar_TypeChecker_Env.push_binders e [b]