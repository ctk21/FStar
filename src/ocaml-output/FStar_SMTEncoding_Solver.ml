open Prims
type z3_replay_result =
  (FStar_SMTEncoding_Z3.unsat_core,FStar_SMTEncoding_Term.error_labels)
    FStar_Util.either
let z3_result_as_replay_result :
  'Auu____35 'Auu____36 'Auu____37 .
    ('Auu____35,('Auu____36 * 'Auu____37)) FStar_Util.either ->
      ('Auu____35,'Auu____36) FStar_Util.either
  =
  fun uu___0_54  ->
    match uu___0_54 with
    | FStar_Util.Inl l -> FStar_Util.Inl l
    | FStar_Util.Inr (r,uu____69) -> FStar_Util.Inr r
  
let (recorded_hints :
  FStar_Util.hints FStar_Pervasives_Native.option FStar_ST.ref) =
  FStar_Util.mk_ref FStar_Pervasives_Native.None 
let (replaying_hints :
  FStar_Util.hints FStar_Pervasives_Native.option FStar_ST.ref) =
  FStar_Util.mk_ref FStar_Pervasives_Native.None 
let (format_hints_file_name : Prims.string -> Prims.string) =
  fun src_filename  -> FStar_Util.format1 "%s.hints" src_filename 
let initialize_hints_db : 'Auu____105 . Prims.string -> 'Auu____105 -> unit =
  fun src_filename  ->
    fun format_filename  ->
      (let uu____119 = FStar_Options.record_hints ()  in
       if uu____119
       then
         FStar_ST.op_Colon_Equals recorded_hints
           (FStar_Pervasives_Native.Some [])
       else ());
      (let uu____149 = FStar_Options.use_hints ()  in
       if uu____149
       then
         let norm_src_filename = FStar_Util.normalize_file_path src_filename
            in
         let val_filename =
           let uu____156 = FStar_Options.hint_file ()  in
           match uu____156 with
           | FStar_Pervasives_Native.Some fn -> fn
           | FStar_Pervasives_Native.None  ->
               format_hints_file_name norm_src_filename
            in
         let uu____165 = FStar_Util.read_hints val_filename  in
         match uu____165 with
         | FStar_Pervasives_Native.Some hints ->
             let expected_digest =
               FStar_Util.digest_of_file norm_src_filename  in
             ((let uu____172 = FStar_Options.hint_info ()  in
               if uu____172
               then
                 let uu____175 =
                   let uu____177 = FStar_Options.hint_file ()  in
                   match uu____177 with
                   | FStar_Pervasives_Native.Some fn ->
                       Prims.op_Hat " from '" (Prims.op_Hat val_filename "'")
                   | uu____187 -> ""  in
                 FStar_Util.print3 "(%s) digest is %s%s.\n" norm_src_filename
                   (if hints.FStar_Util.module_digest = expected_digest
                    then "valid; using hints"
                    else "invalid; using potentially stale hints") uu____175
               else ());
              FStar_ST.op_Colon_Equals replaying_hints
                (FStar_Pervasives_Native.Some (hints.FStar_Util.hints)))
         | FStar_Pervasives_Native.None  ->
             let uu____225 = FStar_Options.hint_info ()  in
             (if uu____225
              then
                FStar_Util.print1 "(%s) Unable to read hint file.\n"
                  norm_src_filename
              else ())
       else ())
  
let (finalize_hints_db : Prims.string -> unit) =
  fun src_filename  ->
    (let uu____242 = FStar_Options.record_hints ()  in
     if uu____242
     then
       let hints =
         let uu____246 = FStar_ST.op_Bang recorded_hints  in
         FStar_Option.get uu____246  in
       let hints_db =
         let uu____273 = FStar_Util.digest_of_file src_filename  in
         { FStar_Util.module_digest = uu____273; FStar_Util.hints = hints }
          in
       let norm_src_filename = FStar_Util.normalize_file_path src_filename
          in
       let val_filename =
         let uu____279 = FStar_Options.hint_file ()  in
         match uu____279 with
         | FStar_Pervasives_Native.Some fn -> fn
         | FStar_Pervasives_Native.None  ->
             format_hints_file_name norm_src_filename
          in
       FStar_Util.write_hints val_filename hints_db
     else ());
    FStar_ST.op_Colon_Equals recorded_hints FStar_Pervasives_Native.None;
    FStar_ST.op_Colon_Equals replaying_hints FStar_Pervasives_Native.None
  
let with_hints_db : 'a . Prims.string -> (unit -> 'a) -> 'a =
  fun fname  ->
    fun f  ->
      initialize_hints_db fname false;
      (let result = f ()  in finalize_hints_db fname; result)
  
let (filter_using_facts_from :
  FStar_TypeChecker_Env.env ->
    FStar_SMTEncoding_Term.decl Prims.list ->
      FStar_SMTEncoding_Term.decl Prims.list)
  =
  fun e  ->
    fun theory  ->
      let matches_fact_ids include_assumption_names a =
        match a.FStar_SMTEncoding_Term.assumption_fact_ids with
        | [] -> true
        | uu____404 ->
            (FStar_All.pipe_right
               a.FStar_SMTEncoding_Term.assumption_fact_ids
               (FStar_Util.for_some
                  (fun uu___1_412  ->
                     match uu___1_412 with
                     | FStar_SMTEncoding_Term.Name lid ->
                         FStar_TypeChecker_Env.should_enc_lid e lid
                     | uu____415 -> false)))
              ||
              (let uu____418 =
                 FStar_Util.smap_try_find include_assumption_names
                   a.FStar_SMTEncoding_Term.assumption_name
                  in
               FStar_Option.isSome uu____418)
         in
      let theory_rev = FStar_List.rev theory  in
      let pruned_theory =
        let include_assumption_names =
          FStar_Util.smap_create (Prims.of_int (10000))  in
        let keep_decl uu___2_442 =
          match uu___2_442 with
          | FStar_SMTEncoding_Term.Assume a ->
              matches_fact_ids include_assumption_names a
          | FStar_SMTEncoding_Term.RetainAssumptions names1 ->
              (FStar_List.iter
                 (fun x  ->
                    FStar_Util.smap_add include_assumption_names x true)
                 names1;
               true)
          | FStar_SMTEncoding_Term.Module uu____457 ->
              failwith
                "Solver.fs::keep_decl should never have been called with a Module decl"
          | uu____467 -> true  in
        FStar_List.fold_left
          (fun out  ->
             fun d  ->
               match d with
               | FStar_SMTEncoding_Term.Module (name,decls) ->
                   let uu____490 =
                     FStar_All.pipe_right decls (FStar_List.filter keep_decl)
                      in
                   FStar_All.pipe_right uu____490
                     (fun decls1  ->
                        (FStar_SMTEncoding_Term.Module (name, decls1)) :: out)
               | uu____508 ->
                   let uu____509 = keep_decl d  in
                   if uu____509 then d :: out else out) [] theory_rev
         in
      pruned_theory
  
