open Eliom_content.Html.D
open Eliom_content.Html
open Lwt

let river_images =
	let _make_river_image () =
		(* HTML validation: img requires mandatory alt and src attributes *)
		img
			~alt:""
			~a:[a_class ["center-vertical" ; "river-single"]]
			~src:(make_uri ~service:(Eliom_service.static_dir ()) ["images" ; "river.png"]) ()
	in
	let nb_river_images =
		if Config.extremes_height > 305 then 1
		else if Config.extremes_height > 120 then 2
		else 5
	in
	let rec _make_river_images = function
		| 0 -> []
		| n -> (_make_river_image ())::(_make_river_images (n - 1))
	in
	_make_river_images nb_river_images

let river =
	(* HTML validation: div structure and attribute types checked at compile time *)
	div ~a:[
		a_class ["extreme" ; "river"] ;
		a_style ("height:" ^ string_of_int Config.extremes_height ^ "px;")
	] [
		div ~a:[a_class ["center-vertical" ; "center-horizontal"]]
			river_images
	]

let hospital_images =
	let _make_hospital_image () =
		(* HTML validation: img requires mandatory alt and src attributes *)
		img
			~alt:""
			~a:[a_class ["center-vertical" ; "hospital-image"]]
			~src:(make_uri ~service:(Eliom_service.static_dir ()) ["images" ; "hospital.png"]) ()
	in
	let nb_hospital_images =
		if Config.extremes_height > 305 then 1
		else if Config.extremes_height > 120 then 2
		else 5
	in
	let rec _make_hospital_images = function
		| 0 -> []
		| n -> (_make_hospital_image ())::(_make_hospital_images (n - 1))
	in
	_make_hospital_images nb_hospital_images

let hospital =
	(* HTML validation: div structure and nested elements validated *)
	div ~a:[
		a_class ["extreme" ; "hospital"] ;
		a_style ("height:" ^ string_of_int Config.extremes_height ^ "px;" ^
							"margin-top:" ^ string_of_int (Config.board_height - Config.extremes_height * 2) ^ "px;")
	] [
		div ~a:[a_class ["center-vertical" ; "center-horizontal"]]
			hospital_images
	]

let creature_container =
	(* HTML validation: container div with proper dimensions and child elements *)
	div ~a:[
		a_class ["creature-container"] ;
		a_style ("width:" ^ string_of_int Config.board_width ^ "px;" ^
							"height:" ^ string_of_int Config.board_height ^ "px;")
	] [
		river ;
		hospital
	]

let game_over =
	(* HTML validation: game over div with calculated positioning *)
	div ~a:[
		a_class ["game-over-container"] ;
		a_style (
		"margin-left:" ^ string_of_int ((Config.board_width + 40 - 400) / 2) ^ "px;" ^
		"margin-top:" ^ string_of_int ((Config.board_height + 40 - 175) / 2) ^ "px;"
		)
	] [
		div ~a:[a_class ["game-over-container-child"]] [
			p [txt "Game Over!"]
		]
	]

let board_container =
	(* HTML validation: board container with border elements and proper structure *)
	div ~a:[a_class ["board-container"]] [
		game_over ;
		creature_container
	]

let start_button =
	(* HTML validation: button div with proper class structure *)
	div ~a:[a_class ["btn start-game"]] [txt "Start game"]

let reset_button =
	(* HTML validation: button div with proper class structure *)
	div ~a:[a_class ["btn reset-game"]] [txt "Reset game"]

let first_input_parent =
	(* HTML validation: form inputs with proper types and attributes *)
	div ~a:[a_class ["input-parent"]] [
		txt "Creature's size: ";
		span ~a:[a_class ["range-field rangeparent"] ; a_title "fst-parent"] [
			(* HTML validation: Form.input validates input_type and form type *)
			Form.input ~a:[a_id "creature-size"] ~input_type:`Range Form.string
		] ;
		txt "Creature's speed: ";
		span ~a:[a_class ["range-field rangeparent"] ; a_title "fst-parent"] [
			(* HTML validation: Form.input validates input_type and form type *)
			Form.input ~a:[a_id "creature-speed"] ~input_type:`Range Form.string
		] ;
	]

