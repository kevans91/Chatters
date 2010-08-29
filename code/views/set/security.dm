Settings
	Security
		proc
			holder()
			BrowseSecurity()
				set hidden = 1
				var/SetView/Set = new()
				Set.Display(src, "security")
				del(Set)
