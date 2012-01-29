rollout outliner_main "Outliner"
(
local getPrefFn;
local setPrefFn;
local btn_w = 25;
local btn_h = 25;
local margin = 4;
local sortmode_images;

dotNetControl searchField "System.Windows.Forms.TextBox" pos:[margin, margin] height:19;
button searchClear "" width:19 height:19 pos:[margin, margin] tooltip:"Clear search field" border:false;
checkbutton searchCaseSensitive "" width:19 height:19 pos:[margin, margin] tooltip:"Search case-sensitive" border:false;

dotNetControl tree "Outliner.TreeView" pos:[margin, margin];

--Button y position is set in positionElements()
checkbutton listmode_h tooltip:"Hierarchy Mode" width:btn_w height:btn_h pos:[margin, margin] border:false;
checkbutton listmode_l tooltip:"Layer Mode" width:btn_w height:btn_h pos:[margin + btn_w, margin] border:false;
checkbutton listmode_m tooltip:"Material Mode" width:btn_w height:btn_h pos:[margin + btn_w*2, margin] border:false;

button sortmode_btn width:btn_w height:btn_h pos:[margin + btn_w * 3 + 4, margin] border:false;
checkbutton filter_enabled tooltip:"Enable Filter\nRight-Click to configure filter" width:btn_w height:btn_h pos:[margin + btn_w * 4 + 8, margin] border:false;
button options tooltip:"Options" width:btn_w height:btn_h pos:[0, margin] border:false;


--Position the main buttons (vertically).
function positionButtons y =
(
   listmode_h.pos.y     = y;
   listmode_l.pos.y     = y;
   listmode_m.pos.y     = y;
   sortmode_btn.pos.y   = y;
   filter_enabled.pos.y = y;
   options.pos.y        = y;
)

--Position search bar (vertically).
function positionSearchBar y =
(
   searchField.pos.y         = y;
   searchClear.pos.y         = y;
   searchCaseSensitive.pos.y = y;
)

--Search bar visibility.
function setSearchBarVisible v =
(
   searchField.visible         = v;
   searchClear.visible         = v;
   searchCaseSensitive.visible = v;
)

--Position Elements.
function positionElements = 
(
   local mainW          = outliner_main.width;
   local showSearchBar  = getPrefFn #Visual #showSearchBar;
   local searchBarAtTop = getPrefFn #Visual #searchBarAtTop;
   local buttonsAtTop   = getPrefFn #Visual #buttonsAtTop;
   
   local treePosY      = margin;
   local buttonsPosY   = margin;
   local searchBarPosY = margin;
   
   if (buttonsAtTop) do
   (
      treePosY      += btn_h + margin;
      searchBarPosY += btn_h + margin;
   )
   
   if (showSearchBar) do
   (
      if (searchBarAtTop) then
         treePosY += searchField.height + margin;
      else
         searchBarPosY = outliner_main.height - searchField.height - margin;
   )
   
   if (not buttonsAtTop) do
   (
      buttonsPosY = outliner_main.height - btn_h - margin;
      if (showSearchBar AND not searchBarAtTop) do
         searchBarPosY -= (btn_h + margin);
   )
   
   
   if (showSearchBar) then
   (
      searchField.width         = mainW - (searchField.height * 2) - (margin * 2) - 1;
      searchClear.pos.x         = mainW - (searchField.height * 2) - margin;
      searchCaseSensitive.pos.x = mainW - searchField.height - margin;
      tree.height               = outliner_main.height - searchField.height - btn_h - margin * 2 - 6;
   )
   else
   (
      tree.height = outliner_main.height - btn_h - margin - 6;
      --Even though visible is set to false, the controls still catch mouse 
      --clicks if they're in the same bounds as the tree..
      searchBarPosY = -25;
   )
   
   
   tree.pos.y = treePosY;
   positionButtons buttonsPosY;
   positionSearchBar searchBarPosY;
   
   setSearchBarVisible showSearchBar;

   tree.width    = mainW - margin * 2;
   options.pos.x = mainW - margin - btn_w;
)




/**
 * BUTTON EVENTS & FUNCTIONS
 */
local buttons = #(listmode_h, listmode_l, listmode_m, \
                  filter_enabled, options, \
                  searchCaseSensitive, searchClear);

