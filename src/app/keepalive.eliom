[%%server

open Lwt
open Lwt_process

(* Self-ping mechanism to keep Render.com instance alive *)
(* Pings the application every 5 minutes to prevent sleep *)

let ping_interval_seconds = 300.0 (* 5 minutes *)

(* Get the base URL - hardcoded for Render.com deployment *)
let get_base_url () =
	"https://four2-ocreet.onrender.com"

(* Perform self-ping using curl *)
let perform_ping () =
	let base_url = get_base_url () in
	(* Ensure URL ends with / for root path *)
	let url = base_url ^ "/" in
	try
		let command = Printf.sprintf "curl -f -s -m 10 %s" (String.escaped url) in
		let process = open_process (shell command) in
		process#status >>= fun _status ->
		Lwt.return_unit
	with
	| e ->
		(* Silently ignore errors to avoid spam in logs *)
		Lwt.return_unit

(* Recursive function to ping periodically *)
let rec ping_loop () =
	Lwt_unix.sleep ping_interval_seconds >>= fun () ->
	perform_ping () >>= fun () ->
	ping_loop ()

(* Start the keep-alive mechanism *)
let start_keepalive () =
	Lwt.async (fun () -> ping_loop ())

]

