(
global outliner_options;
global outliner_options_general;

local marginX = 10;
local marginY = 5;
local chkbxDY = 21;

local drpDwnW = 110;
local drpDwnLblX = marginX + drpDwnW + 6;

local getPrefFn;
local setPrefFn;

rollout outliner_options_general "General"
(
   checkbox checkForUpdates "Check for updates every" pos:[marginX, marginY];
   spinner checkUpdatesInterval "" range:[1, 30, 7] type:#integer fieldWidth:30 pos:[marginX + 140, marginY + 1];
   label checkUpdateDaysLbl "days" pos:[marginX + 187, marginY + 1];
   checkbutton checkNowBtn "Check now" width:70 pos:[marginX + 220, marginY - 2];
   checkbox skipTrialVersions "Skip trial versions (recommended)" pos:[marginX, marginY + chkbxDY];
   
   checkbox openAtStartup "Open at 3dsMax startup" pos:[marginX, marginY + chkbxDY * 2];
   checkbox focusSearchFieldOnOpen "Set focus to search field when opening" pos:[marginX, marginY + chkbxDY * 3];
   checkbox clearSearchFieldAfterSelect "Clear search field when selecting found nodes" pos:[marginX, marginY + chkbxDY * 4];
   dropdownlist dragMouseButton "" width:drpDwnW items:#("Left", "Middle") pos:[marginX, marginY + chkbxDY * 5];
   label dragdropMouseBtnLbl "Drag \x26\x26 Drop Mousebutton" pos:[drpDwnLblX, marginY + chkbxDY * 5 + 3];
   dropdownlist doubleClickAction "" width:drpDwnW items:#("Expand", "Rename") pos:[marginX, marginY + chkbxDY * 6];
   label doubleClickActionLbl "Double-Click Action" pos:[drpDwnLblX, marginY + chkbxDY * 6 + 3];

   on checkForUpdates changed checked do
      setPrefFn #General #checkForUpdates checked;
      
   on checkUpdatesInterval changed val do
      setPrefFn #General #checkUpdatesInterval val;
   
   
   function resetCheckBtn =
   (
      checkNowBtn.text = "Check now";
      checkNowBtn.checked = false;
   )
   
   on checkNowBtn changed checked do
   (
      if (checked) then
      (
         checkNowBtn.text = "Cancel";
         outliner_update.checkCompleteFn = outliner_options_general.resetCheckBtn;
         outliner_update.checkUpdateManual();
      )
      else
      (
         checkNowBtn.text = "Check now";
         outliner_update.cancelCheckUpdate();
      )
   )
   
   on skipTrialVersions changed checked do
   (
      setPrefFn #General #accept_trial (not checked);
      if (not checked) do
         messageBox "It is possible that by disabling this option, you will be presented with\nuntested pre-release versions of the Outliner.\nUse this at your own risk!" title:"Warning";
   )
      
   on openAtStartup changed checked do
      setPrefFn #General #openAtStartup checked;
   
   on focusSearchFieldOnOpen changed checked do
      setPrefFn #General #focusSearchFieldOnOpen checked;
      
   on clearSearchFieldAfterSelect changed checked do
      setPrefFn #General #clearSearchFieldAfterSelect checked;
   
   on dragMouseButton selected sel do
   (
      setPrefFn #Tree #dragMouseButton dragMouseButton.selected;
      outliner.tree.DragMouseButton = outliner.parseDotNetEnum "System.Windows.Forms.MouseButtons" dragMouseButton.selected
   )
   
   on doubleClickAction selected sel do
   (
      setPrefFn #Tree #doubleClickAction doubleClickAction.selected;
      outliner.tree.DoubleClickAction = outliner.parseDotNetEnum "Outliner.DoubleClickAction" doubleClickAction.selected;
   )
   
   function setUIvalues =
   (
      checkForUpdates.checked = getPrefFn #General #checkForUpdates;
      checkUpdatesInterval.value = getPrefFn #General #checkUpdatesInterval;
      skipTrialVersions.checked = not (getPrefFn #General #accept_trial);
      openAtStartup.checked = getPrefFn #General #openAtStartup;
      focusSearchFieldOnOpen.checked = getPrefFn #General #focusSearchFieldOnOpen;
      clearSearchFieldAfterSelect.checked = getPrefFn #General #clearSearchFieldAfterSelect;
      dragMouseButton.selection = findItem dragMouseButton.items (getPrefFn #Tree #dragMouseButton);
      doubleClickAction.selection = findItem doubleClickAction.items (getPrefFn #Tree #doubleClickAction);
   )
)--End rollout.



rollout outliner_options_visual "User Interface"
(
   dropdownList searchBarLocation "" items:#("Hide", "Top", "Bottom") width:drpDwnW pos:[marginX, marginY];
   label searchBarLocationLbl "Search Bar Location" pos:[drpDwnLblX, marginY + 4];
   dropdownList buttonsLocation "" items:#("Top", "Bottom") width:drpDwnW pos:[marginX, marginY + chkbxDY];
   label buttonsLocationLbl "Main UI Buttons Location" pos:[drpDwnLblX, marginY + chkbxDY + 4];
   dropdownList colorScheme "" width:drpDwnW pos:[marginX, marginY + chkbxDY * 2];
   label colorSchemeLbl "Color Scheme" pos:[drpDwnLblX, marginY + chkbxDY * 2 + 4];
   dropdownList iconset "" width:drpDwnW pos:[marginX, marginY + chkbxDY * 3];
   label iconsetLbl "Icon Set" pos:[drpDwnLblX, marginY + chkbxDY * 3 + 4];
   checkbox invertIcons "Invert" pos:[marginX + 170, marginY + chkbxDY * 3 + 4];
   
   
   dropdownList nodeIconClickAction "" items:#("Hide", "Freeze", "Set Layer Active") width:drpDwnW pos:[marginX, marginY + chkbxDY * 4 + 5];
   label nodeIconClickActionLbl "Node Icon Click Action" pos:[drpDwnLblX, marginY + chkbxDY * 4 + 9];
   
   checkbox showNodeHideButton "Show Node Hide Button" pos:[marginX, marginY + chkbxDY * 5 + 9];
   dropdownlist nodeHideButtonLocation "" items:#("Before Node", "After Node", "Align Right") width:drpDwnW pos:[marginX + 170, marginY + chkbxDY * 5 + 6];
   
   checkbox showNodeFreezeButton "Show Node Freeze Button" pos:[marginX, marginY + chkbxDY * 6 + 9];
   dropdownlist nodeFreezeButtonLocation "" items:#("Before Node", "After Node", "Align Right") width:drpDwnW pos:[marginX + 170, marginY + chkbxDY * 6 + 6];
   
   checkbox showNodeBoxModeButton "Show Node Box Mode Button" pos:[marginX, marginY + chkbxDY * 7 + 9];
   dropdownlist nodeBoxModeButtonLocation "" items:#("Before Node", "After Node", "Align Right") width:drpDwnW pos:[marginX + 170, marginY + chkbxDY * 7 + 6];
   
   checkbox showNodeAddButton "Show Node Add Button" pos:[marginX, marginY + chkbxDY * 8 + 9];
   dropdownlist nodeAddButtonLocation "" items:#("Before Node", "After Node", "Align Right") width:drpDwnW pos:[marginX + 170, marginY + chkbxDY * 8 + 6];
   
   checkbox invertNodeHideButton "Invert Node Hide Button behavior" pos:[marginX, marginY + chkbxDY * 9 + 9];
   
   
   on colorScheme selected sel do
   (
      setPrefFn #Visual #colorScheme colorScheme.selected;
      outliner.setTreeColorScheme colorScheme.selected;
   )
   
   on iconSet selected sel do
   (
      setPrefFn #Visual #iconSet iconSet.selected;
      outliner.tree.IconSet = outliner.parseDotNetEnum "Outliner.IconSet" iconSet.selected;
      if (outliner_status.filterConfigOpen) do
         try ( outliner_filter_config.setButtonImages(); ) catch()
   )
   
   on invertIcons changed checked do
   (
      setPrefFn #Visual #invertIcons checked;
      outliner.tree.InvertIcons = checked;
   )
   
   on buttonsLocation selected sel do
   (
      setPrefFn #Visual #buttonsAtTop (sel == 1);
      outliner_main.positionElements();
   )
   
   on searchBarLocation selected e do
   (
      setPrefFn #Visual #showSearchBar (e != 1);
      setPrefFn #Visual #searchBarAtTop (e == 2);
      outliner_main.positionElements();
   )
   
   on showNodeHideButton changed e do
   (
      setPrefFn #Tree #showNodeHideButton e;
      outliner.tree.ShowNodeHideButton = e;
   )
   
   on showNodeFreezeButton changed e do
   (
      setPrefFn #Tree #showNodeFreezeButton e;
      outliner.tree.ShowNodeFreezeButton = e;
   )
   
   on showNodeBoxModeButton changed e do
   (
      setPrefFn #Tree #showNodeBoxModeButton e;
      outliner.tree.ShowNodeBoxModeButton = e;
   )
   
   on showNodeAddButton changed e do
   (
      setPrefFn #Tree #showNodeAddButton e;
      outliner.tree.ShowNodeAddButton = e;
   )
   
   on nodeHideButtonLocation selected sel do
   (
      local val = case sel of ( 1 : "BeforeNode"; 2 : "AfterNode"; 3 : "AlignRight"; )
      setPrefFn #Tree #nodeHideButtonLocation val;
      outliner.tree.NodeHideButtonLocation = outliner.parseDotNetENum "Outliner.NodeButtonsLocation" val;
   )
   
   on nodeFreezeButtonLocation selected sel do
   (
      local val = case sel of ( 1 : "BeforeNode"; 2 : "AfterNode"; 3 : "AlignRight"; )
      setPrefFn #Tree #nodeFreezeButtonLocation val;
      outliner.tree.NodeFreezeButtonLocation = outliner.parseDotNetENum "Outliner.NodeButtonsLocation" val;
   )
   
   on nodeBoxModeButtonLocation selected sel do
   (
      local val = case sel of ( 1 : "BeforeNode"; 2 : "AfterNode"; 3 : "AlignRight"; )
      setPrefFn #Tree #nodeBoxModeButtonLocation val;
      outliner.tree.NodeBoxModeButtonLocation = outliner.parseDotNetENum "Outliner.NodeButtonsLocation" val;
   )
   
   on nodeAddButtonLocation selected sel do
   (
      local val = case sel of ( 1 : "BeforeNode"; 2 : "AfterNode"; 3 : "AlignRight"; )
      setPrefFn #Tree #nodeAddButtonLocation val;
      outliner.tree.NodeAddButtonLocation = outliner.parseDotNetENum "Outliner.NodeButtonsLocation" val;
   )
   
   on nodeIconClickAction selected sel do
   (
      local val = case sel of
      (
         1 : "Hide";
         2 : "Freeze";
         3 : "SetActive";
      )
      setPrefFn #Tree #iconClickAction val;
      outliner.tree.IconClickAction = outliner.parseDotNetENum "Outliner.IconClickAction" val;
   )
   
   on invertNodeHideButton changed e do
   (
      setPrefFn #Tree #InvertNodeHideButton e;
      outliner.tree.InvertNodeHideButton = e;
   )
   
   function setUIValues = 
   (
      colorScheme.items	= join (getINISetting (pathConfig.appendPath outliner.dir "colorSchemes.ini")) \
                               (getINISetting (pathConfig.appendPath (GetDir #userScripts) "outliner_user_colors.ini"));
      colorScheme.selection      = findItem colorScheme.items (getPrefFn #Visual #colorScheme);
      iconSet.Items					= outliner.getNamesDotNetEnum "Outliner.IconSet";
      iconSet.selection				= findItem iconSet.items (getPrefFn #Visual #iconSet);
      invertIcons.checked				= getPrefFn #Visual #invertIcons;
      buttonsLocation.selection		= if (getPrefFn #Visual #buttonsAtTop) then 1 else 2;
      searchBarLocation.selection		= if (not (getPrefFn #Visual #showSearchBar)) then 1 else if (getPrefFn #Visual #searchBarAtTop) then 2 else 3;
      showNodeHideButton.checked		= getPrefFn #Tree #showNodeHideButton;
      showNodeFreezeButton.checked	= getPrefFn #Tree #showNodeFreezeButton;
      showNodeBoxModeButton.checked	= getPrefFn #Tree #showNodeBoxModeButton;
      showNodeAddButton.checked = getPrefFn #Tree #showNodeAddButton;
      invertNodeHideButton.checked = getPrefFn #Tree #invertNodeHideButton;
      
      nodeHideButtonLocation.selection = case (getPrefFn #Tree #nodeHideButtonLocation) of
      ( "BeforeNode" : 1; "AfterNode" : 2; "AlignRight" : 3; )
      
      nodeFreezeButtonLocation.selection = case (getPrefFn #Tree #nodeFreezeButtonLocation) of
      ( "BeforeNode" : 1; "AfterNode" : 2; "AlignRight" : 3; )
      
      nodeBoxModeButtonLocation.selection = case (getPrefFn #Tree #nodeBoxModeButtonLocation) of
      ( "BeforeNode" : 1; "AfterNode" : 2; "AlignRight" : 3; )
      
      nodeAddButtonLocation.selection = case (getPrefFn #Tree #nodeAddButtonLocation) of
      ( "BeforeNode" : 1; "AfterNode" : 2; "AlignRight" : 3; )
      
      nodeIconClickAction.selection = case (getPrefFn #Tree #iconClickAction) of
      (
         "Hide" : 1;
         "Freeze" : 2;
         "SetActive" : 3;
      )
   )
)--End rollout.



rollout outliner_options_hierarchy "Hierarchy Mode"
(
   checkbox autoExpandHierarchy "Always expand entire hierarchy" pos:[marginX,  marginY];
   dropdownlist expandSelectionPolicy "" items:#("Never", "When Necessary", "Always") width:drpDwnW pos:[marginX, marginY + chkbxDY] tooltip:"If set to \"When necessary\", parents of selected nodes will only be expanded when no other selected nodes are directly visible.";
   label expandSelectionPolicyLbl "Expand selection" pos:[drpDwnLblX, marginY + chkbxDY + 3];
   dropdownlist expandHierarchyKey "" items:#("Alt", "Control", "Shift") width:drpDwnW pos:[marginX, marginY + chkbxDY * 2];
   label expandHierarchyLbl "Expand entire hierarchy key" pos:[drpDwnLblX, marginY + chkbxDY * 2 + 3];
   
   on autoExpandHierarchy changed checked do
   (
      setPrefFn #Tree #autoExpandHierarchy checked;
      outliner.tree.AutoExpandHierarchy = checked;
      expandSelectionPolicy.enabled = not checked;
      expandSelectionPolicyLbl.enabled = not checked;
   )

   on expandHierarchyKey selected sel do 
   (
      setPrefFn #Tree #expandHierarchyKey expandHierarchyKey.selected;
      outliner.tree.ExpandHierarchyKey = outliner.parseDotNetEnum "System.Windows.Forms.Keys" expandHierarchyKey.selected;
   )
   
   on expandSelectionPolicy selected sel do
   (
      local expPolicy = substituteString expandSelectionPolicy.selected " " "";
      setPrefFn #Tree #expandSelPolicyHierarchy expPolicy;
      outliner.tree.ExpandSelectionPolicyHierarchy = outliner.parseDotNetEnum "Outliner.ExpandPolicy" expPolicy;
   )

   function setUIValues =
   (
      autoExpandHierarchy.checked = getPrefFn #Tree #autoExpandHierarchy;
      expandHierarchyKey.selection = findItem expandHierarchyKey.items (getPrefFn #Tree #expandHierarchyKey);
      local expPolicy = getPrefFn #Tree #expandSelPolicyHierarchy;
      expandSelectionPolicy.selection = if (expPolicy == "Never") then 1 else if (expPolicy == "WhenNecessary") then 2 else 3;
      expandSelectionPolicy.enabled = not autoExpandHierarchy.checked;
      expandSelectionPolicyLbl.enabled = not autoExpandHierarchy.checked;
   )
)--End rollout.



rollout outliner_options_layer "Layer Mode"
(
   checkbox autoExpandLayer "Always expand all layers" pos:[marginX,  marginY];
   dropdownlist expandSelectionPolicy "" items:#("Never", "When Necessary", "Always") width:drpDwnW pos:[marginX, marginY + chkbxDY - 2] tooltip:"If set to \"When necessary\", parents of selected nodes will only be expanded when no other selected nodes are directly visible.";
   label expandSelectionPolicyLbl "Expand selection" pos:[drpDwnLblX, marginY + chkbxDY + 1];
   checkbox hideGroupMembersLayerMode "Hide group contents in layer mode" pos:[marginX,  marginY + chkbxDY * 2] tooltip:"When enabled, only top-level group heads will be shown. When moving it to another layer, all group contents will be moved as well.";
   
   checkbox editNewLayerName "Edit newly created layer name" pos:[marginX, marginY + chkbxDY * 3] tooltip:"Only applies to layers created through the context-menu in the Outliner.";
   checkbox setNewLayerActive "Set newly created layer to active" pos:[marginX, marginY + chkbxDY * 4] tooltip:"Only applies to layers created through the context-menu in the Outliner.";
   
   on autoExpandLayer changed checked do
   (
      setPrefFn #Tree #autoExpandLayer checked;
      outliner.tree.AutoExpandLayer = checked;
      expandSelectionPolicy.enabled = not checked;
      expandSelectionPolicyLbl.enabled = not checked;
   )
         
   on expandSelectionPolicy selected sel do
   (
      local expPolicy = substituteString expandSelectionPolicy.selected " " "";
      setPrefFn #Tree #expandSelPolicyLayer expPolicy;
      outliner.tree.ExpandSelectionPolicyLayer = outliner.parseDotNetEnum "Outliner.ExpandPolicy" expPolicy;
   )
   
   on hideGroupMembersLayerMode changed checked do
   (
      setPrefFn #Tree #hideGroupMembersLayerMode checked;
      outliner.tree.HideGroupMembersLayerMode = checked;
   )

   on editNewLayerName changed checked do
   (
      setPrefFn #Tree #editNewLayerName checked;
   )
   
   on setNewLayerActive changed checked do
   (
      setPrefFn #Tree #setNewLayerActive checked;
   )
   
   function setUIValues =
   (
      autoExpandLayer.checked = getPrefFn #Tree #autoExpandLayer;
      
      local expPolicy = getPrefFn #Tree #expandSelPolicyLayer;
      expandSelectionPolicy.selection = if (expPolicy == "Never") then 1 else if (expPolicy == "WhenNecessary") then 2 else 3;
      expandSelectionPolicy.enabled = not autoExpandLayer.checked;
      expandSelectionPolicyLbl.enabled = not autoExpandLayer.checked;
      
      hideGroupMembersLayerMode.checked = getPrefFn #Tree #hideGroupMembersLayerMode;
      editNewLayerName.checked = getPrefFn #Tree #editNewLayerName;
      setNewLayerActive.checked = getPrefFn #Tree #setNewLayerActive;
   )
)--End rollout.


rollout outliner_options_material "Material Mode"
(
   checkbox autoExpandMaterial "Always expand all materials" pos:[marginX,  marginY];
   dropdownlist expandSelectionPolicy "" items:#("Never", "When Necessary", "Always") width:drpDwnW pos:[marginX, marginY + chkbxDY] tooltip:"If set to \"When necessary\", parents of selected nodes will only be expanded when no other selected nodes are directly visible.";
   label expandSelectionPolicyLbl "Expand selection" pos:[drpDwnLblX, marginY + chkbxDY + 3];
   
   on autoExpandMaterial changed checked do
   (
      setPrefFn #Tree #autoExpandMaterial checked;
      outliner.tree.AutoExpandMaterial = checked;
      expandSelectionPolicy.enabled = not checked;
      expandSelectionPolicyLbl.enabled = not checked;
   )
   
   on expandSelectionPolicy selected sel do
   (
      local expPolicy = substituteString expandSelectionPolicy.selected " " "";
      setPrefFn #Tree #expandSelPolicyMaterial expPolicy;
      outliner.tree.ExpandSelectionPolicyMaterial = outliner.parseDotNetEnum "Outliner.ExpandPolicy" expPolicy;
   )
   
   function setUIValues =
   (
      autoExpandMaterial.checked = getPrefFn #Tree #autoExpandMaterial;
      local expPolicy = getPrefFn #Tree #expandSelPolicyMaterial;
      expandSelectionPolicy.selection = if (expPolicy == "Never") then 1 else if (expPolicy == "WhenNecessary") then 2 else 3;
      expandSelectionPolicy.enabled = not autoExpandMaterial.checked;
      expandSelectionPolicyLbl.enabled = not autoExpandMaterial.checked;
   )
)--End rollout.



rollout outliner_options_workflowtools "Workflow Tools Options"
(
   checkbox highlightLastSel "Highlight last selected object" pos:[marginX, marginY] tooltip:"This is useful when using maya-style parenting";
   
         
   on highlightLastSel changed checked do
   (
      setPrefFn #Tree #highlightLastSel checked;
      outliner.tree.HighlighLastSelectedObject = checked;
   )
   
   function setUIValues =
   (
      highlightLastSel.checked = getPrefFn #Tree #highlightLastSel;
   )
)--End rollout.


rollout outliner_options_about "About \x26 Donate"
(
   label versionLbl "";
   label nameLbl "Copyright \xa9 2011, Pier Janssen"
   hyperlink mailLbl "pier@threesixty.nl" address:"mailto:pier@threesixty.nl" align:#center;
   hyperlink siteLbl "outliner.threesixty.nl" address:"http://outliner.threesixty.nl/" align:#center offset:[0, -2];
   
   hyperlink donateLbl "Cick here to make a donation." align:#center offset:[0, 10] address:"http://script.threesixty.nl/outliner/index.php/donate";
   label donateLbl2 "Doing so will support future development and maintenance." align:#center offset:[0, -4];
   label donateLbl3 "And you'll get the Outliner Workflow Tools in return!" align:#center offset:[0, -4];
   label donateLbl4 "Thank you." align:#center offset:[0, -4];
   
   function setUIValues = 
   (
      versionLbl.text = "Version " + outliner.product_info.getValue #General #versionString;
   )
)--End rollout.



rollout outliner_options "Options"
(
   subrollout rollouts width:(outliner_options.width + 5) height:(outliner_options.height - 32) pos:[-1, 0];
   button closeBtn "Close" width:(outliner_options.width - 10) height:25 pos:[5, outliner_options.height - 28];
   
   local closing = false;
   
   function close = 
   (
      if (outliner_status != undefined) do outliner_status.optionsOpen = false;
      if (not closing) do destroyDialog outliner_options;
   )
   
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
   
   on closeBtn pressed do
      close();
            
   on outliner_options open do
   (
      if (checkOutlinerStatus()) do
      (
         AddSubRollout rollouts outliner_options_general;
         AddSubRollout rollouts outliner_options_visual rolledUp:true;
         AddSubRollout rollouts outliner_options_hierarchy rolledUp:true;
         AddSubRollout rollouts outliner_options_layer rolledUp:true;
         AddSubRollout rollouts outliner_options_material rolledUp:true;
         
         if (outliner.product_info.getValue #General #workflowToolsInstalled) do
            AddSubRollout rollouts outliner_options_workflowtools rolledUp:true;
         
         AddSubRollout rollouts outliner_options_about;
         
         getPrefFn = outliner.prefs.getValue;
         setPrefFn = outliner.prefs.setValue;
         
         for r in rollouts.rollouts do
            r.setUIValues();
      )
   )
   
   on outliner_options close do
   (
      closing = true;
      close();
   )
)--End rollout.

)