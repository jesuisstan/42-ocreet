

[%%server

(* Server-side placeholder - types are client-side only *)

]

[%%client

open Eliom_content.Html.D
open Eliom_content.Html
open Lwt
open Js_of_ocaml

type creature_state =
	| StdSick of bool
	| Berserk
	| Insane

type creature = {
	elt:						Html_types.img D.elt ;
	dom_elt:					Dom_html.element Js.t ;
	mutable x:					float ;
	mutable y:					float ;
	mutable size:				float ;
	mutable rotation:			int ;
	start_time:					float ;
	mutable speed:				float ;
	mutable state:				creature_state ;
	mutable change_rotation_at:	float ;
	mutable updated_at:			float option ;
	mutable dead:				bool ;
	mutable got_infected_at:	float option ;
	mutable full_size_at:		float option ;
	mutable currently_dragged:  bool
}

]