let second_input_parent =
	(* HTML validation: form inputs with proper types and attributes *)
	div ~a:[a_class ["input-parent"]] [
		txt "Starting number of creatures: ";
		span ~a:[a_class ["range-field rangeparent"] ; a_title "snd-parent"] [
			(* HTML validation: Form.input validates input_type and form type *)
			Form.input ~a:[a_id "starting-number-of-creatures"] ~input_type:`Range Form.string
		] ;
		txt "New creature every N seconds: ";
		span ~a:[a_class ["range-field rangeparent"] ; a_title "snd-parent"] [
			(* HTML validation: Form.input validates input_type and form type *)
			Form.input ~a:[a_id "new-creature-every"] ~input_type:`Range Form.string
		] ;
	]

let third_input_parent =
	(* HTML validation: form inputs with proper types and attributes *)
	let buttons = div ~a:[a_class ["button-container"]] [start_button; reset_button] in
	div ~a:[a_class ["input-parent"]] [
		txt "Sickness time: ";
		span ~a:[a_class ["range-field rangeparent"] ; a_title "thd-parent"] [
			(* HTML validation: Form.input validates input_type and form type *)
			Form.input ~a:[a_id "life-time-after-infection"] ~input_type:`Range Form.string
		] ;
		buttons
	]

let form = 
	(* HTML validation: form container with proper nested structure *)
	div ~a:[a_class ["all-input-parent"]] [
		first_input_parent ;
		second_input_parent ;
		third_input_parent
	]

let agenda_container =
	(* HTML validation: text content with proper paragraph structure *)
	div ~a:[a_class ["agenda-container"]] [
		p ~a:[a_class ["centertext" ; "agenda"]] [
			txt "Creatures have lived in a peaceful land bordered by a river. Unfortunately, the river has been polluted by H42N42, a deadly and very infectious virus for some time." ;
			br () ;
			txt "The Creatures will not survive without your assistance! Your goal will be to help them stay away from the river and to bring the sick ones to the hospital where they will be healed so they don't contaminate the others."
		] ;
		form
	]

let theme_toggle_button =
	(* Theme toggle button with SVG icon and accessibility label *)
	button ~a:[a_class ["theme-toggle-btn"]; a_user_data "aria-label" "Toggle color theme"] [
		img ~alt:"Toggle theme" ~src:(make_uri ~service:(Eliom_service.static_dir ()) ["images"; "sun-moon.svg"]) ()
	]

let main_content =
	(* Add theme toggle button at the top right *)
	div ~a:[a_class ["main-content"]] [
		div ~a:[a_class ["theme-toggle-btn-container"]] [theme_toggle_button];
		agenda_container;
		board_container
	]

let body_html =
	(* HTML validation: body element with proper heading hierarchy *)
	(body [
		h1 [txt "OCreet GAME"] ;
		main_content
	])

let make () =
	(* HTML validation: complete HTML document structure with head and body *)
	html
		(* HTML validation: head element with proper meta tags and resource links *)
		(head (title (txt "OCreet GAME"))
			[(* HTML validation: Google Fonts link for modern typography *)
			css_link ~uri:(Eliom_content.Html.D.uri_of_string (fun () -> "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap")) () ;
			(* HTML validation: CSS links with validated URIs *)
			css_link ~uri:(make_uri ~service:(Eliom_service.static_dir ()) ["css" ; "h42n42.css"]) () ;
			(* HTML validation: JavaScript scripts with validated URIs *)
			js_script ~uri:(make_uri ~service:(Eliom_service.static_dir ()) ["js" ; "jquery.min.js"]) () ;
			(* HTML validation: CSS links with validated URIs *)
			css_link ~uri:(make_uri ~service:(Eliom_service.static_dir ()) ["css" ; "materialize.min.css"]) () ;
			(* HTML validation: JavaScript scripts with validated URIs *)
			js_script ~uri:(make_uri ~service:(Eliom_service.static_dir ()) ["js" ; "materialize.min.js"]) () ;
			(* HTML validation: JavaScript scripts with validated URIs *)
			js_script ~uri:(make_uri ~service:(Eliom_service.static_dir ()) ["js" ; "utils.js"]) ()
			])
		body_html