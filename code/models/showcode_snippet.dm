/showcode_snippet
	var/id
	var/owner = ""
	var/target = ""

	var/code
	var/timestamp

	New()
		..()
		// Generates a unique ID for the code snippet based off the global array showcodes.
		if(!Home.showcodes) {Home.showcodes = list()}
		id = Home.showcodes.len + 1
		Home.showcodes += src

	proc/ReturnHtml()
		var/html = {"
			<html><head>
			<link rel="stylesheet" href="http://yandex.st/highlightjs/6.2/styles/default.min.css">
			<script src="http://yandex.st/highlightjs/6.2/highlight.min.js"></script>
			<script>hljs.initHighlightingOnLoad();</script>
			<title>[owner]'s Showcode</title></head>
			<body><pre><code>[html_encode(code)]</code></pre></body>
			</html>"}
		return html

	proc/Send()
		if(target) {
			var/Messenger/im = new(ChatMan.Get(owner), target)
			im.Display(ChatMan.Get(owner))
			MsgMan.RouteMsg(ChatMan.Get(owner), ChatMan.Get(target), "[owner] has sent a private code snippet.  <a href='byond://?dest=chatman&action=showcode&index=[id]'>Show Code</a>", 1)
		} else {
			// This is shown to the channel.
			Home.chanbot.RawSay("[owner] has posted a code snippet.  <a href='byond://?dest=chatman&action=showcode&index=[id]'>Show Code</a>")
		}