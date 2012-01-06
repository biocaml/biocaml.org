#!/usr/bin/env ocamlscript
--
open Printf;; open Filename

let prog = basename Sys.argv.(0)

let usage = sprintf
"Usage:
  %s srcdir

Publish changes to biocaml.org. Can only be run by developers having
authentication rights to biocaml.org server.

Options:
  srcdir
  Path to 'src' directory in the biocamlweb repo.
" prog

let main srcdir =
  let cmd = sprintf "rsync -av --delete %s biocaml@biocaml.org:biocaml.org/" (concat srcdir "*") in
  let _ = Sys.command cmd in
  ()

;;
match Sys.argv with
  | [||] -> assert false
  | [|_|] -> eprintf "%s\n" usage
  | [|_; srcdir|] -> main srcdir
  | _ -> eprintf "%s\n" usage
