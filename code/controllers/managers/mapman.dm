
MapManager
	var
		list
			maps

	New()
		..()
		spawn()
			maps = new()
			Load()

	proc
		Load()
			//maps += SwapMaps_Load("default")

		Save()

		Join(mob/chatter/C)
			C.loc = locate(1,1,1)
