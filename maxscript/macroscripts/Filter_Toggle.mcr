macroScript outliner_filter_toggle 
	category:"Outliner" 
	toolTip:"Outliner Toggle Filter" 
	buttonText:"Toggle Filter"
	icon:#("Outliner_main", 4)
(
   global outliner;
	global outliner_status;
	   
   on isEnabled do outliner_status != undefined AND \
                   outliner_status.windowOpen;
   
   on isChecked do outliner_status != undefined AND \
                   outliner_status.windowOpen AND \
                   (outliner.getFilterEnabled());
                   
   on execute do (
      if (outliner != undefined  AND \
          outliner_status != undefined AND \
          outliner_status.windowOpen) do
         outliner.setFilterEnabled (not (outliner.getFilterEnabled()));
   )
)