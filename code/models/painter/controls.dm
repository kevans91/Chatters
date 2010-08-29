
mob
	chatter
		verb
			Paint()
				if(!Painter)
					PaintMan.NewView(src)
				else
					Painter.Paint.Display(src)

			NewImage()
				set hidden = 1
				if(!Painter) return
				del(Painter)
				Paint()

			LoadImage()
				set hidden = 1
				if(!Painter) return
				Painter.Paint.Load(src)

			SaveImage()
				set hidden = 1
				if(!Painter) return
				Painter.Paint.Save(src)

			Undo()
				set hidden = 1
				if(Painter)
					Painter.Paint.restoreUndo(src)

			Redo()
				set hidden = 1
				if(Painter)
					Painter.Paint.restoreRedo(src)
