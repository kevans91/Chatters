
turf
	void
		name = ""
		icon = './resources/icons/atoms/turfs.dmi'
		icon_state = "void"

	default
		icon = './resources/icons/atoms/turfs.dmi'


obj
	default
		icon = './resources/icons/atoms/objects.dmi'

	selection
		var/obj/source

		New(Source)
			source = Source
			name = source.name
			..()

		Click(location, ctl)
			source.Click(usr, location, ctl)

		DblClick(location, ctl)
			source.DblClick(usr, location, ctl)

	help
		icon = './resources/icons/atoms/objects.dmi'

		chapter
			icon_state = "chapter"
			var/indent = 0
			var/list/open = new()

			proc
				open(mob/chatter/M)
					if(!M) return
					M << output(null, "contents_grid.output")
					winset(M, "contents_grid.output", "is-visible=false")
					icon_state = "chapter_open"
					open += M.name
					for(var/obj/help/chapter/C in world) C.display(M)
					winset(M, "contents_grid.output", "is-visible=true")

				close(mob/chatter/M)
					if(!M) return
					M << output(null, "contents_grid.output")
					winset(M, "contents_grid.output", "is-visible=false")
					icon_state = "chapter"
					open -= M.name
					for(var/obj/help/chapter/C in world) C.display(M)
					winset(M, "contents_grid.output", "is-visible=true")

				display(mob/chatter/M)
					if(!M) return
					if(src.loc && !(M.name in src.loc:open)) return
					if(M.name in open)
						M << output("<a href='byond://?dest=helpman&action=close&target=[url_encode(src.name)]' style='margin-left: [10*src.indent]px;color:#000000;text-decoration:none;'><img class=\"icon\" src=\"\ref[src.icon]\" iconstate=\"[src.icon_state]\">[src.name]</a>", "contents_grid.output")
						for(var/obj/help/topic/T in src) T.display(M)
					else
						M << output("<a href='byond://?dest=helpman&action=open&target=[url_encode(src.name)]' style='margin-left: [10*src.indent]px;color:#000000;text-decoration:none;'><img class=\"icon\" src=\"\ref[src.icon]\" iconstate=\"[src.icon_state]\">[src.name]</a>", "contents_grid.output")

		topic
			icon_state = "topic"
			var/indent = 1
			var/Text = "No help available."

			proc
				display(mob/chatter/M)
					if(!M) return
					if(src.loc && !(M.name in src.loc:open)) return
					M << output("<a href='byond://?dest=helpman&action=view_topic&page=contents&target=[url_encode(src.name)]' style='margin-left: [10*src.indent]px;color:#000000;text-decoration:none;'><img class=\"icon\" src=\"\ref[src.icon]\" iconstate=\"[src.icon_state]\">[src.name]</a>", "contents_grid.output")

				show(var/mob/chatter/M, page)
					if(!M) return
					winset(M, "[page]_output.info", "is-visible=false")
					winset(M, "[page]_output.globe", "is-visible=false")
					winset(M, "[page]_output.copy1", "is-visible=false")
					winset(M, "[page]_output.copy2", "is-visible=false")
					winset(M, "[page]_output.output", "is-visible=true")
					M << output(null, "[page]_output.output")
					M << output("\n<b>[src.name]</b>\n", "[page]_output.output")
					M << output(src.Text, "[page]_output.output")

