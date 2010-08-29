
LogManager	// Defines the default error logging scheme
			// and provides a means to log non-error
			// info as well as create backups of logs

	New()
		..()
		BackupLog()
		InitLog()

	var
		// The error log file
		logfile = "log.txt"

		// Toggles backing up error logs on shutdown
		logback = 0	// so that new sessions each have their own log
					// Backups are re-named with the date and time they were saved


	proc
		Log(T)	// Used to log information
			if(!logfile) // If no logging defined
				world.log << T // Revert to default world.log

			else // Otherwise...
				logfile << T


		InitLog() // Initializes the log file
			if(logfile) // If a logfile is defined

				if(!fexists("./data/saves/logs/[logfile]"))
					new/savefile("./data/saves/logs/[logfile]")
					fdel("./data/saves/logs/[logfile]")

				// Initialize it as a writable file handler
				logfile = file("./data/saves/logs/[logfile]")

				// And also send runtime errors to this file
				world.log = logfile


		BackupLog() // Backs up the log file
			if(logfile && logback && length(file2text("./data/saves/logs/[logfile]")))
				// If a logfile is defined, and backups are requested
				// and the log is not empty

				// Create a new backup with the dat.tim.bak.txt naming convention
				var/backfile = file("./data/saves/logs/[time2text(world.realtime,"MMDDYY.hhmmss")].bak.txt")

				// Export the text contents of the logfile into the backup
				backfile << file2text("./data/saves/logs/[logfile]")

				// And delete the old log file
				world.log = null // Remove its reference to the world.log now
				fdel("./data/saves/logs/[logfile]")// Or the file will not be free to delete
