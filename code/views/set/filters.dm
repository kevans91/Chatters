Settings
	Filters
		proc
			BrowseFilters()
				set hidden = 1
				var/SetView/Set = new()
				Set.Display(src, "filters")
				del(Set)

			UpdateFilters()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				call(C, "ShowFilterList")()
				winset(C, "filters.updated", "is-visible=true")
				var/save = winget(C, "filters.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "filters.saved", "is-visible=true")
				sleep(50)
				winset(C, "filters.updated", "is-visible=false")
				winset(C, "filters.saved", "is-visible=false")

			SetDefaultFilters()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				var/save = winget(C, "filters.save", "is-checked")
				if(save == "true")
					C.winsize = winget(C, "default", "size")
					ChatMan.Save(C)
					winset(C, "filters.saved", "is-visible=true")
				sleep(50)
				if(C && C.client)
					winset(C, "filters.updated", "is-visible=false")
					winset(C, "filters.saved", "is-visible=false")

			ShowFilterList(list/L)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				if(!L) switch(C.filter)
					if(0)
						L = list("No filtered words")
					if(1)
						if(C.filtered_words)
							L = C.filtered_words
						else
							L = list("No filtered words")
					if(2)
						if(Home) L = Home.filtered_words
						else
							winset(C, "filters.chan_filter", "is-disabled=true;")
							L = list("No filtered words")
				if(C.filter==1)
					winset(C, "filters.filtered_word_label", "text-color='#333';")
					winset(C, "filters.replacement_word_label", "text-color='#333';")
					winset(C, "filters.filtered_word_input", "is-disabled=false;background-color='#FFF';")
					winset(C, "filters.replacement_word_input", "is-disabled=false;background-color='#FFF';")
					winset(C, "filters.add_word", "is-disabled=false;")
					winset(C, "filters.remove_word", "is-disabled=false;")
				else
					winset(C, "filters.filtered_word_label", "text-color='#BBB';")
					winset(C, "filters.replacement_word_label", "text-color='#BBB';")
					winset(C, "filters.filtered_word_input", "is-disabled=true;background-color='#CCC';")
					winset(C, "filters.replacement_word_input", "is-disabled=true;background-color='#CCC';")
					winset(C, "filters.add_word", "is-disabled=true;")
					winset(C, "filters.remove_word", "is-disabled=true;")
				if(Home)
					winset(C, "filters.chan_filter", "is-disabled=false;")
				for(var/i=1, i<=L.len, i++)
					if(i&1)
						winset(C, "filters.grid", "style='body{background-color:#CCC;}';")
					else
						winset(C, "filters.grid", "style='body{background-color:#DDD;}';")
					winset(C, "filters.grid", "current-cell=1,[i]")
					C << output(L[i], "filters.grid")
					winset(C, "filters.grid", "current-cell=2,[i]")
					C << output(L[L[i]], "filters.grid")
				winset(C, "filters.grid", "cells=2x[L.len]")

			SetFilter(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				if(!t) t = "0"
				switch(t)
					if("0")
						C.filter = 0
						call(C, "ShowFilterList")()
						winset(C, "filters.no_filter", "is-checked=true")
						winset(C, "filters.my_filter", "is-checked=false")
						winset(C, "filters.chan_filter", "is-checked=false")
					if("1")
						C.filter = 1
						call(C, "ShowFilterList")(C.filtered_words)
						winset(C, "filters.no_filter", "is-checked=false")
						winset(C, "filters.my_filter", "is-checked=true")
						winset(C, "filters.chan_filter", "is-checked=false")
					if("2")
						C.filter = 2
						if(Home) call(C, "ShowFilterList")(Home.filtered_words)
						winset(C, "filters.no_filter", "is-checked=false")
						winset(C, "filters.my_filter", "is-checked=false")
						winset(C, "filters.chan_filter", "is-checked=true")

			AddWord()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				var/f_word = winget(C, "filters.filtered_word_input", "text")
				var/r_word = winget(C, "filters.replacement_word_input", "text")
				if(!f_word || !r_word) return
				if(!C.filtered_words) C.filtered_words = new
				if(!(f_word in C.filtered_words)) C.filtered_words += f_word
				C.filtered_words[f_word] = r_word
				call(C, "ShowFilterList")()

			RemoveWord()
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				var/f_word = winget(C, "filters.filtered_word_input", "text")
				var/r_word = winget(C, "filters.replacement_word_input", "text")
				if(!f_word && !r_word) return
				if(!C.filtered_words) return
				if(f_word in C.filtered_words) C.filtered_words -= f_word
				if(r_word) for(var/word in C.filtered_words)
					if(C.filtered_words[word] == r_word)
						C.filtered_words -= word
				call(C, "ShowFilterList")()

			SetFilteredWord(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				winset(C, "filters.filtered_word_input", "text='[t]';")

			SetReplacementWord(t as text|null)
				set hidden = 1
				var/mob/chatter/C = usr
				if(!C) return
				winset(C, "filters.replacement_word_input", "text='[t]';")
