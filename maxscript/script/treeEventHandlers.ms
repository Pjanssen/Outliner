struct outliner_TreeEventHandlers
(
	/**
	 * SELECTION CHANGED
	 */
	function SelectionChanged e =
	(
		try 
		(
			outliner_status.selectedInOutliner = true;
			
			local listMode = outliner.prefs.getValue #Tree #listMode;
			
			undo "Select" on
			(
				with redraw off 
				(
					local selNodes = for n in outliner.tree.SelectedObjectHandles where (isValidNode (obj = (GetAnimByHandle n))) collect obj;
					
					-- Open/Close groups where necessary.
					outliner.handleGroupOpeningClosing selNodes true;				
					
					-- Select nodes.
					if (selNodes.count == 0) then
						clearSelection();
					else
						select selNodes;
						
	
					-- Select layers.
					if (listMode == "Layer") then
					(
						for l in e.SelectedLayerHandles do (GetAnimByHandle l).select true;
					)
					
					-- Select materials.
					else if (listMode == "Material" AND (MatEditor.isOpen())) then
					(
						local matFound = false;
						for m in e.SelectedMaterialHandles while (not matFound) do
						(
							local mat = GetAnimByHandle m;
							if (mat != undefined) do
							(
								local matIndex = findItem meditmaterials mat;
								if (matIndex != 0) do
								(
									activeMeditSlot = matIndex;
									matFound = true;
								)
							)
						)
					)
				)
			)
		
			outliner_status.selectedInOutliner = false;
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	
	
	
	/**
	 * NODE HIDDEN
	 */
	function NodeHidden e =
	(
		try
		(
			outliner_status.hiddenInOutliner = true;
			
			local undoString = if (e.NewValue) then "Hide" else "Unhide";
			
			undo undoString on
			(
				with redraw off
				(		
					for handle in e.Handles do
					(
						local n = GetAnimByHandle handle;
						if (n != undefined) do
						(
							if (isKindOf n node) then
								n.isNodeHidden = e.newValue;
							else if (isKindOf n Base_Layer) then
								outliner_NestedLayers.setLayerProperty n #isHidden e.newValue;
						)
					)
				)
			)
			
			outliner_status.hiddenInOutliner = false;
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	
	
	
	
	/**
	 * NODE RENAMED
	 */
	function NodeRenamed e =
	(
		try
		(
			outliner_status.renamedInOutliner = true;
			
			local n = (GetAnimByHandle e.Handle);
			
			if (n != undefined) do
			(
				-- Rename node.
				if (isKindOf n Node OR isKindOf n Material) then
				(
					n.name = e.Name;
				)
				
				-- Rename layer.
				else if (isKindOf n Base_Layer) then
				(
					n.setName e.Name;
				)
			)
			
			outliner_status.renamedInOutliner = false;
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	
	
	
	
	/**
	 * MATERIAL CHANGED
	 */
	function ObjectMaterialChanged e =
	(
		try
		(
			outliner_status.matChangedInOutliner = true;
		
			local mat = GetAnimByHandle e.NewValue;
					
			if (mat != undefined OR (mat == undefined AND e.NewValue == -1)) do
			(
				local undoStr = if (mat != undefined) then "Assign material" else "Remove material";
				
				undo undoStr on
				(
					with redraw off
					(
						for h in e.Handles do
						(
							local n = GetAnimByHandle h;
							if (IsValidNode n) do
								n.material = mat;
						)
					)
				)
			)
			
			outliner_status.matChangedInOutliner = false;
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	
	
	
	/**
	 * SPACEWARP BOUND
	 */
	function SpaceWarpBound e =
	(
		try
		(
			undo "Bind Spacewarp" on
			(
				with redraw off
				(
					local target = GetAnimByHandle e.TargetHandle;
					
					if (isValidNode target) do
					(
						for h in e.Handles do
						(
							local n = GetAnimByHandle h;
							if (isValidNode n) do
								bindSpaceWarp n target;
						)
					)
				)
			)
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	
	
	
	/**
	 * OBJECT ADDED TO CONTAINER
	 */
	function ObjectAddedToContainer e =
	(
		try
		(
			local targetNode = GetAnimByHandle e.TargetHandle;
			local nodes = for handle in e.Handles collect (GetAnimByHandle handle);
			
			if (targetNode != undefined AND nodes.count > 0 AND e.IsGroupMember) do
			(
				undo "Add to container" on
				(
					targetNode.AddNodesToContent nodes;
				)
			)
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	
	
	/**
	 * OBJECT LAYER CHANGED
	 */
	function ObjectLayerChanged e =
	(
		try
		(
			outliner_status.layerChangedInOutliner = true;
			
			local layer = (GetAnimByHandle e.TargetHandle);
			if (layer != undefined) do
			(
				undo "Change Layers" on 
				(
					with redraw off
					(
						for h in e.Handles do
						(
							local n = GetAnimByHandle h;
							if (isValidNode n) do layer.addNode n;
						)
					)
				)
			)
			
			outliner_status.layerChangedInOutliner = false;
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	
	
	
	/**
	 * NODE LINKED
	 */
	function ObjectLinked e =
	(
		try
		(
			outliner_status.linkedInOutliner = true;
			
			local undoString;
			local targetNode;
			
			if (e.TargetHandle != -1) then 
			(
				undoString = "Link";
				targetNode = (GetAnimByHandle e.TargetHandle);
			)
			else
				undoString = "Unlink";
			
			
			undo undoString on
			(
				with redraw off
				(
					for handle in e.Handles do
					(
						local n = GetAnimByHandle handle;
						if (isValidNode n) do
						(
							if (not refs.dependencyLoopTest targetNode n) then
								n.Parent = targetNode;
							else
							(
								messagebox ("Linking " + n.name + " to " + targetNode.name + " would create a dependency loop.") title:"Link failed";
								outliner_callbacks.nodeLinkedIntern n;
							)
						)
					)
				)
			)
			
			outliner_status.linkedInOutliner = false;
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	
	
	
	/**
	 * OBJET GROUPED
	 */
	function ObjectGrouped e =
	(
		try
		(
			outliner_status.linkedInOutliner = true;
			
			local undoString = if (e.IsGroupMember) then "Add to group" else "Remove from group";
			local targetNode = if (e.TargetHandle != -1) then (GetAnimByHandle e.TargetHandle) else undefined;
			
			undo undoString on
			(
				with redraw off
				(
					for handle in e.Handles do
					(
						local n = GetAnimByHandle handle;
						if (isValidNode n) do
						(
							if (not refs.dependencyLoopTest targetNode n) then
							(
								if (e.Linked) do
								(
									
									local parentToDelete;
									if (n.parent != undefined AND isGroupHead n.parent AND n.parent.children.count == 1) do
										parentToDelete = n.parent;
								 
									n.Parent = targetNode;
									if (parentToDelete != undefined) do
										delete parentToDelete;
								)
								setGroupMember n e.IsGroupMember;
							)
							else
							(
								messagebox ("Linking " + n.name + " to " + targetNode.name + " would create a dependency loop.") title:"Link failed";
								outliner_callbacks.nodeLinkedIntern n;
							)
						)
					)
				)
			)
				
			outliner_status.linkedInOutliner = false;
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	
	
	
	
	/**
	 * LAYER LINKED
	 */
	function LayerLinked e =
	(
		try
		(
			local targetLayer = if (e.TargetHandle != -1) then (GetAnimByHandle e.TargetHandle) else undefined;
			
			for h in e.Handles do
			(
				local layer = GetAnimByHandle h;
				if (layer != undefined) do
				(
					outliner_NestedLayers.setLayerParent layer targetLayer;
				)
			)
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	
	
	
	
	/**
	 * CONTEXT MENU
	 */
	function setContextMenuMaterialSlotNames =
	(
		try
		(
			local selMaterialHandles = outliner.tree.SelectedMaterialHandles;
			local selMat;
			if (selMaterialHandles.count > 0) do
				selMat = GetAnimByHandle selMaterialHandles[1];
	
			local contextMenus = dotnetClass "Outliner.ContextMenus";
			local enum = contextMenus.EditMaterialMenu.Items.GetEnumerator();
			
			while enum.MoveNext() do
			(
				local item = enum.Current;
				local i = item.Tag;
				
				local itemTxt = i as string;
				if (i < 10) then
					itemTxt += "   | ";
				else
					itemTxt += " | ";
				itemTxt += meditmaterials[i].name;
				item.Text = itemTxt;
				
				local deps = refs.dependents (medit.GetTopMtlSlot i) immediateOnly:false;
				local isUnusedSlot = (deps.count == 2 AND deps[1] == meditmaterials);
				if (not isUnusedSlot) then
					item.Font = dotNetObject "System.Drawing.Font" item.Font (dotNetClass "System.Drawing.FontStyle").Bold;
				else
					item.Font = dotNetObject "System.Drawing.Font" item.Font (dotNetClass "System.Drawing.FontStyle").Regular;
				
				item.Checked = (selMat == meditmaterials[i]);
			)
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	
	


	function ContextMenuOpened e =
	(
		try
		(
			local contextMenus = dotnetClass "Outliner.ContextMenus";
	
			if (outliner.maxV < 12) do
				contextMenus.AddToNewContainerItem.Visible = false;
				
			if (contextMenus.EditMaterialItem.Visible) do
				outliner_TreeEventHandlers.setContextMenuMaterialSlotNames();
				
			if (not outliner.prefs.getValue #General #workflowToolsInstalled) do
				contextMenus.AdvancedRenameItem.Visible = false;
				
			if (contextMenus.DisplayPropertiesItem.Visible OR contextMenus.RenderPropertiesItem.Visible) do
			(
				local selHandles = outliner.tree.SelectedNodeHandles;
				local selContainsLayers = false;
				local trajectory = true;
				local seeThrough = true;
				local backFaceCull = true;
				local boxMode = true;
				local showInVpt = true;
				local display;
				local layersShareDisplay = true;
				local displayByLayer = true;
			
				local renderable = true;
				local visibleToCam = true;
				local visibleToRefl = true;
				local receiveShadows = true;
				local castShadows = true;
				local renderByLayer = true;
				
				for handle in selHandles do
				(
					local n = GetAnimByHandle handle;
					if (n != undefined) do
					(
						if (isKindOf n Node) then
						(
							if (not n.displayByLayer) do displayByLayer = false;
							if (not n.renderByLayer) do renderByLayer = false;
						)
						else if (isKindOf n Base_Layer) then
						(
							selContainsLayers = true;
							if (display == undefined) do display = n.display 
							if (n.display != display) do layersShareDisplay = false;
						)
						
						if (isKindOf n Material) then
						(
							if (not n.showInViewport) do showInVpt = false;
						)
						else
						(
							if (not n.showTrajectory) do trajectory = false;
							if (not n.xray) do seeThrough = false;
							if (not n.backFaceCull) do backFaceCull = false;
							if (not n.boxMode) do boxMode = false;
							
							if (not n.renderable) do renderable = false;
							if (not n.primaryVisibility) do visibleToCam = false;
							if (not n.secondaryVisibility) do visibleToRefl = false;
							if (not n.receiveshadows) do receiveShadows = false;
							if (not n.castshadows) do castShadows = false;
						)
					)
				)
				
				contextMenus.DisplayViewportItem.Checked	= (layersShareDisplay AND display == #viewport);
				contextMenus.DisplayBoundingBoxItem.Checked	= (layersShareDisplay AND display == #boundingbox);
				contextMenus.DisplayWireframeItem.Checked	= (layersShareDisplay AND display == #wireframe);
				contextMenus.DisplayShadedItem.Checked		= (layersShareDisplay AND display == #shaded);
				contextMenus.DisplayShowInVptItem.Checked	= showInVpt;
				contextMenus.DisplaySeeThroughItem.Checked	= seeThrough;
				contextMenus.DisplayBackfaceCullItem.Checked= backFaceCull;
				contextMenus.DisplayBoxModeItem.Checked		= boxMode;
				contextMenus.DisplayTrajectoryItem.Checked	= trajectory;
				contextMenus.DisplayByLayerItem.Checked 	= displayByLayer;
				
				contextMenus.DisplaySeeThroughItem.Enabled	= selContainsLayers OR not displayByLayer;
				contextMenus.DisplayBackfaceCullItem.Enabled= selContainsLayers OR not displayByLayer;
				contextMenus.DisplayBoxModeItem.Enabled		= selContainsLayers OR not displayByLayer;
				contextMenus.DisplayTrajectoryItem.Enabled	= selContainsLayers OR not displayByLayer;
				
				contextMenus.RenderableItem.Checked			= renderable;
				contextMenus.VisibleToCamItem.Checked		= visibleToCam;
				contextMenus.VisibleToReflItem.Checked		= visibleToRefl;
				contextMenus.ReceiveShadowsItem.Checked		= receiveShadows;
				contextMenus.CastShadowsItem.Checked		= castShadows;
				contextMenus.RenderByLayerItem.Checked		= renderByLayer;
				
				contextMenus.RenderableItem.Enabled			= selContainsLayers OR not renderByLayer;
				contextMenus.VisibleToCamItem.Enabled		= selContainsLayers OR not renderByLayer;
				contextMenus.VisibleToReflItem.Enabled		= selContainsLayers OR not renderByLayer;
				contextMenus.ReceiveShadowsItem.Enabled		= selContainsLayers OR not renderByLayer;
				contextMenus.CastShadowsItem.Enabled		= selContainsLayers OR not renderByLayer;
			)
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	
	function ContextMenuItemClicked e =
	(
		try
		(
			--Note: some click events are handled in the tree itself!
			local contextMenus = dotnetClass "Outliner.ContextMenus";
			local clickedItem = e.ClickedItem;
			
			if (e.Menu == contextMenus.MainMenu) then
			(
				--Set active layer.
				if (clickedItem == contextMenus.SetActiveLayerItem) then 
					outliner.setActiveLayerSelected();
				--Create new layer.
				else if (clickedItem == contextMenus.CreateNewLayerItem) then
				(
					local layer = (LayerManager.NewLayer()).layerAsRefTarg;
					if (outliner.prefs.getValue #Tree #editNewLayerName) do
						outliner.tree.EditNodeName (GetHandleByAnim layer);
				)
				--Advanced rename.
				else if (clickedItem == contextMenus.AdvancedRenameItem) then
					macros.run "Outliner Workflow Tools" "advancedRename";
				--Delete selection.
				else if (clickedItem == contextMenus.DeleteItem) then 
					outliner.deleteSelection();
					
				
				--Hide selection.
				else if (clickedItem == contextMenus.HideItem) then 
					outliner.hideSelection true;
				--Unhide selection.
				else if (clickedItem == contextMenus.UnhideItem) then 
					outliner.hideSelection false;
				--Freeze selection.
				else if (clickedItem == contextMenus.FreezeItem) then 
					outliner.freezeSelection true;
				--Unfreeze selection.
				else if (clickedItem == contextMenus.UnfreezeItem) then 
					outliner.freezeSelection false;
					
				--Unlink selection.
				else if (clickedItem == contextMenus.UnlinkItem) then 
					outliner.unlinkSelection();
				--Ungroup selection.
				else if (clickedItem == contextMenus.UngroupItem) then
					try ( ungroup $; ) catch ( print (getCurrentException()); )
				
				--Layer properties.
				else if (clickedItem == contextMenus.LayerPropertiesItem) then
				(
					local layers = #();
					for lHandle in outliner.tree.SelectedLayerHandles do
					(
						local layer = GetAnimByHandle lHandle;
						if (layer != undefined) do
						(
							append layers layer;
							join layers (outliner_NestedLayers.getAllChildLayers layer);
						)
					)
					outliner.UI.openLayerProperties layers;
				)
				--Object properties.
				else if (clickedItem == contextMenus.ObjectPropertiesItem) then
					max properties;
			)
			
			
			else if (e.Menu == contextMenus.EditMaterialMenu) then
			(
				if (clickedItem != undefined AND clickedItem.Tag != undefined) do
				(
					local selMaterialHandles = outliner.tree.SelectedMaterialHandles;
					if (selMaterialHandles.count > 0) do
					(
						local mat = GetAnimByHandle selMaterialHandles[1];
						if (mat != undefined) do
						(
							medit.PutMtlToMtlEditor mat e.ClickedItem.Tag;
							medit.SetActiveMtlSlot e.ClickedItem.Tag false;
							MatEditor.Open();
						)
					)
				)
			)
			
			
			else if (e.Menu == contextMenus.AddSelectionToMenu) then
			(
				--Add selection to new container.
				if (clickedItem == contextMenus.AddToNewContainerItem) then
					outliner.addSelectionToNewContainer();
				--Add selection to new group.
				else if (clickedItem == contextMenus.AddToNewGroupItem) then
					outliner.addSelectionToNewGroup();
				--Add selection to new layer.
				else if (clickedItem == contextMenus.AddToNewLayerItem) then
					outliner.addSelectionToNewLayer();
				--Add to existing layer.
				else if (clickedItem != undefined AND clickedItem.Name == "addSelToExistingLayer" AND clickedItem.Tag != undefined) then
					outliner.moveSelectionToLayer (GetAnimByHandle clickedItem.Tag);
			)
			
			
			else if (e.Menu == contextMenus.DisplayPropertiesMenu) then
			(
				--Display Layer #viewport.
				if (clickedItem == contextMenus.DisplayViewportItem) then 
					outliner.setPropertyOnSelection #display #viewport includeLayers:true;
				--Display Layer #boundingbox.
				else if (clickedItem == contextMenus.DisplayBoundingBoxItem) then 
					outliner.setPropertyOnSelection #display #boundingbox includeLayers:true;
				--Display Layer #wireframe.
				else if (clickedItem == contextMenus.DisplayWireframeItem) then
					outliner.setPropertyOnSelection #display #wireframe includeLayers:true;
				--Display Layer #shaded.
				else if (clickedItem == contextMenus.DisplayShadedItem) then 
					outliner.setPropertyOnSelection #display #shaded includeLayers:true;
					
				--Show material in viewport.
				else if (clickedItem == contextMenus.DisplayShowInVptItem) then
					outliner.setPropertyOnSelection #showInViewport (not clickedItem.Checked) includeMaterials:true;
				--Display SeeThrough
				else if (clickedItem == contextMenus.DisplaySeeThroughItem) then 
					outliner.setPropertyOnSelection #xray (not clickedItem.Checked) includeObjects:true includeLayers:true;
				--Display Backface Cull
				else if (clickedItem == contextMenus.DisplayBackfaceCullItem) then
					outliner.setPropertyOnSelection #backFaceCull (not clickedItem.Checked) includeObjects:true includeLayers:true;
				--Display Backface Cull
				else if (clickedItem == contextMenus.DisplayBoxModeItem) then
					outliner.setPropertyOnSelection #boxmode (not clickedItem.Checked) includeObjects:true includeLayers:true;
				--Display Trajectory
				else if (clickedItem == contextMenus.DisplayTrajectoryItem) then 
					outliner.setPropertyOnSelection #showTrajectory (not clickedItem.Checked) includeObjects:true includeLayers:true;
					
				--Set Display by layer
				else if (clickedItem == contextMenus.DisplayByLayerItem) then
					outliner.setPropertyOnSelection #displayByLayer (not clickedItem.Checked) includeObjects:true;
				else if (clickedItem == contextMenus.DisplayByLayerAllItem) then
					outliner.setPropertyOnAllSelectedLayerObjects #displayByLayer true;
			)
			
			
			else if (e.Menu == contextMenus.RenderPropertiesMenu) then
			(
				--Renderable
				if (clickedItem == contextMenus.RenderableItem) then
					outliner.setPropertyOnSelection #renderable (not clickedItem.Checked) includeObjects:true includeLayers:true;
				--Visible To Camera.
				else if (clickedItem == contextMenus.VisibleToCamItem) then
					outliner.setPropertyOnSelection #primaryVisibility (not clickedItem.Checked) includeObjects:true includeLayers:true;
				--Visible To Reflection.
				else if (clickedItem == contextMenus.VisibleToReflItem) then 
					outliner.setPropertyOnSelection #secondaryVisibility (not clickedItem.Checked) includeObjects:true includeLayers:true;
				--Receive Shadows.
				else if (clickedItem == contextMenus.ReceiveShadowsItem) then 
					outliner.setPropertyOnSelection #receiveshadows (not clickedItem.Checked) includeObjects:true includeLayers:true;
				--Cast Shadows.
				else if (clickedItem == contextMenus.CastShadowsItem) then 
					outliner.setPropertyOnSelection #castshadows (not clickedItem.Checked) includeObjects:true includeLayers:true;
					
				--Set Render by layer
				else if (clickedItem == contextMenus.RenderByLayerItem) then
					outliner.setPropertyOnSelection #renderByLayer (not clickedItem.Checked) includeObjects:true;
				else if (clickedItem == contextMenus.RenderByLayerAllItem) then
					outliner.setPropertyOnAllSelectedLayerObjects #renderByLayer true;
			)
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	)

)