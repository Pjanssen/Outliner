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
		
		checkbox openAtStartup "Open at 3dsMax startup" pos:[marginX, marginY + chkbxDY];
		checkbox filterAffectVpt "Filter affects viewports" pos:[marginX, marginY + chkbxDY * 2];
		dropdownlist dragMouseButton "" width:drpDwnW items:#("Left", "Middle") pos:[marginX, marginY + chkbxDY * 3];
		label dragdropMouseBtnLbl "Drag \x26\x26 Drop Mousebutton" pos:[drpDwnLblX, marginY + chkbxDY * 3 + 3];
		dropdownlist doubleClickAction "" width:drpDwnW items:#("Expand", "Rename") pos:[marginX, marginY + chkbxDY * 4];
		label doubleClickActionLbl "Double-Click Action" pos:[drpDwnLblX, marginY + chkbxDY * 4 + 3];

		on checkForUpdates changed checked do
			setPrefFn #General #checkForUpdates checked;
			
		on checkUpdatesInterval changed val do
			setPrefFn #General #checkUpdatesInterval val;
		
		
		on checkNowBtn changed checked do
		(
			if (checked) then
			(
				checkNowBtn.text = "Cancel";
				outliner.getUpdateVersionAsync true;
			)
			else
			(
				checkNowBtn.text = "Check now";
				outliner.webClient.CancelAsync();
			)
		)
			
		on openAtStartup changed checked do
			setPrefFn #General #openAtStartup checked;
		
		on filterAffectVpt changed checked do
		(
			setPrefFn #Tree #objFilterAffectsVpt checked;
			outliner_main.setHideByCategory();
		)
		
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
			openAtStartup.checked = getPrefFn #General #openAtStartup;
			filterAffectVpt.checked = getPrefFn #Tree #objFilterAffectsVpt;
			dragMouseButton.selection = findItem dragMouseButton.items (getPrefFn #Tree #dragMouseButton);
			doubleClickAction.selection = findItem doubleClickAction.items (getPrefFn #Tree #doubleClickAction);
		)
	)
	
	
	
	rollout outliner_options_visual "Visual"
	(
		dropdownList colorScheme "" width:drpDwnW pos:[marginX, marginY];
		label colorSchemeLbl "Color Scheme" pos:[drpDwnLblX, marginY + 4];
		dropdownList iconset "" width:drpDwnW pos:[marginX, marginY + chkbxDY];
		label iconsetLbl "Icon Set" pos:[drpDwnLblX, marginY + chkbxDY + 4];
		checkbox invertIcons "Adjust icons to dark color scheme" pos:[marginX, marginY + chkbxDY * 2];
		
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
		
		function setUIValues = 
		(
			colorScheme.items		= getINISetting (outliner.dir + "colorSchemes.ini");
			colorScheme.selection	= findItem colorScheme.items (getPrefFn #Visual #colorScheme);
			iconSet.Items				= outliner.getNamesDotNetEnum "Outliner.IconSet";
			iconSet.selection			= findItem iconSet.items (getPrefFn #Visual #iconSet);
			invertIcons.checked		= getPrefFn #Visual #invertIcons;
		)
	)
	
	
	
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
	)
	
	
	
	rollout outliner_options_layer "Layer Mode"
	(
		checkbox autoExpandLayer "Always expand all layers" pos:[marginX,  marginY];
		dropdownlist expandSelectionPolicy "" items:#("Never", "When Necessary", "Always") width:drpDwnW pos:[marginX, marginY + chkbxDY - 2] tooltip:"If set to \"When necessary\", parents of selected nodes will only be expanded when no other selected nodes are directly visible.";
		label expandSelectionPolicyLbl "Expand selection" pos:[drpDwnLblX, marginY + chkbxDY + 1];
		checkbox hideGroupMembersLayerMode "Hide group contents in layer mode" pos:[marginX,  marginY + chkbxDY * 2] tooltip:"When enabled, only top-level group heads will be shown. When moving it to another layer, all group contents will be moved as well.";
		checkbox addNestedLayerCheck "Add Outliner check to scene when using nested layers" pos:[marginX, marginY + chkbxDY * 3] tooltip:"If this option is enabled, and someone who doesn't have the Outliner installed uses a scene with nested layers, he/she will be notified of this (once).";
		
		
		on autoExpandLayer changed checked do
		(
			setPrefFn #Tree #autoExpandLayer checked;
			outliner.tree.AutoExpandLayer = checked;
			expandSelectionPolicy.enabled = not checked;
			expandSelectionPolicyLbl.enabled = not checked;
		)
		
		on hideGroupMembersLayerMode changed checked do
		(
			setPrefFn #Tree #hideGroupMembersLayerMode checked;
			outliner.tree.HideGroupMembersLayerMode = checked;
		)
	
		on addNestedLayerCheck changed checked do
			setPrefFn #General #addNestedLayerMessage checked;
			
		on expandSelectionPolicy selected sel do
		(
			local expPolicy = substituteString expandSelectionPolicy.selected " " "";
			setPrefFn #Tree #expandSelPolicyLayer expPolicy;
			outliner.tree.ExpandSelectionPolicyLayer = outliner.parseDotNetEnum "Outliner.ExpandPolicy" expPolicy;
		)
		
		function setUIValues =
		(
			autoExpandLayer.checked = getPrefFn #Tree #autoExpandLayer;
			hideGroupMembersLayerMode.checked = getPrefFn #Tree #hideGroupMembersLayerMode;
			addNestedLayerCheck.checked = getPrefFn #General #addNestedLayerMessage;
			
			local expPolicy = getPrefFn #Tree #expandSelPolicyLayer;
			expandSelectionPolicy.selection = if (expPolicy == "Never") then 1 else if (expPolicy == "WhenNecessary") then 2 else 3;
			expandSelectionPolicy.enabled = not autoExpandLayer.checked;
			expandSelectionPolicyLbl.enabled = not autoExpandLayer.checked;
		)
	)
	
	
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
	)


	
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
	)
	
	
	rollout outliner_options_about "About \x26 Donate"
	(
		imgTag logoImg width:262 height:66 align:#center offset:[0, -10]
		label nameLbl "Copyright \xa9 2010, Pier Janssen"
		hyperlink mailLbl "pier@threesixty.nl" address:"mailto:pier@threesixty.nl" align:#center;
		hyperlink siteLbl "www.threesixty.nl" address:"http://www.threesixty.nl/" align:#center offset:[0, -2];
		
		hyperlink donateLbl "Cick here to make a small donation through PayPal." align:#center offset:[0, 10] address:"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=XQGQPSEAW5HVC&lc=GB&item_name=Outliner%20donations%20%2d%20Pier%20Janssen&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted";
		label donateLbl2 "Doing so will support future development and maintenance." align:#center offset:[0, -4];
		label donateLbl3 "And you'll get the Outliner Workflow Tools in return!" align:#center offset:[0, -4];
		label donateLbl4 "Thank you." align:#center offset:[0, -4];
			
		on outliner_options_about open do
		(
			if (outliner.ui.usingMaxDarkScheme()) then
			(
				logoImg.bitmap = openBitmap (Outliner.icondir + "logo_dark.bmp");
				logoImg.transparent = color 82 82 82;
			)
			else
			(
				logoImg.bitmap = openBitmap (Outliner.icondir + "logo_light.bmp");
				logoImg.transparent = color 186 186 186;
			)
		)
		
		function setUIValues = ()
	)
	
	
	
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
				AddSubRollout rollouts outliner_options_hierarchy;
				AddSubRollout rollouts outliner_options_layer;
				AddSubRollout rollouts outliner_options_material;
				
				if (outliner.prefs.getValue #General #workflowToolsInstalled) do
					AddSubRollout rollouts outliner_options_workflowtools rolledUp:true;
				
				AddSubRollout rollouts outliner_options_about rolledUp:true;
				
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
	)
)