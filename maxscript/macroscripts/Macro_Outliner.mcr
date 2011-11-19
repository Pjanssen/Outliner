macroScript toggleOutliner 
	category:"Outliner" 
	toolTip:"Open/Close Outliner Window" 
	buttonText:"Open/Close Outliner Window"
	icon:#("Outliner", 1)
(
	global outliner;
	global outliner_status;

	function outliner_get_instance =
	(
		if outliner == undefined do
			fileIn ((getDir #userScripts) + "/outliner/init.ms");
	
		outliner;
	)
	
	
	on isChecked do 
	(
		if (outliner_status == undefined OR outliner_status.windowOpen == false) then
			false;
		else
			outliner_status.windowOpen;
	)
	
	on execute do 
	(
		local outlinerInst = outliner_get_instance();
		if (outlinerInst != undefined) do
		(
			if (outliner_status == undefined OR outliner_status.windowOpen == false) then
				outlinerInst.open();
			else
				outlinerInst.close();
		)
	)
		
)