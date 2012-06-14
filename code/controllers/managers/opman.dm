
OperatorManager

	var
		list
			op_ranks
			op_privileges

	New()
		..()
		LoadXML()

	proc
		LoadXML()
			var/list/ranks = flist("./data/xml/ops/ranks/")
			op_ranks = listOpen(op_ranks)
			op_ranks.len = ranks.len
			for(var/rank in ranks)
				if(!findtext(rank, "xml", length(rank)-2)) continue
				var/XML/Element/rank_root = xmlRootFromFile("./data/xml/ops/ranks/[rank]")
				rank_root = rank_root.Descendant("oprank")
				if(!rank_root) return
				var/OpRank/Rank = new()
				Rank.name = rank_root.Attribute("name")
				Rank.select.name = Rank.name
				Rank.pos = text2num(rank_root.Attribute("pos"))
				Rank.color = rank_root.Attribute("color")
				Rank.monitor = text2num(rank_root.Attribute("monitor"))
				Rank.auto_approve = text2num(rank_root.Attribute("approve"))
				var/XML/Element/descXML = rank_root.Descendant("desc")
				if(descXML) Rank.desc = descXML.Text()
				var/XML/Element/promoteXML = rank_root.Descendant("promote")
				if(promoteXML) Rank.promote = promoteXML.Text()
				var/XML/Element/demoteXML = rank_root.Descendant("demote")
				if(demoteXML) Rank.demote = demoteXML.Text()
				var/XML/Element/tempXML = rank_root.Descendant("temp")
				if(tempXML)
					Rank.temp = 1
					Rank.expires = text2num(tempXML.Attribute("expires"))
				else Rank.temp = 0
				var/XML/Element/electXML = rank_root.Descendant("elect")
				if(electXML)
					Rank.elect = 1
					Rank.elect_by = electXML.Attribute("by")
					Rank.or_lower = text2num(electXML.Attribute("orlower"))
					if(!Rank.or_lower) Rank.or_higher = 1
					else Rank.or_higher = text2num(electXML.Attribute("orhigher"))
					Rank.max_elect = text2num(electXML.Attribute("max"))
				else Rank.elect = 0
				Rank.privs = new()
				var/XML/Element/privsXML = rank_root.Descendant("privileges")
				if(privsXML)
					for(var/XML/Element/Priv in privsXML.Descendants("privilege"))
						Rank.privs += Priv.Attribute("name")
				op_ranks[Rank.pos] = Rank
			for(var/r in op_ranks)
				if(isnull(r)) op_ranks -= r
			var/list/privs = flist("./data/xml/ops/privileges/")
			op_privileges = listOpen(op_privileges)
			op_privileges.len = privs.len
			for(var/priv in privs)
				if(!findtext(priv, "xml", length(priv)-2)) continue
				var/XML/Element/priv_root = xmlRootFromFile("./data/xml/ops/privileges/[priv]")
				priv_root = priv_root.Descendant("oppriv")
				if(!priv_root) return
				var/OpPrivilege/Priv = new()
				Priv.name = priv_root.Attribute("name")
				Priv.select.name = Priv.name
				Priv.monitor = text2num(priv_root.Attribute("monitor"))
				Priv.auto_approve = text2num(priv_root.Attribute("approve"))
				var/XML/Element/descXML = priv_root.Descendant("desc")
				if(descXML) Priv.desc = descXML.Text()
				var/XML/Element/executeXML = priv_root.Descendant("execute")
				if(executeXML) Priv.execute = executeXML.Text()
				var/XML/Element/commandXML = priv_root.Descendant("command")
				if(commandXML) Priv.command = commandXML.Text()
				var/XML/Element/electXML = priv_root.Descendant("elect")
				if(electXML)
					Priv.elect = 1
					Priv.elect_by = electXML.Attribute("by")
					Priv.or_lower = text2num(electXML.Attribute("orlower"))
					if(!Priv.or_lower) Priv.or_higher = 1
					else Priv.or_higher = text2num(electXML.Attribute("orhigher"))
					Priv.min_votes = abs(text2num(electXML.Attribute("min_votes")))
					Priv.min_delay = abs(text2num(electXML.Attribute("min_delay")))
					Priv.margin = abs(text2num(electXML.Attribute("margin")))
				else Priv.elect = 0
				op_privileges[Priv.name] = Priv
			for(var/p in op_privileges)
				if(isnull(p)) op_privileges -= p

		SaveRankXML(OpRank/Rank)
			if(!Rank) return
			var/XML/Element/mainXML = new("xml")
			var/XML/Element/rankXML = new("oprank")
			mainXML.AddChild(rankXML)
			var/list/rank_attributes = list("name"=Rank.name,"pos"="[Rank.pos]","color"=Rank.color)
			if(Rank.monitor) rank_attributes["monitor"] = "1"
			if(Rank.auto_approve) rank_attributes["approve"] = "1"
			rankXML.setAttributes(rank_attributes)
			var/XML/Element/descXML = new("desc")
			rankXML.AddChild(descXML)
			descXML.setText(Rank.desc)
			var/XML/Element/promoteXML = new("promote")
			rankXML.AddChild(promoteXML)
			promoteXML.setText(Rank.promote)
			var/XML/Element/demoteXML = new("demote")
			rankXML.AddChild(demoteXML)
			demoteXML.setText(Rank.demote)
			if(Rank.temp)
				var/XML/Element/tempXML = new("temp")
				rankXML.AddChild(tempXML)
				tempXML.setAttribute("expires",Rank.expires)
			if(Rank.elect)
				var/XML/Element/electXML = new("elect")
				rankXML.AddChild(electXML)
				electXML.setAttribute("by", Rank.elect_by)
				if(Rank.or_higher)
					electXML.setAttribute("orhigher", "1")
				electXML.setAttribute("max", Rank.max_elect)
			var/XML/Element/privsXML = new("privileges")
			rankXML.AddChild(privsXML)
			for(var/priv in Rank.privs)
				var/XML/Element/privXML = new("privilege")
				privsXML.AddChild(privXML)
				privXML.setAttribute("name", priv)
			mainXML.WriteToFile("./data/xml/ops/ranks/[Rank.name].xml")


