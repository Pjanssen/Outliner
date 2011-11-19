rollout outliner_main "Outliner"
(
	local getPrefFn;
	local setPrefFn;
	local margin = 2;
	
	dotNetControl mainContainer "Outliner.Controls.MainContainer" pos:[margin, margin];
	
	--Position Elements.
	function positionElements = 
	(
		mainContainer.width	= outliner_main.width - margin * 2;
		mainContainer.height = outliner_main.height - margin * 2;
	)
	
	
	
	/**
	 * Refresh Layer Names Timer.
	 */
	/*
	timer refreshLayerNamesTimer interval:400 active:false;
	on refreshLayerNamesTimer tick do outliner_callbacks.refreshLayerNames();
	*/
	
	


	/** FILTER **/
	function setHideByCategory forceSet:false =
	(
		local objFilterAffectVpt	= getPrefFn #Tree #objFilterAffectVpt;
		local objFilterEnabled		= getPrefFn #Tree #objFilterEnabled;
		local objFilter				= getPrefFn #Tree #objFilter;
		local hideByCat_enum 		= #(&hideByCategory.geometry, &hideByCategory.shapes, &hideByCategory.lights, 
										&hideByCategory.cameras, &hideByCategory.helpers, &hideByCategory.spacewarps, 
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
	
	
	
	
	
	
	/**
	 * TREE EVENTS FUNCTION CACHE
	 */
	 /*
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
		TreeEventHandlers_SelectionChanged			= outliner_TreeEventHandlers.SelectionChanged;
		TreeEventHandlers_NodeHidden	 			= outliner_TreeEventHandlers.NodeHidden;
		TreeEventHandlers_NodeFrozen				= outliner_TreeEventHandlers.NodeFrozen;
		TreeEventHandlers_NodeBoxModeChanged		= outliner_TreeEventHandlers.NodeBoxModeChanged;
		TreeEventHandlers_NodeRenamed				= outliner_TreeEventHandlers.NodeRenamed;
		TreeEventHandlers_ObjectMaterialChanged		= outliner_TreeEventHandlers.ObjectMaterialChanged;
		TreeEventHandlers_SpaceWarpBound			= outliner_TreeEventHandlers.SpaceWarpBound;
		TreeEventHandlers_ObjectAddedToContainer	= outliner_TreeEventHandlers.ObjectAddedToContainer;
		TreeEventHandlers_ObjectLayerChanged		= outliner_TreeEventHandlers.ObjectLayerChanged;
		TreeEventHandlers_ObjectLinked				= outliner_TreeEventHandlers.ObjectLinked;
		TreeEventHandlers_ObjectGrouped				= outliner_TreeEventHandlers.ObjectGrouped;
		TreeEventHandlers_LayerLinked				= outliner_TreeEventHandlers.LayerLinked;
		TreeEventHandlers_LayerActiveChanged		= outliner_TreeEventHandlers.LayerActiveChanged;
		TreeEventHandlers_ContextMenuOpened			= outliner_TreeEventHandlers.ContextMenuOpened;
		TreeEventHandlers_ContextMenuItemClicked	= outliner_TreeEventHandlers.ContextMenuItemClicked;
	)
	
	function disposeFunctionCache =
	(
		outliner_handleKeyUp = undefined;
		TreeEventHandlers_SelectionChanged			= undefined;
		TreeEventHandlers_NodeHidden				= undefined;
		TreeEventHandlers_NodeFrozen				= undefined;
		TreeEventHandlers_NodeBoxModeChanged		= undefined;
		TreeEventHandlers_NodeRenamed				= undefined;
		TreeEventHandlers_ObjectMaterialChanged		= undefined;
		TreeEventHandlers_SpaceWarpBound			= undefined;
		TreeEventHandlers_ObjectAddedToContainer	= undefined;
		TreeEventHandlers_ObjectLayerChanged		= undefined;
		TreeEventHandlers_ObjectLinked				= undefined;
		TreeEventHandlers_ObjectGrouped				= undefined;
		TreeEventHandlers_LayerLinked				= undefined;
		TreeEventHandlers_LayerActiveChanged		= undefined;
		TreeEventHandlers_ContextMenuOpened			= undefined;
		TreeEventHandlers_ContextMenuItemClicked	= undefined;
	)
	*/
	
	
	on mainContainer mousedown s e do
	(
		format "%\n" e;
	)
	
	/**
	 * WINDOW EVENTS
	 */
	--Rollout opened.
	on outliner_main open do
	(
		getPrefFn = outliner.prefs.getValue;
		setPrefFn = outliner.prefs.setValue;

		positionElements();
		
/*
		outliner.setTreeColorScheme (getPrefFn #Visual #colorscheme);
		tree.IconSet				= outliner.parseDotNetEnum "Outliner.IconSet" (getPrefFn #Visual #iconSet);
		
		tree.TreeViewNodeSorter 	= dotNetObject ("Outliner.NodeSorters." + (getPrefFn #Tree #sortMode) + "Sorter");	
		
		tree.ShowNodeHideButton			= getPrefFn #Tree #showNodeHideButton;
		tree.NodeHideButtonLocation		= outliner.parseDotNetEnum "Outliner.NodeButtonsLocation" (getPrefFn #Tree #nodeHideButtonLocation);
		tree.ShowNodeFreezeButton		= getPrefFn #Tree #showNodeFreezeButton;
		tree.NodeFreezeButtonLocation	= outliner.parseDotNetEnum "Outliner.NodeButtonsLocation" (getPrefFn #Tree #nodeFreezeButtonLocation);
		tree.ShowNodeBoxModeButton		= getPrefFn #Tree #showNodeBoxModeButton;
		tree.NodeBoxModeButtonLocation	= outliner.parseDotNetEnum "Outliner.NodeButtonsLocation" (getPrefFn #Tree #nodeBoxModeButtonLocation);
		tree.ShowNodeAddButton			= getPrefFn #Tree #showNodeAddButton;
		tree.NodeAddButtonLocation		= outliner.parseDotNetEnum "Outliner.NodeButtonsLocation" (getPrefFn #Tree #nodeAddButtonLocation);
		tree.InvertNodeHideButton		= getPrefFn #Tree #invertNodeHideButton;
		
		tree.HighlighLastSelectedObject	= getPrefFn #Tree #highlightLastSel;
		tree.AutoExpandHierarchy		= getPrefFn #Tree #autoExpandHierarchy;
		tree.AutoExpandLayer			= getPrefFn #Tree #autoExpandLayer;
		tree.AutoExpandMaterial			= getPrefFn #Tree #autoExpandMaterial;
		tree.HideGroupMembersLayerMode 	= getPrefFn #Tree #hideGroupMembersLayerMode;
		
		tree.ListMode				= outliner.parseDotNetEnum "Outliner.OutlinerListMode" (getPrefFn #Tree #listMode);
		tree.IconClickAction		= outliner.parseDotNetEnum "Outliner.IconClickAction" (getPrefFn #Tree #iconClickAction);
		tree.DoubleClickAction		= outliner.parseDotNetEnum "Outliner.DoubleClickAction" (getPrefFn #Tree #doubleClickAction);
		tree.DragMouseButton		= outliner.parseDotNetEnum "System.Windows.Forms.MouseButtons" (getPrefFn #Tree #dragMouseButton);
		tree.ExpandHierarchyKey 	= outliner.parseDotNetEnum "System.Windows.Forms.Keys" (getPrefFn #Tree #expandHierarchyKey);
		
		tree.ExpandSelectionPolicyHierarchy = outliner.parseDotNetEnum "Outliner.ExpandPolicy" (getPrefFn #Tree #expandSelPolicyHierarchy);
		tree.ExpandSelectionPolicyLayer		= outliner.parseDotNetEnum "Outliner.ExpandPolicy" (getPrefFn #Tree #expandSelPolicyLayer);
		tree.ExpandSelectionPolicyMaterial	= outliner.parseDotNetEnum "Outliner.ExpandPolicy" (getPrefFn #Tree #expandSelPolicyMaterial);
			

		tree.Filter.Enabled			= getPrefFn #Tree #objFilterEnabled;
		tree.Filter.AffectLayers	= getPrefFn #Tree #objFilterAffectLayers;
		local filter_enum	= #(&tree.Filter.showGeometry, &tree.Filter.showShapes, &tree.Filter.showLights, &tree.Filter.showCameras,
					   			&tree.Filter.showHelpers, &tree.Filter.showSpaceWarps, &tree.Filter.showBones, &tree.Filter.showParticles,
					   			&tree.Filter.showXRefs, &tree.Filter.showHidden, &tree.Filter.showFrozen);
		local objFilter = (getPrefFn #Tree #objFilter);
		for i = 1 to filter_enum.count do *filter_enum[i] = objFilter[i];

		setHideByCategory();
		
		createFunctionCache();
*/
	)
	
	
	
	--Rollout closed.
	on outliner_main close do 
	(
--		disposeFunctionCache();
		
		--Avoid calling closeOutliner() again when dialog is closed from that function.
		if (outliner_status != undefined AND not outliner_status.closingOutliner) do
		(
			outliner.close();
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
	/*
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

	on tree NodeFrozen e do
		TreeEventHandlers_NodeFrozen e;
		
	on tree NodeBoxModeChanged e do
		TreeEventHandlers_NodeBoxModeChanged e;
		
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

	on tree LayerActiveChanged e do
		TreeEventHandlers_LayerActiveChanged e;
		

	on tree ContextMenuOpened e do
		TreeEventHandlers_ContextMenuOpened e;
		
	on tree ContextMenuItemClicked e do
		TreeEventHandlers_ContextMenuItemClicked e;
	*/
)