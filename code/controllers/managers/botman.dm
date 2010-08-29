
BotManager

	Del()
		if(Home && Home.chanbot) SaveBot(Home.chanbot)
		..()

	proc
		SaveBot(Bot/ChanBot)
			var/savefile/S = new("./data/saves/channels/[ckey(ChanBot.Chan.name)].sav")
			S["bot.name"]		<< ChanBot.name
			S["bot.name_color"]	<< ChanBot.name_color
			S["bot.text_color"]	<< ChanBot.text_color
			S["bot.fade_name"]	<< ChanBot.fade_name

		LoadBot(Channel/Chan)
			var/savefile/S = new("./data/saves/channels/[ckey(Chan.name)].sav")
			var/Bot/ChanBot = new(Chan)
			S["bot.name"]		>> ChanBot.name
			S["bot.name_color"]	>> ChanBot.name_color
			S["bot.text_color"]	>> ChanBot.text_color
			S["bot.fade_name"]	>> ChanBot.fade_name
			return ChanBot