let rec (filter_assertions_with_stats :
  FStar_TypeChecker_Env.env ->
    FStar_SMTEncoding_Z3.unsat_core ->
      FStar_SMTEncoding_Term.decl Prims.list ->
        (FStar_SMTEncoding_Term.decl Prims.list * Prims.bool * Prims.int *
          Prims.int))
  =
  fun e  ->
    fun core  ->
      fun theory  ->
        match core with
        | FStar_Pervasives_Native.None  ->
            let uu____565 = filter_using_facts_from e theory  in
            (uu____565, false, Prims.int_zero, Prims.int_zero)
        | FStar_Pervasives_Native.Some core1 ->
            let theory_rev = FStar_List.rev theory  in
            let uu____586 =
              let uu____597 =
                let uu____608 =
                  let uu____611 =
                    let uu____612 =
                      let uu____614 =
                        FStar_All.pipe_right core1 (FStar_String.concat ", ")
                         in
                      Prims.op_Hat "UNSAT CORE: " uu____614  in
                    FStar_SMTEncoding_Term.Caption uu____612  in
                  [uu____611]  in
                (uu____608, Prims.int_zero, Prims.int_zero)  in
              FStar_List.fold_left
                (fun uu____644  ->
                   fun d  ->
                     match uu____644 with
                     | (theory1,n_retained,n_pruned) ->
                         (match d with
                          | FStar_SMTEncoding_Term.Assume a ->
                              if
                                FStar_List.contains
                                  a.FStar_SMTEncoding_Term.assumption_name
                                  core1
                              then
                                ((d :: theory1),
                                  (n_retained + Prims.int_one), n_pruned)
                              else
                                if
                                  FStar_Util.starts_with
                                    a.FStar_SMTEncoding_Term.assumption_name
                                    "@"
                                then ((d :: theory1), n_retained, n_pruned)
                                else
                                  (theory1, n_retained,
                                    (n_pruned + Prims.int_one))
                          | FStar_SMTEncoding_Term.Module (name,decls) ->
                              let uu____738 =
                                FStar_All.pipe_right decls
                                  (filter_assertions_with_stats e
                                     (FStar_Pervasives_Native.Some core1))
                                 in
                              FStar_All.pipe_right uu____738
                                (fun uu____798  ->
                                   match uu____798 with
                                   | (decls1,uu____823,r,p) ->
                                       (((FStar_SMTEncoding_Term.Module
                                            (name, decls1)) :: theory1),
                                         (n_retained + r), (n_pruned + p)))
                          | uu____843 ->
                              ((d :: theory1), n_retained, n_pruned)))
                uu____597 theory_rev
               in
            (match uu____586 with
             | (theory',n_retained,n_pruned) ->
                 (theory', true, n_retained, n_pruned))
  
let (filter_assertions :
  FStar_TypeChecker_Env.env ->
    FStar_SMTEncoding_Z3.unsat_core ->
      FStar_SMTEncoding_Term.decl Prims.list ->
        (FStar_SMTEncoding_Term.decl Prims.list * Prims.bool))
  =
  fun e  ->
    fun core  ->
      fun theory  ->
        let uu____905 = filter_assertions_with_stats e core theory  in
        match uu____905 with
        | (theory1,b,uu____928,uu____929) -> (theory1, b)
  
let (filter_facts_without_core :
  FStar_TypeChecker_Env.env ->
    FStar_SMTEncoding_Term.decl Prims.list ->
      (FStar_SMTEncoding_Term.decl Prims.list * Prims.bool))
  =
  fun e  ->
    fun x  ->
      let uu____965 = filter_using_facts_from e x  in (uu____965, false)
  
type errors =
  {
  error_reason: Prims.string ;
  error_fuel: Prims.int ;
  error_ifuel: Prims.int ;
  error_hint: Prims.string Prims.list FStar_Pervasives_Native.option ;
  error_messages:
    (FStar_Errors.raw_error * Prims.string * FStar_Range.range) Prims.list }
let (__proj__Mkerrors__item__error_reason : errors -> Prims.string) =
  fun projectee  ->
    match projectee with
    | { error_reason; error_fuel; error_ifuel; error_hint; error_messages;_}
        -> error_reason
  
let (__proj__Mkerrors__item__error_fuel : errors -> Prims.int) =
  fun projectee  ->
    match projectee with
    | { error_reason; error_fuel; error_ifuel; error_hint; error_messages;_}
        -> error_fuel
  
let (__proj__Mkerrors__item__error_ifuel : errors -> Prims.int) =
  fun projectee  ->
    match projectee with
    | { error_reason; error_fuel; error_ifuel; error_hint; error_messages;_}
        -> error_ifuel
  
let (__proj__Mkerrors__item__error_hint :
  errors -> Prims.string Prims.list FStar_Pervasives_Native.option) =
  fun projectee  ->
    match projectee with
    | { error_reason; error_fuel; error_ifuel; error_hint; error_messages;_}
        -> error_hint
  
let (__proj__Mkerrors__item__error_messages :
  errors ->
    (FStar_Errors.raw_error * Prims.string * FStar_Range.range) Prims.list)
  =
  fun projectee  ->
    match projectee with
    | { error_reason; error_fuel; error_ifuel; error_hint; error_messages;_}
        -> error_messages
  
let (error_to_short_string : errors -> Prims.string) =
  fun err  ->
    let uu____1195 = FStar_Util.string_of_int err.error_fuel  in
    let uu____1197 = FStar_Util.string_of_int err.error_ifuel  in
    FStar_Util.format4 "%s (fuel=%s; ifuel=%s%s)" err.error_reason uu____1195
      uu____1197
      (if FStar_Option.isSome err.error_hint then "; with hint" else "")
  
let (error_to_is_timeout : errors -> Prims.string Prims.list) =
  fun err  ->
    if FStar_Util.ends_with err.error_reason "canceled"
    then
      let uu____1223 =
        let uu____1225 = FStar_Util.string_of_int err.error_fuel  in
        let uu____1227 = FStar_Util.string_of_int err.error_ifuel  in
        FStar_Util.format4 "timeout (fuel=%s; ifuel=%s; %s)" err.error_reason
          uu____1225 uu____1227
          (if FStar_Option.isSome err.error_hint then "with hint" else "")
         in
      [uu____1223]
    else []
  
type query_settings =
  {
  query_env: FStar_TypeChecker_Env.env ;
  query_decl: FStar_SMTEncoding_Term.decl ;
  query_name: Prims.string ;
  query_index: Prims.int ;
  query_range: FStar_Range.range ;
  query_fuel: Prims.int ;
  query_ifuel: Prims.int ;
  query_rlimit: Prims.int ;
  query_hint: FStar_SMTEncoding_Z3.unsat_core ;
  query_errors: errors Prims.list ;
  query_all_labels: FStar_SMTEncoding_Term.error_labels ;
  query_suffix: FStar_SMTEncoding_Term.decl Prims.list ;
  query_hash: Prims.string FStar_Pervasives_Native.option }
let (__proj__Mkquery_settings__item__query_env :
  query_settings -> FStar_TypeChecker_Env.env) =
  fun projectee  ->
    match projectee with
    | { query_env; query_decl; query_name; query_index; query_range;
        query_fuel; query_ifuel; query_rlimit; query_hint; query_errors;
        query_all_labels; query_suffix; query_hash;_} -> query_env
  
let (__proj__Mkquery_settings__item__query_decl :
  query_settings -> FStar_SMTEncoding_Term.decl) =
  fun projectee  ->
    match projectee with
    | { query_env; query_decl; query_name; query_index; query_range;
        query_fuel; query_ifuel; query_rlimit; query_hint; query_errors;
        query_all_labels; query_suffix; query_hash;_} -> query_decl
  
let (__proj__Mkquery_settings__item__query_name :
  query_settings -> Prims.string) =
  fun projectee  ->
    match projectee with
    | { query_env; query_decl; query_name; query_index; query_range;
        query_fuel; query_ifuel; query_rlimit; query_hint; query_errors;
        query_all_labels; query_suffix; query_hash;_} -> query_name
  
let (__proj__Mkquery_settings__item__query_index :
  query_settings -> Prims.int) =
  fun projectee  ->
    match projectee with
    | { query_env; query_decl; query_name; query_index; query_range;
        query_fuel; query_ifuel; query_rlimit; query_hint; query_errors;
        query_all_labels; query_suffix; query_hash;_} -> query_index
  
let (__proj__Mkquery_settings__item__query_range :
  query_settings -> FStar_Range.range) =
  fun projectee  ->
    match projectee with
    | { query_env; query_decl; query_name; query_index; query_range;
        query_fuel; query_ifuel; query_rlimit; query_hint; query_errors;
        query_all_labels; query_suffix; query_hash;_} -> query_range
  
let (__proj__Mkquery_settings__item__query_fuel :
  query_settings -> Prims.int) =
  fun projectee  ->
    match projectee with
    | { query_env; query_decl; query_name; query_index; query_range;
        query_fuel; query_ifuel; query_rlimit; query_hint; query_errors;
        query_all_labels; query_suffix; query_hash;_} -> query_fuel
  
let (__proj__Mkquery_settings__item__query_ifuel :
  query_settings -> Prims.int) =
  fun projectee  ->
    match projectee with
    | { query_env; query_decl; query_name; query_index; query_range;
        query_fuel; query_ifuel; query_rlimit; query_hint; query_errors;
        query_all_labels; query_suffix; query_hash;_} -> query_ifuel
  
let (__proj__Mkquery_settings__item__query_rlimit :
  query_settings -> Prims.int) =
  fun projectee  ->
    match projectee with
    | { query_env; query_decl; query_name; query_index; query_range;
        query_fuel; query_ifuel; query_rlimit; query_hint; query_errors;
        query_all_labels; query_suffix; query_hash;_} -> query_rlimit
  
let (__proj__Mkquery_settings__item__query_hint :
  query_settings -> FStar_SMTEncoding_Z3.unsat_core) =
  fun projectee  ->
    match projectee with
    | { query_env; query_decl; query_name; query_index; query_range;
        query_fuel; query_ifuel; query_rlimit; query_hint; query_errors;
        query_all_labels; query_suffix; query_hash;_} -> query_hint
  
let (__proj__Mkquery_settings__item__query_errors :
  query_settings -> errors Prims.list) =
  fun projectee  ->
    match projectee with
    | { query_env; query_decl; query_name; query_index; query_range;
        query_fuel; query_ifuel; query_rlimit; query_hint; query_errors;
        query_all_labels; query_suffix; query_hash;_} -> query_errors
  
let (__proj__Mkquery_settings__item__query_all_labels :
  query_settings -> FStar_SMTEncoding_Term.error_labels) =
  fun projectee  ->
    match projectee with
    | { query_env; query_decl; query_name; query_index; query_range;
        query_fuel; query_ifuel; query_rlimit; query_hint; query_errors;
        query_all_labels; query_suffix; query_hash;_} -> query_all_labels
  
let (__proj__Mkquery_settings__item__query_suffix :
  query_settings -> FStar_SMTEncoding_Term.decl Prims.list) =
  fun projectee  ->
    match projectee with
    | { query_env; query_decl; query_name; query_index; query_range;
        query_fuel; query_ifuel; query_rlimit; query_hint; query_errors;
        query_all_labels; query_suffix; query_hash;_} -> query_suffix
  
let (__proj__Mkquery_settings__item__query_hash :
  query_settings -> Prims.string FStar_Pervasives_Native.option) =
  fun projectee  ->
    match projectee with
    | { query_env; query_decl; query_name; query_index; query_range;
        query_fuel; query_ifuel; query_rlimit; query_hint; query_errors;
        query_all_labels; query_suffix; query_hash;_} -> query_hash
  
let (with_fuel_and_diagnostics :
  query_settings ->
    FStar_SMTEncoding_Term.decl Prims.list ->
      FStar_SMTEncoding_Term.decl Prims.list)
  =
  fun settings  ->
    fun label_assumptions  ->
      let n1 = settings.query_fuel  in
      let i = settings.query_ifuel  in
      let rlimit = settings.query_rlimit  in
      let uu____1771 =
        let uu____1774 =
          let uu____1775 =
            let uu____1777 = FStar_Util.string_of_int n1  in
            let uu____1779 = FStar_Util.string_of_int i  in
            FStar_Util.format2 "<fuel='%s' ifuel='%s'>" uu____1777 uu____1779
             in
          FStar_SMTEncoding_Term.Caption uu____1775  in
        let uu____1782 =
          let uu____1785 =
            let uu____1786 =
              let uu____1794 =
                let uu____1795 =
                  let uu____1800 =
                    FStar_SMTEncoding_Util.mkApp ("MaxFuel", [])  in
                  let uu____1805 = FStar_SMTEncoding_Term.n_fuel n1  in
                  (uu____1800, uu____1805)  in
                FStar_SMTEncoding_Util.mkEq uu____1795  in
              (uu____1794, FStar_Pervasives_Native.None,
                "@MaxFuel_assumption")
               in
            FStar_SMTEncoding_Util.mkAssume uu____1786  in
          let uu____1809 =
            let uu____1812 =
              let uu____1813 =
                let uu____1821 =
                  let uu____1822 =
                    let uu____1827 =
                      FStar_SMTEncoding_Util.mkApp ("MaxIFuel", [])  in
                    let uu____1832 = FStar_SMTEncoding_Term.n_fuel i  in
                    (uu____1827, uu____1832)  in
                  FStar_SMTEncoding_Util.mkEq uu____1822  in
                (uu____1821, FStar_Pervasives_Native.None,
                  "@MaxIFuel_assumption")
                 in
              FStar_SMTEncoding_Util.mkAssume uu____1813  in
            [uu____1812; settings.query_decl]  in
          uu____1785 :: uu____1809  in
        uu____1774 :: uu____1782  in
      let uu____1836 =
        let uu____1839 =
          let uu____1842 =
            let uu____1845 =
              let uu____1846 =
                let uu____1853 = FStar_Util.string_of_int rlimit  in
                ("rlimit", uu____1853)  in
              FStar_SMTEncoding_Term.SetOption uu____1846  in
            [uu____1845;
            FStar_SMTEncoding_Term.CheckSat;
            FStar_SMTEncoding_Term.SetOption ("rlimit", "0");
            FStar_SMTEncoding_Term.GetReasonUnknown;
            FStar_SMTEncoding_Term.GetUnsatCore]  in
          let uu____1862 =
            let uu____1865 =
              let uu____1868 =
                (FStar_Options.print_z3_statistics ()) ||
                  (FStar_Options.query_stats ())
                 in
              if uu____1868
              then [FStar_SMTEncoding_Term.GetStatistics]
              else []  in
            FStar_List.append uu____1865 settings.query_suffix  in
          FStar_List.append uu____1842 uu____1862  in
        FStar_List.append label_assumptions uu____1839  in
      FStar_List.append uu____1771 uu____1836
  
let (used_hint : query_settings -> Prims.bool) =
  fun s  -> FStar_Option.isSome s.query_hint 
let (get_hint_for :
  Prims.string -> Prims.int -> FStar_Util.hint FStar_Pervasives_Native.option)
  =
  fun qname  ->
    fun qindex  ->
      let uu____1902 = FStar_ST.op_Bang replaying_hints  in
      match uu____1902 with
      | FStar_Pervasives_Native.Some hints ->
          FStar_Util.find_map hints
            (fun uu___3_1935  ->
               match uu___3_1935 with
               | FStar_Pervasives_Native.Some hint when
                   (hint.FStar_Util.hint_name = qname) &&
                     (hint.FStar_Util.hint_index = qindex)
                   -> FStar_Pervasives_Native.Some hint
               | uu____1943 -> FStar_Pervasives_Native.None)
      | uu____1946 -> FStar_Pervasives_Native.None
  
let (query_errors :
  query_settings ->
    FStar_SMTEncoding_Z3.z3result -> errors FStar_Pervasives_Native.option)
  =
  fun settings  ->
    fun z3result  ->
      match z3result.FStar_SMTEncoding_Z3.z3result_status with
      | FStar_SMTEncoding_Z3.UNSAT uu____1964 -> FStar_Pervasives_Native.None
      | uu____1965 ->
          let uu____1966 =
            FStar_SMTEncoding_Z3.status_string_and_errors
              z3result.FStar_SMTEncoding_Z3.z3result_status
             in
          (match uu____1966 with
           | (msg,error_labels) ->
               let err =
                 let uu____1979 =
                   FStar_List.map
                     (fun uu____2007  ->
                        match uu____2007 with
                        | (uu____2022,x,y) ->
                            (FStar_Errors.Error_Z3SolverError, x, y))
                     error_labels
                    in
                 {
                   error_reason = msg;
                   error_fuel = (settings.query_fuel);
                   error_ifuel = (settings.query_ifuel);
                   error_hint = (settings.query_hint);
                   error_messages = uu____1979
                 }  in
               FStar_Pervasives_Native.Some err)
  
let (detail_hint_replay :
  query_settings -> FStar_SMTEncoding_Z3.z3result -> unit) =
  fun settings  ->
    fun z3result  ->
      let uu____2039 =
        (used_hint settings) && (FStar_Options.detail_hint_replay ())  in
      if uu____2039
      then
        match z3result.FStar_SMTEncoding_Z3.z3result_status with
        | FStar_SMTEncoding_Z3.UNSAT uu____2042 -> ()
        | _failed ->
            let ask_z3 label_assumptions =
              let res = FStar_Util.mk_ref FStar_Pervasives_Native.None  in
              (let uu____2062 =
                 with_fuel_and_diagnostics settings label_assumptions  in
               FStar_SMTEncoding_Z3.ask settings.query_range
                 (filter_assertions settings.query_env settings.query_hint)
                 settings.query_hash settings.query_all_labels uu____2062
                 FStar_Pervasives_Native.None
                 (fun r  ->
                    FStar_ST.op_Colon_Equals res
                      (FStar_Pervasives_Native.Some r)) false);
              (let uu____2091 = FStar_ST.op_Bang res  in
               FStar_Option.get uu____2091)
               in
            FStar_SMTEncoding_ErrorReporting.detail_errors true
              settings.query_env settings.query_all_labels ask_z3
      else ()
  
let (find_localized_errors :
  errors Prims.list -> errors FStar_Pervasives_Native.option) =
  fun errs  ->
    FStar_All.pipe_right errs
      (FStar_List.tryFind
         (fun err  ->
            match err.error_messages with | [] -> false | uu____2147 -> true))
  
let (has_localized_errors : errors Prims.list -> Prims.bool) =
  fun errs  ->
    let uu____2169 = find_localized_errors errs  in
    FStar_Option.isSome uu____2169
  
let (report_errors : query_settings -> unit) =
  fun settings  ->
    let format_smt_error msg =
      FStar_Util.format1
        "SMT solver says:\n\t%s;\n\tNote: 'canceled' or 'resource limits reached' means the SMT query timed out, so you might want to increase the rlimit;\n\t'incomplete quantifiers' means a (partial) counterexample was found, so try to spell your proof out in greater detail, increase fuel or ifuel\n\t'unknown' means Z3 provided no further reason for the proof failing"
        msg
       in
    (let smt_error =
       let uu____2196 = FStar_Options.query_stats ()  in
       if uu____2196
       then
         let uu____2205 =
           let uu____2207 =
             let uu____2209 =
               FStar_All.pipe_right settings.query_errors
                 (FStar_List.map error_to_short_string)
                in
             FStar_All.pipe_right uu____2209 (FStar_String.concat ";\n\t")
              in
           FStar_All.pipe_right uu____2207 format_smt_error  in
         FStar_All.pipe_right uu____2205 (fun _2235  -> FStar_Util.Inr _2235)
       else
         (let uu____2238 =
            FStar_List.fold_left
              (fun uu____2263  ->
                 fun err  ->
                   match uu____2263 with
                   | (ic,cc,uc) ->
                       let err1 =
                         FStar_Util.substring_from err.error_reason
                           (FStar_String.length "unknown because ")
                          in
                       if
                         ((FStar_Util.starts_with err1 "canceled") ||
                            (FStar_Util.starts_with err1 "(resource"))
                           || (FStar_Util.starts_with err1 "timeout")
                       then (ic, (cc + Prims.int_one), uc)
                       else
                         if FStar_Util.starts_with err1 "(incomplete"
                         then ((ic + Prims.int_one), cc, uc)
                         else (ic, cc, (uc + Prims.int_one)))
              (Prims.int_zero, Prims.int_zero, Prims.int_zero)
              settings.query_errors
             in
          match uu____2238 with
          | (incomplete_count,canceled_count,unknown_count) ->
              FStar_All.pipe_right
                (match (incomplete_count, canceled_count, unknown_count) with
                 | (uu____2368,_2373,_2374) when
                     ((_2373 = Prims.int_zero) && (_2374 = Prims.int_zero))
                       && (incomplete_count > Prims.int_zero)
                     ->
                     "The solver found a (partial) counterexample, try to spell your proof in more detail or increase fuel/ifuel"
                 | (_2381,uu____2377,_2383) when
                     ((_2381 = Prims.int_zero) && (_2383 = Prims.int_zero))
                       && (canceled_count > Prims.int_zero)
                     ->
                     "The SMT query timed out, you might want to increase the rlimit"
                 | (uu____2386,uu____2387,uu____2388) ->
                     "Try with --query_stats to get more details")
                (fun _2398  -> FStar_Util.Inl _2398))
        in
     let uu____2399 = find_localized_errors settings.query_errors  in
     match uu____2399 with
     | FStar_Pervasives_Native.Some err ->
         FStar_TypeChecker_Err.add_errors_smt_detail settings.query_env
           err.error_messages smt_error
     | FStar_Pervasives_Native.None  ->
         FStar_TypeChecker_Err.add_errors_smt_detail settings.query_env
           [(FStar_Errors.Error_UnknownFatal_AssertionFailure,
              "Unknown assertion failed", (settings.query_range))] smt_error);
    (let uu____2419 = FStar_Options.detail_errors ()  in
     if uu____2419
     then
       let initial_fuel1 =
         let uu___262_2423 = settings  in
         let uu____2424 = FStar_Options.initial_fuel ()  in
         let uu____2426 = FStar_Options.initial_ifuel ()  in
         {
           query_env = (uu___262_2423.query_env);
           query_decl = (uu___262_2423.query_decl);
           query_name = (uu___262_2423.query_name);
           query_index = (uu___262_2423.query_index);
           query_range = (uu___262_2423.query_range);
           query_fuel = uu____2424;
           query_ifuel = uu____2426;
           query_rlimit = (uu___262_2423.query_rlimit);
           query_hint = FStar_Pervasives_Native.None;
           query_errors = (uu___262_2423.query_errors);
           query_all_labels = (uu___262_2423.query_all_labels);
           query_suffix = (uu___262_2423.query_suffix);
           query_hash = (uu___262_2423.query_hash)
         }  in
       let ask_z3 label_assumptions =
         let res = FStar_Util.mk_ref FStar_Pervasives_Native.None  in
         (let uu____2449 =
            with_fuel_and_diagnostics initial_fuel1 label_assumptions  in
          FStar_SMTEncoding_Z3.ask settings.query_range
            (filter_facts_without_core settings.query_env)
            settings.query_hash settings.query_all_labels uu____2449
            FStar_Pervasives_Native.None
            (fun r  ->
               FStar_ST.op_Colon_Equals res (FStar_Pervasives_Native.Some r))
            false);
         (let uu____2478 = FStar_ST.op_Bang res  in
          FStar_Option.get uu____2478)
          in
       FStar_SMTEncoding_ErrorReporting.detail_errors false
         settings.query_env settings.query_all_labels ask_z3
     else ())
  
let (query_info : query_settings -> FStar_SMTEncoding_Z3.z3result -> unit) =
  fun settings  ->
    fun z3result  ->
      let process_unsat_core core =
        let accumulator uu____2543 =
          let r = FStar_Util.mk_ref []  in
          let uu____2554 =
            let module_names = FStar_Util.mk_ref []  in
            ((fun m  ->
                let ms = FStar_ST.op_Bang module_names  in
                if FStar_List.contains m ms
                then ()
                else FStar_ST.op_Colon_Equals module_names (m :: ms)),
              (fun uu____2654  ->
                 let uu____2655 = FStar_ST.op_Bang module_names  in
                 FStar_All.pipe_right uu____2655
                   (FStar_Util.sort_with FStar_String.compare)))
             in
          match uu____2554 with | (add1,get1) -> (add1, get1)  in
        let uu____2737 = accumulator ()  in
        match uu____2737 with
        | (add_module_name,get_module_names) ->
            let uu____2774 = accumulator ()  in
            (match uu____2774 with
             | (add_discarded_name,get_discarded_names) ->
                 let parse_axiom_name s =
                   let chars = FStar_String.list_of_string s  in
                   let first_upper_index =
                     FStar_Util.try_find_index FStar_Util.is_upper chars  in
                   match first_upper_index with
                   | FStar_Pervasives_Native.None  ->
                       (add_discarded_name s; [])
                   | FStar_Pervasives_Native.Some first_upper_index1 ->
                       let name_and_suffix =
                         FStar_Util.substring_from s first_upper_index1  in
                       let components =
                         FStar_String.split [46] name_and_suffix  in
                       let excluded_suffixes =
                         ["fuel_instrumented";
                         "_pretyping";
                         "_Tm_refine";
                         "_Tm_abs";
                         "@";
                         "_interpretation_Tm_arrow";
                         "MaxFuel_assumption";
                         "MaxIFuel_assumption"]  in
                       let exclude_suffix s1 =
                         let s2 = FStar_Util.trim_string s1  in
                         let sopt =
                           FStar_Util.find_map excluded_suffixes
                             (fun sfx  ->
                                if FStar_Util.contains s2 sfx
                                then
                                  let uu____2897 =
                                    FStar_List.hd (FStar_Util.split s2 sfx)
                                     in
                                  FStar_Pervasives_Native.Some uu____2897
                                else FStar_Pervasives_Native.None)
                            in
                         match sopt with
                         | FStar_Pervasives_Native.None  ->
                             if s2 = "" then [] else [s2]
                         | FStar_Pervasives_Native.Some s3 ->
                             if s3 = "" then [] else [s3]
                          in
                       let components1 =
                         match components with
                         | [] -> []
                         | uu____2942 ->
                             let uu____2946 = FStar_Util.prefix components
                                in
                             (match uu____2946 with
                              | (module_name,last1) ->
                                  let components1 =
                                    let uu____2973 = exclude_suffix last1  in
                                    FStar_List.append module_name uu____2973
                                     in
                                  ((match components1 with
                                    | [] -> ()
                                    | uu____2980::[] -> ()
                                    | uu____2984 ->
                                        add_module_name
                                          (FStar_String.concat "."
                                             module_name));
                                   components1))
                          in
                       if components1 = []
                       then (add_discarded_name s; [])
                       else
                         (let uu____3001 =
                            FStar_All.pipe_right components1
                              (FStar_String.concat ".")
                             in
                          [uu____3001])
                    in
                 (match core with
                  | FStar_Pervasives_Native.None  ->
                      FStar_Util.print_string "no unsat core\n"
                  | FStar_Pervasives_Native.Some core1 ->
                      let core2 = FStar_List.collect parse_axiom_name core1
                         in
                      ((let uu____3028 =
                          let uu____3030 = get_module_names ()  in
                          FStar_All.pipe_right uu____3030
                            (FStar_String.concat "\nZ3 Proof Stats:\t")
                           in
                        FStar_Util.print1
                          "Z3 Proof Stats: Modules relevant to this proof:\nZ3 Proof Stats:\t%s\n"
                          uu____3028);
                       FStar_Util.print1
                         "Z3 Proof Stats (Detail 1): Specifically:\nZ3 Proof Stats (Detail 1):\t%s\n"
                         (FStar_String.concat
                            "\nZ3 Proof Stats (Detail 1):\t" core2);
                       (let uu____3043 =
                          let uu____3045 = get_discarded_names ()  in
                          FStar_All.pipe_right uu____3045
                            (FStar_String.concat ", ")
                           in
                        FStar_Util.print1
                          "Z3 Proof Stats (Detail 2): Note, this report ignored the following names in the context: %s\n"
                          uu____3043))))
         in
      let uu____3055 =
        (FStar_Options.hint_info ()) || (FStar_Options.query_stats ())  in
      if uu____3055
      then
        let uu____3058 =
          FStar_SMTEncoding_Z3.status_string_and_errors
            z3result.FStar_SMTEncoding_Z3.z3result_status
           in
        match uu____3058 with
        | (status_string,errs) ->
            let at_log_file =
              match z3result.FStar_SMTEncoding_Z3.z3result_log_file with
              | FStar_Pervasives_Native.None  -> ""
              | FStar_Pervasives_Native.Some s -> Prims.op_Hat "@" s  in
            let uu____3077 =
              match z3result.FStar_SMTEncoding_Z3.z3result_status with
              | FStar_SMTEncoding_Z3.UNSAT core -> ("succeeded", core)
              | uu____3091 ->
                  ((Prims.op_Hat "failed {reason-unknown="
                      (Prims.op_Hat status_string "}")),
                    FStar_Pervasives_Native.None)
               in
            (match uu____3077 with
             | (tag,core) ->
                 let range =
                   let uu____3104 =
                     let uu____3106 =
                       FStar_Range.string_of_range settings.query_range  in
                     Prims.op_Hat uu____3106 (Prims.op_Hat at_log_file ")")
                      in
                   Prims.op_Hat "(" uu____3104  in
                 let used_hint_tag =
                   if used_hint settings then " (with hint)" else ""  in
                 let stats =
                   let uu____3120 = FStar_Options.query_stats ()  in
                   if uu____3120
                   then
                     let f k v1 a =
                       Prims.op_Hat a
                         (Prims.op_Hat k
                            (Prims.op_Hat "=" (Prims.op_Hat v1 " ")))
                        in
                     let str =
                       FStar_Util.smap_fold
                         z3result.FStar_SMTEncoding_Z3.z3result_statistics f
                         "statistics={"
                        in
                     let uu____3154 =
                       FStar_Util.substring str Prims.int_zero
                         ((FStar_String.length str) - Prims.int_one)
                        in
                     Prims.op_Hat uu____3154 "}"
                   else ""  in
                 ((let uu____3163 =
                     let uu____3167 =
                       let uu____3171 =
                         let uu____3175 =
                           FStar_Util.string_of_int settings.query_index  in
                         let uu____3177 =
                           let uu____3181 =
                             let uu____3185 =
                               let uu____3189 =
                                 FStar_Util.string_of_int
                                   z3result.FStar_SMTEncoding_Z3.z3result_time
                                  in
                               let uu____3191 =
                                 let uu____3195 =
                                   FStar_Util.string_of_int
                                     settings.query_fuel
                                    in
                                 let uu____3197 =
                                   let uu____3201 =
                                     FStar_Util.string_of_int
                                       settings.query_ifuel
                                      in
                                   let uu____3203 =
                                     let uu____3207 =
                                       FStar_Util.string_of_int
                                         settings.query_rlimit
                                        in
                                     [uu____3207; stats]  in
                                   uu____3201 :: uu____3203  in
                                 uu____3195 :: uu____3197  in
                               uu____3189 :: uu____3191  in
                             used_hint_tag :: uu____3185  in
                           tag :: uu____3181  in
                         uu____3175 :: uu____3177  in
                       (settings.query_name) :: uu____3171  in
                     range :: uu____3167  in
                   FStar_Util.print
                     "%s\tQuery-stats (%s, %s)\t%s%s in %s milliseconds with fuel %s and ifuel %s and rlimit %s %s\n"
                     uu____3163);
                  (let uu____3222 = FStar_Options.print_z3_statistics ()  in
                   if uu____3222 then process_unsat_core core else ());
                  FStar_All.pipe_right errs
                    (FStar_List.iter
                       (fun uu____3248  ->
                          match uu____3248 with
                          | (uu____3256,msg,range1) ->
                              let tag1 =
                                if used_hint settings
                                then "(Hint-replay failed): "
                                else ""  in
                              FStar_Errors.log_issue range1
                                (FStar_Errors.Warning_HitReplayFailed,
                                  (Prims.op_Hat tag1 msg))))))
      else ()
  
let (record_hint : query_settings -> FStar_SMTEncoding_Z3.z3result -> unit) =
  fun settings  ->
    fun z3result  ->
      let uu____3283 =
        let uu____3285 = FStar_Options.record_hints ()  in
        Prims.op_Negation uu____3285  in
      if uu____3283
      then ()
      else
        (let mk_hint core =
           {
             FStar_Util.hint_name = (settings.query_name);
             FStar_Util.hint_index = (settings.query_index);
             FStar_Util.fuel = (settings.query_fuel);
             FStar_Util.ifuel = (settings.query_ifuel);
             FStar_Util.unsat_core = core;
             FStar_Util.query_elapsed_time = Prims.int_zero;
             FStar_Util.hash =
               (match z3result.FStar_SMTEncoding_Z3.z3result_status with
                | FStar_SMTEncoding_Z3.UNSAT core1 ->
                    z3result.FStar_SMTEncoding_Z3.z3result_query_hash
                | uu____3312 -> FStar_Pervasives_Native.None)
           }  in
         let store_hint hint =
           let uu____3320 = FStar_ST.op_Bang recorded_hints  in
           match uu____3320 with
           | FStar_Pervasives_Native.Some l ->
               FStar_ST.op_Colon_Equals recorded_hints
                 (FStar_Pervasives_Native.Some
                    (FStar_List.append l [FStar_Pervasives_Native.Some hint]))
           | uu____3376 -> ()  in
         match z3result.FStar_SMTEncoding_Z3.z3result_status with
         | FStar_SMTEncoding_Z3.UNSAT (FStar_Pervasives_Native.None ) ->
             let uu____3383 =
               let uu____3384 =
                 get_hint_for settings.query_name settings.query_index  in
               FStar_Option.get uu____3384  in
             store_hint uu____3383
         | FStar_SMTEncoding_Z3.UNSAT unsat_core ->
             if used_hint settings
             then store_hint (mk_hint settings.query_hint)
             else store_hint (mk_hint unsat_core)
         | uu____3391 -> ())
  
let (process_result :
  query_settings ->
    FStar_SMTEncoding_Z3.z3result -> errors FStar_Pervasives_Native.option)
  =
  fun settings  ->
    fun result  ->
      let errs = query_errors settings result  in
      query_info settings result;
      record_hint settings result;
      detail_hint_replay settings result;
      errs
  
let (fold_queries :
  query_settings Prims.list ->
    (query_settings -> (FStar_SMTEncoding_Z3.z3result -> unit) -> unit) ->
      (query_settings ->
         FStar_SMTEncoding_Z3.z3result ->
           errors FStar_Pervasives_Native.option)
        -> (errors Prims.list -> unit) -> unit)
  =
  fun qs  ->
    fun ask1  ->
      fun f  ->
        fun report1  ->
          let rec aux acc qs1 =
            match qs1 with
            | [] -> report1 acc
            | q::qs2 ->
                ask1 q
                  (fun res  ->
                     let uu____3502 = f q res  in
                     match uu____3502 with
                     | FStar_Pervasives_Native.None  -> ()
                     | FStar_Pervasives_Native.Some errs ->
                         aux (errs :: acc) qs2)
             in
          aux [] qs
  
let (ask_and_report_errors :
  FStar_TypeChecker_Env.env ->
    FStar_SMTEncoding_Term.error_labels ->
      FStar_SMTEncoding_Term.decl Prims.list ->
        FStar_SMTEncoding_Term.decl ->
          FStar_SMTEncoding_Term.decl Prims.list -> unit)
  =
  fun env  ->
    fun all_labels  ->
      fun prefix1  ->
        fun query  ->
          fun suffix  ->
            FStar_SMTEncoding_Z3.giveZ3 prefix1;
            (let uu____3541 =
               let uu____3548 =
                 match env.FStar_TypeChecker_Env.qtbl_name_and_index with
                 | (uu____3561,FStar_Pervasives_Native.None ) ->
                     failwith "No query name set!"
                 | (uu____3587,FStar_Pervasives_Native.Some (q,n1)) ->
                     let uu____3610 = FStar_Ident.text_of_lid q  in
                     (uu____3610, n1)
                  in
               match uu____3548 with
               | (qname,index1) ->
                   let rlimit =
                     let uu____3628 = FStar_Options.z3_rlimit_factor ()  in
                     let uu____3630 =
                       let uu____3632 = FStar_Options.z3_rlimit ()  in
                       uu____3632 * (Prims.parse_int "544656")  in
                     uu____3628 * uu____3630  in
                   let next_hint = get_hint_for qname index1  in
                   let default_settings =
                     let uu____3639 = FStar_TypeChecker_Env.get_range env  in
                     let uu____3640 = FStar_Options.initial_fuel ()  in
                     let uu____3642 = FStar_Options.initial_ifuel ()  in
                     {
                       query_env = env;
                       query_decl = query;
                       query_name = qname;
                       query_index = index1;
                       query_range = uu____3639;
                       query_fuel = uu____3640;
                       query_ifuel = uu____3642;
                       query_rlimit = rlimit;
                       query_hint = FStar_Pervasives_Native.None;
                       query_errors = [];
                       query_all_labels = all_labels;
                       query_suffix = suffix;
                       query_hash =
                         (match next_hint with
                          | FStar_Pervasives_Native.None  ->
                              FStar_Pervasives_Native.None
                          | FStar_Pervasives_Native.Some
                              { FStar_Util.hint_name = uu____3651;
                                FStar_Util.hint_index = uu____3652;
                                FStar_Util.fuel = uu____3653;
                                FStar_Util.ifuel = uu____3654;
                                FStar_Util.unsat_core = uu____3655;
                                FStar_Util.query_elapsed_time = uu____3656;
                                FStar_Util.hash = h;_}
                              -> h)
                     }  in
                   (default_settings, next_hint)
                in
             match uu____3541 with
             | (default_settings,next_hint) ->
                 let use_hints_setting =
                   match next_hint with
                   | FStar_Pervasives_Native.Some
                       { FStar_Util.hint_name = uu____3684;
                         FStar_Util.hint_index = uu____3685;
                         FStar_Util.fuel = i; FStar_Util.ifuel = j;
                         FStar_Util.unsat_core = FStar_Pervasives_Native.Some
                           core;
                         FStar_Util.query_elapsed_time = uu____3689;
                         FStar_Util.hash = h;_}
                       ->
                       [(let uu___451_3706 = default_settings  in
                         {
                           query_env = (uu___451_3706.query_env);
                           query_decl = (uu___451_3706.query_decl);
                           query_name = (uu___451_3706.query_name);
                           query_index = (uu___451_3706.query_index);
                           query_range = (uu___451_3706.query_range);
                           query_fuel = i;
                           query_ifuel = j;
                           query_rlimit = (uu___451_3706.query_rlimit);
                           query_hint = (FStar_Pervasives_Native.Some core);
                           query_errors = (uu___451_3706.query_errors);
                           query_all_labels =
                             (uu___451_3706.query_all_labels);
                           query_suffix = (uu___451_3706.query_suffix);
                           query_hash = (uu___451_3706.query_hash)
                         })]
                   | uu____3710 -> []  in
                 let initial_fuel_max_ifuel =
                   let uu____3716 =
                     let uu____3718 = FStar_Options.max_ifuel ()  in
                     let uu____3720 = FStar_Options.initial_ifuel ()  in
                     uu____3718 > uu____3720  in
                   if uu____3716
                   then
                     let uu____3725 =
                       let uu___456_3726 = default_settings  in
                       let uu____3727 = FStar_Options.max_ifuel ()  in
                       {
                         query_env = (uu___456_3726.query_env);
                         query_decl = (uu___456_3726.query_decl);
                         query_name = (uu___456_3726.query_name);
                         query_index = (uu___456_3726.query_index);
                         query_range = (uu___456_3726.query_range);
                         query_fuel = (uu___456_3726.query_fuel);
                         query_ifuel = uu____3727;
                         query_rlimit = (uu___456_3726.query_rlimit);
                         query_hint = (uu___456_3726.query_hint);
                         query_errors = (uu___456_3726.query_errors);
                         query_all_labels = (uu___456_3726.query_all_labels);
                         query_suffix = (uu___456_3726.query_suffix);
                         query_hash = (uu___456_3726.query_hash)
                       }  in
                     [uu____3725]
                   else []  in
                 let half_max_fuel_max_ifuel =
                   let uu____3734 =
                     let uu____3736 =
                       let uu____3738 = FStar_Options.max_fuel ()  in
                       uu____3738 / (Prims.of_int (2))  in
                     let uu____3741 = FStar_Options.initial_fuel ()  in
                     uu____3736 > uu____3741  in
                   if uu____3734
                   then
                     let uu____3746 =
                       let uu___460_3747 = default_settings  in
                       let uu____3748 =
                         let uu____3750 = FStar_Options.max_fuel ()  in
                         uu____3750 / (Prims.of_int (2))  in
                       let uu____3753 = FStar_Options.max_ifuel ()  in
                       {
                         query_env = (uu___460_3747.query_env);
                         query_decl = (uu___460_3747.query_decl);
                         query_name = (uu___460_3747.query_name);
                         query_index = (uu___460_3747.query_index);
                         query_range = (uu___460_3747.query_range);
                         query_fuel = uu____3748;
                         query_ifuel = uu____3753;
                         query_rlimit = (uu___460_3747.query_rlimit);
                         query_hint = (uu___460_3747.query_hint);
                         query_errors = (uu___460_3747.query_errors);
                         query_all_labels = (uu___460_3747.query_all_labels);
                         query_suffix = (uu___460_3747.query_suffix);
                         query_hash = (uu___460_3747.query_hash)
                       }  in
                     [uu____3746]
                   else []  in
                 let max_fuel_max_ifuel =
                   let uu____3760 =
                     (let uu____3766 = FStar_Options.max_fuel ()  in
                      let uu____3768 = FStar_Options.initial_fuel ()  in
                      uu____3766 > uu____3768) &&
                       (let uu____3772 = FStar_Options.max_ifuel ()  in
                        let uu____3774 = FStar_Options.initial_ifuel ()  in
                        uu____3772 >= uu____3774)
                      in
                   if uu____3760
                   then
                     let uu____3779 =
                       let uu___464_3780 = default_settings  in
                       let uu____3781 = FStar_Options.max_fuel ()  in
                       let uu____3783 = FStar_Options.max_ifuel ()  in
                       {
                         query_env = (uu___464_3780.query_env);
                         query_decl = (uu___464_3780.query_decl);
                         query_name = (uu___464_3780.query_name);
                         query_index = (uu___464_3780.query_index);
                         query_range = (uu___464_3780.query_range);
                         query_fuel = uu____3781;
                         query_ifuel = uu____3783;
                         query_rlimit = (uu___464_3780.query_rlimit);
                         query_hint = (uu___464_3780.query_hint);
                         query_errors = (uu___464_3780.query_errors);
                         query_all_labels = (uu___464_3780.query_all_labels);
                         query_suffix = (uu___464_3780.query_suffix);
                         query_hash = (uu___464_3780.query_hash)
                       }  in
                     [uu____3779]
                   else []  in
                 let min_fuel1 =
                   let uu____3790 =
                     let uu____3792 = FStar_Options.min_fuel ()  in
                     let uu____3794 = FStar_Options.initial_fuel ()  in
                     uu____3792 < uu____3794  in
                   if uu____3790
                   then
                     let uu____3799 =
                       let uu___468_3800 = default_settings  in
                       let uu____3801 = FStar_Options.min_fuel ()  in
                       {
                         query_env = (uu___468_3800.query_env);
                         query_decl = (uu___468_3800.query_decl);
                         query_name = (uu___468_3800.query_name);
                         query_index = (uu___468_3800.query_index);
                         query_range = (uu___468_3800.query_range);
                         query_fuel = uu____3801;
                         query_ifuel = Prims.int_one;
                         query_rlimit = (uu___468_3800.query_rlimit);
                         query_hint = (uu___468_3800.query_hint);
                         query_errors = (uu___468_3800.query_errors);
                         query_all_labels = (uu___468_3800.query_all_labels);
                         query_suffix = (uu___468_3800.query_suffix);
                         query_hash = (uu___468_3800.query_hash)
                       }  in
                     [uu____3799]
                   else []  in
                 let all_configs =
                   FStar_List.append use_hints_setting
                     (FStar_List.append [default_settings]
                        (FStar_List.append initial_fuel_max_ifuel
                           (FStar_List.append half_max_fuel_max_ifuel
                              max_fuel_max_ifuel)))
                    in
                 let check_one_config config1 k =
                   (let uu____3826 = FStar_Options.z3_refresh ()  in
                    if uu____3826
                    then FStar_SMTEncoding_Z3.refresh ()
                    else ());
                   (let uu____3831 = with_fuel_and_diagnostics config1 []  in
                    let uu____3834 =
                      let uu____3837 = FStar_SMTEncoding_Z3.mk_fresh_scope ()
                         in
                      FStar_Pervasives_Native.Some uu____3837  in
                    FStar_SMTEncoding_Z3.ask config1.query_range
                      (filter_assertions config1.query_env config1.query_hint)
                      config1.query_hash config1.query_all_labels uu____3831
                      uu____3834 k (used_hint config1))
                    in
                 let check_all_configs configs =
                   let report1 errs =
                     report_errors
                       (let uu___481_3860 = default_settings  in
                        {
                          query_env = (uu___481_3860.query_env);
                          query_decl = (uu___481_3860.query_decl);
                          query_name = (uu___481_3860.query_name);
                          query_index = (uu___481_3860.query_index);
                          query_range = (uu___481_3860.query_range);
                          query_fuel = (uu___481_3860.query_fuel);
                          query_ifuel = (uu___481_3860.query_ifuel);
                          query_rlimit = (uu___481_3860.query_rlimit);
                          query_hint = (uu___481_3860.query_hint);
                          query_errors = errs;
                          query_all_labels = (uu___481_3860.query_all_labels);
                          query_suffix = (uu___481_3860.query_suffix);
                          query_hash = (uu___481_3860.query_hash)
                        })
                      in
                   fold_queries configs check_one_config process_result
                     report1
                    in
                 let uu____3861 =
                   let uu____3870 = FStar_Options.admit_smt_queries ()  in
                   let uu____3872 = FStar_Options.admit_except ()  in
                   (uu____3870, uu____3872)  in
                 (match uu____3861 with
                  | (true ,uu____3880) -> ()
                  | (false ,FStar_Pervasives_Native.None ) ->
                      check_all_configs all_configs
                  | (false ,FStar_Pervasives_Native.Some id1) ->
                      let skip =
                        if FStar_Util.starts_with id1 "("
                        then
                          let full_query_id =
                            let uu____3910 =
                              let uu____3912 =
                                let uu____3914 =
                                  let uu____3916 =
                                    FStar_Util.string_of_int
                                      default_settings.query_index
                                     in
                                  Prims.op_Hat uu____3916 ")"  in
                                Prims.op_Hat ", " uu____3914  in
                              Prims.op_Hat default_settings.query_name
                                uu____3912
                               in
                            Prims.op_Hat "(" uu____3910  in
                          full_query_id <> id1
                        else default_settings.query_name <> id1  in
                      if Prims.op_Negation skip
                      then check_all_configs all_configs
                      else ()))
  
type solver_cfg =
  {
  seed: Prims.int ;
  cliopt: Prims.string Prims.list ;
  facts: (Prims.string Prims.list * Prims.bool) Prims.list ;
  valid_intro: Prims.bool ;
  valid_elim: Prims.bool }
let (__proj__Mksolver_cfg__item__seed : solver_cfg -> Prims.int) =
  fun projectee  ->
    match projectee with
    | { seed; cliopt; facts; valid_intro; valid_elim;_} -> seed
  
let (__proj__Mksolver_cfg__item__cliopt :
  solver_cfg -> Prims.string Prims.list) =
  fun projectee  ->
    match projectee with
    | { seed; cliopt; facts; valid_intro; valid_elim;_} -> cliopt
  
let (__proj__Mksolver_cfg__item__facts :
  solver_cfg -> (Prims.string Prims.list * Prims.bool) Prims.list) =
  fun projectee  ->
    match projectee with
    | { seed; cliopt; facts; valid_intro; valid_elim;_} -> facts
  
let (__proj__Mksolver_cfg__item__valid_intro : solver_cfg -> Prims.bool) =
  fun projectee  ->
    match projectee with
    | { seed; cliopt; facts; valid_intro; valid_elim;_} -> valid_intro
  
let (__proj__Mksolver_cfg__item__valid_elim : solver_cfg -> Prims.bool) =
  fun projectee  ->
    match projectee with
    | { seed; cliopt; facts; valid_intro; valid_elim;_} -> valid_elim
  
let (_last_cfg : solver_cfg FStar_Pervasives_Native.option FStar_ST.ref) =
  FStar_Util.mk_ref FStar_Pervasives_Native.None 
let (get_cfg : FStar_TypeChecker_Env.env -> solver_cfg) =
  fun env  ->
    let uu____4149 = FStar_Options.z3_seed ()  in
    let uu____4151 = FStar_Options.z3_cliopt ()  in
    let uu____4155 = FStar_Options.smtencoding_valid_intro ()  in
    let uu____4157 = FStar_Options.smtencoding_valid_elim ()  in
    {
      seed = uu____4149;
      cliopt = uu____4151;
      facts = (env.FStar_TypeChecker_Env.proof_ns);
      valid_intro = uu____4155;
      valid_elim = uu____4157
    }
  
let (save_cfg : FStar_TypeChecker_Env.env -> unit) =
  fun env  ->
    let uu____4165 =
      let uu____4168 = get_cfg env  in
      FStar_Pervasives_Native.Some uu____4168  in
    FStar_ST.op_Colon_Equals _last_cfg uu____4165
  
let (should_refresh : FStar_TypeChecker_Env.env -> Prims.bool) =
  fun env  ->
    let uu____4199 = FStar_ST.op_Bang _last_cfg  in
    match uu____4199 with
    | FStar_Pervasives_Native.None  -> (save_cfg env; false)
    | FStar_Pervasives_Native.Some cfg ->
        let uu____4229 = let uu____4231 = get_cfg env  in cfg = uu____4231
           in
        Prims.op_Negation uu____4229
  
let (solve :
  (unit -> Prims.string) FStar_Pervasives_Native.option ->
    FStar_TypeChecker_Env.env -> FStar_Syntax_Syntax.term -> unit)
  =
  fun use_env_msg  ->
    fun tcenv  ->
      fun q  ->
        let uu____4259 = FStar_Options.no_smt ()  in
        if uu____4259
        then
          let uu____4262 =
            let uu____4272 =
              let uu____4280 =
                let uu____4282 = FStar_Syntax_Print.term_to_string q  in
                FStar_Util.format1
                  "Q = %s\nA query could not be solved internally, and --no_smt was given"
                  uu____4282
                 in
              (FStar_Errors.Error_NoSMTButNeeded, uu____4280,
                (tcenv.FStar_TypeChecker_Env.range))
               in
            [uu____4272]  in
          FStar_TypeChecker_Err.add_errors tcenv uu____4262
        else
          ((let uu____4303 = should_refresh tcenv  in
            if uu____4303
            then (save_cfg tcenv; FStar_SMTEncoding_Z3.refresh ())
            else ());
           (let uu____4310 =
              let uu____4312 =
                let uu____4314 = FStar_TypeChecker_Env.get_range tcenv  in
                FStar_All.pipe_left FStar_Range.string_of_range uu____4314
                 in
              FStar_Util.format1 "Starting query at %s" uu____4312  in
            FStar_SMTEncoding_Encode.push uu____4310);
           (let pop1 uu____4322 =
              let uu____4323 =
                let uu____4325 =
                  let uu____4327 = FStar_TypeChecker_Env.get_range tcenv  in
                  FStar_All.pipe_left FStar_Range.string_of_range uu____4327
                   in
                FStar_Util.format1 "Ending query at %s" uu____4325  in
              FStar_SMTEncoding_Encode.pop uu____4323  in
            try
              (fun uu___530_4343  ->
                 match () with
                 | () ->
                     let uu____4344 =
                       FStar_SMTEncoding_Encode.encode_query use_env_msg
                         tcenv q
                        in
                     (match uu____4344 with
                      | (prefix1,labels,qry,suffix) ->
                          let tcenv1 =
                            FStar_TypeChecker_Env.incr_query_index tcenv  in
                          (match qry with
                           | FStar_SMTEncoding_Term.Assume
                               {
                                 FStar_SMTEncoding_Term.assumption_term =
                                   {
                                     FStar_SMTEncoding_Term.tm =
                                       FStar_SMTEncoding_Term.App
                                       (FStar_SMTEncoding_Term.FalseOp
                                        ,uu____4376);
                                     FStar_SMTEncoding_Term.freevars =
                                       uu____4377;
                                     FStar_SMTEncoding_Term.rng = uu____4378;_};
                                 FStar_SMTEncoding_Term.assumption_caption =
                                   uu____4379;
                                 FStar_SMTEncoding_Term.assumption_name =
                                   uu____4380;
                                 FStar_SMTEncoding_Term.assumption_fact_ids =
                                   uu____4381;_}
                               -> pop1 ()
                           | uu____4401 when
                               tcenv1.FStar_TypeChecker_Env.admit -> 
                               pop1 ()
                           | FStar_SMTEncoding_Term.Assume uu____4402 ->
                               (ask_and_report_errors tcenv1 labels prefix1
                                  qry suffix;
                                pop1 ())
                           | uu____4404 -> failwith "Impossible"))) ()
            with
            | FStar_SMTEncoding_Env.Inner_let_rec names1 ->
                (pop1 ();
                 (let uu____4420 =
                    let uu____4430 =
                      let uu____4438 =
                        let uu____4440 =
                          let uu____4442 =
                            FStar_List.map FStar_Pervasives_Native.fst names1
                             in
                          FStar_String.concat "," uu____4442  in
                        FStar_Util.format1
                          "Could not encode the query since F* does not support precise smtencoding of inner let-recs yet (in this case %s)"
                          uu____4440
                         in
                      (FStar_Errors.Error_NonTopRecFunctionNotFullyEncoded,
                        uu____4438, (tcenv.FStar_TypeChecker_Env.range))
                       in
                    [uu____4430]  in
                  FStar_TypeChecker_Err.add_errors tcenv uu____4420))))
  
let (solver : FStar_TypeChecker_Env.solver_t) =
  {
    FStar_TypeChecker_Env.init =
      (fun e  -> save_cfg e; FStar_SMTEncoding_Encode.init e);
    FStar_TypeChecker_Env.push = FStar_SMTEncoding_Encode.push;
    FStar_TypeChecker_Env.pop = FStar_SMTEncoding_Encode.pop;
    FStar_TypeChecker_Env.snapshot = FStar_SMTEncoding_Encode.snapshot;
    FStar_TypeChecker_Env.rollback = FStar_SMTEncoding_Encode.rollback;
    FStar_TypeChecker_Env.encode_sig = FStar_SMTEncoding_Encode.encode_sig;
    FStar_TypeChecker_Env.preprocess =
      (fun e  ->
         fun g  ->
           let uu____4482 =
             let uu____4489 = FStar_Options.peek ()  in (e, g, uu____4489)
              in
           [uu____4482]);
    FStar_TypeChecker_Env.solve = solve;
    FStar_TypeChecker_Env.finish = FStar_SMTEncoding_Z3.finish;
    FStar_TypeChecker_Env.refresh = FStar_SMTEncoding_Z3.refresh
  } 
let (dummy : FStar_TypeChecker_Env.solver_t) =
  {
    FStar_TypeChecker_Env.init = (fun uu____4505  -> ());
    FStar_TypeChecker_Env.push = (fun uu____4507  -> ());
    FStar_TypeChecker_Env.pop = (fun uu____4510  -> ());
    FStar_TypeChecker_Env.snapshot =
      (fun uu____4513  ->
         ((Prims.int_zero, Prims.int_zero, Prims.int_zero), ()));
    FStar_TypeChecker_Env.rollback =
      (fun uu____4532  -> fun uu____4533  -> ());
    FStar_TypeChecker_Env.encode_sig =
      (fun uu____4548  -> fun uu____4549  -> ());
    FStar_TypeChecker_Env.preprocess =
      (fun e  ->
         fun g  ->
           let uu____4555 =
             let uu____4562 = FStar_Options.peek ()  in (e, g, uu____4562)
              in
           [uu____4555]);
    FStar_TypeChecker_Env.solve =
      (fun uu____4578  -> fun uu____4579  -> fun uu____4580  -> ());
    FStar_TypeChecker_Env.finish = (fun uu____4587  -> ());
    FStar_TypeChecker_Env.refresh = (fun uu____4589  -> ())
  } 