try ( outliner.closeOutliner() ) catch (); --Just to make sure everything is closed.

--Pair structure for general use.
struct Pair
(
   key,
   value
)

--Define required globals
global outliner;
global outlinerCore;
global outliner_callbacks;
global outliner_status;
global outliner_main;
global outliner_update;
global outliner_convertLegacyNestedLayers;
   
   
if (outliner_restart_required == true) then
   Messagebox "Please restart 3dsmax before using the Outliner." title:"Restart required";
else
(
   --Import scripts.
   fileIn "nestedLayers.ms";
   fileIn "preferences.ms";
   fileIn "callbacks.ms";
   fileIn "treeEventHandlers.ms";
   fileIn "ui/filter_config.ms";
   fileIn "ui/options.ms";
   fileIn "ui/layer_properties.ms";
   fileIn "ui/sortmode.ms";
   fileIn "ui/main.ms";
   fileIn "ui.ms";
   fileIn "update.ms";
   fileIn "core.ms";
   
   --Import legacy support scripts.
   fileIn "legacy_support/legacy_nestedlayers.ms";
   
   outliner = outlinerCore();
   if (not outliner.init()) do
      outliner = undefined;
)