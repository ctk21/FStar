open Prims
type annotated_pat =
  (FStar_Syntax_Syntax.pat * (FStar_Syntax_Syntax.bv *
    FStar_Syntax_Syntax.typ) Prims.list)
let (desugar_disjunctive_pattern :
  (FStar_Syntax_Syntax.pat' FStar_Syntax_Syntax.withinfo_t *
    (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.term'
    FStar_Syntax_Syntax.syntax) Prims.list) Prims.list ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax
      FStar_Pervasives_Native.option ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.branch Prims.list)
  =
  fun annotated_pats  ->
    fun when_opt  ->
      fun branch1  ->
        FStar_All.pipe_right annotated_pats
          (FStar_List.map
             (fun uu____103  ->
                match uu____103 with
                | (pat,annots) ->
                    let branch2 =
                      FStar_List.fold_left
                        (fun br  ->
                           fun uu____158  ->
                             match uu____158 with
                             | (bv,ty) ->
                                 let lb =
                                   let uu____176 =
                                     FStar_Syntax_Syntax.bv_to_name bv  in
                                   FStar_Syntax_Util.mk_letbinding
                                     (FStar_Util.Inl bv) [] ty
                                     FStar_Parser_Const.effect_Tot_lid
                                     uu____176 [] br.FStar_Syntax_Syntax.pos
                                    in
                                 let branch2 =
                                   let uu____182 =
                                     let uu____183 =
                                       FStar_Syntax_Syntax.mk_binder bv  in
                                     [uu____183]  in
                                   FStar_Syntax_Subst.close uu____182 branch1
                                    in
                                 FStar_Syntax_Syntax.mk
                                   (FStar_Syntax_Syntax.Tm_let
                                      ((false, [lb]), branch2))
                                   FStar_Pervasives_Native.None
                                   br.FStar_Syntax_Syntax.pos) branch1 annots
                       in
                    FStar_Syntax_Util.branch (pat, when_opt, branch2)))
  
let (trans_qual :
  FStar_Range.range ->
    FStar_Ident.lident FStar_Pervasives_Native.option ->
      FStar_Parser_AST.qualifier -> FStar_Syntax_Syntax.qualifier)
  =
  fun r  ->
    fun maybe_effect_id  ->
      fun uu___0_240  ->
        match uu___0_240 with
        | FStar_Parser_AST.Private  -> FStar_Syntax_Syntax.Private
        | FStar_Parser_AST.Assumption  -> FStar_Syntax_Syntax.Assumption
        | FStar_Parser_AST.Unfold_for_unification_and_vcgen  ->
            FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen
        | FStar_Parser_AST.Inline_for_extraction  ->
            FStar_Syntax_Syntax.Inline_for_extraction
        | FStar_Parser_AST.NoExtract  -> FStar_Syntax_Syntax.NoExtract
        | FStar_Parser_AST.Irreducible  -> FStar_Syntax_Syntax.Irreducible
        | FStar_Parser_AST.Logic  -> FStar_Syntax_Syntax.Logic
        | FStar_Parser_AST.TotalEffect  -> FStar_Syntax_Syntax.TotalEffect
        | FStar_Parser_AST.Effect_qual  -> FStar_Syntax_Syntax.Effect
        | FStar_Parser_AST.New  -> FStar_Syntax_Syntax.New
        | FStar_Parser_AST.Abstract  -> FStar_Syntax_Syntax.Abstract
        | FStar_Parser_AST.Opaque  ->
            (FStar_Errors.log_issue r
               (FStar_Errors.Warning_DeprecatedOpaqueQualifier,
                 "The 'opaque' qualifier is deprecated since its use was strangely schizophrenic. There were two overloaded uses: (1) Given 'opaque val f : t', the behavior was to exclude the definition of 'f' to the SMT solver. This corresponds roughly to the new 'irreducible' qualifier. (2) Given 'opaque type t = t'', the behavior was to provide the definition of 't' to the SMT solver, but not to inline it, unless absolutely required for unification. This corresponds roughly to the behavior of 'unfoldable' (which is currently the default).");
             FStar_Syntax_Syntax.Visible_default)
        | FStar_Parser_AST.Reflectable  ->
            (match maybe_effect_id with
             | FStar_Pervasives_Native.None  ->
                 FStar_Errors.raise_error
                   (FStar_Errors.Fatal_ReflectOnlySupportedOnEffects,
                     "Qualifier reflect only supported on effects") r
             | FStar_Pervasives_Native.Some effect_id ->
                 FStar_Syntax_Syntax.Reflectable effect_id)
        | FStar_Parser_AST.Reifiable  -> FStar_Syntax_Syntax.Reifiable
        | FStar_Parser_AST.Noeq  -> FStar_Syntax_Syntax.Noeq
        | FStar_Parser_AST.Unopteq  -> FStar_Syntax_Syntax.Unopteq
        | FStar_Parser_AST.DefaultEffect  ->
            FStar_Errors.raise_error
              (FStar_Errors.Fatal_DefaultQualifierNotAllowedOnEffects,
                "The 'default' qualifier on effects is no longer supported")
              r
        | FStar_Parser_AST.Inline  ->
            FStar_Errors.raise_error
              (FStar_Errors.Fatal_UnsupportedQualifier,
                "Unsupported qualifier") r
        | FStar_Parser_AST.Visible  ->
            FStar_Errors.raise_error
              (FStar_Errors.Fatal_UnsupportedQualifier,
                "Unsupported qualifier") r
  
let (trans_pragma : FStar_Parser_AST.pragma -> FStar_Syntax_Syntax.pragma) =
  fun uu___1_260  ->
    match uu___1_260 with
    | FStar_Parser_AST.SetOptions s -> FStar_Syntax_Syntax.SetOptions s
    | FStar_Parser_AST.ResetOptions sopt ->
        FStar_Syntax_Syntax.ResetOptions sopt
    | FStar_Parser_AST.PushOptions sopt ->
        FStar_Syntax_Syntax.PushOptions sopt
    | FStar_Parser_AST.PopOptions  -> FStar_Syntax_Syntax.PopOptions
    | FStar_Parser_AST.RestartSolver  -> FStar_Syntax_Syntax.RestartSolver
    | FStar_Parser_AST.LightOff  -> FStar_Syntax_Syntax.LightOff
  
let (as_imp :
  FStar_Parser_AST.imp ->
    FStar_Syntax_Syntax.arg_qualifier FStar_Pervasives_Native.option)
  =
  fun uu___2_278  ->
    match uu___2_278 with
    | FStar_Parser_AST.Hash  ->
        FStar_Pervasives_Native.Some FStar_Syntax_Syntax.imp_tag
    | uu____281 -> FStar_Pervasives_Native.None
  
let arg_withimp_e :
  'Auu____289 .
    FStar_Parser_AST.imp ->
      'Auu____289 ->
        ('Auu____289 * FStar_Syntax_Syntax.arg_qualifier
          FStar_Pervasives_Native.option)
  = fun imp  -> fun t  -> (t, (as_imp imp)) 
let arg_withimp_t :
  'Auu____315 .
    FStar_Parser_AST.imp ->
      'Auu____315 ->
        ('Auu____315 * FStar_Syntax_Syntax.arg_qualifier
          FStar_Pervasives_Native.option)
  =
  fun imp  ->
    fun t  ->
      match imp with
      | FStar_Parser_AST.Hash  ->
          (t, (FStar_Pervasives_Native.Some FStar_Syntax_Syntax.imp_tag))
      | uu____334 -> (t, FStar_Pervasives_Native.None)
  
let (contains_binder : FStar_Parser_AST.binder Prims.list -> Prims.bool) =
  fun binders  ->
    FStar_All.pipe_right binders
      (FStar_Util.for_some
         (fun b  ->
            match b.FStar_Parser_AST.b with
            | FStar_Parser_AST.Annotated uu____355 -> true
            | uu____361 -> false))
  
let rec (unparen : FStar_Parser_AST.term -> FStar_Parser_AST.term) =
  fun t  ->
    match t.FStar_Parser_AST.tm with
    | FStar_Parser_AST.Paren t1 -> unparen t1
    | uu____370 -> t
  
let (tm_type_z : FStar_Range.range -> FStar_Parser_AST.term) =
  fun r  ->
    let uu____377 =
      let uu____378 = FStar_Ident.lid_of_path ["Type0"] r  in
      FStar_Parser_AST.Name uu____378  in
    FStar_Parser_AST.mk_term uu____377 r FStar_Parser_AST.Kind
  
let (tm_type : FStar_Range.range -> FStar_Parser_AST.term) =
  fun r  ->
    let uu____388 =
      let uu____389 = FStar_Ident.lid_of_path ["Type"] r  in
      FStar_Parser_AST.Name uu____389  in
    FStar_Parser_AST.mk_term uu____388 r FStar_Parser_AST.Kind
  
let rec (is_comp_type :
  FStar_Syntax_DsEnv.env -> FStar_Parser_AST.term -> Prims.bool) =
  fun env  ->
    fun t  ->
      let uu____405 =
        let uu____406 = unparen t  in uu____406.FStar_Parser_AST.tm  in
      match uu____405 with
      | FStar_Parser_AST.Name l ->
          let uu____409 = FStar_Syntax_DsEnv.try_lookup_effect_name env l  in
          FStar_All.pipe_right uu____409 FStar_Option.isSome
      | FStar_Parser_AST.Construct (l,uu____416) ->
          let uu____429 = FStar_Syntax_DsEnv.try_lookup_effect_name env l  in
          FStar_All.pipe_right uu____429 FStar_Option.isSome
      | FStar_Parser_AST.App (head1,uu____436,uu____437) ->
          is_comp_type env head1
      | FStar_Parser_AST.Paren t1 -> failwith "impossible"
      | FStar_Parser_AST.Ascribed (t1,uu____442,uu____443) ->
          is_comp_type env t1
      | FStar_Parser_AST.LetOpen (uu____448,t1) -> is_comp_type env t1
      | uu____450 -> false
  
let (unit_ty : FStar_Parser_AST.term) =
  FStar_Parser_AST.mk_term
    (FStar_Parser_AST.Name FStar_Parser_Const.unit_lid)
    FStar_Range.dummyRange FStar_Parser_AST.Type_level
  
type env_t = FStar_Syntax_DsEnv.env
type lenv_t = FStar_Syntax_Syntax.bv Prims.list
let (desugar_name' :
  (FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term) ->
    env_t ->
      Prims.bool ->
        FStar_Ident.lid ->
          FStar_Syntax_Syntax.term FStar_Pervasives_Native.option)
  =
  fun setpos  ->
    fun env  ->
      fun resolve  ->
        fun l  ->
          let tm_attrs_opt =
            if resolve
            then FStar_Syntax_DsEnv.try_lookup_lid_with_attributes env l
            else
              FStar_Syntax_DsEnv.try_lookup_lid_with_attributes_no_resolve
                env l
             in
          match tm_attrs_opt with
          | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
          | FStar_Pervasives_Native.Some (tm,attrs) ->
              let warn_if_deprecated attrs1 =
                FStar_List.iter
                  (fun a  ->
                     match a.FStar_Syntax_Syntax.n with
                     | FStar_Syntax_Syntax.Tm_app
                         ({
                            FStar_Syntax_Syntax.n =
                              FStar_Syntax_Syntax.Tm_fvar fv;
                            FStar_Syntax_Syntax.pos = uu____551;
                            FStar_Syntax_Syntax.vars = uu____552;_},args)
                         when
                         FStar_Ident.lid_equals
                           (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                           FStar_Parser_Const.deprecated_attr
                         ->
                         let msg =
                           let uu____580 =
                             FStar_Syntax_Print.term_to_string tm  in
                           Prims.op_Hat uu____580 " is deprecated"  in
                         let msg1 =
                           if (FStar_List.length args) > Prims.int_zero
                           then
                             let uu____596 =
                               let uu____597 =
                                 let uu____600 = FStar_List.hd args  in
                                 FStar_Pervasives_Native.fst uu____600  in
                               uu____597.FStar_Syntax_Syntax.n  in
                             match uu____596 with
                             | FStar_Syntax_Syntax.Tm_constant
                                 (FStar_Const.Const_string (s,uu____623))
                                 when
                                 Prims.op_Negation
                                   ((FStar_Util.trim_string s) = "")
                                 ->
                                 Prims.op_Hat msg
                                   (Prims.op_Hat ", use "
                                      (Prims.op_Hat s " instead"))
                             | uu____630 -> msg
                           else msg  in
                         let uu____633 = FStar_Ident.range_of_lid l  in
                         FStar_Errors.log_issue uu____633
                           (FStar_Errors.Warning_DeprecatedDefinition, msg1)
                     | FStar_Syntax_Syntax.Tm_fvar fv when
                         FStar_Ident.lid_equals
                           (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                           FStar_Parser_Const.deprecated_attr
                         ->
                         let msg =
                           let uu____638 =
                             FStar_Syntax_Print.term_to_string tm  in
                           Prims.op_Hat uu____638 " is deprecated"  in
                         let uu____641 = FStar_Ident.range_of_lid l  in
                         FStar_Errors.log_issue uu____641
                           (FStar_Errors.Warning_DeprecatedDefinition, msg)
                     | uu____643 -> ()) attrs1
                 in
              (warn_if_deprecated attrs;
               (let tm1 = setpos tm  in FStar_Pervasives_Native.Some tm1))
  
let desugar_name :
  'Auu____659 .
    'Auu____659 ->
      (FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term) ->
        env_t -> Prims.bool -> FStar_Ident.lident -> FStar_Syntax_Syntax.term
  =
  fun mk1  ->
    fun setpos  ->
      fun env  ->
        fun resolve  ->
          fun l  ->
            FStar_Syntax_DsEnv.fail_or env (desugar_name' setpos env resolve)
              l
  
let (compile_op_lid :
  Prims.int -> Prims.string -> FStar_Range.range -> FStar_Ident.lident) =
  fun n1  ->
    fun s  ->
      fun r  ->
        let uu____712 =
          let uu____715 =
            let uu____716 =
              let uu____722 = FStar_Parser_AST.compile_op n1 s r  in
              (uu____722, r)  in
            FStar_Ident.mk_ident uu____716  in
          [uu____715]  in
        FStar_All.pipe_right uu____712 FStar_Ident.lid_of_ids
  
let op_as_term :
  'Auu____738 .
    env_t ->
      Prims.int ->
        'Auu____738 ->
          FStar_Ident.ident ->
            FStar_Syntax_Syntax.term FStar_Pervasives_Native.option
  =
  fun env  ->
    fun arity  ->
      fun rng  ->
        fun op  ->
          let r l dd =
            let uu____776 =
              let uu____777 =
                let uu____778 =
                  FStar_Ident.set_lid_range l op.FStar_Ident.idRange  in
                FStar_Syntax_Syntax.lid_as_fv uu____778 dd
                  FStar_Pervasives_Native.None
                 in
              FStar_All.pipe_right uu____777 FStar_Syntax_Syntax.fv_to_tm  in
            FStar_Pervasives_Native.Some uu____776  in
          let fallback uu____786 =
            let uu____787 = FStar_Ident.text_of_id op  in
            match uu____787 with
            | "=" ->
                r FStar_Parser_Const.op_Eq
                  FStar_Syntax_Syntax.delta_equational
            | ":=" ->
                r FStar_Parser_Const.write_lid
                  FStar_Syntax_Syntax.delta_equational
            | "<" ->
                r FStar_Parser_Const.op_LT
                  FStar_Syntax_Syntax.delta_equational
            | "<=" ->
                r FStar_Parser_Const.op_LTE
                  FStar_Syntax_Syntax.delta_equational
            | ">" ->
                r FStar_Parser_Const.op_GT
                  FStar_Syntax_Syntax.delta_equational
            | ">=" ->
                r FStar_Parser_Const.op_GTE
                  FStar_Syntax_Syntax.delta_equational
            | "&&" ->
                r FStar_Parser_Const.op_And
                  FStar_Syntax_Syntax.delta_equational
            | "||" ->
                r FStar_Parser_Const.op_Or
                  FStar_Syntax_Syntax.delta_equational
            | "+" ->
                r FStar_Parser_Const.op_Addition
                  FStar_Syntax_Syntax.delta_equational
            | "-" when arity = Prims.int_one ->
                r FStar_Parser_Const.op_Minus
                  FStar_Syntax_Syntax.delta_equational
            | "-" ->
                r FStar_Parser_Const.op_Subtraction
                  FStar_Syntax_Syntax.delta_equational
            | "/" ->
                r FStar_Parser_Const.op_Division
                  FStar_Syntax_Syntax.delta_equational
            | "%" ->
                r FStar_Parser_Const.op_Modulus
                  FStar_Syntax_Syntax.delta_equational
            | "!" ->
                r FStar_Parser_Const.read_lid
                  FStar_Syntax_Syntax.delta_equational
            | "@" ->
                let uu____808 = FStar_Options.ml_ish ()  in
                if uu____808
                then
                  r FStar_Parser_Const.list_append_lid
                    (FStar_Syntax_Syntax.Delta_equational_at_level
                       (Prims.of_int (2)))
                else
                  r FStar_Parser_Const.list_tot_append_lid
                    (FStar_Syntax_Syntax.Delta_equational_at_level
                       (Prims.of_int (2)))
            | "|>" ->
                r FStar_Parser_Const.pipe_right_lid
                  FStar_Syntax_Syntax.delta_equational
            | "<|" ->
                r FStar_Parser_Const.pipe_left_lid
                  FStar_Syntax_Syntax.delta_equational
            | "<>" ->
                r FStar_Parser_Const.op_notEq
                  FStar_Syntax_Syntax.delta_equational
            | "~" ->
                r FStar_Parser_Const.not_lid
                  (FStar_Syntax_Syntax.Delta_constant_at_level
                     (Prims.of_int (2)))
            | "==" ->
                r FStar_Parser_Const.eq2_lid
                  (FStar_Syntax_Syntax.Delta_constant_at_level
                     (Prims.of_int (2)))
            | "<<" ->
                r FStar_Parser_Const.precedes_lid
                  FStar_Syntax_Syntax.delta_constant
            | "/\\" ->
                r FStar_Parser_Const.and_lid
                  (FStar_Syntax_Syntax.Delta_constant_at_level Prims.int_one)
            | "\\/" ->
                r FStar_Parser_Const.or_lid
                  (FStar_Syntax_Syntax.Delta_constant_at_level Prims.int_one)
            | "==>" ->
                r FStar_Parser_Const.imp_lid
                  (FStar_Syntax_Syntax.Delta_constant_at_level Prims.int_one)
            | "<==>" ->
                r FStar_Parser_Const.iff_lid
                  (FStar_Syntax_Syntax.Delta_constant_at_level
                     (Prims.of_int (2)))
            | uu____833 -> FStar_Pervasives_Native.None  in
          let uu____835 =
            let uu____838 =
              compile_op_lid arity op.FStar_Ident.idText
                op.FStar_Ident.idRange
               in
            desugar_name'
              (fun t  ->
                 let uu___203_844 = t  in
                 {
                   FStar_Syntax_Syntax.n =
                     (uu___203_844.FStar_Syntax_Syntax.n);
                   FStar_Syntax_Syntax.pos = (op.FStar_Ident.idRange);
                   FStar_Syntax_Syntax.vars =
                     (uu___203_844.FStar_Syntax_Syntax.vars)
                 }) env true uu____838
             in
          match uu____835 with
          | FStar_Pervasives_Native.Some t -> FStar_Pervasives_Native.Some t
          | uu____849 -> fallback ()
  
let (sort_ftv : FStar_Ident.ident Prims.list -> FStar_Ident.ident Prims.list)
  =
  fun ftv  ->
    let uu____864 =
      FStar_Util.remove_dups
        (fun x  -> fun y  -> x.FStar_Ident.idText = y.FStar_Ident.idText) ftv
       in
    FStar_All.pipe_left
      (FStar_Util.sort_with
         (fun x  ->
            fun y  ->
              FStar_String.compare x.FStar_Ident.idText y.FStar_Ident.idText))
      uu____864
  
let rec (free_type_vars_b :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.binder ->
      (FStar_Syntax_DsEnv.env * FStar_Ident.ident Prims.list))
  =
  fun env  ->
    fun binder  ->
      match binder.FStar_Parser_AST.b with
      | FStar_Parser_AST.Variable uu____913 -> (env, [])
      | FStar_Parser_AST.TVariable x ->
          let uu____917 = FStar_Syntax_DsEnv.push_bv env x  in
          (match uu____917 with | (env1,uu____929) -> (env1, [x]))
      | FStar_Parser_AST.Annotated (uu____932,term) ->
          let uu____934 = free_type_vars env term  in (env, uu____934)
      | FStar_Parser_AST.TAnnotated (id1,uu____940) ->
          let uu____941 = FStar_Syntax_DsEnv.push_bv env id1  in
          (match uu____941 with | (env1,uu____953) -> (env1, []))
      | FStar_Parser_AST.NoName t ->
          let uu____957 = free_type_vars env t  in (env, uu____957)

and (free_type_vars :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.term -> FStar_Ident.ident Prims.list)
  =
  fun env  ->
    fun t  ->
      let uu____964 =
        let uu____965 = unparen t  in uu____965.FStar_Parser_AST.tm  in
      match uu____964 with
      | FStar_Parser_AST.Labeled uu____968 ->
          failwith "Impossible --- labeled source term"
      | FStar_Parser_AST.Tvar a ->
          let uu____981 = FStar_Syntax_DsEnv.try_lookup_id env a  in
          (match uu____981 with
           | FStar_Pervasives_Native.None  -> [a]
           | uu____986 -> [])
      | FStar_Parser_AST.Wild  -> []
      | FStar_Parser_AST.Const uu____989 -> []
      | FStar_Parser_AST.Uvar uu____990 -> []
      | FStar_Parser_AST.Var uu____991 -> []
      | FStar_Parser_AST.Projector uu____992 -> []
      | FStar_Parser_AST.Discrim uu____997 -> []
      | FStar_Parser_AST.Name uu____998 -> []
      | FStar_Parser_AST.Requires (t1,uu____1000) -> free_type_vars env t1
      | FStar_Parser_AST.Ensures (t1,uu____1008) -> free_type_vars env t1
      | FStar_Parser_AST.NamedTyp (uu____1015,t1) -> free_type_vars env t1
      | FStar_Parser_AST.Paren t1 -> failwith "impossible"
      | FStar_Parser_AST.Ascribed (t1,t',tacopt) ->
          let ts = t1 :: t' ::
            (match tacopt with
             | FStar_Pervasives_Native.None  -> []
             | FStar_Pervasives_Native.Some t2 -> [t2])
             in
          FStar_List.collect (free_type_vars env) ts
      | FStar_Parser_AST.Construct (uu____1034,ts) ->
          FStar_List.collect
            (fun uu____1055  ->
               match uu____1055 with
               | (t1,uu____1063) -> free_type_vars env t1) ts
      | FStar_Parser_AST.Op (uu____1064,ts) ->
          FStar_List.collect (free_type_vars env) ts
      | FStar_Parser_AST.App (t1,t2,uu____1072) ->
          let uu____1073 = free_type_vars env t1  in
          let uu____1076 = free_type_vars env t2  in
          FStar_List.append uu____1073 uu____1076
      | FStar_Parser_AST.Refine (b,t1) ->
          let uu____1081 = free_type_vars_b env b  in
          (match uu____1081 with
           | (env1,f) ->
               let uu____1096 = free_type_vars env1 t1  in
               FStar_List.append f uu____1096)
      | FStar_Parser_AST.Sum (binders,body) ->
          let uu____1113 =
            FStar_List.fold_left
              (fun uu____1137  ->
                 fun bt  ->
                   match uu____1137 with
                   | (env1,free) ->
                       let uu____1161 =
                         match bt with
                         | FStar_Util.Inl binder ->
                             free_type_vars_b env1 binder
                         | FStar_Util.Inr t1 ->
                             let uu____1176 = free_type_vars env1 body  in
                             (env1, uu____1176)
                          in
                       (match uu____1161 with
                        | (env2,f) -> (env2, (FStar_List.append f free))))
              (env, []) binders
             in
          (match uu____1113 with
           | (env1,free) ->
               let uu____1205 = free_type_vars env1 body  in
               FStar_List.append free uu____1205)
      | FStar_Parser_AST.Product (binders,body) ->
          let uu____1214 =
            FStar_List.fold_left
              (fun uu____1234  ->
                 fun binder  ->
                   match uu____1234 with
                   | (env1,free) ->
                       let uu____1254 = free_type_vars_b env1 binder  in
                       (match uu____1254 with
                        | (env2,f) -> (env2, (FStar_List.append f free))))
              (env, []) binders
             in
          (match uu____1214 with
           | (env1,free) ->
               let uu____1285 = free_type_vars env1 body  in
               FStar_List.append free uu____1285)
      | FStar_Parser_AST.Project (t1,uu____1289) -> free_type_vars env t1
      | FStar_Parser_AST.Attributes cattributes ->
          FStar_List.collect (free_type_vars env) cattributes
      | FStar_Parser_AST.CalcProof (rel,init1,steps) ->
          let uu____1300 = free_type_vars env rel  in
          let uu____1303 =
            let uu____1306 = free_type_vars env init1  in
            let uu____1309 =
              FStar_List.collect
                (fun uu____1318  ->
                   match uu____1318 with
                   | FStar_Parser_AST.CalcStep (rel1,just,next) ->
                       let uu____1324 = free_type_vars env rel1  in
                       let uu____1327 =
                         let uu____1330 = free_type_vars env just  in
                         let uu____1333 = free_type_vars env next  in
                         FStar_List.append uu____1330 uu____1333  in
                       FStar_List.append uu____1324 uu____1327) steps
               in
            FStar_List.append uu____1306 uu____1309  in
          FStar_List.append uu____1300 uu____1303
      | FStar_Parser_AST.Abs uu____1336 -> []
      | FStar_Parser_AST.Let uu____1343 -> []
      | FStar_Parser_AST.LetOpen uu____1364 -> []
      | FStar_Parser_AST.If uu____1369 -> []
      | FStar_Parser_AST.QForall uu____1376 -> []
      | FStar_Parser_AST.QExists uu____1395 -> []
      | FStar_Parser_AST.Record uu____1414 -> []
      | FStar_Parser_AST.Match uu____1427 -> []
      | FStar_Parser_AST.TryWith uu____1442 -> []
      | FStar_Parser_AST.Bind uu____1457 -> []
      | FStar_Parser_AST.Quote uu____1464 -> []
      | FStar_Parser_AST.VQuote uu____1469 -> []
      | FStar_Parser_AST.Antiquote uu____1470 -> []
      | FStar_Parser_AST.Seq uu____1471 -> []

let (head_and_args :
  FStar_Parser_AST.term ->
    (FStar_Parser_AST.term * (FStar_Parser_AST.term * FStar_Parser_AST.imp)
      Prims.list))
  =
  fun t  ->
    let rec aux args t1 =
      let uu____1525 =
        let uu____1526 = unparen t1  in uu____1526.FStar_Parser_AST.tm  in
      match uu____1525 with
      | FStar_Parser_AST.App (t2,arg,imp) -> aux ((arg, imp) :: args) t2
      | FStar_Parser_AST.Construct (l,args') ->
          ({
             FStar_Parser_AST.tm = (FStar_Parser_AST.Name l);
             FStar_Parser_AST.range = (t1.FStar_Parser_AST.range);
             FStar_Parser_AST.level = (t1.FStar_Parser_AST.level)
           }, (FStar_List.append args' args))
      | uu____1568 -> (t1, args)  in
    aux [] t
  
let (close :
  FStar_Syntax_DsEnv.env -> FStar_Parser_AST.term -> FStar_Parser_AST.term) =
  fun env  ->
    fun t  ->
      let ftv =
        let uu____1593 = free_type_vars env t  in
        FStar_All.pipe_left sort_ftv uu____1593  in
      if (FStar_List.length ftv) = Prims.int_zero
      then t
      else
        (let binders =
           FStar_All.pipe_right ftv
             (FStar_List.map
                (fun x  ->
                   let uu____1615 =
                     let uu____1616 =
                       let uu____1621 = tm_type x.FStar_Ident.idRange  in
                       (x, uu____1621)  in
                     FStar_Parser_AST.TAnnotated uu____1616  in
                   FStar_Parser_AST.mk_binder uu____1615
                     x.FStar_Ident.idRange FStar_Parser_AST.Type_level
                     (FStar_Pervasives_Native.Some FStar_Parser_AST.Implicit)))
            in
         let result =
           FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (binders, t))
             t.FStar_Parser_AST.range t.FStar_Parser_AST.level
            in
         result)
  
let (close_fun :
  FStar_Syntax_DsEnv.env -> FStar_Parser_AST.term -> FStar_Parser_AST.term) =
  fun env  ->
    fun t  ->
      let ftv =
        let uu____1639 = free_type_vars env t  in
        FStar_All.pipe_left sort_ftv uu____1639  in
      if (FStar_List.length ftv) = Prims.int_zero
      then t
      else
        (let binders =
           FStar_All.pipe_right ftv
             (FStar_List.map
                (fun x  ->
                   let uu____1661 =
                     let uu____1662 =
                       let uu____1667 = tm_type x.FStar_Ident.idRange  in
                       (x, uu____1667)  in
                     FStar_Parser_AST.TAnnotated uu____1662  in
                   FStar_Parser_AST.mk_binder uu____1661
                     x.FStar_Ident.idRange FStar_Parser_AST.Type_level
                     (FStar_Pervasives_Native.Some FStar_Parser_AST.Implicit)))
            in
         let t1 =
           let uu____1669 =
             let uu____1670 = unparen t  in uu____1670.FStar_Parser_AST.tm
              in
           match uu____1669 with
           | FStar_Parser_AST.Product uu____1671 -> t
           | uu____1678 ->
               FStar_Parser_AST.mk_term
                 (FStar_Parser_AST.App
                    ((FStar_Parser_AST.mk_term
                        (FStar_Parser_AST.Name
                           FStar_Parser_Const.effect_Tot_lid)
                        t.FStar_Parser_AST.range t.FStar_Parser_AST.level),
                      t, FStar_Parser_AST.Nothing)) t.FStar_Parser_AST.range
                 t.FStar_Parser_AST.level
            in
         let result =
           FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (binders, t1))
             t1.FStar_Parser_AST.range t1.FStar_Parser_AST.level
            in
         result)
  
let rec (uncurry :
  FStar_Parser_AST.binder Prims.list ->
    FStar_Parser_AST.term ->
      (FStar_Parser_AST.binder Prims.list * FStar_Parser_AST.term))
  =
  fun bs  ->
    fun t  ->
      match t.FStar_Parser_AST.tm with
      | FStar_Parser_AST.Product (binders,t1) ->
          uncurry (FStar_List.append bs binders) t1
      | uu____1715 -> (bs, t)
  
let rec (is_var_pattern : FStar_Parser_AST.pattern -> Prims.bool) =
  fun p  ->
    match p.FStar_Parser_AST.pat with
    | FStar_Parser_AST.PatWild uu____1726 -> true
    | FStar_Parser_AST.PatTvar (uu____1730,uu____1731) -> true
    | FStar_Parser_AST.PatVar (uu____1737,uu____1738) -> true
    | FStar_Parser_AST.PatAscribed (p1,uu____1745) -> is_var_pattern p1
    | uu____1758 -> false
  
let rec (is_app_pattern : FStar_Parser_AST.pattern -> Prims.bool) =
  fun p  ->
    match p.FStar_Parser_AST.pat with
    | FStar_Parser_AST.PatAscribed (p1,uu____1769) -> is_app_pattern p1
    | FStar_Parser_AST.PatApp
        ({ FStar_Parser_AST.pat = FStar_Parser_AST.PatVar uu____1782;
           FStar_Parser_AST.prange = uu____1783;_},uu____1784)
        -> true
    | uu____1796 -> false
  
let (replace_unit_pattern :
  FStar_Parser_AST.pattern -> FStar_Parser_AST.pattern) =
  fun p  ->
    match p.FStar_Parser_AST.pat with
    | FStar_Parser_AST.PatConst (FStar_Const.Const_unit ) ->
        FStar_Parser_AST.mk_pattern
          (FStar_Parser_AST.PatAscribed
             ((FStar_Parser_AST.mk_pattern
                 (FStar_Parser_AST.PatWild FStar_Pervasives_Native.None)
                 p.FStar_Parser_AST.prange),
               (unit_ty, FStar_Pervasives_Native.None)))
          p.FStar_Parser_AST.prange
    | uu____1812 -> p
  
let rec (destruct_app_pattern :
  FStar_Syntax_DsEnv.env ->
    Prims.bool ->
      FStar_Parser_AST.pattern ->
        ((FStar_Ident.ident,FStar_Ident.lident) FStar_Util.either *
          FStar_Parser_AST.pattern Prims.list * (FStar_Parser_AST.term *
          FStar_Parser_AST.term FStar_Pervasives_Native.option)
          FStar_Pervasives_Native.option))
  =
  fun env  ->
    fun is_top_level1  ->
      fun p  ->
        match p.FStar_Parser_AST.pat with
        | FStar_Parser_AST.PatAscribed (p1,t) ->
            let uu____1885 = destruct_app_pattern env is_top_level1 p1  in
            (match uu____1885 with
             | (name,args,uu____1928) ->
                 (name, args, (FStar_Pervasives_Native.Some t)))
        | FStar_Parser_AST.PatApp
            ({
               FStar_Parser_AST.pat = FStar_Parser_AST.PatVar
                 (id1,uu____1978);
               FStar_Parser_AST.prange = uu____1979;_},args)
            when is_top_level1 ->
            let uu____1989 =
              let uu____1994 = FStar_Syntax_DsEnv.qualify env id1  in
              FStar_Util.Inr uu____1994  in
            (uu____1989, args, FStar_Pervasives_Native.None)
        | FStar_Parser_AST.PatApp
            ({
               FStar_Parser_AST.pat = FStar_Parser_AST.PatVar
                 (id1,uu____2016);
               FStar_Parser_AST.prange = uu____2017;_},args)
            -> ((FStar_Util.Inl id1), args, FStar_Pervasives_Native.None)
        | uu____2047 -> failwith "Not an app pattern"
  
let rec (gather_pattern_bound_vars_maybe_top :
  Prims.bool ->
    FStar_Ident.ident FStar_Util.set ->
      FStar_Parser_AST.pattern -> FStar_Ident.ident FStar_Util.set)
  =
  fun fail_on_patconst  ->
    fun acc  ->
      fun p  ->
        let gather_pattern_bound_vars_from_list =
          FStar_List.fold_left
            (gather_pattern_bound_vars_maybe_top fail_on_patconst) acc
           in
        match p.FStar_Parser_AST.pat with
        | FStar_Parser_AST.PatWild uu____2106 -> acc
        | FStar_Parser_AST.PatName uu____2109 -> acc
        | FStar_Parser_AST.PatOp uu____2110 -> acc
        | FStar_Parser_AST.PatConst uu____2111 ->
            if fail_on_patconst
            then
              FStar_Errors.raise_error
                (FStar_Errors.Error_CannotRedefineConst,
                  "Constants cannot be redefined") p.FStar_Parser_AST.prange
            else acc
        | FStar_Parser_AST.PatApp (phead,pats) ->
            gather_pattern_bound_vars_from_list (phead :: pats)
        | FStar_Parser_AST.PatTvar (x,uu____2128) -> FStar_Util.set_add x acc
        | FStar_Parser_AST.PatVar (x,uu____2134) -> FStar_Util.set_add x acc
        | FStar_Parser_AST.PatList pats ->
            gather_pattern_bound_vars_from_list pats
        | FStar_Parser_AST.PatTuple (pats,uu____2143) ->
            gather_pattern_bound_vars_from_list pats
        | FStar_Parser_AST.PatOr pats ->
            gather_pattern_bound_vars_from_list pats
        | FStar_Parser_AST.PatRecord guarded_pats ->
            let uu____2160 =
              FStar_List.map FStar_Pervasives_Native.snd guarded_pats  in
            gather_pattern_bound_vars_from_list uu____2160
        | FStar_Parser_AST.PatAscribed (pat,uu____2168) ->
            gather_pattern_bound_vars_maybe_top fail_on_patconst acc pat
  
let (gather_pattern_bound_vars :
  Prims.bool -> FStar_Parser_AST.pattern -> FStar_Ident.ident FStar_Util.set)
  =
  fun fail_on_patconst  ->
    fun p  ->
      let acc =
        FStar_Util.new_set
          (fun id1  ->
             fun id2  ->
               if id1.FStar_Ident.idText = id2.FStar_Ident.idText
               then Prims.int_zero
               else Prims.int_one)
         in
      gather_pattern_bound_vars_maybe_top fail_on_patconst acc p
  
type bnd =
  | LocalBinder of (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.aqual) 
  | LetBinder of (FStar_Ident.lident * (FStar_Syntax_Syntax.term *
  FStar_Syntax_Syntax.term FStar_Pervasives_Native.option)) 
let (uu___is_LocalBinder : bnd -> Prims.bool) =
  fun projectee  ->
    match projectee with | LocalBinder _0 -> true | uu____2250 -> false
  
let (__proj__LocalBinder__item___0 :
  bnd -> (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.aqual)) =
  fun projectee  -> match projectee with | LocalBinder _0 -> _0 
let (uu___is_LetBinder : bnd -> Prims.bool) =
  fun projectee  ->
    match projectee with | LetBinder _0 -> true | uu____2291 -> false
  
let (__proj__LetBinder__item___0 :
  bnd ->
    (FStar_Ident.lident * (FStar_Syntax_Syntax.term *
      FStar_Syntax_Syntax.term FStar_Pervasives_Native.option)))
  = fun projectee  -> match projectee with | LetBinder _0 -> _0 
let (binder_of_bnd :
  bnd -> (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.aqual)) =
  fun uu___3_2339  ->
    match uu___3_2339 with
    | LocalBinder (a,aq) -> (a, aq)
    | uu____2346 -> failwith "Impossible"
  
let (mk_lb :
  (FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax Prims.list *
    (FStar_Syntax_Syntax.bv,FStar_Syntax_Syntax.fv) FStar_Util.either *
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax *
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax * FStar_Range.range)
    -> FStar_Syntax_Syntax.letbinding)
  =
  fun uu____2379  ->
    match uu____2379 with
    | (attrs,n1,t,e,pos) ->
        {
          FStar_Syntax_Syntax.lbname = n1;
          FStar_Syntax_Syntax.lbunivs = [];
          FStar_Syntax_Syntax.lbtyp = t;
          FStar_Syntax_Syntax.lbeff = FStar_Parser_Const.effect_ALL_lid;
          FStar_Syntax_Syntax.lbdef = e;
          FStar_Syntax_Syntax.lbattrs = attrs;
          FStar_Syntax_Syntax.lbpos = pos
        }
  
let (no_annot_abs :
  FStar_Syntax_Syntax.binders ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
      FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax)
  =
  fun bs  ->
    fun t  -> FStar_Syntax_Util.abs bs t FStar_Pervasives_Native.None
  
let (mk_ref_read :
  FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax)
  =
  fun tm  ->
    let tm' =
      let uu____2461 =
        let uu____2478 =
          let uu____2481 =
            FStar_Syntax_Syntax.lid_as_fv FStar_Parser_Const.sread_lid
              FStar_Syntax_Syntax.delta_constant FStar_Pervasives_Native.None
             in
          FStar_Syntax_Syntax.fv_to_tm uu____2481  in
        let uu____2482 =
          let uu____2493 =
            let uu____2502 = FStar_Syntax_Syntax.as_implicit false  in
            (tm, uu____2502)  in
          [uu____2493]  in
        (uu____2478, uu____2482)  in
      FStar_Syntax_Syntax.Tm_app uu____2461  in
    FStar_Syntax_Syntax.mk tm' FStar_Pervasives_Native.None
      tm.FStar_Syntax_Syntax.pos
  
let (mk_ref_alloc :
  FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax)
  =
  fun tm  ->
    let tm' =
      let uu____2551 =
        let uu____2568 =
          let uu____2571 =
            FStar_Syntax_Syntax.lid_as_fv FStar_Parser_Const.salloc_lid
              FStar_Syntax_Syntax.delta_constant FStar_Pervasives_Native.None
             in
          FStar_Syntax_Syntax.fv_to_tm uu____2571  in
        let uu____2572 =
          let uu____2583 =
            let uu____2592 = FStar_Syntax_Syntax.as_implicit false  in
            (tm, uu____2592)  in
          [uu____2583]  in
        (uu____2568, uu____2572)  in
      FStar_Syntax_Syntax.Tm_app uu____2551  in
    FStar_Syntax_Syntax.mk tm' FStar_Pervasives_Native.None
      tm.FStar_Syntax_Syntax.pos
  
let (mk_ref_assign :
  FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
      FStar_Range.range ->
        FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax)
  =
  fun t1  ->
    fun t2  ->
      fun pos  ->
        let tm =
          let uu____2655 =
            let uu____2672 =
              let uu____2675 =
                FStar_Syntax_Syntax.lid_as_fv FStar_Parser_Const.swrite_lid
                  FStar_Syntax_Syntax.delta_constant
                  FStar_Pervasives_Native.None
                 in
              FStar_Syntax_Syntax.fv_to_tm uu____2675  in
            let uu____2676 =
              let uu____2687 =
                let uu____2696 = FStar_Syntax_Syntax.as_implicit false  in
                (t1, uu____2696)  in
              let uu____2704 =
                let uu____2715 =
                  let uu____2724 = FStar_Syntax_Syntax.as_implicit false  in
                  (t2, uu____2724)  in
                [uu____2715]  in
              uu____2687 :: uu____2704  in
            (uu____2672, uu____2676)  in
          FStar_Syntax_Syntax.Tm_app uu____2655  in
        FStar_Syntax_Syntax.mk tm FStar_Pervasives_Native.None pos
  
let (generalize_annotated_univs :
  FStar_Syntax_Syntax.sigelt -> FStar_Syntax_Syntax.sigelt) =
  fun s  ->
    let bs_univnames bs =
      let uu____2784 =
        let uu____2799 =
          FStar_Util.new_set FStar_Syntax_Syntax.order_univ_name  in
        FStar_List.fold_left
          (fun uvs  ->
             fun uu____2818  ->
               match uu____2818 with
               | ({ FStar_Syntax_Syntax.ppname = uu____2829;
                    FStar_Syntax_Syntax.index = uu____2830;
                    FStar_Syntax_Syntax.sort = t;_},uu____2832)
                   ->
                   let uu____2840 = FStar_Syntax_Free.univnames t  in
                   FStar_Util.set_union uvs uu____2840) uu____2799
         in
      FStar_All.pipe_right bs uu____2784  in
    let empty_set = FStar_Util.new_set FStar_Syntax_Syntax.order_univ_name
       in
    match s.FStar_Syntax_Syntax.sigel with
    | FStar_Syntax_Syntax.Sig_inductive_typ uu____2856 ->
        failwith
          "Impossible: collect_annotated_universes: bare data/type constructor"
    | FStar_Syntax_Syntax.Sig_datacon uu____2874 ->
        failwith
          "Impossible: collect_annotated_universes: bare data/type constructor"
    | FStar_Syntax_Syntax.Sig_bundle (sigs,lids) ->
        let uvs =
          let uu____2902 =
            FStar_All.pipe_right sigs
              (FStar_List.fold_left
                 (fun uvs  ->
                    fun se  ->
                      let se_univs =
                        match se.FStar_Syntax_Syntax.sigel with
                        | FStar_Syntax_Syntax.Sig_inductive_typ
                            (uu____2923,uu____2924,bs,t,uu____2927,uu____2928)
                            ->
                            let uu____2937 = bs_univnames bs  in
                            let uu____2940 = FStar_Syntax_Free.univnames t
                               in
                            FStar_Util.set_union uu____2937 uu____2940
                        | FStar_Syntax_Syntax.Sig_datacon
                            (uu____2943,uu____2944,t,uu____2946,uu____2947,uu____2948)
                            -> FStar_Syntax_Free.univnames t
                        | uu____2955 ->
                            failwith
                              "Impossible: collect_annotated_universes: Sig_bundle should not have a non data/type sigelt"
                         in
                      FStar_Util.set_union uvs se_univs) empty_set)
             in
          FStar_All.pipe_right uu____2902 FStar_Util.set_elements  in
        let usubst = FStar_Syntax_Subst.univ_var_closing uvs  in
        let uu___585_2964 = s  in
        let uu____2965 =
          let uu____2966 =
            let uu____2975 =
              FStar_All.pipe_right sigs
                (FStar_List.map
                   (fun se  ->
                      match se.FStar_Syntax_Syntax.sigel with
                      | FStar_Syntax_Syntax.Sig_inductive_typ
                          (lid,uu____2993,bs,t,lids1,lids2) ->
                          let uu___596_3006 = se  in
                          let uu____3007 =
                            let uu____3008 =
                              let uu____3025 =
                                FStar_Syntax_Subst.subst_binders usubst bs
                                 in
                              let uu____3026 =
                                let uu____3027 =
                                  FStar_Syntax_Subst.shift_subst
                                    (FStar_List.length bs) usubst
                                   in
                                FStar_Syntax_Subst.subst uu____3027 t  in
                              (lid, uvs, uu____3025, uu____3026, lids1,
                                lids2)
                               in
                            FStar_Syntax_Syntax.Sig_inductive_typ uu____3008
                             in
                          {
                            FStar_Syntax_Syntax.sigel = uu____3007;
                            FStar_Syntax_Syntax.sigrng =
                              (uu___596_3006.FStar_Syntax_Syntax.sigrng);
                            FStar_Syntax_Syntax.sigquals =
                              (uu___596_3006.FStar_Syntax_Syntax.sigquals);
                            FStar_Syntax_Syntax.sigmeta =
                              (uu___596_3006.FStar_Syntax_Syntax.sigmeta);
                            FStar_Syntax_Syntax.sigattrs =
                              (uu___596_3006.FStar_Syntax_Syntax.sigattrs)
                          }
                      | FStar_Syntax_Syntax.Sig_datacon
                          (lid,uu____3041,t,tlid,n1,lids1) ->
                          let uu___606_3052 = se  in
                          let uu____3053 =
                            let uu____3054 =
                              let uu____3070 =
                                FStar_Syntax_Subst.subst usubst t  in
                              (lid, uvs, uu____3070, tlid, n1, lids1)  in
                            FStar_Syntax_Syntax.Sig_datacon uu____3054  in
                          {
                            FStar_Syntax_Syntax.sigel = uu____3053;
                            FStar_Syntax_Syntax.sigrng =
                              (uu___606_3052.FStar_Syntax_Syntax.sigrng);
                            FStar_Syntax_Syntax.sigquals =
                              (uu___606_3052.FStar_Syntax_Syntax.sigquals);
                            FStar_Syntax_Syntax.sigmeta =
                              (uu___606_3052.FStar_Syntax_Syntax.sigmeta);
                            FStar_Syntax_Syntax.sigattrs =
                              (uu___606_3052.FStar_Syntax_Syntax.sigattrs)
                          }
                      | uu____3074 ->
                          failwith
                            "Impossible: collect_annotated_universes: Sig_bundle should not have a non data/type sigelt"))
               in
            (uu____2975, lids)  in
          FStar_Syntax_Syntax.Sig_bundle uu____2966  in
        {
          FStar_Syntax_Syntax.sigel = uu____2965;
          FStar_Syntax_Syntax.sigrng =
            (uu___585_2964.FStar_Syntax_Syntax.sigrng);
          FStar_Syntax_Syntax.sigquals =
            (uu___585_2964.FStar_Syntax_Syntax.sigquals);
          FStar_Syntax_Syntax.sigmeta =
            (uu___585_2964.FStar_Syntax_Syntax.sigmeta);
          FStar_Syntax_Syntax.sigattrs =
            (uu___585_2964.FStar_Syntax_Syntax.sigattrs)
        }
    | FStar_Syntax_Syntax.Sig_declare_typ (lid,uu____3081,t) ->
        let uvs =
          let uu____3084 = FStar_Syntax_Free.univnames t  in
          FStar_All.pipe_right uu____3084 FStar_Util.set_elements  in
        let uu___615_3089 = s  in
        let uu____3090 =
          let uu____3091 =
            let uu____3098 = FStar_Syntax_Subst.close_univ_vars uvs t  in
            (lid, uvs, uu____3098)  in
          FStar_Syntax_Syntax.Sig_declare_typ uu____3091  in
        {
          FStar_Syntax_Syntax.sigel = uu____3090;
          FStar_Syntax_Syntax.sigrng =
            (uu___615_3089.FStar_Syntax_Syntax.sigrng);
          FStar_Syntax_Syntax.sigquals =
            (uu___615_3089.FStar_Syntax_Syntax.sigquals);
          FStar_Syntax_Syntax.sigmeta =
            (uu___615_3089.FStar_Syntax_Syntax.sigmeta);
          FStar_Syntax_Syntax.sigattrs =
            (uu___615_3089.FStar_Syntax_Syntax.sigattrs)
        }
    | FStar_Syntax_Syntax.Sig_let ((b,lbs),lids) ->
        let lb_univnames lb =
          let uu____3122 =
            FStar_Syntax_Free.univnames lb.FStar_Syntax_Syntax.lbtyp  in
          let uu____3125 =
            match (lb.FStar_Syntax_Syntax.lbdef).FStar_Syntax_Syntax.n with
            | FStar_Syntax_Syntax.Tm_abs (bs,e,uu____3132) ->
                let uvs1 = bs_univnames bs  in
                let uvs2 =
                  match e.FStar_Syntax_Syntax.n with
                  | FStar_Syntax_Syntax.Tm_ascribed
                      (uu____3165,(FStar_Util.Inl t,uu____3167),uu____3168)
                      -> FStar_Syntax_Free.univnames t
                  | FStar_Syntax_Syntax.Tm_ascribed
                      (uu____3215,(FStar_Util.Inr c,uu____3217),uu____3218)
                      -> FStar_Syntax_Free.univnames_comp c
                  | uu____3265 -> empty_set  in
                FStar_Util.set_union uvs1 uvs2
            | FStar_Syntax_Syntax.Tm_ascribed
                (uu____3266,(FStar_Util.Inl t,uu____3268),uu____3269) ->
                FStar_Syntax_Free.univnames t
            | FStar_Syntax_Syntax.Tm_ascribed
                (uu____3316,(FStar_Util.Inr c,uu____3318),uu____3319) ->
                FStar_Syntax_Free.univnames_comp c
            | uu____3366 -> empty_set  in
          FStar_Util.set_union uu____3122 uu____3125  in
        let all_lb_univs =
          let uu____3370 =
            FStar_All.pipe_right lbs
              (FStar_List.fold_left
                 (fun uvs  ->
                    fun lb  ->
                      let uu____3386 = lb_univnames lb  in
                      FStar_Util.set_union uvs uu____3386) empty_set)
             in
          FStar_All.pipe_right uu____3370 FStar_Util.set_elements  in
        let usubst = FStar_Syntax_Subst.univ_var_closing all_lb_univs  in
        let uu___670_3396 = s  in
        let uu____3397 =
          let uu____3398 =
            let uu____3405 =
              let uu____3406 =
                FStar_All.pipe_right lbs
                  (FStar_List.map
                     (fun lb  ->
                        let uu___673_3418 = lb  in
                        let uu____3419 =
                          FStar_Syntax_Subst.subst usubst
                            lb.FStar_Syntax_Syntax.lbtyp
                           in
                        let uu____3422 =
                          FStar_Syntax_Subst.subst usubst
                            lb.FStar_Syntax_Syntax.lbdef
                           in
                        {
                          FStar_Syntax_Syntax.lbname =
                            (uu___673_3418.FStar_Syntax_Syntax.lbname);
                          FStar_Syntax_Syntax.lbunivs = all_lb_univs;
                          FStar_Syntax_Syntax.lbtyp = uu____3419;
                          FStar_Syntax_Syntax.lbeff =
                            (uu___673_3418.FStar_Syntax_Syntax.lbeff);
                          FStar_Syntax_Syntax.lbdef = uu____3422;
                          FStar_Syntax_Syntax.lbattrs =
                            (uu___673_3418.FStar_Syntax_Syntax.lbattrs);
                          FStar_Syntax_Syntax.lbpos =
                            (uu___673_3418.FStar_Syntax_Syntax.lbpos)
                        }))
                 in
              (b, uu____3406)  in
            (uu____3405, lids)  in
          FStar_Syntax_Syntax.Sig_let uu____3398  in
        {
          FStar_Syntax_Syntax.sigel = uu____3397;
          FStar_Syntax_Syntax.sigrng =
            (uu___670_3396.FStar_Syntax_Syntax.sigrng);
          FStar_Syntax_Syntax.sigquals =
            (uu___670_3396.FStar_Syntax_Syntax.sigquals);
          FStar_Syntax_Syntax.sigmeta =
            (uu___670_3396.FStar_Syntax_Syntax.sigmeta);
          FStar_Syntax_Syntax.sigattrs =
            (uu___670_3396.FStar_Syntax_Syntax.sigattrs)
        }
    | FStar_Syntax_Syntax.Sig_assume (lid,uu____3431,fml) ->
        let uvs =
          let uu____3434 = FStar_Syntax_Free.univnames fml  in
          FStar_All.pipe_right uu____3434 FStar_Util.set_elements  in
        let uu___681_3439 = s  in
        let uu____3440 =
          let uu____3441 =
            let uu____3448 = FStar_Syntax_Subst.close_univ_vars uvs fml  in
            (lid, uvs, uu____3448)  in
          FStar_Syntax_Syntax.Sig_assume uu____3441  in
        {
          FStar_Syntax_Syntax.sigel = uu____3440;
          FStar_Syntax_Syntax.sigrng =
            (uu___681_3439.FStar_Syntax_Syntax.sigrng);
          FStar_Syntax_Syntax.sigquals =
            (uu___681_3439.FStar_Syntax_Syntax.sigquals);
          FStar_Syntax_Syntax.sigmeta =
            (uu___681_3439.FStar_Syntax_Syntax.sigmeta);
          FStar_Syntax_Syntax.sigattrs =
            (uu___681_3439.FStar_Syntax_Syntax.sigattrs)
        }
    | FStar_Syntax_Syntax.Sig_effect_abbrev (lid,uu____3450,bs,c,flags) ->
        let uvs =
          let uu____3459 =
            let uu____3462 = bs_univnames bs  in
            let uu____3465 = FStar_Syntax_Free.univnames_comp c  in
            FStar_Util.set_union uu____3462 uu____3465  in
          FStar_All.pipe_right uu____3459 FStar_Util.set_elements  in
        let usubst = FStar_Syntax_Subst.univ_var_closing uvs  in
        let uu___692_3473 = s  in
        let uu____3474 =
          let uu____3475 =
            let uu____3488 = FStar_Syntax_Subst.subst_binders usubst bs  in
            let uu____3489 = FStar_Syntax_Subst.subst_comp usubst c  in
            (lid, uvs, uu____3488, uu____3489, flags)  in
          FStar_Syntax_Syntax.Sig_effect_abbrev uu____3475  in
        {
          FStar_Syntax_Syntax.sigel = uu____3474;
          FStar_Syntax_Syntax.sigrng =
            (uu___692_3473.FStar_Syntax_Syntax.sigrng);
          FStar_Syntax_Syntax.sigquals =
            (uu___692_3473.FStar_Syntax_Syntax.sigquals);
          FStar_Syntax_Syntax.sigmeta =
            (uu___692_3473.FStar_Syntax_Syntax.sigmeta);
          FStar_Syntax_Syntax.sigattrs =
            (uu___692_3473.FStar_Syntax_Syntax.sigattrs)
        }
    | uu____3492 -> s
  
let (is_special_effect_combinator : Prims.string -> Prims.bool) =
  fun uu___4_3500  ->
    match uu___4_3500 with
    | "lift1" -> true
    | "lift2" -> true
    | "pure" -> true
    | "app" -> true
    | "push" -> true
    | "wp_if_then_else" -> true
    | "wp_assert" -> true
    | "wp_assume" -> true
    | "wp_close" -> true
    | "stronger" -> true
    | "ite_wp" -> true
    | "wp_trivial" -> true
    | "ctx" -> true
    | "gctx" -> true
    | "lift_from_pure" -> true
    | "return_wp" -> true
    | "return_elab" -> true
    | "bind_wp" -> true
    | "bind_elab" -> true
    | "repr" -> true
    | "post" -> true
    | "pre" -> true
    | "wp" -> true
    | uu____3549 -> false
  
let rec (sum_to_universe :
  FStar_Syntax_Syntax.universe -> Prims.int -> FStar_Syntax_Syntax.universe)
  =
  fun u  ->
    fun n1  ->
      if n1 = Prims.int_zero
      then u
      else
        (let uu____3570 = sum_to_universe u (n1 - Prims.int_one)  in
         FStar_Syntax_Syntax.U_succ uu____3570)
  
let (int_to_universe : Prims.int -> FStar_Syntax_Syntax.universe) =
  fun n1  -> sum_to_universe FStar_Syntax_Syntax.U_zero n1 
let rec (desugar_maybe_non_constant_universe :
  FStar_Parser_AST.term ->
    (Prims.int,FStar_Syntax_Syntax.universe) FStar_Util.either)
  =
  fun t  ->
    let uu____3596 =
      let uu____3597 = unparen t  in uu____3597.FStar_Parser_AST.tm  in
    match uu____3596 with
    | FStar_Parser_AST.Wild  ->
        let uu____3603 =
          let uu____3604 = FStar_Syntax_Unionfind.univ_fresh ()  in
          FStar_Syntax_Syntax.U_unif uu____3604  in
        FStar_Util.Inr uu____3603
    | FStar_Parser_AST.Uvar u ->
        FStar_Util.Inr (FStar_Syntax_Syntax.U_name u)
    | FStar_Parser_AST.Const (FStar_Const.Const_int (repr,uu____3617)) ->
        let n1 = FStar_Util.int_of_string repr  in
        (if n1 < Prims.int_zero
         then
           FStar_Errors.raise_error
             (FStar_Errors.Fatal_NegativeUniverseConstFatal_NotSupported,
               (Prims.op_Hat
                  "Negative universe constant  are not supported : " repr))
             t.FStar_Parser_AST.range
         else ();
         FStar_Util.Inl n1)
    | FStar_Parser_AST.Op (op_plus,t1::t2::[]) ->
        let u1 = desugar_maybe_non_constant_universe t1  in
        let u2 = desugar_maybe_non_constant_universe t2  in
        (match (u1, u2) with
         | (FStar_Util.Inl n1,FStar_Util.Inl n2) -> FStar_Util.Inl (n1 + n2)
         | (FStar_Util.Inl n1,FStar_Util.Inr u) ->
             let uu____3708 = sum_to_universe u n1  in
             FStar_Util.Inr uu____3708
         | (FStar_Util.Inr u,FStar_Util.Inl n1) ->
             let uu____3725 = sum_to_universe u n1  in
             FStar_Util.Inr uu____3725
         | (FStar_Util.Inr u11,FStar_Util.Inr u21) ->
             let uu____3741 =
               let uu____3747 =
                 let uu____3749 = FStar_Parser_AST.term_to_string t  in
                 Prims.op_Hat
                   "This universe might contain a sum of two universe variables "
                   uu____3749
                  in
               (FStar_Errors.Fatal_UniverseMightContainSumOfTwoUnivVars,
                 uu____3747)
                in
             FStar_Errors.raise_error uu____3741 t.FStar_Parser_AST.range)
    | FStar_Parser_AST.App uu____3758 ->
        let rec aux t1 univargs =
          let uu____3795 =
            let uu____3796 = unparen t1  in uu____3796.FStar_Parser_AST.tm
             in
          match uu____3795 with
          | FStar_Parser_AST.App (t2,targ,uu____3804) ->
              let uarg = desugar_maybe_non_constant_universe targ  in
              aux t2 (uarg :: univargs)
          | FStar_Parser_AST.Var max_lid1 ->
              if
                FStar_List.existsb
                  (fun uu___5_3831  ->
                     match uu___5_3831 with
                     | FStar_Util.Inr uu____3838 -> true
                     | uu____3841 -> false) univargs
              then
                let uu____3849 =
                  let uu____3850 =
                    FStar_List.map
                      (fun uu___6_3860  ->
                         match uu___6_3860 with
                         | FStar_Util.Inl n1 -> int_to_universe n1
                         | FStar_Util.Inr u -> u) univargs
                     in
                  FStar_Syntax_Syntax.U_max uu____3850  in
                FStar_Util.Inr uu____3849
              else
                (let nargs =
                   FStar_List.map
                     (fun uu___7_3886  ->
                        match uu___7_3886 with
                        | FStar_Util.Inl n1 -> n1
                        | FStar_Util.Inr uu____3896 -> failwith "impossible")
                     univargs
                    in
                 let uu____3900 =
                   FStar_List.fold_left
                     (fun m  -> fun n1  -> if m > n1 then m else n1)
                     Prims.int_zero nargs
                    in
                 FStar_Util.Inl uu____3900)
          | uu____3916 ->
              let uu____3917 =
                let uu____3923 =
                  let uu____3925 =
                    let uu____3927 = FStar_Parser_AST.term_to_string t1  in
                    Prims.op_Hat uu____3927 " in universe context"  in
                  Prims.op_Hat "Unexpected term " uu____3925  in
                (FStar_Errors.Fatal_UnexpectedTermInUniverse, uu____3923)  in
              FStar_Errors.raise_error uu____3917 t1.FStar_Parser_AST.range
           in
        aux t []
    | uu____3942 ->
        let uu____3943 =
          let uu____3949 =
            let uu____3951 =
              let uu____3953 = FStar_Parser_AST.term_to_string t  in
              Prims.op_Hat uu____3953 " in universe context"  in
            Prims.op_Hat "Unexpected term " uu____3951  in
          (FStar_Errors.Fatal_UnexpectedTermInUniverse, uu____3949)  in
        FStar_Errors.raise_error uu____3943 t.FStar_Parser_AST.range
  
let rec (desugar_universe :
  FStar_Parser_AST.term -> FStar_Syntax_Syntax.universe) =
  fun t  ->
    let u = desugar_maybe_non_constant_universe t  in
    match u with
    | FStar_Util.Inl n1 -> int_to_universe n1
    | FStar_Util.Inr u1 -> u1
  
let (check_no_aq : FStar_Syntax_Syntax.antiquotations -> unit) =
  fun aq  ->
    match aq with
    | [] -> ()
    | (bv,{
            FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_quoted
              (e,{
                   FStar_Syntax_Syntax.qkind =
                     FStar_Syntax_Syntax.Quote_dynamic ;
                   FStar_Syntax_Syntax.antiquotes = uu____3994;_});
            FStar_Syntax_Syntax.pos = uu____3995;
            FStar_Syntax_Syntax.vars = uu____3996;_})::uu____3997
        ->
        let uu____4028 =
          let uu____4034 =
            let uu____4036 = FStar_Syntax_Print.term_to_string e  in
            FStar_Util.format1 "Unexpected antiquotation: `@(%s)" uu____4036
             in
          (FStar_Errors.Fatal_UnexpectedAntiquotation, uu____4034)  in
        FStar_Errors.raise_error uu____4028 e.FStar_Syntax_Syntax.pos
    | (bv,e)::uu____4042 ->
        let uu____4061 =
          let uu____4067 =
            let uu____4069 = FStar_Syntax_Print.term_to_string e  in
            FStar_Util.format1 "Unexpected antiquotation: `#(%s)" uu____4069
             in
          (FStar_Errors.Fatal_UnexpectedAntiquotation, uu____4067)  in
        FStar_Errors.raise_error uu____4061 e.FStar_Syntax_Syntax.pos
  
let check_fields :
  'Auu____4082 .
    FStar_Syntax_DsEnv.env ->
      (FStar_Ident.lident * 'Auu____4082) Prims.list ->
        FStar_Range.range -> FStar_Syntax_DsEnv.record_or_dc
  =
  fun env  ->
    fun fields  ->
      fun rg  ->
        let uu____4110 = FStar_List.hd fields  in
        match uu____4110 with
        | (f,uu____4120) ->
            (FStar_Syntax_DsEnv.fail_if_qualified_by_curmodule env f;
             (let record =
                FStar_Syntax_DsEnv.fail_or env
                  (FStar_Syntax_DsEnv.try_lookup_record_by_field_name env) f
                 in
              let check_field uu____4132 =
                match uu____4132 with
                | (f',uu____4138) ->
                    (FStar_Syntax_DsEnv.fail_if_qualified_by_curmodule env f';
                     (let uu____4140 =
                        FStar_Syntax_DsEnv.belongs_to_record env f' record
                         in
                      if uu____4140
                      then ()
                      else
                        (let msg =
                           FStar_Util.format3
                             "Field %s belongs to record type %s, whereas field %s does not"
                             f.FStar_Ident.str
                             (record.FStar_Syntax_DsEnv.typename).FStar_Ident.str
                             f'.FStar_Ident.str
                            in
                         FStar_Errors.raise_error
                           (FStar_Errors.Fatal_FieldsNotBelongToSameRecordType,
                             msg) rg)))
                 in
              (let uu____4150 = FStar_List.tl fields  in
               FStar_List.iter check_field uu____4150);
              (match () with | () -> record)))
  
let rec (desugar_data_pat :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.pattern -> (env_t * bnd * annotated_pat Prims.list))
  =
  fun env  ->
    fun p  ->
      let check_linear_pattern_variables pats r =
        let rec pat_vars p1 =
          match p1.FStar_Syntax_Syntax.v with
          | FStar_Syntax_Syntax.Pat_dot_term uu____4513 ->
              FStar_Syntax_Syntax.no_names
          | FStar_Syntax_Syntax.Pat_wild uu____4520 ->
              FStar_Syntax_Syntax.no_names
          | FStar_Syntax_Syntax.Pat_constant uu____4521 ->
              FStar_Syntax_Syntax.no_names
          | FStar_Syntax_Syntax.Pat_var x ->
              FStar_Util.set_add x FStar_Syntax_Syntax.no_names
          | FStar_Syntax_Syntax.Pat_cons (uu____4523,pats1) ->
              let aux out uu____4564 =
                match uu____4564 with
                | (p2,uu____4577) ->
                    let intersection =
                      let uu____4587 = pat_vars p2  in
                      FStar_Util.set_intersect uu____4587 out  in
                    let uu____4590 = FStar_Util.set_is_empty intersection  in
                    if uu____4590
                    then
                      let uu____4595 = pat_vars p2  in
                      FStar_Util.set_union out uu____4595
                    else
                      (let duplicate_bv =
                         let uu____4601 =
                           FStar_Util.set_elements intersection  in
                         FStar_List.hd uu____4601  in
                       let uu____4604 =
                         let uu____4610 =
                           FStar_Util.format1
                             "Non-linear patterns are not permitted: `%s` appears more than once in this pattern."
                             (duplicate_bv.FStar_Syntax_Syntax.ppname).FStar_Ident.idText
                            in
                         (FStar_Errors.Fatal_NonLinearPatternNotPermitted,
                           uu____4610)
                          in
                       FStar_Errors.raise_error uu____4604 r)
                 in
              FStar_List.fold_left aux FStar_Syntax_Syntax.no_names pats1
           in
        match pats with
        | [] -> ()
        | p1::[] ->
            let uu____4634 = pat_vars p1  in
            FStar_All.pipe_right uu____4634 (fun a1  -> ())
        | p1::ps ->
            let pvars = pat_vars p1  in
            let aux p2 =
              let uu____4662 =
                let uu____4664 = pat_vars p2  in
                FStar_Util.set_eq pvars uu____4664  in
              if uu____4662
              then ()
              else
                (let nonlinear_vars =
                   let uu____4673 = pat_vars p2  in
                   FStar_Util.set_symmetric_difference pvars uu____4673  in
                 let first_nonlinear_var =
                   let uu____4677 = FStar_Util.set_elements nonlinear_vars
                      in
                   FStar_List.hd uu____4677  in
                 let uu____4680 =
                   let uu____4686 =
                     FStar_Util.format1
                       "Patterns in this match are incoherent, variable %s is bound in some but not all patterns."
                       (first_nonlinear_var.FStar_Syntax_Syntax.ppname).FStar_Ident.idText
                      in
                   (FStar_Errors.Fatal_IncoherentPatterns, uu____4686)  in
                 FStar_Errors.raise_error uu____4680 r)
               in
            FStar_List.iter aux ps
         in
      let resolvex l e x =
        let uu____4714 =
          FStar_All.pipe_right l
            (FStar_Util.find_opt
               (fun y  ->
                  (y.FStar_Syntax_Syntax.ppname).FStar_Ident.idText =
                    x.FStar_Ident.idText))
           in
        match uu____4714 with
        | FStar_Pervasives_Native.Some y -> (l, e, y)
        | uu____4731 ->
            let uu____4734 = FStar_Syntax_DsEnv.push_bv e x  in
            (match uu____4734 with | (e1,x1) -> ((x1 :: l), e1, x1))
         in
      let rec aux' top loc env1 p1 =
        let pos q = FStar_Syntax_Syntax.withinfo q p1.FStar_Parser_AST.prange
           in
        let pos_r r q = FStar_Syntax_Syntax.withinfo q r  in
        let orig = p1  in
        match p1.FStar_Parser_AST.pat with
        | FStar_Parser_AST.PatOr uu____4885 -> failwith "impossible"
        | FStar_Parser_AST.PatOp op ->
            let uu____4909 =
              let uu____4910 =
                let uu____4911 =
                  let uu____4918 =
                    let uu____4919 =
                      let uu____4925 =
                        FStar_Parser_AST.compile_op Prims.int_zero
                          op.FStar_Ident.idText op.FStar_Ident.idRange
                         in
                      (uu____4925, (op.FStar_Ident.idRange))  in
                    FStar_Ident.mk_ident uu____4919  in
                  (uu____4918, FStar_Pervasives_Native.None)  in
                FStar_Parser_AST.PatVar uu____4911  in
              {
                FStar_Parser_AST.pat = uu____4910;
                FStar_Parser_AST.prange = (p1.FStar_Parser_AST.prange)
              }  in
            aux loc env1 uu____4909
        | FStar_Parser_AST.PatAscribed (p2,(t,tacopt)) ->
            ((match tacopt with
              | FStar_Pervasives_Native.None  -> ()
              | FStar_Pervasives_Native.Some uu____4945 ->
                  FStar_Errors.raise_error
                    (FStar_Errors.Fatal_TypeWithinPatternsAllowedOnVariablesOnly,
                      "Type ascriptions within patterns cannot be associated with a tactic")
                    orig.FStar_Parser_AST.prange);
             (let uu____4948 = aux loc env1 p2  in
              match uu____4948 with
              | (loc1,env',binder,p3,annots,imp) ->
                  let annot_pat_var p4 t1 =
                    match p4.FStar_Syntax_Syntax.v with
                    | FStar_Syntax_Syntax.Pat_var x ->
                        let uu___929_5037 = p4  in
                        {
                          FStar_Syntax_Syntax.v =
                            (FStar_Syntax_Syntax.Pat_var
                               (let uu___931_5042 = x  in
                                {
                                  FStar_Syntax_Syntax.ppname =
                                    (uu___931_5042.FStar_Syntax_Syntax.ppname);
                                  FStar_Syntax_Syntax.index =
                                    (uu___931_5042.FStar_Syntax_Syntax.index);
                                  FStar_Syntax_Syntax.sort = t1
                                }));
                          FStar_Syntax_Syntax.p =
                            (uu___929_5037.FStar_Syntax_Syntax.p)
                        }
                    | FStar_Syntax_Syntax.Pat_wild x ->
                        let uu___935_5044 = p4  in
                        {
                          FStar_Syntax_Syntax.v =
                            (FStar_Syntax_Syntax.Pat_wild
                               (let uu___937_5049 = x  in
                                {
                                  FStar_Syntax_Syntax.ppname =
                                    (uu___937_5049.FStar_Syntax_Syntax.ppname);
                                  FStar_Syntax_Syntax.index =
                                    (uu___937_5049.FStar_Syntax_Syntax.index);
                                  FStar_Syntax_Syntax.sort = t1
                                }));
                          FStar_Syntax_Syntax.p =
                            (uu___935_5044.FStar_Syntax_Syntax.p)
                        }
                    | uu____5050 when top -> p4
                    | uu____5051 ->
                        FStar_Errors.raise_error
                          (FStar_Errors.Fatal_TypeWithinPatternsAllowedOnVariablesOnly,
                            "Type ascriptions within patterns are only allowed on variables")
                          orig.FStar_Parser_AST.prange
                     in
                  let uu____5056 =
                    match binder with
                    | LetBinder uu____5077 -> failwith "impossible"
                    | LocalBinder (x,aq) ->
                        let t1 =
                          let uu____5102 = close_fun env1 t  in
                          desugar_term env1 uu____5102  in
                        let x1 =
                          let uu___948_5104 = x  in
                          {
                            FStar_Syntax_Syntax.ppname =
                              (uu___948_5104.FStar_Syntax_Syntax.ppname);
                            FStar_Syntax_Syntax.index =
                              (uu___948_5104.FStar_Syntax_Syntax.index);
                            FStar_Syntax_Syntax.sort = t1
                          }  in
                        ([(x1, t1)], (LocalBinder (x1, aq)))
                     in
                  (match uu____5056 with
                   | (annots',binder1) ->
                       (loc1, env', binder1, p3,
                         (FStar_List.append annots' annots), imp))))
        | FStar_Parser_AST.PatWild aq ->
            let imp =
              aq = (FStar_Pervasives_Native.Some FStar_Parser_AST.Implicit)
               in
            let aq1 = trans_aqual env1 aq  in
            let x =
              FStar_Syntax_Syntax.new_bv
                (FStar_Pervasives_Native.Some (p1.FStar_Parser_AST.prange))
                FStar_Syntax_Syntax.tun
               in
            let uu____5172 =
              FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_wild x)  in
            (loc, env1, (LocalBinder (x, aq1)), uu____5172, [], imp)
        | FStar_Parser_AST.PatConst c ->
            let x =
              FStar_Syntax_Syntax.new_bv
                (FStar_Pervasives_Native.Some (p1.FStar_Parser_AST.prange))
                FStar_Syntax_Syntax.tun
               in
            let uu____5186 =
              FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_constant c)
               in
            (loc, env1, (LocalBinder (x, FStar_Pervasives_Native.None)),
              uu____5186, [], false)
        | FStar_Parser_AST.PatTvar (x,aq) ->
            let imp =
              aq = (FStar_Pervasives_Native.Some FStar_Parser_AST.Implicit)
               in
            let aq1 = trans_aqual env1 aq  in
            let uu____5210 = resolvex loc env1 x  in
            (match uu____5210 with
             | (loc1,env2,xbv) ->
                 let uu____5239 =
                   FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_var xbv)
                    in
                 (loc1, env2, (LocalBinder (xbv, aq1)), uu____5239, [], imp))
        | FStar_Parser_AST.PatVar (x,aq) ->
            let imp =
              aq = (FStar_Pervasives_Native.Some FStar_Parser_AST.Implicit)
               in
            let aq1 = trans_aqual env1 aq  in
            let uu____5262 = resolvex loc env1 x  in
            (match uu____5262 with
             | (loc1,env2,xbv) ->
                 let uu____5291 =
                   FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_var xbv)
                    in
                 (loc1, env2, (LocalBinder (xbv, aq1)), uu____5291, [], imp))
        | FStar_Parser_AST.PatName l ->
            let l1 =
              FStar_Syntax_DsEnv.fail_or env1
                (FStar_Syntax_DsEnv.try_lookup_datacon env1) l
               in
            let x =
              FStar_Syntax_Syntax.new_bv
                (FStar_Pervasives_Native.Some (p1.FStar_Parser_AST.prange))
                FStar_Syntax_Syntax.tun
               in
            let uu____5306 =
              FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_cons (l1, []))
               in
            (loc, env1, (LocalBinder (x, FStar_Pervasives_Native.None)),
              uu____5306, [], false)
        | FStar_Parser_AST.PatApp
            ({ FStar_Parser_AST.pat = FStar_Parser_AST.PatName l;
               FStar_Parser_AST.prange = uu____5336;_},args)
            ->
            let uu____5342 =
              FStar_List.fold_right
                (fun arg  ->
                   fun uu____5403  ->
                     match uu____5403 with
                     | (loc1,env2,annots,args1) ->
                         let uu____5484 = aux loc1 env2 arg  in
                         (match uu____5484 with
                          | (loc2,env3,uu____5531,arg1,ans,imp) ->
                              (loc2, env3, (FStar_List.append ans annots),
                                ((arg1, imp) :: args1)))) args
                (loc, env1, [], [])
               in
            (match uu____5342 with
             | (loc1,env2,annots,args1) ->
                 let l1 =
                   FStar_Syntax_DsEnv.fail_or env2
                     (FStar_Syntax_DsEnv.try_lookup_datacon env2) l
                    in
                 let x =
                   FStar_Syntax_Syntax.new_bv
                     (FStar_Pervasives_Native.Some
                        (p1.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun
                    in
                 let uu____5663 =
                   FStar_All.pipe_left pos
                     (FStar_Syntax_Syntax.Pat_cons (l1, args1))
                    in
                 (loc1, env2,
                   (LocalBinder (x, FStar_Pervasives_Native.None)),
                   uu____5663, annots, false))
        | FStar_Parser_AST.PatApp uu____5681 ->
            FStar_Errors.raise_error
              (FStar_Errors.Fatal_UnexpectedPattern, "Unexpected pattern")
              p1.FStar_Parser_AST.prange
        | FStar_Parser_AST.PatList pats ->
            let uu____5712 =
              FStar_List.fold_right
                (fun pat  ->
                   fun uu____5763  ->
                     match uu____5763 with
                     | (loc1,env2,annots,pats1) ->
                         let uu____5824 = aux loc1 env2 pat  in
                         (match uu____5824 with
                          | (loc2,env3,uu____5866,pat1,ans,uu____5869) ->
                              (loc2, env3, (FStar_List.append ans annots),
                                (pat1 :: pats1)))) pats (loc, env1, [], [])
               in
            (match uu____5712 with
             | (loc1,env2,annots,pats1) ->
                 let pat =
                   let uu____5966 =
                     let uu____5969 =
                       let uu____5976 =
                         FStar_Range.end_range p1.FStar_Parser_AST.prange  in
                       pos_r uu____5976  in
                     let uu____5977 =
                       let uu____5978 =
                         let uu____5992 =
                           FStar_Syntax_Syntax.lid_as_fv
                             FStar_Parser_Const.nil_lid
                             FStar_Syntax_Syntax.delta_constant
                             (FStar_Pervasives_Native.Some
                                FStar_Syntax_Syntax.Data_ctor)
                            in
                         (uu____5992, [])  in
                       FStar_Syntax_Syntax.Pat_cons uu____5978  in
                     FStar_All.pipe_left uu____5969 uu____5977  in
                   FStar_List.fold_right
                     (fun hd1  ->
                        fun tl1  ->
                          let r =
                            FStar_Range.union_ranges
                              hd1.FStar_Syntax_Syntax.p
                              tl1.FStar_Syntax_Syntax.p
                             in
                          let uu____6026 =
                            let uu____6027 =
                              let uu____6041 =
                                FStar_Syntax_Syntax.lid_as_fv
                                  FStar_Parser_Const.cons_lid
                                  FStar_Syntax_Syntax.delta_constant
                                  (FStar_Pervasives_Native.Some
                                     FStar_Syntax_Syntax.Data_ctor)
                                 in
                              (uu____6041, [(hd1, false); (tl1, false)])  in
                            FStar_Syntax_Syntax.Pat_cons uu____6027  in
                          FStar_All.pipe_left (pos_r r) uu____6026) pats1
                     uu____5966
                    in
                 let x =
                   FStar_Syntax_Syntax.new_bv
                     (FStar_Pervasives_Native.Some
                        (p1.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun
                    in
                 (loc1, env2,
                   (LocalBinder (x, FStar_Pervasives_Native.None)), pat,
                   annots, false))
        | FStar_Parser_AST.PatTuple (args,dep1) ->
            let uu____6099 =
              FStar_List.fold_left
                (fun uu____6159  ->
                   fun p2  ->
                     match uu____6159 with
                     | (loc1,env2,annots,pats) ->
                         let uu____6241 = aux loc1 env2 p2  in
                         (match uu____6241 with
                          | (loc2,env3,uu____6288,pat,ans,uu____6291) ->
                              (loc2, env3, (FStar_List.append ans annots),
                                ((pat, false) :: pats)))) (loc, env1, [], [])
                args
               in
            (match uu____6099 with
             | (loc1,env2,annots,args1) ->
                 let args2 = FStar_List.rev args1  in
                 let l =
                   if dep1
                   then
                     FStar_Parser_Const.mk_dtuple_data_lid
                       (FStar_List.length args2) p1.FStar_Parser_AST.prange
                   else
                     FStar_Parser_Const.mk_tuple_data_lid
                       (FStar_List.length args2) p1.FStar_Parser_AST.prange
                    in
                 let constr =
                   FStar_Syntax_DsEnv.fail_or env2
                     (FStar_Syntax_DsEnv.try_lookup_lid env2) l
                    in
                 let l1 =
                   match constr.FStar_Syntax_Syntax.n with
                   | FStar_Syntax_Syntax.Tm_fvar fv -> fv
                   | uu____6457 -> failwith "impossible"  in
                 let x =
                   FStar_Syntax_Syntax.new_bv
                     (FStar_Pervasives_Native.Some
                        (p1.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun
                    in
                 let uu____6460 =
                   FStar_All.pipe_left pos
                     (FStar_Syntax_Syntax.Pat_cons (l1, args2))
                    in
                 (loc1, env2,
                   (LocalBinder (x, FStar_Pervasives_Native.None)),
                   uu____6460, annots, false))
        | FStar_Parser_AST.PatRecord [] ->
            FStar_Errors.raise_error
              (FStar_Errors.Fatal_UnexpectedPattern, "Unexpected pattern")
              p1.FStar_Parser_AST.prange
        | FStar_Parser_AST.PatRecord fields ->
            let record = check_fields env1 fields p1.FStar_Parser_AST.prange
               in
            let fields1 =
              FStar_All.pipe_right fields
                (FStar_List.map
                   (fun uu____6541  ->
                      match uu____6541 with
                      | (f,p2) -> ((f.FStar_Ident.ident), p2)))
               in
            let args =
              FStar_All.pipe_right record.FStar_Syntax_DsEnv.fields
                (FStar_List.map
                   (fun uu____6571  ->
                      match uu____6571 with
                      | (f,uu____6577) ->
                          let uu____6578 =
                            FStar_All.pipe_right fields1
                              (FStar_List.tryFind
                                 (fun uu____6604  ->
                                    match uu____6604 with
                                    | (g,uu____6611) ->
                                        f.FStar_Ident.idText =
                                          g.FStar_Ident.idText))
                             in
                          (match uu____6578 with
                           | FStar_Pervasives_Native.None  ->
                               FStar_Parser_AST.mk_pattern
                                 (FStar_Parser_AST.PatWild
                                    FStar_Pervasives_Native.None)
                                 p1.FStar_Parser_AST.prange
                           | FStar_Pervasives_Native.Some (uu____6617,p2) ->
                               p2)))
               in
            let app =
              let uu____6624 =
                let uu____6625 =
                  let uu____6632 =
                    let uu____6633 =
                      let uu____6634 =
                        FStar_Ident.lid_of_ids
                          (FStar_List.append
                             (record.FStar_Syntax_DsEnv.typename).FStar_Ident.ns
                             [record.FStar_Syntax_DsEnv.constrname])
                         in
                      FStar_Parser_AST.PatName uu____6634  in
                    FStar_Parser_AST.mk_pattern uu____6633
                      p1.FStar_Parser_AST.prange
                     in
                  (uu____6632, args)  in
                FStar_Parser_AST.PatApp uu____6625  in
              FStar_Parser_AST.mk_pattern uu____6624
                p1.FStar_Parser_AST.prange
               in
            let uu____6637 = aux loc env1 app  in
            (match uu____6637 with
             | (env2,e,b,p2,annots,uu____6683) ->
                 let p3 =
                   match p2.FStar_Syntax_Syntax.v with
                   | FStar_Syntax_Syntax.Pat_cons (fv,args1) ->
                       let uu____6723 =
                         let uu____6724 =
                           let uu____6738 =
                             let uu___1096_6739 = fv  in
                             let uu____6740 =
                               let uu____6743 =
                                 let uu____6744 =
                                   let uu____6751 =
                                     FStar_All.pipe_right
                                       record.FStar_Syntax_DsEnv.fields
                                       (FStar_List.map
                                          FStar_Pervasives_Native.fst)
                                      in
                                   ((record.FStar_Syntax_DsEnv.typename),
                                     uu____6751)
                                    in
                                 FStar_Syntax_Syntax.Record_ctor uu____6744
                                  in
                               FStar_Pervasives_Native.Some uu____6743  in
                             {
                               FStar_Syntax_Syntax.fv_name =
                                 (uu___1096_6739.FStar_Syntax_Syntax.fv_name);
                               FStar_Syntax_Syntax.fv_delta =
                                 (uu___1096_6739.FStar_Syntax_Syntax.fv_delta);
                               FStar_Syntax_Syntax.fv_qual = uu____6740
                             }  in
                           (uu____6738, args1)  in
                         FStar_Syntax_Syntax.Pat_cons uu____6724  in
                       FStar_All.pipe_left pos uu____6723
                   | uu____6777 -> p2  in
                 (env2, e, b, p3, annots, false))
      
      and aux loc env1 p1 = aux' false loc env1 p1
       in
      let aux_maybe_or env1 p1 =
        let loc = []  in
        match p1.FStar_Parser_AST.pat with
        | FStar_Parser_AST.PatOr [] -> failwith "impossible"
        | FStar_Parser_AST.PatOr (p2::ps) ->
            let uu____6863 = aux' true loc env1 p2  in
            (match uu____6863 with
             | (loc1,env2,var,p3,ans,uu____6907) ->
                 let uu____6922 =
                   FStar_List.fold_left
                     (fun uu____6971  ->
                        fun p4  ->
                          match uu____6971 with
                          | (loc2,env3,ps1) ->
                              let uu____7036 = aux' true loc2 env3 p4  in
                              (match uu____7036 with
                               | (loc3,env4,uu____7077,p5,ans1,uu____7080) ->
                                   (loc3, env4, ((p5, ans1) :: ps1))))
                     (loc1, env2, []) ps
                    in
                 (match uu____6922 with
                  | (loc2,env3,ps1) ->
                      let pats = (p3, ans) :: (FStar_List.rev ps1)  in
                      (env3, var, pats)))
        | uu____7241 ->
            let uu____7242 = aux' true loc env1 p1  in
            (match uu____7242 with
             | (loc1,env2,vars,pat,ans,b) -> (env2, vars, [(pat, ans)]))
         in
      let uu____7339 = aux_maybe_or env p  in
      match uu____7339 with
      | (env1,b,pats) ->
          ((let uu____7394 = FStar_List.map FStar_Pervasives_Native.fst pats
               in
            check_linear_pattern_variables uu____7394
              p.FStar_Parser_AST.prange);
           (env1, b, pats))

and (desugar_binding_pat_maybe_top :
  Prims.bool ->
    FStar_Syntax_DsEnv.env ->
      FStar_Parser_AST.pattern -> (env_t * bnd * annotated_pat Prims.list))
  =
  fun top  ->
    fun env  ->
      fun p  ->
        let mklet x ty tacopt =
          let uu____7467 =
            let uu____7468 =
              let uu____7479 = FStar_Syntax_DsEnv.qualify env x  in
              (uu____7479, (ty, tacopt))  in
            LetBinder uu____7468  in
          (env, uu____7467, [])  in
        let op_to_ident x =
          let uu____7496 =
            let uu____7502 =
              FStar_Parser_AST.compile_op Prims.int_zero x.FStar_Ident.idText
                x.FStar_Ident.idRange
               in
            (uu____7502, (x.FStar_Ident.idRange))  in
          FStar_Ident.mk_ident uu____7496  in
        if top
        then
          match p.FStar_Parser_AST.pat with
          | FStar_Parser_AST.PatOp x ->
              let uu____7524 = op_to_ident x  in
              mklet uu____7524 FStar_Syntax_Syntax.tun
                FStar_Pervasives_Native.None
          | FStar_Parser_AST.PatVar (x,uu____7526) ->
              mklet x FStar_Syntax_Syntax.tun FStar_Pervasives_Native.None
          | FStar_Parser_AST.PatAscribed
              ({ FStar_Parser_AST.pat = FStar_Parser_AST.PatOp x;
                 FStar_Parser_AST.prange = uu____7532;_},(t,tacopt))
              ->
              let tacopt1 = FStar_Util.map_opt tacopt (desugar_term env)  in
              let uu____7548 = op_to_ident x  in
              let uu____7549 = desugar_term env t  in
              mklet uu____7548 uu____7549 tacopt1
          | FStar_Parser_AST.PatAscribed
              ({
                 FStar_Parser_AST.pat = FStar_Parser_AST.PatVar
                   (x,uu____7551);
                 FStar_Parser_AST.prange = uu____7552;_},(t,tacopt))
              ->
              let tacopt1 = FStar_Util.map_opt tacopt (desugar_term env)  in
              let uu____7572 = desugar_term env t  in
              mklet x uu____7572 tacopt1
          | uu____7573 ->
              FStar_Errors.raise_error
                (FStar_Errors.Fatal_UnexpectedPattern,
                  "Unexpected pattern at the top-level")
                p.FStar_Parser_AST.prange
        else
          (let uu____7586 = desugar_data_pat env p  in
           match uu____7586 with
           | (env1,binder,p1) ->
               let p2 =
                 match p1 with
                 | ({
                      FStar_Syntax_Syntax.v = FStar_Syntax_Syntax.Pat_var
                        uu____7615;
                      FStar_Syntax_Syntax.p = uu____7616;_},uu____7617)::[]
                     -> []
                 | ({
                      FStar_Syntax_Syntax.v = FStar_Syntax_Syntax.Pat_wild
                        uu____7630;
                      FStar_Syntax_Syntax.p = uu____7631;_},uu____7632)::[]
                     -> []
                 | uu____7645 -> p1  in
               (env1, binder, p2))

and (desugar_binding_pat :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.pattern -> (env_t * bnd * annotated_pat Prims.list))
  = fun env  -> fun p  -> desugar_binding_pat_maybe_top false env p

and (desugar_match_pat_maybe_top :
  Prims.bool ->
    FStar_Syntax_DsEnv.env ->
      FStar_Parser_AST.pattern -> (env_t * annotated_pat Prims.list))
  =
  fun uu____7653  ->
    fun env  ->
      fun pat  ->
        let uu____7657 = desugar_data_pat env pat  in
        match uu____7657 with | (env1,uu____7673,pat1) -> (env1, pat1)

and (desugar_match_pat :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.pattern -> (env_t * annotated_pat Prims.list))
  = fun env  -> fun p  -> desugar_match_pat_maybe_top false env p

and (desugar_term_aq :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.term ->
      (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.antiquotations))
  =
  fun env  ->
    fun e  ->
      let env1 = FStar_Syntax_DsEnv.set_expect_typ env false  in
      desugar_term_maybe_top false env1 e

and (desugar_term :
  FStar_Syntax_DsEnv.env -> FStar_Parser_AST.term -> FStar_Syntax_Syntax.term)
  =
  fun env  ->
    fun e  ->
      let uu____7695 = desugar_term_aq env e  in
      match uu____7695 with | (t,aq) -> (check_no_aq aq; t)

and (desugar_typ_aq :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.term ->
      (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.antiquotations))
  =
  fun env  ->
    fun e  ->
      let env1 = FStar_Syntax_DsEnv.set_expect_typ env true  in
      desugar_term_maybe_top false env1 e

and (desugar_typ :
  FStar_Syntax_DsEnv.env -> FStar_Parser_AST.term -> FStar_Syntax_Syntax.term)
  =
  fun env  ->
    fun e  ->
      let uu____7714 = desugar_typ_aq env e  in
      match uu____7714 with | (t,aq) -> (check_no_aq aq; t)

and (desugar_machine_integer :
  FStar_Syntax_DsEnv.env ->
    Prims.string ->
      (FStar_Const.signedness * FStar_Const.width) ->
        FStar_Range.range -> FStar_Syntax_Syntax.term)
  =
  fun env  ->
    fun repr  ->
      fun uu____7724  ->
        fun range  ->
          match uu____7724 with
          | (signedness,width) ->
              let tnm =
                Prims.op_Hat "FStar."
                  (Prims.op_Hat
                     (match signedness with
                      | FStar_Const.Unsigned  -> "U"
                      | FStar_Const.Signed  -> "")
                     (Prims.op_Hat "Int"
                        (match width with
                         | FStar_Const.Int8  -> "8"
                         | FStar_Const.Int16  -> "16"
                         | FStar_Const.Int32  -> "32"
                         | FStar_Const.Int64  -> "64")))
                 in
              ((let uu____7746 =
                  let uu____7748 =
                    FStar_Const.within_bounds repr signedness width  in
                  Prims.op_Negation uu____7748  in
                if uu____7746
                then
                  let uu____7751 =
                    let uu____7757 =
                      FStar_Util.format2
                        "%s is not in the expected range for %s" repr tnm
                       in
                    (FStar_Errors.Error_OutOfRange, uu____7757)  in
                  FStar_Errors.log_issue range uu____7751
                else ());
               (let private_intro_nm =
                  Prims.op_Hat tnm
                    (Prims.op_Hat ".__"
                       (Prims.op_Hat
                          (match signedness with
                           | FStar_Const.Unsigned  -> "u"
                           | FStar_Const.Signed  -> "") "int_to_t"))
                   in
                let intro_nm =
                  Prims.op_Hat tnm
                    (Prims.op_Hat "."
                       (Prims.op_Hat
                          (match signedness with
                           | FStar_Const.Unsigned  -> "u"
                           | FStar_Const.Signed  -> "") "int_to_t"))
                   in
                let lid =
                  let uu____7778 = FStar_Ident.path_of_text intro_nm  in
                  FStar_Ident.lid_of_path uu____7778 range  in
                let lid1 =
                  let uu____7782 = FStar_Syntax_DsEnv.try_lookup_lid env lid
                     in
                  match uu____7782 with
                  | FStar_Pervasives_Native.Some intro_term ->
                      (match intro_term.FStar_Syntax_Syntax.n with
                       | FStar_Syntax_Syntax.Tm_fvar fv ->
                           let private_lid =
                             let uu____7792 =
                               FStar_Ident.path_of_text private_intro_nm  in
                             FStar_Ident.lid_of_path uu____7792 range  in
                           let private_fv =
                             let uu____7794 =
                               FStar_Syntax_Util.incr_delta_depth
                                 fv.FStar_Syntax_Syntax.fv_delta
                                in
                             FStar_Syntax_Syntax.lid_as_fv private_lid
                               uu____7794 fv.FStar_Syntax_Syntax.fv_qual
                              in
                           let uu___1266_7795 = intro_term  in
                           {
                             FStar_Syntax_Syntax.n =
                               (FStar_Syntax_Syntax.Tm_fvar private_fv);
                             FStar_Syntax_Syntax.pos =
                               (uu___1266_7795.FStar_Syntax_Syntax.pos);
                             FStar_Syntax_Syntax.vars =
                               (uu___1266_7795.FStar_Syntax_Syntax.vars)
                           }
                       | uu____7796 ->
                           failwith
                             (Prims.op_Hat "Unexpected non-fvar for "
                                intro_nm))
                  | FStar_Pervasives_Native.None  ->
                      let uu____7800 =
                        let uu____7806 =
                          FStar_Util.format1
                            "Unexpected numeric literal.  Restart F* to load %s."
                            tnm
                           in
                        (FStar_Errors.Fatal_UnexpectedNumericLiteral,
                          uu____7806)
                         in
                      FStar_Errors.raise_error uu____7800 range
                   in
                let repr1 =
                  FStar_Syntax_Syntax.mk
                    (FStar_Syntax_Syntax.Tm_constant
                       (FStar_Const.Const_int
                          (repr, FStar_Pervasives_Native.None)))
                    FStar_Pervasives_Native.None range
                   in
                let uu____7826 =
                  let uu____7833 =
                    let uu____7834 =
                      let uu____7851 =
                        let uu____7862 =
                          let uu____7871 =
                            FStar_Syntax_Syntax.as_implicit false  in
                          (repr1, uu____7871)  in
                        [uu____7862]  in
                      (lid1, uu____7851)  in
                    FStar_Syntax_Syntax.Tm_app uu____7834  in
                  FStar_Syntax_Syntax.mk uu____7833  in
                uu____7826 FStar_Pervasives_Native.None range))

and (desugar_attributes :
  env_t ->
    FStar_Parser_AST.term Prims.list -> FStar_Syntax_Syntax.cflag Prims.list)
  =
  fun env  ->
    fun cattributes  ->
      let desugar_attribute t =
        let uu____7919 =
          let uu____7920 = unparen t  in uu____7920.FStar_Parser_AST.tm  in
        match uu____7919 with
        | FStar_Parser_AST.Var
            { FStar_Ident.ns = uu____7921; FStar_Ident.ident = uu____7922;
              FStar_Ident.nsstr = uu____7923; FStar_Ident.str = "cps";_}
            -> FStar_Syntax_Syntax.CPS
        | uu____7928 ->
            let uu____7929 =
              let uu____7935 =
                let uu____7937 = FStar_Parser_AST.term_to_string t  in
                Prims.op_Hat "Unknown attribute " uu____7937  in
              (FStar_Errors.Fatal_UnknownAttribute, uu____7935)  in
            FStar_Errors.raise_error uu____7929 t.FStar_Parser_AST.range
         in
      FStar_List.map desugar_attribute cattributes

and (desugar_term_maybe_top :
  Prims.bool ->
    env_t ->
      FStar_Parser_AST.term ->
        (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.antiquotations))
  =
  fun top_level  ->
    fun env  ->
      fun top  ->
        let mk1 e =
          FStar_Syntax_Syntax.mk e FStar_Pervasives_Native.None
            top.FStar_Parser_AST.range
           in
        let noaqs = []  in
        let join_aqs aqs = FStar_List.flatten aqs  in
        let setpos e =
          let uu___1293_8024 = e  in
          {
            FStar_Syntax_Syntax.n = (uu___1293_8024.FStar_Syntax_Syntax.n);
            FStar_Syntax_Syntax.pos = (top.FStar_Parser_AST.range);
            FStar_Syntax_Syntax.vars =
              (uu___1293_8024.FStar_Syntax_Syntax.vars)
          }  in
        let uu____8027 =
          let uu____8028 = unparen top  in uu____8028.FStar_Parser_AST.tm  in
        match uu____8027 with
        | FStar_Parser_AST.Wild  -> ((setpos FStar_Syntax_Syntax.tun), noaqs)
        | FStar_Parser_AST.Labeled uu____8033 ->
            let uu____8042 = desugar_formula env top  in (uu____8042, noaqs)
        | FStar_Parser_AST.Requires (t,lopt) ->
            let uu____8051 = desugar_formula env t  in (uu____8051, noaqs)
        | FStar_Parser_AST.Ensures (t,lopt) ->
            let uu____8060 = desugar_formula env t  in (uu____8060, noaqs)
        | FStar_Parser_AST.Attributes ts ->
            failwith
              "Attributes should not be desugared by desugar_term_maybe_top"
        | FStar_Parser_AST.Const (FStar_Const.Const_int
            (i,FStar_Pervasives_Native.Some size)) ->
            let uu____8087 =
              desugar_machine_integer env i size top.FStar_Parser_AST.range
               in
            (uu____8087, noaqs)
        | FStar_Parser_AST.Const c ->
            let uu____8089 = mk1 (FStar_Syntax_Syntax.Tm_constant c)  in
            (uu____8089, noaqs)
        | FStar_Parser_AST.Op
            ({ FStar_Ident.idText = "=!="; FStar_Ident.idRange = r;_},args)
            ->
            let e =
              let uu____8098 =
                let uu____8099 =
                  let uu____8106 = FStar_Ident.mk_ident ("==", r)  in
                  (uu____8106, args)  in
                FStar_Parser_AST.Op uu____8099  in
              FStar_Parser_AST.mk_term uu____8098 top.FStar_Parser_AST.range
                top.FStar_Parser_AST.level
               in
            let uu____8111 =
              let uu____8112 =
                let uu____8113 =
                  let uu____8120 = FStar_Ident.mk_ident ("~", r)  in
                  (uu____8120, [e])  in
                FStar_Parser_AST.Op uu____8113  in
              FStar_Parser_AST.mk_term uu____8112 top.FStar_Parser_AST.range
                top.FStar_Parser_AST.level
               in
            desugar_term_aq env uu____8111
        | FStar_Parser_AST.Op (op_star,lhs::rhs::[]) when
            (let uu____8132 = FStar_Ident.text_of_id op_star  in
             uu____8132 = "*") &&
              (let uu____8137 =
                 op_as_term env (Prims.of_int (2)) top.FStar_Parser_AST.range
                   op_star
                  in
               FStar_All.pipe_right uu____8137 FStar_Option.isNone)
            ->
            let rec flatten1 t =
              match t.FStar_Parser_AST.tm with
              | FStar_Parser_AST.Op
                  ({ FStar_Ident.idText = "*";
                     FStar_Ident.idRange = uu____8154;_},t1::t2::[])
                  when
                  let uu____8160 =
                    op_as_term env (Prims.of_int (2))
                      top.FStar_Parser_AST.range op_star
                     in
                  FStar_All.pipe_right uu____8160 FStar_Option.isNone ->
                  let uu____8167 = flatten1 t1  in
                  FStar_List.append uu____8167 [t2]
              | uu____8170 -> [t]  in
            let terms = flatten1 lhs  in
            let t =
              let uu___1341_8175 = top  in
              let uu____8176 =
                let uu____8177 =
                  let uu____8188 =
                    FStar_List.map (fun _8199  -> FStar_Util.Inr _8199) terms
                     in
                  (uu____8188, rhs)  in
                FStar_Parser_AST.Sum uu____8177  in
              {
                FStar_Parser_AST.tm = uu____8176;
                FStar_Parser_AST.range =
                  (uu___1341_8175.FStar_Parser_AST.range);
                FStar_Parser_AST.level =
                  (uu___1341_8175.FStar_Parser_AST.level)
              }  in
            desugar_term_maybe_top top_level env t
        | FStar_Parser_AST.Tvar a ->
            let uu____8207 =
              let uu____8208 =
                FStar_Syntax_DsEnv.fail_or2
                  (FStar_Syntax_DsEnv.try_lookup_id env) a
                 in
              FStar_All.pipe_left setpos uu____8208  in
            (uu____8207, noaqs)
        | FStar_Parser_AST.Uvar u ->
            let uu____8214 =
              let uu____8220 =
                let uu____8222 =
                  let uu____8224 = FStar_Ident.text_of_id u  in
                  Prims.op_Hat uu____8224 " in non-universe context"  in
                Prims.op_Hat "Unexpected universe variable " uu____8222  in
              (FStar_Errors.Fatal_UnexpectedUniverseVariable, uu____8220)  in
            FStar_Errors.raise_error uu____8214 top.FStar_Parser_AST.range
        | FStar_Parser_AST.Op (s,args) ->
            let uu____8239 =
              op_as_term env (FStar_List.length args)
                top.FStar_Parser_AST.range s
               in
            (match uu____8239 with
             | FStar_Pervasives_Native.None  ->
                 let uu____8246 =
                   let uu____8252 =
                     let uu____8254 = FStar_Ident.text_of_id s  in
                     Prims.op_Hat "Unexpected or unbound operator: "
                       uu____8254
                      in
                   (FStar_Errors.Fatal_UnepxectedOrUnboundOperator,
                     uu____8252)
                    in
                 FStar_Errors.raise_error uu____8246
                   top.FStar_Parser_AST.range
             | FStar_Pervasives_Native.Some op ->
                 if (FStar_List.length args) > Prims.int_zero
                 then
                   let uu____8269 =
                     let uu____8294 =
                       FStar_All.pipe_right args
                         (FStar_List.map
                            (fun t  ->
                               let uu____8356 = desugar_term_aq env t  in
                               match uu____8356 with
                               | (t',s1) ->
                                   ((t', FStar_Pervasives_Native.None), s1)))
                        in
                     FStar_All.pipe_right uu____8294 FStar_List.unzip  in
                   (match uu____8269 with
                    | (args1,aqs) ->
                        let uu____8489 =
                          mk1 (FStar_Syntax_Syntax.Tm_app (op, args1))  in
                        (uu____8489, (join_aqs aqs)))
                 else (op, noaqs))
        | FStar_Parser_AST.Construct (n1,(a,uu____8506)::[]) when
            n1.FStar_Ident.str = "SMTPat" ->
            let uu____8523 =
              let uu___1370_8524 = top  in
              let uu____8525 =
                let uu____8526 =
                  let uu____8533 =
                    let uu___1372_8534 = top  in
                    let uu____8535 =
                      let uu____8536 =
                        FStar_Ident.lid_of_path ["Prims"; "smt_pat"]
                          top.FStar_Parser_AST.range
                         in
                      FStar_Parser_AST.Var uu____8536  in
                    {
                      FStar_Parser_AST.tm = uu____8535;
                      FStar_Parser_AST.range =
                        (uu___1372_8534.FStar_Parser_AST.range);
                      FStar_Parser_AST.level =
                        (uu___1372_8534.FStar_Parser_AST.level)
                    }  in
                  (uu____8533, a, FStar_Parser_AST.Nothing)  in
                FStar_Parser_AST.App uu____8526  in
              {
                FStar_Parser_AST.tm = uu____8525;
                FStar_Parser_AST.range =
                  (uu___1370_8524.FStar_Parser_AST.range);
                FStar_Parser_AST.level =
                  (uu___1370_8524.FStar_Parser_AST.level)
              }  in
            desugar_term_maybe_top top_level env uu____8523
        | FStar_Parser_AST.Construct (n1,(a,uu____8544)::[]) when
            n1.FStar_Ident.str = "SMTPatT" ->
            (FStar_Errors.log_issue top.FStar_Parser_AST.range
               (FStar_Errors.Warning_SMTPatTDeprecated,
                 "SMTPatT is deprecated; please just use SMTPat");
             (let uu____8564 =
                let uu___1382_8565 = top  in
                let uu____8566 =
                  let uu____8567 =
                    let uu____8574 =
                      let uu___1384_8575 = top  in
                      let uu____8576 =
                        let uu____8577 =
                          FStar_Ident.lid_of_path ["Prims"; "smt_pat"]
                            top.FStar_Parser_AST.range
                           in
                        FStar_Parser_AST.Var uu____8577  in
                      {
                        FStar_Parser_AST.tm = uu____8576;
                        FStar_Parser_AST.range =
                          (uu___1384_8575.FStar_Parser_AST.range);
                        FStar_Parser_AST.level =
                          (uu___1384_8575.FStar_Parser_AST.level)
                      }  in
                    (uu____8574, a, FStar_Parser_AST.Nothing)  in
                  FStar_Parser_AST.App uu____8567  in
                {
                  FStar_Parser_AST.tm = uu____8566;
                  FStar_Parser_AST.range =
                    (uu___1382_8565.FStar_Parser_AST.range);
                  FStar_Parser_AST.level =
                    (uu___1382_8565.FStar_Parser_AST.level)
                }  in
              desugar_term_maybe_top top_level env uu____8564))
        | FStar_Parser_AST.Construct (n1,(a,uu____8585)::[]) when
            n1.FStar_Ident.str = "SMTPatOr" ->
            let uu____8602 =
              let uu___1393_8603 = top  in
              let uu____8604 =
                let uu____8605 =
                  let uu____8612 =
                    let uu___1395_8613 = top  in
                    let uu____8614 =
                      let uu____8615 =
                        FStar_Ident.lid_of_path ["Prims"; "smt_pat_or"]
                          top.FStar_Parser_AST.range
                         in
                      FStar_Parser_AST.Var uu____8615  in
                    {
                      FStar_Parser_AST.tm = uu____8614;
                      FStar_Parser_AST.range =
                        (uu___1395_8613.FStar_Parser_AST.range);
                      FStar_Parser_AST.level =
                        (uu___1395_8613.FStar_Parser_AST.level)
                    }  in
                  (uu____8612, a, FStar_Parser_AST.Nothing)  in
                FStar_Parser_AST.App uu____8605  in
              {
                FStar_Parser_AST.tm = uu____8604;
                FStar_Parser_AST.range =
                  (uu___1393_8603.FStar_Parser_AST.range);
                FStar_Parser_AST.level =
                  (uu___1393_8603.FStar_Parser_AST.level)
              }  in
            desugar_term_maybe_top top_level env uu____8602
        | FStar_Parser_AST.Name
            { FStar_Ident.ns = uu____8621; FStar_Ident.ident = uu____8622;
              FStar_Ident.nsstr = uu____8623; FStar_Ident.str = "Type0";_}
            ->
            let uu____8628 =
              mk1 (FStar_Syntax_Syntax.Tm_type FStar_Syntax_Syntax.U_zero)
               in
            (uu____8628, noaqs)
        | FStar_Parser_AST.Name
            { FStar_Ident.ns = uu____8629; FStar_Ident.ident = uu____8630;
              FStar_Ident.nsstr = uu____8631; FStar_Ident.str = "Type";_}
            ->
            let uu____8636 =
              mk1 (FStar_Syntax_Syntax.Tm_type FStar_Syntax_Syntax.U_unknown)
               in
            (uu____8636, noaqs)
        | FStar_Parser_AST.Construct
            ({ FStar_Ident.ns = uu____8637; FStar_Ident.ident = uu____8638;
               FStar_Ident.nsstr = uu____8639; FStar_Ident.str = "Type";_},
             (t,FStar_Parser_AST.UnivApp )::[])
            ->
            let uu____8659 =
              let uu____8660 =
                let uu____8661 = desugar_universe t  in
                FStar_Syntax_Syntax.Tm_type uu____8661  in
              mk1 uu____8660  in
            (uu____8659, noaqs)
        | FStar_Parser_AST.Name
            { FStar_Ident.ns = uu____8662; FStar_Ident.ident = uu____8663;
              FStar_Ident.nsstr = uu____8664; FStar_Ident.str = "Effect";_}
            ->
            let uu____8669 =
              mk1 (FStar_Syntax_Syntax.Tm_constant FStar_Const.Const_effect)
               in
            (uu____8669, noaqs)
        | FStar_Parser_AST.Name
            { FStar_Ident.ns = uu____8670; FStar_Ident.ident = uu____8671;
              FStar_Ident.nsstr = uu____8672; FStar_Ident.str = "True";_}
            ->
            let uu____8677 =
              let uu____8678 =
                FStar_Ident.set_lid_range FStar_Parser_Const.true_lid
                  top.FStar_Parser_AST.range
                 in
              FStar_Syntax_Syntax.fvar uu____8678
                FStar_Syntax_Syntax.delta_constant
                FStar_Pervasives_Native.None
               in
            (uu____8677, noaqs)
        | FStar_Parser_AST.Name
            { FStar_Ident.ns = uu____8679; FStar_Ident.ident = uu____8680;
              FStar_Ident.nsstr = uu____8681; FStar_Ident.str = "False";_}
            ->
            let uu____8686 =
              let uu____8687 =
                FStar_Ident.set_lid_range FStar_Parser_Const.false_lid
                  top.FStar_Parser_AST.range
                 in
              FStar_Syntax_Syntax.fvar uu____8687
                FStar_Syntax_Syntax.delta_constant
                FStar_Pervasives_Native.None
               in
            (uu____8686, noaqs)
        | FStar_Parser_AST.Projector
            (eff_name,{ FStar_Ident.idText = txt;
                        FStar_Ident.idRange = uu____8690;_})
            when
            (is_special_effect_combinator txt) &&
              (FStar_Syntax_DsEnv.is_effect_name env eff_name)
            ->
            (FStar_Syntax_DsEnv.fail_if_qualified_by_curmodule env eff_name;
             (let uu____8693 =
                FStar_Syntax_DsEnv.try_lookup_effect_defn env eff_name  in
              match uu____8693 with
              | FStar_Pervasives_Native.Some ed ->
                  let lid = FStar_Syntax_Util.dm4f_lid ed txt  in
                  let uu____8702 =
                    FStar_Syntax_Syntax.fvar lid
                      (FStar_Syntax_Syntax.Delta_constant_at_level
                         Prims.int_one) FStar_Pervasives_Native.None
                     in
                  (uu____8702, noaqs)
              | FStar_Pervasives_Native.None  ->
                  let uu____8704 =
                    let uu____8706 = FStar_Ident.text_of_lid eff_name  in
                    FStar_Util.format2
                      "Member %s of effect %s is not accessible (using an effect abbreviation instead of the original effect ?)"
                      uu____8706 txt
                     in
                  failwith uu____8704))
        | FStar_Parser_AST.Var l ->
            (FStar_Syntax_DsEnv.fail_if_qualified_by_curmodule env l;
             (let uu____8715 = desugar_name mk1 setpos env true l  in
              (uu____8715, noaqs)))
        | FStar_Parser_AST.Name l ->
            (FStar_Syntax_DsEnv.fail_if_qualified_by_curmodule env l;
             (let uu____8724 = desugar_name mk1 setpos env true l  in
              (uu____8724, noaqs)))
        | FStar_Parser_AST.Projector (l,i) ->
            (FStar_Syntax_DsEnv.fail_if_qualified_by_curmodule env l;
             (let name =
                let uu____8742 = FStar_Syntax_DsEnv.try_lookup_datacon env l
                   in
                match uu____8742 with
                | FStar_Pervasives_Native.Some uu____8752 ->
                    FStar_Pervasives_Native.Some (true, l)
                | FStar_Pervasives_Native.None  ->
                    let uu____8760 =
                      FStar_Syntax_DsEnv.try_lookup_root_effect_name env l
                       in
                    (match uu____8760 with
                     | FStar_Pervasives_Native.Some new_name ->
                         FStar_Pervasives_Native.Some (false, new_name)
                     | uu____8778 -> FStar_Pervasives_Native.None)
                 in
              match name with
              | FStar_Pervasives_Native.Some (resolve,new_name) ->
                  let uu____8799 =
                    let uu____8800 =
                      FStar_Syntax_Util.mk_field_projector_name_from_ident
                        new_name i
                       in
                    desugar_name mk1 setpos env resolve uu____8800  in
                  (uu____8799, noaqs)
              | uu____8806 ->
                  let uu____8814 =
                    let uu____8820 =
                      FStar_Util.format1
                        "Data constructor or effect %s not found"
                        l.FStar_Ident.str
                       in
                    (FStar_Errors.Fatal_EffectNotFound, uu____8820)  in
                  FStar_Errors.raise_error uu____8814
                    top.FStar_Parser_AST.range))
        | FStar_Parser_AST.Discrim lid ->
            (FStar_Syntax_DsEnv.fail_if_qualified_by_curmodule env lid;
             (let uu____8830 = FStar_Syntax_DsEnv.try_lookup_datacon env lid
                 in
              match uu____8830 with
              | FStar_Pervasives_Native.None  ->
                  let uu____8837 =
                    let uu____8843 =
                      FStar_Util.format1 "Data constructor %s not found"
                        lid.FStar_Ident.str
                       in
                    (FStar_Errors.Fatal_DataContructorNotFound, uu____8843)
                     in
                  FStar_Errors.raise_error uu____8837
                    top.FStar_Parser_AST.range
              | uu____8851 ->
                  let lid' = FStar_Syntax_Util.mk_discriminator lid  in
                  let uu____8855 = desugar_name mk1 setpos env true lid'  in
                  (uu____8855, noaqs)))
        | FStar_Parser_AST.Construct (l,args) ->
            (FStar_Syntax_DsEnv.fail_if_qualified_by_curmodule env l;
             (let uu____8877 = FStar_Syntax_DsEnv.try_lookup_datacon env l
                 in
              match uu____8877 with
              | FStar_Pervasives_Native.Some head1 ->
                  let head2 = mk1 (FStar_Syntax_Syntax.Tm_fvar head1)  in
                  (match args with
                   | [] -> (head2, noaqs)
                   | uu____8896 ->
                       let uu____8903 =
                         FStar_Util.take
                           (fun uu____8927  ->
                              match uu____8927 with
                              | (uu____8933,imp) ->
                                  imp = FStar_Parser_AST.UnivApp) args
                          in
                       (match uu____8903 with
                        | (universes,args1) ->
                            let universes1 =
                              FStar_List.map
                                (fun x  ->
                                   desugar_universe
                                     (FStar_Pervasives_Native.fst x))
                                universes
                               in
                            let uu____8978 =
                              let uu____9003 =
                                FStar_List.map
                                  (fun uu____9046  ->
                                     match uu____9046 with
                                     | (t,imp) ->
                                         let uu____9063 =
                                           desugar_term_aq env t  in
                                         (match uu____9063 with
                                          | (te,aq) ->
                                              ((arg_withimp_e imp te), aq)))
                                  args1
                                 in
                              FStar_All.pipe_right uu____9003
                                FStar_List.unzip
                               in
                            (match uu____8978 with
                             | (args2,aqs) ->
                                 let head3 =
                                   if universes1 = []
                                   then head2
                                   else
                                     mk1
                                       (FStar_Syntax_Syntax.Tm_uinst
                                          (head2, universes1))
                                    in
                                 let uu____9206 =
                                   mk1
                                     (FStar_Syntax_Syntax.Tm_app
                                        (head3, args2))
                                    in
                                 (uu____9206, (join_aqs aqs)))))
              | FStar_Pervasives_Native.None  ->
                  let err =
                    let uu____9225 =
                      FStar_Syntax_DsEnv.try_lookup_effect_name env l  in
                    match uu____9225 with
                    | FStar_Pervasives_Native.None  ->
                        (FStar_Errors.Fatal_ConstructorNotFound,
                          (Prims.op_Hat "Constructor "
                             (Prims.op_Hat l.FStar_Ident.str " not found")))
                    | FStar_Pervasives_Native.Some uu____9236 ->
                        (FStar_Errors.Fatal_UnexpectedEffect,
                          (Prims.op_Hat "Effect "
                             (Prims.op_Hat l.FStar_Ident.str
                                " used at an unexpected position")))
                     in
                  FStar_Errors.raise_error err top.FStar_Parser_AST.range))
        | FStar_Parser_AST.Sum (binders,t) when
            FStar_Util.for_all
              (fun uu___8_9264  ->
                 match uu___8_9264 with
                 | FStar_Util.Inr uu____9270 -> true
                 | uu____9272 -> false) binders
            ->
            let terms =
              let uu____9281 =
                FStar_All.pipe_right binders
                  (FStar_List.map
                     (fun uu___9_9298  ->
                        match uu___9_9298 with
                        | FStar_Util.Inr x -> x
                        | FStar_Util.Inl uu____9304 -> failwith "Impossible"))
                 in
              FStar_List.append uu____9281 [t]  in
            let uu____9306 =
              let uu____9331 =
                FStar_All.pipe_right terms
                  (FStar_List.map
                     (fun t1  ->
                        let uu____9388 = desugar_typ_aq env t1  in
                        match uu____9388 with
                        | (t',aq) ->
                            let uu____9399 = FStar_Syntax_Syntax.as_arg t'
                               in
                            (uu____9399, aq)))
                 in
              FStar_All.pipe_right uu____9331 FStar_List.unzip  in
            (match uu____9306 with
             | (targs,aqs) ->
                 let tup =
                   let uu____9509 =
                     FStar_Parser_Const.mk_tuple_lid
                       (FStar_List.length targs) top.FStar_Parser_AST.range
                      in
                   FStar_Syntax_DsEnv.fail_or env
                     (FStar_Syntax_DsEnv.try_lookup_lid env) uu____9509
                    in
                 let uu____9518 =
                   mk1 (FStar_Syntax_Syntax.Tm_app (tup, targs))  in
                 (uu____9518, (join_aqs aqs)))
        | FStar_Parser_AST.Sum (binders,t) ->
            let uu____9545 =
              let uu____9562 =
                let uu____9569 =
                  let uu____9576 =
                    FStar_All.pipe_left (fun _9585  -> FStar_Util.Inl _9585)
                      (FStar_Parser_AST.mk_binder (FStar_Parser_AST.NoName t)
                         t.FStar_Parser_AST.range FStar_Parser_AST.Type_level
                         FStar_Pervasives_Native.None)
                     in
                  [uu____9576]  in
                FStar_List.append binders uu____9569  in
              FStar_List.fold_left
                (fun uu____9630  ->
                   fun b  ->
                     match uu____9630 with
                     | (env1,tparams,typs) ->
                         let uu____9691 =
                           match b with
                           | FStar_Util.Inl b1 -> desugar_binder env1 b1
                           | FStar_Util.Inr t1 ->
                               let uu____9706 = desugar_typ env1 t1  in
                               (FStar_Pervasives_Native.None, uu____9706)
                            in
                         (match uu____9691 with
                          | (xopt,t1) ->
                              let uu____9731 =
                                match xopt with
                                | FStar_Pervasives_Native.None  ->
                                    let uu____9740 =
                                      FStar_Syntax_Syntax.new_bv
                                        (FStar_Pervasives_Native.Some
                                           (top.FStar_Parser_AST.range))
                                        FStar_Syntax_Syntax.tun
                                       in
                                    (env1, uu____9740)
                                | FStar_Pervasives_Native.Some x ->
                                    FStar_Syntax_DsEnv.push_bv env1 x
                                 in
                              (match uu____9731 with
                               | (env2,x) ->
                                   let uu____9760 =
                                     let uu____9763 =
                                       let uu____9766 =
                                         let uu____9767 =
                                           no_annot_abs tparams t1  in
                                         FStar_All.pipe_left
                                           FStar_Syntax_Syntax.as_arg
                                           uu____9767
                                          in
                                       [uu____9766]  in
                                     FStar_List.append typs uu____9763  in
                                   (env2,
                                     (FStar_List.append tparams
                                        [(((let uu___1554_9793 = x  in
                                            {
                                              FStar_Syntax_Syntax.ppname =
                                                (uu___1554_9793.FStar_Syntax_Syntax.ppname);
                                              FStar_Syntax_Syntax.index =
                                                (uu___1554_9793.FStar_Syntax_Syntax.index);
                                              FStar_Syntax_Syntax.sort = t1
                                            })),
                                           FStar_Pervasives_Native.None)]),
                                     uu____9760)))) (env, [], []) uu____9562
               in
            (match uu____9545 with
             | (env1,uu____9821,targs) ->
                 let tup =
                   let uu____9844 =
                     FStar_Parser_Const.mk_dtuple_lid
                       (FStar_List.length targs) top.FStar_Parser_AST.range
                      in
                   FStar_Syntax_DsEnv.fail_or env1
                     (FStar_Syntax_DsEnv.try_lookup_lid env1) uu____9844
                    in
                 let uu____9845 =
                   FStar_All.pipe_left mk1
                     (FStar_Syntax_Syntax.Tm_app (tup, targs))
                    in
                 (uu____9845, noaqs))
        | FStar_Parser_AST.Product (binders,t) ->
            let uu____9864 = uncurry binders t  in
            (match uu____9864 with
             | (bs,t1) ->
                 let rec aux env1 bs1 uu___10_9908 =
                   match uu___10_9908 with
                   | [] ->
                       let cod =
                         desugar_comp top.FStar_Parser_AST.range true env1 t1
                          in
                       let uu____9925 =
                         FStar_Syntax_Util.arrow (FStar_List.rev bs1) cod  in
                       FStar_All.pipe_left setpos uu____9925
                   | hd1::tl1 ->
                       let bb = desugar_binder env1 hd1  in
                       let uu____9949 =
                         as_binder env1 hd1.FStar_Parser_AST.aqual bb  in
                       (match uu____9949 with
                        | (b,env2) -> aux env2 (b :: bs1) tl1)
                    in
                 let uu____9982 = aux env [] bs  in (uu____9982, noaqs))
        | FStar_Parser_AST.Refine (b,f) ->
            let uu____9991 = desugar_binder env b  in
            (match uu____9991 with
             | (FStar_Pervasives_Native.None ,uu____10002) ->
                 failwith "Missing binder in refinement"
             | b1 ->
                 let uu____10017 =
                   as_binder env FStar_Pervasives_Native.None b1  in
                 (match uu____10017 with
                  | ((x,uu____10033),env1) ->
                      let f1 = desugar_formula env1 f  in
                      let uu____10046 =
                        let uu____10047 = FStar_Syntax_Util.refine x f1  in
                        FStar_All.pipe_left setpos uu____10047  in
                      (uu____10046, noaqs)))
        | FStar_Parser_AST.Abs (binders,body) ->
            let bvss =
              FStar_List.map (gather_pattern_bound_vars false) binders  in
            let check_disjoint sets =
              let rec aux acc sets1 =
                match sets1 with
                | [] -> FStar_Pervasives_Native.None
                | set1::sets2 ->
                    let i = FStar_Util.set_intersect acc set1  in
                    let uu____10126 = FStar_Util.set_is_empty i  in
                    if uu____10126
                    then
                      let uu____10131 = FStar_Util.set_union acc set1  in
                      aux uu____10131 sets2
                    else
                      (let uu____10136 =
                         let uu____10137 = FStar_Util.set_elements i  in
                         FStar_List.hd uu____10137  in
                       FStar_Pervasives_Native.Some uu____10136)
                 in
              let uu____10140 = FStar_Syntax_Syntax.new_id_set ()  in
              aux uu____10140 sets  in
            ((let uu____10144 = check_disjoint bvss  in
              match uu____10144 with
              | FStar_Pervasives_Native.None  -> ()
              | FStar_Pervasives_Native.Some id1 ->
                  let uu____10148 =
                    let uu____10154 =
                      FStar_Util.format1
                        "Non-linear patterns are not permitted: `%s` appears more than once in this function definition."
                        id1.FStar_Ident.idText
                       in
                    (FStar_Errors.Fatal_NonLinearPatternNotPermitted,
                      uu____10154)
                     in
                  let uu____10158 = FStar_Ident.range_of_id id1  in
                  FStar_Errors.raise_error uu____10148 uu____10158);
             (let binders1 =
                FStar_All.pipe_right binders
                  (FStar_List.map replace_unit_pattern)
                 in
              let uu____10166 =
                FStar_List.fold_left
                  (fun uu____10186  ->
                     fun pat  ->
                       match uu____10186 with
                       | (env1,ftvs) ->
                           (match pat.FStar_Parser_AST.pat with
                            | FStar_Parser_AST.PatAscribed
                                (uu____10212,(t,FStar_Pervasives_Native.None
                                              ))
                                ->
                                let uu____10222 =
                                  let uu____10225 = free_type_vars env1 t  in
                                  FStar_List.append uu____10225 ftvs  in
                                (env1, uu____10222)
                            | FStar_Parser_AST.PatAscribed
                                (uu____10230,(t,FStar_Pervasives_Native.Some
                                              tac))
                                ->
                                let uu____10241 =
                                  let uu____10244 = free_type_vars env1 t  in
                                  let uu____10247 =
                                    let uu____10250 = free_type_vars env1 tac
                                       in
                                    FStar_List.append uu____10250 ftvs  in
                                  FStar_List.append uu____10244 uu____10247
                                   in
                                (env1, uu____10241)
                            | uu____10255 -> (env1, ftvs))) (env, [])
                  binders1
                 in
              match uu____10166 with
              | (uu____10264,ftv) ->
                  let ftv1 = sort_ftv ftv  in
                  let binders2 =
                    let uu____10276 =
                      FStar_All.pipe_right ftv1
                        (FStar_List.map
                           (fun a  ->
                              FStar_Parser_AST.mk_pattern
                                (FStar_Parser_AST.PatTvar
                                   (a,
                                     (FStar_Pervasives_Native.Some
                                        FStar_Parser_AST.Implicit)))
                                top.FStar_Parser_AST.range))
                       in
                    FStar_List.append uu____10276 binders1  in
                  let rec aux env1 bs sc_pat_opt uu___11_10333 =
                    match uu___11_10333 with
                    | [] ->
                        let uu____10360 = desugar_term_aq env1 body  in
                        (match uu____10360 with
                         | (body1,aq) ->
                             let body2 =
                               match sc_pat_opt with
                               | FStar_Pervasives_Native.Some (sc,pat) ->
                                   let body2 =
                                     let uu____10397 =
                                       let uu____10398 =
                                         FStar_Syntax_Syntax.pat_bvs pat  in
                                       FStar_All.pipe_right uu____10398
                                         (FStar_List.map
                                            FStar_Syntax_Syntax.mk_binder)
                                        in
                                     FStar_Syntax_Subst.close uu____10397
                                       body1
                                      in
                                   FStar_Syntax_Syntax.mk
                                     (FStar_Syntax_Syntax.Tm_match
                                        (sc,
                                          [(pat,
                                             FStar_Pervasives_Native.None,
                                             body2)]))
                                     FStar_Pervasives_Native.None
                                     body2.FStar_Syntax_Syntax.pos
                               | FStar_Pervasives_Native.None  -> body1  in
                             let uu____10467 =
                               let uu____10470 =
                                 no_annot_abs (FStar_List.rev bs) body2  in
                               setpos uu____10470  in
                             (uu____10467, aq))
                    | p::rest ->
                        let uu____10485 = desugar_binding_pat env1 p  in
                        (match uu____10485 with
                         | (env2,b,pat) ->
                             let pat1 =
                               match pat with
                               | [] -> FStar_Pervasives_Native.None
                               | (p1,uu____10519)::[] ->
                                   FStar_Pervasives_Native.Some p1
                               | uu____10534 ->
                                   FStar_Errors.raise_error
                                     (FStar_Errors.Fatal_UnsupportedDisjuctivePatterns,
                                       "Disjunctive patterns are not supported in abstractions")
                                     p.FStar_Parser_AST.prange
                                in
                             let uu____10543 =
                               match b with
                               | LetBinder uu____10584 ->
                                   failwith "Impossible"
                               | LocalBinder (x,aq) ->
                                   let sc_pat_opt1 =
                                     match (pat1, sc_pat_opt) with
                                     | (FStar_Pervasives_Native.None
                                        ,uu____10653) -> sc_pat_opt
                                     | (FStar_Pervasives_Native.Some
                                        p1,FStar_Pervasives_Native.None ) ->
                                         let uu____10707 =
                                           let uu____10716 =
                                             FStar_Syntax_Syntax.bv_to_name x
                                              in
                                           (uu____10716, p1)  in
                                         FStar_Pervasives_Native.Some
                                           uu____10707
                                     | (FStar_Pervasives_Native.Some
                                        p1,FStar_Pervasives_Native.Some
                                        (sc,p')) ->
                                         (match ((sc.FStar_Syntax_Syntax.n),
                                                  (p'.FStar_Syntax_Syntax.v))
                                          with
                                          | (FStar_Syntax_Syntax.Tm_name
                                             uu____10778,uu____10779) ->
                                              let tup2 =
                                                let uu____10781 =
                                                  FStar_Parser_Const.mk_tuple_data_lid
                                                    (Prims.of_int (2))
                                                    top.FStar_Parser_AST.range
                                                   in
                                                FStar_Syntax_Syntax.lid_as_fv
                                                  uu____10781
                                                  FStar_Syntax_Syntax.delta_constant
                                                  (FStar_Pervasives_Native.Some
                                                     FStar_Syntax_Syntax.Data_ctor)
                                                 in
                                              let sc1 =
                                                let uu____10786 =
                                                  let uu____10793 =
                                                    let uu____10794 =
                                                      let uu____10811 =
                                                        mk1
                                                          (FStar_Syntax_Syntax.Tm_fvar
                                                             tup2)
                                                         in
                                                      let uu____10814 =
                                                        let uu____10825 =
                                                          FStar_Syntax_Syntax.as_arg
                                                            sc
                                                           in
                                                        let uu____10834 =
                                                          let uu____10845 =
                                                            let uu____10854 =
                                                              FStar_Syntax_Syntax.bv_to_name
                                                                x
                                                               in
                                                            FStar_All.pipe_left
                                                              FStar_Syntax_Syntax.as_arg
                                                              uu____10854
                                                             in
                                                          [uu____10845]  in
                                                        uu____10825 ::
                                                          uu____10834
                                                         in
                                                      (uu____10811,
                                                        uu____10814)
                                                       in
                                                    FStar_Syntax_Syntax.Tm_app
                                                      uu____10794
                                                     in
                                                  FStar_Syntax_Syntax.mk
                                                    uu____10793
                                                   in
                                                uu____10786
                                                  FStar_Pervasives_Native.None
                                                  top.FStar_Parser_AST.range
                                                 in
                                              let p2 =
                                                let uu____10902 =
                                                  FStar_Range.union_ranges
                                                    p'.FStar_Syntax_Syntax.p
                                                    p1.FStar_Syntax_Syntax.p
                                                   in
                                                FStar_Syntax_Syntax.withinfo
                                                  (FStar_Syntax_Syntax.Pat_cons
                                                     (tup2,
                                                       [(p', false);
                                                       (p1, false)]))
                                                  uu____10902
                                                 in
                                              FStar_Pervasives_Native.Some
                                                (sc1, p2)
                                          | (FStar_Syntax_Syntax.Tm_app
                                             (uu____10953,args),FStar_Syntax_Syntax.Pat_cons
                                             (uu____10955,pats)) ->
                                              let tupn =
                                                let uu____11000 =
                                                  FStar_Parser_Const.mk_tuple_data_lid
                                                    (Prims.int_one +
                                                       (FStar_List.length
                                                          args))
                                                    top.FStar_Parser_AST.range
                                                   in
                                                FStar_Syntax_Syntax.lid_as_fv
                                                  uu____11000
                                                  FStar_Syntax_Syntax.delta_constant
                                                  (FStar_Pervasives_Native.Some
                                                     FStar_Syntax_Syntax.Data_ctor)
                                                 in
                                              let sc1 =
                                                let uu____11013 =
                                                  let uu____11014 =
                                                    let uu____11031 =
                                                      mk1
                                                        (FStar_Syntax_Syntax.Tm_fvar
                                                           tupn)
                                                       in
                                                    let uu____11034 =
                                                      let uu____11045 =
                                                        let uu____11056 =
                                                          let uu____11065 =
                                                            FStar_Syntax_Syntax.bv_to_name
                                                              x
                                                             in
                                                          FStar_All.pipe_left
                                                            FStar_Syntax_Syntax.as_arg
                                                            uu____11065
                                                           in
                                                        [uu____11056]  in
                                                      FStar_List.append args
                                                        uu____11045
                                                       in
                                                    (uu____11031,
                                                      uu____11034)
                                                     in
                                                  FStar_Syntax_Syntax.Tm_app
                                                    uu____11014
                                                   in
                                                mk1 uu____11013  in
                                              let p2 =
                                                let uu____11113 =
                                                  FStar_Range.union_ranges
                                                    p'.FStar_Syntax_Syntax.p
                                                    p1.FStar_Syntax_Syntax.p
                                                   in
                                                FStar_Syntax_Syntax.withinfo
                                                  (FStar_Syntax_Syntax.Pat_cons
                                                     (tupn,
                                                       (FStar_List.append
                                                          pats [(p1, false)])))
                                                  uu____11113
                                                 in
                                              FStar_Pervasives_Native.Some
                                                (sc1, p2)
                                          | uu____11160 ->
                                              failwith "Impossible")
                                      in
                                   ((x, aq), sc_pat_opt1)
                                in
                             (match uu____10543 with
                              | (b1,sc_pat_opt1) ->
                                  aux env2 (b1 :: bs) sc_pat_opt1 rest))
                     in
                  aux env [] FStar_Pervasives_Native.None binders2))
        | FStar_Parser_AST.App
            (uu____11254,uu____11255,FStar_Parser_AST.UnivApp ) ->
            let rec aux universes e =
              let uu____11277 =
                let uu____11278 = unparen e  in
                uu____11278.FStar_Parser_AST.tm  in
              match uu____11277 with
              | FStar_Parser_AST.App (e1,t,FStar_Parser_AST.UnivApp ) ->
                  let univ_arg = desugar_universe t  in
                  aux (univ_arg :: universes) e1
              | uu____11288 ->
                  let uu____11289 = desugar_term_aq env e  in
                  (match uu____11289 with
                   | (head1,aq) ->
                       let uu____11302 =
                         mk1
                           (FStar_Syntax_Syntax.Tm_uinst (head1, universes))
                          in
                       (uu____11302, aq))
               in
            aux [] top
        | FStar_Parser_AST.App uu____11309 ->
            let rec aux args aqs e =
              let uu____11386 =
                let uu____11387 = unparen e  in
                uu____11387.FStar_Parser_AST.tm  in
              match uu____11386 with
              | FStar_Parser_AST.App (e1,t,imp) when
                  imp <> FStar_Parser_AST.UnivApp ->
                  let uu____11405 = desugar_term_aq env t  in
                  (match uu____11405 with
                   | (t1,aq) ->
                       let arg = arg_withimp_e imp t1  in
                       aux (arg :: args) (aq :: aqs) e1)
              | uu____11453 ->
                  let uu____11454 = desugar_term_aq env e  in
                  (match uu____11454 with
                   | (head1,aq) ->
                       let uu____11475 =
                         mk1 (FStar_Syntax_Syntax.Tm_app (head1, args))  in
                       (uu____11475, (join_aqs (aq :: aqs))))
               in
            aux [] [] top
        | FStar_Parser_AST.Bind (x,t1,t2) ->
            let xpat =
              FStar_Parser_AST.mk_pattern
                (FStar_Parser_AST.PatVar (x, FStar_Pervasives_Native.None))
                x.FStar_Ident.idRange
               in
            let k =
              FStar_Parser_AST.mk_term (FStar_Parser_AST.Abs ([xpat], t2))
                t2.FStar_Parser_AST.range t2.FStar_Parser_AST.level
               in
            let bind_lid =
              FStar_Ident.lid_of_path ["bind"] x.FStar_Ident.idRange  in
            let bind1 =
              FStar_Parser_AST.mk_term (FStar_Parser_AST.Var bind_lid)
                x.FStar_Ident.idRange FStar_Parser_AST.Expr
               in
            let uu____11538 =
              FStar_Parser_AST.mkExplicitApp bind1 [t1; k]
                top.FStar_Parser_AST.range
               in
            desugar_term_aq env uu____11538
        | FStar_Parser_AST.Seq (t1,t2) ->
            let t =
              FStar_Parser_AST.mk_term
                (FStar_Parser_AST.Let
                   (FStar_Parser_AST.NoLetQualifier,
                     [(FStar_Pervasives_Native.None,
                        ((FStar_Parser_AST.mk_pattern
                            (FStar_Parser_AST.PatWild
                               FStar_Pervasives_Native.None)
                            t1.FStar_Parser_AST.range), t1))], t2))
                top.FStar_Parser_AST.range FStar_Parser_AST.Expr
               in
            let uu____11590 = desugar_term_aq env t  in
            (match uu____11590 with
             | (tm,s) ->
                 let uu____11601 =
                   mk1
                     (FStar_Syntax_Syntax.Tm_meta
                        (tm,
                          (FStar_Syntax_Syntax.Meta_desugared
                             FStar_Syntax_Syntax.Sequence)))
                    in
                 (uu____11601, s))
        | FStar_Parser_AST.LetOpen (lid,e) ->
            let env1 = FStar_Syntax_DsEnv.push_namespace env lid  in
            let uu____11607 =
              let uu____11620 = FStar_Syntax_DsEnv.expect_typ env1  in
              if uu____11620 then desugar_typ_aq else desugar_term_aq  in
            uu____11607 env1 e
        | FStar_Parser_AST.Let (qual,lbs,body) ->
            let is_rec = qual = FStar_Parser_AST.Rec  in
            let ds_let_rec_or_app uu____11679 =
              let bindings = lbs  in
              let funs =
                FStar_All.pipe_right bindings
                  (FStar_List.map
                     (fun uu____11822  ->
                        match uu____11822 with
                        | (attr_opt,(p,def)) ->
                            let uu____11880 = is_app_pattern p  in
                            if uu____11880
                            then
                              let uu____11913 =
                                destruct_app_pattern env top_level p  in
                              (attr_opt, uu____11913, def)
                            else
                              (match FStar_Parser_AST.un_function p def with
                               | FStar_Pervasives_Native.Some (p1,def1) ->
                                   let uu____11996 =
                                     destruct_app_pattern env top_level p1
                                      in
                                   (attr_opt, uu____11996, def1)
                               | uu____12041 ->
                                   (match p.FStar_Parser_AST.pat with
                                    | FStar_Parser_AST.PatAscribed
                                        ({
                                           FStar_Parser_AST.pat =
                                             FStar_Parser_AST.PatVar
                                             (id1,uu____12079);
                                           FStar_Parser_AST.prange =
                                             uu____12080;_},t)
                                        ->
                                        if top_level
                                        then
                                          let uu____12129 =
                                            let uu____12150 =
                                              let uu____12155 =
                                                FStar_Syntax_DsEnv.qualify
                                                  env id1
                                                 in
                                              FStar_Util.Inr uu____12155  in
                                            (uu____12150, [],
                                              (FStar_Pervasives_Native.Some t))
                                             in
                                          (attr_opt, uu____12129, def)
                                        else
                                          (attr_opt,
                                            ((FStar_Util.Inl id1), [],
                                              (FStar_Pervasives_Native.Some t)),
                                            def)
                                    | FStar_Parser_AST.PatVar
                                        (id1,uu____12247) ->
                                        if top_level
                                        then
                                          let uu____12283 =
                                            let uu____12304 =
                                              let uu____12309 =
                                                FStar_Syntax_DsEnv.qualify
                                                  env id1
                                                 in
                                              FStar_Util.Inr uu____12309  in
                                            (uu____12304, [],
                                              FStar_Pervasives_Native.None)
                                             in
                                          (attr_opt, uu____12283, def)
                                        else
                                          (attr_opt,
                                            ((FStar_Util.Inl id1), [],
                                              FStar_Pervasives_Native.None),
                                            def)
                                    | uu____12400 ->
                                        FStar_Errors.raise_error
                                          (FStar_Errors.Fatal_UnexpectedLetBinding,
                                            "Unexpected let binding")
                                          p.FStar_Parser_AST.prange))))
                 in
              let uu____12433 =
                FStar_List.fold_left
                  (fun uu____12506  ->
                     fun uu____12507  ->
                       match (uu____12506, uu____12507) with
                       | ((env1,fnames,rec_bindings),(_attr_opt,(f,uu____12615,uu____12616),uu____12617))
                           ->
                           let uu____12734 =
                             match f with
                             | FStar_Util.Inl x ->
                                 let uu____12760 =
                                   FStar_Syntax_DsEnv.push_bv env1 x  in
                                 (match uu____12760 with
                                  | (env2,xx) ->
                                      let uu____12779 =
                                        let uu____12782 =
                                          FStar_Syntax_Syntax.mk_binder xx
                                           in
                                        uu____12782 :: rec_bindings  in
                                      (env2, (FStar_Util.Inl xx),
                                        uu____12779))
                             | FStar_Util.Inr l ->
                                 let uu____12790 =
                                   FStar_Syntax_DsEnv.push_top_level_rec_binding
                                     env1 l.FStar_Ident.ident
                                     FStar_Syntax_Syntax.delta_equational
                                    in
                                 (uu____12790, (FStar_Util.Inr l),
                                   rec_bindings)
                              in
                           (match uu____12734 with
                            | (env2,lbname,rec_bindings1) ->
                                (env2, (lbname :: fnames), rec_bindings1)))
                  (env, [], []) funs
                 in
              match uu____12433 with
              | (env',fnames,rec_bindings) ->
                  let fnames1 = FStar_List.rev fnames  in
                  let rec_bindings1 = FStar_List.rev rec_bindings  in
                  let desugar_one_def env1 lbname uu____12938 =
                    match uu____12938 with
                    | (attrs_opt,(uu____12974,args,result_t),def) ->
                        let args1 =
                          FStar_All.pipe_right args
                            (FStar_List.map replace_unit_pattern)
                           in
                        let pos = def.FStar_Parser_AST.range  in
                        let def1 =
                          match result_t with
                          | FStar_Pervasives_Native.None  -> def
                          | FStar_Pervasives_Native.Some (t,tacopt) ->
                              let t1 =
                                let uu____13062 = is_comp_type env1 t  in
                                if uu____13062
                                then
                                  ((let uu____13066 =
                                      FStar_All.pipe_right args1
                                        (FStar_List.tryFind
                                           (fun x  ->
                                              let uu____13076 =
                                                is_var_pattern x  in
                                              Prims.op_Negation uu____13076))
                                       in
                                    match uu____13066 with
                                    | FStar_Pervasives_Native.None  -> ()
                                    | FStar_Pervasives_Native.Some p ->
                                        FStar_Errors.raise_error
                                          (FStar_Errors.Fatal_ComputationTypeNotAllowed,
                                            "Computation type annotations are only permitted on let-bindings without inlined patterns; replace this pattern with a variable")
                                          p.FStar_Parser_AST.prange);
                                   t)
                                else
                                  (let uu____13083 =
                                     ((FStar_Options.ml_ish ()) &&
                                        (let uu____13086 =
                                           FStar_Syntax_DsEnv.try_lookup_effect_name
                                             env1
                                             FStar_Parser_Const.effect_ML_lid
                                            in
                                         FStar_Option.isSome uu____13086))
                                       &&
                                       ((Prims.op_Negation is_rec) ||
                                          ((FStar_List.length args1) <>
                                             Prims.int_zero))
                                      in
                                   if uu____13083
                                   then FStar_Parser_AST.ml_comp t
                                   else FStar_Parser_AST.tot_comp t)
                                 in
                              FStar_Parser_AST.mk_term
                                (FStar_Parser_AST.Ascribed (def, t1, tacopt))
                                def.FStar_Parser_AST.range
                                FStar_Parser_AST.Expr
                           in
                        let def2 =
                          match args1 with
                          | [] -> def1
                          | uu____13097 ->
                              FStar_Parser_AST.mk_term
                                (FStar_Parser_AST.un_curry_abs args1 def1)
                                top.FStar_Parser_AST.range
                                top.FStar_Parser_AST.level
                           in
                        let body1 = desugar_term env1 def2  in
                        let lbname1 =
                          match lbname with
                          | FStar_Util.Inl x -> FStar_Util.Inl x
                          | FStar_Util.Inr l ->
                              let uu____13112 =
                                let uu____13113 =
                                  FStar_Syntax_Util.incr_delta_qualifier
                                    body1
                                   in
                                FStar_Syntax_Syntax.lid_as_fv l uu____13113
                                  FStar_Pervasives_Native.None
                                 in
                              FStar_Util.Inr uu____13112
                           in
                        let body2 =
                          if is_rec
                          then FStar_Syntax_Subst.close rec_bindings1 body1
                          else body1  in
                        let attrs =
                          match attrs_opt with
                          | FStar_Pervasives_Native.None  -> []
                          | FStar_Pervasives_Native.Some l ->
                              FStar_List.map (desugar_term env1) l
                           in
                        mk_lb
                          (attrs, lbname1, FStar_Syntax_Syntax.tun, body2,
                            pos)
                     in
                  let lbs1 =
                    FStar_List.map2
                      (desugar_one_def (if is_rec then env' else env))
                      fnames1 funs
                     in
                  let uu____13194 = desugar_term_aq env' body  in
                  (match uu____13194 with
                   | (body1,aq) ->
                       let uu____13207 =
                         let uu____13210 =
                           let uu____13211 =
                             let uu____13225 =
                               FStar_Syntax_Subst.close rec_bindings1 body1
                                in
                             ((is_rec, lbs1), uu____13225)  in
                           FStar_Syntax_Syntax.Tm_let uu____13211  in
                         FStar_All.pipe_left mk1 uu____13210  in
                       (uu____13207, aq))
               in
            let ds_non_rec attrs_opt pat t1 t2 =
              let attrs =
                match attrs_opt with
                | FStar_Pervasives_Native.None  -> []
                | FStar_Pervasives_Native.Some l ->
                    FStar_List.map (desugar_term env) l
                 in
              let t11 = desugar_term env t1  in
              let uu____13300 =
                desugar_binding_pat_maybe_top top_level env pat  in
              match uu____13300 with
              | (env1,binder,pat1) ->
                  let uu____13322 =
                    match binder with
                    | LetBinder (l,(t,_tacopt)) ->
                        let uu____13348 = desugar_term_aq env1 t2  in
                        (match uu____13348 with
                         | (body1,aq) ->
                             let fv =
                               let uu____13362 =
                                 FStar_Syntax_Util.incr_delta_qualifier t11
                                  in
                               FStar_Syntax_Syntax.lid_as_fv l uu____13362
                                 FStar_Pervasives_Native.None
                                in
                             let uu____13363 =
                               FStar_All.pipe_left mk1
                                 (FStar_Syntax_Syntax.Tm_let
                                    ((false,
                                       [mk_lb
                                          (attrs, (FStar_Util.Inr fv), t,
                                            t11,
                                            (t11.FStar_Syntax_Syntax.pos))]),
                                      body1))
                                in
                             (uu____13363, aq))
                    | LocalBinder (x,uu____13396) ->
                        let uu____13397 = desugar_term_aq env1 t2  in
                        (match uu____13397 with
                         | (body1,aq) ->
                             let body2 =
                               match pat1 with
                               | [] -> body1
                               | ({
                                    FStar_Syntax_Syntax.v =
                                      FStar_Syntax_Syntax.Pat_wild
                                      uu____13411;
                                    FStar_Syntax_Syntax.p = uu____13412;_},uu____13413)::[]
                                   -> body1
                               | uu____13426 ->
                                   let uu____13429 =
                                     let uu____13436 =
                                       let uu____13437 =
                                         let uu____13460 =
                                           FStar_Syntax_Syntax.bv_to_name x
                                            in
                                         let uu____13463 =
                                           desugar_disjunctive_pattern pat1
                                             FStar_Pervasives_Native.None
                                             body1
                                            in
                                         (uu____13460, uu____13463)  in
                                       FStar_Syntax_Syntax.Tm_match
                                         uu____13437
                                        in
                                     FStar_Syntax_Syntax.mk uu____13436  in
                                   uu____13429 FStar_Pervasives_Native.None
                                     top.FStar_Parser_AST.range
                                in
                             let uu____13500 =
                               let uu____13503 =
                                 let uu____13504 =
                                   let uu____13518 =
                                     let uu____13521 =
                                       let uu____13522 =
                                         FStar_Syntax_Syntax.mk_binder x  in
                                       [uu____13522]  in
                                     FStar_Syntax_Subst.close uu____13521
                                       body2
                                      in
                                   ((false,
                                      [mk_lb
                                         (attrs, (FStar_Util.Inl x),
                                           (x.FStar_Syntax_Syntax.sort), t11,
                                           (t11.FStar_Syntax_Syntax.pos))]),
                                     uu____13518)
                                    in
                                 FStar_Syntax_Syntax.Tm_let uu____13504  in
                               FStar_All.pipe_left mk1 uu____13503  in
                             (uu____13500, aq))
                     in
                  (match uu____13322 with | (tm,aq) -> (tm, aq))
               in
            let uu____13584 = FStar_List.hd lbs  in
            (match uu____13584 with
             | (attrs,(head_pat,defn)) ->
                 let uu____13628 = is_rec || (is_app_pattern head_pat)  in
                 if uu____13628
                 then ds_let_rec_or_app ()
                 else ds_non_rec attrs head_pat defn body)
        | FStar_Parser_AST.If (t1,t2,t3) ->
            let x =
              FStar_Syntax_Syntax.new_bv
                (FStar_Pervasives_Native.Some (t3.FStar_Parser_AST.range))
                FStar_Syntax_Syntax.tun
               in
            let t_bool1 =
              let uu____13644 =
                let uu____13645 =
                  FStar_Syntax_Syntax.lid_as_fv FStar_Parser_Const.bool_lid
                    FStar_Syntax_Syntax.delta_constant
                    FStar_Pervasives_Native.None
                   in
                FStar_Syntax_Syntax.Tm_fvar uu____13645  in
              mk1 uu____13644  in
            let uu____13646 = desugar_term_aq env t1  in
            (match uu____13646 with
             | (t1',aq1) ->
                 let uu____13657 = desugar_term_aq env t2  in
                 (match uu____13657 with
                  | (t2',aq2) ->
                      let uu____13668 = desugar_term_aq env t3  in
                      (match uu____13668 with
                       | (t3',aq3) ->
                           let uu____13679 =
                             let uu____13680 =
                               let uu____13681 =
                                 let uu____13704 =
                                   let uu____13721 =
                                     let uu____13736 =
                                       FStar_Syntax_Syntax.withinfo
                                         (FStar_Syntax_Syntax.Pat_constant
                                            (FStar_Const.Const_bool true))
                                         t1.FStar_Parser_AST.range
                                        in
                                     (uu____13736,
                                       FStar_Pervasives_Native.None, t2')
                                      in
                                   let uu____13750 =
                                     let uu____13767 =
                                       let uu____13782 =
                                         FStar_Syntax_Syntax.withinfo
                                           (FStar_Syntax_Syntax.Pat_wild x)
                                           t1.FStar_Parser_AST.range
                                          in
                                       (uu____13782,
                                         FStar_Pervasives_Native.None, t3')
                                        in
                                     [uu____13767]  in
                                   uu____13721 :: uu____13750  in
                                 (t1', uu____13704)  in
                               FStar_Syntax_Syntax.Tm_match uu____13681  in
                             mk1 uu____13680  in
                           (uu____13679, (join_aqs [aq1; aq2; aq3])))))
        | FStar_Parser_AST.TryWith (e,branches) ->
            let r = top.FStar_Parser_AST.range  in
            let handler = FStar_Parser_AST.mk_function branches r r  in
            let body =
              FStar_Parser_AST.mk_function
                [((FStar_Parser_AST.mk_pattern
                     (FStar_Parser_AST.PatConst FStar_Const.Const_unit) r),
                   FStar_Pervasives_Native.None, e)] r r
               in
            let try_with_lid1 = FStar_Ident.lid_of_path ["try_with"] r  in
            let try_with1 =
              FStar_Parser_AST.mk_term (FStar_Parser_AST.Var try_with_lid1) r
                FStar_Parser_AST.Expr
               in
            let a1 =
              FStar_Parser_AST.mk_term
                (FStar_Parser_AST.App
                   (try_with1, body, FStar_Parser_AST.Nothing)) r
                top.FStar_Parser_AST.level
               in
            let a2 =
              FStar_Parser_AST.mk_term
                (FStar_Parser_AST.App (a1, handler, FStar_Parser_AST.Nothing))
                r top.FStar_Parser_AST.level
               in
            desugar_term_aq env a2
        | FStar_Parser_AST.Match (e,branches) ->
            let desugar_branch uu____13978 =
              match uu____13978 with
              | (pat,wopt,b) ->
                  let uu____14000 = desugar_match_pat env pat  in
                  (match uu____14000 with
                   | (env1,pat1) ->
                       let wopt1 =
                         match wopt with
                         | FStar_Pervasives_Native.None  ->
                             FStar_Pervasives_Native.None
                         | FStar_Pervasives_Native.Some e1 ->
                             let uu____14031 = desugar_term env1 e1  in
                             FStar_Pervasives_Native.Some uu____14031
                          in
                       let uu____14036 = desugar_term_aq env1 b  in
                       (match uu____14036 with
                        | (b1,aq) ->
                            let uu____14049 =
                              desugar_disjunctive_pattern pat1 wopt1 b1  in
                            (uu____14049, aq)))
               in
            let uu____14054 = desugar_term_aq env e  in
            (match uu____14054 with
             | (e1,aq) ->
                 let uu____14065 =
                   let uu____14096 =
                     let uu____14129 = FStar_List.map desugar_branch branches
                        in
                     FStar_All.pipe_right uu____14129 FStar_List.unzip  in
                   FStar_All.pipe_right uu____14096
                     (fun uu____14347  ->
                        match uu____14347 with
                        | (x,y) -> ((FStar_List.flatten x), y))
                    in
                 (match uu____14065 with
                  | (brs,aqs) ->
                      let uu____14566 =
                        FStar_All.pipe_left mk1
                          (FStar_Syntax_Syntax.Tm_match (e1, brs))
                         in
                      (uu____14566, (join_aqs (aq :: aqs)))))
        | FStar_Parser_AST.Ascribed (e,t,tac_opt) ->
            let uu____14600 =
              let uu____14621 = is_comp_type env t  in
              if uu____14621
              then
                let comp = desugar_comp t.FStar_Parser_AST.range true env t
                   in
                ((FStar_Util.Inr comp), [])
              else
                (let uu____14676 = desugar_term_aq env t  in
                 match uu____14676 with
                 | (tm,aq) -> ((FStar_Util.Inl tm), aq))
               in
            (match uu____14600 with
             | (annot,aq0) ->
                 let tac_opt1 = FStar_Util.map_opt tac_opt (desugar_term env)
                    in
                 let uu____14768 = desugar_term_aq env e  in
                 (match uu____14768 with
                  | (e1,aq) ->
                      let uu____14779 =
                        FStar_All.pipe_left mk1
                          (FStar_Syntax_Syntax.Tm_ascribed
                             (e1, (annot, tac_opt1),
                               FStar_Pervasives_Native.None))
                         in
                      (uu____14779, (FStar_List.append aq0 aq))))
        | FStar_Parser_AST.Record (uu____14818,[]) ->
            FStar_Errors.raise_error
              (FStar_Errors.Fatal_UnexpectedEmptyRecord,
                "Unexpected empty record") top.FStar_Parser_AST.range
        | FStar_Parser_AST.Record (eopt,fields) ->
            let record = check_fields env fields top.FStar_Parser_AST.range
               in
            let user_ns =
              let uu____14861 = FStar_List.hd fields  in
              match uu____14861 with | (f,uu____14873) -> f.FStar_Ident.ns
               in
            let get_field xopt f =
              let found =
                FStar_All.pipe_right fields
                  (FStar_Util.find_opt
                     (fun uu____14919  ->
                        match uu____14919 with
                        | (g,uu____14926) ->
                            f.FStar_Ident.idText =
                              (g.FStar_Ident.ident).FStar_Ident.idText))
                 in
              let fn = FStar_Ident.lid_of_ids (FStar_List.append user_ns [f])
                 in
              match found with
              | FStar_Pervasives_Native.Some (uu____14933,e) -> (fn, e)
              | FStar_Pervasives_Native.None  ->
                  (match xopt with
                   | FStar_Pervasives_Native.None  ->
                       let uu____14947 =
                         let uu____14953 =
                           FStar_Util.format2
                             "Field %s of record type %s is missing"
                             f.FStar_Ident.idText
                             (record.FStar_Syntax_DsEnv.typename).FStar_Ident.str
                            in
                         (FStar_Errors.Fatal_MissingFieldInRecord,
                           uu____14953)
                          in
                       FStar_Errors.raise_error uu____14947
                         top.FStar_Parser_AST.range
                   | FStar_Pervasives_Native.Some x ->
                       (fn,
                         (FStar_Parser_AST.mk_term
                            (FStar_Parser_AST.Project (x, fn))
                            x.FStar_Parser_AST.range x.FStar_Parser_AST.level)))
               in
            let user_constrname =
              FStar_Ident.lid_of_ids
                (FStar_List.append user_ns
                   [record.FStar_Syntax_DsEnv.constrname])
               in
            let recterm =
              match eopt with
              | FStar_Pervasives_Native.None  ->
                  let uu____14964 =
                    let uu____14975 =
                      FStar_All.pipe_right record.FStar_Syntax_DsEnv.fields
                        (FStar_List.map
                           (fun uu____15006  ->
                              match uu____15006 with
                              | (f,uu____15016) ->
                                  let uu____15017 =
                                    let uu____15018 =
                                      get_field FStar_Pervasives_Native.None
                                        f
                                       in
                                    FStar_All.pipe_left
                                      FStar_Pervasives_Native.snd uu____15018
                                     in
                                  (uu____15017, FStar_Parser_AST.Nothing)))
                       in
                    (user_constrname, uu____14975)  in
                  FStar_Parser_AST.Construct uu____14964
              | FStar_Pervasives_Native.Some e ->
                  let x = FStar_Ident.gen e.FStar_Parser_AST.range  in
                  let xterm =
                    let uu____15036 =
                      let uu____15037 = FStar_Ident.lid_of_ids [x]  in
                      FStar_Parser_AST.Var uu____15037  in
                    FStar_Parser_AST.mk_term uu____15036
                      x.FStar_Ident.idRange FStar_Parser_AST.Expr
                     in
                  let record1 =
                    let uu____15039 =
                      let uu____15052 =
                        FStar_All.pipe_right record.FStar_Syntax_DsEnv.fields
                          (FStar_List.map
                             (fun uu____15082  ->
                                match uu____15082 with
                                | (f,uu____15092) ->
                                    get_field
                                      (FStar_Pervasives_Native.Some xterm) f))
                         in
                      (FStar_Pervasives_Native.None, uu____15052)  in
                    FStar_Parser_AST.Record uu____15039  in
                  FStar_Parser_AST.Let
                    (FStar_Parser_AST.NoLetQualifier,
                      [(FStar_Pervasives_Native.None,
                         ((FStar_Parser_AST.mk_pattern
                             (FStar_Parser_AST.PatVar
                                (x, FStar_Pervasives_Native.None))
                             x.FStar_Ident.idRange), e))],
                      (FStar_Parser_AST.mk_term record1
                         top.FStar_Parser_AST.range
                         top.FStar_Parser_AST.level))
               in
            let recterm1 =
              FStar_Parser_AST.mk_term recterm top.FStar_Parser_AST.range
                top.FStar_Parser_AST.level
               in
            let uu____15152 = desugar_term_aq env recterm1  in
            (match uu____15152 with
             | (e,s) ->
                 (match e.FStar_Syntax_Syntax.n with
                  | FStar_Syntax_Syntax.Tm_app
                      ({
                         FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar
                           fv;
                         FStar_Syntax_Syntax.pos = uu____15168;
                         FStar_Syntax_Syntax.vars = uu____15169;_},args)
                      ->
                      let uu____15195 =
                        let uu____15196 =
                          let uu____15197 =
                            let uu____15214 =
                              let uu____15217 =
                                FStar_Ident.set_lid_range
                                  (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                  e.FStar_Syntax_Syntax.pos
                                 in
                              let uu____15218 =
                                let uu____15221 =
                                  let uu____15222 =
                                    let uu____15229 =
                                      FStar_All.pipe_right
                                        record.FStar_Syntax_DsEnv.fields
                                        (FStar_List.map
                                           FStar_Pervasives_Native.fst)
                                       in
                                    ((record.FStar_Syntax_DsEnv.typename),
                                      uu____15229)
                                     in
                                  FStar_Syntax_Syntax.Record_ctor uu____15222
                                   in
                                FStar_Pervasives_Native.Some uu____15221  in
                              FStar_Syntax_Syntax.fvar uu____15217
                                FStar_Syntax_Syntax.delta_constant
                                uu____15218
                               in
                            (uu____15214, args)  in
                          FStar_Syntax_Syntax.Tm_app uu____15197  in
                        FStar_All.pipe_left mk1 uu____15196  in
                      (uu____15195, s)
                  | uu____15258 -> (e, s)))
        | FStar_Parser_AST.Project (e,f) ->
            (FStar_Syntax_DsEnv.fail_if_qualified_by_curmodule env f;
             (let uu____15262 =
                FStar_Syntax_DsEnv.fail_or env
                  (FStar_Syntax_DsEnv.try_lookup_dc_by_field_name env) f
                 in
              match uu____15262 with
              | (constrname,is_rec) ->
                  let uu____15281 = desugar_term_aq env e  in
                  (match uu____15281 with
                   | (e1,s) ->
                       let projname =
                         FStar_Syntax_Util.mk_field_projector_name_from_ident
                           constrname f.FStar_Ident.ident
                          in
                       let qual =
                         if is_rec
                         then
                           FStar_Pervasives_Native.Some
                             (FStar_Syntax_Syntax.Record_projector
                                (constrname, (f.FStar_Ident.ident)))
                         else FStar_Pervasives_Native.None  in
                       let uu____15301 =
                         let uu____15302 =
                           let uu____15303 =
                             let uu____15320 =
                               let uu____15323 =
                                 let uu____15324 = FStar_Ident.range_of_lid f
                                    in
                                 FStar_Ident.set_lid_range projname
                                   uu____15324
                                  in
                               FStar_Syntax_Syntax.fvar uu____15323
                                 (FStar_Syntax_Syntax.Delta_equational_at_level
                                    Prims.int_one) qual
                                in
                             let uu____15326 =
                               let uu____15337 =
                                 FStar_Syntax_Syntax.as_arg e1  in
                               [uu____15337]  in
                             (uu____15320, uu____15326)  in
                           FStar_Syntax_Syntax.Tm_app uu____15303  in
                         FStar_All.pipe_left mk1 uu____15302  in
                       (uu____15301, s))))
        | FStar_Parser_AST.NamedTyp (uu____15374,e) -> desugar_term_aq env e
        | FStar_Parser_AST.Paren e -> failwith "impossible"
        | FStar_Parser_AST.VQuote e ->
            let tm = desugar_term env e  in
            let uu____15384 =
              let uu____15385 = FStar_Syntax_Subst.compress tm  in
              uu____15385.FStar_Syntax_Syntax.n  in
            (match uu____15384 with
             | FStar_Syntax_Syntax.Tm_fvar fv ->
                 let uu____15393 =
                   let uu___2088_15394 =
                     let uu____15395 =
                       let uu____15397 = FStar_Syntax_Syntax.lid_of_fv fv  in
                       FStar_Ident.string_of_lid uu____15397  in
                     FStar_Syntax_Util.exp_string uu____15395  in
                   {
                     FStar_Syntax_Syntax.n =
                       (uu___2088_15394.FStar_Syntax_Syntax.n);
                     FStar_Syntax_Syntax.pos = (e.FStar_Parser_AST.range);
                     FStar_Syntax_Syntax.vars =
                       (uu___2088_15394.FStar_Syntax_Syntax.vars)
                   }  in
                 (uu____15393, noaqs)
             | uu____15398 ->
                 let uu____15399 =
                   let uu____15405 =
                     let uu____15407 = FStar_Syntax_Print.term_to_string tm
                        in
                     Prims.op_Hat "VQuote, expected an fvar, got: "
                       uu____15407
                      in
                   (FStar_Errors.Fatal_UnexpectedTermVQuote, uu____15405)  in
                 FStar_Errors.raise_error uu____15399
                   top.FStar_Parser_AST.range)
        | FStar_Parser_AST.Quote (e,FStar_Parser_AST.Static ) ->
            let uu____15416 = desugar_term_aq env e  in
            (match uu____15416 with
             | (tm,vts) ->
                 let qi =
                   {
                     FStar_Syntax_Syntax.qkind =
                       FStar_Syntax_Syntax.Quote_static;
                     FStar_Syntax_Syntax.antiquotes = vts
                   }  in
                 let uu____15428 =
                   FStar_All.pipe_left mk1
                     (FStar_Syntax_Syntax.Tm_quoted (tm, qi))
                    in
                 (uu____15428, noaqs))
        | FStar_Parser_AST.Antiquote e ->
            let bv =
              FStar_Syntax_Syntax.new_bv
                (FStar_Pervasives_Native.Some (e.FStar_Parser_AST.range))
                FStar_Syntax_Syntax.tun
               in
            let uu____15433 = FStar_Syntax_Syntax.bv_to_name bv  in
            let uu____15434 =
              let uu____15435 =
                let uu____15442 = desugar_term env e  in (bv, uu____15442)
                 in
              [uu____15435]  in
            (uu____15433, uu____15434)
        | FStar_Parser_AST.Quote (e,FStar_Parser_AST.Dynamic ) ->
            let qi =
              {
                FStar_Syntax_Syntax.qkind = FStar_Syntax_Syntax.Quote_dynamic;
                FStar_Syntax_Syntax.antiquotes = []
              }  in
            let uu____15467 =
              let uu____15468 =
                let uu____15469 =
                  let uu____15476 = desugar_term env e  in (uu____15476, qi)
                   in
                FStar_Syntax_Syntax.Tm_quoted uu____15469  in
              FStar_All.pipe_left mk1 uu____15468  in
            (uu____15467, noaqs)
        | FStar_Parser_AST.CalcProof (rel,init_expr,steps) ->
            let eta_and_annot rel1 =
              let x = FStar_Ident.gen rel1.FStar_Parser_AST.range  in
              let y = FStar_Ident.gen rel1.FStar_Parser_AST.range  in
              let xt =
                FStar_Parser_AST.mk_term (FStar_Parser_AST.Tvar x)
                  rel1.FStar_Parser_AST.range FStar_Parser_AST.Expr
                 in
              let yt =
                FStar_Parser_AST.mk_term (FStar_Parser_AST.Tvar y)
                  rel1.FStar_Parser_AST.range FStar_Parser_AST.Expr
                 in
              let pats =
                [FStar_Parser_AST.mk_pattern
                   (FStar_Parser_AST.PatVar (x, FStar_Pervasives_Native.None))
                   rel1.FStar_Parser_AST.range;
                FStar_Parser_AST.mk_pattern
                  (FStar_Parser_AST.PatVar (y, FStar_Pervasives_Native.None))
                  rel1.FStar_Parser_AST.range]
                 in
              let uu____15505 =
                let uu____15506 =
                  let uu____15513 =
                    let uu____15514 =
                      let uu____15515 =
                        let uu____15524 =
                          FStar_Parser_AST.mkApp rel1
                            [(xt, FStar_Parser_AST.Nothing);
                            (yt, FStar_Parser_AST.Nothing)]
                            rel1.FStar_Parser_AST.range
                           in
                        let uu____15537 =
                          let uu____15538 =
                            let uu____15539 = FStar_Ident.lid_of_str "Type0"
                               in
                            FStar_Parser_AST.Name uu____15539  in
                          FStar_Parser_AST.mk_term uu____15538
                            rel1.FStar_Parser_AST.range FStar_Parser_AST.Expr
                           in
                        (uu____15524, uu____15537,
                          FStar_Pervasives_Native.None)
                         in
                      FStar_Parser_AST.Ascribed uu____15515  in
                    FStar_Parser_AST.mk_term uu____15514
                      rel1.FStar_Parser_AST.range FStar_Parser_AST.Expr
                     in
                  (pats, uu____15513)  in
                FStar_Parser_AST.Abs uu____15506  in
              FStar_Parser_AST.mk_term uu____15505
                rel1.FStar_Parser_AST.range FStar_Parser_AST.Expr
               in
            let rel1 = eta_and_annot rel  in
            let wild r =
              FStar_Parser_AST.mk_term FStar_Parser_AST.Wild r
                FStar_Parser_AST.Expr
               in
            let init1 =
              FStar_Parser_AST.mk_term
                (FStar_Parser_AST.Var FStar_Parser_Const.calc_init_lid)
                FStar_Range.dummyRange FStar_Parser_AST.Expr
               in
            let last_expr =
              let uu____15554 = FStar_List.last steps  in
              match uu____15554 with
              | FStar_Pervasives_Native.Some (FStar_Parser_AST.CalcStep
                  (uu____15557,uu____15558,last_expr)) -> last_expr
              | uu____15560 -> failwith "impossible: no last_expr on calc"
               in
            let step r =
              FStar_Parser_AST.mk_term
                (FStar_Parser_AST.Var FStar_Parser_Const.calc_step_lid) r
                FStar_Parser_AST.Expr
               in
            let finish1 =
              FStar_Parser_AST.mkApp
                (FStar_Parser_AST.mk_term
                   (FStar_Parser_AST.Var FStar_Parser_Const.calc_finish_lid)
                   top.FStar_Parser_AST.range FStar_Parser_AST.Expr)
                [(rel1, FStar_Parser_AST.Nothing)] top.FStar_Parser_AST.range
               in
            let e =
              FStar_Parser_AST.mkApp init1
                [(init_expr, FStar_Parser_AST.Nothing)]
                FStar_Range.dummyRange
               in
            let uu____15588 =
              FStar_List.fold_left
                (fun uu____15605  ->
                   fun uu____15606  ->
                     match (uu____15605, uu____15606) with
                     | ((e1,prev),FStar_Parser_AST.CalcStep
                        (rel2,just,next_expr)) ->
                         let pf =
                           let uu____15629 =
                             let uu____15636 =
                               let uu____15643 =
                                 let uu____15650 =
                                   let uu____15657 =
                                     let uu____15662 = eta_and_annot rel2  in
                                     (uu____15662, FStar_Parser_AST.Nothing)
                                      in
                                   let uu____15663 =
                                     let uu____15670 =
                                       let uu____15677 =
                                         let uu____15682 =
                                           FStar_Parser_AST.thunk e1  in
                                         (uu____15682,
                                           FStar_Parser_AST.Nothing)
                                          in
                                       let uu____15683 =
                                         let uu____15690 =
                                           let uu____15695 =
                                             FStar_Parser_AST.thunk just  in
                                           (uu____15695,
                                             FStar_Parser_AST.Nothing)
                                            in
                                         [uu____15690]  in
                                       uu____15677 :: uu____15683  in
                                     (next_expr, FStar_Parser_AST.Nothing) ::
                                       uu____15670
                                      in
                                   uu____15657 :: uu____15663  in
                                 (prev, FStar_Parser_AST.Hash) :: uu____15650
                                  in
                               (init_expr, FStar_Parser_AST.Hash) ::
                                 uu____15643
                                in
                             ((wild rel2.FStar_Parser_AST.range),
                               FStar_Parser_AST.Hash) :: uu____15636
                              in
                           FStar_Parser_AST.mkApp
                             (step rel2.FStar_Parser_AST.range) uu____15629
                             FStar_Range.dummyRange
                            in
                         (pf, next_expr)) (e, init_expr) steps
               in
            (match uu____15588 with
             | (e1,uu____15733) ->
                 let e2 =
                   let uu____15735 =
                     let uu____15742 =
                       let uu____15749 =
                         let uu____15756 =
                           let uu____15761 = FStar_Parser_AST.thunk e1  in
                           (uu____15761, FStar_Parser_AST.Nothing)  in
                         [uu____15756]  in
                       (last_expr, FStar_Parser_AST.Hash) :: uu____15749  in
                     (init_expr, FStar_Parser_AST.Hash) :: uu____15742  in
                   FStar_Parser_AST.mkApp finish1 uu____15735
                     FStar_Range.dummyRange
                    in
                 desugar_term_maybe_top top_level env e2)
        | uu____15778 when
            top.FStar_Parser_AST.level = FStar_Parser_AST.Formula ->
            let uu____15779 = desugar_formula env top  in
            (uu____15779, noaqs)
        | uu____15780 ->
            let uu____15781 =
              let uu____15787 =
                let uu____15789 = FStar_Parser_AST.term_to_string top  in
                Prims.op_Hat "Unexpected term: " uu____15789  in
              (FStar_Errors.Fatal_UnexpectedTerm, uu____15787)  in
            FStar_Errors.raise_error uu____15781 top.FStar_Parser_AST.range

and (not_ascribed : FStar_Parser_AST.term -> Prims.bool) =
  fun t  ->
    match t.FStar_Parser_AST.tm with
    | FStar_Parser_AST.Ascribed uu____15799 -> false
    | uu____15809 -> true

and (desugar_args :
  FStar_Syntax_DsEnv.env ->
    (FStar_Parser_AST.term * FStar_Parser_AST.imp) Prims.list ->
      (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.arg_qualifier
        FStar_Pervasives_Native.option) Prims.list)
  =
  fun env  ->
    fun args  ->
      FStar_All.pipe_right args
        (FStar_List.map
           (fun uu____15847  ->
              match uu____15847 with
              | (a,imp) ->
                  let uu____15860 = desugar_term env a  in
                  arg_withimp_e imp uu____15860))

and (desugar_comp :
  FStar_Range.range ->
    Prims.bool ->
      FStar_Syntax_DsEnv.env ->
        FStar_Parser_AST.term ->
          FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax)
  =
  fun r  ->
    fun allow_type_promotion  ->
      fun env  ->
        fun t  ->
          let fail1 err = FStar_Errors.raise_error err r  in
          let is_requires uu____15897 =
            match uu____15897 with
            | (t1,uu____15904) ->
                let uu____15905 =
                  let uu____15906 = unparen t1  in
                  uu____15906.FStar_Parser_AST.tm  in
                (match uu____15905 with
                 | FStar_Parser_AST.Requires uu____15908 -> true
                 | uu____15917 -> false)
             in
          let is_ensures uu____15929 =
            match uu____15929 with
            | (t1,uu____15936) ->
                let uu____15937 =
                  let uu____15938 = unparen t1  in
                  uu____15938.FStar_Parser_AST.tm  in
                (match uu____15937 with
                 | FStar_Parser_AST.Ensures uu____15940 -> true
                 | uu____15949 -> false)
             in
          let is_app head1 uu____15967 =
            match uu____15967 with
            | (t1,uu____15975) ->
                let uu____15976 =
                  let uu____15977 = unparen t1  in
                  uu____15977.FStar_Parser_AST.tm  in
                (match uu____15976 with
                 | FStar_Parser_AST.App
                     ({ FStar_Parser_AST.tm = FStar_Parser_AST.Var d;
                        FStar_Parser_AST.range = uu____15980;
                        FStar_Parser_AST.level = uu____15981;_},uu____15982,uu____15983)
                     -> (d.FStar_Ident.ident).FStar_Ident.idText = head1
                 | uu____15985 -> false)
             in
          let is_smt_pat uu____15997 =
            match uu____15997 with
            | (t1,uu____16004) ->
                let uu____16005 =
                  let uu____16006 = unparen t1  in
                  uu____16006.FStar_Parser_AST.tm  in
                (match uu____16005 with
                 | FStar_Parser_AST.Construct
                     (cons1,({
                               FStar_Parser_AST.tm =
                                 FStar_Parser_AST.Construct
                                 (smtpat,uu____16010);
                               FStar_Parser_AST.range = uu____16011;
                               FStar_Parser_AST.level = uu____16012;_},uu____16013)::uu____16014::[])
                     ->
                     (FStar_Ident.lid_equals cons1
                        FStar_Parser_Const.cons_lid)
                       &&
                       (FStar_Util.for_some
                          (fun s  -> smtpat.FStar_Ident.str = s)
                          ["SMTPat"; "SMTPatT"; "SMTPatOr"])
                 | FStar_Parser_AST.Construct
                     (cons1,({
                               FStar_Parser_AST.tm = FStar_Parser_AST.Var
                                 smtpat;
                               FStar_Parser_AST.range = uu____16063;
                               FStar_Parser_AST.level = uu____16064;_},uu____16065)::uu____16066::[])
                     ->
                     (FStar_Ident.lid_equals cons1
                        FStar_Parser_Const.cons_lid)
                       &&
                       (FStar_Util.for_some
                          (fun s  -> smtpat.FStar_Ident.str = s)
                          ["smt_pat"; "smt_pat_or"])
                 | uu____16099 -> false)
             in
          let is_decreases = is_app "decreases"  in
          let pre_process_comp_typ t1 =
            let uu____16134 = head_and_args t1  in
            match uu____16134 with
            | (head1,args) ->
                (match head1.FStar_Parser_AST.tm with
                 | FStar_Parser_AST.Name lemma when
                     (lemma.FStar_Ident.ident).FStar_Ident.idText = "Lemma"
                     ->
                     let unit_tm =
                       ((FStar_Parser_AST.mk_term
                           (FStar_Parser_AST.Name FStar_Parser_Const.unit_lid)
                           t1.FStar_Parser_AST.range
                           FStar_Parser_AST.Type_level),
                         FStar_Parser_AST.Nothing)
                        in
                     let nil_pat =
                       ((FStar_Parser_AST.mk_term
                           (FStar_Parser_AST.Name FStar_Parser_Const.nil_lid)
                           t1.FStar_Parser_AST.range FStar_Parser_AST.Expr),
                         FStar_Parser_AST.Nothing)
                        in
                     let req_true =
                       let req =
                         FStar_Parser_AST.Requires
                           ((FStar_Parser_AST.mk_term
                               (FStar_Parser_AST.Name
                                  FStar_Parser_Const.true_lid)
                               t1.FStar_Parser_AST.range
                               FStar_Parser_AST.Formula),
                             FStar_Pervasives_Native.None)
                          in
                       ((FStar_Parser_AST.mk_term req
                           t1.FStar_Parser_AST.range
                           FStar_Parser_AST.Type_level),
                         FStar_Parser_AST.Nothing)
                        in
                     let thunk_ens uu____16227 =
                       match uu____16227 with
                       | (e,i) ->
                           let uu____16238 = FStar_Parser_AST.thunk e  in
                           (uu____16238, i)
                        in
                     let fail_lemma uu____16250 =
                       let expected_one_of =
                         ["Lemma post";
                         "Lemma (ensures post)";
                         "Lemma (requires pre) (ensures post)";
                         "Lemma post [SMTPat ...]";
                         "Lemma (ensures post) [SMTPat ...]";
                         "Lemma (ensures post) (decreases d)";
                         "Lemma (ensures post) (decreases d) [SMTPat ...]";
                         "Lemma (requires pre) (ensures post) (decreases d)";
                         "Lemma (requires pre) (ensures post) [SMTPat ...]";
                         "Lemma (requires pre) (ensures post) (decreases d) [SMTPat ...]"]
                          in
                       let msg = FStar_String.concat "\n\t" expected_one_of
                          in
                       FStar_Errors.raise_error
                         (FStar_Errors.Fatal_InvalidLemmaArgument,
                           (Prims.op_Hat
                              "Invalid arguments to 'Lemma'; expected one of the following:\n\t"
                              msg)) t1.FStar_Parser_AST.range
                        in
                     let args1 =
                       match args with
                       | [] -> fail_lemma ()
                       | req::[] when is_requires req -> fail_lemma ()
                       | smtpat::[] when is_smt_pat smtpat -> fail_lemma ()
                       | dec::[] when is_decreases dec -> fail_lemma ()
                       | ens::[] ->
                           let uu____16356 =
                             let uu____16363 =
                               let uu____16370 = thunk_ens ens  in
                               [uu____16370; nil_pat]  in
                             req_true :: uu____16363  in
                           unit_tm :: uu____16356
                       | req::ens::[] when
                           (is_requires req) && (is_ensures ens) ->
                           let uu____16417 =
                             let uu____16424 =
                               let uu____16431 = thunk_ens ens  in
                               [uu____16431; nil_pat]  in
                             req :: uu____16424  in
                           unit_tm :: uu____16417
                       | ens::smtpat::[] when
                           (((let uu____16480 = is_requires ens  in
                              Prims.op_Negation uu____16480) &&
                               (let uu____16483 = is_smt_pat ens  in
                                Prims.op_Negation uu____16483))
                              &&
                              (let uu____16486 = is_decreases ens  in
                               Prims.op_Negation uu____16486))
                             && (is_smt_pat smtpat)
                           ->
                           let uu____16488 =
                             let uu____16495 =
                               let uu____16502 = thunk_ens ens  in
                               [uu____16502; smtpat]  in
                             req_true :: uu____16495  in
                           unit_tm :: uu____16488
                       | ens::dec::[] when
                           (is_ensures ens) && (is_decreases dec) ->
                           let uu____16549 =
                             let uu____16556 =
                               let uu____16563 = thunk_ens ens  in
                               [uu____16563; nil_pat; dec]  in
                             req_true :: uu____16556  in
                           unit_tm :: uu____16549
                       | ens::dec::smtpat::[] when
                           ((is_ensures ens) && (is_decreases dec)) &&
                             (is_smt_pat smtpat)
                           ->
                           let uu____16623 =
                             let uu____16630 =
                               let uu____16637 = thunk_ens ens  in
                               [uu____16637; smtpat; dec]  in
                             req_true :: uu____16630  in
                           unit_tm :: uu____16623
                       | req::ens::dec::[] when
                           ((is_requires req) && (is_ensures ens)) &&
                             (is_decreases dec)
                           ->
                           let uu____16697 =
                             let uu____16704 =
                               let uu____16711 = thunk_ens ens  in
                               [uu____16711; nil_pat; dec]  in
                             req :: uu____16704  in
                           unit_tm :: uu____16697
                       | req::ens::smtpat::[] when
                           ((is_requires req) && (is_ensures ens)) &&
                             (is_smt_pat smtpat)
                           ->
                           let uu____16771 =
                             let uu____16778 =
                               let uu____16785 = thunk_ens ens  in
                               [uu____16785; smtpat]  in
                             req :: uu____16778  in
                           unit_tm :: uu____16771
                       | req::ens::dec::smtpat::[] when
                           (((is_requires req) && (is_ensures ens)) &&
                              (is_smt_pat smtpat))
                             && (is_decreases dec)
                           ->
                           let uu____16850 =
                             let uu____16857 =
                               let uu____16864 = thunk_ens ens  in
                               [uu____16864; dec; smtpat]  in
                             req :: uu____16857  in
                           unit_tm :: uu____16850
                       | _other -> fail_lemma ()  in
                     let head_and_attributes =
                       FStar_Syntax_DsEnv.fail_or env
                         (FStar_Syntax_DsEnv.try_lookup_effect_name_and_attributes
                            env) lemma
                        in
                     (head_and_attributes, args1)
                 | FStar_Parser_AST.Name l when
                     FStar_Syntax_DsEnv.is_effect_name env l ->
                     let uu____16926 =
                       FStar_Syntax_DsEnv.fail_or env
                         (FStar_Syntax_DsEnv.try_lookup_effect_name_and_attributes
                            env) l
                        in
                     (uu____16926, args)
                 | FStar_Parser_AST.Name l when
                     (let uu____16954 = FStar_Syntax_DsEnv.current_module env
                         in
                      FStar_Ident.lid_equals uu____16954
                        FStar_Parser_Const.prims_lid)
                       && ((l.FStar_Ident.ident).FStar_Ident.idText = "Tot")
                     ->
                     let uu____16957 =
                       let uu____16964 =
                         FStar_Ident.set_lid_range
                           FStar_Parser_Const.effect_Tot_lid
                           head1.FStar_Parser_AST.range
                          in
                       (uu____16964, [])  in
                     (uu____16957, args)
                 | FStar_Parser_AST.Name l when
                     (let uu____16982 = FStar_Syntax_DsEnv.current_module env
                         in
                      FStar_Ident.lid_equals uu____16982
                        FStar_Parser_Const.prims_lid)
                       && ((l.FStar_Ident.ident).FStar_Ident.idText = "GTot")
                     ->
                     let uu____16985 =
                       let uu____16992 =
                         FStar_Ident.set_lid_range
                           FStar_Parser_Const.effect_GTot_lid
                           head1.FStar_Parser_AST.range
                          in
                       (uu____16992, [])  in
                     (uu____16985, args)
                 | FStar_Parser_AST.Name l when
                     (((l.FStar_Ident.ident).FStar_Ident.idText = "Type") ||
                        ((l.FStar_Ident.ident).FStar_Ident.idText = "Type0"))
                       ||
                       ((l.FStar_Ident.ident).FStar_Ident.idText = "Effect")
                     ->
                     let uu____17014 =
                       let uu____17021 =
                         FStar_Ident.set_lid_range
                           FStar_Parser_Const.effect_Tot_lid
                           head1.FStar_Parser_AST.range
                          in
                       (uu____17021, [])  in
                     (uu____17014, [(t1, FStar_Parser_AST.Nothing)])
                 | uu____17044 when allow_type_promotion ->
                     let default_effect =
                       let uu____17046 = FStar_Options.ml_ish ()  in
                       if uu____17046
                       then FStar_Parser_Const.effect_ML_lid
                       else
                         ((let uu____17052 =
                             FStar_Options.warn_default_effects ()  in
                           if uu____17052
                           then
                             FStar_Errors.log_issue
                               head1.FStar_Parser_AST.range
                               (FStar_Errors.Warning_UseDefaultEffect,
                                 "Using default effect Tot")
                           else ());
                          FStar_Parser_Const.effect_Tot_lid)
                        in
                     let uu____17059 =
                       let uu____17066 =
                         FStar_Ident.set_lid_range default_effect
                           head1.FStar_Parser_AST.range
                          in
                       (uu____17066, [])  in
                     (uu____17059, [(t1, FStar_Parser_AST.Nothing)])
                 | uu____17089 ->
                     FStar_Errors.raise_error
                       (FStar_Errors.Fatal_EffectNotFound,
                         "Expected an effect constructor")
                       t1.FStar_Parser_AST.range)
             in
          let uu____17108 = pre_process_comp_typ t  in
          match uu____17108 with
          | ((eff,cattributes),args) ->
              (if (FStar_List.length args) = Prims.int_zero
               then
                 (let uu____17160 =
                    let uu____17166 =
                      let uu____17168 = FStar_Syntax_Print.lid_to_string eff
                         in
                      FStar_Util.format1 "Not enough args to effect %s"
                        uu____17168
                       in
                    (FStar_Errors.Fatal_NotEnoughArgsToEffect, uu____17166)
                     in
                  fail1 uu____17160)
               else ();
               (let is_universe uu____17184 =
                  match uu____17184 with
                  | (uu____17190,imp) -> imp = FStar_Parser_AST.UnivApp  in
                let uu____17192 = FStar_Util.take is_universe args  in
                match uu____17192 with
                | (universes,args1) ->
                    let universes1 =
                      FStar_List.map
                        (fun uu____17251  ->
                           match uu____17251 with
                           | (u,imp) -> desugar_universe u) universes
                       in
                    let uu____17258 =
                      let uu____17273 = FStar_List.hd args1  in
                      let uu____17282 = FStar_List.tl args1  in
                      (uu____17273, uu____17282)  in
                    (match uu____17258 with
                     | (result_arg,rest) ->
                         let result_typ =
                           desugar_typ env
                             (FStar_Pervasives_Native.fst result_arg)
                            in
                         let rest1 = desugar_args env rest  in
                         let uu____17337 =
                           let is_decrease uu____17376 =
                             match uu____17376 with
                             | (t1,uu____17387) ->
                                 (match t1.FStar_Syntax_Syntax.n with
                                  | FStar_Syntax_Syntax.Tm_app
                                      ({
                                         FStar_Syntax_Syntax.n =
                                           FStar_Syntax_Syntax.Tm_fvar fv;
                                         FStar_Syntax_Syntax.pos =
                                           uu____17398;
                                         FStar_Syntax_Syntax.vars =
                                           uu____17399;_},uu____17400::[])
                                      ->
                                      FStar_Syntax_Syntax.fv_eq_lid fv
                                        FStar_Parser_Const.decreases_lid
                                  | uu____17439 -> false)
                              in
                           FStar_All.pipe_right rest1
                             (FStar_List.partition is_decrease)
                            in
                         (match uu____17337 with
                          | (dec,rest2) ->
                              let decreases_clause =
                                FStar_All.pipe_right dec
                                  (FStar_List.map
                                     (fun uu____17556  ->
                                        match uu____17556 with
                                        | (t1,uu____17566) ->
                                            (match t1.FStar_Syntax_Syntax.n
                                             with
                                             | FStar_Syntax_Syntax.Tm_app
                                                 (uu____17575,(arg,uu____17577)::[])
                                                 ->
                                                 FStar_Syntax_Syntax.DECREASES
                                                   arg
                                             | uu____17616 ->
                                                 failwith "impos")))
                                 in
                              let no_additional_args =
                                let is_empty l =
                                  match l with
                                  | [] -> true
                                  | uu____17637 -> false  in
                                (((is_empty decreases_clause) &&
                                    (is_empty rest2))
                                   && (is_empty cattributes))
                                  && (is_empty universes1)
                                 in
                              let uu____17649 =
                                no_additional_args &&
                                  (FStar_Ident.lid_equals eff
                                     FStar_Parser_Const.effect_Tot_lid)
                                 in
                              if uu____17649
                              then FStar_Syntax_Syntax.mk_Total result_typ
                              else
                                (let uu____17656 =
                                   no_additional_args &&
                                     (FStar_Ident.lid_equals eff
                                        FStar_Parser_Const.effect_GTot_lid)
                                    in
                                 if uu____17656
                                 then
                                   FStar_Syntax_Syntax.mk_GTotal result_typ
                                 else
                                   (let flags =
                                      let uu____17666 =
                                        FStar_Ident.lid_equals eff
                                          FStar_Parser_Const.effect_Lemma_lid
                                         in
                                      if uu____17666
                                      then [FStar_Syntax_Syntax.LEMMA]
                                      else
                                        (let uu____17673 =
                                           FStar_Ident.lid_equals eff
                                             FStar_Parser_Const.effect_Tot_lid
                                            in
                                         if uu____17673
                                         then [FStar_Syntax_Syntax.TOTAL]
                                         else
                                           (let uu____17680 =
                                              FStar_Ident.lid_equals eff
                                                FStar_Parser_Const.effect_ML_lid
                                               in
                                            if uu____17680
                                            then
                                              [FStar_Syntax_Syntax.MLEFFECT]
                                            else
                                              (let uu____17687 =
                                                 FStar_Ident.lid_equals eff
                                                   FStar_Parser_Const.effect_GTot_lid
                                                  in
                                               if uu____17687
                                               then
                                                 [FStar_Syntax_Syntax.SOMETRIVIAL]
                                               else [])))
                                       in
                                    let flags1 =
                                      FStar_List.append flags cattributes  in
                                    let rest3 =
                                      let uu____17708 =
                                        FStar_Ident.lid_equals eff
                                          FStar_Parser_Const.effect_Lemma_lid
                                         in
                                      if uu____17708
                                      then
                                        match rest2 with
                                        | req::ens::(pat,aq)::[] ->
                                            let pat1 =
                                              match pat.FStar_Syntax_Syntax.n
                                              with
                                              | FStar_Syntax_Syntax.Tm_fvar
                                                  fv when
                                                  FStar_Syntax_Syntax.fv_eq_lid
                                                    fv
                                                    FStar_Parser_Const.nil_lid
                                                  ->
                                                  let nil =
                                                    FStar_Syntax_Syntax.mk_Tm_uinst
                                                      pat
                                                      [FStar_Syntax_Syntax.U_zero]
                                                     in
                                                  let pattern =
                                                    let uu____17799 =
                                                      FStar_Ident.set_lid_range
                                                        FStar_Parser_Const.pattern_lid
                                                        pat.FStar_Syntax_Syntax.pos
                                                       in
                                                    FStar_Syntax_Syntax.fvar
                                                      uu____17799
                                                      FStar_Syntax_Syntax.delta_constant
                                                      FStar_Pervasives_Native.None
                                                     in
                                                  FStar_Syntax_Syntax.mk_Tm_app
                                                    nil
                                                    [(pattern,
                                                       (FStar_Pervasives_Native.Some
                                                          FStar_Syntax_Syntax.imp_tag))]
                                                    FStar_Pervasives_Native.None
                                                    pat.FStar_Syntax_Syntax.pos
                                              | uu____17820 -> pat  in
                                            let uu____17821 =
                                              let uu____17832 =
                                                let uu____17843 =
                                                  let uu____17852 =
                                                    FStar_Syntax_Syntax.mk
                                                      (FStar_Syntax_Syntax.Tm_meta
                                                         (pat1,
                                                           (FStar_Syntax_Syntax.Meta_desugared
                                                              FStar_Syntax_Syntax.Meta_smt_pat)))
                                                      FStar_Pervasives_Native.None
                                                      pat1.FStar_Syntax_Syntax.pos
                                                     in
                                                  (uu____17852, aq)  in
                                                [uu____17843]  in
                                              ens :: uu____17832  in
                                            req :: uu____17821
                                        | uu____17893 -> rest2
                                      else rest2  in
                                    FStar_Syntax_Syntax.mk_Comp
                                      {
                                        FStar_Syntax_Syntax.comp_univs =
                                          universes1;
                                        FStar_Syntax_Syntax.effect_name = eff;
                                        FStar_Syntax_Syntax.result_typ =
                                          result_typ;
                                        FStar_Syntax_Syntax.effect_args =
                                          rest3;
                                        FStar_Syntax_Syntax.flags =
                                          (FStar_List.append flags1
                                             decreases_clause)
                                      }))))))

and (desugar_formula :
  FStar_Syntax_DsEnv.env -> FStar_Parser_AST.term -> FStar_Syntax_Syntax.term)
  =
  fun env  ->
    fun f  ->
      let connective s =
        match s with
        | "/\\" -> FStar_Pervasives_Native.Some FStar_Parser_Const.and_lid
        | "\\/" -> FStar_Pervasives_Native.Some FStar_Parser_Const.or_lid
        | "==>" -> FStar_Pervasives_Native.Some FStar_Parser_Const.imp_lid
        | "<==>" -> FStar_Pervasives_Native.Some FStar_Parser_Const.iff_lid
        | "~" -> FStar_Pervasives_Native.Some FStar_Parser_Const.not_lid
        | uu____17925 -> FStar_Pervasives_Native.None  in
      let mk1 t =
        FStar_Syntax_Syntax.mk t FStar_Pervasives_Native.None
          f.FStar_Parser_AST.range
         in
      let setpos t =
        let uu___2395_17947 = t  in
        {
          FStar_Syntax_Syntax.n = (uu___2395_17947.FStar_Syntax_Syntax.n);
          FStar_Syntax_Syntax.pos = (f.FStar_Parser_AST.range);
          FStar_Syntax_Syntax.vars =
            (uu___2395_17947.FStar_Syntax_Syntax.vars)
        }  in
      let desugar_quant q b pats body =
        let tk =
          desugar_binder env
            (let uu___2402_18001 = b  in
             {
               FStar_Parser_AST.b = (uu___2402_18001.FStar_Parser_AST.b);
               FStar_Parser_AST.brange =
                 (uu___2402_18001.FStar_Parser_AST.brange);
               FStar_Parser_AST.blevel = FStar_Parser_AST.Formula;
               FStar_Parser_AST.aqual =
                 (uu___2402_18001.FStar_Parser_AST.aqual)
             })
           in
        let with_pats env1 uu____18030 body1 =
          match uu____18030 with
          | (names1,pats1) ->
              (match (names1, pats1) with
               | ([],[]) -> body1
               | ([],uu____18076::uu____18077) ->
                   failwith
                     "Impossible: Annotated pattern without binders in scope"
               | uu____18095 ->
                   let names2 =
                     FStar_All.pipe_right names1
                       (FStar_List.map
                          (fun i  ->
                             let uu___2421_18122 =
                               FStar_Syntax_DsEnv.fail_or2
                                 (FStar_Syntax_DsEnv.try_lookup_id env1) i
                                in
                             {
                               FStar_Syntax_Syntax.n =
                                 (uu___2421_18122.FStar_Syntax_Syntax.n);
                               FStar_Syntax_Syntax.pos =
                                 (i.FStar_Ident.idRange);
                               FStar_Syntax_Syntax.vars =
                                 (uu___2421_18122.FStar_Syntax_Syntax.vars)
                             }))
                      in
                   let pats2 =
                     FStar_All.pipe_right pats1
                       (FStar_List.map
                          (fun es  ->
                             FStar_All.pipe_right es
                               (FStar_List.map
                                  (fun e  ->
                                     let uu____18185 = desugar_term env1 e
                                        in
                                     FStar_All.pipe_left
                                       (arg_withimp_t
                                          FStar_Parser_AST.Nothing)
                                       uu____18185))))
                      in
                   mk1
                     (FStar_Syntax_Syntax.Tm_meta
                        (body1,
                          (FStar_Syntax_Syntax.Meta_pattern (names2, pats2)))))
           in
        match tk with
        | (FStar_Pervasives_Native.Some a,k) ->
            let uu____18216 = FStar_Syntax_DsEnv.push_bv env a  in
            (match uu____18216 with
             | (env1,a1) ->
                 let a2 =
                   let uu___2434_18226 = a1  in
                   {
                     FStar_Syntax_Syntax.ppname =
                       (uu___2434_18226.FStar_Syntax_Syntax.ppname);
                     FStar_Syntax_Syntax.index =
                       (uu___2434_18226.FStar_Syntax_Syntax.index);
                     FStar_Syntax_Syntax.sort = k
                   }  in
                 let body1 = desugar_formula env1 body  in
                 let body2 = with_pats env1 pats body1  in
                 let body3 =
                   let uu____18232 =
                     let uu____18235 =
                       let uu____18236 = FStar_Syntax_Syntax.mk_binder a2  in
                       [uu____18236]  in
                     no_annot_abs uu____18235 body2  in
                   FStar_All.pipe_left setpos uu____18232  in
                 let uu____18257 =
                   let uu____18258 =
                     let uu____18275 =
                       let uu____18278 =
                         FStar_Ident.set_lid_range q
                           b.FStar_Parser_AST.brange
                          in
                       FStar_Syntax_Syntax.fvar uu____18278
                         (FStar_Syntax_Syntax.Delta_constant_at_level
                            Prims.int_one) FStar_Pervasives_Native.None
                        in
                     let uu____18280 =
                       let uu____18291 = FStar_Syntax_Syntax.as_arg body3  in
                       [uu____18291]  in
                     (uu____18275, uu____18280)  in
                   FStar_Syntax_Syntax.Tm_app uu____18258  in
                 FStar_All.pipe_left mk1 uu____18257)
        | uu____18330 -> failwith "impossible"  in
      let push_quant q binders pats body =
        match binders with
        | b::b'::_rest ->
            let rest = b' :: _rest  in
            let body1 =
              let uu____18395 = q (rest, pats, body)  in
              let uu____18398 =
                FStar_Range.union_ranges b'.FStar_Parser_AST.brange
                  body.FStar_Parser_AST.range
                 in
              FStar_Parser_AST.mk_term uu____18395 uu____18398
                FStar_Parser_AST.Formula
               in
            let uu____18399 = q ([b], ([], []), body1)  in
            FStar_Parser_AST.mk_term uu____18399 f.FStar_Parser_AST.range
              FStar_Parser_AST.Formula
        | uu____18410 -> failwith "impossible"  in
      let uu____18414 =
        let uu____18415 = unparen f  in uu____18415.FStar_Parser_AST.tm  in
      match uu____18414 with
      | FStar_Parser_AST.Labeled (f1,l,p) ->
          let f2 = desugar_formula env f1  in
          FStar_All.pipe_left mk1
            (FStar_Syntax_Syntax.Tm_meta
               (f2,
                 (FStar_Syntax_Syntax.Meta_labeled
                    (l, (f2.FStar_Syntax_Syntax.pos), p))))
      | FStar_Parser_AST.QForall ([],uu____18428,uu____18429) ->
          failwith "Impossible: Quantifier without binders"
      | FStar_Parser_AST.QExists ([],uu____18453,uu____18454) ->
          failwith "Impossible: Quantifier without binders"
      | FStar_Parser_AST.QForall (_1::_2::_3,pats,body) ->
          let binders = _1 :: _2 :: _3  in
          let uu____18510 =
            push_quant (fun x  -> FStar_Parser_AST.QForall x) binders pats
              body
             in
          desugar_formula env uu____18510
      | FStar_Parser_AST.QExists (_1::_2::_3,pats,body) ->
          let binders = _1 :: _2 :: _3  in
          let uu____18554 =
            push_quant (fun x  -> FStar_Parser_AST.QExists x) binders pats
              body
             in
          desugar_formula env uu____18554
      | FStar_Parser_AST.QForall (b::[],pats,body) ->
          desugar_quant FStar_Parser_Const.forall_lid b pats body
      | FStar_Parser_AST.QExists (b::[],pats,body) ->
          desugar_quant FStar_Parser_Const.exists_lid b pats body
      | FStar_Parser_AST.Paren f1 -> failwith "impossible"
      | uu____18618 -> desugar_term env f

and (typars_of_binders :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.binder Prims.list ->
      (FStar_Syntax_DsEnv.env * (FStar_Syntax_Syntax.bv *
        FStar_Syntax_Syntax.aqual) Prims.list))
  =
  fun env  ->
    fun bs  ->
      let uu____18623 =
        FStar_List.fold_left
          (fun uu____18656  ->
             fun b  ->
               match uu____18656 with
               | (env1,out) ->
                   let tk =
                     desugar_binder env1
                       (let uu___2513_18700 = b  in
                        {
                          FStar_Parser_AST.b =
                            (uu___2513_18700.FStar_Parser_AST.b);
                          FStar_Parser_AST.brange =
                            (uu___2513_18700.FStar_Parser_AST.brange);
                          FStar_Parser_AST.blevel = FStar_Parser_AST.Formula;
                          FStar_Parser_AST.aqual =
                            (uu___2513_18700.FStar_Parser_AST.aqual)
                        })
                      in
                   (match tk with
                    | (FStar_Pervasives_Native.Some a,k) ->
                        let uu____18715 = FStar_Syntax_DsEnv.push_bv env1 a
                           in
                        (match uu____18715 with
                         | (env2,a1) ->
                             let a2 =
                               let uu___2523_18733 = a1  in
                               {
                                 FStar_Syntax_Syntax.ppname =
                                   (uu___2523_18733.FStar_Syntax_Syntax.ppname);
                                 FStar_Syntax_Syntax.index =
                                   (uu___2523_18733.FStar_Syntax_Syntax.index);
                                 FStar_Syntax_Syntax.sort = k
                               }  in
                             let uu____18734 =
                               let uu____18741 =
                                 let uu____18746 =
                                   trans_aqual env2 b.FStar_Parser_AST.aqual
                                    in
                                 (a2, uu____18746)  in
                               uu____18741 :: out  in
                             (env2, uu____18734))
                    | uu____18757 ->
                        FStar_Errors.raise_error
                          (FStar_Errors.Fatal_UnexpectedBinder,
                            "Unexpected binder") b.FStar_Parser_AST.brange))
          (env, []) bs
         in
      match uu____18623 with | (env1,tpars) -> (env1, (FStar_List.rev tpars))

and (desugar_binder :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.binder ->
      (FStar_Ident.ident FStar_Pervasives_Native.option *
        FStar_Syntax_Syntax.term))
  =
  fun env  ->
    fun b  ->
      match b.FStar_Parser_AST.b with
      | FStar_Parser_AST.TAnnotated (x,t) ->
          let uu____18830 = desugar_typ env t  in
          ((FStar_Pervasives_Native.Some x), uu____18830)
      | FStar_Parser_AST.Annotated (x,t) ->
          let uu____18835 = desugar_typ env t  in
          ((FStar_Pervasives_Native.Some x), uu____18835)
      | FStar_Parser_AST.TVariable x ->
          let uu____18839 =
            FStar_Syntax_Syntax.mk
              (FStar_Syntax_Syntax.Tm_type FStar_Syntax_Syntax.U_unknown)
              FStar_Pervasives_Native.None x.FStar_Ident.idRange
             in
          ((FStar_Pervasives_Native.Some x), uu____18839)
      | FStar_Parser_AST.NoName t ->
          let uu____18843 = desugar_typ env t  in
          (FStar_Pervasives_Native.None, uu____18843)
      | FStar_Parser_AST.Variable x ->
          ((FStar_Pervasives_Native.Some x), FStar_Syntax_Syntax.tun)

and (as_binder :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.arg_qualifier FStar_Pervasives_Native.option ->
      (FStar_Ident.ident FStar_Pervasives_Native.option *
        FStar_Syntax_Syntax.term) ->
        ((FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier
          FStar_Pervasives_Native.option) * FStar_Syntax_DsEnv.env))
  =
  fun env  ->
    fun imp  ->
      fun uu___12_18851  ->
        match uu___12_18851 with
        | (FStar_Pervasives_Native.None ,k) ->
            let uu____18873 = FStar_Syntax_Syntax.null_binder k  in
            (uu____18873, env)
        | (FStar_Pervasives_Native.Some a,k) ->
            let uu____18890 = FStar_Syntax_DsEnv.push_bv env a  in
            (match uu____18890 with
             | (env1,a1) ->
                 let uu____18907 =
                   let uu____18914 = trans_aqual env1 imp  in
                   ((let uu___2557_18920 = a1  in
                     {
                       FStar_Syntax_Syntax.ppname =
                         (uu___2557_18920.FStar_Syntax_Syntax.ppname);
                       FStar_Syntax_Syntax.index =
                         (uu___2557_18920.FStar_Syntax_Syntax.index);
                       FStar_Syntax_Syntax.sort = k
                     }), uu____18914)
                    in
                 (uu____18907, env1))

and (trans_aqual :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.arg_qualifier FStar_Pervasives_Native.option ->
      FStar_Syntax_Syntax.aqual)
  =
  fun env  ->
    fun uu___13_18928  ->
      match uu___13_18928 with
      | FStar_Pervasives_Native.Some (FStar_Parser_AST.Implicit ) ->
          FStar_Pervasives_Native.Some FStar_Syntax_Syntax.imp_tag
      | FStar_Pervasives_Native.Some (FStar_Parser_AST.Equality ) ->
          FStar_Pervasives_Native.Some FStar_Syntax_Syntax.Equality
      | FStar_Pervasives_Native.Some (FStar_Parser_AST.Meta t) ->
          let uu____18932 =
            let uu____18933 = desugar_term env t  in
            FStar_Syntax_Syntax.Meta uu____18933  in
          FStar_Pervasives_Native.Some uu____18932
      | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None

let (binder_ident :
  FStar_Parser_AST.binder -> FStar_Ident.ident FStar_Pervasives_Native.option)
  =
  fun b  ->
    match b.FStar_Parser_AST.b with
    | FStar_Parser_AST.TAnnotated (x,uu____18949) ->
        FStar_Pervasives_Native.Some x
    | FStar_Parser_AST.Annotated (x,uu____18951) ->
        FStar_Pervasives_Native.Some x
    | FStar_Parser_AST.TVariable x -> FStar_Pervasives_Native.Some x
    | FStar_Parser_AST.Variable x -> FStar_Pervasives_Native.Some x
    | FStar_Parser_AST.NoName uu____18954 -> FStar_Pervasives_Native.None
  
let (binder_idents :
  FStar_Parser_AST.binder Prims.list -> FStar_Ident.ident Prims.list) =
  fun bs  ->
    FStar_List.collect
      (fun b  ->
         let uu____18972 = binder_ident b  in
         FStar_Common.list_of_option uu____18972) bs
  
let (mk_data_discriminators :
  FStar_Syntax_Syntax.qualifier Prims.list ->
    FStar_Syntax_DsEnv.env ->
      FStar_Ident.lident Prims.list -> FStar_Syntax_Syntax.sigelt Prims.list)
  =
  fun quals  ->
    fun env  ->
      fun datas  ->
        let quals1 =
          FStar_All.pipe_right quals
            (FStar_List.filter
               (fun uu___14_19009  ->
                  match uu___14_19009 with
                  | FStar_Syntax_Syntax.NoExtract  -> true
                  | FStar_Syntax_Syntax.Abstract  -> true
                  | FStar_Syntax_Syntax.Private  -> true
                  | uu____19014 -> false))
           in
        let quals2 q =
          let uu____19028 =
            (let uu____19032 = FStar_Syntax_DsEnv.iface env  in
             Prims.op_Negation uu____19032) ||
              (FStar_Syntax_DsEnv.admitted_iface env)
             in
          if uu____19028
          then FStar_List.append (FStar_Syntax_Syntax.Assumption :: q) quals1
          else FStar_List.append q quals1  in
        FStar_All.pipe_right datas
          (FStar_List.map
             (fun d  ->
                let disc_name = FStar_Syntax_Util.mk_discriminator d  in
                let uu____19049 = FStar_Ident.range_of_lid disc_name  in
                let uu____19050 =
                  quals2
                    [FStar_Syntax_Syntax.OnlyName;
                    FStar_Syntax_Syntax.Discriminator d]
                   in
                {
                  FStar_Syntax_Syntax.sigel =
                    (FStar_Syntax_Syntax.Sig_declare_typ
                       (disc_name, [], FStar_Syntax_Syntax.tun));
                  FStar_Syntax_Syntax.sigrng = uu____19049;
                  FStar_Syntax_Syntax.sigquals = uu____19050;
                  FStar_Syntax_Syntax.sigmeta =
                    FStar_Syntax_Syntax.default_sigmeta;
                  FStar_Syntax_Syntax.sigattrs = []
                }))
  
let (mk_indexed_projector_names :
  FStar_Syntax_Syntax.qualifier Prims.list ->
    FStar_Syntax_Syntax.fv_qual ->
      FStar_Syntax_DsEnv.env ->
        FStar_Ident.lident ->
          FStar_Syntax_Syntax.binder Prims.list ->
            FStar_Syntax_Syntax.sigelt Prims.list)
  =
  fun iquals  ->
    fun fvq  ->
      fun env  ->
        fun lid  ->
          fun fields  ->
            let p = FStar_Ident.range_of_lid lid  in
            let uu____19090 =
              FStar_All.pipe_right fields
                (FStar_List.mapi
                   (fun i  ->
                      fun uu____19128  ->
                        match uu____19128 with
                        | (x,uu____19139) ->
                            let uu____19144 =
                              FStar_Syntax_Util.mk_field_projector_name lid x
                                i
                               in
                            (match uu____19144 with
                             | (field_name,uu____19152) ->
                                 let only_decl =
                                   ((let uu____19157 =
                                       FStar_Syntax_DsEnv.current_module env
                                        in
                                     FStar_Ident.lid_equals
                                       FStar_Parser_Const.prims_lid
                                       uu____19157)
                                      ||
                                      (fvq <> FStar_Syntax_Syntax.Data_ctor))
                                     ||
                                     (let uu____19159 =
                                        let uu____19161 =
                                          FStar_Syntax_DsEnv.current_module
                                            env
                                           in
                                        uu____19161.FStar_Ident.str  in
                                      FStar_Options.dont_gen_projectors
                                        uu____19159)
                                    in
                                 let no_decl =
                                   FStar_Syntax_Syntax.is_type
                                     x.FStar_Syntax_Syntax.sort
                                    in
                                 let quals q =
                                   if only_decl
                                   then
                                     let uu____19179 =
                                       FStar_List.filter
                                         (fun uu___15_19183  ->
                                            match uu___15_19183 with
                                            | FStar_Syntax_Syntax.Abstract 
                                                -> false
                                            | uu____19186 -> true) q
                                        in
                                     FStar_Syntax_Syntax.Assumption ::
                                       uu____19179
                                   else q  in
                                 let quals1 =
                                   let iquals1 =
                                     FStar_All.pipe_right iquals
                                       (FStar_List.filter
                                          (fun uu___16_19201  ->
                                             match uu___16_19201 with
                                             | FStar_Syntax_Syntax.NoExtract 
                                                 -> true
                                             | FStar_Syntax_Syntax.Abstract 
                                                 -> true
                                             | FStar_Syntax_Syntax.Private 
                                                 -> true
                                             | uu____19206 -> false))
                                      in
                                   quals (FStar_Syntax_Syntax.OnlyName ::
                                     (FStar_Syntax_Syntax.Projector
                                        (lid, (x.FStar_Syntax_Syntax.ppname)))
                                     :: iquals1)
                                    in
                                 let decl =
                                   let uu____19209 =
                                     FStar_Ident.range_of_lid field_name  in
                                   {
                                     FStar_Syntax_Syntax.sigel =
                                       (FStar_Syntax_Syntax.Sig_declare_typ
                                          (field_name, [],
                                            FStar_Syntax_Syntax.tun));
                                     FStar_Syntax_Syntax.sigrng = uu____19209;
                                     FStar_Syntax_Syntax.sigquals = quals1;
                                     FStar_Syntax_Syntax.sigmeta =
                                       FStar_Syntax_Syntax.default_sigmeta;
                                     FStar_Syntax_Syntax.sigattrs = []
                                   }  in
                                 if only_decl
                                 then [decl]
                                 else
                                   (let dd =
                                      let uu____19216 =
                                        FStar_All.pipe_right quals1
                                          (FStar_List.contains
                                             FStar_Syntax_Syntax.Abstract)
                                         in
                                      if uu____19216
                                      then
                                        FStar_Syntax_Syntax.Delta_abstract
                                          (FStar_Syntax_Syntax.Delta_equational_at_level
                                             Prims.int_one)
                                      else
                                        FStar_Syntax_Syntax.Delta_equational_at_level
                                          Prims.int_one
                                       in
                                    let lb =
                                      let uu____19227 =
                                        let uu____19232 =
                                          FStar_Syntax_Syntax.lid_as_fv
                                            field_name dd
                                            FStar_Pervasives_Native.None
                                           in
                                        FStar_Util.Inr uu____19232  in
                                      {
                                        FStar_Syntax_Syntax.lbname =
                                          uu____19227;
                                        FStar_Syntax_Syntax.lbunivs = [];
                                        FStar_Syntax_Syntax.lbtyp =
                                          FStar_Syntax_Syntax.tun;
                                        FStar_Syntax_Syntax.lbeff =
                                          FStar_Parser_Const.effect_Tot_lid;
                                        FStar_Syntax_Syntax.lbdef =
                                          FStar_Syntax_Syntax.tun;
                                        FStar_Syntax_Syntax.lbattrs = [];
                                        FStar_Syntax_Syntax.lbpos =
                                          FStar_Range.dummyRange
                                      }  in
                                    let impl =
                                      let uu____19236 =
                                        let uu____19237 =
                                          let uu____19244 =
                                            let uu____19247 =
                                              let uu____19248 =
                                                FStar_All.pipe_right
                                                  lb.FStar_Syntax_Syntax.lbname
                                                  FStar_Util.right
                                                 in
                                              FStar_All.pipe_right
                                                uu____19248
                                                (fun fv  ->
                                                   (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v)
                                               in
                                            [uu____19247]  in
                                          ((false, [lb]), uu____19244)  in
                                        FStar_Syntax_Syntax.Sig_let
                                          uu____19237
                                         in
                                      {
                                        FStar_Syntax_Syntax.sigel =
                                          uu____19236;
                                        FStar_Syntax_Syntax.sigrng = p;
                                        FStar_Syntax_Syntax.sigquals = quals1;
                                        FStar_Syntax_Syntax.sigmeta =
                                          FStar_Syntax_Syntax.default_sigmeta;
                                        FStar_Syntax_Syntax.sigattrs = []
                                      }  in
                                    if no_decl then [impl] else [decl; impl]))))
               in
            FStar_All.pipe_right uu____19090 FStar_List.flatten
  
let (mk_data_projector_names :
  FStar_Syntax_Syntax.qualifier Prims.list ->
    FStar_Syntax_DsEnv.env ->
      FStar_Syntax_Syntax.sigelt -> FStar_Syntax_Syntax.sigelt Prims.list)
  =
  fun iquals  ->
    fun env  ->
      fun se  ->
        match se.FStar_Syntax_Syntax.sigel with
        | FStar_Syntax_Syntax.Sig_datacon
            (lid,uu____19297,t,uu____19299,n1,uu____19301) when
            let uu____19308 =
              FStar_Ident.lid_equals lid FStar_Parser_Const.lexcons_lid  in
            Prims.op_Negation uu____19308 ->
            let uu____19310 = FStar_Syntax_Util.arrow_formals t  in
            (match uu____19310 with
             | (formals,uu____19328) ->
                 (match formals with
                  | [] -> []
                  | uu____19357 ->
                      let filter_records uu___17_19373 =
                        match uu___17_19373 with
                        | FStar_Syntax_Syntax.RecordConstructor
                            (uu____19376,fns) ->
                            FStar_Pervasives_Native.Some
                              (FStar_Syntax_Syntax.Record_ctor (lid, fns))
                        | uu____19388 -> FStar_Pervasives_Native.None  in
                      let fv_qual =
                        let uu____19390 =
                          FStar_Util.find_map se.FStar_Syntax_Syntax.sigquals
                            filter_records
                           in
                        match uu____19390 with
                        | FStar_Pervasives_Native.None  ->
                            FStar_Syntax_Syntax.Data_ctor
                        | FStar_Pervasives_Native.Some q -> q  in
                      let iquals1 =
                        if
                          (FStar_List.contains FStar_Syntax_Syntax.Abstract
                             iquals)
                            &&
                            (Prims.op_Negation
                               (FStar_List.contains
                                  FStar_Syntax_Syntax.Private iquals))
                        then FStar_Syntax_Syntax.Private :: iquals
                        else iquals  in
                      let uu____19402 = FStar_Util.first_N n1 formals  in
                      (match uu____19402 with
                       | (uu____19431,rest) ->
                           mk_indexed_projector_names iquals1 fv_qual env lid
                             rest)))
        | uu____19465 -> []
  
let (mk_typ_abbrev :
  FStar_Ident.lident ->
    FStar_Syntax_Syntax.univ_name Prims.list ->
      (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier
        FStar_Pervasives_Native.option) Prims.list ->
        FStar_Syntax_Syntax.typ FStar_Pervasives_Native.option ->
          FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
            FStar_Ident.lident Prims.list ->
              FStar_Syntax_Syntax.qualifier Prims.list ->
                FStar_Range.range -> FStar_Syntax_Syntax.sigelt)
  =
  fun lid  ->
    fun uvs  ->
      fun typars  ->
        fun kopt  ->
          fun t  ->
            fun lids  ->
              fun quals  ->
                fun rng  ->
                  let dd =
                    let uu____19544 =
                      FStar_All.pipe_right quals
                        (FStar_List.contains FStar_Syntax_Syntax.Abstract)
                       in
                    if uu____19544
                    then
                      let uu____19550 =
                        FStar_Syntax_Util.incr_delta_qualifier t  in
                      FStar_Syntax_Syntax.Delta_abstract uu____19550
                    else FStar_Syntax_Util.incr_delta_qualifier t  in
                  let lb =
                    let uu____19554 =
                      let uu____19559 =
                        FStar_Syntax_Syntax.lid_as_fv lid dd
                          FStar_Pervasives_Native.None
                         in
                      FStar_Util.Inr uu____19559  in
                    let uu____19560 =
                      if FStar_Util.is_some kopt
                      then
                        let uu____19566 =
                          let uu____19569 =
                            FStar_All.pipe_right kopt FStar_Util.must  in
                          FStar_Syntax_Syntax.mk_Total uu____19569  in
                        FStar_Syntax_Util.arrow typars uu____19566
                      else FStar_Syntax_Syntax.tun  in
                    let uu____19574 = no_annot_abs typars t  in
                    {
                      FStar_Syntax_Syntax.lbname = uu____19554;
                      FStar_Syntax_Syntax.lbunivs = uvs;
                      FStar_Syntax_Syntax.lbtyp = uu____19560;
                      FStar_Syntax_Syntax.lbeff =
                        FStar_Parser_Const.effect_Tot_lid;
                      FStar_Syntax_Syntax.lbdef = uu____19574;
                      FStar_Syntax_Syntax.lbattrs = [];
                      FStar_Syntax_Syntax.lbpos = rng
                    }  in
                  {
                    FStar_Syntax_Syntax.sigel =
                      (FStar_Syntax_Syntax.Sig_let ((false, [lb]), lids));
                    FStar_Syntax_Syntax.sigrng = rng;
                    FStar_Syntax_Syntax.sigquals = quals;
                    FStar_Syntax_Syntax.sigmeta =
                      FStar_Syntax_Syntax.default_sigmeta;
                    FStar_Syntax_Syntax.sigattrs = []
                  }
  
let rec (desugar_tycon :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.decl ->
      FStar_Syntax_Syntax.qualifier Prims.list ->
        FStar_Parser_AST.tycon Prims.list ->
          (env_t * FStar_Syntax_Syntax.sigelts))
  =
  fun env  ->
    fun d  ->
      fun quals  ->
        fun tcs  ->
          let rng = d.FStar_Parser_AST.drange  in
          let tycon_id uu___18_19628 =
            match uu___18_19628 with
            | FStar_Parser_AST.TyconAbstract (id1,uu____19630,uu____19631) ->
                id1
            | FStar_Parser_AST.TyconAbbrev
                (id1,uu____19641,uu____19642,uu____19643) -> id1
            | FStar_Parser_AST.TyconRecord
                (id1,uu____19653,uu____19654,uu____19655) -> id1
            | FStar_Parser_AST.TyconVariant
                (id1,uu____19685,uu____19686,uu____19687) -> id1
             in
          let binder_to_term b =
            match b.FStar_Parser_AST.b with
            | FStar_Parser_AST.Annotated (x,uu____19733) ->
                let uu____19734 =
                  let uu____19735 = FStar_Ident.lid_of_ids [x]  in
                  FStar_Parser_AST.Var uu____19735  in
                FStar_Parser_AST.mk_term uu____19734 x.FStar_Ident.idRange
                  FStar_Parser_AST.Expr
            | FStar_Parser_AST.Variable x ->
                let uu____19737 =
                  let uu____19738 = FStar_Ident.lid_of_ids [x]  in
                  FStar_Parser_AST.Var uu____19738  in
                FStar_Parser_AST.mk_term uu____19737 x.FStar_Ident.idRange
                  FStar_Parser_AST.Expr
            | FStar_Parser_AST.TAnnotated (a,uu____19740) ->
                FStar_Parser_AST.mk_term (FStar_Parser_AST.Tvar a)
                  a.FStar_Ident.idRange FStar_Parser_AST.Type_level
            | FStar_Parser_AST.TVariable a ->
                FStar_Parser_AST.mk_term (FStar_Parser_AST.Tvar a)
                  a.FStar_Ident.idRange FStar_Parser_AST.Type_level
            | FStar_Parser_AST.NoName t -> t  in
          let tot =
            FStar_Parser_AST.mk_term
              (FStar_Parser_AST.Name FStar_Parser_Const.effect_Tot_lid) rng
              FStar_Parser_AST.Expr
             in
          let with_constructor_effect t =
            FStar_Parser_AST.mk_term
              (FStar_Parser_AST.App (tot, t, FStar_Parser_AST.Nothing))
              t.FStar_Parser_AST.range t.FStar_Parser_AST.level
             in
          let apply_binders t binders =
            let imp_of_aqual b =
              match b.FStar_Parser_AST.aqual with
              | FStar_Pervasives_Native.Some (FStar_Parser_AST.Implicit ) ->
                  FStar_Parser_AST.Hash
              | uu____19771 -> FStar_Parser_AST.Nothing  in
            FStar_List.fold_left
              (fun out  ->
                 fun b  ->
                   let uu____19779 =
                     let uu____19780 =
                       let uu____19787 = binder_to_term b  in
                       (out, uu____19787, (imp_of_aqual b))  in
                     FStar_Parser_AST.App uu____19780  in
                   FStar_Parser_AST.mk_term uu____19779
                     out.FStar_Parser_AST.range out.FStar_Parser_AST.level) t
              binders
             in
          let tycon_record_as_variant uu___19_19799 =
            match uu___19_19799 with
            | FStar_Parser_AST.TyconRecord (id1,parms,kopt,fields) ->
                let constrName =
                  FStar_Ident.mk_ident
                    ((Prims.op_Hat "Mk" id1.FStar_Ident.idText),
                      (id1.FStar_Ident.idRange))
                   in
                let mfields =
                  FStar_List.map
                    (fun uu____19856  ->
                       match uu____19856 with
                       | (x,t,uu____19867) ->
                           FStar_Parser_AST.mk_binder
                             (FStar_Parser_AST.Annotated (x, t))
                             x.FStar_Ident.idRange FStar_Parser_AST.Expr
                             FStar_Pervasives_Native.None) fields
                   in
                let result =
                  let uu____19873 =
                    let uu____19874 =
                      let uu____19875 = FStar_Ident.lid_of_ids [id1]  in
                      FStar_Parser_AST.Var uu____19875  in
                    FStar_Parser_AST.mk_term uu____19874
                      id1.FStar_Ident.idRange FStar_Parser_AST.Type_level
                     in
                  apply_binders uu____19873 parms  in
                let constrTyp =
                  FStar_Parser_AST.mk_term
                    (FStar_Parser_AST.Product
                       (mfields, (with_constructor_effect result)))
                    id1.FStar_Ident.idRange FStar_Parser_AST.Type_level
                   in
                let names1 =
                  let uu____19882 = binder_idents parms  in id1 ::
                    uu____19882
                   in
                (FStar_List.iter
                   (fun uu____19900  ->
                      match uu____19900 with
                      | (f,uu____19910,uu____19911) ->
                          let uu____19916 =
                            FStar_Util.for_some
                              (fun i  -> FStar_Ident.ident_equals f i) names1
                             in
                          if uu____19916
                          then
                            let uu____19921 =
                              let uu____19927 =
                                let uu____19929 =
                                  FStar_Ident.string_of_ident f  in
                                FStar_Util.format1
                                  "Field %s shadows the record's name or a parameter of it, please rename it"
                                  uu____19929
                                 in
                              (FStar_Errors.Error_FieldShadow, uu____19927)
                               in
                            FStar_Errors.raise_error uu____19921
                              f.FStar_Ident.idRange
                          else ()) fields;
                 (let uu____19935 =
                    FStar_All.pipe_right fields
                      (FStar_List.map
                         (fun uu____19962  ->
                            match uu____19962 with
                            | (x,uu____19972,uu____19973) -> x))
                     in
                  ((FStar_Parser_AST.TyconVariant
                      (id1, parms, kopt,
                        [(constrName,
                           (FStar_Pervasives_Native.Some constrTyp),
                           FStar_Pervasives_Native.None, false)])),
                    uu____19935)))
            | uu____20031 -> failwith "impossible"  in
          let desugar_abstract_tc quals1 _env mutuals uu___20_20071 =
            match uu___20_20071 with
            | FStar_Parser_AST.TyconAbstract (id1,binders,kopt) ->
                let uu____20095 = typars_of_binders _env binders  in
                (match uu____20095 with
                 | (_env',typars) ->
                     let k =
                       match kopt with
                       | FStar_Pervasives_Native.None  ->
                           FStar_Syntax_Util.ktype
                       | FStar_Pervasives_Native.Some k ->
                           desugar_term _env' k
                        in
                     let tconstr =
                       let uu____20131 =
                         let uu____20132 =
                           let uu____20133 = FStar_Ident.lid_of_ids [id1]  in
                           FStar_Parser_AST.Var uu____20133  in
                         FStar_Parser_AST.mk_term uu____20132
                           id1.FStar_Ident.idRange
                           FStar_Parser_AST.Type_level
                          in
                       apply_binders uu____20131 binders  in
                     let qlid = FStar_Syntax_DsEnv.qualify _env id1  in
                     let typars1 = FStar_Syntax_Subst.close_binders typars
                        in
                     let k1 = FStar_Syntax_Subst.close typars1 k  in
                     let se =
                       {
                         FStar_Syntax_Syntax.sigel =
                           (FStar_Syntax_Syntax.Sig_inductive_typ
                              (qlid, [], typars1, k1, mutuals, []));
                         FStar_Syntax_Syntax.sigrng = rng;
                         FStar_Syntax_Syntax.sigquals = quals1;
                         FStar_Syntax_Syntax.sigmeta =
                           FStar_Syntax_Syntax.default_sigmeta;
                         FStar_Syntax_Syntax.sigattrs = []
                       }  in
                     let _env1 =
                       FStar_Syntax_DsEnv.push_top_level_rec_binding _env id1
                         FStar_Syntax_Syntax.delta_constant
                        in
                     let _env2 =
                       FStar_Syntax_DsEnv.push_top_level_rec_binding _env'
                         id1 FStar_Syntax_Syntax.delta_constant
                        in
                     (_env1, _env2, se, tconstr))
            | uu____20144 -> failwith "Unexpected tycon"  in
          let push_tparams env1 bs =
            let uu____20187 =
              FStar_List.fold_left
                (fun uu____20221  ->
                   fun uu____20222  ->
                     match (uu____20221, uu____20222) with
                     | ((env2,tps),(x,imp)) ->
                         let uu____20291 =
                           FStar_Syntax_DsEnv.push_bv env2
                             x.FStar_Syntax_Syntax.ppname
                            in
                         (match uu____20291 with
                          | (env3,y) -> (env3, ((y, imp) :: tps))))
                (env1, []) bs
               in
            match uu____20187 with
            | (env2,bs1) -> (env2, (FStar_List.rev bs1))  in
          match tcs with
          | (FStar_Parser_AST.TyconAbstract (id1,bs,kopt))::[] ->
              let kopt1 =
                match kopt with
                | FStar_Pervasives_Native.None  ->
                    let uu____20382 = tm_type_z id1.FStar_Ident.idRange  in
                    FStar_Pervasives_Native.Some uu____20382
                | uu____20383 -> kopt  in
              let tc = FStar_Parser_AST.TyconAbstract (id1, bs, kopt1)  in
              let uu____20391 = desugar_abstract_tc quals env [] tc  in
              (match uu____20391 with
               | (uu____20404,uu____20405,se,uu____20407) ->
                   let se1 =
                     match se.FStar_Syntax_Syntax.sigel with
                     | FStar_Syntax_Syntax.Sig_inductive_typ
                         (l,uu____20410,typars,k,[],[]) ->
                         let quals1 = se.FStar_Syntax_Syntax.sigquals  in
                         let quals2 =
                           if
                             FStar_List.contains
                               FStar_Syntax_Syntax.Assumption quals1
                           then quals1
                           else
                             ((let uu____20429 =
                                 let uu____20431 = FStar_Options.ml_ish ()
                                    in
                                 Prims.op_Negation uu____20431  in
                               if uu____20429
                               then
                                 let uu____20434 =
                                   let uu____20440 =
                                     let uu____20442 =
                                       FStar_Syntax_Print.lid_to_string l  in
                                     FStar_Util.format1
                                       "Adding an implicit 'assume new' qualifier on %s"
                                       uu____20442
                                      in
                                   (FStar_Errors.Warning_AddImplicitAssumeNewQualifier,
                                     uu____20440)
                                    in
                                 FStar_Errors.log_issue
                                   se.FStar_Syntax_Syntax.sigrng uu____20434
                               else ());
                              FStar_Syntax_Syntax.Assumption
                              ::
                              FStar_Syntax_Syntax.New
                              ::
                              quals1)
                            in
                         let t =
                           match typars with
                           | [] -> k
                           | uu____20455 ->
                               let uu____20456 =
                                 let uu____20463 =
                                   let uu____20464 =
                                     let uu____20479 =
                                       FStar_Syntax_Syntax.mk_Total k  in
                                     (typars, uu____20479)  in
                                   FStar_Syntax_Syntax.Tm_arrow uu____20464
                                    in
                                 FStar_Syntax_Syntax.mk uu____20463  in
                               uu____20456 FStar_Pervasives_Native.None
                                 se.FStar_Syntax_Syntax.sigrng
                            in
                         let uu___2832_20492 = se  in
                         {
                           FStar_Syntax_Syntax.sigel =
                             (FStar_Syntax_Syntax.Sig_declare_typ (l, [], t));
                           FStar_Syntax_Syntax.sigrng =
                             (uu___2832_20492.FStar_Syntax_Syntax.sigrng);
                           FStar_Syntax_Syntax.sigquals = quals2;
                           FStar_Syntax_Syntax.sigmeta =
                             (uu___2832_20492.FStar_Syntax_Syntax.sigmeta);
                           FStar_Syntax_Syntax.sigattrs =
                             (uu___2832_20492.FStar_Syntax_Syntax.sigattrs)
                         }
                     | uu____20493 -> failwith "Impossible"  in
                   let env1 = FStar_Syntax_DsEnv.push_sigelt env se1  in
                   let env2 =
                     let uu____20497 = FStar_Syntax_DsEnv.qualify env1 id1
                        in
                     FStar_Syntax_DsEnv.push_doc env1 uu____20497
                       d.FStar_Parser_AST.doc
                      in
                   (env2, [se1]))
          | (FStar_Parser_AST.TyconAbbrev (id1,binders,kopt,t))::[] ->
              let uu____20510 = typars_of_binders env binders  in
              (match uu____20510 with
               | (env',typars) ->
                   let kopt1 =
                     match kopt with
                     | FStar_Pervasives_Native.None  ->
                         let uu____20544 =
                           FStar_Util.for_some
                             (fun uu___21_20547  ->
                                match uu___21_20547 with
                                | FStar_Syntax_Syntax.Effect  -> true
                                | uu____20550 -> false) quals
                            in
                         if uu____20544
                         then
                           FStar_Pervasives_Native.Some
                             FStar_Syntax_Syntax.teff
                         else FStar_Pervasives_Native.None
                     | FStar_Pervasives_Native.Some k ->
                         let uu____20558 = desugar_term env' k  in
                         FStar_Pervasives_Native.Some uu____20558
                      in
                   let t0 = t  in
                   let quals1 =
                     let uu____20563 =
                       FStar_All.pipe_right quals
                         (FStar_Util.for_some
                            (fun uu___22_20569  ->
                               match uu___22_20569 with
                               | FStar_Syntax_Syntax.Logic  -> true
                               | uu____20572 -> false))
                        in
                     if uu____20563
                     then quals
                     else
                       if
                         t0.FStar_Parser_AST.level = FStar_Parser_AST.Formula
                       then FStar_Syntax_Syntax.Logic :: quals
                       else quals
                      in
                   let qlid = FStar_Syntax_DsEnv.qualify env id1  in
                   let se =
                     let uu____20586 =
                       FStar_All.pipe_right quals1
                         (FStar_List.contains FStar_Syntax_Syntax.Effect)
                        in
                     if uu____20586
                     then
                       let uu____20592 =
                         let uu____20599 =
                           let uu____20600 = unparen t  in
                           uu____20600.FStar_Parser_AST.tm  in
                         match uu____20599 with
                         | FStar_Parser_AST.Construct (head1,args) ->
                             let uu____20621 =
                               match FStar_List.rev args with
                               | (last_arg,uu____20651)::args_rev ->
                                   let uu____20663 =
                                     let uu____20664 = unparen last_arg  in
                                     uu____20664.FStar_Parser_AST.tm  in
                                   (match uu____20663 with
                                    | FStar_Parser_AST.Attributes ts ->
                                        (ts, (FStar_List.rev args_rev))
                                    | uu____20692 -> ([], args))
                               | uu____20701 -> ([], args)  in
                             (match uu____20621 with
                              | (cattributes,args1) ->
                                  let uu____20740 =
                                    desugar_attributes env cattributes  in
                                  ((FStar_Parser_AST.mk_term
                                      (FStar_Parser_AST.Construct
                                         (head1, args1))
                                      t.FStar_Parser_AST.range
                                      t.FStar_Parser_AST.level), uu____20740))
                         | uu____20751 -> (t, [])  in
                       match uu____20592 with
                       | (t1,cattributes) ->
                           let c =
                             desugar_comp t1.FStar_Parser_AST.range false
                               env' t1
                              in
                           let typars1 =
                             FStar_Syntax_Subst.close_binders typars  in
                           let c1 = FStar_Syntax_Subst.close_comp typars1 c
                              in
                           let quals2 =
                             FStar_All.pipe_right quals1
                               (FStar_List.filter
                                  (fun uu___23_20774  ->
                                     match uu___23_20774 with
                                     | FStar_Syntax_Syntax.Effect  -> false
                                     | uu____20777 -> true))
                              in
                           {
                             FStar_Syntax_Syntax.sigel =
                               (FStar_Syntax_Syntax.Sig_effect_abbrev
                                  (qlid, [], typars1, c1,
                                    (FStar_List.append cattributes
                                       (FStar_Syntax_Util.comp_flags c1))));
                             FStar_Syntax_Syntax.sigrng = rng;
                             FStar_Syntax_Syntax.sigquals = quals2;
                             FStar_Syntax_Syntax.sigmeta =
                               FStar_Syntax_Syntax.default_sigmeta;
                             FStar_Syntax_Syntax.sigattrs = []
                           }
                     else
                       (let t1 = desugar_typ env' t  in
                        mk_typ_abbrev qlid [] typars kopt1 t1 [qlid] quals1
                          rng)
                      in
                   let env1 = FStar_Syntax_DsEnv.push_sigelt env se  in
                   let env2 =
                     FStar_Syntax_DsEnv.push_doc env1 qlid
                       d.FStar_Parser_AST.doc
                      in
                   (env2, [se]))
          | (FStar_Parser_AST.TyconRecord uu____20786)::[] ->
              let trec = FStar_List.hd tcs  in
              let uu____20810 = tycon_record_as_variant trec  in
              (match uu____20810 with
               | (t,fs) ->
                   let uu____20827 =
                     let uu____20830 =
                       let uu____20831 =
                         let uu____20840 =
                           let uu____20843 =
                             FStar_Syntax_DsEnv.current_module env  in
                           FStar_Ident.ids_of_lid uu____20843  in
                         (uu____20840, fs)  in
                       FStar_Syntax_Syntax.RecordType uu____20831  in
                     uu____20830 :: quals  in
                   desugar_tycon env d uu____20827 [t])
          | uu____20848::uu____20849 ->
              let env0 = env  in
              let mutuals =
                FStar_List.map
                  (fun x  ->
                     FStar_All.pipe_left (FStar_Syntax_DsEnv.qualify env)
                       (tycon_id x)) tcs
                 in
              let rec collect_tcs quals1 et tc =
                let uu____21019 = et  in
                match uu____21019 with
                | (env1,tcs1) ->
                    (match tc with
                     | FStar_Parser_AST.TyconRecord uu____21249 ->
                         let trec = tc  in
                         let uu____21273 = tycon_record_as_variant trec  in
                         (match uu____21273 with
                          | (t,fs) ->
                              let uu____21333 =
                                let uu____21336 =
                                  let uu____21337 =
                                    let uu____21346 =
                                      let uu____21349 =
                                        FStar_Syntax_DsEnv.current_module
                                          env1
                                         in
                                      FStar_Ident.ids_of_lid uu____21349  in
                                    (uu____21346, fs)  in
                                  FStar_Syntax_Syntax.RecordType uu____21337
                                   in
                                uu____21336 :: quals1  in
                              collect_tcs uu____21333 (env1, tcs1) t)
                     | FStar_Parser_AST.TyconVariant
                         (id1,binders,kopt,constructors) ->
                         let uu____21439 =
                           desugar_abstract_tc quals1 env1 mutuals
                             (FStar_Parser_AST.TyconAbstract
                                (id1, binders, kopt))
                            in
                         (match uu____21439 with
                          | (env2,uu____21500,se,tconstr) ->
                              (env2,
                                ((FStar_Util.Inl
                                    (se, constructors, tconstr, quals1)) ::
                                tcs1)))
                     | FStar_Parser_AST.TyconAbbrev (id1,binders,kopt,t) ->
                         let uu____21653 =
                           desugar_abstract_tc quals1 env1 mutuals
                             (FStar_Parser_AST.TyconAbstract
                                (id1, binders, kopt))
                            in
                         (match uu____21653 with
                          | (env2,uu____21714,se,tconstr) ->
                              (env2,
                                ((FStar_Util.Inr (se, binders, t, quals1)) ::
                                tcs1)))
                     | uu____21842 ->
                         FStar_Errors.raise_error
                           (FStar_Errors.Fatal_NonInductiveInMutuallyDefinedType,
                             "Mutually defined type contains a non-inductive element")
                           rng)
                 in
              let uu____21892 =
                FStar_List.fold_left (collect_tcs quals) (env, []) tcs  in
              (match uu____21892 with
               | (env1,tcs1) ->
                   let tcs2 = FStar_List.rev tcs1  in
                   let docs_tps_sigelts =
                     FStar_All.pipe_right tcs2
                       (FStar_List.collect
                          (fun uu___25_22407  ->
                             match uu___25_22407 with
                             | FStar_Util.Inr
                                 ({
                                    FStar_Syntax_Syntax.sigel =
                                      FStar_Syntax_Syntax.Sig_inductive_typ
                                      (id1,uvs,tpars,k,uu____22473,uu____22474);
                                    FStar_Syntax_Syntax.sigrng = uu____22475;
                                    FStar_Syntax_Syntax.sigquals =
                                      uu____22476;
                                    FStar_Syntax_Syntax.sigmeta = uu____22477;
                                    FStar_Syntax_Syntax.sigattrs =
                                      uu____22478;_},binders,t,quals1)
                                 ->
                                 let t1 =
                                   let uu____22542 =
                                     typars_of_binders env1 binders  in
                                   match uu____22542 with
                                   | (env2,tpars1) ->
                                       let uu____22569 =
                                         push_tparams env2 tpars1  in
                                       (match uu____22569 with
                                        | (env_tps,tpars2) ->
                                            let t1 = desugar_typ env_tps t
                                               in
                                            let tpars3 =
                                              FStar_Syntax_Subst.close_binders
                                                tpars2
                                               in
                                            FStar_Syntax_Subst.close tpars3
                                              t1)
                                    in
                                 let uu____22598 =
                                   let uu____22617 =
                                     mk_typ_abbrev id1 uvs tpars
                                       (FStar_Pervasives_Native.Some k) t1
                                       [id1] quals1 rng
                                      in
                                   ((id1, (d.FStar_Parser_AST.doc)), [],
                                     uu____22617)
                                    in
                                 [uu____22598]
                             | FStar_Util.Inl
                                 ({
                                    FStar_Syntax_Syntax.sigel =
                                      FStar_Syntax_Syntax.Sig_inductive_typ
                                      (tname,univs1,tpars,k,mutuals1,uu____22677);
                                    FStar_Syntax_Syntax.sigrng = uu____22678;
                                    FStar_Syntax_Syntax.sigquals =
                                      tname_quals;
                                    FStar_Syntax_Syntax.sigmeta = uu____22680;
                                    FStar_Syntax_Syntax.sigattrs =
                                      uu____22681;_},constrs,tconstr,quals1)
                                 ->
                                 let mk_tot t =
                                   let tot1 =
                                     FStar_Parser_AST.mk_term
                                       (FStar_Parser_AST.Name
                                          FStar_Parser_Const.effect_Tot_lid)
                                       t.FStar_Parser_AST.range
                                       t.FStar_Parser_AST.level
                                      in
                                   FStar_Parser_AST.mk_term
                                     (FStar_Parser_AST.App
                                        (tot1, t, FStar_Parser_AST.Nothing))
                                     t.FStar_Parser_AST.range
                                     t.FStar_Parser_AST.level
                                    in
                                 let tycon = (tname, tpars, k)  in
                                 let uu____22782 = push_tparams env1 tpars
                                    in
                                 (match uu____22782 with
                                  | (env_tps,tps) ->
                                      let data_tpars =
                                        FStar_List.map
                                          (fun uu____22849  ->
                                             match uu____22849 with
                                             | (x,uu____22861) ->
                                                 (x,
                                                   (FStar_Pervasives_Native.Some
                                                      (FStar_Syntax_Syntax.Implicit
                                                         true)))) tps
                                         in
                                      let tot_tconstr = mk_tot tconstr  in
                                      let uu____22866 =
                                        let uu____22893 =
                                          FStar_All.pipe_right constrs
                                            (FStar_List.map
                                               (fun uu____23003  ->
                                                  match uu____23003 with
                                                  | (id1,topt,doc1,of_notation)
                                                      ->
                                                      let t =
                                                        if of_notation
                                                        then
                                                          match topt with
                                                          | FStar_Pervasives_Native.Some
                                                              t ->
                                                              FStar_Parser_AST.mk_term
                                                                (FStar_Parser_AST.Product
                                                                   ([
                                                                    FStar_Parser_AST.mk_binder
                                                                    (FStar_Parser_AST.NoName
                                                                    t)
                                                                    t.FStar_Parser_AST.range
                                                                    t.FStar_Parser_AST.level
                                                                    FStar_Pervasives_Native.None],
                                                                    tot_tconstr))
                                                                t.FStar_Parser_AST.range
                                                                t.FStar_Parser_AST.level
                                                          | FStar_Pervasives_Native.None
                                                               -> tconstr
                                                        else
                                                          (match topt with
                                                           | FStar_Pervasives_Native.None
                                                                ->
                                                               failwith
                                                                 "Impossible"
                                                           | FStar_Pervasives_Native.Some
                                                               t -> t)
                                                         in
                                                      let t1 =
                                                        let uu____23063 =
                                                          close env_tps t  in
                                                        desugar_term env_tps
                                                          uu____23063
                                                         in
                                                      let name =
                                                        FStar_Syntax_DsEnv.qualify
                                                          env1 id1
                                                         in
                                                      let quals2 =
                                                        FStar_All.pipe_right
                                                          tname_quals
                                                          (FStar_List.collect
                                                             (fun
                                                                uu___24_23074
                                                                 ->
                                                                match uu___24_23074
                                                                with
                                                                | FStar_Syntax_Syntax.RecordType
                                                                    fns ->
                                                                    [
                                                                    FStar_Syntax_Syntax.RecordConstructor
                                                                    fns]
                                                                | uu____23086
                                                                    -> []))
                                                         in
                                                      let ntps =
                                                        FStar_List.length
                                                          data_tpars
                                                         in
                                                      let uu____23094 =
                                                        let uu____23113 =
                                                          let uu____23114 =
                                                            let uu____23115 =
                                                              let uu____23131
                                                                =
                                                                let uu____23132
                                                                  =
                                                                  let uu____23135
                                                                    =
                                                                    FStar_All.pipe_right
                                                                    t1
                                                                    FStar_Syntax_Util.name_function_binders
                                                                     in
                                                                  FStar_Syntax_Syntax.mk_Total
                                                                    uu____23135
                                                                   in
                                                                FStar_Syntax_Util.arrow
                                                                  data_tpars
                                                                  uu____23132
                                                                 in
                                                              (name, univs1,
                                                                uu____23131,
                                                                tname, ntps,
                                                                mutuals1)
                                                               in
                                                            FStar_Syntax_Syntax.Sig_datacon
                                                              uu____23115
                                                             in
                                                          {
                                                            FStar_Syntax_Syntax.sigel
                                                              = uu____23114;
                                                            FStar_Syntax_Syntax.sigrng
                                                              = rng;
                                                            FStar_Syntax_Syntax.sigquals
                                                              = quals2;
                                                            FStar_Syntax_Syntax.sigmeta
                                                              =
                                                              FStar_Syntax_Syntax.default_sigmeta;
                                                            FStar_Syntax_Syntax.sigattrs
                                                              = []
                                                          }  in
                                                        ((name, doc1), tps,
                                                          uu____23113)
                                                         in
                                                      (name, uu____23094)))
                                           in
                                        FStar_All.pipe_left FStar_List.split
                                          uu____22893
                                         in
                                      (match uu____22866 with
                                       | (constrNames,constrs1) ->
                                           ((tname, (d.FStar_Parser_AST.doc)),
                                             [],
                                             {
                                               FStar_Syntax_Syntax.sigel =
                                                 (FStar_Syntax_Syntax.Sig_inductive_typ
                                                    (tname, univs1, tpars, k,
                                                      mutuals1, constrNames));
                                               FStar_Syntax_Syntax.sigrng =
                                                 rng;
                                               FStar_Syntax_Syntax.sigquals =
                                                 tname_quals;
                                               FStar_Syntax_Syntax.sigmeta =
                                                 FStar_Syntax_Syntax.default_sigmeta;
                                               FStar_Syntax_Syntax.sigattrs =
                                                 []
                                             })
                                           :: constrs1))
                             | uu____23347 -> failwith "impossible"))
                      in
                   let name_docs =
                     FStar_All.pipe_right docs_tps_sigelts
                       (FStar_List.map
                          (fun uu____23475  ->
                             match uu____23475 with
                             | (name_doc,uu____23501,uu____23502) -> name_doc))
                      in
                   let sigelts =
                     FStar_All.pipe_right docs_tps_sigelts
                       (FStar_List.map
                          (fun uu____23574  ->
                             match uu____23574 with
                             | (uu____23593,uu____23594,se) -> se))
                      in
                   let uu____23620 =
                     let uu____23627 =
                       FStar_List.collect FStar_Syntax_Util.lids_of_sigelt
                         sigelts
                        in
                     FStar_Syntax_MutRecTy.disentangle_abbrevs_from_bundle
                       sigelts quals uu____23627 rng
                      in
                   (match uu____23620 with
                    | (bundle,abbrevs) ->
                        let env2 = FStar_Syntax_DsEnv.push_sigelt env0 bundle
                           in
                        let env3 =
                          FStar_List.fold_left FStar_Syntax_DsEnv.push_sigelt
                            env2 abbrevs
                           in
                        let data_ops =
                          FStar_All.pipe_right docs_tps_sigelts
                            (FStar_List.collect
                               (fun uu____23689  ->
                                  match uu____23689 with
                                  | (uu____23710,tps,se) ->
                                      mk_data_projector_names quals env3 se))
                           in
                        let discs =
                          FStar_All.pipe_right sigelts
                            (FStar_List.collect
                               (fun se  ->
                                  match se.FStar_Syntax_Syntax.sigel with
                                  | FStar_Syntax_Syntax.Sig_inductive_typ
                                      (tname,uu____23758,tps,k,uu____23761,constrs)
                                      ->
                                      let quals1 =
                                        se.FStar_Syntax_Syntax.sigquals  in
                                      let quals2 =
                                        if
                                          (FStar_List.contains
                                             FStar_Syntax_Syntax.Abstract
                                             quals1)
                                            &&
                                            (Prims.op_Negation
                                               (FStar_List.contains
                                                  FStar_Syntax_Syntax.Private
                                                  quals1))
                                        then FStar_Syntax_Syntax.Private ::
                                          quals1
                                        else quals1  in
                                      let uu____23782 =
                                        FStar_All.pipe_right constrs
                                          (FStar_List.filter
                                             (fun data_lid  ->
                                                let data_quals =
                                                  let data_se =
                                                    let uu____23797 =
                                                      FStar_All.pipe_right
                                                        sigelts
                                                        (FStar_List.find
                                                           (fun se1  ->
                                                              match se1.FStar_Syntax_Syntax.sigel
                                                              with
                                                              | FStar_Syntax_Syntax.Sig_datacon
                                                                  (name,uu____23814,uu____23815,uu____23816,uu____23817,uu____23818)
                                                                  ->
                                                                  FStar_Ident.lid_equals
                                                                    name
                                                                    data_lid
                                                              | uu____23825
                                                                  -> false))
                                                       in
                                                    FStar_All.pipe_right
                                                      uu____23797
                                                      FStar_Util.must
                                                     in
                                                  data_se.FStar_Syntax_Syntax.sigquals
                                                   in
                                                let uu____23829 =
                                                  FStar_All.pipe_right
                                                    data_quals
                                                    (FStar_List.existsb
                                                       (fun uu___26_23836  ->
                                                          match uu___26_23836
                                                          with
                                                          | FStar_Syntax_Syntax.RecordConstructor
                                                              uu____23838 ->
                                                              true
                                                          | uu____23848 ->
                                                              false))
                                                   in
                                                Prims.op_Negation uu____23829))
                                         in
                                      mk_data_discriminators quals2 env3
                                        uu____23782
                                  | uu____23850 -> []))
                           in
                        let ops = FStar_List.append discs data_ops  in
                        let env4 =
                          FStar_List.fold_left FStar_Syntax_DsEnv.push_sigelt
                            env3 ops
                           in
                        let env5 =
                          FStar_List.fold_left
                            (fun acc  ->
                               fun uu____23867  ->
                                 match uu____23867 with
                                 | (lid,doc1) ->
                                     FStar_Syntax_DsEnv.push_doc env4 lid
                                       doc1) env4 name_docs
                           in
                        (env5,
                          (FStar_List.append [bundle]
                             (FStar_List.append abbrevs ops)))))
          | [] -> failwith "impossible"
  
let (desugar_binders :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.binder Prims.list ->
      (FStar_Syntax_DsEnv.env * (FStar_Syntax_Syntax.bv *
        FStar_Syntax_Syntax.arg_qualifier FStar_Pervasives_Native.option)
        Prims.list))
  =
  fun env  ->
    fun binders  ->
      let uu____23912 =
        FStar_List.fold_left
          (fun uu____23947  ->
             fun b  ->
               match uu____23947 with
               | (env1,binders1) ->
                   let uu____23991 = desugar_binder env1 b  in
                   (match uu____23991 with
                    | (FStar_Pervasives_Native.Some a,k) ->
                        let uu____24014 =
                          as_binder env1 b.FStar_Parser_AST.aqual
                            ((FStar_Pervasives_Native.Some a), k)
                           in
                        (match uu____24014 with
                         | (binder,env2) -> (env2, (binder :: binders1)))
                    | uu____24067 ->
                        FStar_Errors.raise_error
                          (FStar_Errors.Fatal_MissingNameInBinder,
                            "Missing name in binder")
                          b.FStar_Parser_AST.brange)) (env, []) binders
         in
      match uu____23912 with
      | (env1,binders1) -> (env1, (FStar_List.rev binders1))
  
let (push_reflect_effect :
  FStar_Syntax_DsEnv.env ->
    FStar_Syntax_Syntax.qualifier Prims.list ->
      FStar_Ident.lid -> FStar_Range.range -> FStar_Syntax_DsEnv.env)
  =
  fun env  ->
    fun quals  ->
      fun effect_name  ->
        fun range  ->
          let uu____24171 =
            FStar_All.pipe_right quals
              (FStar_Util.for_some
                 (fun uu___27_24178  ->
                    match uu___27_24178 with
                    | FStar_Syntax_Syntax.Reflectable uu____24180 -> true
                    | uu____24182 -> false))
             in
          if uu____24171
          then
            let monad_env =
              FStar_Syntax_DsEnv.enter_monad_scope env
                effect_name.FStar_Ident.ident
               in
            let reflect_lid =
              let uu____24187 = FStar_Ident.id_of_text "reflect"  in
              FStar_All.pipe_right uu____24187
                (FStar_Syntax_DsEnv.qualify monad_env)
               in
            let quals1 =
              [FStar_Syntax_Syntax.Assumption;
              FStar_Syntax_Syntax.Reflectable effect_name]  in
            let refl_decl =
              {
                FStar_Syntax_Syntax.sigel =
                  (FStar_Syntax_Syntax.Sig_declare_typ
                     (reflect_lid, [], FStar_Syntax_Syntax.tun));
                FStar_Syntax_Syntax.sigrng = range;
                FStar_Syntax_Syntax.sigquals = quals1;
                FStar_Syntax_Syntax.sigmeta =
                  FStar_Syntax_Syntax.default_sigmeta;
                FStar_Syntax_Syntax.sigattrs = []
              }  in
            FStar_Syntax_DsEnv.push_sigelt env refl_decl
          else env
  
let (parse_attr_with_list :
  Prims.bool ->
    FStar_Syntax_Syntax.term ->
      FStar_Ident.lident ->
        (Prims.int Prims.list FStar_Pervasives_Native.option * Prims.bool))
  =
  fun warn  ->
    fun at1  ->
      fun head1  ->
        let warn1 uu____24238 =
          if warn
          then
            let uu____24240 =
              let uu____24246 =
                let uu____24248 = FStar_Ident.string_of_lid head1  in
                FStar_Util.format1
                  "Found ill-applied '%s', argument should be a non-empty list of integer literals"
                  uu____24248
                 in
              (FStar_Errors.Warning_UnappliedFail, uu____24246)  in
            FStar_Errors.log_issue at1.FStar_Syntax_Syntax.pos uu____24240
          else ()  in
        let uu____24254 = FStar_Syntax_Util.head_and_args at1  in
        match uu____24254 with
        | (hd1,args) ->
            let uu____24307 =
              let uu____24308 = FStar_Syntax_Subst.compress hd1  in
              uu____24308.FStar_Syntax_Syntax.n  in
            (match uu____24307 with
             | FStar_Syntax_Syntax.Tm_fvar fv when
                 FStar_Syntax_Syntax.fv_eq_lid fv head1 ->
                 (match args with
                  | [] -> ((FStar_Pervasives_Native.Some []), true)
                  | (a1,uu____24352)::[] ->
                      let uu____24377 =
                        let uu____24382 =
                          let uu____24391 =
                            FStar_Syntax_Embeddings.e_list
                              FStar_Syntax_Embeddings.e_int
                             in
                          FStar_Syntax_Embeddings.unembed uu____24391 a1  in
                        uu____24382 true FStar_Syntax_Embeddings.id_norm_cb
                         in
                      (match uu____24377 with
                       | FStar_Pervasives_Native.Some es ->
                           let uu____24414 =
                             let uu____24420 =
                               FStar_List.map FStar_BigInt.to_int_fs es  in
                             FStar_Pervasives_Native.Some uu____24420  in
                           (uu____24414, true)
                       | uu____24435 ->
                           (warn1 (); (FStar_Pervasives_Native.None, true)))
                  | uu____24451 ->
                      (warn1 (); (FStar_Pervasives_Native.None, true)))
             | uu____24473 -> (FStar_Pervasives_Native.None, false))
  
let (get_fail_attr :
  Prims.bool ->
    FStar_Syntax_Syntax.term ->
      (Prims.int Prims.list * Prims.bool) FStar_Pervasives_Native.option)
  =
  fun warn  ->
    fun at1  ->
      let rebind res b =
        match res with
        | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
        | FStar_Pervasives_Native.Some l ->
            FStar_Pervasives_Native.Some (l, b)
         in
      let uu____24590 =
        parse_attr_with_list warn at1 FStar_Parser_Const.fail_attr  in
      match uu____24590 with
      | (res,matched) ->
          if matched
          then rebind res false
          else
            (let uu____24639 =
               parse_attr_with_list warn at1 FStar_Parser_Const.fail_lax_attr
                in
             match uu____24639 with | (res1,uu____24661) -> rebind res1 true)
  
let rec (desugar_effect :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.decl ->
      FStar_Parser_AST.qualifiers ->
        FStar_Ident.ident ->
          FStar_Parser_AST.binder Prims.list ->
            FStar_Parser_AST.term ->
              FStar_Parser_AST.decl Prims.list ->
                FStar_Parser_AST.term Prims.list ->
                  (FStar_Syntax_DsEnv.env * FStar_Syntax_Syntax.sigelt
                    Prims.list))
  =
  fun env  ->
    fun d  ->
      fun quals  ->
        fun eff_name  ->
          fun eff_binders  ->
            fun eff_typ  ->
              fun eff_decls  ->
                fun attrs  ->
                  let env0 = env  in
                  let monad_env =
                    FStar_Syntax_DsEnv.enter_monad_scope env eff_name  in
                  let uu____24826 = desugar_binders monad_env eff_binders  in
                  match uu____24826 with
                  | (env1,binders) ->
                      let eff_t = desugar_term env1 eff_typ  in
                      let for_free =
                        let uu____24866 =
                          let uu____24868 =
                            let uu____24877 =
                              FStar_Syntax_Util.arrow_formals eff_t  in
                            FStar_Pervasives_Native.fst uu____24877  in
                          FStar_List.length uu____24868  in
                        uu____24866 = Prims.int_one  in
                      let mandatory_members =
                        let rr_members = ["repr"; "return"; "bind"]  in
                        if for_free
                        then rr_members
                        else
                          FStar_List.append rr_members
                            ["return_wp";
                            "bind_wp";
                            "if_then_else";
                            "ite_wp";
                            "stronger";
                            "close_wp";
                            "trivial"]
                         in
                      let name_of_eff_decl decl =
                        match decl.FStar_Parser_AST.d with
                        | FStar_Parser_AST.Tycon
                            (uu____24955,uu____24956,(FStar_Parser_AST.TyconAbbrev
                                                      (name,uu____24958,uu____24959,uu____24960),uu____24961)::[])
                            -> FStar_Ident.text_of_id name
                        | uu____24998 ->
                            failwith "Malformed effect member declaration."
                         in
                      let uu____25001 =
                        FStar_List.partition
                          (fun decl  ->
                             let uu____25013 = name_of_eff_decl decl  in
                             FStar_List.mem uu____25013 mandatory_members)
                          eff_decls
                         in
                      (match uu____25001 with
                       | (mandatory_members_decls,actions) ->
                           let uu____25032 =
                             FStar_All.pipe_right mandatory_members_decls
                               (FStar_List.fold_left
                                  (fun uu____25061  ->
                                     fun decl  ->
                                       match uu____25061 with
                                       | (env2,out) ->
                                           let uu____25081 =
                                             desugar_decl env2 decl  in
                                           (match uu____25081 with
                                            | (env3,ses) ->
                                                let uu____25094 =
                                                  let uu____25097 =
                                                    FStar_List.hd ses  in
                                                  uu____25097 :: out  in
                                                (env3, uu____25094)))
                                  (env1, []))
                              in
                           (match uu____25032 with
                            | (env2,decls) ->
                                let binders1 =
                                  FStar_Syntax_Subst.close_binders binders
                                   in
                                let actions_docs =
                                  FStar_All.pipe_right actions
                                    (FStar_List.map
                                       (fun d1  ->
                                          match d1.FStar_Parser_AST.d with
                                          | FStar_Parser_AST.Tycon
                                              (uu____25166,uu____25167,
                                               (FStar_Parser_AST.TyconAbbrev
                                                (name,action_params,uu____25170,
                                                 {
                                                   FStar_Parser_AST.tm =
                                                     FStar_Parser_AST.Construct
                                                     (uu____25171,(def,uu____25173)::
                                                      (cps_type,uu____25175)::[]);
                                                   FStar_Parser_AST.range =
                                                     uu____25176;
                                                   FStar_Parser_AST.level =
                                                     uu____25177;_}),doc1)::[])
                                              when Prims.op_Negation for_free
                                              ->
                                              let uu____25233 =
                                                desugar_binders env2
                                                  action_params
                                                 in
                                              (match uu____25233 with
                                               | (env3,action_params1) ->
                                                   let action_params2 =
                                                     FStar_Syntax_Subst.close_binders
                                                       action_params1
                                                      in
                                                   let uu____25271 =
                                                     let uu____25272 =
                                                       FStar_Syntax_DsEnv.qualify
                                                         env3 name
                                                        in
                                                     let uu____25273 =
                                                       let uu____25274 =
                                                         desugar_term env3
                                                           def
                                                          in
                                                       FStar_Syntax_Subst.close
                                                         (FStar_List.append
                                                            binders1
                                                            action_params2)
                                                         uu____25274
                                                        in
                                                     let uu____25281 =
                                                       let uu____25282 =
                                                         desugar_typ env3
                                                           cps_type
                                                          in
                                                       FStar_Syntax_Subst.close
                                                         (FStar_List.append
                                                            binders1
                                                            action_params2)
                                                         uu____25282
                                                        in
                                                     {
                                                       FStar_Syntax_Syntax.action_name
                                                         = uu____25272;
                                                       FStar_Syntax_Syntax.action_unqualified_name
                                                         = name;
                                                       FStar_Syntax_Syntax.action_univs
                                                         = [];
                                                       FStar_Syntax_Syntax.action_params
                                                         = action_params2;
                                                       FStar_Syntax_Syntax.action_defn
                                                         = uu____25273;
                                                       FStar_Syntax_Syntax.action_typ
                                                         = uu____25281
                                                     }  in
                                                   (uu____25271, doc1))
                                          | FStar_Parser_AST.Tycon
                                              (uu____25291,uu____25292,
                                               (FStar_Parser_AST.TyconAbbrev
                                                (name,action_params,uu____25295,defn),doc1)::[])
                                              when for_free ->
                                              let uu____25334 =
                                                desugar_binders env2
                                                  action_params
                                                 in
                                              (match uu____25334 with
                                               | (env3,action_params1) ->
                                                   let action_params2 =
                                                     FStar_Syntax_Subst.close_binders
                                                       action_params1
                                                      in
                                                   let uu____25372 =
                                                     let uu____25373 =
                                                       FStar_Syntax_DsEnv.qualify
                                                         env3 name
                                                        in
                                                     let uu____25374 =
                                                       let uu____25375 =
                                                         desugar_term env3
                                                           defn
                                                          in
                                                       FStar_Syntax_Subst.close
                                                         (FStar_List.append
                                                            binders1
                                                            action_params2)
                                                         uu____25375
                                                        in
                                                     {
                                                       FStar_Syntax_Syntax.action_name
                                                         = uu____25373;
                                                       FStar_Syntax_Syntax.action_unqualified_name
                                                         = name;
                                                       FStar_Syntax_Syntax.action_univs
                                                         = [];
                                                       FStar_Syntax_Syntax.action_params
                                                         = action_params2;
                                                       FStar_Syntax_Syntax.action_defn
                                                         = uu____25374;
                                                       FStar_Syntax_Syntax.action_typ
                                                         =
                                                         FStar_Syntax_Syntax.tun
                                                     }  in
                                                   (uu____25372, doc1))
                                          | uu____25384 ->
                                              FStar_Errors.raise_error
                                                (FStar_Errors.Fatal_MalformedActionDeclaration,
                                                  "Malformed action declaration; if this is an \"effect for free\", just provide the direct-style declaration. If this is not an \"effect for free\", please provide a pair of the definition and its cps-type with arrows inserted in the right place (see examples).")
                                                d1.FStar_Parser_AST.drange))
                                   in
                                let actions1 =
                                  FStar_List.map FStar_Pervasives_Native.fst
                                    actions_docs
                                   in
                                let eff_t1 =
                                  FStar_Syntax_Subst.close binders1 eff_t  in
                                let lookup1 s =
                                  let l =
                                    let uu____25420 =
                                      FStar_Ident.mk_ident
                                        (s, (d.FStar_Parser_AST.drange))
                                       in
                                    FStar_Syntax_DsEnv.qualify env2
                                      uu____25420
                                     in
                                  let uu____25422 =
                                    let uu____25423 =
                                      FStar_Syntax_DsEnv.fail_or env2
                                        (FStar_Syntax_DsEnv.try_lookup_definition
                                           env2) l
                                       in
                                    FStar_All.pipe_left
                                      (FStar_Syntax_Subst.close binders1)
                                      uu____25423
                                     in
                                  ([], uu____25422)  in
                                let mname =
                                  FStar_Syntax_DsEnv.qualify env0 eff_name
                                   in
                                let qualifiers =
                                  FStar_List.map
                                    (trans_qual d.FStar_Parser_AST.drange
                                       (FStar_Pervasives_Native.Some mname))
                                    quals
                                   in
                                let se =
                                  if for_free
                                  then
                                    let dummy_tscheme =
                                      let uu____25441 =
                                        FStar_Syntax_Syntax.mk
                                          FStar_Syntax_Syntax.Tm_unknown
                                          FStar_Pervasives_Native.None
                                          FStar_Range.dummyRange
                                         in
                                      ([], uu____25441)  in
                                    let uu____25448 =
                                      let uu____25449 =
                                        let uu____25450 =
                                          let uu____25451 = lookup1 "repr"
                                             in
                                          FStar_Pervasives_Native.snd
                                            uu____25451
                                           in
                                        let uu____25461 = lookup1 "return"
                                           in
                                        let uu____25463 = lookup1 "bind"  in
                                        let uu____25465 =
                                          FStar_List.map (desugar_term env2)
                                            attrs
                                           in
                                        {
                                          FStar_Syntax_Syntax.cattributes =
                                            [];
                                          FStar_Syntax_Syntax.mname = mname;
                                          FStar_Syntax_Syntax.univs = [];
                                          FStar_Syntax_Syntax.binders =
                                            binders1;
                                          FStar_Syntax_Syntax.signature =
                                            eff_t1;
                                          FStar_Syntax_Syntax.ret_wp =
                                            dummy_tscheme;
                                          FStar_Syntax_Syntax.bind_wp =
                                            dummy_tscheme;
                                          FStar_Syntax_Syntax.if_then_else =
                                            dummy_tscheme;
                                          FStar_Syntax_Syntax.ite_wp =
                                            dummy_tscheme;
                                          FStar_Syntax_Syntax.stronger =
                                            dummy_tscheme;
                                          FStar_Syntax_Syntax.close_wp =
                                            dummy_tscheme;
                                          FStar_Syntax_Syntax.trivial =
                                            dummy_tscheme;
                                          FStar_Syntax_Syntax.repr =
                                            uu____25450;
                                          FStar_Syntax_Syntax.return_repr =
                                            uu____25461;
                                          FStar_Syntax_Syntax.bind_repr =
                                            uu____25463;
                                          FStar_Syntax_Syntax.actions =
                                            actions1;
                                          FStar_Syntax_Syntax.eff_attrs =
                                            uu____25465
                                        }  in
                                      FStar_Syntax_Syntax.Sig_new_effect_for_free
                                        uu____25449
                                       in
                                    {
                                      FStar_Syntax_Syntax.sigel = uu____25448;
                                      FStar_Syntax_Syntax.sigrng =
                                        (d.FStar_Parser_AST.drange);
                                      FStar_Syntax_Syntax.sigquals =
                                        qualifiers;
                                      FStar_Syntax_Syntax.sigmeta =
                                        FStar_Syntax_Syntax.default_sigmeta;
                                      FStar_Syntax_Syntax.sigattrs = []
                                    }
                                  else
                                    (let rr =
                                       FStar_Util.for_some
                                         (fun uu___28_25473  ->
                                            match uu___28_25473 with
                                            | FStar_Syntax_Syntax.Reifiable 
                                                -> true
                                            | FStar_Syntax_Syntax.Reflectable
                                                uu____25476 -> true
                                            | uu____25478 -> false)
                                         qualifiers
                                        in
                                     let un_ts =
                                       ([], FStar_Syntax_Syntax.tun)  in
                                     let uu____25493 =
                                       let uu____25494 =
                                         let uu____25495 =
                                           lookup1 "return_wp"  in
                                         let uu____25497 = lookup1 "bind_wp"
                                            in
                                         let uu____25499 =
                                           lookup1 "if_then_else"  in
                                         let uu____25501 = lookup1 "ite_wp"
                                            in
                                         let uu____25503 = lookup1 "stronger"
                                            in
                                         let uu____25505 = lookup1 "close_wp"
                                            in
                                         let uu____25507 = lookup1 "trivial"
                                            in
                                         let uu____25509 =
                                           if rr
                                           then
                                             let uu____25511 = lookup1 "repr"
                                                in
                                             FStar_All.pipe_left
                                               FStar_Pervasives_Native.snd
                                               uu____25511
                                           else FStar_Syntax_Syntax.tun  in
                                         let uu____25529 =
                                           if rr
                                           then lookup1 "return"
                                           else un_ts  in
                                         let uu____25534 =
                                           if rr
                                           then lookup1 "bind"
                                           else un_ts  in
                                         let uu____25539 =
                                           FStar_List.map (desugar_term env2)
                                             attrs
                                            in
                                         {
                                           FStar_Syntax_Syntax.cattributes =
                                             [];
                                           FStar_Syntax_Syntax.mname = mname;
                                           FStar_Syntax_Syntax.univs = [];
                                           FStar_Syntax_Syntax.binders =
                                             binders1;
                                           FStar_Syntax_Syntax.signature =
                                             eff_t1;
                                           FStar_Syntax_Syntax.ret_wp =
                                             uu____25495;
                                           FStar_Syntax_Syntax.bind_wp =
                                             uu____25497;
                                           FStar_Syntax_Syntax.if_then_else =
                                             uu____25499;
                                           FStar_Syntax_Syntax.ite_wp =
                                             uu____25501;
                                           FStar_Syntax_Syntax.stronger =
                                             uu____25503;
                                           FStar_Syntax_Syntax.close_wp =
                                             uu____25505;
                                           FStar_Syntax_Syntax.trivial =
                                             uu____25507;
                                           FStar_Syntax_Syntax.repr =
                                             uu____25509;
                                           FStar_Syntax_Syntax.return_repr =
                                             uu____25529;
                                           FStar_Syntax_Syntax.bind_repr =
                                             uu____25534;
                                           FStar_Syntax_Syntax.actions =
                                             actions1;
                                           FStar_Syntax_Syntax.eff_attrs =
                                             uu____25539
                                         }  in
                                       FStar_Syntax_Syntax.Sig_new_effect
                                         uu____25494
                                        in
                                     {
                                       FStar_Syntax_Syntax.sigel =
                                         uu____25493;
                                       FStar_Syntax_Syntax.sigrng =
                                         (d.FStar_Parser_AST.drange);
                                       FStar_Syntax_Syntax.sigquals =
                                         qualifiers;
                                       FStar_Syntax_Syntax.sigmeta =
                                         FStar_Syntax_Syntax.default_sigmeta;
                                       FStar_Syntax_Syntax.sigattrs = []
                                     })
                                   in
                                let env3 =
                                  FStar_Syntax_DsEnv.push_sigelt env0 se  in
                                let env4 =
                                  FStar_Syntax_DsEnv.push_doc env3 mname
                                    d.FStar_Parser_AST.doc
                                   in
                                let env5 =
                                  FStar_All.pipe_right actions_docs
                                    (FStar_List.fold_left
                                       (fun env5  ->
                                          fun uu____25565  ->
                                            match uu____25565 with
                                            | (a,doc1) ->
                                                let env6 =
                                                  let uu____25579 =
                                                    FStar_Syntax_Util.action_as_lb
                                                      mname a
                                                      (a.FStar_Syntax_Syntax.action_defn).FStar_Syntax_Syntax.pos
                                                     in
                                                  FStar_Syntax_DsEnv.push_sigelt
                                                    env5 uu____25579
                                                   in
                                                FStar_Syntax_DsEnv.push_doc
                                                  env6
                                                  a.FStar_Syntax_Syntax.action_name
                                                  doc1) env4)
                                   in
                                let env6 =
                                  push_reflect_effect env5 qualifiers mname
                                    d.FStar_Parser_AST.drange
                                   in
                                let env7 =
                                  FStar_Syntax_DsEnv.push_doc env6 mname
                                    d.FStar_Parser_AST.doc
                                   in
                                (env7, [se])))

and (desugar_redefine_effect :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.decl ->
      (FStar_Ident.lident FStar_Pervasives_Native.option ->
         FStar_Parser_AST.qualifier -> FStar_Syntax_Syntax.qualifier)
        ->
        FStar_Parser_AST.qualifier Prims.list ->
          FStar_Ident.ident ->
            FStar_Parser_AST.binder Prims.list ->
              FStar_Parser_AST.term ->
                (FStar_Syntax_DsEnv.env * FStar_Syntax_Syntax.sigelt
                  Prims.list))
  =
  fun env  ->
    fun d  ->
      fun trans_qual1  ->
        fun quals  ->
          fun eff_name  ->
            fun eff_binders  ->
              fun defn  ->
                let env0 = env  in
                let env1 = FStar_Syntax_DsEnv.enter_monad_scope env eff_name
                   in
                let uu____25603 = desugar_binders env1 eff_binders  in
                match uu____25603 with
                | (env2,binders) ->
                    let uu____25640 =
                      let uu____25651 = head_and_args defn  in
                      match uu____25651 with
                      | (head1,args) ->
                          let lid =
                            match head1.FStar_Parser_AST.tm with
                            | FStar_Parser_AST.Name l -> l
                            | uu____25688 ->
                                let uu____25689 =
                                  let uu____25695 =
                                    let uu____25697 =
                                      let uu____25699 =
                                        FStar_Parser_AST.term_to_string head1
                                         in
                                      Prims.op_Hat uu____25699 " not found"
                                       in
                                    Prims.op_Hat "Effect " uu____25697  in
                                  (FStar_Errors.Fatal_EffectNotFound,
                                    uu____25695)
                                   in
                                FStar_Errors.raise_error uu____25689
                                  d.FStar_Parser_AST.drange
                             in
                          let ed =
                            FStar_Syntax_DsEnv.fail_or env2
                              (FStar_Syntax_DsEnv.try_lookup_effect_defn env2)
                              lid
                             in
                          let uu____25705 =
                            match FStar_List.rev args with
                            | (last_arg,uu____25735)::args_rev ->
                                let uu____25747 =
                                  let uu____25748 = unparen last_arg  in
                                  uu____25748.FStar_Parser_AST.tm  in
                                (match uu____25747 with
                                 | FStar_Parser_AST.Attributes ts ->
                                     (ts, (FStar_List.rev args_rev))
                                 | uu____25776 -> ([], args))
                            | uu____25785 -> ([], args)  in
                          (match uu____25705 with
                           | (cattributes,args1) ->
                               let uu____25828 = desugar_args env2 args1  in
                               let uu____25829 =
                                 desugar_attributes env2 cattributes  in
                               (lid, ed, uu____25828, uu____25829))
                       in
                    (match uu____25640 with
                     | (ed_lid,ed,args,cattributes) ->
                         let binders1 =
                           FStar_Syntax_Subst.close_binders binders  in
                         (if
                            (FStar_List.length args) <>
                              (FStar_List.length
                                 ed.FStar_Syntax_Syntax.binders)
                          then
                            FStar_Errors.raise_error
                              (FStar_Errors.Fatal_ArgumentLengthMismatch,
                                "Unexpected number of arguments to effect constructor")
                              defn.FStar_Parser_AST.range
                          else ();
                          (let uu____25869 =
                             FStar_Syntax_Subst.open_term'
                               ed.FStar_Syntax_Syntax.binders
                               FStar_Syntax_Syntax.t_unit
                              in
                           match uu____25869 with
                           | (ed_binders,uu____25883,ed_binders_opening) ->
                               let sub' shift_n uu____25902 =
                                 match uu____25902 with
                                 | (us,x) ->
                                     let x1 =
                                       let uu____25917 =
                                         FStar_Syntax_Subst.shift_subst
                                           (shift_n + (FStar_List.length us))
                                           ed_binders_opening
                                          in
                                       FStar_Syntax_Subst.subst uu____25917 x
                                        in
                                     let s =
                                       FStar_Syntax_Util.subst_of_list
                                         ed_binders args
                                        in
                                     let uu____25921 =
                                       let uu____25922 =
                                         FStar_Syntax_Subst.subst s x1  in
                                       (us, uu____25922)  in
                                     FStar_Syntax_Subst.close_tscheme
                                       binders1 uu____25921
                                  in
                               let sub1 = sub' Prims.int_zero  in
                               let mname =
                                 FStar_Syntax_DsEnv.qualify env0 eff_name  in
                               let ed1 =
                                 let uu____25943 =
                                   let uu____25944 =
                                     sub1
                                       ([],
                                         (ed.FStar_Syntax_Syntax.signature))
                                      in
                                   FStar_Pervasives_Native.snd uu____25944
                                    in
                                 let uu____25959 =
                                   sub1 ed.FStar_Syntax_Syntax.ret_wp  in
                                 let uu____25960 =
                                   sub1 ed.FStar_Syntax_Syntax.bind_wp  in
                                 let uu____25961 =
                                   sub1 ed.FStar_Syntax_Syntax.if_then_else
                                    in
                                 let uu____25962 =
                                   sub1 ed.FStar_Syntax_Syntax.ite_wp  in
                                 let uu____25963 =
                                   sub1 ed.FStar_Syntax_Syntax.stronger  in
                                 let uu____25964 =
                                   sub1 ed.FStar_Syntax_Syntax.close_wp  in
                                 let uu____25965 =
                                   sub1 ed.FStar_Syntax_Syntax.trivial  in
                                 let uu____25966 =
                                   let uu____25967 =
                                     sub1 ([], (ed.FStar_Syntax_Syntax.repr))
                                      in
                                   FStar_Pervasives_Native.snd uu____25967
                                    in
                                 let uu____25982 =
                                   sub1 ed.FStar_Syntax_Syntax.return_repr
                                    in
                                 let uu____25983 =
                                   sub1 ed.FStar_Syntax_Syntax.bind_repr  in
                                 let uu____25984 =
                                   FStar_List.map
                                     (fun action  ->
                                        let nparam =
                                          FStar_List.length
                                            action.FStar_Syntax_Syntax.action_params
                                           in
                                        let uu____26000 =
                                          FStar_Syntax_DsEnv.qualify env2
                                            action.FStar_Syntax_Syntax.action_unqualified_name
                                           in
                                        let uu____26001 =
                                          let uu____26002 =
                                            sub' nparam
                                              ([],
                                                (action.FStar_Syntax_Syntax.action_defn))
                                             in
                                          FStar_Pervasives_Native.snd
                                            uu____26002
                                           in
                                        let uu____26017 =
                                          let uu____26018 =
                                            sub' nparam
                                              ([],
                                                (action.FStar_Syntax_Syntax.action_typ))
                                             in
                                          FStar_Pervasives_Native.snd
                                            uu____26018
                                           in
                                        {
                                          FStar_Syntax_Syntax.action_name =
                                            uu____26000;
                                          FStar_Syntax_Syntax.action_unqualified_name
                                            =
                                            (action.FStar_Syntax_Syntax.action_unqualified_name);
                                          FStar_Syntax_Syntax.action_univs =
                                            (action.FStar_Syntax_Syntax.action_univs);
                                          FStar_Syntax_Syntax.action_params =
                                            (action.FStar_Syntax_Syntax.action_params);
                                          FStar_Syntax_Syntax.action_defn =
                                            uu____26001;
                                          FStar_Syntax_Syntax.action_typ =
                                            uu____26017
                                        }) ed.FStar_Syntax_Syntax.actions
                                    in
                                 {
                                   FStar_Syntax_Syntax.cattributes =
                                     cattributes;
                                   FStar_Syntax_Syntax.mname = mname;
                                   FStar_Syntax_Syntax.univs =
                                     (ed.FStar_Syntax_Syntax.univs);
                                   FStar_Syntax_Syntax.binders = binders1;
                                   FStar_Syntax_Syntax.signature =
                                     uu____25943;
                                   FStar_Syntax_Syntax.ret_wp = uu____25959;
                                   FStar_Syntax_Syntax.bind_wp = uu____25960;
                                   FStar_Syntax_Syntax.if_then_else =
                                     uu____25961;
                                   FStar_Syntax_Syntax.ite_wp = uu____25962;
                                   FStar_Syntax_Syntax.stronger = uu____25963;
                                   FStar_Syntax_Syntax.close_wp = uu____25964;
                                   FStar_Syntax_Syntax.trivial = uu____25965;
                                   FStar_Syntax_Syntax.repr = uu____25966;
                                   FStar_Syntax_Syntax.return_repr =
                                     uu____25982;
                                   FStar_Syntax_Syntax.bind_repr =
                                     uu____25983;
                                   FStar_Syntax_Syntax.actions = uu____25984;
                                   FStar_Syntax_Syntax.eff_attrs =
                                     (ed.FStar_Syntax_Syntax.eff_attrs)
                                 }  in
                               let se =
                                 let for_free =
                                   let uu____26036 =
                                     let uu____26038 =
                                       let uu____26047 =
                                         FStar_Syntax_Util.arrow_formals
                                           ed1.FStar_Syntax_Syntax.signature
                                          in
                                       FStar_Pervasives_Native.fst
                                         uu____26047
                                        in
                                     FStar_List.length uu____26038  in
                                   uu____26036 = Prims.int_one  in
                                 let uu____26080 =
                                   let uu____26083 =
                                     trans_qual1
                                       (FStar_Pervasives_Native.Some mname)
                                      in
                                   FStar_List.map uu____26083 quals  in
                                 {
                                   FStar_Syntax_Syntax.sigel =
                                     (if for_free
                                      then
                                        FStar_Syntax_Syntax.Sig_new_effect_for_free
                                          ed1
                                      else
                                        FStar_Syntax_Syntax.Sig_new_effect
                                          ed1);
                                   FStar_Syntax_Syntax.sigrng =
                                     (d.FStar_Parser_AST.drange);
                                   FStar_Syntax_Syntax.sigquals = uu____26080;
                                   FStar_Syntax_Syntax.sigmeta =
                                     FStar_Syntax_Syntax.default_sigmeta;
                                   FStar_Syntax_Syntax.sigattrs = []
                                 }  in
                               let monad_env = env2  in
                               let env3 =
                                 FStar_Syntax_DsEnv.push_sigelt env0 se  in
                               let env4 =
                                 FStar_Syntax_DsEnv.push_doc env3 ed_lid
                                   d.FStar_Parser_AST.doc
                                  in
                               let env5 =
                                 FStar_All.pipe_right
                                   ed1.FStar_Syntax_Syntax.actions
                                   (FStar_List.fold_left
                                      (fun env5  ->
                                         fun a  ->
                                           let doc1 =
                                             FStar_Syntax_DsEnv.try_lookup_doc
                                               env5
                                               a.FStar_Syntax_Syntax.action_name
                                              in
                                           let env6 =
                                             let uu____26107 =
                                               FStar_Syntax_Util.action_as_lb
                                                 mname a
                                                 (a.FStar_Syntax_Syntax.action_defn).FStar_Syntax_Syntax.pos
                                                in
                                             FStar_Syntax_DsEnv.push_sigelt
                                               env5 uu____26107
                                              in
                                           FStar_Syntax_DsEnv.push_doc env6
                                             a.FStar_Syntax_Syntax.action_name
                                             doc1) env4)
                                  in
                               let env6 =
                                 let uu____26109 =
                                   FStar_All.pipe_right quals
                                     (FStar_List.contains
                                        FStar_Parser_AST.Reflectable)
                                    in
                                 if uu____26109
                                 then
                                   let reflect_lid =
                                     let uu____26116 =
                                       FStar_Ident.id_of_text "reflect"  in
                                     FStar_All.pipe_right uu____26116
                                       (FStar_Syntax_DsEnv.qualify monad_env)
                                      in
                                   let quals1 =
                                     [FStar_Syntax_Syntax.Assumption;
                                     FStar_Syntax_Syntax.Reflectable mname]
                                      in
                                   let refl_decl =
                                     {
                                       FStar_Syntax_Syntax.sigel =
                                         (FStar_Syntax_Syntax.Sig_declare_typ
                                            (reflect_lid, [],
                                              FStar_Syntax_Syntax.tun));
                                       FStar_Syntax_Syntax.sigrng =
                                         (d.FStar_Parser_AST.drange);
                                       FStar_Syntax_Syntax.sigquals = quals1;
                                       FStar_Syntax_Syntax.sigmeta =
                                         FStar_Syntax_Syntax.default_sigmeta;
                                       FStar_Syntax_Syntax.sigattrs = []
                                     }  in
                                   FStar_Syntax_DsEnv.push_sigelt env5
                                     refl_decl
                                 else env5  in
                               let env7 =
                                 FStar_Syntax_DsEnv.push_doc env6 mname
                                   d.FStar_Parser_AST.doc
                                  in
                               (env7, [se]))))

and (mk_comment_attr :
  FStar_Parser_AST.decl ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax Prims.list)
  =
  fun d  ->
    let uu____26128 =
      match d.FStar_Parser_AST.doc with
      | FStar_Pervasives_Native.None  -> ("", [])
      | FStar_Pervasives_Native.Some fsdoc -> fsdoc  in
    match uu____26128 with
    | (text,kv) ->
        let summary =
          match FStar_List.assoc "summary" kv with
          | FStar_Pervasives_Native.None  -> ""
          | FStar_Pervasives_Native.Some s ->
              Prims.op_Hat "  " (Prims.op_Hat s "\n")
           in
        let pp =
          match FStar_List.assoc "type" kv with
          | FStar_Pervasives_Native.Some uu____26215 ->
              let uu____26218 =
                let uu____26220 =
                  FStar_Parser_ToDocument.signature_to_document d  in
                FStar_Pprint.pretty_string 0.95 (Prims.of_int (80))
                  uu____26220
                 in
              Prims.op_Hat "\n  " uu____26218
          | uu____26223 -> ""  in
        let other =
          FStar_List.filter_map
            (fun uu____26242  ->
               match uu____26242 with
               | (k,v1) ->
                   if (k <> "summary") && (k <> "type")
                   then
                     FStar_Pervasives_Native.Some
                       (Prims.op_Hat k (Prims.op_Hat ": " v1))
                   else FStar_Pervasives_Native.None) kv
           in
        let other1 =
          if other <> []
          then Prims.op_Hat (FStar_String.concat "\n" other) "\n"
          else ""  in
        let str =
          Prims.op_Hat summary (Prims.op_Hat pp (Prims.op_Hat other1 text))
           in
        let fv =
          let uu____26287 = FStar_Ident.lid_of_str "FStar.Pervasives.Comment"
             in
          FStar_Syntax_Syntax.fvar uu____26287
            FStar_Syntax_Syntax.delta_constant FStar_Pervasives_Native.None
           in
        if str = ""
        then []
        else
          (let uu____26300 =
             let arg = FStar_Syntax_Util.exp_string str  in
             let uu____26304 =
               let uu____26315 = FStar_Syntax_Syntax.as_arg arg  in
               [uu____26315]  in
             FStar_Syntax_Util.mk_app fv uu____26304  in
           [uu____26300])

and (desugar_decl_aux :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.decl -> (env_t * FStar_Syntax_Syntax.sigelts))
  =
  fun env  ->
    fun d  ->
      let env0 = env  in
      let uu____26351 = desugar_decl_noattrs env d  in
      match uu____26351 with
      | (env1,sigelts) ->
          let attrs = d.FStar_Parser_AST.attrs  in
          let attrs1 = FStar_List.map (desugar_term env1) attrs  in
          let val_attrs =
            match sigelts with
            | {
                FStar_Syntax_Syntax.sigel = FStar_Syntax_Syntax.Sig_let
                  (lbs,names1);
                FStar_Syntax_Syntax.sigrng = uu____26381;
                FStar_Syntax_Syntax.sigquals = uu____26382;
                FStar_Syntax_Syntax.sigmeta = uu____26383;
                FStar_Syntax_Syntax.sigattrs = uu____26384;_}::[] ->
                let uu____26393 =
                  FStar_All.pipe_right names1
                    (FStar_List.collect
                       (fun nm  ->
                          let uu____26403 =
                            FStar_Syntax_DsEnv.lookup_letbinding_quals_and_attrs
                              env0 nm
                             in
                          FStar_Pervasives_Native.snd uu____26403))
                   in
                FStar_All.pipe_right uu____26393
                  (FStar_List.filter
                     (fun t  ->
                        let uu____26425 = get_fail_attr false t  in
                        FStar_Option.isNone uu____26425))
            | uu____26445 -> []  in
          let attrs2 =
            let uu____26453 = mk_comment_attr d  in
            FStar_List.append uu____26453
              (FStar_List.append attrs1 val_attrs)
             in
          let uu____26462 =
            FStar_List.mapi
              (fun i  ->
                 fun sigelt  ->
                   if i = Prims.int_zero
                   then
                     let uu___3413_26472 = sigelt  in
                     {
                       FStar_Syntax_Syntax.sigel =
                         (uu___3413_26472.FStar_Syntax_Syntax.sigel);
                       FStar_Syntax_Syntax.sigrng =
                         (uu___3413_26472.FStar_Syntax_Syntax.sigrng);
                       FStar_Syntax_Syntax.sigquals =
                         (uu___3413_26472.FStar_Syntax_Syntax.sigquals);
                       FStar_Syntax_Syntax.sigmeta =
                         (uu___3413_26472.FStar_Syntax_Syntax.sigmeta);
                       FStar_Syntax_Syntax.sigattrs = attrs2
                     }
                   else
                     (let uu___3415_26475 = sigelt  in
                      let uu____26476 =
                        FStar_List.filter
                          (fun at1  ->
                             let uu____26482 = get_fail_attr false at1  in
                             FStar_Option.isNone uu____26482) attrs2
                         in
                      {
                        FStar_Syntax_Syntax.sigel =
                          (uu___3415_26475.FStar_Syntax_Syntax.sigel);
                        FStar_Syntax_Syntax.sigrng =
                          (uu___3415_26475.FStar_Syntax_Syntax.sigrng);
                        FStar_Syntax_Syntax.sigquals =
                          (uu___3415_26475.FStar_Syntax_Syntax.sigquals);
                        FStar_Syntax_Syntax.sigmeta =
                          (uu___3415_26475.FStar_Syntax_Syntax.sigmeta);
                        FStar_Syntax_Syntax.sigattrs = uu____26476
                      })) sigelts
             in
          (env1, uu____26462)

and (desugar_decl :
  env_t -> FStar_Parser_AST.decl -> (env_t * FStar_Syntax_Syntax.sigelts)) =
  fun env  ->
    fun d  ->
      let uu____26508 = desugar_decl_aux env d  in
      match uu____26508 with
      | (env1,ses) ->
          let uu____26519 =
            FStar_All.pipe_right ses
              (FStar_List.map generalize_annotated_univs)
             in
          (env1, uu____26519)

and (desugar_decl_noattrs :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.decl -> (env_t * FStar_Syntax_Syntax.sigelts))
  =
  fun env  ->
    fun d  ->
      let trans_qual1 = trans_qual d.FStar_Parser_AST.drange  in
      match d.FStar_Parser_AST.d with
      | FStar_Parser_AST.Pragma p ->
          let p1 = trans_pragma p  in
          (FStar_Syntax_Util.process_pragma p1 d.FStar_Parser_AST.drange;
           (let se =
              {
                FStar_Syntax_Syntax.sigel =
                  (FStar_Syntax_Syntax.Sig_pragma p1);
                FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
                FStar_Syntax_Syntax.sigquals = [];
                FStar_Syntax_Syntax.sigmeta =
                  FStar_Syntax_Syntax.default_sigmeta;
                FStar_Syntax_Syntax.sigattrs = []
              }  in
            (env, [se])))
      | FStar_Parser_AST.Fsdoc uu____26547 -> (env, [])
      | FStar_Parser_AST.TopLevelModule id1 -> (env, [])
      | FStar_Parser_AST.Open lid ->
          let env1 = FStar_Syntax_DsEnv.push_namespace env lid  in (env1, [])
      | FStar_Parser_AST.Friend lid ->
          let uu____26552 = FStar_Syntax_DsEnv.iface env  in
          if uu____26552
          then
            FStar_Errors.raise_error
              (FStar_Errors.Fatal_FriendInterface,
                "'friend' declarations are not allowed in interfaces")
              d.FStar_Parser_AST.drange
          else
            (let uu____26567 =
               let uu____26569 =
                 let uu____26571 = FStar_Syntax_DsEnv.dep_graph env  in
                 let uu____26572 = FStar_Syntax_DsEnv.current_module env  in
                 FStar_Parser_Dep.module_has_interface uu____26571
                   uu____26572
                  in
               Prims.op_Negation uu____26569  in
             if uu____26567
             then
               FStar_Errors.raise_error
                 (FStar_Errors.Fatal_FriendInterface,
                   "'friend' declarations are not allowed in modules that lack interfaces")
                 d.FStar_Parser_AST.drange
             else
               (let uu____26586 =
                  let uu____26588 =
                    let uu____26590 = FStar_Syntax_DsEnv.dep_graph env  in
                    FStar_Parser_Dep.module_has_interface uu____26590 lid  in
                  Prims.op_Negation uu____26588  in
                if uu____26586
                then
                  FStar_Errors.raise_error
                    (FStar_Errors.Fatal_FriendInterface,
                      "'friend' declarations cannot refer to modules that lack interfaces")
                    d.FStar_Parser_AST.drange
                else
                  (let uu____26604 =
                     let uu____26606 =
                       let uu____26608 = FStar_Syntax_DsEnv.dep_graph env  in
                       FStar_Parser_Dep.deps_has_implementation uu____26608
                         lid
                        in
                     Prims.op_Negation uu____26606  in
                   if uu____26604
                   then
                     FStar_Errors.raise_error
                       (FStar_Errors.Fatal_FriendInterface,
                         "'friend' module has not been loaded; recompute dependences (C-c C-r) if in interactive mode")
                       d.FStar_Parser_AST.drange
                   else (env, []))))
      | FStar_Parser_AST.Include lid ->
          let env1 = FStar_Syntax_DsEnv.push_include env lid  in (env1, [])
      | FStar_Parser_AST.ModuleAbbrev (x,l) ->
          let uu____26626 = FStar_Syntax_DsEnv.push_module_abbrev env x l  in
          (uu____26626, [])
      | FStar_Parser_AST.Tycon (is_effect,typeclass,tcs) ->
          let quals = d.FStar_Parser_AST.quals  in
          let quals1 =
            if is_effect
            then FStar_Parser_AST.Effect_qual :: quals
            else quals  in
          let quals2 =
            if typeclass
            then
              match tcs with
              | (FStar_Parser_AST.TyconRecord uu____26667,uu____26668)::[] ->
                  FStar_Parser_AST.Noeq :: quals1
              | uu____26707 ->
                  FStar_Errors.raise_error
                    (FStar_Errors.Error_BadClassDecl,
                      "Ill-formed `class` declaration: definition must be a record type")
                    d.FStar_Parser_AST.drange
            else quals1  in
          let tcs1 =
            FStar_List.map
              (fun uu____26734  ->
                 match uu____26734 with | (x,uu____26742) -> x) tcs
             in
          let uu____26747 =
            let uu____26752 =
              FStar_List.map (trans_qual1 FStar_Pervasives_Native.None)
                quals2
               in
            desugar_tycon env d uu____26752 tcs1  in
          (match uu____26747 with
           | (env1,ses) ->
               let mkclass lid =
                 let uu____26769 =
                   let uu____26770 =
                     let uu____26777 =
                       FStar_Syntax_Syntax.new_bv
                         FStar_Pervasives_Native.None FStar_Syntax_Syntax.tun
                        in
                     FStar_Syntax_Syntax.mk_binder uu____26777  in
                   [uu____26770]  in
                 let uu____26790 =
                   let uu____26793 =
                     FStar_Syntax_Syntax.tabbrev
                       FStar_Parser_Const.mk_class_lid
                      in
                   let uu____26796 =
                     let uu____26807 =
                       let uu____26816 =
                         let uu____26817 = FStar_Ident.string_of_lid lid  in
                         FStar_Syntax_Util.exp_string uu____26817  in
                       FStar_Syntax_Syntax.as_arg uu____26816  in
                     [uu____26807]  in
                   FStar_Syntax_Util.mk_app uu____26793 uu____26796  in
                 FStar_Syntax_Util.abs uu____26769 uu____26790
                   FStar_Pervasives_Native.None
                  in
               let get_meths se =
                 let rec get_fname quals3 =
                   match quals3 with
                   | (FStar_Syntax_Syntax.Projector
                       (uu____26857,id1))::uu____26859 ->
                       FStar_Pervasives_Native.Some id1
                   | uu____26862::quals4 -> get_fname quals4
                   | [] -> FStar_Pervasives_Native.None  in
                 let uu____26866 = get_fname se.FStar_Syntax_Syntax.sigquals
                    in
                 match uu____26866 with
                 | FStar_Pervasives_Native.None  -> []
                 | FStar_Pervasives_Native.Some id1 ->
                     let uu____26872 = FStar_Syntax_DsEnv.qualify env1 id1
                        in
                     [uu____26872]
                  in
               let rec splice_decl meths se =
                 match se.FStar_Syntax_Syntax.sigel with
                 | FStar_Syntax_Syntax.Sig_bundle (ses1,uu____26893) ->
                     FStar_List.concatMap (splice_decl meths) ses1
                 | FStar_Syntax_Syntax.Sig_inductive_typ
                     (lid,uu____26903,uu____26904,uu____26905,uu____26906,uu____26907)
                     ->
                     let uu____26916 =
                       let uu____26917 =
                         let uu____26918 =
                           let uu____26925 = mkclass lid  in
                           (meths, uu____26925)  in
                         FStar_Syntax_Syntax.Sig_splice uu____26918  in
                       {
                         FStar_Syntax_Syntax.sigel = uu____26917;
                         FStar_Syntax_Syntax.sigrng =
                           (d.FStar_Parser_AST.drange);
                         FStar_Syntax_Syntax.sigquals = [];
                         FStar_Syntax_Syntax.sigmeta =
                           FStar_Syntax_Syntax.default_sigmeta;
                         FStar_Syntax_Syntax.sigattrs = []
                       }  in
                     [uu____26916]
                 | uu____26928 -> []  in
               let extra =
                 if typeclass
                 then
                   let meths = FStar_List.concatMap get_meths ses  in
                   FStar_List.concatMap (splice_decl meths) ses
                 else []  in
               let env2 =
                 FStar_List.fold_left FStar_Syntax_DsEnv.push_sigelt env1
                   extra
                  in
               (env2, (FStar_List.append ses extra)))
      | FStar_Parser_AST.TopLevelLet (isrec,lets) ->
          let quals = d.FStar_Parser_AST.quals  in
          let expand_toplevel_pattern =
            (isrec = FStar_Parser_AST.NoLetQualifier) &&
              (match lets with
               | ({
                    FStar_Parser_AST.pat = FStar_Parser_AST.PatOp uu____26962;
                    FStar_Parser_AST.prange = uu____26963;_},uu____26964)::[]
                   -> false
               | ({
                    FStar_Parser_AST.pat = FStar_Parser_AST.PatVar
                      uu____26974;
                    FStar_Parser_AST.prange = uu____26975;_},uu____26976)::[]
                   -> false
               | ({
                    FStar_Parser_AST.pat = FStar_Parser_AST.PatAscribed
                      ({
                         FStar_Parser_AST.pat = FStar_Parser_AST.PatOp
                           uu____26992;
                         FStar_Parser_AST.prange = uu____26993;_},uu____26994);
                    FStar_Parser_AST.prange = uu____26995;_},uu____26996)::[]
                   -> false
               | ({
                    FStar_Parser_AST.pat = FStar_Parser_AST.PatAscribed
                      ({
                         FStar_Parser_AST.pat = FStar_Parser_AST.PatVar
                           uu____27018;
                         FStar_Parser_AST.prange = uu____27019;_},uu____27020);
                    FStar_Parser_AST.prange = uu____27021;_},uu____27022)::[]
                   -> false
               | (p,uu____27051)::[] ->
                   let uu____27060 = is_app_pattern p  in
                   Prims.op_Negation uu____27060
               | uu____27062 -> false)
             in
          if Prims.op_Negation expand_toplevel_pattern
          then
            let lets1 =
              FStar_List.map (fun x  -> (FStar_Pervasives_Native.None, x))
                lets
               in
            let as_inner_let =
              FStar_Parser_AST.mk_term
                (FStar_Parser_AST.Let
                   (isrec, lets1,
                     (FStar_Parser_AST.mk_term
                        (FStar_Parser_AST.Const FStar_Const.Const_unit)
                        d.FStar_Parser_AST.drange FStar_Parser_AST.Expr)))
                d.FStar_Parser_AST.drange FStar_Parser_AST.Expr
               in
            let uu____27137 = desugar_term_maybe_top true env as_inner_let
               in
            (match uu____27137 with
             | (ds_lets,aq) ->
                 (check_no_aq aq;
                  (let uu____27150 =
                     let uu____27151 =
                       FStar_All.pipe_left FStar_Syntax_Subst.compress
                         ds_lets
                        in
                     uu____27151.FStar_Syntax_Syntax.n  in
                   match uu____27150 with
                   | FStar_Syntax_Syntax.Tm_let (lbs,uu____27161) ->
                       let fvs =
                         FStar_All.pipe_right
                           (FStar_Pervasives_Native.snd lbs)
                           (FStar_List.map
                              (fun lb  ->
                                 FStar_Util.right
                                   lb.FStar_Syntax_Syntax.lbname))
                          in
                       let val_quals =
                         FStar_All.pipe_right fvs
                           (FStar_List.collect
                              (fun fv  ->
                                 let uu____27202 =
                                   FStar_Syntax_DsEnv.lookup_letbinding_quals_and_attrs
                                     env
                                     (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                    in
                                 FStar_Pervasives_Native.fst uu____27202))
                          in
                       let quals1 =
                         match quals with
                         | uu____27220::uu____27221 ->
                             FStar_List.map
                               (trans_qual1 FStar_Pervasives_Native.None)
                               quals
                         | uu____27224 -> val_quals  in
                       let quals2 =
                         let uu____27228 =
                           FStar_All.pipe_right lets1
                             (FStar_Util.for_some
                                (fun uu____27261  ->
                                   match uu____27261 with
                                   | (uu____27275,(uu____27276,t)) ->
                                       t.FStar_Parser_AST.level =
                                         FStar_Parser_AST.Formula))
                            in
                         if uu____27228
                         then FStar_Syntax_Syntax.Logic :: quals1
                         else quals1  in
                       let lbs1 =
                         let uu____27296 =
                           FStar_All.pipe_right quals2
                             (FStar_List.contains
                                FStar_Syntax_Syntax.Abstract)
                            in
                         if uu____27296
                         then
                           let uu____27302 =
                             FStar_All.pipe_right
                               (FStar_Pervasives_Native.snd lbs)
                               (FStar_List.map
                                  (fun lb  ->
                                     let fv =
                                       FStar_Util.right
                                         lb.FStar_Syntax_Syntax.lbname
                                        in
                                     let uu___3593_27317 = lb  in
                                     {
                                       FStar_Syntax_Syntax.lbname =
                                         (FStar_Util.Inr
                                            (let uu___3595_27319 = fv  in
                                             {
                                               FStar_Syntax_Syntax.fv_name =
                                                 (uu___3595_27319.FStar_Syntax_Syntax.fv_name);
                                               FStar_Syntax_Syntax.fv_delta =
                                                 (FStar_Syntax_Syntax.Delta_abstract
                                                    (fv.FStar_Syntax_Syntax.fv_delta));
                                               FStar_Syntax_Syntax.fv_qual =
                                                 (uu___3595_27319.FStar_Syntax_Syntax.fv_qual)
                                             }));
                                       FStar_Syntax_Syntax.lbunivs =
                                         (uu___3593_27317.FStar_Syntax_Syntax.lbunivs);
                                       FStar_Syntax_Syntax.lbtyp =
                                         (uu___3593_27317.FStar_Syntax_Syntax.lbtyp);
                                       FStar_Syntax_Syntax.lbeff =
                                         (uu___3593_27317.FStar_Syntax_Syntax.lbeff);
                                       FStar_Syntax_Syntax.lbdef =
                                         (uu___3593_27317.FStar_Syntax_Syntax.lbdef);
                                       FStar_Syntax_Syntax.lbattrs =
                                         (uu___3593_27317.FStar_Syntax_Syntax.lbattrs);
                                       FStar_Syntax_Syntax.lbpos =
                                         (uu___3593_27317.FStar_Syntax_Syntax.lbpos)
                                     }))
                              in
                           ((FStar_Pervasives_Native.fst lbs), uu____27302)
                         else lbs  in
                       let names1 =
                         FStar_All.pipe_right fvs
                           (FStar_List.map
                              (fun fv  ->
                                 (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v))
                          in
                       let s =
                         {
                           FStar_Syntax_Syntax.sigel =
                             (FStar_Syntax_Syntax.Sig_let (lbs1, names1));
                           FStar_Syntax_Syntax.sigrng =
                             (d.FStar_Parser_AST.drange);
                           FStar_Syntax_Syntax.sigquals = quals2;
                           FStar_Syntax_Syntax.sigmeta =
                             FStar_Syntax_Syntax.default_sigmeta;
                           FStar_Syntax_Syntax.sigattrs = []
                         }  in
                       let env1 = FStar_Syntax_DsEnv.push_sigelt env s  in
                       let env2 =
                         FStar_List.fold_left
                           (fun env2  ->
                              fun id1  ->
                                FStar_Syntax_DsEnv.push_doc env2 id1
                                  d.FStar_Parser_AST.doc) env1 names1
                          in
                       (env2, [s])
                   | uu____27346 ->
                       failwith "Desugaring a let did not produce a let")))
          else
            (let uu____27354 =
               match lets with
               | (pat,body)::[] -> (pat, body)
               | uu____27373 ->
                   failwith
                     "expand_toplevel_pattern should only allow single definition lets"
                in
             match uu____27354 with
             | (pat,body) ->
                 let fresh_toplevel_name =
                   FStar_Ident.gen FStar_Range.dummyRange  in
                 let fresh_pat =
                   let var_pat =
                     FStar_Parser_AST.mk_pattern
                       (FStar_Parser_AST.PatVar
                          (fresh_toplevel_name, FStar_Pervasives_Native.None))
                       FStar_Range.dummyRange
                      in
                   match pat.FStar_Parser_AST.pat with
                   | FStar_Parser_AST.PatAscribed (pat1,ty) ->
                       let uu___3620_27410 = pat1  in
                       {
                         FStar_Parser_AST.pat =
                           (FStar_Parser_AST.PatAscribed (var_pat, ty));
                         FStar_Parser_AST.prange =
                           (uu___3620_27410.FStar_Parser_AST.prange)
                       }
                   | uu____27417 -> var_pat  in
                 let main_let =
                   desugar_decl env
                     (let uu___3624_27424 = d  in
                      {
                        FStar_Parser_AST.d =
                          (FStar_Parser_AST.TopLevelLet
                             (isrec, [(fresh_pat, body)]));
                        FStar_Parser_AST.drange =
                          (uu___3624_27424.FStar_Parser_AST.drange);
                        FStar_Parser_AST.doc =
                          (uu___3624_27424.FStar_Parser_AST.doc);
                        FStar_Parser_AST.quals = (FStar_Parser_AST.Private ::
                          (d.FStar_Parser_AST.quals));
                        FStar_Parser_AST.attrs =
                          (uu___3624_27424.FStar_Parser_AST.attrs)
                      })
                    in
                 let build_projection uu____27460 id1 =
                   match uu____27460 with
                   | (env1,ses) ->
                       let main =
                         let uu____27481 =
                           let uu____27482 =
                             FStar_Ident.lid_of_ids [fresh_toplevel_name]  in
                           FStar_Parser_AST.Var uu____27482  in
                         FStar_Parser_AST.mk_term uu____27481
                           FStar_Range.dummyRange FStar_Parser_AST.Expr
                          in
                       let lid = FStar_Ident.lid_of_ids [id1]  in
                       let projectee =
                         FStar_Parser_AST.mk_term (FStar_Parser_AST.Var lid)
                           FStar_Range.dummyRange FStar_Parser_AST.Expr
                          in
                       let body1 =
                         FStar_Parser_AST.mk_term
                           (FStar_Parser_AST.Match
                              (main,
                                [(pat, FStar_Pervasives_Native.None,
                                   projectee)])) FStar_Range.dummyRange
                           FStar_Parser_AST.Expr
                          in
                       let bv_pat =
                         FStar_Parser_AST.mk_pattern
                           (FStar_Parser_AST.PatVar
                              (id1, FStar_Pervasives_Native.None))
                           FStar_Range.dummyRange
                          in
                       let id_decl =
                         FStar_Parser_AST.mk_decl
                           (FStar_Parser_AST.TopLevelLet
                              (FStar_Parser_AST.NoLetQualifier,
                                [(bv_pat, body1)])) FStar_Range.dummyRange []
                          in
                       let uu____27532 = desugar_decl env1 id_decl  in
                       (match uu____27532 with
                        | (env2,ses') -> (env2, (FStar_List.append ses ses')))
                    in
                 let bvs =
                   let uu____27550 = gather_pattern_bound_vars true pat  in
                   FStar_All.pipe_right uu____27550 FStar_Util.set_elements
                    in
                 FStar_List.fold_left build_projection main_let bvs)
      | FStar_Parser_AST.Main t ->
          let e = desugar_term env t  in
          let se =
            {
              FStar_Syntax_Syntax.sigel = (FStar_Syntax_Syntax.Sig_main e);
              FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
              FStar_Syntax_Syntax.sigquals = [];
              FStar_Syntax_Syntax.sigmeta =
                FStar_Syntax_Syntax.default_sigmeta;
              FStar_Syntax_Syntax.sigattrs = []
            }  in
          (env, [se])
      | FStar_Parser_AST.Assume (id1,t) ->
          let f = desugar_formula env t  in
          let lid = FStar_Syntax_DsEnv.qualify env id1  in
          let env1 =
            FStar_Syntax_DsEnv.push_doc env lid d.FStar_Parser_AST.doc  in
          (env1,
            [{
               FStar_Syntax_Syntax.sigel =
                 (FStar_Syntax_Syntax.Sig_assume (lid, [], f));
               FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
               FStar_Syntax_Syntax.sigquals =
                 [FStar_Syntax_Syntax.Assumption];
               FStar_Syntax_Syntax.sigmeta =
                 FStar_Syntax_Syntax.default_sigmeta;
               FStar_Syntax_Syntax.sigattrs = []
             }])
      | FStar_Parser_AST.Val (id1,t) ->
          let quals = d.FStar_Parser_AST.quals  in
          let t1 =
            let uu____27574 = close_fun env t  in
            desugar_term env uu____27574  in
          let quals1 =
            let uu____27578 =
              (FStar_Syntax_DsEnv.iface env) &&
                (FStar_Syntax_DsEnv.admitted_iface env)
               in
            if uu____27578
            then FStar_Parser_AST.Assumption :: quals
            else quals  in
          let lid = FStar_Syntax_DsEnv.qualify env id1  in
          let attrs =
            FStar_List.map (desugar_term env) d.FStar_Parser_AST.attrs  in
          let se =
            let uu____27590 =
              FStar_List.map (trans_qual1 FStar_Pervasives_Native.None)
                quals1
               in
            {
              FStar_Syntax_Syntax.sigel =
                (FStar_Syntax_Syntax.Sig_declare_typ (lid, [], t1));
              FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
              FStar_Syntax_Syntax.sigquals = uu____27590;
              FStar_Syntax_Syntax.sigmeta =
                FStar_Syntax_Syntax.default_sigmeta;
              FStar_Syntax_Syntax.sigattrs = attrs
            }  in
          let env1 = FStar_Syntax_DsEnv.push_sigelt env se  in
          let env2 =
            FStar_Syntax_DsEnv.push_doc env1 lid d.FStar_Parser_AST.doc  in
          (env2, [se])
      | FStar_Parser_AST.Exception (id1,t_opt) ->
          let t =
            match t_opt with
            | FStar_Pervasives_Native.None  ->
                FStar_Syntax_DsEnv.fail_or env
                  (FStar_Syntax_DsEnv.try_lookup_lid env)
                  FStar_Parser_Const.exn_lid
            | FStar_Pervasives_Native.Some term ->
                let t = desugar_term env term  in
                let uu____27604 =
                  let uu____27613 = FStar_Syntax_Syntax.null_binder t  in
                  [uu____27613]  in
                let uu____27632 =
                  let uu____27635 =
                    FStar_Syntax_DsEnv.fail_or env
                      (FStar_Syntax_DsEnv.try_lookup_lid env)
                      FStar_Parser_Const.exn_lid
                     in
                  FStar_All.pipe_left FStar_Syntax_Syntax.mk_Total
                    uu____27635
                   in
                FStar_Syntax_Util.arrow uu____27604 uu____27632
             in
          let l = FStar_Syntax_DsEnv.qualify env id1  in
          let qual = [FStar_Syntax_Syntax.ExceptionConstructor]  in
          let se =
            {
              FStar_Syntax_Syntax.sigel =
                (FStar_Syntax_Syntax.Sig_datacon
                   (l, [], t, FStar_Parser_Const.exn_lid, Prims.int_zero,
                     [FStar_Parser_Const.exn_lid]));
              FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
              FStar_Syntax_Syntax.sigquals = qual;
              FStar_Syntax_Syntax.sigmeta =
                FStar_Syntax_Syntax.default_sigmeta;
              FStar_Syntax_Syntax.sigattrs = []
            }  in
          let se' =
            {
              FStar_Syntax_Syntax.sigel =
                (FStar_Syntax_Syntax.Sig_bundle ([se], [l]));
              FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
              FStar_Syntax_Syntax.sigquals = qual;
              FStar_Syntax_Syntax.sigmeta =
                FStar_Syntax_Syntax.default_sigmeta;
              FStar_Syntax_Syntax.sigattrs = []
            }  in
          let env1 = FStar_Syntax_DsEnv.push_sigelt env se'  in
          let env2 =
            FStar_Syntax_DsEnv.push_doc env1 l d.FStar_Parser_AST.doc  in
          let data_ops = mk_data_projector_names [] env2 se  in
          let discs = mk_data_discriminators [] env2 [l]  in
          let env3 =
            FStar_List.fold_left FStar_Syntax_DsEnv.push_sigelt env2
              (FStar_List.append discs data_ops)
             in
          (env3, (FStar_List.append (se' :: discs) data_ops))
      | FStar_Parser_AST.NewEffect (FStar_Parser_AST.RedefineEffect
          (eff_name,eff_binders,defn)) ->
          let quals = d.FStar_Parser_AST.quals  in
          desugar_redefine_effect env d trans_qual1 quals eff_name
            eff_binders defn
      | FStar_Parser_AST.NewEffect (FStar_Parser_AST.DefineEffect
          (eff_name,eff_binders,eff_typ,eff_decls)) ->
          let quals = d.FStar_Parser_AST.quals  in
          let attrs = d.FStar_Parser_AST.attrs  in
          desugar_effect env d quals eff_name eff_binders eff_typ eff_decls
            attrs
      | FStar_Parser_AST.SubEffect l ->
          let lookup1 l1 =
            let uu____27690 =
              FStar_Syntax_DsEnv.try_lookup_effect_name env l1  in
            match uu____27690 with
            | FStar_Pervasives_Native.None  ->
                let uu____27693 =
                  let uu____27699 =
                    let uu____27701 =
                      let uu____27703 = FStar_Syntax_Print.lid_to_string l1
                         in
                      Prims.op_Hat uu____27703 " not found"  in
                    Prims.op_Hat "Effect name " uu____27701  in
                  (FStar_Errors.Fatal_EffectNotFound, uu____27699)  in
                FStar_Errors.raise_error uu____27693
                  d.FStar_Parser_AST.drange
            | FStar_Pervasives_Native.Some l2 -> l2  in
          let src = lookup1 l.FStar_Parser_AST.msource  in
          let dst = lookup1 l.FStar_Parser_AST.mdest  in
          let uu____27711 =
            match l.FStar_Parser_AST.lift_op with
            | FStar_Parser_AST.NonReifiableLift t ->
                let uu____27729 =
                  let uu____27732 =
                    let uu____27733 = desugar_term env t  in
                    ([], uu____27733)  in
                  FStar_Pervasives_Native.Some uu____27732  in
                (uu____27729, FStar_Pervasives_Native.None)
            | FStar_Parser_AST.ReifiableLift (wp,t) ->
                let uu____27746 =
                  let uu____27749 =
                    let uu____27750 = desugar_term env wp  in
                    ([], uu____27750)  in
                  FStar_Pervasives_Native.Some uu____27749  in
                let uu____27757 =
                  let uu____27760 =
                    let uu____27761 = desugar_term env t  in
                    ([], uu____27761)  in
                  FStar_Pervasives_Native.Some uu____27760  in
                (uu____27746, uu____27757)
            | FStar_Parser_AST.LiftForFree t ->
                let uu____27773 =
                  let uu____27776 =
                    let uu____27777 = desugar_term env t  in
                    ([], uu____27777)  in
                  FStar_Pervasives_Native.Some uu____27776  in
                (FStar_Pervasives_Native.None, uu____27773)
             in
          (match uu____27711 with
           | (lift_wp,lift) ->
               let se =
                 {
                   FStar_Syntax_Syntax.sigel =
                     (FStar_Syntax_Syntax.Sig_sub_effect
                        {
                          FStar_Syntax_Syntax.source = src;
                          FStar_Syntax_Syntax.target = dst;
                          FStar_Syntax_Syntax.lift_wp = lift_wp;
                          FStar_Syntax_Syntax.lift = lift
                        });
                   FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
                   FStar_Syntax_Syntax.sigquals = [];
                   FStar_Syntax_Syntax.sigmeta =
                     FStar_Syntax_Syntax.default_sigmeta;
                   FStar_Syntax_Syntax.sigattrs = []
                 }  in
               (env, [se]))
      | FStar_Parser_AST.Splice (ids,t) ->
          let t1 = desugar_term env t  in
          let se =
            let uu____27811 =
              let uu____27812 =
                let uu____27819 =
                  FStar_List.map (FStar_Syntax_DsEnv.qualify env) ids  in
                (uu____27819, t1)  in
              FStar_Syntax_Syntax.Sig_splice uu____27812  in
            {
              FStar_Syntax_Syntax.sigel = uu____27811;
              FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
              FStar_Syntax_Syntax.sigquals = [];
              FStar_Syntax_Syntax.sigmeta =
                FStar_Syntax_Syntax.default_sigmeta;
              FStar_Syntax_Syntax.sigattrs = []
            }  in
          let env1 = FStar_Syntax_DsEnv.push_sigelt env se  in (env1, [se])

let (desugar_decls :
  env_t ->
    FStar_Parser_AST.decl Prims.list ->
      (env_t * FStar_Syntax_Syntax.sigelt Prims.list))
  =
  fun env  ->
    fun decls  ->
      let uu____27846 =
        FStar_List.fold_left
          (fun uu____27866  ->
             fun d  ->
               match uu____27866 with
               | (env1,sigelts) ->
                   let uu____27886 = desugar_decl env1 d  in
                   (match uu____27886 with
                    | (env2,se) -> (env2, (FStar_List.append sigelts se))))
          (env, []) decls
         in
      match uu____27846 with | (env1,sigelts) -> (env1, sigelts)
  
let (open_prims_all :
  (FStar_Parser_AST.decoration Prims.list -> FStar_Parser_AST.decl)
    Prims.list)
  =
  [FStar_Parser_AST.mk_decl
     (FStar_Parser_AST.Open FStar_Parser_Const.prims_lid)
     FStar_Range.dummyRange;
  FStar_Parser_AST.mk_decl (FStar_Parser_AST.Open FStar_Parser_Const.all_lid)
    FStar_Range.dummyRange]
  
let (desugar_modul_common :
  FStar_Syntax_Syntax.modul FStar_Pervasives_Native.option ->
    FStar_Syntax_DsEnv.env ->
      FStar_Parser_AST.modul ->
        (env_t * FStar_Syntax_Syntax.modul * Prims.bool))
  =
  fun curmod  ->
    fun env  ->
      fun m  ->
        let env1 =
          match (curmod, m) with
          | (FStar_Pervasives_Native.None ,uu____27977) -> env
          | (FStar_Pervasives_Native.Some
             { FStar_Syntax_Syntax.name = prev_lid;
               FStar_Syntax_Syntax.declarations = uu____27981;
               FStar_Syntax_Syntax.exports = uu____27982;
               FStar_Syntax_Syntax.is_interface = uu____27983;_},FStar_Parser_AST.Module
             (current_lid,uu____27985)) when
              (FStar_Ident.lid_equals prev_lid current_lid) &&
                (FStar_Options.interactive ())
              -> env
          | (FStar_Pervasives_Native.Some prev_mod,uu____27994) ->
              let uu____27997 =
                FStar_Syntax_DsEnv.finish_module_or_interface env prev_mod
                 in
              FStar_Pervasives_Native.fst uu____27997
           in
        let uu____28002 =
          match m with
          | FStar_Parser_AST.Interface (mname,decls,admitted) ->
              let uu____28044 =
                FStar_Syntax_DsEnv.prepare_module_or_interface true admitted
                  env1 mname FStar_Syntax_DsEnv.default_mii
                 in
              (uu____28044, mname, decls, true)
          | FStar_Parser_AST.Module (mname,decls) ->
              let uu____28066 =
                FStar_Syntax_DsEnv.prepare_module_or_interface false false
                  env1 mname FStar_Syntax_DsEnv.default_mii
                 in
              (uu____28066, mname, decls, false)
           in
        match uu____28002 with
        | ((env2,pop_when_done),mname,decls,intf) ->
            let uu____28108 = desugar_decls env2 decls  in
            (match uu____28108 with
             | (env3,sigelts) ->
                 let modul =
                   {
                     FStar_Syntax_Syntax.name = mname;
                     FStar_Syntax_Syntax.declarations = sigelts;
                     FStar_Syntax_Syntax.exports = [];
                     FStar_Syntax_Syntax.is_interface = intf
                   }  in
                 (env3, modul, pop_when_done))
  
let (as_interface : FStar_Parser_AST.modul -> FStar_Parser_AST.modul) =
  fun m  ->
    match m with
    | FStar_Parser_AST.Module (mname,decls) ->
        FStar_Parser_AST.Interface (mname, decls, true)
    | i -> i
  
let (desugar_partial_modul :
  FStar_Syntax_Syntax.modul FStar_Pervasives_Native.option ->
    env_t -> FStar_Parser_AST.modul -> (env_t * FStar_Syntax_Syntax.modul))
  =
  fun curmod  ->
    fun env  ->
      fun m  ->
        let m1 =
          let uu____28176 =
            (FStar_Options.interactive ()) &&
              (let uu____28179 =
                 let uu____28181 =
                   let uu____28183 = FStar_Options.file_list ()  in
                   FStar_List.hd uu____28183  in
                 FStar_Util.get_file_extension uu____28181  in
               FStar_List.mem uu____28179 ["fsti"; "fsi"])
             in
          if uu____28176 then as_interface m else m  in
        let uu____28197 = desugar_modul_common curmod env m1  in
        match uu____28197 with
        | (env1,modul,pop_when_done) ->
            if pop_when_done
            then
              let uu____28219 = FStar_Syntax_DsEnv.pop ()  in
              (uu____28219, modul)
            else (env1, modul)
  
let (desugar_modul :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.modul -> (env_t * FStar_Syntax_Syntax.modul))
  =
  fun env  ->
    fun m  ->
      let uu____28241 =
        desugar_modul_common FStar_Pervasives_Native.None env m  in
      match uu____28241 with
      | (env1,modul,pop_when_done) ->
          let uu____28258 =
            FStar_Syntax_DsEnv.finish_module_or_interface env1 modul  in
          (match uu____28258 with
           | (env2,modul1) ->
               ((let uu____28270 =
                   FStar_Options.dump_module
                     (modul1.FStar_Syntax_Syntax.name).FStar_Ident.str
                    in
                 if uu____28270
                 then
                   let uu____28273 =
                     FStar_Syntax_Print.modul_to_string modul1  in
                   FStar_Util.print1 "Module after desugaring:\n%s\n"
                     uu____28273
                 else ());
                (let uu____28278 =
                   if pop_when_done
                   then
                     FStar_Syntax_DsEnv.export_interface
                       modul1.FStar_Syntax_Syntax.name env2
                   else env2  in
                 (uu____28278, modul1))))
  
let with_options : 'a . (unit -> 'a) -> 'a =
  fun f  ->
    FStar_Options.push ();
    (let res = f ()  in
     let light = FStar_Options.ml_ish ()  in
     FStar_Options.pop ();
     if light then FStar_Options.set_ml_ish () else ();
     res)
  
let (ast_modul_to_modul :
  FStar_Parser_AST.modul ->
    FStar_Syntax_Syntax.modul FStar_Syntax_DsEnv.withenv)
  =
  fun modul  ->
    fun env  ->
      with_options
        (fun uu____28328  ->
           let uu____28329 = desugar_modul env modul  in
           match uu____28329 with | (e,m) -> (m, e))
  
let (decls_to_sigelts :
  FStar_Parser_AST.decl Prims.list ->
    FStar_Syntax_Syntax.sigelts FStar_Syntax_DsEnv.withenv)
  =
  fun decls  ->
    fun env  ->
      with_options
        (fun uu____28367  ->
           let uu____28368 = desugar_decls env decls  in
           match uu____28368 with | (env1,sigelts) -> (sigelts, env1))
  
let (partial_ast_modul_to_modul :
  FStar_Syntax_Syntax.modul FStar_Pervasives_Native.option ->
    FStar_Parser_AST.modul ->
      FStar_Syntax_Syntax.modul FStar_Syntax_DsEnv.withenv)
  =
  fun modul  ->
    fun a_modul  ->
      fun env  ->
        with_options
          (fun uu____28419  ->
             let uu____28420 = desugar_partial_modul modul env a_modul  in
             match uu____28420 with | (env1,modul1) -> (modul1, env1))
  
let (add_modul_to_env :
  FStar_Syntax_Syntax.modul ->
    FStar_Syntax_DsEnv.module_inclusion_info ->
      (FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term) ->
        unit FStar_Syntax_DsEnv.withenv)
  =
  fun m  ->
    fun mii  ->
      fun erase_univs  ->
        fun en  ->
          let erase_univs_ed ed =
            let erase_binders bs =
              match bs with
              | [] -> []
              | uu____28515 ->
                  let t =
                    let uu____28525 =
                      FStar_Syntax_Syntax.mk
                        (FStar_Syntax_Syntax.Tm_abs
                           (bs, FStar_Syntax_Syntax.t_unit,
                             FStar_Pervasives_Native.None))
                        FStar_Pervasives_Native.None FStar_Range.dummyRange
                       in
                    erase_univs uu____28525  in
                  let uu____28538 =
                    let uu____28539 = FStar_Syntax_Subst.compress t  in
                    uu____28539.FStar_Syntax_Syntax.n  in
                  (match uu____28538 with
                   | FStar_Syntax_Syntax.Tm_abs (bs1,uu____28551,uu____28552)
                       -> bs1
                   | uu____28577 -> failwith "Impossible")
               in
            let uu____28587 =
              let uu____28594 = erase_binders ed.FStar_Syntax_Syntax.binders
                 in
              FStar_Syntax_Subst.open_term' uu____28594
                FStar_Syntax_Syntax.t_unit
               in
            match uu____28587 with
            | (binders,uu____28596,binders_opening) ->
                let erase_term t =
                  let uu____28604 =
                    let uu____28605 =
                      FStar_Syntax_Subst.subst binders_opening t  in
                    erase_univs uu____28605  in
                  FStar_Syntax_Subst.close binders uu____28604  in
                let erase_tscheme uu____28623 =
                  match uu____28623 with
                  | (us,t) ->
                      let t1 =
                        let uu____28643 =
                          FStar_Syntax_Subst.shift_subst
                            (FStar_List.length us) binders_opening
                           in
                        FStar_Syntax_Subst.subst uu____28643 t  in
                      let uu____28646 =
                        let uu____28647 = erase_univs t1  in
                        FStar_Syntax_Subst.close binders uu____28647  in
                      ([], uu____28646)
                   in
                let erase_action action =
                  let opening =
                    FStar_Syntax_Subst.shift_subst
                      (FStar_List.length
                         action.FStar_Syntax_Syntax.action_univs)
                      binders_opening
                     in
                  let erased_action_params =
                    match action.FStar_Syntax_Syntax.action_params with
                    | [] -> []
                    | uu____28670 ->
                        let bs =
                          let uu____28680 =
                            FStar_Syntax_Subst.subst_binders opening
                              action.FStar_Syntax_Syntax.action_params
                             in
                          FStar_All.pipe_left erase_binders uu____28680  in
                        let t =
                          FStar_Syntax_Syntax.mk
                            (FStar_Syntax_Syntax.Tm_abs
                               (bs, FStar_Syntax_Syntax.t_unit,
                                 FStar_Pervasives_Native.None))
                            FStar_Pervasives_Native.None
                            FStar_Range.dummyRange
                           in
                        let uu____28720 =
                          let uu____28721 =
                            let uu____28724 =
                              FStar_Syntax_Subst.close binders t  in
                            FStar_Syntax_Subst.compress uu____28724  in
                          uu____28721.FStar_Syntax_Syntax.n  in
                        (match uu____28720 with
                         | FStar_Syntax_Syntax.Tm_abs
                             (bs1,uu____28726,uu____28727) -> bs1
                         | uu____28752 -> failwith "Impossible")
                     in
                  let erase_term1 t =
                    let uu____28760 =
                      let uu____28761 = FStar_Syntax_Subst.subst opening t
                         in
                      erase_univs uu____28761  in
                    FStar_Syntax_Subst.close binders uu____28760  in
                  let uu___3882_28762 = action  in
                  let uu____28763 =
                    erase_term1 action.FStar_Syntax_Syntax.action_defn  in
                  let uu____28764 =
                    erase_term1 action.FStar_Syntax_Syntax.action_typ  in
                  {
                    FStar_Syntax_Syntax.action_name =
                      (uu___3882_28762.FStar_Syntax_Syntax.action_name);
                    FStar_Syntax_Syntax.action_unqualified_name =
                      (uu___3882_28762.FStar_Syntax_Syntax.action_unqualified_name);
                    FStar_Syntax_Syntax.action_univs = [];
                    FStar_Syntax_Syntax.action_params = erased_action_params;
                    FStar_Syntax_Syntax.action_defn = uu____28763;
                    FStar_Syntax_Syntax.action_typ = uu____28764
                  }  in
                let uu___3884_28765 = ed  in
                let uu____28766 = FStar_Syntax_Subst.close_binders binders
                   in
                let uu____28767 = erase_term ed.FStar_Syntax_Syntax.signature
                   in
                let uu____28768 = erase_tscheme ed.FStar_Syntax_Syntax.ret_wp
                   in
                let uu____28769 =
                  erase_tscheme ed.FStar_Syntax_Syntax.bind_wp  in
                let uu____28770 =
                  erase_tscheme ed.FStar_Syntax_Syntax.if_then_else  in
                let uu____28771 = erase_tscheme ed.FStar_Syntax_Syntax.ite_wp
                   in
                let uu____28772 =
                  erase_tscheme ed.FStar_Syntax_Syntax.stronger  in
                let uu____28773 =
                  erase_tscheme ed.FStar_Syntax_Syntax.close_wp  in
                let uu____28774 =
                  erase_tscheme ed.FStar_Syntax_Syntax.trivial  in
                let uu____28775 = erase_term ed.FStar_Syntax_Syntax.repr  in
                let uu____28776 =
                  erase_tscheme ed.FStar_Syntax_Syntax.return_repr  in
                let uu____28777 =
                  erase_tscheme ed.FStar_Syntax_Syntax.bind_repr  in
                let uu____28778 =
                  FStar_List.map erase_action ed.FStar_Syntax_Syntax.actions
                   in
                {
                  FStar_Syntax_Syntax.cattributes =
                    (uu___3884_28765.FStar_Syntax_Syntax.cattributes);
                  FStar_Syntax_Syntax.mname =
                    (uu___3884_28765.FStar_Syntax_Syntax.mname);
                  FStar_Syntax_Syntax.univs = [];
                  FStar_Syntax_Syntax.binders = uu____28766;
                  FStar_Syntax_Syntax.signature = uu____28767;
                  FStar_Syntax_Syntax.ret_wp = uu____28768;
                  FStar_Syntax_Syntax.bind_wp = uu____28769;
                  FStar_Syntax_Syntax.if_then_else = uu____28770;
                  FStar_Syntax_Syntax.ite_wp = uu____28771;
                  FStar_Syntax_Syntax.stronger = uu____28772;
                  FStar_Syntax_Syntax.close_wp = uu____28773;
                  FStar_Syntax_Syntax.trivial = uu____28774;
                  FStar_Syntax_Syntax.repr = uu____28775;
                  FStar_Syntax_Syntax.return_repr = uu____28776;
                  FStar_Syntax_Syntax.bind_repr = uu____28777;
                  FStar_Syntax_Syntax.actions = uu____28778;
                  FStar_Syntax_Syntax.eff_attrs =
                    (uu___3884_28765.FStar_Syntax_Syntax.eff_attrs)
                }
             in
          let push_sigelt1 env se =
            match se.FStar_Syntax_Syntax.sigel with
            | FStar_Syntax_Syntax.Sig_new_effect ed ->
                let se' =
                  let uu___3891_28794 = se  in
                  let uu____28795 =
                    let uu____28796 = erase_univs_ed ed  in
                    FStar_Syntax_Syntax.Sig_new_effect uu____28796  in
                  {
                    FStar_Syntax_Syntax.sigel = uu____28795;
                    FStar_Syntax_Syntax.sigrng =
                      (uu___3891_28794.FStar_Syntax_Syntax.sigrng);
                    FStar_Syntax_Syntax.sigquals =
                      (uu___3891_28794.FStar_Syntax_Syntax.sigquals);
                    FStar_Syntax_Syntax.sigmeta =
                      (uu___3891_28794.FStar_Syntax_Syntax.sigmeta);
                    FStar_Syntax_Syntax.sigattrs =
                      (uu___3891_28794.FStar_Syntax_Syntax.sigattrs)
                  }  in
                let env1 = FStar_Syntax_DsEnv.push_sigelt env se'  in
                push_reflect_effect env1 se.FStar_Syntax_Syntax.sigquals
                  ed.FStar_Syntax_Syntax.mname se.FStar_Syntax_Syntax.sigrng
            | FStar_Syntax_Syntax.Sig_new_effect_for_free ed ->
                let se' =
                  let uu___3897_28800 = se  in
                  let uu____28801 =
                    let uu____28802 = erase_univs_ed ed  in
                    FStar_Syntax_Syntax.Sig_new_effect_for_free uu____28802
                     in
                  {
                    FStar_Syntax_Syntax.sigel = uu____28801;
                    FStar_Syntax_Syntax.sigrng =
                      (uu___3897_28800.FStar_Syntax_Syntax.sigrng);
                    FStar_Syntax_Syntax.sigquals =
                      (uu___3897_28800.FStar_Syntax_Syntax.sigquals);
                    FStar_Syntax_Syntax.sigmeta =
                      (uu___3897_28800.FStar_Syntax_Syntax.sigmeta);
                    FStar_Syntax_Syntax.sigattrs =
                      (uu___3897_28800.FStar_Syntax_Syntax.sigattrs)
                  }  in
                let env1 = FStar_Syntax_DsEnv.push_sigelt env se'  in
                push_reflect_effect env1 se.FStar_Syntax_Syntax.sigquals
                  ed.FStar_Syntax_Syntax.mname se.FStar_Syntax_Syntax.sigrng
            | uu____28804 -> FStar_Syntax_DsEnv.push_sigelt env se  in
          let uu____28805 =
            FStar_Syntax_DsEnv.prepare_module_or_interface false false en
              m.FStar_Syntax_Syntax.name mii
             in
          match uu____28805 with
          | (en1,pop_when_done) ->
              let en2 =
                let uu____28822 =
                  FStar_Syntax_DsEnv.set_current_module en1
                    m.FStar_Syntax_Syntax.name
                   in
                FStar_List.fold_left push_sigelt1 uu____28822
                  m.FStar_Syntax_Syntax.exports
                 in
              let env = FStar_Syntax_DsEnv.finish en2 m  in
              let uu____28824 =
                if pop_when_done
                then
                  FStar_Syntax_DsEnv.export_interface
                    m.FStar_Syntax_Syntax.name env
                else env  in
              ((), uu____28824)
  