function setButtonImages =
(
   local mainImgFile = outliner.ui.getIconPath "main";
   local sortImgFile = outliner.ui.getIconPath "sortmodes";
   local numMainImages = 7;
   local numSortImages = 6;
   
   for i = 1 to buttons.count do 
      buttons[i].images = #(mainImgFile, undefined, numMainImages, i, i, i, i, true, false);
   
   sortmode_images = #(sortImgFile, undefined, numSortImages, 1, 1, 1, 1, true, false);
   sortmode_btn.images = sortmode_images;
   
)


function setButtonStates =
(
   searchCaseSensitive.checked   = getPrefFn #Tree #searchCaseSensitive;
   local listmode = getPrefFn #Tree #listMode;
   listMode_h.checked = (listmode == "Hierarchy");
   listMode_l.checked = (listmode == "Layer");
   listMode_m.checked = (listmode == "Material");
   filter_enabled.checked = getPrefFn #Tree #objFilterEnabled; 
)

function setSortModeBtnImages =
(
   local sortmode = outliner.prefs.getValue #Tree #sortmode;
   local sortmodeIndex = findItem outliner_sortmode.sortmodes sortmode;
   if (sortmodeIndex != 0) do
   (
      sortmode_images[4] = sortmode_images[5] = sortmode_images[6] = sortmode_images[7] = sortmodeIndex;
      sortmode_btn.images = sortmode_images;
      sortmode_btn.tooltip = "Select SortMode\nCurrent: " + sortmode;
   )
)


/** LIST MODE **/ 
on listMode_h changed checked do
(
   if (not checked) then
      listmode_h.checked = true;
   else
   (
      listmode_l.checked = listmode_m.checked = false;
      outliner.switchListMode "Hierarchy";
   )
)

on listMode_l changed checked do
(
   if (not checked) then
      listmode_l.checked = true;
   else
   (
      listmode_h.checked = listmode_m.checked = false;
      outliner.switchListMode "Layer";
   )
)

on listMode_m changed checked do
(
   if (not checked) then
      listmode_m.checked = true;
   else
   (
      listmode_h.checked = listmode_l.checked = false;
      outliner.switchListMode "Material";
   )
)


/** SORT MODE **/
on sortmode_btn pressed do
(
   outliner.UI.openSortModeWindow();
)



/** FILTER **/
function setHideByCategory forceSet:false =
(
   local objFilterAffectVpt = getPrefFn #Tree #objFilterAffectVpt;
   local objFilterEnabled   = getPrefFn #Tree #objFilterEnabled;
   local objFilter          = getPrefFn #Tree #objFilter;
   local hideByCat_enum     = #(&hideByCategory.geometry, &hideByCategory.shapes, 
                                &hideByCategory.lights, &hideByCategory.cameras, 
                                &hideByCategory.helpers, &hideByCategory.spacewarps, 
                                &hideByCategory.bones, &hideByCategory.particles);
   
   if (objFilterAffectVpt OR forceSet) do
   (
      disableSceneRedraw();
      
      if (objFilterAffectVpt AND objFilterEnabled) then
      (
         for i = 1 to hideByCat_enum.count do *hideByCat_enum[i] = not objFilter[i];
         maxOps.hideFrozenObjects = not objFilter[11];
      )
      else
      (
         for i = 1 to hideByCat_enum.count do *hideByCat_enum[i] = false;
         maxOps.hideFrozenObjects = false;
      )
      
      enableSceneRedraw();
      completeRedraw();
   )
)



on filter_enabled changed checked do
(
   outliner.setFilterEnabled checked;
)

on filter_enabled rightclick do 
(
   outliner.UI.openFilterConfigWindow();
)




/** OPTIONS **/
on options pressed do outliner.UI.openOptionsWindow();



/**
 * TEXT SEARCH EVENTS
 */
function clearSearchField =
(
   searchField.Text = "";
   tree.Filter.NameFilter = "";
   tree.FillTree();
)

on searchField TextChanged e do 
(
   try
   (
      tree.Filter.NameFilter = searchField.Text;
      tree.FillTree();
   )
   catch
   (
      fileIn "../crash_report.ms";
   )
)

