global outliner_callbacks;

struct outlinerCallbacks (
callbacksEnum = #(
   (Pair key:#nodePreDelete       value:"outliner_callbacks.nodePreDelete()"),
   (Pair key:#nodePostDelete      value:"outliner_callbacks.nodePostDelete()"),
   (Pair key:#nodePostMaterial    value:"outliner_callbacks.nodePostMaterial()"),
   (Pair key:#layerCreated        value:"outliner_callbacks.layerCreated()"),
   (Pair key:#layerDeleted        value:"outliner_callbacks.layerDeleted()"),
   (Pair key:#objectXrefPreMerge  value:"outliner_callbacks.objectXrefPreMerge()"),
   (Pair key:#objectXrefPostMerge value:"outliner_callbacks.objectXrefPostMerge()"),
   (Pair key:#filePreMerge        value:"outliner_callbacks.filePreMerge()"),
   (Pair key:#filePostMerge       value:"outliner_callbacks.filePostMerge()"),
   (Pair key:#preImport           value:"outliner_callbacks.preImport()"),
   (Pair key:#postImport          value:"outliner_callbacks.postImport()"),
   (Pair key:#filePreOpen         value:"outliner_callbacks.filePreOpen()"),
   (Pair key:#systemPostNew       value:"outliner_callbacks.systemPostNew()"),
   (Pair key:#systemPostReset     value:"outliner_callbacks.systemPostNew()"),
   (Pair key:#colorChanged        value:"outliner_callbacks.colorChanged()"),
   (Pair key:#preSystemShutdown   value:"try ( outliner_callbacks.preSystemShutdown() ) catch ()")
),

deletingNode = undefined,
isOpening = false,
isMerging = false,
isMergingXrefs = false,



/**
 * FUNCTION CACHE
 */
outliner_addObjectToTreeFn,
outliner_addLayerToTreeFn,
outliner_addMaterialToTreeFn,

tree_beginUpdateFn,
tree_endUpdateFn,
tree_getNodeCountFn,
tree_selectObjectRangeFn,
tree_selectAllFn,
tree_addObjectToTreeFn,
tree_addLayerToTreeFn,
tree_setObjectParentFn,
tree_setObjectIsGroupMemberFn,
tree_deleteObjectFn,
tree_setObjectNameFn,
tree_setObjectHiddenFn,
tree_setObjectFrozenFn,
tree_setObjectMaterialFn,
tree_setObjectLayerFn,
tree_setObjectClassFn,
tree_SetLayerNameFn,
scene_IsValidLayerNameFn,
tree_SetLayerActiveFn,
tree_DeleteLayerFn,
tree_SetNodeDisplayPropertiesFn,
tree_containsMaterialFn,
tree_addMaterialToTreeFn,
tree_setMaterialNameFn,


--Cache tree functions to minimize lookup time.
function createFunctionCache =
(
   outliner_addLayerToTreeFn     = outliner.addLayerToTree;
   outliner_addObjectToTreeFn    = outliner.addObjectToTree;
   outliner_addMaterialToTreeFn  = outliner.addMaterialToTree;
   
   tree_beginUpdateFn            = outliner.tree.BeginUpdate;
   tree_endUpdateFn              = outliner.tree.EndUpdate;
   tree_getNodeCountFn           = outliner.tree.GetNodeCount;
   tree_selectObjectRangeFn      = outliner.tree.SelectObjectRange;
   tree_selectAllFn              = outliner.tree.SelectAll;
   tree_addObjectToTreeFn        = outliner.tree.AddObjectToTree;
   tree_addLayerToTreeFn         = outliner.tree.AddLayerToTree;
   tree_setObjectParentFn        = outliner.tree.SetObjectParent;
   tree_setObjectIsGroupMemberFn = outliner.tree.SetObjectIsGroupMember
   tree_deleteObjectFn           = outliner.tree.DeleteObject;
   tree_setObjectNameFn          = outliner.tree.SetObjectName;
   tree_setObjectHiddenFn        = outliner.tree.SetObjectHidden;
   tree_setObjectFrozenFn        = outliner.tree.SetObjectFrozen;
   tree_setObjectMaterialFn      = outliner.tree.SetObjectMaterial;
   tree_setObjectLayerFn         = outliner.tree.SetObjectLayer;
   tree_setObjectClassFn         = outliner.tree.SetObjectClass;
   tree_SetLayerNameFn           = outliner.tree.SetLayerName;
   scene_IsValidLayerNameFn      = outliner.tree.Scene.IsValidLayerName;
   tree_SetLayerActiveFn         = outliner.tree.SetLayerActive;
   tree_DeleteLayerFn            = outliner.tree.DeleteLayer;
   tree_SetNodeDisplayPropertiesFn  = outliner.tree.SetNodeDisplayProperties;
   tree_containsMaterialFn       = outliner.tree.Scene.ContainsMaterial;
   tree_addMaterialToTreeFn      = outliner.tree.AddMaterialToTree;
   tree_setMaterialNameFn        = outliner.tree.SetMaterialName;
),


function disposeFunctionCache =
(
   --Set all properties ending in "Fn" to undefined.
   for p in (getPropNames this) where (matchPattern p pattern:"*Fn") do 
      setProperty this p undefined;

   (dotnetClass "System.GC").Collect();
),




function removeLayerChangeHandlers =
(
   deleteAllChangeHandlers id:#outliner_layers;
),

function createLayerChangeHandlers =
(
   removeLayerChangeHandlers();
   when parameters (for i=0 to LayerManager.count - 1 \
                            collect (LayerManager.getLayer i).layerAsRefTarg) \
        changes id:#outliner_layers layer do 
         outliner_callbacks.layerParametersChanged layer;
),



function removeMaterialChangeHandlers =
(
   deleteAllChangeHandlers id:#outliner_materials;
),

function createMaterialChangeHandlers =
(
   removeMaterialChangeHandlers();
   when name (for m in sceneMaterials collect m) \
        changes id:#outliner_materials mat do
         outliner_callbacks.materialNameSet mat;   
),


nodeEventCB,

function createCallbacks = 
(
   createFunctionCache();
   
   for c in callbacksEnum do
   (
      callbacks.addScript c.key c.value id:#outliner;
   )
   
   createLayerChangeHandlers();
   
   
   nodeEventCB = NodeEventCallback mouseUp:true delay:10;
   nodeEventCB.callbackBegin    = (fn a e h = outliner_callbacks.callbackBegin e h);
   nodeEventCB.callbackEnd      = (fn a e h = outliner_callbacks.callbackEnd e h);
   nodeEventCB.selectionChanged = (fn a e h = outliner_callbacks.selectionChanged e h);
   nodeEventCB.added            = (fn a e h = outliner_callbacks.nodesAdded e h);
   nodeEventCB.nameChanged      = (fn a e h = outliner_callbacks.nodesNameChanged e h);
   nodeEventCB.linkChanged      = (fn a e h = outliner_callbacks.nodesLinked e h);
   nodeEventCB.groupChanged     = (fn a e h = outliner_callbacks.nodesGroupChanged e h);
   nodeEventCB.layerChanged     = (fn a e h = outliner_callbacks.nodesLayerChanged e h);
   nodeEventCB.modelStructured  = (fn a e h = outliner_callbacks.modelStructured e h);
   nodeEventCB.displayPropertiesChanged = (fn a e h = outliner_callbacks.displayPropertiesChanged e h);
),

function removeCallbacks = 
(
   nodeEventCB.enabled = false;
   nodeEventCB = undefined;
   
   callbacks.removeScripts id:#outliner;
   removeLayerChangeHandlers();
   removeMaterialChangeHandlers();
   disposeFunctionCache();

   --Garbage collection is performed in ui.closeOutliner()
),




function callbackBegin evt handles =
(
   tree_beginUpdateFn();
),

function callbackEnd evt handles =
(
   tree_endUpdateFn();
   
   if (outliner_status != undefined) do
      outliner_status.ignoreEvents = #();
),


--Returns true if the event should be processed, and false if it was caused by 
--an action performed in the Outliner.
function processEvent evt =
(
   not isMerging AND \
   not isMergingXrefs AND \
   not isOpening AND \
   outliner_status != undefined AND \
   findItem outliner_status.ignoreEvents evt == 0;
),






/*
 * SELECTION CHANGED
 */
function selectionChanged evt handles = 
(
   try
   (
      if (processEvent evt) do
      (
         -- A small shortcut to deselect all objects quickly.
         if (selection.count == 0) then
            tree_selectAllFn false;
         else
         (
            tree_beginUpdateFn();
         
            --Deselect all nodes.
            tree_selectAllFn false;
   
            --Iterate through selection, select each node.
            tree_selectObjectRangeFn (for o in selection \
                                            collect (GetHandleByAnim o)) true;
         
            tree_endUpdateFn();
         )
         
         -- Close any groups that are no longer required to be open.
         outliner.handleGroupOpeningClosing selection false;
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),
   
   
   
   





function nodesAdded evt handles =
(
   try
   (
      if (processEvent evt) do
      (
         for h in handles where isValidNode (n = GetAnimByHandle h) AND
                                classof n != undefined do
         (
            outliner_addObjectToTreeFn n;
            tree_addObjectToTreeFn h;
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),



function nodesNameChanged evt handles =
(
   try
   (
      if (processEvent evt) do
      (
         for h in handles where isValidNode (n = GetAnimByHandle h) AND 
                                classof n != undefined do
            tree_setObjectNameFn h n.name;
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),





function nodesLinked evt handles =
(
   try
   (
      if (processEvent evt) do 
      (
         --First process objects that became unlinked.
         --This avoids issues when reversing hierarchy. 
         --E.g. x.parent = y ==> y.parent = x.
         for h in handles where isValidNode (n = GetAnimByHandle h) \
                                AND n.parent == undefined do
            tree_setObjectParentFn h -1;
         
         --Then process linked objects.
         for h in handles where isValidNode (n = GetAnimByHandle h) \
                                AND n.parent != undefined do
            tree_setObjectParentFn h (GetHandleByAnim n.parent);
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),




function nodesGroupChanged evt handles =
(
   try
   (
      if (processEvent evt) do
      (
         for h in handles where isValidNode (n = GetAnimByHandle h) AND
                                classof n != undefined do
         (
            tree_setObjectIsGroupMemberFn h (isGroupMember n);
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),




function nodesLayerChanged evt handles =
(
   try
   (
      if (processEvent evt) do
      (
         for h in handles where isValidNode (n = GetAnimByHandle h) AND
                                classof n != undefined do
         (
            tree_setObjectLayerFn h (GetHandleByAnim n.layer.layerAsRefTarg);            
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),




/**
 * MODEL STRUCTURED.
 */
function modelStructured evt handles =
(
   try
   (
      --Avoid calling outliner.tree.SetObjectClass when Outliner has been 
      --closed (caused a crash before).
      if (tree_setObjectClassFn != undefined AND processEvent evt) do
      (
         for h in handles where isValidNode (n = GetAnimByHandle h) AND
                                classof n != undefined do
         (
            tree_setObjectClassFn h (getClassName n) \
                                    ((superClassOf n) as string);
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),



--The displayPropertiesChanged event is a bit of a catch-all event for -as the 
--name suggests- display properties. These include hidden, frozen and boxmode.
function displayPropertiesChanged evt handles =
(
   try
   (
      if (processEvent evt) do
      (
         for h in handles where isValidNode (n = GetAnimByHandle h) AND
                                classof n != undefined do
         (
            tree_SetNodeDisplayPropertiesFn h n.isHiddenInVpt \
                                              n.isFrozen \
                                              n.BoxMode;
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),










/*
 * NODE LINKED.
 */
function nodeLinkedIntern linkedNode =
(
   try
   (
      if (isValidNode linkedNode) do
      (
         local parentHandle = if (linkedNode.parent != undefined) \
                                 then (GetHandleByAnim linkedNode.parent) \
                                 else -1;
         tree_setObjectParentFn (GetHandleByAnim linkedNode) \
                                 parentHandle;
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),




   
/*
 * NODE PRE DELETE & POST DELETE.
 */
function nodePreDelete = 
(
   try
   (
      deletingNode = callbacks.notificationParam();
      
      if (isValidNode deletingNode) do
      (
         local deletedNodeHandle = GetHandleByAnim deletingNode;
         
         if (isGrouphead deletingNode) do 
            outliner.openGroupHeads[deletedNodeHandle] = false;
   
         tree_deleteObjectFn deletedNodeHandle;
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),

function nodePostDelete =
(
   deletingNode = undefined;
),









/**
 * NODE POST MATERIAL.
 */
function nodePostMaterial = 
(
   try
   (
      if (outliner_status.matChangedInOutliner == false AND isMerging == false) do
      (
         local n = callbacks.notificationParam();
         if (isValidNode n) do
         (
            local matHandle = if (n.material != undefined) then \
                                 (GetHandleByAnim n.material) else -1;
            tree_setObjectMaterialFn (GetHandleByAnim n) matHandle;
            if ((tree_containsMaterialFn matHandle) == false) do
            (
               outliner_addMaterialToTreeFn n.material -1;
               tree_addMaterialToTreeFn matHandle;
                  
               if (matHandle != -1) do
               (
                  when name n.material changes id:#outliner_materials mat do
                     outliner_callbacks.materialNameSet mat;
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


function materialNameSet mat =
(
   try
   (
      if ((processEvent #nameChanged) AND mat != undefined) do
      (
         tree_setMaterialNameFn (GetHandleByAnim mat) mat.name;
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),




/**
 * NODE LAYER CHANGED.
 */
function nodeLayerChangedIntern node layer =
(
   try
   (
      if (node != undefined AND layer != undefined) do
         tree_setObjectLayerFn (GetHandleByAnim node) \
                               (GetHandleByAnim layer.layerAsRefTarg);
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),





/**
 * LAYER CREATED
 */
function layerCreated = 
(
   try
   (
      if (not isMerging) do
      (
         local layer = (callbacks.notificationParam()).layerAsRefTarg;
         outliner_addLayerToTreeFn layer;
         tree_addLayerToTreeFn (GetHandleByAnim layer);
         
         when parameters layer change id:#outliner_layers layer do 
            outliner_callbacks.layerParametersChanged layer;
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),


/**
 * LAYER DELETED
 */
function layerDeletedIntern layer =
(
   try
   (
      if (layer != undefined) do
      (
         tree_DeleteLayerFn (GetHandleByAnim layer.layerAsRefTarg);
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),

function layerDeleted = 
(
   local deletedLayer = callbacks.notificationParam();
   layerDeletedIntern deletedLayer;
),


/**
 * LAYER PARAMETERS CHANGED.
 *    called from when parameters change handler when either 
 *    isHidden, isFrozen, renderable or color is changed
 */
function layerParametersChanged layer =
(
   try
   (
      if (layer != undefined AND not (isDeleted layer)) do
      (
         tree_SetNodeDisplayPropertiesFn (GetHandleByAnim layer) \
                                          layer.isHidden \
                                          layer.isFrozen \
                                          layer.boxMode;
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),












/**
 * XREF PRE & POST MERGE
 */
function postMerge =
(
   outliner.refresh();
),

function objectXrefPreMerge =
(
   isMergingXrefs = true;
),
function objectXrefPostMerge =
(
   isMergingXrefs = false;
   postMerge();
),



/**
 * FILE PRE & POST MERGE, PRE IMPORT, POST IMPORT
 */
function filePreMerge =
(
   isMerging = true;
),
function filePostMerge =
(
   isMerging = false;
   if (isMergingXrefs == false) do
      postMerge();
),

function preImport =
(
   isMerging = true;
),

function postImport =
(
   isMerging = false;
   postMerge();
),




/**
 * SYSTEM POST NEW
 */
function systemPostNew = 
(
   outliner.refresh();

   createLayerChangeHandlers();
),


/**
 * FILE PRE OPEN
 */
function filePreOpen =
(
   isOpening = true;
   outliner.tree.ClearTree();
   --Clear the outlinerscene. I suspect that garbagecollections might occur 
   --when there's a dotnetmxsvalue that has no scene representation anymore.
   outliner.tree.Scene.Clear();
   removeCallbacks();
   callbacks.addScript #filePostOpen "outliner_callbacks.filePostOpen()" id:#outliner;
),


/**
 * FILE POST OPEN
 */
function filePostOpen =
(
   isOpening = false;
   outliner_callbacks.createCallbacks();
   outliner.refresh();
),



/**
 * PRE SYSTEM SHUTDOWN
 */
function preSystemShutdown =
(
   try ( outliner.ui.closeOutliner(); ) catch ()
   try ( outliner.dispose(); ) catch ()
),



/**
 * CUSTOM COLORS CHANGED
 */
function colorChanged =
(
   -- Pass an empty string to the tree colorscheme function to 
   -- autonatically find the right one.
   outliner.setTreeColorScheme "";
   
   outliner.ui.setIconDir();
)

)--End struct.