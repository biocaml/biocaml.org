#!/usr/bin/env ocamlscript
--
open Printf

let (/) = Filename.concat
let prog = Filename.basename Sys.argv.(0)

let usage = sprintf
"Usage:
  %s main <biocamlorg_root_dir> - publish main content, i.e. all except doc
  %s doc-dev <biocaml_root_dir> - publish doc of main dev branch
  %s doc-release <version> - publish doc for a released version

Publish changes to biocaml.org. Can only be run by developers having
authentication rights to biocaml.org server.

Arguments:
  <biocamlorg_root_dir>
  Path to local working copy of the biocaml.org repo.

  <biocaml_root_dir>
  Path to local working copy of the biocaml repo. It is assumed that
  the doclib.docdir directory already exists here.

  <version>
  Released version in the form X.Y.Z."
  prog prog prog

let server_root = "biocaml.org"
let server_user = "biocaml"
let server_addr = "biocaml.org"

let run cmd =
  printf "%s\n%!" cmd
  ; ignore (Sys.command cmd)

let rsync src dst_dir =
  run (
    sprintf "rsync -av --delete %s %s@%s:%s/"
      src server_user server_addr dst_dir
  )

;;
match Sys.argv with
  | [||] -> assert false
  | [|_; "main"; biocamlorg_root|] ->
      rsync (biocamlorg_root/"src"/"*") server_root
  | [|_; "doc-dev"; biocaml_root|] ->
      rsync (biocaml_root/"doclib.docdir"/"*") (server_root/"doc"/"dev"/"api")
  | [|_; "doc-release"; version|] ->
      let dst_dir = server_root/"doc"/("v" ^ version)/"api" in
      run (sprintf "ssh %s@%s \"mkdir -p %s\"" server_user server_addr dst_dir);
      run (sprintf "cd %s" (Filename.get_temp_dir_name ()));
      let base = sprintf "biocaml-%s" version in
      run (sprintf "wget --no-check-certificate https://github.com/downloads/biocaml/biocaml/%s.tgz" base);
      run (sprintf "tar xzf %s.tgz" base);
      run (sprintf "rm -f %s.tgz" base);
      rsync (base/"doc"/"html"/"*") dst_dir;
      run (sprintf "rm -rf %s" base)
  | _ -> eprintf "%s\n" usage
