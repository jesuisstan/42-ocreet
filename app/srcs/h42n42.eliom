[%%shared

open Eliom_content.Html.D
open Eliom_content.Html
open Lwt
open BestioleType

]

[%%client

open Js_of_ocaml

let rec wait_for_threads beginned_at threads existing_bestioles attach_n_bestioles =
	Lwt.choose threads >>= fun () ->
		Lwt.return (List.filter (fun x -> Lwt.state x = Lwt.Sleep) threads) >>= fun threads ->
			let threads = (match threads with | [] -> [] | hd :: rest -> Lwt.cancel hd ; rest) in
			Lwt.return (List.filter (fun b -> not b.dead) existing_bestioles) >>= fun existing_bestioles ->
				if List.length existing_bestioles = 0 then exit_game () else (
					let new_b_every = float_of_int (Config.get_val "new-bestiole-every") in
					if (Utils.get_time ()) -. beginned_at >= new_b_every then (
						make_bestioles_loop false 1 threads existing_bestioles attach_n_bestioles
					) else (
											let wait_n_sec = new_b_every -. ((Utils.get_time ()) -. beginned_at) in
					let threads = (Js_of_ocaml_lwt.Lwt_js.sleep wait_n_sec) :: threads in
						let collisions = MainUtils.check_for_collisions_thread existing_bestioles in
						let threads = collisions :: threads in
						wait_for_threads beginned_at threads existing_bestioles attach_n_bestioles 
					)
				)

and make_bestioles_loop start nb threads existing_bestioles attach_n_bestioles =
	let at_least_one_healthy = List.exists (fun b -> b.state = StdIll false) existing_bestioles in
	let nb = if start || at_least_one_healthy then nb else 0 in
	let new_bestioles = attach_n_bestioles (not start) nb in
	let existing_bestioles = List.fold_left (fun acc b -> b::acc) existing_bestioles new_bestioles in
	let threads = List.fold_left (fun acc b -> (Bestiole.bestiole_thread b)::acc) threads new_bestioles in
	let new_b_every = float_of_int (Config.get_val "new-bestiole-every") in
	let threads = (Js_of_ocaml_lwt.Lwt_js.sleep new_b_every) :: threads in
	let collisions = MainUtils.check_for_collisions_thread existing_bestioles in
	let threads = collisions :: threads in
	wait_for_threads (Utils.get_time ()) threads existing_bestioles attach_n_bestioles

and start_game () =
	let container = Utils.elt_to_dom_elt ~%(Page.bestiole_container) in
	MainUtils.clear_game_board container ;
	MainUtils.update_config () ;
	let start_time = Utils.get_time () in
	let events_cbs = Dragging.{
		dragstart = (fun _ -> ()) ;
		dragend = Bestiole.handle_bestiole_dragend
	} in
	let move bestiole x y =
		let x = x -. (BestioleUtils.get_bestiole_size bestiole /. 2.0) in
		let y = y -. (BestioleUtils.get_bestiole_size bestiole /. 2.0) in
		BestioleUtils.move_bestiole bestiole x y
	in
	let set_dragging_status bestiole status =
		bestiole.currently_dragged <- status
	in
	let get_dom_elt bestiole =
		bestiole.dom_elt
	in
	let dragging_handler = Dragging.make_handler events_cbs move set_dragging_status get_dom_elt in
	let attach_n_bestioles = Bestiole.make_bestioles_and_attach start_time dragging_handler container in
	let nb_bestioles = (Config.get_val "starting-nb-bestioles") in
	make_bestioles_loop true nb_bestioles [] [] attach_n_bestioles

and init_client restart =
	try
		Random.self_init () ;
		Config.set_std_vals () ;
		let body = Utils.elt_to_dom_elt ~%(Page.body_html) in
		let ranges = Js.Unsafe.meth_call body "querySelectorAll" [| Js.Unsafe.inject (Js.string "span.rangeparent") |] in
		List.iter MainUtils.replace_range_tagname (Dom.list_of_nodeList ranges) ;
		let start_button = Utils.elt_to_dom_elt ~%(Page.start_button) in
		(* Simple click handler using DOM events *)
		Js.Unsafe.set start_button (Js.string "onclick") 
			(Js.Unsafe.callback (fun () -> 
				try
					Lwt.async (fun () -> start_game ())
				with 
				| e -> 
					let console = Js.Unsafe.get Js.Unsafe.global (Js.string "console") in
					ignore (Js.Unsafe.meth_call console "log" [| Js.Unsafe.inject (Js.string ("Error in start_game: " ^ (Printexc.to_string e))) |])
			));
		Lwt.return_unit
	with 
	| e -> 
		let console = Js.Unsafe.get Js.Unsafe.global (Js.string "console") in
		ignore (Js.Unsafe.meth_call console "log" [| Js.Unsafe.inject (Js.string ("Error in init_client: " ^ (Printexc.to_string e))) |]);
		Lwt.return_unit

and exit_game () =
	let container = Utils.elt_to_dom_elt ~%(Page.bestiole_container) in
	MainUtils.add_game_over_css container ;
	Js_of_ocaml_lwt.Lwt_js.sleep 1.0 >>= fun () ->
		let game_over = Utils.elt_to_dom_elt ~%(Page.game_over) in
		let classes = Js.to_string (Js.Unsafe.get game_over (Js.string "className")) in
		Js.Unsafe.set game_over (Js.string "className") (Js.string (classes ^ " " ^ "appear")) ;
		let style = Js.Unsafe.get game_over (Js.string "style") in
		Js.Unsafe.set style (Js.string "display") (Js.string "inherit") ;
		Lwt.return ()

(* Auto-initialize client when page loads *)
let () = Lwt.async (fun () -> init_client false)

]

module H42n42_app =
	Eliom_registration.App (
		struct
			let application_name = "h42n42"
			let global_data_path = None
		end)

let main_service =
	H42n42_app.create
		~path:(Eliom_service.Path [""])
		~meth:(Eliom_service.Get Eliom_parameter.unit)
		(fun () () ->
			Lwt.return (Page.make ()))