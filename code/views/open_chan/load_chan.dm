
OpenChannel
	proc
		GetLoadChanHTML()
			var/html = {"
<style>
body {
	color: #333333;
	background-color: #ffffff;
	font-family: Verdana;
}

.heading {
	font-size: 18px;
	font-weight: bold;
}

#main {
	text-align: center;
}

.chan_box {
	text-align: left;
	width: 95%;
	border: 2px solid #666;
	margin: 1em;
}

.chan_name {
	width: 100%;
	background-color: #666;
	color: #CCC;
	padding: 0 0 3px 3px;
}

.chan_on {
	width: 100%;
	text-align: right;
	color: #C00;
	padding: 0 3px 3px 0;
	background-color: #CCC;
}

.chan_off {
	width: 100%;
	text-align: right;
	color: #00C;
	padding: 0 3px 3px 0;
	background-color: #CCC;
}

.chan_desc {
	padding: 0 1em 10px 1em;
}

.chan_topic {
	text-indent: -1em;
	padding: 0 1em 0 2em;
}

.chan_pub {
	padding: 1em 1em 0 1em;
	margin-bottom: -1.5em;
	font-style: italic;
	color: #999;
}

.buttons {
	text-align: right;
	padding: 3px;
}

.form {
	display: inline;
}

.input {
	border: 1px solid #333;
	backgfround-color: #c0c0c0;
	color: #333;
	height: 20px;
	font-size: 10px;
	margin: 0 0 0 -17px;
}
</style>
<div class="heading">Load Channel</div><div id="main">
"}
			if(Chans && Chans.len)
				for(var/c in Chans)
					var/isHome
					var/Channel/C = ChanMan.LoadChan(c)
					C.chanbot = BotMan.LoadBot(C)
					if(Home)
						if(C.name == Home.name) isHome=1
					html += {"
	<div class='chan_box'>
		<div class='chan_name'><strong style='color:#FFF'>[C.name]</strong> founded by [C.founder]</div>
		<div class='[isHome ? "chan_on" : "chan_off" ]'>Currently [isHome ? "Online" : "Offline" ]"}
					if(isHome)
						html += " - [Home.chatters.len] Chatter\s"
					html += {"</div>
		<div class='chan_desc'>[C.desc]</div>
		<div class='chan_topic'><strong><span style='color: [C.chanbot.name_color]'>[C.chanbot.name]</span>:</strong> &nbsp; <span style='color: [C.chanbot.text_color]'>[C.topic]</span></div>
		<div class='chan_pub'>\[[C.publicity] channel]</div>
		<div class='buttons'>
			<form class='form' method=get action='byond://?'>
				<input type="hidden" name="dest" value="chanman">
				<input type="hidden" name="action" value="loadchan">
				<input type="hidden" name="chan" value="[c]">
				<input class='input' type='submit' value='Load'[isHome ? " disabled" : "" ]>
			</form>
			<form class='form' method=get action='byond://?'>
				<input type="hidden" name="dest" value="chanman">
				<input type="hidden" name="action" value="delchan">
				<input type="hidden" name="chan" value="[c]">
				<input class='input' type='submit' value='Delete'>
			</form>
		</div>
	</div>
"}
					del(C.chanbot)
					del(C)
				return html+"</div>"
			html += "No Channels."
			return html+"</div>"