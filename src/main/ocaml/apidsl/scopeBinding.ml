open ApiAst


let flip f a b = f b a


let this = "this"


let scoped scopes name f =
  let scopes = name :: scopes in
  f scopes
  


let transform symtab decls =
  let open ApiMap in


  let map_uname v scopes uname =
    SymbolTable.lookup symtab scopes uname
  in


  let map_lname v scopes lname =
    SymbolTable.lookup symtab scopes lname
  in


  let map_enumerator v scopes = function
    | Enum_Name _ as enumerator ->
        visit_enumerator v scopes enumerator

    | Enum_Namespace (uname, enumerators) ->
        let uname' = v.map_uname v scopes uname in
        let enumerators = scoped scopes uname (flip (visit_list v.map_enumerator v) enumerators) in
        Enum_Namespace (uname', enumerators)
  in


  let map_decl v scopes = function
    | Decl_Namespace (lname, decls) ->
        let lname' = v.map_lname v scopes lname in
        let decls = scoped scopes lname (flip (visit_list v.map_decl v) decls) in
        Decl_Namespace (lname', decls)
    | Decl_Class (lname, decls) ->
        let lname' = v.map_lname v scopes lname in
        let decls = scoped scopes lname (flip (visit_list v.map_decl v) decls) in
        Decl_Class (lname', decls)
    | Decl_Function (type_name, lname, parameters, error_list) ->
        let type_name = v.map_type_name v scopes type_name in
        let lname' = v.map_lname v scopes lname in
        let parameters = scoped scopes lname (flip (visit_list v.map_parameter v) parameters) in
        let error_list = scoped scopes lname (flip (v.map_error_list v) error_list) in
        Decl_Function (type_name, lname', parameters, error_list)
    | Decl_Enum (is_class, uname, enumerators) ->
        let uname' = v.map_uname v scopes uname in
        let enumerators = scoped scopes uname (flip (visit_list v.map_enumerator v) enumerators) in
        Decl_Enum (is_class, uname', enumerators)
    | Decl_Error (lname, enumerators) ->
        let lname' = v.map_lname v scopes lname in
        let enumerators = scoped scopes lname (flip (visit_list v.map_enumerator v) enumerators) in
        Decl_Error (lname', enumerators)
    | Decl_Struct decls ->
        let decls = scoped scopes this (flip (visit_list v.map_decl v) decls) in
        Decl_Struct decls
    | Decl_GetSet (type_name, lname, decls) ->
        let type_name = scoped scopes lname (flip (v.map_type_name v) type_name) in
        let lname' = v.map_lname v scopes lname in
        let decls = scoped scopes lname (flip (visit_list v.map_decl v) decls) in
        Decl_GetSet (type_name, lname', decls)
    | Decl_Event (lname, decl) ->
        let lname = "event " ^ lname in
        let lname' = v.map_lname v scopes lname in
        let decl = scoped scopes lname (flip (v.map_decl v) decl) in
        Decl_Event (lname', decl)

    | Decl_Const _
    | Decl_Member _
    | Decl_Comment _
    | Decl_Static _
    | Decl_Macro _
    | Decl_Typedef _ as decl ->
        ApiMap.visit_decl v scopes decl
  in

  let v = {
    map_uname;
    map_lname;
    map_enumerator;
    map_decl;

    map_macro = visit_macro;
    map_comment_fragment = visit_comment_fragment;
    map_comment = visit_comment;
    map_size_spec = visit_size_spec;
    map_type_name = visit_type_name;
    map_error_list = visit_error_list;
    map_parameter = visit_parameter;
    map_expr = visit_expr;
  } in
  symtab, visit_decls v [] decls
  


let inverse (symtab, decls) =
  let open ApiMap in


  let map_uname v () uname =
    SymbolTable.name symtab uname
  in


  let map_lname v () lname =
    SymbolTable.name symtab lname
  in


  let v = {
    map_uname;
    map_lname;

    map_enumerator = visit_enumerator;
    map_decl = visit_decl;
    map_macro = visit_macro;
    map_comment_fragment = visit_comment_fragment;
    map_comment = visit_comment;
    map_size_spec = visit_size_spec;
    map_type_name = visit_type_name;
    map_error_list = visit_error_list;
    map_parameter = visit_parameter;
    map_expr = visit_expr;
  } in
  visit_decls v () decls