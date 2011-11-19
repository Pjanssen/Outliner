global outliner_callbacks;

struct outlinerCallbacks 
(

private nodeEventCB,


--Function cache.
private objectRootHandle,
private layerRootHandle,
private materialRootHandle,
private matUnassignedHandle,
private setSelectionFn,
private beginUpdateFn,
private endUpdateFn,
private addObjectFn,
private addLayerFn,
private addMaterialFn,
private setNodeParentFn,

public function createFunctionCache = 
(
	objectRootHandle	= (dotNetClass "Outliner.Scene.OutlinerScene").ObjectRootHandle;
	layerRootHandle		= (dotNetClass "Outliner.Scene.OutlinerScene").LayerRootHandle;
	materialRootHandle	= (dotNetClass "Outliner.Scene.OutlinerScene").MaterialRootHandle;
	matUnassignedHandle = (dotNetClass "Outliner.Scene.OutlinerScene").MaterialUnassignedHandle;
	setSelectionFn		= outliner.treeController.SetSelection;
	beginUpdateFn		= outliner.treeController.BeginUpdate;
	endUpdateFn			= outliner.treeController.EndUpdate;
	addObjectFn			= outliner_sceneFunctions.addObjectToTreeController;
	addLayerFn			= outliner_sceneFunctions.addLayerToTreeController;
	addMaterialFn		= outliner_sceneFunctions.addMaterialToTreeController;
	setNodeParentFn		= outliner.treeController.SetNodeParent;
),
public function disposeFunctionCache =
(
	setSelectionFn		= undefined;
	beginUpdateFn		= undefined;
	endUpdateFn			= undefined;
	addObjectFn			= undefined;
	addLayerFn			= undefined;
	addMaterialFn		= undefined;
	setNodeParentFn		= undefined;
),




public function createCallbacks =
(
	createFunctionCache();
	
	nodeEventCB = NodeEventCallback mouseUp:true delay:20;
	nodeEventCB.callbackBegin		= fn delegateFn evt nodes = ( outliner_callbacks.node_callbackBegin evt undefined; );
	nodeEventCB.callbackEnd			= fn delegateFn evt nodes = ( outliner_callbacks.node_callbackEnd evt undefined; );
	nodeEventCB.added				= fn delegateFn evt nodes = ( outliner_callbacks.node_added evt nodes; );
	nodeEventCB.linkChanged			= fn delegateFn evt nodes = ( outliner_callbacks.node_linkChanged evt nodes; );
	nodeEventCB.hideChanged			= fn delegateFn evt nodes = ( outliner_callbacks.node_hideChanged evt nodes; );
	nodeEventCB.freezeChanged		= fn delegateFn evt nodes = ( outliner_callbacks.node_freezeChanged evt nodes; );
	
	callbacks.addScript #selectionSetChanged "outliner_callbacks.selectionChanged()" id:#outliner;
),
public function removeCallbacks =
(
	callbacks.removeScripts id:#outliner;

	if (nodeEventCB != undefined) do
	(
		nodeEventCB.enabled = false;
		nodeEventCB = undefined;
	)
	
	disposeFunctionCache();

	gc();
),




public function selectionChanged =
(
	if (outliner_status != undefined AND outliner_status.lastTreeAction != #selectionChanged) do
		setSelectionFn (for o in selection collect (GetHandleByAnim o));
),


public function node_callbackBegin evt nodes =
(
	beginUpdateFn();
),
public function node_callbackEnd evt nodes =
(
	endUpdateFn();
),




public function node_added evt nodes =
(
	local n;
	for nHandle in nodes do
	(
		n = GetAnimByHandle nHandle;
		addObjectFn n;
	)
),




public function node_linkChanged evt nodes =
(
/*
	local n;
	for nHandle in nodes do
	(
		n = GetAnimByHandle nHandle;
		setNodeParentFn nHandle (if (n.parent != undefined) then (GetHandleByAnim n.parent) else objectRootHandle);
	)
	*/
),




public function node_hideChanged evt nodes =
(
	outliner.treeController.SetNodeHidden \
		(for n in nodes where ((isValidNode (obj = (GetAnimByHandle n))) AND obj.isHidden) collect n) \
		true;
		
	outliner.treeController.SetNodeHidden \
		(for n in nodes where ((isValidNode (obj = (GetAnimByHandle n))) AND not obj.isHidden) collect n) \
		false;
),

public function node_freezeChanged evt nodes =
(
	outliner.treeController.SetNodeFrozen \
		(for n in nodes where ((isValidNode (obj = (GetAnimByHandle n))) AND obj.isFrozen) collect n) \
		true;
		
	outliner.treeController.SetNodeFrozen \
		(for n in nodes where ((isValidNode (obj = (GetAnimByHandle n))) AND not obj.isFrozen) collect n) \
		false;
)

)