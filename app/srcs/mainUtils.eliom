

[%%shared

open Eliom_content.Html.D
open Eliom_content.Html
open Lwt
open BestioleType

]

[%%client

open Js_of_ocaml

module BestioleLeaf : (Quadtree.Leaf with type t = bestiole) = struct
	type t = bestiole
	let get_coords bestiole =
		(bestiole.x, bestiole.y)
	let get_size bestiole =
		(bestiole.size, bestiole.size)
end
module BestioleQuadtree = Quadtree.Make (BestioleLeaf)

let game_over_class = "game-over-animation"

let add_lost_css dom_elt =
	let classes = Js.to_string (Js.Unsafe.get dom_elt (Js.string "className")) in
	Js.Unsafe.set dom_elt (Js.string "className") (Js.string (classes ^ " " ^ game_over_class))

let remove_lost_css dom_elt =
	let classes = Js.to_string (Js.Unsafe.get dom_elt (Js.string "className")) in
	if String.length classes > 30 then (
		let ind = String.length classes - String.length (" " ^ game_over_class) in
		let new_classes = String.sub classes 0 ind in
		Js.Unsafe.set dom_elt (Js.string "className") (Js.string new_classes)
	)

let clear_game_board container =
	remove_lost_css container ;
	let game_over = Utils.elt_to_dom_elt ~%(Page.game_over) in
	let style = Js.Unsafe.get game_over (Js.string "style") in
	Js.Unsafe.set style (Js.string "display") (Js.string "none")

let update_config_val inp =
	let value = Js.Unsafe.meth_call inp "getAttribute" [| Js.Unsafe.inject (Js.string "value") |] in
	let ident = Js.Unsafe.meth_call inp "getAttribute" [| Js.Unsafe.inject (Js.string "id") |] in
	let value = Js.Opt.get value (fun _ -> assert false) in
	let ident = Js.Opt.get ident (fun _ -> assert false) in
	let value = Js.to_string value in
	let ident = Js.to_string ident in
	let value = try int_of_string value with | _ -> 10 in
	let value = if value <= 0 then 10 else value in
	Config.set_val ident value

let update_config () =
	ignore (Js.Unsafe.eval_string "setVals()") ;
	let body = Utils.elt_to_dom_elt ~%(Page.body_html) in
	let inps = Js.Unsafe.meth_call body "querySelectorAll" [| Js.Unsafe.inject (Js.string ".rangeparent > input") |] in
	List.iter update_config_val (Dom.list_of_nodeList inps)

let replace_range_tagname range =
	let d = Dom_html.createP Dom_html.document in
	Js.Unsafe.set d (Js.string "innerHTML") (Js.Unsafe.get range (Js.string "innerHTML")) ;
	Js.Unsafe.set d (Js.string "className") (Js.string "range-field rangeparent") ;
	let title = Js.Unsafe.get range (Js.string "title") in
	let parent = ( match Js.to_string title with
		| "fst-parent" -> Utils.elt_to_dom_elt ~%(Page.first_input_parent)
		| "snd-parent" -> Utils.elt_to_dom_elt ~%(Page.second_input_parent)
		| _ -> Utils.elt_to_dom_elt ~%(Page.third_input_parent)
	) in
	Dom.replaceChild parent d range ;
	let inp = Dom.list_of_nodeList (Js.Unsafe.meth_call d "querySelectorAll" [| Js.Unsafe.inject (Js.string "input") |]) in
	match inp with
	| [] -> ()
	| hd :: rest -> (
			let value, min, max = Hashtbl.find Config.vals (Js.to_string (Js.Unsafe.get hd (Js.string "id"))) in
			Js.Unsafe.meth_call hd "setAttribute" [| Js.Unsafe.inject (Js.string "min"); Js.Unsafe.inject (Js.string (string_of_int min)) |] ;
			Js.Unsafe.meth_call hd "setAttribute" [| Js.Unsafe.inject (Js.string "max"); Js.Unsafe.inject (Js.string (string_of_int max)) |] ;
			Js.Unsafe.meth_call hd "setAttribute" [| Js.Unsafe.inject (Js.string "value"); Js.Unsafe.inject (Js.string (string_of_int value)) |]
		)

let change_naughty_rotation bestiole existing_bestioles =
	let rad_to_deg rad =
		rad *. (180.0 /. 3.14159265)
	in
	let closer_bestiole acc b =
		if b.state <> StdIll false then acc
		else ( match acc with
			| None -> Some b
			| Some a -> (
				let distance1 = sqrt ((b.x -. bestiole.x) ** 2.0 +. (b.y -. bestiole.y) ** 2.0) in
				let distance2 = sqrt ((a.x -. bestiole.x) ** 2.0 +. (a.y -. bestiole.y) ** 2.0) in
				if distance1 < distance2 then Some b
				else Some a
			)
		)
	in
	if bestiole.state = Naughty then (
		match List.fold_left closer_bestiole None existing_bestioles with
		| None -> ()
		| Some b -> (
			let x = b.x -. bestiole.x in
			let y = b.y -. bestiole.y in
			let deg = rad_to_deg (atan2 y x) in
			BestioleUtils.update_rotation bestiole (int_of_float deg)
		)
	)

let make_ill_if_collision quadtree bestiole =
	let other_bestiole_ill = (fun x _ -> not x.currently_dragged && Bestiole.is_ill x) in
	if not (Bestiole.is_ill bestiole) && not bestiole.currently_dragged
		&& BestioleQuadtree.collision_pred quadtree bestiole other_bestiole_ill then (
		match Random.int 10 with
		| 0 -> Bestiole.make_bestiole_ill bestiole
		| _ -> ()
	)

let rec check_for_collisions_thread existing_bestioles =
	Js_of_ocaml_lwt.Lwt_js.sleep 0.1 >>= fun () ->
		let width = float_of_int Config.board_width in
		let height = float_of_int Config.board_height in
		let quadtree = BestioleQuadtree.make width height in
		let quadtree = List.fold_left (fun acc b -> BestioleQuadtree.add acc b) quadtree existing_bestioles in
		List.iter (make_ill_if_collision quadtree) existing_bestioles ;
		List.iter (fun x -> change_naughty_rotation x existing_bestioles) existing_bestioles ;
		check_for_collisions_thread existing_bestioles

]