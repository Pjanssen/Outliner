global outliner_callbacks;

struct outlinerCallbacks (
	callbacksEnum = #(
				(Pair key:#selectionSetChanged		value:"outliner_callbacks.selectionChanged()"),
				(Pair key:#sceneNodeAdded			value:"outliner_callbacks.sceneNodeAdded()"),
				(Pair key:#nodeCreated				value:"outliner_callbacks.nodeCreated()"),
				(Pair key:#nodeNameSet				value:"outliner_callbacks.nodeNameSet()"),
				(Pair key:#nodePreDelete			value:"outliner_callbacks.nodePreDelete()"),
				(Pair key:#nodePostDelete			value:"outliner_callbacks.nodePostDelete()"),
				(Pair key:#nodeLinked				value:"outliner_callbacks.nodeLinked()"),
				(Pair key:#nodeHide					value:"outliner_callbacks.nodeHidden()"),
				(Pair key:#nodeUnhide				value:"outliner_callbacks.nodeHidden()"),
				(Pair key:#nodeFreeze				value:"outliner_callbacks.nodeFrozen()"),
				(Pair key:#nodeUnfreeze				value:"outliner_callbacks.nodeFrozen()"),
				(Pair key:#nodePostMaterial			value:"outliner_callbacks.nodePostMaterial()"),
				(Pair key:#nodeLayerChanged			value:"outliner_callbacks.nodeLayerChanged()"),
				(Pair key:#layerCreated				value:"outliner_callbacks.layerCreated()"),
				(Pair key:#layerDeleted				value:"outliner_callbacks.layerDeleted()"),
				(Pair key:#sceneUndo				value:"outliner_callbacks.sceneUndo()"),
				(Pair key:#sceneRedo				value:"outliner_callbacks.sceneRedo()"),
				(Pair key:#objectXrefPreMerge		value:"outliner_callbacks.objectXrefPreMerge()"),
				(Pair key:#objectXrefPostMerge		value:"outliner_callbacks.objectXrefPostMerge()"),
				(Pair key:#filePreMerge				value:"outliner_callbacks.filePreMerge()"),
				(Pair key:#filePostMerge			value:"outliner_callbacks.filePostMerge()"),
				(Pair key:#preImport				value:"outliner_callbacks.preImport()"),
				(Pair key:#postImport				value:"outliner_callbacks.postImport()"),
				(Pair key:#filePreOpen				value:"outliner_callbacks.filePreOpen()"),
				(Pair key:#systemPostNew			value:"outliner_callbacks.systemPostNew()"),
				(Pair key:#systemPostReset			value:"outliner_callbacks.systemPostNew()"),
				(Pair key:#colorChanged				value:"outliner_callbacks.colorChanged()"),
				(Pair key:#preSystemShutdown		value:"try ( outliner_callbacks.preSystemShutdown() ) catch ()")
			),
	nodeEventCallbackItem,
	isCreatingNode = false,
	isDeleting = false,
	isMerging = false,
	isMergingXrefs = false,
	layerNames,
	currentLayer,




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
	scene_IsValidLayerName,
	tree_SetLayerActiveFn,
	tree_DeleteLayerFn,
	tree_SetLayerHiddenFrozenFn,
	tree_containsMaterialFn,
	tree_addMaterialToTreeFn,
	tree_setMaterialNameFn,


	--Cache tree functions to minimize lookup time.
	function createFunctionCache =
	(
		outliner_addLayerToTreeFn		= outliner.addLayerToTree;
		outliner_addObjectToTreeFn		= outliner.addObjectToTree;
		outliner_addMaterialToTreeFn	= outliner.addMaterialToTree;
		
		tree_beginUpdateFn				= outliner.tree.BeginUpdate;
		tree_endUpdateFn				= outliner.tree.EndUpdate;
		tree_getNodeCountFn				= outliner.tree.GetNodeCount;
		tree_selectObjectRangeFn		= outliner.tree.SelectObjectRange;
		tree_selectAllFn				= outliner.tree.SelectAll;
		tree_addObjectToTreeFn			= outliner.tree.AddObjectToTree;
		tree_addLayerToTreeFn			= outliner.tree.AddLayerToTree;
		tree_setObjectParentFn			= outliner.tree.SetObjectParent;
		tree_deleteObjectFn				= outliner.tree.DeleteObject;
		tree_setObjectNameFn			= outliner.tree.SetObjectName;
		tree_setObjectHiddenFn			= outliner.tree.SetObjectHidden;
		tree_setObjectFrozenFn			= outliner.tree.SetObjectFrozen;
		tree_setObjectMaterialFn		= outliner.tree.SetObjectMaterial;
		tree_setObjectLayerFn			= outliner.tree.SetObjectLayer;
		tree_setObjectClassFn			= outliner.tree.SetObjectClass;
		tree_SetLayerNameFn				= outliner.tree.SetLayerName;
		scene_IsValidLayerName			= outliner.tree.Scene.IsValidLayerName;
		tree_SetLayerActiveFn			= outliner.tree.SetLayerActive;
		tree_DeleteLayerFn				= outliner.tree.DeleteLayer;
		tree_SetLayerHiddenFrozenFn		= outliner.tree.SetLayerHiddenFrozen;
		tree_containsMaterialFn			= outliner.tree.Scene.ContainsMaterial;
		tree_addMaterialToTreeFn		= outliner.tree.AddMaterialToTree;
		tree_setMaterialNameFn			= outliner.tree.SetMaterialName;
	),
	
	
	function disposeFunctionCache =
	(
		outliner_addLayerToTreeFn		= undefined;
		outliner_addObjectToTreeFn		= undefined;
		outliner_addMaterialToTreeFn	= undefined;
		
		tree_beginUpdateFn				= undefined;
		tree_endUpdateFn				= undefined;
		tree_getNodeCountFn				= undefined;
		tree_selectObjectRangeFn		= undefined;
		tree_selectAllFn				= undefined;
		tree_addObjectToTreeFn			= undefined;
		tree_addLayerToTreeFn			= undefined;
		tree_setObjectParentFn			= undefined;
		tree_deleteObjectFn				= undefined;
		tree_setObjectNameFn			= undefined;
		tree_setObjectHiddenFn			= undefined;
		tree_setObjectFrozenFn			= undefined;
		tree_setObjectMaterialFn		= undefined;
		tree_setObjectLayerFn			= undefined;
		tree_setObjectClassFn			= undefined;
		tree_SetLayerNameFn				= undefined;
		scene_IsValidLayerName			= undefined;
		tree_SetLayerActiveFn			= undefined;
		tree_DeleteLayerFn				= undefined;
		tree_SetLayerHiddenFrozenFn		= undefined;
		tree_containsMaterialFn			= undefined;
		tree_addMaterialToTreeFn		= undefined;
		tree_setMaterialNameFn			= undefined;
		(dotnetClass "System.GC").Collect();
	),




	function removeLayerChangeHandlers =
	(
		deleteAllChangeHandlers id:#outliner_layers;
	),
	
	function createLayerChangeHandlers =
	(
		removeLayerChangeHandlers();
 		when parameters (for i = 0 to LayerManager.count - 1 collect (LayerManager.getLayer i).layerAsRefTarg) changes id:#outliner_layers layer do 
 			outliner_callbacks.layerParametersChanged layer;
	),


	
	function removeMaterialChangeHandlers =
	(
		deleteAllChangeHandlers id:#outliner_materials;
	),
	
	function createMaterialChangeHandlers =
	(
		removeMaterialChangeHandlers();
		when name (for m in sceneMaterials collect m) changes id:#outliner_materials mat do
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
			nodeEventCallbackItem = NodeEventCallback modelStructured:(function ms_fn evt n = ( outliner_callbacks.modelStructured evt n; )) delay:500; --workaround to avoid issue with function not yet being declared.
 		
		outliner_callbacks.setLayerNames();
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
					tree_selectObjectRangeFn (for o in selection collect (GetHandleByAnim o)) true;
				
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
				isCreatingNode = true;
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
	
	function nodeCreated =
	(
		isCreatingNode = false;
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
				local parentHandle = if (linkedNode.parent != undefined) then (GetHandleByAnim linkedNode.parent) else -1;
				tree_setObjectParentFn (GetHandleByAnim linkedNode) parentHandle (isGroupMember linkedNode);
			)
		)
		catch
		(
			fileIn "crash_report.ms";
		)
	),
	
	function nodeLinked = 
	(
		if (not outliner_status.linkedInOutliner AND not isDeleting AND not isMerging) do
		(
			nodeLinkedIntern (callbacks.notificationParam());
		)
	),
	

	
		
	/*
	 * NODE PRE DELETE & POST DELETE.
	 */
	function nodePreDelete = 
	(
		try
		(
			isDeleting = true;
			
			local deletedObject = callbacks.notificationParam();
			if (isValidNode deletedObject) do
			(
				local deletedObjectHandle = GetHandleByAnim deletedObject;
				
				if (isGrouphead deletedObject) do 
					outliner.openGroupHeads[deletedObjectHandle] = false;
		
				tree_deleteObjectFn deletedObjectHandle;
			)
		)
		catch
		(
			fileIn "crash_report.ms";
		)
	),
	
	function nodePostDelete =
	(
		isDeleting = false;
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
			-- Avoid calling outliner.tree.SetObjectClass when Outliner has been closed (caused a crash before).
			if (tree_setObjectClassFn != undefined AND outliner_status != undefined AND outliner_status.windowOpen AND outliner != undefined) do
			(
				for n in nodes do
				(
					local obj = GetAnimByHandle n;
					if (isValidNode obj AND (classof obj) != undefined) do
						tree_setObjectClassFn n (getClassName obj) ((superClassOf obj) as string);
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
					local matHandle = if (n.material != undefined) then (GetHandleByAnim n.material) else -1;
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
				tree_setObjectLayerFn (GetHandleByAnim node) (GetHandleByAnim layer.layerAsRefTarg);
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
			if (not isCreatingNode AND not isDeleting AND not isMerging AND not outliner_status.layerChangedInOutliner) do
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
				append layernames layer.name;
				
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
		
				local layerIndex = (findItem layerNames layer.name);
				if (layerIndex != 0) do 
				(
					deleteItem layerNames layerIndex;
				)
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
	 * 	called from when parameters change handler when either isHidden, isFrozen, renderable or color is changed
	 */
	function layerParametersChanged layer =
	(
		try
		(
			if (layer != undefined AND not (isDeleted layer)) do
			(
				local isHidden = outliner_NestedLayers.getLayerProperty layer #isHidden;
				local isFrozen = outliner_NestedLayers.getLayerProperty layer #isFrozen;
				if (isHidden != undefined AND isFrozen != undefined) do
					tree_SetLayerHiddenFrozenFn (GetHandleByAnim layer) isHidden isFrozen;
			)
		)
		catch
		(
			fileIn "crash_report.ms";
		)
	),
	
	
	/**
	 * Set Layer Names
	 */
	function setLayerNames = 
	(
		currentLayer = LayerManager.current;
		
		layerNames = #();
		for i = 0 to (LayerManager.count - 1) do
		(
			local layer = (LayerManager.getLayer i);
			append layerNames layer.name;
		)
	),
	
	
	/**
	 * Refresh Layer Names in treeview.
	 */
	function refreshLayerNames = 
	(
		try
		(
			if (tree_SetLayerNameFn != undefined AND scene_IsValidLayerName != undefined AND tree_SetLayerActiveFn != undefined) do
			(
				for i = 1 to LayerManager.count do 
				(
					if (i <= layerNames.count) do
					(
						local layer = LayerManager.getLayer (i - 1);
						
						-- Layer name changed.
						if (layerNames[i] != layer.name AND outliner_status.renamedInOutliner == false) do
						(
							if (scene_IsValidLayerName (GetHandleByAnim layer.layerAsRefTarg) layer.name) do
							(
								tree_SetLayerNameFn (GetHandleByAnim layer.layerAsRefTarg) layer.name;
								layerNames[i] = layer.name;
							)
						)
					)
				)
				
				if (LayerManager.current != currentLayer) do
				(
					if (not (isDeleted currentLayer)) do 
						tree_SetLayerActiveFn (GetHandleByAnim currentLayer.layerAsRefTarg) false;
						
					currentLayer = LayerManager.current;
					tree_SetLayerActiveFn (GetHandleByAnim currentLayer.layerAsRefTarg) true;
				)
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
	/*
		try
		(
			local undoName = callbacks.notificationParam();
			
			-- I haven't the faintest idea why the "group" action should be registered as "key" in the undo system, but it is max after all...
			-- When undoing, the group node isn't deleted (or at least no callback is called), so we have to refresh the entire tree to get rid of it.
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
			
			-- I haven't the faintest idea why the "group" action should be registered as "%d %s Selected" in the undo system, but it is max after all...
			-- When redoing, the group node isn't recreated (or at least no callback is called), so we have to refresh the entire tree to get it back.
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
		setLayerNames();
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
		setLayerNames();
	),
	
	
	/**
	 * FILE PRE OPEN
	 */
	function filePreOpen =
	(
		outliner.tree.ClearTree();
		--Clear the outlinerscene. I suspect that garbagecollections might occur when there's a dotnetmxsvalue that has no scene representation anymore.
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
		-- Pass an empty string to the tree colorscheme function to autonatically find the right one.
		outliner.setTreeColorScheme "";
	)
)