[%%server

(* Server-side placeholder - creature logic is client-side only *)

]

[%%client

open Js_of_ocaml
open Eliom_content.Html.D
open Eliom_content.Html
open Lwt
open CreatureType

let is_sick creature =
	match creature.state with
	| StdIll false -> false
	| StdIll true -> true
	| Berserk -> true
	| Naughty -> true

let cure_creature creature =
	if creature.state = Berserk then (
		creature.size <- float_of_int (Config.get_val "creature-size") ;
		let size_str = (Config.get_val "creature-size") |> string_of_int |> Js.string in
			ignore (Js.Unsafe.meth_call creature.dom_elt "setAttribute" [| Js.Unsafe.inject (Js.string "width"); Js.Unsafe.inject size_str |])
	) ;
	creature.state <- StdIll false ;
	ignore (Js.Unsafe.meth_call creature.dom_elt "setAttribute" [| Js.Unsafe.inject (Js.string "src"); Js.Unsafe.inject (Js.string "./images/creature_sane.png") |]) ;
	creature.got_infected_at <- None ;
	creature.full_size_at <- None

let make_creature_sick creature =
	let n = Random.int 10 in
	creature.got_infected_at <- Some (Utils.get_time ()) ;
	let img_src = ( match n with
		| 0 -> creature.state <- Berserk ; creature.full_size_at <- Some (Utils.get_time () +. 7.0) ; "./images/creature_berserk.png"
		| 1 -> creature.state <- Naughty ; "./images/creature_naughty.png"
		| _ -> creature.state <- StdIll true ; "./images/creature_sick.png"
	) in
	ignore (Js.Unsafe.meth_call creature.dom_elt "setAttribute" [| Js.Unsafe.inject (Js.string "src"); Js.Unsafe.inject (Js.string img_src) |])

let kill_creature creature =
	creature.dead <- true ;
	let container = Utils.elt_to_dom_elt ~%(Page.creature_container) in
	Dom.removeChild container creature.dom_elt ;
	Lwt.return ()

let update_speed creature =
	let multiplier = match creature.state with
		| StdIll true -> 0.85
		| StdIll false -> 1.0
		| Berserk -> 0.85
		| Naughty -> 1.15
	in
	let time_speedup = (Utils.get_time () -. creature.start_time) /. 120.0 in
	let time_speedup = 1.0 +. time_speedup in
	creature.speed <- float_of_int (Config.get_val "creature-speed") *. time_speedup *. multiplier 

let update_size creature =
	if creature.state <> Berserk then ()
	else (
		match creature.full_size_at with
		| Some x -> (
			let current_time = Utils.get_time () in
				let multiplier = ( if current_time >= x then
						4.0
					else
						1.0 +. ((current_time +. 7.0 -. x) /. 7.0 *. 2.0)
				) in
				let multiplier = if multiplier > 4.0 then 4.0 else multiplier in
				creature.size <- float_of_int (Config.get_val "creature-size") *. multiplier ;
				let size_str = creature.size |> string_of_float |> Js.string in
				ignore (Js.Unsafe.meth_call creature.dom_elt "setAttribute" [| Js.Unsafe.inject (Js.string "width"); Js.Unsafe.inject size_str |])
			)
		| _ -> ()
 	)

let next_coords creature =
	let deg_to_rad deg =
		0.01745329252 *. float_of_int deg
	in
	match creature.updated_at with
	| None -> (creature.x, creature.y)
	| Some updated_at -> (
		let nb_pixels_decal = creature.speed *. (Utils.get_time () -. updated_at) in
		let x = nb_pixels_decal *. cos (deg_to_rad creature.rotation) in
		let y = nb_pixels_decal *. sin (deg_to_rad creature.rotation) in
		(creature.x +. x, creature.y +. y)
	)

let change_rotation_if_ok creature =
	match creature.state with
	| Naughty -> ()
	| _ -> (
		if Utils.get_time () >= creature.change_rotation_at then (
			CreatureUtils.update_rotation creature (Utils.random_rotation ()) ;
			creature.change_rotation_at <- Utils.random_forward_time ()
		)
	)

let make_sick_if_ok creature =
	if not (is_sick creature) && creature.y <= float_of_int Config.extremes_height then
		make_creature_sick creature

let rec creature_thread creature =
	let living_time_after_infection = Config.get_val "life-time-after-infection" in
	let living_time_after_infection = float_of_int living_time_after_infection in
	match creature.got_infected_at with
	| Some time when Utils.get_time () -. time >= living_time_after_infection ->
			kill_creature creature
	| _ -> (
		Js_of_ocaml_lwt.Lwt_js.sleep 0.01 >>= fun () ->
			match creature.currently_dragged with
			| true -> ( creature.updated_at <- Some (Utils.get_time ()) ;
						creature_thread creature )
			| false -> (
				change_rotation_if_ok creature ;
				update_speed creature ;
				update_size creature ;
				let x, y = next_coords creature in
				CreatureUtils.move_creature_bounce creature x y ;
				make_sick_if_ok creature ;
				creature_thread creature
		)
	)

let handle_creature_dragend creature =
	let bottom_y = creature.y +. CreatureUtils.get_creature_size creature in
	let hospital_start = Config.board_height - Config.extremes_height in
	let hospital_start = float_of_int hospital_start in
	if bottom_y >= hospital_start then cure_creature creature ;
	CreatureUtils.update_rotation creature (Utils.random_rotation ()) ;
	creature.change_rotation_at <- Utils.random_forward_time ()

let make_creature ?fadein:(fadein=false) start_time dragging_handler =
	let image = img
		~alt:""
		~a:[
			a_width (Config.get_val "creature-size") ;
			a_class ["creature"] ;
			a_style (if fadein then "animation: fadein 2s;" else "")
		]
		~src:(make_uri ~service:(Eliom_service.static_dir ()) ["images" ; "creature_sane.png"]) ()
	in
	let creature = {
		elt = image ;
		dom_elt = Utils.elt_to_dom_elt image ;
		x = 0.0 ;
		y = 0.0 ;
		size = float_of_int (Config.get_val "creature-size") ;
		rotation = 0 ;
		start_time = start_time ;
		speed = float_of_int (Config.get_val "creature-speed") ;
		state = StdIll false ;
		change_rotation_at = Utils.random_forward_time () ;
		updated_at = None ;
		dead = false ;
		got_infected_at = None ;
		full_size_at = None ;
		currently_dragged = false
	} in
	let rand_x = Random.float (float_of_int Config.board_width) in
	let rand_y = Random.float (float_of_int Config.board_height) in
	let rand_x, rand_y = CreatureUtils.get_creature_absolute_coords rand_x rand_y in
	CreatureUtils.update_rotation creature (Utils.random_rotation ()) ;
	CreatureUtils.move_creature creature rand_x rand_y ;
	Dragging.make_draggable dragging_handler creature ;
	creature

let make_creatures ?fadein:(fadein=false) start_time dragging_handler n =
	let rec _make_creatures acc = function
		| 0 -> acc
		| n -> _make_creatures (make_creature ~fadein:fadein start_time dragging_handler::acc) (n - 1)
	in
	_make_creatures [] n

let make_creatures_and_attach start_time dragging_handler parent fadein n =
	let creatures = make_creatures ~fadein:fadein start_time dragging_handler n in
	List.iter (fun b -> Dom.appendChild parent b.dom_elt) creatures ;
	creatures

]