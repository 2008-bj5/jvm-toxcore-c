open ApiAst


let prepend_ns ns name =
  List.fold_left
    (fun name ns ->
       ns ^ "_" ^ name
    ) name ns


let transform decls =
  let open ApiFoldMap in

  let fold_decl v ns = function
    | Decl_Function (type_name, lname, parameters, error_list) ->
        let lname = prepend_ns (ReplaceDecl.get ns) lname in
        ns, Decl_Function (type_name, lname, parameters, error_list)

    | Decl_Class (name, decls) ->
        let ns' = ReplaceDecl.(set ns (name :: get ns)) in
        let _, decls = visit_list v.fold_decl v ns' decls in
        let decls = Decl_Class (name, []) :: decls in
        let ns = ReplaceDecl.replace ns decls in
        ns, Decl_Class (name, decls)

    | decl ->
        ReplaceDecl.fold_decl v ns decl
  in

  let v = {
    default with
    fold_decl;
  } in
  snd @@ ReplaceDecl.fold_decls v (ReplaceDecl.initial []) decls