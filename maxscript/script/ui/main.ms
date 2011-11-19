rollout outliner_main ("Outliner " + outliner.versionStr)
(
	local getPrefFn;
	local setPrefFn;
	local btn_w = 25;
	local btn_h = 25;
	local margin = 4;
	local sortmode_images;
	
	editText search "" pos:[margin - 4, margin];
	checkbutton searchCaseSensitive "" width:search.height height:search.height pos:[margin, margin] tooltip:"Search case-sensitive";
	
	dotNetControl tree "Outliner.TreeView" pos:[margin, margin + search.height + 2];
	
	--Button y position is set in positionElements()
	checkbutton listmode_h tooltip:"Hierarchy Mode" width:btn_w height:btn_h pos:[margin, 0];
	checkbutton listmode_l tooltip:"Layer Mode" width:btn_w height:btn_h pos:[margin + btn_w, 0];
	checkbutton listmode_m tooltip:"Material Mode (beta)" width:btn_w height:btn_h pos:[margin + btn_w*2, 0];
	
	button sortmode_btn width:btn_w height:btn_h pos:[margin + btn_w * 3 + 4, 0];
	checkbutton filter_enabled tooltip:"Enable Filter\nRight-Click to configure filter" width:btn_w height:btn_h pos:[margin + btn_w * 4 + 8, 0];
	button options tooltip:"Options" width:btn_w height:btn_h pos:[0, 0];
	
	
	--Position Elements.
	function positionElements = 
	(
		local mainW = outliner_main.width;
		
		search.width				= mainW - search.height - 2 - margin * 2;
		searchCaseSensitive.pos.x	= mainW - search.height - margin;
		tree.width					= mainW - margin * 2;
		
		options.pos.x = mainW - margin - btn_w;
		
		local btn_y = outliner_main.height - btn_h - margin;
		listmode_h.pos.y = listmode_l.pos.y = listmode_m.pos.y = filter_enabled.pos.y = sortmode_btn.pos.y = options.pos.y = btn_y;
		
		tree.height		= outliner_main.height - search.height - btn_h - margin * 2 - 6;
	)
	
	
	
	/**
	 * Refresh Layer Names Timer.
	 */
	timer refreshLayerNamesTimer interval:400 active:false;
	on refreshLayerNamesTimer tick do outliner_callbacks.refreshLayerNames();
	
	
	
	/**
	 * BUTTON EVENTS & FUNCTIONS
	 */
	local buttons = #(listmode_h, listmode_l, listmode_m, filter_enabled, options, searchCaseSensitive);
	function setButtonImages =
	(
		local mainImgFile = outliner.icondir + "main_icons.bmp";
		local sortImgFile = outliner.icondir + "sortmode_icons.bmp";
		
		-- ColorTheme feature was introduced in 3dsmax2010 (v12).
		if (outliner.maxV < 12) then
		(
			if (outliner.ui.usingMaxDarkScheme()) do
			(
				mainImgFile = outliner.icondir + "main_icons_dark.bmp";
				sortImgFile = outliner.icondir + "sortmode_icons_dark.bmp";
			)
				
			for i = 1 to buttons.count do buttons[i].images = #(mainImgFile, outliner.icondir + "main_icons_a.bmp", 6, i, i, i, i);
			sortmode_images = #(sortImgFile, outliner.icondir + "sortmode_icons_a.bmp", 6, 1, 1, 1, 1);
		)
		else
		(
			for i = 1 to buttons.count do buttons[i].images = #(mainImgFile, undefined, 6, i, i, i, i, true, true);
			sortmode_images = #(sortImgFile, undefined, 6, 1, 1, 1, 1, true, true);
		)
		sortmode_btn.images = sortmode_images;
	)
	
	
	function setButtonStates =
	(
		searchCaseSensitive.checked	= getPrefFn #Tree #searchCaseSensitive;
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
			
			if ((getPrefFn #General #matModeFirstRun) == true) do
			(
				setPrefFn #General #matModeFirstRun false;
				messageBox "Warning: beta code ahead!\nThe material mode is currently in development, so some things might not work as you'd expect.\nIf you encounter crashes or have other feedback, let me know!\nMy contact details can be found in the options dialog." title:"Material mode beta";
			)
			
			outliner.switchListMode "Material";
		)
	)
	
	
	/** SORT MODE **/
	on sortmode_btn pressed do
	(
		outliner.UI.openSortModeWindow();
	)



	/** FILTER **/
	function setHideByCategory =
	(
		if (getPrefFn #Tree #objFilterAffectsVpt) do
		(
			local objFilter = getPrefFn #Tree #objFilter;
			local objFilterEnabled = getPrefFn #Tree #objFilterEnabled;
			local hideByCat_enum = #(&hideByCategory.geometry, &hideByCategory.shapes, &hideByCategory.lights, &hideByCategory.cameras,
									&hideByCategory.helpers, &hideByCategory.spacewarps, &hideByCategory.bones, &hideByCategory.particles);
			
			disableSceneRedraw();
			
			if (not objFilterEnabled) then
			(
				for i = 1 to hideByCat_enum.count do *hideByCat_enum[i] = false;
				maxOps.hideFrozenObjects = false;
			)
			else
			(
				for i = 1 to hideByCat_enum.count do not objFilter[i];
				maxOps.hideFrozenObjects = not objFilter[11];
			)
			
			enableSceneRedraw()
			completeRedraw();
		)
	)
	
	function setFilterEnabled enabled =
	(
		setPrefFn #Tree #objFilterEnabled enabled;
		
		setHideByCategory();
		
		tree.Filter.Enabled = enabled;
		tree.FillTree();
	)
	
	on filter_enabled changed checked do
	(
		setFilterEnabled checked;
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
	on search changed text do 
	(
		tree.SelectNodesByName text (getPrefFn #Tree #searchCaseSensitive);
	)
	
	on searchCaseSensitive changed checked do
	(
		setPrefFn #Tree #searchCaseSensitive checked;
		if (search.text != "") do
			tree.SelectNodesByName search.text checked;
	)
	
	
	
	
	
	/**
	 * TREE EVENTS FUNCTION CACHE
	 */
	local outliner_handleKeyUp;
	local TreeEventHandlers_SelectionChanged;
	local TreeEventHandlers_NodeHidden;
	local TreeEventHandlers_NodeRenamed;
	local TreeEventHandlers_ObjectMaterialChanged;
	local TreeEventHandlers_SpaceWarpBound;
	local TreeEventHandlers_ObjectAddedToContainer;
	local TreeEventHandlers_ObjectLayerChanged;
	local TreeEventHandlers_ObjectLinked;
	local TreeEventHandlers_ObjectGrouped;
	local TreeEventHandlers_LayerLinked;
	local TreeEventHandlers_ContextMenuOpened;
	local TreeEventHandlers_ContextMenuItemClicked;
	
	function createFunctionCache =
	(
		outliner_handleKeyUp = outliner.handleKeyUp
		TreeEventHandlers_SelectionChanged			= outliner_TreeEventHandlers.SelectionChanged;
		TreeEventHandlers_NodeHidden	 			= outliner_TreeEventHandlers.NodeHidden;
		TreeEventHandlers_NodeRenamed				= outliner_TreeEventHandlers.NodeRenamed;
		TreeEventHandlers_ObjectMaterialChanged		= outliner_TreeEventHandlers.ObjectMaterialChanged;
		TreeEventHandlers_SpaceWarpBound			= outliner_TreeEventHandlers.SpaceWarpBound;
		TreeEventHandlers_ObjectAddedToContainer	= outliner_TreeEventHandlers.ObjectAddedToContainer;
		TreeEventHandlers_ObjectLayerChanged		= outliner_TreeEventHandlers.ObjectLayerChanged;
		TreeEventHandlers_ObjectLinked				= outliner_TreeEventHandlers.ObjectLinked;
		TreeEventHandlers_ObjectGrouped				= outliner_TreeEventHandlers.ObjectGrouped;
		TreeEventHandlers_LayerLinked				= outliner_TreeEventHandlers.LayerLinked;
		TreeEventHandlers_ContextMenuOpened			= outliner_TreeEventHandlers.ContextMenuOpened;
		TreeEventHandlers_ContextMenuItemClicked	= outliner_TreeEventHandlers.ContextMenuItemClicked;
	)
	
	function disposeFunctionCache =
	(
		outliner_handleKeyUp = undefined;
		TreeEventHandlers_SelectionChanged			= undefined;
		TreeEventHandlers_NodeHidden				= undefined;
		TreeEventHandlers_NodeRenamed				= undefined;
		TreeEventHandlers_ObjectMaterialChanged		= undefined;
		TreeEventHandlers_SpaceWarpBound			= undefined;
		TreeEventHandlers_ObjectAddedToContainer	= undefined;
		TreeEventHandlers_ObjectLayerChanged		= undefined;
		TreeEventHandlers_ObjectLinked				= undefined;
		TreeEventHandlers_ObjectGrouped				= undefined;
		TreeEventHandlers_LayerLinked				= undefined;
		TreeEventHandlers_ContextMenuOpened			= undefined;
		TreeEventHandlers_ContextMenuItemClicked	= undefined;
	)
	
	
	
	
	
	/**
	 * WINDOW EVENTS
	 */
	--Rollout opened.
	on outliner_main open do
	(
		outliner.setTreeInst tree;
		getPrefFn = outliner.prefs.getValue;
		setPrefFn = outliner.prefs.setValue;

		positionElements();
		setButtonImages();
		setButtonStates();
		setSortModeBtnImages();

		outliner.setTreeColorScheme (getPrefFn #Visual #colorscheme);
		tree.IconSet				= outliner.parseDotNetEnum "Outliner.IconSet" (getPrefFn #Visual #iconSet);
		
		tree.TreeViewNodeSorter 	= dotNetObject ("Outliner.NodeSorters." + (getPrefFn #Tree #sortMode) + "Sorter");	
		
		tree.HighlighLastSelectedObject	= (getPrefFn #Tree #highlightLastSel);
		tree.AutoExpandHierarchy		= (getPrefFn #Tree #autoExpandHierarchy);
		tree.AutoExpandLayer			= (getPrefFn #Tree #autoExpandLayer);
		tree.AutoExpandMaterial			= (getPrefFn #Tree #autoExpandMaterial);
		tree.HideGroupMembersLayerMode 	= (getPrefFn #Tree #hideGroupMembersLayerMode);
		
		tree.ListMode			 = outliner.parseDotNetEnum "Outliner.OutlinerListMode" (getPrefFn #Tree #listMode);
		tree.DoubleClickAction	 = outliner.parseDotNetEnum "Outliner.DoubleClickAction" (getPrefFn #Tree #doubleClickAction);
		tree.DragMouseButton	 = outliner.parseDotNetEnum "System.Windows.Forms.MouseButtons" (getPrefFn #Tree #dragMouseButton);
		tree.ExpandHierarchyKey	 = outliner.parseDotNetEnum "System.Windows.Forms.Keys" (getPrefFn #Tree #expandHierarchyKey);
		
		tree.ExpandSelectionPolicyHierarchy = outliner.parseDotNetEnum "Outliner.ExpandPolicy" (getPrefFn #Tree #expandSelPolicyHierarchy);
		tree.ExpandSelectionPolicyLayer		= outliner.parseDotNetEnum "Outliner.ExpandPolicy" (getPrefFn #Tree #expandSelPolicyLayer);
		tree.ExpandSelectionPolicyMaterial	= outliner.parseDotNetEnum "Outliner.ExpandPolicy" (getPrefFn #Tree #expandSelPolicyMaterial);
			

		tree.Filter.Enabled	= (getPrefFn #Tree #objFilterEnabled);
		local filter_enum	= #(&tree.Filter.showGeometry, &tree.Filter.showShapes, &tree.Filter.showLights, &tree.Filter.showCameras,
					   			&tree.Filter.showHelpers, &tree.Filter.showSpaceWarps, &tree.Filter.showBones, &tree.Filter.showParticles,
					   			&tree.Filter.showXRefs, &tree.Filter.showHidden, &tree.Filter.showFrozen);
		local objFilter = (getPrefFn #Tree #objFilter);
		for i = 1 to filter_enum.count do *filter_enum[i] = objFilter[i];

		setHideByCategory();
		
		createFunctionCache();
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
		setPrefFn #Window #posx arg[1];
		setPrefFn #Window #posy arg[2];
	)
	
	
	
	--Rollout resized.
	on outliner_main resized arg do
	(
		if (outliner_status.windowOpen AND not outliner_status.closingOutliner AND outliner_main.dialogBar) do
		(
			local dockState = cui.getDockState outliner_main;
			if ((getPrefFn #Window #dockFlag) != dockState) do
			(
				setPrefFn #Window #dockFlag (cui.getDockState outliner_main);
				if (dockState == #cui_floatable) do
				(
					cui.UnRegisterDialogBar outliner_main;
				
					outliner_main.width -= 8;
				
					cui.RegisterDialogBar outliner_main minSize:[outliner.ui.mainMinWidth, outliner.ui.mainMinHeight] maxSize:[-1,-1] style:#(#cui_dock_vert, #cui_floatable);
				)
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
	
	

	on tree SelectionChanged e do
		TreeEventHandlers_SelectionChanged e;

	
	on tree NodeHidden e do
		TreeEventHandlers_NodeHidden e;


	on tree NodeRenamed e do
		TreeEventHandlers_NodeRenamed e;


	on tree ObjectMaterialChanged e do
		TreeEventHandlers_ObjectMaterialChanged e;


	on tree SpaceWarpBound e do
		TreeEventHandlers_SpaceWarpBound e;


	on tree ObjectAddedToContainer e do
		TreeEventHandlers_ObjectAddedToContainer e;


	on tree ObjectLayerChanged e do
		TreeEventHandlers_ObjectLayerChanged e;
		
	
	on tree ObjectLinked e do
		TreeEventHandlers_ObjectLinked e;
		
		
	on tree ObjectGrouped e do
		TreeEventHandlers_ObjectGrouped e;
		
		
	on tree LayerLinked e do
		TreeEventHandlers_LayerLinked e;


	on tree ContextMenuOpened e do
		TreeEventHandlers_ContextMenuOpened e;
		
	on tree ContextMenuItemClicked e do
		TreeEventHandlers_ContextMenuItemClicked e;
	
)