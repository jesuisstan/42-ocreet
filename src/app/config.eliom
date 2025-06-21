

[%%shared

let board_width = 1100
let board_height = 800
let extremes_height = 71

let vals = Hashtbl.create ~random:true 10

let set_std_vals () =
	Hashtbl.add vals "creature-size" (50, 30, 100) ;
	Hashtbl.add vals "creature-speed" (100, 30, 300) ;
	Hashtbl.add vals "starting-number-of-creatures" (5, 2, 21) ;
	Hashtbl.add vals "new-creature-every" (8, 4, 42) ;
	Hashtbl.add vals "life-time-after-infection" (10, 1, 21)

let set_val name value =
	let current_value, mini, maxi = Hashtbl.find vals name in
	Hashtbl.replace vals name (value, mini, maxi)

let get_val name =
	let value, _, _ = Hashtbl.find vals name in
	value

]