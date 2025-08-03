[%%shared

open Eliom_content.Html.D
open Eliom_content.Html
open Lwt
open CreatureType

]

[%%client

open Eliom_content.Html.D
open Eliom_content.Html
open Lwt
open Js_of_ocaml

(* Quadtree implementation for creatures - optimizes collision detection *)
(* Instead of O(n²) brute force, we get O(log n) performance *)
module CreatureLeaf : (Quadtree.Leaf with type t = creature) = struct
	type t = creature
	let get_coords creature =
		(creature.x, creature.y)  (* Get creature position *)
	let get_size creature =
		(creature.size, creature.size)  (* Get creature bounding box *)
end
module CreatureQuadtree = Quadtree.Make (CreatureLeaf)

let game_over_class = "game-over-animation"

let add_game_over_css dom_elt =
	let classes = Js.to_string (Js.Unsafe.get dom_elt (Js.string "className")) in
	Js.Unsafe.set dom_elt (Js.string "className") (Js.string (classes ^ " " ^ game_over_class))

let remove_game_over_css dom_elt =
	let classes = Js.to_string (Js.Unsafe.get dom_elt (Js.string "className")) in
	if String.length classes > 30 then (
		let ind = String.length classes - String.length (" " ^ game_over_class) in
		let new_classes = String.sub classes 0 ind in
		Js.Unsafe.set dom_elt (Js.string "className") (Js.string new_classes)
	)

let clear_game_board container =
	remove_game_over_css container ;
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
		| "fst-parent" -> Utils.elt_to_dom_elt ~%(Page.customization_input_one)
		| "snd-parent" -> Utils.elt_to_dom_elt ~%(Page.customization_input_two)
		| _ -> Utils.elt_to_dom_elt ~%(Page.customization_input_three)
	) in
	Dom.replaceChild parent d range ;
	let inp = Dom.list_of_nodeList (Js.Unsafe.meth_call d "querySelectorAll" [| Js.Unsafe.inject (Js.string "input") |]) in
	match inp with
	| [] -> ()
	| hd :: rest -> (
			let value, min, max = Hashtbl.find Config.vals (Js.to_string (Js.Unsafe.get hd (Js.string "id"))) in
			ignore (Js.Unsafe.meth_call hd "setAttribute" [| Js.Unsafe.inject (Js.string "min"); Js.Unsafe.inject (Js.string (string_of_int min)) |]) ;
			ignore (Js.Unsafe.meth_call hd "setAttribute" [| Js.Unsafe.inject (Js.string "max"); Js.Unsafe.inject (Js.string (string_of_int max)) |]) ;
			ignore (Js.Unsafe.meth_call hd "setAttribute" [| Js.Unsafe.inject (Js.string "value"); Js.Unsafe.inject (Js.string (string_of_int value)) |])
		)

let change_insane_rotation creature existing_creatures =
	let rad_to_deg rad =
		rad *. (180.0 /. 3.14159265)
	in
	let closer_creature acc b =
		if b.state <> StdSick false then acc
		else ( match acc with
			| None -> Some b
			| Some a -> (
				let distance1 = sqrt ((b.x -. creature.x) ** 2.0 +. (b.y -. creature.y) ** 2.0) in
				let distance2 = sqrt ((a.x -. creature.x) ** 2.0 +. (a.y -. creature.y) ** 2.0) in
				if distance1 < distance2 then Some b
				else Some a
			)
		)
	in
	if creature.state = Insane then (
		match List.fold_left closer_creature None existing_creatures with
		| None -> ()
		| Some b -> (
			let x = b.x -. creature.x in
			let y = b.y -. creature.y in
			let deg = rad_to_deg (atan2 y x) in
			CreatureUtils.update_rotation creature (int_of_float deg)
		)
	)

(* Optimized collision detection using quadtree spatial partitioning *)
let make_sick_if_collision quadtree creature =
	let other_creature_sick = (fun x _ -> not x.currently_dragged && Creature.is_sick x) in
	if not (Creature.is_sick creature) && not creature.currently_dragged
		&& CreatureQuadtree.collision_pred quadtree creature other_creature_sick then (
		match Random.int 10 with
		| 0 -> Creature.make_creature_sick creature
		| _ -> ()
	)

]