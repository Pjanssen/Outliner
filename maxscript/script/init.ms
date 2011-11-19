try ( outliner.closeOutliner() ) catch (); --Just to make sure everything is closed.

--Pair structure for general use.
struct Pair
(
	key,
	value
)

--Define global objects.
global outliner;
global outliner_callbacks;
global outliner_sceneFunctions;
global outliner_status;
global outliner_update;
global outliner_crash_report;
--Define rollout globals.
global outliner_main;
global outliner_sortmode;
global outliner_filter_config;
global outliner_options;
global outliner_layerprops;

	
	
if (outliner_restart_required == true) then
	Messagebox "Please restart 3dsmax before using the Outliner." title:"Restart required";
else
(
	--Import scripts.
	fileIn "helperFunctions.ms";
	fileIn "keyboardActionsFile.ms";
	fileIn "nestedLayers.ms";
	fileIn "preferences.ms";
	fileIn "sceneFunctions.ms";
	fileIn "callbacks.ms";
	fileIn "treeEventHandlers.ms";
	fileIn "ui/main.ms";
	fileIn "ui.ms";
	fileIn "update.ms";
	fileIn "core.ms";
	
	outliner = outlinerCore();
	if (not outliner.init()) do
		outliner = undefined;
)