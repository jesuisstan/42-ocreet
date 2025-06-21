

[%%server

(* Server-side placeholder - dragging logic is client-side only *)

]

[%%client

open Js_of_ocaml

type 'a events_callbacks = {
	dragstart:	'a -> unit ;
	dragend:	'a -> unit
}

type 'a dragging_handler = {
	events_cbs:						'a events_callbacks ;
	move:							'a -> float -> float -> unit ;
	set_dragging_status:			'a -> bool -> unit ;
	get_dom_elt:					'a -> Dom_html.element Js.t ;
	mutable currently_dragging:		'a option
}

let dragged_css_class = "dragged"

let add_dragged_css dom_elt =
	let classes = Js.to_string (Js.Unsafe.get dom_elt (Js.string "className")) in
	Js.Unsafe.set dom_elt (Js.string "className") (Js.string (classes ^ " " ^ dragged_css_class))

let remove_dragged_css dom_elt =
	let classes = Js.to_string (Js.Unsafe.get dom_elt (Js.string "className")) in
	let ind = String.length classes - String.length (" " ^ dragged_css_class) in
	let new_classes = String.sub classes 0 ind in
	Js.Unsafe.set dom_elt (Js.string "className") (Js.string new_classes)

let deselect_elt handler =
	match handler.currently_dragging with
	| None -> ()
	| Some elt -> ( handler.set_dragging_status elt false ;
					remove_dragged_css (handler.get_dom_elt elt) )

let select_elt handler =
	match handler.currently_dragging with
	| None -> ()
	| Some elt -> ( handler.set_dragging_status elt true ;
					add_dragged_css (handler.get_dom_elt elt) )

let stop_dragging handler =
	deselect_elt handler ;
	handler.currently_dragging <- None

let change_dragging_elt handler elt =
	deselect_elt handler ;
	handler.currently_dragging <- Some elt ;
	select_elt handler

let make_draggable handler elt =
	Lwt.async (fun () ->
		Js_of_ocaml_lwt.Lwt_js_events.mousedowns (handler.get_dom_elt elt)
			( fun ev _ ->
				Js_of_ocaml.Dom.preventDefault ev ;
				change_dragging_elt handler elt ;
				handler.events_cbs.dragstart elt ;
				Lwt.return ()
			)
	)

let make_handler events_cbs move set_dragging_status get_dom_elt =
	let handler = {
		events_cbs = events_cbs ;
		move = move ;
		set_dragging_status = set_dragging_status ;
		get_dom_elt = get_dom_elt ;
		currently_dragging = None
	} in
	let handle_mouseup ev _ =
		let currently_dragging = handler.currently_dragging in
		stop_dragging handler ;
		( match currently_dragging with
		| None -> ()
		| Some elt -> handler.events_cbs.dragend elt ) ;
		Lwt.return ()
	in
	let handle_mousemove ev _ =
		( match handler.currently_dragging with
		| None -> ()
		| Some elt -> handler.move elt (float_of_int (Js.Unsafe.get ev (Js.string "clientX"))) (float_of_int (Js.Unsafe.get ev (Js.string "clientY"))) ) ;
		Lwt.return ()
	in
	ignore (Js_of_ocaml_lwt.Lwt_js_events.mouseups Js_of_ocaml.Dom_html.document handle_mouseup) ;
	ignore (Js_of_ocaml_lwt.Lwt_js_events.mousemoves Js_of_ocaml.Dom_html.document handle_mousemove) ;
	handler

]