struct outliner_TreeEventHandlers
(
/**
 * SELECTION CHANGED
 */
function SelectionChanged e =
(
   try 
   (
      --Signal the outliner to ignore events fired by this method.
      append outliner_status.ignoreEvents #selectionChanged;
      
      local listMode = outliner.prefs.getValue #Tree #listMode;
      
      undo "Select" on
      (
         with redraw off 
         (
            local selNodes = for n in outliner.tree.SelectedObjectHandles \
                                   where (isValidNode (obj = (GetAnimByHandle n))) \
                                   collect obj;
            
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
               for l in e.SelectedLayerHandles do 
               (
                  local layer = GetAnimByHandle l;
                  if (layer != undefined) do
                     layer.select true;
               )
            )
            
            -- Select materials.
            else if (listMode == "Material" AND (MatEditor.isOpen())) then
            (
               local matFound = false;
               for m in e.SelectedMaterialHandles while (not matFound) do
               (
                  local mat = GetAnimByHandle m;
                  if (mat != undefined AND ((superclassof m) == material)) do
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
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),




/**
 * NODE HIDDEN
 */
function NodeHidden e =
(
   try
   (
      --Signal the outliner to ignore events fired by this method.
      append outliner_status.ignoreEvents #displayPropertiesChanged;
      
      local undoString = if (e.NewValue) then "Hide" else "Unhide";
      
      undo undoString on
      (
         with redraw off
         (     
            for handle in e.Handles do
            (
               local n = GetAnimByHandle handle;
               if (n != undefined AND not isDeleted n) do
               (
                  if (isValidNode n) then
                     n.isNodeHidden = e.newValue;
                  else if (isKindOf n Base_Layer) then
                     outlinerNestedLayers.setLayerProperty n #isHidden e.newValue;
               )
            )
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),



/**
 * NODE FROZEN
 */
function NodeFrozen e =
(
   try
   (
      --Signal the outliner to ignore events fired by this method.
      append outliner_status.ignoreEvents #displayPropertiesChanged;
      
      local undoString = if (e.NewValue) then "Freeze" else "Unfreeze";
      
      undo undoString on
      (
         with redraw off
         (     
            for handle in e.Handles do
            (
               local n = GetAnimByHandle handle;
               if (n != undefined AND not isDeleted n) do
               (
                  if (isValidNode n) then
                     n.isNodeFrozen = e.newValue;
                  else if (isKindOf n Base_Layer) then
                     outlinerNestedLayers.setLayerProperty n #isFrozen e.newValue;
               )
            )
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),




/**
 * NODE BOXMODE CHANGED.
 */
function NodeBoxModeChanged e =
(
   try
   (
      --Signal the outliner to ignore events fired by this method.
      append outliner_status.ignoreEvents #displayPropertiesChanged;
      
      with redraw off
      (     
         for handle in e.Handles do
         (
            local n = GetAnimByHandle handle;
            if (n != undefined AND not isDeleted n) do
            (
               if (isValidNode n) then
                  n.boxMode = e.newValue;
               else if (isKindOf n Base_Layer) then
                  outlinerNestedLayers.setLayerProperty n #boxMode e.newValue;
            )
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),





/**
 * NODE RENAMED
 */
function NodeRenamed e =
(
   try
   (
      --Signal the outliner to ignore events fired by this method.
      append outliner_status.ignoreEvents #nameChanged;
      
      local n = (GetAnimByHandle e.Handle);
      
      if (n != undefined AND not isDeleted n) do
      (
         -- Rename node.
         if (isValidNode n OR isKindOf n Material) then
         (
            n.name = e.Name;
         )
         
         -- Rename layer.
         else if (isKindOf n Base_Layer) then
         (
            n.setName e.Name;
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
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
         local undoStr = if (mat != undefined) then "Assign material" \
                                               else "Remove material";
         
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
      fileIn "crash_report.ms";
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
      fileIn "crash_report.ms";
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
      fileIn "crash_report.ms";
   )
),



/**
 * OBJECT LAYER CHANGED
 */
function ObjectLayerChanged e =
(
   try
   (
      --Signal the outliner to ignore events fired by this method.
      append outliner_status.ignoreEvents #layerChanged;
      
      local targetLayer = (GetAnimByHandle e.TargetHandle);
      if (targetLayer != undefined) do
      (
         undo "Change Layers" on 
         (
            with redraw off
            (
               for h in e.Handles do
               (
                  local n = GetAnimByHandle h;
                  if (isValidNode n) do 
                  (
                     targetLayer.addNode n;
                     
                     --Also move dependencies in case of a PFSource
                     if ((classof n) == PF_Source) do
                     (
                        local depNodes = refs.dependentNodes n;
                        for d in depNodes do
                           targetLayer.addNode d;
                     )
                  )
               )
            )
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),




/**
 * NODE LINKED
 */
function ObjectLinked e =
(
   try
   (
      --Signal the outliner to ignore events fired by this method.
      append outliner_status.ignoreEvents #linkChanged;
      
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
            for h in e.Handles where isValidNode (n = GetAnimByHandle h) do
            (
               if (targetNode == undefined) then
                  n.parent = undefined;
               else
               (
                  if (not refs.dependencyLoopTest targetNode n) then
                     n.parent = targetNode;
                  else
                  (
                     messagebox ("Linking " + n.name + \
                                 " to " + targetNode.name + \
                                 " would create a dependency loop.") \
                                 title:"Link failed";
                                 
                     --Undo link operation in Outliner.
                     outliner_callbacks.nodeLinkedIntern n;
                  )
               )
            )
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),




/**
 * OBJET GROUPED
 */
function ObjectGrouped e =
(
   try
   (
      --Signal the outliner to ignore events fired by this method.
      append outliner_status.ignoreEvents #linkChanged;
      append outliner_status.ignoreEvents #groupChanged;
      
      local undoString = if (e.IsGroupMember) then "Add to group" \
                                              else "Remove from group";
      local targetNode = if (e.TargetHandle != -1) then (GetAnimByHandle e.TargetHandle) \
                                                   else undefined;
      
      undo undoString on
      (
         with redraw off
         (
            for h in e.Handles where isValidNode (n = GetAnimByHandle h) do
            (
               if (e.Linked) do
               (
                  if (targetNode == undefined) then
                  (
                     --Link object.
                     local parent = n.parent;
                     n.parent = undefined;
                   
                     --Delete group head if necessary.
                     if (parent != undefined AND isGroupHead parent AND \
                                                 parent.children.count == 0) do
                        delete parent;
                  )
                  else
                  (
                     if (not refs.dependencyLoopTest targetNode n) then
                     (
                        --Link object.
                        local parent = n.parent;
                        n.parent = targetNode;
                   
                        --Delete group head if necessary.
                        if (parent != undefined AND isGroupHead parent AND \
                                                 parent.children.count == 0) do
                           delete parent;
                     )
                     else
                     (
                        messagebox ("Linking " + n.name + \
                                    " to " + targetNode.name + \
                                    " would create a dependency loop.") \
                                    title:"Link failed";
                                    
                        --Undo link operation in Outliner.
                        outliner_callbacks.nodeLinkedIntern n;
                     )
                  )
               )
               
               setGroupMember n e.IsGroupMember;
            )
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),





/**
 * LAYER LINKED
 */
function LayerLinked e =
(
   try
   (
      local targetHandle = e.TargetHandle;
      local layerHandles = e.Handles;
      local targetLayer = if (targetHandle != -1) then (GetAnimByHandle targetHandle) \
                                                  else undefined;

      for h in layerHandles do
      (
         local layer = GetAnimByHandle h;
         if (layer != undefined) do
            outlinerNestedLayers.setParent layer targetLayer;
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),



/**
 * LAYER ACTIVE CHANGED
 */
function LayerActiveChanged e =
(
   try
   (
      if (e.Handles.count == 1 AND e.newValue) do
      (
         local newCurrentLayerHandle = e.Handles[1];
         local oldCurrentLayerHandle = getHandleByAnim LayerManager.current.layerAsRefTarg;
         local layer = GetAnimByHandle e.Handles[1];
         if (layer != undefined AND newCurrentLayerHandle != currentLayerHandle) do
         (
            outliner.tree.SetLayerActive oldCurrentLayerHandle false;
            outliner.tree.SetLayerActive newCurrentLayerHandle true;
            layer.current = true;
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
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

      local menus = dotnetClass "Outliner.ContextMenus";
      local enum = menus.EditMaterialMenu.Items.GetEnumerator();
      
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
         (
            item.Font = dotNetObject "System.Drawing.Font" \
                                     item.Font \
                                     (dotNetClass "System.Drawing.FontStyle").Bold;
         )
         else
         (
            item.Font = dotNetObject "System.Drawing.Font" \
                                     item.Font \
                                     (dotNetClass "System.Drawing.FontStyle").Regular;
         )
         
         item.Checked = (selMat == meditmaterials[i]);
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),





function ContextMenuOpened e =
(
   try
   (
      local menus = dotnetClass "Outliner.ContextMenus";

      if (outliner.maxV < 12) do
         menus.AddToNewContainerItem.Visible = false;
         
      if (menus.EditMaterialItem.Visible) do
         outliner_TreeEventHandlers.setContextMenuMaterialSlotNames();
         
      if (not outliner.product_info.getValue #General #workflowToolsInstalled) do
         menus.AdvancedRenameItem.Visible = false;
         
      if (menus.DisplayPropertiesItem.Visible \
          OR menus.RenderPropertiesItem.Visible) do
      (
         local selHandles = outliner.tree.SelectedNodeHandles;
         local selContainsLayers = false;
         local trajectory = true;
         local frozenInGray = true;
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
            if (n != undefined AND not isDeleted n) do
            (
               if (isValidNode n) then
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
                  if ((isProperty n #showInViewport) AND not n.showInViewport) do 
                     showInVpt = false;
               )
               else
               (
                  if (not n.showTrajectory) do trajectory = false;
                  if (not n.showFrozenInGray) do frozenInGray = false;
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
         
         menus.DisplayViewportItem.Checked     = (layersShareDisplay AND display == #viewport);
         menus.DisplayBoundingBoxItem.Checked  = (layersShareDisplay AND display == #boundingbox);
         menus.DisplayWireframeItem.Checked    = (layersShareDisplay AND display == #wireframe);
         menus.DisplayShadedItem.Checked       = (layersShareDisplay AND display == #shaded);
         menus.DisplayShowInVptItem.Checked    = showInVpt;
         menus.DisplaySeeThroughItem.Checked   = seeThrough;
         menus.DisplayBackfaceCullItem.Checked = backFaceCull;
         menus.DisplayBoxModeItem.Checked      = boxMode;
         menus.DisplayTrajectoryItem.Checked   = trajectory;
         menus.DisplayFrozenInGrayItem.Checked = frozenInGray;
         menus.DisplayByLayerItem.Checked      = displayByLayer;
         
         menus.DisplaySeeThroughItem.Enabled   = \
         menus.DisplayBackfaceCullItem.Enabled = \
         menus.DisplayBoxModeItem.Enabled      = \
         menus.DisplayTrajectoryItem.Enabled   = \
         menus.DisplayFrozenInGrayItem.Enabled = selContainsLayers OR not displayByLayer;
         
         menus.RenderableItem.Checked     = renderable;
         menus.VisibleToCamItem.Checked   = visibleToCam;
         menus.VisibleToReflItem.Checked  = visibleToRefl;
         menus.ReceiveShadowsItem.Checked = receiveShadows;
         menus.CastShadowsItem.Checked    = castShadows;
         menus.RenderByLayerItem.Checked  = renderByLayer;
         
         menus.RenderableItem.Enabled     = \
         menus.VisibleToCamItem.Enabled   = \
         menus.VisibleToReflItem.Enabled  = \
         menus.ReceiveShadowsItem.Enabled = \
         menus.CastShadowsItem.Enabled    = selContainsLayers OR not renderByLayer;
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),


function ContextMenuItemClicked e =
(
   try
   (
      --Note: some click events are handled in the tree itself!
      local menus = dotnetClass "Outliner.ContextMenus";
      local clickedItem = e.ClickedItem;
      
      if (e.Menu == menus.MainMenu) then
      (
         --Set active layer.
         if (clickedItem == menus.SetActiveLayerItem) then 
            outliner.setActiveLayerSelected();
         --Create new layer.
         else if (clickedItem == menus.CreateNewLayerItem) then
         (
            local parentLayer = undefined;
            if (menus.ClickedNode != undefined) do
            (
               local n = getAnimByHandle menus.ClickedNode.Handle;
               if (isKindOf n Base_Layer) then
                  parentLayer = n;
               else if (isValidNode n) then
                  parentLayer = n.layer;
            )
            outliner.createNewLayer parentLayer;
         )
         --Advanced rename.
         else if (clickedItem == menus.AdvancedRenameItem) then
            macros.run "Outliner Workflow Tools" "advancedRename";
         --Delete selection.
         else if (clickedItem == menus.DeleteItem) then 
            outliner.deleteSelection();
            
         
         --Hide selection.
         else if (clickedItem == menus.HideItem) then 
            outliner.hideSelection true;
         --Unhide selection.
         else if (clickedItem == menus.UnhideItem) then 
            outliner.hideSelection false;
         --Freeze selection.
         else if (clickedItem == menus.FreezeItem) then 
            outliner.freezeSelection true;
         --Unfreeze selection.
         else if (clickedItem == menus.UnfreezeItem) then 
            outliner.freezeSelection false;
            
         --Unlink selection.
         else if (clickedItem == menus.UnlinkItem) then 
            outliner.unlinkSelection();
         --Ungroup selection.
         else if (clickedItem == menus.UngroupItem) then
            try ( ungroup $; ) catch ( print (getCurrentException()); )
         
         --Layer properties.
         else if (clickedItem == menus.LayerPropertiesItem) then
         (
            local layers = #();
            for lHandle in outliner.tree.SelectedLayerHandles do
            (
               local layer = GetAnimByHandle lHandle;
               if (layer != undefined) do
               (
                  append layers layer;
                  join layers (outlinerNestedLayers.getChildren layer recursive:true);
               )
            )
            outliner.UI.openLayerProperties layers;
         )
         --Object properties.
         else if (clickedItem == menus.ObjectPropertiesItem) then
            max properties;
      )
      
      
      else if (e.Menu == menus.EditMaterialMenu) then
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
      
      
      else if (e.Menu == menus.AddSelectionToMenu) then
      (
         --Add selection to new container.
         if (clickedItem == menus.AddToNewContainerItem) then
            outliner.addSelectionToNewContainer();
         --Add selection to new group.
         else if (clickedItem == menus.AddToNewGroupItem) then
            outliner.addSelectionToNewGroup();
         --Add selection to new layer.
         else if (clickedItem == menus.AddToNewLayerItem) then
            outliner.addSelectionToNewLayer();
         --Add to existing layer.
         else if (clickedItem != undefined \
                  AND clickedItem.Name == "addSelToExistingLayer" \
                  AND clickedItem.Tag != undefined) then
            outliner.moveSelectionToLayer (GetAnimByHandle clickedItem.Tag);
      )
      
      
      else if (e.Menu == menus.DisplayPropertiesMenu) then
      (
         --Display Layer #viewport.
         if (clickedItem == menus.DisplayViewportItem) then 
            outliner.setPropertyOnSelection #display #viewport includeLayers:true;
         --Display Layer #boundingbox.
         else if (clickedItem == menus.DisplayBoundingBoxItem) then 
            outliner.setPropertyOnSelection #display #boundingbox includeLayers:true;
         --Display Layer #wireframe.
         else if (clickedItem == menus.DisplayWireframeItem) then
            outliner.setPropertyOnSelection #display #wireframe includeLayers:true;
         --Display Layer #shaded.
         else if (clickedItem == menus.DisplayShadedItem) then 
            outliner.setPropertyOnSelection #display #shaded includeLayers:true;
            
         --Show material in viewport.
         else if (clickedItem == menus.DisplayShowInVptItem) then
            outliner.setPropertyOnSelection #showInViewport \
                                            (not clickedItem.Checked) \
                                            includeMaterials:true;
         --Display SeeThrough
         else if (clickedItem == menus.DisplaySeeThroughItem) then 
            outliner.setPropertyOnSelection #xray \
                                            (not clickedItem.Checked) \
                                            includeObjects:true \
                                            includeLayers:true;
         --Display Backface Cull
         else if (clickedItem == menus.DisplayBackfaceCullItem) then
            outliner.setPropertyOnSelection #backFaceCull \
                                            (not clickedItem.Checked) \
                                            includeObjects:true \
                                            includeLayers:true;
         --Display Box Mode
         else if (clickedItem == menus.DisplayBoxModeItem) then
            outliner.setPropertyOnSelection #boxmode \
                                            (not clickedItem.Checked) \
                                            includeObjects:true \
                                            includeLayers:true;
         --Display Trajectory
         else if (clickedItem == menus.DisplayTrajectoryItem) then 
            outliner.setPropertyOnSelection #showTrajectory \
                                            (not clickedItem.Checked) \
                                            includeObjects:true \
                                            includeLayers:true;
                                            
         --Display Frozen in Gray
         else if (clickedItem == menus.DisplayFrozenInGrayItem) then 
            outliner.setPropertyOnSelection #showFrozenInGray \
                                            (not clickedItem.Checked) \
                                            includeObjects:true \
                                            includeLayers:true;
            
         --Set Display by layer
         else if (clickedItem == menus.DisplayByLayerItem) then
            outliner.setPropertyOnSelection #displayByLayer \
                                            (not clickedItem.Checked) \
                                            includeObjects:true;
         else if (clickedItem == menus.DisplayByLayerAllItem) then
            outliner.setPropertyOnAllSelectedLayerObjects #displayByLayer true;
      )
      
      
      else if (e.Menu == menus.RenderPropertiesMenu) then
      (
         --Renderable
         if (clickedItem == menus.RenderableItem) then
            outliner.setPropertyOnSelection #renderable \
                                            (not clickedItem.Checked) \
                                            includeObjects:true \
                                            includeLayers:true;
         --Visible To Camera.
         else if (clickedItem == menus.VisibleToCamItem) then
            outliner.setPropertyOnSelection #primaryVisibility \
                                            (not clickedItem.Checked) \
                                            includeObjects:true \
                                            includeLayers:true;
         --Visible To Reflection.
         else if (clickedItem == menus.VisibleToReflItem) then 
            outliner.setPropertyOnSelection #secondaryVisibility \
                                            (not clickedItem.Checked) \
                                            includeObjects:true \
                                            includeLayers:true;
         --Receive Shadows.
         else if (clickedItem == menus.ReceiveShadowsItem) then 
            outliner.setPropertyOnSelection #receiveshadows \
                                            (not clickedItem.Checked) \
                                            includeObjects:true \
                                            includeLayers:true;
         --Cast Shadows.
         else if (clickedItem == menus.CastShadowsItem) then 
            outliner.setPropertyOnSelection #castshadows \
                                            (not clickedItem.Checked) \
                                            includeObjects:true \
                                            includeLayers:true;
            
         --Set Render by layer
         else if (clickedItem == menus.RenderByLayerItem) then
            outliner.setPropertyOnSelection #renderByLayer \
                                            (not clickedItem.Checked) \
                                            includeObjects:true;
         else if (clickedItem == menus.RenderByLayerAllItem) then
            outliner.setPropertyOnAllSelectedLayerObjects #renderByLayer true;
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
)

)--End struct.