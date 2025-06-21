

[%%server

(* Server-side utility functions using Unix API *)
let get_time () =
	Unix.gettimeofday ()

let random_rotation () =
	Random.int 360

let random_forward_time () =
	let current_time = get_time () in
	current_time +. 3.0 +. Random.float 2.0

]

[%%client

open Js_of_ocaml
open Eliom_content.Html.D
open Eliom_content.Html
open Lwt

let elt_to_dom_elt = To_dom.of_element

let get_time () =
	let date_constructor = Js.Unsafe.get Js.Unsafe.global (Js.string "Date") in
	let date_now = Js.Unsafe.get date_constructor (Js.string "now") in
	Js.to_float (Js.Unsafe.fun_call date_now [||]) /. 1000.0

let random_rotation () =
	Random.int 360

let random_forward_time () =
	let current_time = get_time () in
	current_time +. 3.0 +. Random.float 2.0

]