rollout outliner_filter_config "Filters"
(

function close = 
(
   if (outliner_status != undefined) do outliner_status.filterConfigOpen = false;
   destroyDialog outliner_filter_config;
)

local treeFilter;
local buttons;
local filter_refs;
local hideByCat_refs;

local btn_x = 3;
local btn_y = 3;
local btn_w = 25;
local btn_h = 25;

local btn_y2 = btn_y + btn_h;
checkButton affect_vpt tooltip:"Affect Viewport" width:btn_w height:btn_h pos:[btn_x, btn_y];
checkButton affect_layers tooltip:"Affect Layers" width:btn_w height:btn_h pos:[btn_x, btn_y2];

local btn_x2 = btn_x + btn_w + 8;
checkButton filter_hi tooltip:"Hidden" width:btn_w height:btn_h pos:[btn_x2, btn_y];
checkButton filter_fr tooltip:"Frozen" width:btn_w height:btn_h pos:[btn_x2, btn_y2];

local btn_x3 = btn_x2 + btn_w + 4;
checkButton filter_go tooltip:"Geometry" width:btn_w height:btn_h pos:[btn_x3, btn_y];
checkButton filter_sh tooltip:"Shapes" width:btn_w height:btn_h pos:[btn_x3 + btn_w, btn_y];
checkButton filter_li tooltip:"Lights" width:btn_w height:btn_h pos:[btn_x3 + btn_w * 2, btn_y];
checkButton filter_ca tooltip:"Cameras" width:btn_w height:btn_h pos:[btn_x3 + btn_w * 3, btn_y];
checkButton filter_he tooltip:"Helpers" width:btn_w height:btn_h pos:[btn_x3 + btn_w * 4, btn_y];


checkButton filter_sw tooltip:"Spacewarps" width:btn_w height:btn_h pos:[btn_x3, btn_y2];
checkButton filter_bo tooltip:"Bones" width:btn_w height:btn_h pos:[btn_x3 + btn_w, btn_y2];
checkButton filter_pa tooltip:"Particle Systems" width:btn_w height:btn_h pos:[btn_x3 + btn_w * 2, btn_y2];
checkButton filter_xr tooltip:"XRefs" width:btn_w height:btn_h pos:[btn_x3 + btn_w * 3, btn_y2];
checkButton filter_gr tooltip:"Groups" width:btn_w height:btn_h pos:[btn_x3 + btn_w * 4, btn_y2];




--Check whether outliner is still open. Just a precaution, this window should never be open while the outliner isn't.
function checkOutlinerStatus =
(
   if ((outliner_status == undefined) OR (outliner_status.windowOpen == false)) then
   (
      close();
      false;
   )
   else
      true;
)



function setButtonStates =
(
   for i = 1 to filter_refs.count do
   (
      buttons[i].checked = *(filter_refs[i]);
   )
   affect_layers.checked = outliner.prefs.getValue #Tree #objFilterAffectLayers;
   affect_vpt.checked = outliner.prefs.getValue #Tree #objFilterAffectVpt;
)


function setFilterRange begin end enabled =
(
   try
   (
      if (checkOutlinerStatus()) do
      (
         for i = begin to end do
         (
            buttons[i].checked = enabled;
            (outliner.prefs.getValue #Tree #objFilter)[i] = enabled;
            if (i <= filter_refs.count) do *filter_refs[i] = enabled;
            if ((outliner.prefs.getValue #Tree #objFilterAffectVpt) \
                AND (outliner.prefs.getValue #Tree #objFilterEnabled) \
                AND i <= hideByCat_refs.count) do *hideByCat_refs[i] = not enabled;
         )
         outliner.prefs.savePreferences();
         
         if (outliner.prefs.getValue #Tree #objFilterEnabled) do 
            outliner.tree.FillTree();
      )
   )
   catch
   (
      fileIn "../crash_report.ms";
   )
)


function setFilter prop enabled =
(
   if (keyboard.controlPressed) then
   (
      if (prop < 11) then
         setFilterRange 1 10 (not enabled);
      else
         setFilterRange 11 12 (not enabled);
         
      setFilterRange prop prop enabled;
   )
   else
      setFilterRange prop prop enabled;
)


on affect_layers changed checked do
(
   try
   (
      outliner.prefs.setValue #Tree #objFilterAffectLayers checked;
      outliner.tree.Filter.AffectLayers = checked;
      outliner.tree.FillTree();
   )
   catch
   (
      fileIn "../crash_report.ms";
   )
)


on affect_vpt changed checked do
(
   try
   (
      outliner.prefs.setValue #Tree #objFilterAffectVpt checked;
      outliner_main.setHideByCategory forceSet:true;
   )
   catch
   (
      fileIn "../crash_report.ms";
   )
)

-- Filter category button events.
on filter_go changed checked do setFilter 1 checked;
on filter_sh changed checked do setFilter 2 checked;
on filter_li changed checked do setFilter 3 checked;
on filter_ca changed checked do setFilter 4 checked;
on filter_he changed checked do setFilter 5 checked;
on filter_sw changed checked do setFilter 6 checked;
on filter_bo changed checked do setFilter 7 checked;
on filter_pa changed checked do setFilter 8 checked;
on filter_xr changed checked do setFilter 9 checked;
on filter_gr changed checked do setFilter 10 checked;
on filter_hi changed checked do setFilter 11 checked;
on filter_fr changed checked do setFilter 12 checked;

on filter_go rightclick do setFilterRange 1 10 (not filter_go.checked);
on filter_sh rightclick do setFilterRange 1 10 (not filter_sh.checked);
on filter_li rightclick do setFilterRange 1 10 (not filter_li.checked);
on filter_ca rightclick do setFilterRange 1 10 (not filter_ca.checked);
on filter_he rightclick do setFilterRange 1 10 (not filter_he.checked);
on filter_sw rightclick do setFilterRange 1 10 (not filter_sw.checked);
on filter_bo rightclick do setFilterRange 1 10 (not filter_bo.checked);
on filter_pa rightclick do setFilterRange 1 10 (not filter_pa.checked);
on filter_xr rightclick do setFilterRange 1 10 (not filter_xr.checked);
on filter_gr rightclick do setFilterRange 1 10 (not filter_gr.checked);
on filter_hi rightclick do setFilterRange 11 12 (not filter_hi.checked);
on filter_fr rightclick do setFilterRange 11 12 (not filter_fr.checked);



function setButtonImages =
(
   local imageFile = outliner.ui.getIconPath "filters";
 
   for i = 1 to buttons.count do
   (
      local imgIndex = i * 2 - 1;
      buttons[i].images = #(imageFile, undefined, 14, \
                            i, i, i, i, true, false);
   )
)


-- Set button images on dialog open.
on outliner_filter_config open do
(
   if (checkOutlinerStatus()) do
   (
      -- Note: Button, filter and hidebycategory reference indices must 
      --       correspond for functions to work correctly!
      buttons = #(filter_go, filter_sh, filter_li, filter_ca, filter_he, 
                  filter_sw, filter_bo, filter_pa, filter_xr, filter_gr,
                  filter_hi, filter_fr, affect_layers, affect_vpt);
   
      treeFilter = outliner.tree.Filter;
      filter_refs = #(&treeFilter.showGeometry, &treeFilter.showShapes, 
                      &treeFilter.showLights,   &treeFilter.showCameras, 
                      &treeFilter.showHelpers,  &treeFilter.showSpaceWarps,
                      &treeFilter.showBones,    &treeFilter.showParticles, 
                      &treeFilter.showXRefs,    &treeFilter.showGroups,
                      &treeFilter.showHidden,   &treeFilter.showFrozen);
                    
      hideByCat_refs = #(&hideByCategory.geometry, &hideByCategory.shapes, 
                         &hideByCategory.lights,   &hideByCategory.cameras, 
                         &hideByCategory.helpers,  &hideByCategory.spacewarps,
                         &hideByCategory.bones,    &hideByCategory.particles);

      setButtonImages();
      setButtonStates();
   )
)

)--End struct.