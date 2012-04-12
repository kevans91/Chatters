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

	proc/ReturnHtml(mob/chatter/C, code = 0)
		if(!C) return
		var/html
		if(C.show_highlight && code)
			html = {"
				<html>
				<head>
				<link rel="stylesheet" href="http://yandex.st/highlightjs/6.2/styles/default.min.css">
				<script src="http://yandex.st/highlightjs/6.2/highlight.min.js"></script>
				<script>hljs.initHighlightingOnLoad();</script>
				<title>[owner]'s Showcode</title>
				</head>
				<body><pre><code>[html_encode(src.code)]</code></pre></body>
				</html>
				"}
		else
			html = {"
				<html>
				<head>
				<title>[owner]'s Show[code ? "code" : "text"]</title>
				</head>
				<body><pre><code>[src.code]</pre></body>
				</html>
				"}
		return html

	proc/Send(code = 0)
		if(!target)
			// This is shown to the channel.
			Home.chanbot.RawSay("[owner] has posted a [code ? "code" : "text"] snippet.  <a href='byond://?src=\ref[ChatMan]&target=\ref[ChatMan.Get(owner)]&action=show[code ? "code" : "text"]&index=[id]'>Show [code ? "Code" : "Text"]</a>")
		else
			var/Messenger/im = new(ChatMan.Get(owner), target)
			im.Display(ChatMan.Get(owner))
			MsgMan.RouteMsg(ChatMan.Get(owner), ChatMan.Get(target), "[owner] has semt a private [code ? "code" : "text"] snippet.  <a href='byond://?src=\ref[ChatMan]&target=\ref[ChatMan.Get(owner)]&action=show[code ? "code" : "text"]&index=[id]'>Show [code ? "Code" : "Text"]</a>", 0)