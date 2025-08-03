[%%shared

open Eliom_content.Html.D
open Eliom_content.Html
open Lwt
open CreatureType

]

[%%client

open Js_of_ocaml

(* Game state management *)
type game_state = {
	mutable threads: unit Lwt.t list;
	mutable creatures: creature list;
}
let game = { threads = []; creatures = [] }

let stop_and_clear_creatures () =
	List.iter Lwt.cancel game.threads;
	let container = Utils.elt_to_dom_elt ~%(Page.creature_container) in
	List.iter (fun c ->
		try Dom.removeChild container c.dom_elt with _ -> ()
	) game.creatures;
	game.threads <- [];
	game.creatures <- []

let rec wait_for_threads beginned_at attach_n_creatures =
	Lwt.choose game.threads >>= fun () ->
		game.threads <- List.filter (fun x -> Lwt.state x = Lwt.Sleep) game.threads;
		let living_creatures = List.filter (fun b -> not b.dead) game.creatures in
		(* Game over only when all creatures are dead *)
		if List.length living_creatures = 0 then exit_game ()
		else (
					let new_b_every = float_of_int (Config.get_val "new-creature-every") in
					if (Utils.get_time ()) -. beginned_at >= new_b_every then (
				make_creatures_loop false 1 attach_n_creatures
					) else (
											let wait_n_sec = new_b_every -. ((Utils.get_time ()) -. beginned_at) in
				game.threads <- (Js_of_ocaml_lwt.Lwt_js.sleep wait_n_sec) :: game.threads;
				wait_for_threads beginned_at attach_n_creatures
			)
		)

and collisions_and_chasing_thread () =
	Js_of_ocaml_lwt.Lwt_js.sleep 0.1 >>= fun () ->
		let living_creatures = List.filter (fun b -> not b.dead) game.creatures in
		let width = float_of_int Config.board_width in
		let height = float_of_int Config.board_height in
		(* Create quadtree for spatial partitioning optimization *)
		(* This reduces collision detection from O(n²) to O(log n) *)
		let quadtree = MainUtils.CreatureQuadtree.make width height in
		(* Add all living creatures to the quadtree *)
		let quadtree = List.fold_left (fun acc b -> MainUtils.CreatureQuadtree.add acc b) quadtree living_creatures in
		(* Check collisions using optimized quadtree instead of brute force *)
		List.iter (MainUtils.make_sick_if_collision quadtree) living_creatures ;
		List.iter (fun x -> MainUtils.change_insane_rotation x living_creatures) living_creatures ;
		collisions_and_chasing_thread ()

and make_creatures_loop start nb attach_n_creatures =
	let living_creatures = List.filter (fun b -> not b.dead) game.creatures in
	let at_least_one_healthy = List.exists (fun b -> b.state = StdSick false) living_creatures in
	let nb = if start || at_least_one_healthy then nb else 0 in
	let new_creatures = attach_n_creatures (not start) nb in
	game.creatures <- List.fold_left (fun acc b -> b::acc) game.creatures new_creatures;
	let new_threads = List.map (fun b -> Creature.creature_thread b) new_creatures in
	game.threads <- List.rev_append new_threads game.threads;
	let new_b_every = float_of_int (Config.get_val "new-creature-every") in
	game.threads <- (Js_of_ocaml_lwt.Lwt_js.sleep new_b_every) :: game.threads;
	wait_for_threads (Utils.get_time ()) attach_n_creatures

and start_game () =
	stop_and_clear_creatures ();
	let container = Utils.elt_to_dom_elt ~%(Page.creature_container) in
	MainUtils.clear_game_board container ;
	MainUtils.update_config () ;
	(* Disable start button and enable reset button during game *)
	disable_start_button () ;
	enable_reset_button () ;
	let start_time = Utils.get_time () in
	let events_cbs = Dragging.{
		dragstart = (fun _ -> ()) ;
		dragend = Creature.handle_creature_dragend
	} in
	let move creature x y =
		(* Convert cursor coordinates to container coordinates, accounting for scaling *)
		let board_container = Utils.elt_to_dom_elt ~%(Page.board_container) in
		let board_rect = Js.Unsafe.meth_call board_container "getBoundingClientRect" [||] in
		let board_left = Js.Unsafe.get board_rect (Js.string "left") in
		let board_top = Js.Unsafe.get board_rect (Js.string "top") in
		(* Calculate the scale factor by comparing board container size to original size *)
		let board_width = Js.Unsafe.get board_rect (Js.string "width") in
		let scale_factor = board_width /. float_of_int (Config.board_width + 40) in
		(* Convert cursor position to container coordinates *)
		let container_x = (x -. board_left) /. scale_factor in
		let container_y = (y -. board_top) /. scale_factor in
		(* Center the creature under the cursor *)
		let x = container_x -. (CreatureUtils.get_creature_size creature /. 2.0) in
		let y = container_y -. (CreatureUtils.get_creature_size creature /. 2.0) in
		CreatureUtils.move_creature creature x y
	in
	let set_dragging_status creature status =
		creature.currently_dragged <- status
	in
	let get_dom_elt creature =
		creature.dom_elt
	in
	let dragging_handler = Dragging.make_handler events_cbs move set_dragging_status get_dom_elt in
	let attach_n_creatures = Creature.make_creatures_and_attach start_time dragging_handler container in
	let nb_creatures = (Config.get_val "starting-number-of-creatures") in
	Lwt.async collisions_and_chasing_thread;
	make_creatures_loop true nb_creatures attach_n_creatures

and reset_game () =
	(* Reload the page to reset everything *)
	Js.Unsafe.meth_call (Js.Unsafe.get Js.Unsafe.global (Js.string "location")) "reload" [| |]

and disable_start_button () =
	let start_button = Utils.elt_to_dom_elt ~%(Page.start_button) in
	let classes = Js.to_string (Js.Unsafe.get start_button (Js.string "className")) in
	if not (String.contains classes 'd') then
		Js.Unsafe.set start_button (Js.string "className") (Js.string (classes ^ " disabled"))

and enable_start_button () =
	let start_button = Utils.elt_to_dom_elt ~%(Page.start_button) in
	let classes = Js.to_string (Js.Unsafe.get start_button (Js.string "className")) in
	let new_classes = Str.replace_first (Str.regexp " disabled") "" classes in
	Js.Unsafe.set start_button (Js.string "className") (Js.string new_classes)

and disable_reset_button () =
	let reset_button = Utils.elt_to_dom_elt ~%(Page.reset_button) in
	let classes = Js.to_string (Js.Unsafe.get reset_button (Js.string "className")) in
	if not (String.contains classes 'd') then
		Js.Unsafe.set reset_button (Js.string "className") (Js.string (classes ^ " disabled"))

and enable_reset_button () =
	let reset_button = Utils.elt_to_dom_elt ~%(Page.reset_button) in
	let classes = Js.to_string (Js.Unsafe.get reset_button (Js.string "className")) in
	let new_classes = Str.replace_first (Str.regexp " disabled") "" classes in
	Js.Unsafe.set reset_button (Js.string "className") (Js.string new_classes)

and init_client restart =
	try
		Random.self_init () ;
		Config.set_std_vals () ;
		let body = Utils.elt_to_dom_elt ~%(Page.body_html) in
		let ranges = Js.Unsafe.meth_call body "querySelectorAll" [| Js.Unsafe.inject (Js.string "span.rangeparent") |] in
		List.iter MainUtils.replace_range_tagname (Dom.list_of_nodeList ranges) ;
		(* Call setVals() again to show value indicators immediately after page load	*)
		ignore (Js.Unsafe.eval_string "setVals();");
		
		(* Initialize start button *)
		let start_button = Utils.elt_to_dom_elt ~%(Page.start_button) in
		Js.Unsafe.set start_button (Js.string "onclick") 
			(Js.Unsafe.callback (fun () -> 
				try
					Lwt.async (fun () -> start_game ())
				with 
				| e -> 
					let console = Js.Unsafe.get Js.Unsafe.global (Js.string "console") in
					ignore (Js.Unsafe.meth_call console "log" [| Js.Unsafe.inject (Js.string ("Error in start_game: " ^ (Printexc.to_string e))) |])
			));
		
		(* Initialize reset button - initially disabled *)
		let reset_button = Utils.elt_to_dom_elt ~%(Page.reset_button) in
		disable_reset_button () ;
		Js.Unsafe.set reset_button (Js.string "onclick") 
			(Js.Unsafe.callback (fun () -> 
				try
					reset_game ()
				with 
				| e -> 
					let console = Js.Unsafe.get Js.Unsafe.global (Js.string "console") in
					ignore (Js.Unsafe.meth_call console "log" [| Js.Unsafe.inject (Js.string ("Error in reset_game: " ^ (Printexc.to_string e))) |])
			));
		
		Lwt.return_unit
	with 
	| e -> 
		let console = Js.Unsafe.get Js.Unsafe.global (Js.string "console") in
		ignore (Js.Unsafe.meth_call console "log" [| Js.Unsafe.inject (Js.string ("Error in init_client: " ^ (Printexc.to_string e))) |]);
		Lwt.return_unit

and exit_game () =
	stop_and_clear_creatures ();
	let container = Utils.elt_to_dom_elt ~%(Page.creature_container) in
	MainUtils.add_game_over_css container ;
	(* Re-enable start button and disable reset button when game ends *)
	enable_start_button () ;
	disable_reset_button () ;
		let game_over = Utils.elt_to_dom_elt ~%(Page.game_over) in
		let classes = Js.to_string (Js.Unsafe.get game_over (Js.string "className")) in
		Js.Unsafe.set game_over (Js.string "className") (Js.string (classes ^ " " ^ "appear")) ;
		let style = Js.Unsafe.get game_over (Js.string "style") in
		Js.Unsafe.set style (Js.string "display") (Js.string "inherit") ;
	Lwt.return_unit

(* Auto-initialize client when page loads *)
let () = Eliom_client.onload (fun () -> Lwt.async (fun () -> init_client false))

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