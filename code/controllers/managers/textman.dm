
TextManager
	var
		list
			tags = list("\[b]"="\[/b]",
						"\[i]"="\[/i]",
						"\[u]"="\[/u]",
						"\[s]"="\[/s]",
						"\[#"="\[/#]",
						"\[code]"="\[/code]",
						"\[img]"="\[/img]")

			html = list("<b>"="</b>",
						"<i>"="</i>",
						"<u>"="</u>",
						"<s>"="</s>",
						"<font color=#"="</font>",
						"<code>"="</code>",
						"<img src='"="'>")

			links = list("id"		= "http://www.byond.com/forum/?post=$s",
						 "hub"		= "http://www.byond.com/games/$s",
						 "people"	= "http://www.byond.com/people/$s",
						 "wiki"		= "http://en.wikipedia.org/wiki/$s",
						 "google"	= "http://www.google.com/search?q=$s",
						 "define"	= "http://dictionary.reference.com/browse/$s",
						 "urban"	= "http://www.urbandictionary.com/define.php?term=$s",
						 "imdb"		= "http://imdb.com/find?s=all&q=$s",
						 "snopes"	= "http://search.atomz.com/search/?sp-a=00062d45-sp00000000&sp-q=$s",
						 "acronym"	= "http://www.acronymfinder.com/af-query.asp?Acronym=$s",
						 "synonym"	= "http://thesaurus.reference.com/browse/$s",
						 "youtube"	= "http://www.youtube.com/watch?v=$s",
						 "myspace"	= "http://www.myspace.com/$s",
						 "bash"		= "http://www.bash.org/?$s",
						 "bbash"	= "http://gazoot.byondhome.com/bbash/?quote=$s",
						 "condo"	= "http://gazoot.byondhome.com/condo/site.dmb?browse&owner=$s",
						 "issue"	= "https://github.com/kevans91/Chatters/issues/$s")

	proc
		Sanitize(msg)
			if(!msg) return
			var/pos = findtext(msg, "\\...")
			while(pos)
				var/part1 = copytext(msg, 1, pos)
				var/part2 = copytext(msg, pos+4)
				msg = part1+part2
				pos = findtext(msg, "\\...")
			pos = findtext(msg, ascii2text(10))
			while(pos)
				var/part1 = copytext(msg, 1, pos)
				var/part2 = copytext(msg, pos+1)
				msg = part1+part2
				pos = findtext(msg, ascii2text(10))
			pos = findtext(msg, "\t")
			while(pos)
				var/part1 = copytext(msg, 1, pos)
				var/part2 = copytext(msg, pos+1)
				msg = part1+part2
				pos = findtext(msg, "\t")
			msg = html_encode(msg)
			return msg

		ParseSmileys(msg)
			if(!msg) return
			var/list/C = ParseCode(msg)
			var/list/R = new()
			for(var/c in C)
				if(C[c] == "code")
					R += c
					continue
				R += s_smileys(c,0,'./resources/icons/smileys/smileys.dmi')
			msg = list2text(R)
			return msg


		ParseLinks(msg)
			if(!msg) return
			var/list/C = ParseCode(msg)
			var/list/R = new()
			for(var/c in C)
				if(C[c] == "code")
					R += c
					continue
				var/temp = c
				for(var/L in links)
					var/pos = findtext(temp, "[L]:")

					while(pos)
						var/end = pos+length(L)+1
						var/Tend = findtext(temp, " ", end)
						if(!Tend) Tend = length(temp)+1
						var/part1 = copytext(temp, 1, pos)
						var/query = copytext(temp, end, Tend)
						if(findtextEx(query, "<IMG")) // temp bug fix, breaks links :(
							pos = findtext(temp, "[L]:",Tend)// would rather not parse
							continue				// smileys instead of breaking links
						var/part2 = copytext(temp, Tend)
						var/replace = findtext(links[L], "$s")
						var/link_part1
						var/link_part2
						if(!replace)
							temp = part1+"<a href=\""+links[L]+query+"\">[L]:[query]</a>"+part2
							Tend = length(part1+"<a href=\""+links[L]+query+"\">[L]:[query]</a>")
						else
							link_part1 = copytext(links[L], 1, replace)
							link_part2 = copytext(links[L], replace+2)
							temp = part1+"<a href=\""+link_part1+query+link_part2+"\">[L]:[query]</a>"+part2
							Tend = length(part1+"<a href=\""+link_part1+query+link_part2+"\">[L]:[query]</a>")
						if(length(part2))
							pos = findtext(temp, "[L]:",Tend)
						else
							pos = 0
				R += temp
			msg = list2text(R)
			return msg


		ParseCode(msg)
				/**
					msg: blah[code]foo[/code]bar
					return val: list("blah", "foo" = "code", "bar")
				**/
			if(!msg) return
			var/list/L = new()
			var/pos = findtext(msg, "\[code]")
			if(length(msg) < pos+6)
				L += msg
				return L
			while(pos)
				var/end = findtext(msg, "\[/code]")
				var/end_tag
				if(!end) end = length(msg)
				else end_tag = end+7
				var/part1 = copytext(msg, 1, pos)
				if(part1) L += part1
				var/code = copytext(msg, pos, end_tag)
				L += code
				L[code] = "code"
				if(end_tag) msg = copytext(msg, end_tag)
				else msg = ""
				pos = findtext(msg, "\[code]")
			if(msg) L += msg
			return L


		ParseTags(msg, Color, Highlight, Images)
			if(!msg) return
			var/i=1
			for(var/T in tags)
				var/pos = findtext(msg, T)
				while(pos)
					var/end = findtext(msg, tags[T], pos + 1)
					if(!end) end = length(msg)+1
					if(T == "\[code]")
						if(end > pos+6)
							var/code = html_decode(copytext(msg, pos+6, end))
							var/temp = copytext(msg, 1, pos)
							if(code && length(code))
								if(Highlight)
									code = HighlightCode(code)
									code = copytext(code, 5, length(code)-6)
									temp += "<span"+code+"</span>"
								else temp += html_encode(code)
								if(end < length(msg))
									temp += copytext(msg, end+7)
							msg = temp
						else
							// Empty tags
							msg = copytext(msg, 1, pos) + copytext(msg, end + length(tags[T]))
					else if(T == "\[#")
						var/Tend = findtext(msg, "]", pos, pos+6)
						if(!Tend) Tend = findtext(msg, "]", pos, pos+9)
						if(Tend && (end > Tend+1))
							var/color = copytext(msg, pos+2, Tend)
							var/temp = copytext(msg, 1, pos)
							if(Color)
								temp += html[i]+color+">"
							if(end)
								temp += copytext(msg, Tend+1, end)
								temp += html[html[i]]
								temp += copytext(msg, end+length(tags[T]))
							msg = temp
						else if(end == Tend + 1 && end <= length(msg))
							msg = copytext(msg, 1, pos) + copytext(msg, end + length(tags[T]))

					else if(pos+length(T) < end)
						if((T == "\[img]") && !Images)
							pos = findtext(msg, T, pos+1)
							continue
						var/temp = copytext(msg, 1, pos)
						temp += html[i]
						temp += copytext(msg, pos+length(T), end)
						if(end)
							temp += html[html[i]]
							temp += copytext(msg, end+length(tags[T]))
						msg = temp
					pos = findtext(msg, T, pos+1)
				i++
			return msg

		Implode(words[], seperator)
			 // if words isn't a list, or no seperator, return
			if(!istype(words,/list) || !seperator) return

			var/text = "" // To store our new string

			for(var/w=1, w<=words.len, w++)	// for each position in the list
				if(w!=words.len)			// if it's not the last position
					text += "[words[w]][seperator]" // add it to the text with a seporator

				else						// Otherwise
					text += "[words[w]]"	// don't add the seperator

			return text // return the converted text

		Explode(text, seperator)
			if(!text || !seperator) return // if no text or seperator, return

			var
				List[] = new() // List holds the words to pass back
				pointer = 1 // The current character position in the text
				nextpos = findtext(text, seperator, pointer) // the next position

			do // do the conversion (see while)
				if(!nextpos || nextpos==length(text)) // if no seperator found (or is the end)
					List += copytext(text, pointer) // add the remainder to the list
					nextpos = null // and set nextpos to null to break the loop

				else // Otherwise
					List += copytext(text, pointer, nextpos) // add the item to the List
					pointer = nextpos+1 // update our pointer
					nextpos = findtext(text, seperator, pointer) // and look for the nextpos
					if(!nextpos) nextpos = length(text)

			while(nextpos) // while there is a next position

			return List // After all that, return the List

		QOTD(mob/chatter/Target)
			if(!Target || !Target.client)
				del Target
				return
			var/month = text2num(time2text(world.realtime+Target.time_offset,"MM"))
			var/day = text2num(time2text(world.realtime+Target.time_offset, "DD"))
			var/XML/Element/root = xmlRootFromFile("./data/xml/quotes/quotes[month].xml")
			if(!root) return
			var/list/Quotes = root.Descendants("quote")
			if(day > Quotes.len) day = Quotes.len
			var/XML/Element/Quote = Quotes[day]
			Home.QOTD = TextMan.ParseTags(Quote.Text(), Target.show_colors, Target.show_highlight)

			if(Home.QOTD)
				if(Target.show_colors)
					Target << output("<b>[fadetext("Quote of the Day", list("102102255","255204000"))]:</b>", "[ckey(Target.Chan.name)].chat.default_output")
				else
					Target << output("<b>Quote of the Day:</b>", "[ckey(Target.Chan.name)].chat.default_output")
				Target << output("<i style='font-family: Verdana'>[Home.QOTD]</i>\n", "[ckey(Target.Chan.name)].chat.default_output")


		// Simple string matching procedure.
		// Crashed, C*a*h*d will match.
		// Crashed, Crah*d will not (missing s).
		// Crashed, Crash* will match.
		// Crashed, Crash will not (missing ed).
		Match(string, pattern)
			if(!string || !pattern) return 0

			var parts[] = list()
			var find = findtext(pattern, "*")
			var startWild = find == 1
			var endWild = text2ascii(pattern, length(pattern)) == 42 // '*'

			while(find)
				if(find > 1) parts += copytext(pattern, 1, find)
				pattern = copytext(pattern, find + 1)
				find = findtext(pattern, "*")

			if(pattern) parts += pattern

			if(!parts.len) return 1 // "*" pattern

			find = findtext(string, parts[1])
			if(!find || (!startWild && find != 1)) return 0

			find += length(parts[1])
			parts.Cut(1, 2)

			for(var/part in parts)
				find = findtext(string, part, find)
				if(find) find += length(part)
				else return 0

			return endWild || find == length(string)+1

		fadetext(var/text, var/list/colors)
			if(!colors) return text

			if((!text) || (!length(text)))
				return	0


			if((!colors) || (!colors.len))
				return text

			// text = xo_strip_html(text)

			var/list/links = new()

			var/list/textNlinks = skip_links(text, links)
			text = textNlinks[1]
			links = textNlinks[2]

			if(!length(text)) return 0

			var/list/Text = text2list(text)

			var/list/treds = new()
			var/list/tgreens = new()
			var/list/tblues = new()

			var/list/red_delta = new()
			var/list/green_delta = new()
			var/list/blue_delta = new()

			var/color_span = length(text)

			var/tr = 0
			var/tg = 0
			var/tb = 0

			for(var/x = 1, x <= colors.len, x++)
				treds += text2num(copytext(colors[x],1,4))
				tgreens += text2num(copytext(colors[x],4,7))
				tblues += text2num(copytext(colors[x],7))

			if(colors.len == 1)
				return "<font color=[rgb(treds[1],tgreens[1],tblues[1])]>[text]</font>"

			if(colors.len >= 2)
				color_span = round(color_span / (colors.len - 1))
				if(!color_span) color_span = 0.01

				for(var/x = 2, x <= colors.len, x++)
					red_delta += (treds[x-1] - treds[x]) / color_span
					green_delta += (tgreens[x-1] - tgreens[x]) / color_span
					blue_delta += (tblues[x-1] - tblues[x]) / color_span

			else
				red_delta += color_span
				green_delta += color_span
				blue_delta += color_span

			if(color_span < 1)
				for(var/n = 1, n <= Text.len, n++)
					Text[n] = "<span style='color: rgb([treds[n]],[tgreens[n]],[tblues[n]]);'>[Text[n]]</span>"

				return list2text(restore_links(Text, links))

			for(var/x = 1, x <= colors.len - 1, x++)
				tr = treds[x]
				tg = tgreens[x]
				tb = tblues[x]

				var/segment_start = ((x * color_span) - color_span) + 1
				var/segment_end = x * color_span

				if(x == (colors.len - 1))
					segment_end = length(text)

				for(var/t = segment_start, t <= segment_end, t++)
					Text[t] = "<font color=[rgb(tr,tg,tb)]>[Text[t]]</font>"

					tr -= red_delta[x]
					tg -= green_delta[x]
					tb -= blue_delta[x]

			return list2text(restore_links(Text, links))


		strip_html(var/text)
			if((!text) || (!length(text)))
				return
			if(!findtext(text, "<"))
				return text
			var/pos = findtext(text, "<")
			while(pos)
				var/pos2 = findtext(text, ">", pos)
				if(pos2)
					if(findtext(text, "<", pos+1, pos2-1))
						pos = findtext(text, "<", pos2)
						continue
					var/part1 = copytext(text, 1, pos)
					var/part2 = copytext(text, pos2 + 1)
					text = part1 + part2
					pos = findtext(part2, "<")
					if(pos)
						pos += length(part1)
				else pos = findtext(text, "<", pos+1)
			return text


		skip_links(var/text, var/list/links)
			var/pos1 = findtext(text,"http://")
			if(!pos1) pos1 = findtext(text, "byond://")
			if(!pos1) pos1 = findtext(text, "telnet://")
			if(!pos1) pos1 = findtext(text, "irc://")
			if(!pos1) pos1 = findtext(text, "<img ")
			if(pos1)
				var/pos2
				var/part1
				var/link
				var/link_hold
				var/part2
				var/text_copy
				while(pos1)
					pos2 = findtext(text,"<",pos1)
					if(!pos2)
						pos2 = findtext(text," ",pos1)
					if(!pos2)
						pos2 = findtext(text,ascii2text(9),pos1)	// tab character
					if(!pos2)
						pos2 = findtext(text, ascii2text(10),pos1)	// newline character
					if(!pos2) pos2 = length(text)+1

					part1 = copytext(text, 1, pos1)
					link = copytext(text, pos1, pos2)
					part2 = copytext(text, pos2)
					link_hold = ""

					for(var/i = length(link), i>0, i--)
						link_hold += "Ÿ"

					pos1 = findtext(part2, "http://")
					if(!pos1) pos1 = findtext(part2, "byond://")
					if(!pos1) pos1 = findtext(part2, "telnet://")
					if(!pos1) pos1 = findtext(part2, "irc://")
					if(!pos1) pos1 = findtext(text, "<img ")
					text = part2

					if(!pos1)
						text_copy += part1 + link_hold + part2
					else
						text_copy += part1 + link_hold

					if(!links || !links.len) links = new()
					links += link

				text = text_copy

			return list(text, links)


		restore_links(var/list/L, var/list/links)
			if(!L) return
			if(!links) return L

			var/pos = 1

			while(links.len)
				for(var/l = pos, l <= L.len+1, l++)
					pos = l
					if(!findtext(L[l], "Ÿ"))
						continue
					else
						L[l] = links[1]
						break

				for(var/l = 0, l < length(links[1])-1, l++)
					L -= L[pos+1]

				links -= links[1]

			return L

		FilterChat(msg, mob/chatter/C)
			if(!msg) return
			var/filter = 0
			if(!C) filter = 2
			else filter = C.filter
			if(!filter) return msg
			var/list/filter_list
			switch(filter)
				if(1)
					if(!C.filtered_words || !C.filtered_words.len) return msg
					filter_list = C.filtered_words
				if(2)
					if(!Home || !Home.filtered_words || !Home.filtered_words.len) return msg
					filter_list = Home.filtered_words

			if(filter_list.len)
				for(var/word in filter_list)
					if(!word) continue
					var/whole
					var/trueword
					if(text2ascii(word)<=32)
						trueword = copytext(word,2)
						if(!trueword) continue
						whole = 1
					else
						trueword = word
						whole = 0
					var/i, wl=length(trueword), rl=length(filter_list[word]), ch
					i = findtext(msg, trueword)
					while(i)
						if(whole)
							if(i>1)
								ch = text2ascii(msg, i-1)
								if((ch>=65 && ch<=90) || (ch>=97 && ch<=122) || (ch>=48 && ch<=57))
									i = findtext(msg, trueword, i+wl)
									continue
							if(i+wl<=length(msg))
								ch = text2ascii(msg, i+wl)
								if((ch>=65 && ch<=90) || (ch>=97 && ch<=122) || (ch>=48 && ch<=57))
									i = findtext(msg, trueword, i+wl)
									continue
						msg = copytext(msg,1,i) + ChooseCaps(filter_list[word],msg,i,wl) + copytext(msg, i+wl)
						i = findtext(msg, trueword, i+rl)
			return msg

		ChooseCaps(replace, source, index, len)
			var/i,ch
			for(i=0, i<len, ++i)
				ch = text2ascii(source, index + i)
				if(ch>=97 && ch<=122) return replace
				if(ch>=65 && ch<=90) break
				if(index>1) return replace
			for(++i, i<len, ++i)
				ch = text2ascii(source, index + i)
				if(ch>=97 && ch<=122) break
				if(ch>=65 && ch<=90) return uppertext(replace)
				if(index>1) return replace
			return uppertext(copytext(replace,1,2))+copytext(replace,2)

		lTrim(txt)
			if(!txt) return
			for(var/i=1, i <= length(txt), i++)
				if(text2ascii(txt, i) > 32)
					return copytext(txt, i)

		rTrim(txt)
			if(!txt) return
			for(var/i=length(txt), i >= 1, i--)
				if(text2ascii(txt, i) > 32)
					return copytext(txt, 1, i+1)

		Trim(txt)
			return rtrim(ltrim(txt))

		List(text)
			if(length(text) <= 1)return list(text)
			var/list/List = ListMan.Open()
			for(var/i = 1, i <= length(text), i++) List += copytext(text, i, i+1)
			return List


		hex2dec(hex)
			hex = (uppertext(hex) || "0")
			var/dec, step = 1
			var/hexlist = list( "0"=0, "1"=1, "2"=2, "3"=3,
								"4"=4, "5"=5, "6"=6, "7"=7,
								"8"=8, "9"=9, "A"=10,"B"=11,
								"C"=12,"D"=13,"E"=14,"F"=15)
			var/hexes = invertList(text2list(hex))
			for(var/h in hexes)
				dec += hexlist[h] * step
				step *= 16
			return dec

		check_links(var/text, var/byond)	// checks for unauthorized links
			if(!text) return	// if no text passed, return

			var/pos
			if(byond) // byond links
				pos = findtext(text, "byond://")
			else
				pos = findtext(text, "<a")	// get the pos of the first link
				if(!pos)
					pos = findtext(text, "<A")	// could be capitalized

			while(pos)		// if a link was found
				sleep(1)	// so we don't lock up the program

				var
					quest = 0	// position of the ? in the link
					_src = 0		// position of the src
					action = 0	// position of the action
					pos2 = 0		// position of the closing bracket of the opening link tag
					link = ""		// the link tag from opening to closing brackets
					part1 = ""		// the part of the text before the opening link tag
					part2 = ""		// the part of the text after the opening link tag
				if(byond)
					pos2 = findtext(text, " ", pos)
					if(!pos2)
						pos2 = findtext(text, "\t", pos)
						if(!pos2)
							pos2 = findtext(text, "\n", pos)
							if(!pos2) pos2 = length(text)
				else
					pos2 = findtext(text, ">", pos)			// get the position of the closing bracket
				link = copytext(text, pos, pos2 + 1)	// get the opening link tag

				quest = findtext(link, "?")			// find the ? in the opening link tag
				if(quest)							// if we found the ?
					_src = findtext(link, "src", quest)	// find the src after the ?'s position
				if(_src)								// if we found the src after ?'s position
					action = findtext(link, "action", _src)	// find the action after src's posiiotn
				if(action)							// if we found the action, this must be an unauthorized link
					part1 = copytext(text, 1, pos)		// get the text before the opening link tag
					part2 = copytext(text, pos2 + 1)	// get the text after the opening link tag
					if(byond)
						text = part1 + part2
					else
						text = part1 + "<a href='?action=unauth_link;'>" + part2	// combine the two parts with a new opening link tag

				if(byond)
					pos = findtext(text, "byond://", pos2 + 1)
				else
					pos = findtext(text, "<a", pos2 + 1)	// check for another opening link tag after the previous opening tag's closing bracket
					if(!pos)
						pos = findtext(text, "<A", pos2 + 1) // also check for capitalization
			return text	// return the text when no more links are found


		remove_script(var/T as text)
			if(!T) return
			var/pos = findtext(T, "<script")
			if(pos)
				while(pos)
					var/part1 = copytext(T, 1, pos)
					var/part2 = copytext(T, pos+7)
					T = part1 + part2
					pos = findtext(T, "<script")
			return T


		escapeQuotes(text)
			text = dd_replaceText(text, "\\", "\\\\")
		//	text = dd_replaceText(text, "\"", "\\\"")
			text = dd_replaceText(text, "'" , "\\'" )
			return text
