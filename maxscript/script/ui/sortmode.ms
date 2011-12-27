rollout outliner_sortmode "Sort Mode"
(

function close = 
(
   if (outliner_status != undefined) do outliner_status.sortmodeOpen = false;
   destroyDialog outliner_sortmode;
)



local btn_x = 3;
local btn_y = 3;
local btn_w = 25;
local btn_h = 25;

checkButton sort_al width:btn_w height:btn_h pos:[btn_x, btn_y];
checkButton sort_ch width:btn_w height:btn_h pos:[btn_x + btn_w, btn_y];
checkButton sort_la width:btn_w height:btn_h pos:[btn_x + btn_w * 2, btn_y];
checkButton sort_ma width:btn_w height:btn_h pos:[btn_x + btn_w * 3, btn_y];
checkButton sort_ty width:btn_w height:btn_h pos:[btn_x + btn_w * 4, btn_y];
checkButton sort_vi width:btn_w height:btn_h pos:[btn_x + btn_w * 5, btn_y];

local sortmodes = #("Alphabetical", "Chronological", "Layer", "Material", "Type", "Visibility");
local buttons = #(sort_al, sort_ch, sort_la, sort_ma, sort_ty, sort_vi);


--Check whether outliner is still open. Just a precaution, this window 
--should never be open while the outliner isn't.
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

function set_sortmode mode btn =
(
   if (checkOutlinerStatus()) do
   (     
      if (btn.checked == false) then
         btn.checked = true;
      else
      (
         outliner.switchSortMode mode;
         close();
      )
   )
)

on sort_al changed e do set_sortmode sortmodes[1] sort_al;
on sort_ch changed e do set_sortmode sortmodes[2] sort_ch;
on sort_la changed e do set_sortmode sortmodes[3] sort_la;
on sort_ma changed e do set_sortmode sortmodes[4] sort_ma;
on sort_ty changed e do set_sortmode sortmodes[5] sort_ty;
on sort_vi changed e do set_sortmode sortmodes[6] sort_vi;


on outliner_sortmode open do
(
   if (checkOutlinerStatus()) do
   (
      local sortmode    = outliner.prefs.getValue #Tree #sortmode;
      local sortImgFile = outliner.ui.getIconPath "sortmodes";
      for i = 1 to buttons.count do
      (
         buttons[i].tooltip = sortmodes[i];
         buttons[i].images = #(sortImgFile, undefined, 6, i, i, i, i, true, false);

         if (sortmodes[i] == sortmode) do
            buttons[i].checked = true;
      )
   )
)

)--End rollout.