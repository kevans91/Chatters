
ErrorManager	// Handles all error reporting

	Topic(ErrCode,Info)
		var/ErrMsg = "Unknown Error"
		switch(ErrCode)
			if("100") ErrMsg = "Unable to locate network configuration file: network.cfg"
			if("101") ErrMsg = "Undefined network $name in network configuration file network.cfg"
			if("102") ErrMsg = "Undefined network $desc in network configuration file network.cfg"
			if("103") ErrMsg = "Undefined network $addr in network configuration file network.cfg"
			if("104") ErrMsg = "Undefined network $port in network configuration file network.cfg"
			if("105") ErrMsg = "Undefined network $host in network configuration file network.cfg"

			if("200") ErrMsg = "Unable to open port: [Info]"

			if("300") ErrMsg = "Unable to locate help contents file: contents.xml"
			if("301") ErrMsg = "Unable to load help XML file: contents.xml"
			if("302") ErrMsg = "Unable to load help topics XML"

		CRASH("[ErrCode] : [ErrMsg]")