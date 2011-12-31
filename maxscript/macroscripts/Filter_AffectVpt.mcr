macroScript outliner_filter_affectvpt 
	category:"Outliner" 
	toolTip:"Filter Affects Viewport" 
	buttonText:"Filter Affects Viewport"
	icon:#("Outliner_filters", 14)
(
   global outliner;
	global outliner_status;
	global outliner_main;
	   
   on isEnabled do outliner_status != undefined AND \
                   outliner_status.windowOpen AND \
                   (outliner.getFilterEnabled());
   
   on isChecked do outliner_status != undefined AND \
                   outliner_status.windowOpen AND \
                   (outliner.prefs.getValue #Tree #objFilterAffectVpt);
                   
   on execute do (
      if (outliner != undefined  AND \
          outliner_status != undefined AND \
          outliner_status.windowOpen) do
      (
         local enable = not (outliner.prefs.getValue #Tree #objFilterAffectVpt);
         outliner.prefs.setValue #Tree #objFilterAffectVpt enable;
         outliner_main.setHideByCategory forceSet:true;
      )
   )
)