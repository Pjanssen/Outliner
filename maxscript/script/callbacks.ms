global outliner_callbacks;

struct outlinerCallbacks (
callbacksEnum = #(
   (Pair key:#selectionSetChanged value:"outliner_callbacks.selectionChanged()"),
   (Pair key:#sceneNodeAdded      value:"outliner_callbacks.sceneNodeAdded()"),
   (Pair key:#nodeNameSet         value:"outliner_callbacks.nodeNameSet()"),
   (Pair key:#nodePreDelete       value:"outliner_callbacks.nodePreDelete()"),
   (Pair key:#nodePostDelete      value:"outliner_callbacks.nodePostDelete()"),
   (Pair key:#nodeLinked          value:"outliner_callbacks.nodeLinked()"),
   (Pair key:#nodeHide            value:"outliner_callbacks.nodeHidden()"),
   (Pair key:#nodeUnhide          value:"outliner_callbacks.nodeHidden()"),
   (Pair key:#nodeFreeze          value:"outliner_callbacks.nodeFrozen()"),
   (Pair key:#nodeUnfreeze        value:"outliner_callbacks.nodeFrozen()"),
   (Pair key:#nodePostMaterial    value:"outliner_callbacks.nodePostMaterial()"),
   (Pair key:#nodeLayerChanged    value:"outliner_callbacks.nodeLayerChanged()"),
   (Pair key:#layerCreated        value:"outliner_callbacks.layerCreated()"),
   (Pair key:#layerDeleted        value:"outliner_callbacks.layerDeleted()"),
   (Pair key:#sceneUndo           value:"outliner_callbacks.sceneUndo()"),
   (Pair key:#sceneRedo           value:"outliner_callbacks.sceneRedo()"),
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
nodeEventCallbackItem,
deletingNode = undefined,
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



function createCallbacks = 
(
   createFunctionCache();
   
   for c in callbacksEnum do
   (
      callbacks.addScript c.key c.value id:#outliner;
   )
   
   createLayerChangeHandlers();
   
   if (outliner.maxv > 10) do
   (
      local modelStrFn = (function ms_fn evt n = outliner_callbacks.modelStructured evt n;);
      --using delay:500 as a workaround to avoid issue with function not yet being declared.
      nodeEventCallbackItem = NodeEventCallback modelStructured:modelStrFn delay:500;
   )
),

function removeCallbacks = 
(
   callbacks.removeScripts id:#outliner;
   removeLayerChangeHandlers();
   removeMaterialChangeHandlers();
   nodeEventCallbackItem = undefined;
   disposeFunctionCache();
),





/*
 * SELECTION CHANGED
 */
function selectionChanged = 
(
   try
   (
      if (not outliner_status.selectedInOutliner AND not isMergingXrefs) do
      (
         -- Two small shortcuts to select none or all object quickly.
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
   



/*
 * SCENE NODE ADDED.
 */
function sceneNodeAdded = 
(
   try
   (
      if (not isMerging) do
      (
         local createdObject = callbacks.notificationParam();
         if (isValidNode createdObject) do
         (
            outliner_addObjectToTreeFn createdObject;
            tree_addObjectToTreeFn (GetHandleByAnim createdObject);
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
         local parentHandle = if (linkedNode.parent != undefined) then \
                                 (GetHandleByAnim linkedNode.parent) else -1;
         tree_setObjectParentFn (GetHandleByAnim linkedNode) \
                                 parentHandle \
                                (isGroupMember linkedNode);
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),

function nodeLinked = 
(
   if (not outliner_status.linkedInOutliner) do
   (
      local linkedNode = callbacks.notificationParam();
      if (not isMerging AND not (deletingNode == linkedNode)) do
      (
         nodeLinkedIntern linkedNode;
      )
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




/*
 * NODE RENAMED.
 */
function nodeNameSet = 
(
   try
   (
      if (not outliner_status.renamedInOutliner AND not isMerging) do
      (
         local notifParams = (callbacks.notificationParam());
         if (isValidNode notifParams[3]) do
            tree_setObjectNameFn (GetHandleByAnim notifParams[3]) notifParams[2];
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),




/*
 * NODE HIDDEN.
 */
function nodeHidden = 
(
   try
   (
      if (not outliner_status.hiddenInOutliner AND not isMerging) do
      (
         local node = callbacks.notificationParam();
         if (isValidNode node) do
         (
            tree_setObjectHiddenFn (GetHandleByAnim node) node.isHiddenInVpt;
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),



/*
 * NODE FROZEN.
 */
function nodeFrozen = 
(
   try
   (
      if (not outliner_status.frozenInOutliner AND not isMerging) do
      (
         local node = callbacks.notificationParam();
         tree_setObjectFrozenFn (GetHandleByAnim node) node.isFrozen;
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
function modelStructured evt nodes =
(
   try
   (
      --Avoid calling outliner.tree.SetObjectClass when Outliner has been 
      --closed (caused a crash before).
      if (tree_setObjectClassFn != undefined AND outliner_status != undefined \
                                             AND outliner_status.windowOpen \
                                             AND outliner != undefined) do
      (
         for n in nodes do
         (
            local obj = GetAnimByHandle n;
            if (isValidNode obj AND (classof obj) != undefined) do
               tree_setObjectClassFn n (getClassName obj) \
                                       ((superClassOf obj) as string);
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
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
      if (not outliner_status.renamedInOutliner AND mat != undefined) do
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

function nodeLayerChanged = 
(
   try
   (
      if (deletingNode == undefined \
          AND not isMerging \
          AND not outliner_status.layerChangedInOutliner) do
      (
         local params = callbacks.notificationParam();
         if (params[1] != undefined AND params[3] != undefined) do
            nodeLayerChangedIntern params[1] params[3];
      )
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
 * SCENE UNDO
 */
function sceneUndo =
(
--TODO CHECK WHY THIS IS COMMENTED OUT AND WHETHER IT CAN BE REMOVED.

/*
   try
   (
      local undoName = callbacks.notificationParam();
      
      --I haven't the faintest idea why the "group" action should be registered 
      --as "key" in the undo system, but it is max after all...
      --When undoing, the group node isn't deleted (or at least no callback 
      --is called), so we have to refresh the entire tree to get rid of it.
      if (undoName == "Key") do
      (
         outliner.pushSceneToTree();
         outliner.tree.FillTree();
         selectionChanged();
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )*/
),


/**
 * SCENE REDO
 */
function sceneRedo =
(
   try
   (
      local redoName = callbacks.notificationParam();
      
      --I haven't the faintest idea why the "group" action should be registered 
      --as "%d %s Selected" in the undo system, but it is max after all...
      --When redoing, the group node isn't recreated (or at least no callback 
      --is called), so we have to refresh the entire tree to get it back.
      if (redoName == "%d %s Selected") do
      (
         outliner.pushSceneToTree();
         outliner.tree.FillTree();
         selectionChanged();
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
   outliner.pushSceneToTree();
   outliner.tree.FillTree();
   selectionChanged();
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
   outliner.pushSceneToTree();
   outliner.tree.FillTree();

   createLayerChangeHandlers();
),


/**
 * FILE PRE OPEN
 */
function filePreOpen =
(
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
   outliner.pushSceneToTree();
   outliner.tree.FillTree();
   outliner_callbacks.createCallbacks();
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
)

)--End struct.