on searchField KeyUp e do
(
   try
   (
      if (e.KeyData == (dotNetClass "System.Windows.Forms.Keys").Enter) do
      (
         tree.SelectFilteredNodes();
         if (getPrefFn #General #clearSearchFieldAfterSelect) do
            clearSearchField();
      )
   )
   catch
   (
      fileIn "../crash_report.ms";
   )
)

on searchClear pressed do
(
   clearSearchField();
)

on searchCaseSensitive changed checked do
(
   try
   (
      setPrefFn #Tree #searchCaseSensitive checked;
      tree.Filter.NameFilterCaseSensitive = checked;
      tree.FillTree();
   )
   catch
   (
      fileIn "../crash_report.ms";
   )
)





/**
 * TREE EVENTS FUNCTION CACHE
 */
local outliner_handleKeyUp;
local TreeEventHandlers_SelectionChanged;
local TreeEventHandlers_NodeHidden;
local TreeEventHandlers_NodeFrozen;
local TreeEventHandlers_NodeBoxModeChanged;
local TreeEventHandlers_NodeRenamed;
local TreeEventHandlers_ObjectMaterialChanged;
local TreeEventHandlers_SpaceWarpBound;
local TreeEventHandlers_ObjectAddedToContainer;
local TreeEventHandlers_ObjectLayerChanged;
local TreeEventHandlers_ObjectLinked;
local TreeEventHandlers_ObjectGrouped;
local TreeEventHandlers_LayerLinked;
local TreeEventHandlers_LayerActiveChanged;
local TreeEventHandlers_ContextMenuOpened;
local TreeEventHandlers_ContextMenuItemClicked;

function createFunctionCache =
(
   outliner_handleKeyUp = outliner.handleKeyUp
   TreeEventHandlers_SelectionChanged       = outliner_TreeEventHandlers.SelectionChanged;
   TreeEventHandlers_NodeHidden             = outliner_TreeEventHandlers.NodeHidden;
   TreeEventHandlers_NodeFrozen             = outliner_TreeEventHandlers.NodeFrozen;
   TreeEventHandlers_NodeBoxModeChanged     = outliner_TreeEventHandlers.NodeBoxModeChanged;
   TreeEventHandlers_NodeRenamed            = outliner_TreeEventHandlers.NodeRenamed;
   TreeEventHandlers_ObjectMaterialChanged  = outliner_TreeEventHandlers.ObjectMaterialChanged;
   TreeEventHandlers_SpaceWarpBound         = outliner_TreeEventHandlers.SpaceWarpBound;
   TreeEventHandlers_ObjectAddedToContainer = outliner_TreeEventHandlers.ObjectAddedToContainer;
   TreeEventHandlers_ObjectLayerChanged     = outliner_TreeEventHandlers.ObjectLayerChanged;
   TreeEventHandlers_ObjectLinked           = outliner_TreeEventHandlers.ObjectLinked;
   TreeEventHandlers_ObjectGrouped          = outliner_TreeEventHandlers.ObjectGrouped;
   TreeEventHandlers_LayerLinked            = outliner_TreeEventHandlers.LayerLinked;
   TreeEventHandlers_LayerActiveChanged     = outliner_TreeEventHandlers.LayerActiveChanged;
   TreeEventHandlers_ContextMenuOpened      = outliner_TreeEventHandlers.ContextMenuOpened;
   TreeEventHandlers_ContextMenuItemClicked = outliner_TreeEventHandlers.ContextMenuItemClicked;
)

function disposeFunctionCache =
(
   outliner_handleKeyUp = undefined;
   TreeEventHandlers_SelectionChanged       = undefined;
   TreeEventHandlers_NodeHidden             = undefined;
   TreeEventHandlers_NodeFrozen             = undefined;
   TreeEventHandlers_NodeBoxModeChanged     = undefined;
   TreeEventHandlers_NodeRenamed            = undefined;
   TreeEventHandlers_ObjectMaterialChanged  = undefined;
   TreeEventHandlers_SpaceWarpBound         = undefined;
   TreeEventHandlers_ObjectAddedToContainer = undefined;
   TreeEventHandlers_ObjectLayerChanged     = undefined;
   TreeEventHandlers_ObjectLinked           = undefined;
   TreeEventHandlers_ObjectGrouped          = undefined;
   TreeEventHandlers_LayerLinked            = undefined;
   TreeEventHandlers_LayerActiveChanged     = undefined;
   TreeEventHandlers_ContextMenuOpened      = undefined;
   TreeEventHandlers_ContextMenuItemClicked = undefined;
)





/**
 * WINDOW EVENTS
 */
--Rollout opened.
on outliner_main open do
(
   try (
   outliner.setTreeInst tree;
   getPrefFn = outliner.prefs.getValue;
   setPrefFn = outliner.prefs.setValue;

   positionElements();
   setButtonImages();
   setButtonStates();
   setSortModeBtnImages();
   
   searchField.Font = (dotNetObject "System.Drawing.Font" "Sans Serif" 7.5);

   outliner.setTreeColorScheme (getPrefFn #Visual #colorscheme);
   tree.IconSet = outliner.parseDotNetEnum "Outliner.IconSet" (getPrefFn #Visual #iconSet);
   
   tree.TreeViewNodeSorter = dotNetObject ("Outliner.NodeSorters." + (getPrefFn #Tree #sortMode) + "Sorter");  
   
   tree.ShowNodeHideButton        = getPrefFn #Tree #showNodeHideButton;
   tree.NodeHideButtonLocation    = outliner.parseDotNetEnum "Outliner.NodeButtonsLocation" (getPrefFn #Tree #nodeHideButtonLocation);
   tree.ShowNodeFreezeButton      = getPrefFn #Tree #showNodeFreezeButton;
   tree.NodeFreezeButtonLocation  = outliner.parseDotNetEnum "Outliner.NodeButtonsLocation" (getPrefFn #Tree #nodeFreezeButtonLocation);
   tree.ShowNodeBoxModeButton     = getPrefFn #Tree #showNodeBoxModeButton;
   tree.NodeBoxModeButtonLocation = outliner.parseDotNetEnum "Outliner.NodeButtonsLocation" (getPrefFn #Tree #nodeBoxModeButtonLocation);
   tree.ShowNodeAddButton         = getPrefFn #Tree #showNodeAddButton;
   tree.NodeAddButtonLocation     = outliner.parseDotNetEnum "Outliner.NodeButtonsLocation" (getPrefFn #Tree #nodeAddButtonLocation);
   tree.InvertNodeHideButton      = getPrefFn #Tree #invertNodeHideButton;
   
   tree.HighlighLastSelectedObject = getPrefFn #Tree #highlightLastSel;
   tree.AutoExpandHierarchy        = getPrefFn #Tree #autoExpandHierarchy;
   tree.AutoExpandLayer            = getPrefFn #Tree #autoExpandLayer;
   tree.AutoExpandMaterial         = getPrefFn #Tree #autoExpandMaterial;
   tree.HideGroupMembersLayerMode  = getPrefFn #Tree #hideGroupMembersLayerMode;
   
   tree.ListMode           = outliner.parseDotNetEnum "Outliner.OutlinerListMode" (getPrefFn #Tree #listMode);
   tree.IconClickAction    = outliner.parseDotNetEnum "Outliner.IconClickAction" (getPrefFn #Tree #iconClickAction);
   tree.DoubleClickAction  = outliner.parseDotNetEnum "Outliner.DoubleClickAction" (getPrefFn #Tree #doubleClickAction);
   tree.DragMouseButton    = outliner.parseDotNetEnum "System.Windows.Forms.MouseButtons" (getPrefFn #Tree #dragMouseButton);
   tree.ExpandHierarchyKey = outliner.parseDotNetEnum "System.Windows.Forms.Keys" (getPrefFn #Tree #expandHierarchyKey);
   
   tree.ExpandSelectionPolicyHierarchy = outliner.parseDotNetEnum "Outliner.ExpandPolicy" (getPrefFn #Tree #expandSelPolicyHierarchy);
   tree.ExpandSelectionPolicyLayer     = outliner.parseDotNetEnum "Outliner.ExpandPolicy" (getPrefFn #Tree #expandSelPolicyLayer);
   tree.ExpandSelectionPolicyMaterial  = outliner.parseDotNetEnum "Outliner.ExpandPolicy" (getPrefFn #Tree #expandSelPolicyMaterial);
      

   tree.Filter.Enabled      = getPrefFn #Tree #objFilterEnabled;
   local filter_enum = #(&tree.Filter.showGeometry, &tree.Filter.showShapes, 
                         &tree.Filter.showLights,   &tree.Filter.showCameras,
                         &tree.Filter.showHelpers,  &tree.Filter.showSpaceWarps, 
                         &tree.Filter.showBones,    &tree.Filter.showParticles,
                         &tree.Filter.showXRefs,    &tree.Filter.showGroups,
                         &tree.Filter.showHidden,   &tree.Filter.showFrozen);
   local objFilter = (getPrefFn #Tree #objFilter);
   for i = 1 to filter_enum.count do *filter_enum[i] = objFilter[i];

   setHideByCategory();
   
   createFunctionCache();
   )
   catch
   (
      fileIn "crash_report.ms";
   )
)



--Rollout closed.
on outliner_main close do 
(
   disposeFunctionCache();
   
   --Avoid calling closeOutliner() again when dialog is closed from that function.
   if (outliner_status != undefined AND not outliner_status.closingOutliner) do
   (
      outliner.ui.closeOutliner();
   )
)



--Rollout moved.
on outliner_main moved arg do 
(
   local posx = arg[1];
   local posy = arg[2];
   
   --Adjust for cui.unregisterDialog bug.
   local osVersion = (dotNetClass "System.Environment").osVersion;
   --Windows XP (y - 2)
   if (osVersion.version.major < 6) then
      posy -= 2;
   --Windows 7 (x - 4, y - 6)
   else
   (
      posx -= 4;
      posy -= 6;
   )
   
   --Store preferences.
   setPrefFn #Window #posx posx;
   setPrefFn #Window #posy posy;
)



--Rollout resized.
on outliner_main resized arg do
(
   if (outliner_status.windowOpen AND not outliner_status.closingOutliner \
                                  AND outliner_main.dialogBar) do
   (
      local dockState = cui.getDockState outliner_main;
      if ((getPrefFn #Window #dockFlag) != dockState) do
      (
         setPrefFn #Window #dockFlag (cui.getDockState outliner_main);
      )
      
   )
   setPrefFn #Window #width outliner_main.width;
   setPrefFn #Window #height outliner_main.height;
   
   positionElements();
)












/**
 * TREE EVENTS
 */
on tree DebugEvent e do
(
   format "DebugEvent ";
   if (e.Text1 != undefined) do format "\te.text1: %" e.Text1;
   if (e.Text2 != undefined) do format "\n\t\t\te.text2: %" e.Text2;
   if (e.Text3 != undefined) do format "\n\t\t\te.text3: %" e.Text3;
   format "\n"
)
 
 

on tree KeyPress e do
   e.Handled = true;
   
on tree KeyDown e do 
(
   if (e.KeyValue > 18) do 
      outliner_handleKeyUp e;
)


on tree SelectionChanged e do TreeEventHandlers_SelectionChanged e;
on tree NodeHidden e do TreeEventHandlers_NodeHidden e;
on tree NodeFrozen e do TreeEventHandlers_NodeFrozen e;
on tree NodeBoxModeChanged e do TreeEventHandlers_NodeBoxModeChanged e;
on tree NodeRenamed e do TreeEventHandlers_NodeRenamed e;
on tree ObjectMaterialChanged e do TreeEventHandlers_ObjectMaterialChanged e;
on tree SpaceWarpBound e do TreeEventHandlers_SpaceWarpBound e;
on tree ObjectAddedToContainer e do TreeEventHandlers_ObjectAddedToContainer e;
on tree ObjectLayerChanged e do TreeEventHandlers_ObjectLayerChanged e;
on tree ObjectLinked e do TreeEventHandlers_ObjectLinked e;
on tree ObjectGrouped e do TreeEventHandlers_ObjectGrouped e;
on tree LayerLinked e do TreeEventHandlers_LayerLinked e;
on tree LayerActiveChanged e do TreeEventHandlers_LayerActiveChanged e;
on tree ContextMenuOpened e do TreeEventHandlers_ContextMenuOpened e;
on tree ContextMenuItemClicked e do TreeEventHandlers_ContextMenuItemClicked e;
   
)--End rollout.