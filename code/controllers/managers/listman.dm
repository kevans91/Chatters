
ListManager

	proc
		isList(list/L)
			return istype(L, /list)

		Open(list/L)
			if(!L || !L.len) L = new()
			return L

		Add(list/L)
			L = Open(L)
			var/list/arguments = Open(args)
			arguments = args.Copy(2)
			return L.Add(arglist(arguments))

		Remove(list/L)
			if(!L || !L.len) return
			var/list/arguments = Open(args)
			arguments = args.Copy(2)
			var/result = L.Remove(arglist(arguments))
			Close(arguments)
			Close(L)
			return result

		Close(list/L)
			if(L && !L.len) L = null

		Text(list/L)
			if(!islist(L)) return
			var/text = ""
			for(var/l in L) text += "[l]"
			Close(L)
			return text

		Invert(list/L)
			L = Open(L)
			if(L.len)
				var/head = 1, tail = L.len
				while((head != tail) && (head != tail+1))
					L.Swap(head++,tail--)
			return L

		Stack(var/list/L, var/item, var/list_len)
			L = Open(L)
			if(!L.len)
				L += item
				return L
			if(L.len < list_len)
				L += item
				return L
			var/list/L2[list_len]
			for(var/i = 2, i <= list_len, i++)
				L2[i-1] = L[i]
			L2[list_len] = item
			Close(L)
			return L2

		atomSort(list/L)
			L = Open(L)
			var/atom/A1
			var/atom/A2
			if(L.len > 1)
				for(var/i=L.len, i>0, i--)
					for(var/j=1, j<i, j++)
						A1 = L[j]; A2 = L[j+1]
						if(!istype(A1) || !istype(A2)) continue
						if(ckey(A1.name) > ckey(A2.name))
							L.Swap(j, j+1)
			Close(L)
			return L