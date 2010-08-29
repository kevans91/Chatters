
PaintManager

	var/list
		Views
		Painters
		icon_cache = new() // Stores colored canvas icons for reuse

	proc
		NewView(mob/chatter/owner)
			if(!owner || !ismob(owner) || !owner.client || owner.telnet) return
			var/PaintView/PV = new()
			PV.Initialize(owner)
			Painters = listOpen(Painters)
			Painters += owner
			Views = listOpen(Views)
			Views += PV

		GetView()

		DelView(PaintView/PV)
			del(PV)

		line(x0,y0,x1,y1) // returns a list of x,y coordinates that form a line
			// starting from the x0,y0 coordinate and finishing at x1,y1
			// ex: list(x0,y0,...x1,y1)
			var/east, C, ystep, L[0]
			var/steep = (abs(y1 - y0) > abs(x1 - x0)) ? 1 : 0
			if(steep)
				swapVars(x0, y0, C)
				swapVars(x1, y1, C)
			if(x0 > x1)
				swapVars(x0, x1, C)
				swapVars(y0, y1, C)
			else east = 1
			var/dx = x1 - x0
			var/dy = abs(y1 - y0)
			var/error = dx / 2
			var/y = y0
			if(y0 < y1) ystep = 1
			else ystep = -1
			for(var/x=x0,x<=x1,x++)
				if(steep)
					L += y
					L += x
				else
					L += x
					L += y
				error -= dy
				if(east)
					if(error <= 0)
						y += ystep
						error += dx
				else
					if(error < 0)
						y += ystep
						error += dx
				sleep(-1)
			.=L

		// BYOND's very own Oval algorithm
		// Courtesy of Tom ^_^
		ellipse(x1, y1, x2, y2, fill)
			var/C, L[0]
			if(x1>x2)
				swapVars(x1,x2,C)
			if(y1>y2)
				swapVars(y1,y2,C)

			var/a2 = x2-x1, b2 = y2-y1
			var/x3 = round(x1+a2/2), x4 = x1+x2-x3
			var/y3 = y1, y4 = y2
			var/ox2=(a2++)%2, oy2=b2++
			var/a2sq=a2*a2, b2sq=b2*b2
			var/sq=ox2*b2sq-(oy2+b2)*a2sq
			a2sq*=4; b2sq*=4

			while(x3>x1)
				while(sq<=0)
					if(fill)
						fillbound(x3,y3,x4,y4,L,C)
					else drawbound(x3,y3,x4,y4,L)
					--x3; ++x4; sq+=(ox2+1)*b2sq; ox2+=2
				if(++y3<=--y4) {oy2-=2; sq-=(oy2+1)*a2sq}
				else {--y3;++y4;--x3;++x4}
				if(sq>0 && x3>=x1)
					if(!fill)
						++x3; --x4
						do
							drawbound(x3,y3,x4,y4,L)
							oy2-=2; sq-=(oy2+1)*a2sq
							if(++y3>--y4) {--y3;++y4;break}
						while(sq>0)
						--x3; ++x4
					else
						do
							oy2-=2; sq-=(oy2+1)*a2sq
							if(++y3>--y4) {--y3;++y4;break}
						while(sq>0)
			fillbound(x1,y3,x2,y4,L,C)
			.=L