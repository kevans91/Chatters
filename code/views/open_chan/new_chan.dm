
OpenChannel
	var/new_html = {"
<body onLoad="hidediv('required');">
<style>
body {
	color: #333333;
	background-color: #ffffff;
	font-family: Verdana;
}

#required {
	color: #ff0000;
	font-weight: bold;
	display: none;
	text-align: center;
	width: 100%;
	margin: 10px auto 10px 25px;
}

.note {
	float: right;
}

.heading {
	font-size: 18px;
	font-weight: bold;
}

.input {
	width: 380px;
	margin-left: 25px;
}

.pass {
	margin-left: 25px;
}

.custom {
	margin-top: 0px;
}
</style>
<script language="javascript">
<!--

function getname() {
	document.getElementById("act").value="namecheck";
	document.Form.submit();
	document.getElementById("act").value="newchan";
}

function getLabel(element) {
	var label;
	if(element.parentNode.tagName.toLowerCase() == "label") {
		label = element.parentNode;
	}else{
		var labels = element.parentNode.getElementsByTagName('label');
		if(labels.length==1){
			label = labels\[0];
		}else{
			labels = document.getElementsByTagName('label');
			for(var i=0; i<labels.length; i++) {
				if(labels\[i].getAttribute('htmlfor') == element.name ||
					labels\[i].getAttribute('for') == element.name) {
					label = labels\[i];
					break;
				}
			}
		}
	}
	return label;
}

function hidediv(id) {
	//safe function to hide an element with a specified id
	if (document.getElementById) { // DOM3 = IE5, NS6
		document.getElementById(id).style.display = 'none';
	}
	else {
		if (document.layers) { // Netscape 4
			document.id.display = 'none';
		}
		else { // IE 4
			document.all.id.style.display = 'none';
		}
	}
}

function showdiv(id) {
	//safe function to show an element with a specified id

	if (document.getElementById) { // DOM3 = IE5, NS6
		document.getElementById(id).style.display = 'block';
	}
	else {
		if (document.layers) { // Netscape 4
			document.id.display = 'block';
		}
		else { // IE 4
			document.all.id.style.display = 'block';
		}
	}
}

function check(input) {
	var result = true;
	var label = getLabel(input);

	if(!input.value) {
		if(label) {
			label.style.color = '#ff0000';
			label.style.backgroundColor = '#fff';
			showdiv('required');
		}
		result = false;
	} else {
		if(label) {
			label.style.color = '#000';
			label.style.backgroundColor = '#fff';
		}
	}

	return result;
}

function valid(form) {
	var inputs = Array(form.Name, form.Pass, form.Confirm)
	var result = true;

	hidediv('required');

	for(var i=0; i<inputs.length; i++) {
		if(!check(inputs\[i])) {
			result = false;
		}
	}

	return checkPass(result);
}

function checkPass(result) {
	if(result) {
		pass = document.Form.Pass.value;
		conf = document.Form.Confirm.value;
		if(pass != conf) {
			alert("Your password and confirmation did not match. Please retype them carefully.");
			result = false;
		}
	}
	return result;
}
// -->
</script>

<div id="required">Please fill out all required fields</div>

<div class="note">* denotes mandatory field</div>
<div class="heading">New Channel Settings</div>
<form name="Form" method=get action="byond://?" onSubmit="return valid(this)">
	<input type="hidden" name="dest" value="chanman">
	<input id="act" type="hidden" name="action" value="newchan">
	*<b><label for="Name">Name:</label></b> <a href="javascript:getname();">check for availability</a>
	<br><input class="input" type="text" name="Name"><br><br>

	<b><label for="Publicity">Publicity:</label></b>
	<br><select class="input" name="Publicity">
		<option value="public">Public - Added to the Channel Listing</option>
		<option value="private">Private - Shown to users in your Notify List</option>
		<option value="invisible">Invisible - Not listed anywhere</option>
	</select><br><br>

	<b><label for="Desc">Description:</label></b>
	<br><input class="input" type="text" name="Desc" value="No description available."><br><br>

	<b><label for="Topic">Topic:</label></b>
	<br><input class="input" type="text" name="Topic" value="No topic set. For a list of available commands, type /help."><br><br>

	*<b><label for="Pass">Password:</label></b>
	<br><input class="pass" type="password" name="Pass">
	<b><label for="Confirm">Confirm:</label></b>
	<input type="password" name="Confirm"><br><br>

	<b><label for="Lock">Channel Lock:</label></b> (requires password to join)
	<br><input class="pass" type="radio" name="Lock" value="true">Locked
	<input type="radio" name="Lock" value="false" checked>Unlocked<br><br>

	<b><label for"TelPass">Telnet Password:</label></b>
	<br><input class="pass" type="password" name="TelPass">
	<b><label for="TelAtmpts">Attempts:</label></b>
	<input name="TelAtmpts" size=3 maxlength=3 value=3> (0 for no limit)<br><br>

	<b>Custom Options:</b><ul class="custom">
		<li><a href="?">Operators</a> - OP statuses, priviledges, settings...</li>
		<li><a href="?">ChanBot</a> - Channel Bot name, colors, triggers, events...</li>
		<li><a href="?">Filter</a> - Channel Filter filtered words, replacement words...</li>
		<li><a href="?">Spam Guard</a> - Spam limit, icon limit, flood limit, kick limit...</li>
		<li><a href="?">Events</a> - Channel events, chatter join, chatter quit...</li>
		<li><a href="?">Triggers</a> - !help, !rules, !topic...</li>
		<li><a href="?">Avatars</a> - Custom avatar images</li>
		<li><a href="?">Icons</a> - Custom channel icons</li>
		<li><a href="?">Styles</a> - Colors, fonts, say formats...</li>
	</ul>

	<input type="submit" value="Create My Channel">
	<input type="reset" value="Reset">
</form>
"}