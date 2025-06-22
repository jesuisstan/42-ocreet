[%%server

(* Server-side placeholder - all functions are client-side only *)

]

[%%client

open Js_of_ocaml
open CreatureType

let update_rotation creature new_rot =
	creature.rotation <- new_rot mod 360 ;
	let rotation = "rotate(" ^ (string_of_int (creature.rotation + 90)) ^ "deg)" in
	let style = Js.Unsafe.get creature.dom_elt (Js.string "style") in
	Js.Unsafe.set style (Js.string "transform") (Js.string rotation)

let get_elt_coords elt =
	let coords = Js.Unsafe.meth_call elt "getBoundingClientRect" [||] in
	(Js.Unsafe.get coords (Js.string "left"), Js.Unsafe.get coords (Js.string "top"))

let get_creature_size creature =
	creature.size

let get_creature_relative_coords x y =
	(* Since creatures are now positioned relative to container, 
	   we can use the coordinates directly *)
	(x, y)

let get_creature_absolute_coords x y =
	(* Since creatures are now positioned relative to container, 
	   we can use the coordinates directly *)
	(x, y)

let actual_move_creature creature x_float y_float =
	(* Fix positioning: use integer pixel values to avoid rendering issues *)
	let x = Js.string (string_of_int (int_of_float x_float) ^ "px") in
	let y = Js.string (string_of_int (int_of_float y_float) ^ "px") in
	let style = Js.Unsafe.get creature.dom_elt (Js.string "style") in
	Js.Unsafe.set style (Js.string "left") x ;
	Js.Unsafe.set style (Js.string "top") y ;
	let x, y = get_creature_relative_coords x_float y_float in
	creature.x <- x ;
	creature.y <- y ;
	creature.updated_at <- Some (Utils.get_time ())

let move_creature creature new_x new_y =
	let _limit_by_borders value low high =
		if value < low then low
		else if value > high then high
		else value
	in
	let offset = get_creature_size creature in
	let x = _limit_by_borders new_x 0.0 (float_of_int Config.board_width -. offset) in
	let y = _limit_by_borders new_y 0.0 (float_of_int Config.board_height -. offset) in
	actual_move_creature creature x y

let move_creature_bounce creature x y =
	let b_size = get_creature_size creature in
	( if x <= 0.0 then
		update_rotation creature (180 + (360 - creature.rotation))
	) ;
	( if x +. b_size >= float_of_int Config.board_width then
		update_rotation creature (180 - creature.rotation)
	) ;
	( if y <= 0.0 then
		update_rotation creature (360 - creature.rotation)
	) ;
	( if y +. b_size >= float_of_int Config.board_height then
		update_rotation creature (360 - creature.rotation)
	) ;
	move_creature creature x y

]