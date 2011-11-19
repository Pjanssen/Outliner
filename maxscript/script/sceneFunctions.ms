struct OutlinerSceneFunctions
(

private ctrlrRequiresDataFn,
private ctrlrAddObjectFn,
private ctrlrAddLayerFn,
private ctrlrAddMaterialFn,
private ctrlrAddSelectionSetFn,
private objectRootHandle,
private layerRootHandle,
private materialRootHandle,
private matUnassignedHandle,
private sceneDataTypeEnum,

private function createFunctionCache ctrlr =
(
	ctrlrRequiresDataFn		= ctrlr.RequiresData;
	ctrlrAddObjectFn		= ctrlr.AddObject;
	ctrlrAddLayerFn			= ctrlr.AddLayer;
	ctrlrAddMaterialFn		= ctrlr.AddMaterial;
	ctrlrAddSelectionSetFn	= ctrlr.AddSelectionSet;
	objectRootHandle		= (dotNetClass "Outliner.Scene.OutlinerScene").ObjectRootHandle;
	layerRootHandle			= (dotNetClass "Outliner.Scene.OutlinerScene").LayerRootHandle;
	materialRootHandle		= (dotNetClass "Outliner.Scene.OutlinerScene").MaterialRootHandle;
	matUnassignedHandle		= (dotNetClass "Outliner.Scene.OutlinerScene").MaterialUnassignedHandle;
	sceneDataTypeEnum		= dotNetClass "Outliner.SceneDataType";
),

public function disposeFunctionCache =
(
	ctrlrRequiresDataFn		= undefined;
	ctrlrAddObjectFn		= undefined;
	ctrlrAddLayerFn 		= undefined;
	ctrlrAddMaterialFn		= undefined;
	ctrlrAddSelectionSetFn	= undefined;
	objectRootHandle		= undefined;
	layerRootHandle			= undefined;
	materialRootHandle		= undefined;
	matUnassignedHandle		= undefined;
	sceneDataTypeEnum		= undefined;
),


public function addObjectToTreeController o layerHandle: =
(
	try
	(
		if (isValidNode o) do
		(
			if (layerHandle == unsupplied) do
				layerHandle = GetHandleByAnim o.layer.layerAsRefTarg;
                               
			ctrlrAddObjectFn (GetHandleByAnim o) \
								  (if (o.parent != undefined) then (GetHandleByAnim o.parent) else objectRootHandle) \
								  o.name \
								  layerHandle \
								  (if (o.material != undefined) then (GetHandleByAnim o.material) else matUnassignedHandle) \
								  (getClassName o) ((superclassof o) as string) \
								  (isGroupHead o) (isGroupMember o) \
								  o.isNodeHidden o.isNodeFrozen o.boxMode;
								  
			/*
			 * Code to get object instance handles
			local instances;
			local instanceHandles = #();
			if ((instanceMgr.getInstances o &instances) > 1) do
			(
				for i in instances where i != o do
					append instanceHandles (getHandleByAnim i);
			)
			*/
		)
	)
	catch 
	(
		fileIn "crash_report.ms";
		outliner_crash_report.handle_exception();
	)
),




public function addLayerToTreeController layer layerHandle: = 
(
	try
	(
		if (layerHandle == unsupplied) do
			layerHandle = GetHandleByAnim layer.layerAsRefTarg;
		
		local parentLayer = outliner_NestedLayers.getLayerParent layer;

		ctrlrAddLayerFn layerHandle \
							 (if (parentLayer != undefined) then (GetHandleByAnim parentLayer) else layerRootHandle) \
							 layer.name \
							 layer.current \
							 (outliner_NestedLayers.getLayerProperty layer #isHidden) \
							 (outliner_NestedLayers.getLayerProperty layer #isFrozen) \
							 layer.boxMode;
	)
	catch 
	(
		fileIn "crash_report.ms";
		outliner_crash_report.handle_exception();
	)
),




public function addMaterialToTreeController mat parentHandle =
(
	try
	(
		ctrlrAddMaterialFn (GetHandleByAnim mat) \
								parentHandle \
								mat.name \
								(getClassName mat);
		
		if ((superClassof mat) == material) do
		(
			for m = 1 to (getNumSubMtls mat) do 
				addMaterialToTreectrlr (getSubMtl mat m) (GetHandleByAnim mat);
		)
				
		for m = 1 to (getNumSubTexmaps mat) do
		(
			if ((getSubTexMap mat m) != undefined) do
				addMaterialToTreectrlr (getSubTexmap mat m) (GetHandleByAnim mat);
		)
	)
	catch 
	(
		fileIn "crash_report.ms";
		outliner_crash_report.handle_exception();
	)
),


/**
 * Pushes a selection set to the tree controller.
 */
public function addSelectionSetToTreeController selSet =
(
	try
	(
		ctrlrAddSelectionSetFn selSet.name \
							   (for obj in selSet collect (GetHandleByAnim obj));
	)
	catch
	(
		fileIn "crash_report.ms";
		outliner_crash_report.handle_exception();
	)
),


/**
 * Pushes the scene to the TreeController.
 */
public function pushSceneToTreeController ctrlr =
(
--	try
--	(
		createFunctionCache ctrlr;
		
		ctrlr.BeginScenePush();

		--Add layers to tree.
		if ((ctrlrRequiresDataFn sceneDataTypeEnum.Objects) OR (ctrlrRequiresDataFn sceneDataTypeEnum.Layers)) do
		(
			local layerCount = LayerManager.count - 1;
			for i = 0 to layerCount do
			(
				local layer = LayerManager.getLayer i;
				local layerHandle = GetHandleByAnim layer.layerAsRefTarg;
				
				addLayerToTreeController layer layerHandle:layerHandle;
				
				--Add all objects on this layer
				local nodes;
				layer.nodes &nodes;
				for n in nodes do
					addObjectToTreeController n layerHandle:layerHandle;
			)
		)
		
		--Add materials.
		if (ctrlrRequiresDataFn sceneDataTypeEnum.Materials) do
		(
			for mat in scenematerials do
				addMaterialToTreeController mat materialRootHandle;
		)
		
		--Add selection sets.
		if (ctrlrRequiresDataFn sceneDataTypeEnum.SelectionSets) do
		(
			for selSet in selectionSets do
				addSelectionSetToTreeController selSet;
		)
			
		
		ctrlr.EndScenePush();
--	)
--	catch
--	(
--		fileIn "crash_report.ms";
--		outliner_crash_report.handle_exception();
--	)
)

)