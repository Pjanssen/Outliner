--RUNNING THIS SCRIPT RESETS THE CURRENT MAXFILE WITHOUT PROMPT.
(
resetmaxfile #noPrompt;

global outlinerNestedLayers;

--Open the Outliner if it isn't opened already.
if (outliner_status == undefined OR not outliner_status.windowOpen) do
   assert(macros.run "Outliner" "toggleOutliner");

local l1 = LayerManager.newLayer();
local l2 = LayerManager.newLayer();
local fileName = (getdir #temp + "/nested_layers_merge_test.max");

outlinerNestedLayers.setParent l2 l1;

l2.current = true;
sphere();
sphere();

savemaxfile fileName;

resetmaxfile #noPrompt;

mergemaxfile fileName #(#Sphere01) quiet:on;
mergemaxfile fileName #(#Sphere02) quiet:on;
assert($Sphere01 != undefined);
assert($Sphere02 != undefined);
assert($Sphere01.layer.name == "Layer02");
assert($Sphere02.layer.name == "Layer02");

resetmaxfile #noPrompt;

assert(xrefs.addNewXRefFile fileName != undefined);

resetmaxfile #noPrompt;

assert(xrefs.addNewXRefObject fileName #Sphere01 != undefined);
assert(xrefs.addNewXRefObject fileName #Sphere02 != undefined);

resetmaxfile #noPrompt;
deleteFile fileName;

format "Testing merge/xref outlinerNestedLayers completed.\n";
)