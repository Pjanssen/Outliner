--RUNNING THIS SCRIPT RESETS THE CURRENT MAXFILE WITHOUT PROMPT.
(
resetmaxfile #noPrompt

global outlinerNestedLayers;

--Open the Outliner if it isn't opened already.
if (outliner_status == undefined OR not outliner_status.windowOpen) do
   assert(macros.run "Outliner" "toggleOutliner");

local l1 = LayerManager.newLayer();
local l2 = LayerManager.newLayer();
local l3 = LayerManager.newLayer();
local l1_ref = l1.layerAsRefTarg;
local l2_ref = l2.layerAsRefTarg;
local l3_ref = l3.layerAsRefTarg;



--Parent == undefined innitialy.
assert ((outlinerNestedLayers.getParent l1) == undefined);
assert ((outlinerNestedLayers.getParent l2) == undefined);
assert ((outlinerNestedLayers.getParent l3) == undefined);



--Create layer hierarchy.
try (
   outlinerNestedLayers.setParent l2 l1;
   outlinerNestedLayers.setParent l3 l2;
) catch assert false;



--Verify layer parent.
assert ((outlinerNestedLayers.getParent l1) == undefined);
assert ((outlinerNestedLayers.getParent l2) == l1_ref);
assert ((outlinerNestedLayers.getParent l3) == l2_ref);



--Verify layer children.
assert ((outlinerNestedLayers.getChildren l1).count == 1);
assert ((findItem (outlinerNestedLayers.getChildren l1) l2_ref) != 0);

--Verify layer children recursive.
assert ((outlinerNestedLayers.getChildren l1 recursive:true).count == 2);



--Set new parent.
try outlinerNestedLayers.setParent l3 l1; catch assert false;
assert ((outlinerNestedLayers.getParent l3) != l2_ref);
assert ((outlinerNestedLayers.getParent l3) == l1_ref);
assert ((outlinerNestedLayers.getChildren l1).count == 2);
assert ((outlinerNestedLayers.getChildren l2).count == 0);



--Unparent.
try outlinerNestedLayers.setParent l3 undefined; catch assert false;
assert ((outlinerNestedLayers.getParent l3) != l1_ref);
assert ((outlinerNestedLayers.getParent l3) == undefined);
assert ((outlinerNestedLayers.getChildren l1).count == 1);



--Create hierarchy l1-l2-l3
outlinerNestedLayers.setParent l2 l1;
outlinerNestedLayers.setParent l3 l2;

--Set layer property on child.
outlinerNestedLayers.setLayerProperty l3 #isHidden true;
assert (l3.isHidden);
assert (not l1.isHidden);
assert (not l2.isHidden);


--Set layer property on parent.
outlinerNestedLayers.setLayerProperty l1 #isHidden true;
assert (l1.isHidden);
assert (l2.isHidden);
assert (l3.isHidden);


--Get layer property.
assert (outlinerNestedLayers.getLayerProperty l1 #isHidden);
assert (not (outlinerNestedLayers.getLayerProperty l2 #isHidden));
assert (outlinerNestedLayers.getLayerProperty l3 #isHidden);


--Reset layer property on parent (property set on l3 should remain as before).
outlinerNestedLayers.setLayerProperty l1 #isHidden false;
assert (not l1.isHidden);
assert (not l2.isHidden);
assert (l3.isHidden);


resetmaxfile #noPrompt

format "Testing outlinerNestedLayers completed.\n";
)