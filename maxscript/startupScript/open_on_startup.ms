(
	function outliner_get_instance =
	(
		global outliner;
		if outliner == undefined do
			fileIn ((getDir #userScripts) + "/outliner/init.ms");
		outliner;
	)
	
	local prefsFile = ((GetDir #userScripts) + "/outliner_prefs.ini");
	
	local open = getINISetting prefsfile "General" "openAtStartup";
	if (open != "") then
		try ( open = open as BooleanClass; ) catch ( open = false; )
	else
		open = false;
	
	if (open) do
	(
		local outlinerInst = outliner_get_instance();
		if (outlinerInst != undefined) do
			outlinerInst.open();
	)
)