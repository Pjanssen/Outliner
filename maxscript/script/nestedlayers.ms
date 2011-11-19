outlinerNestedLayerData = attributes outlinerNestedLayerData version:1 attribID:#(0x7f85134a, 0x2ec90557)
(
	parameters main
	(
		outliner_parentLayer type:#MaxObject;
		outliner_isHidden type:#Boolean;
		outliner_isFrozen type:#Boolean;
		--outliner_autoObjectsDisplayByLayer type:#Boolean;
		--outliner_autoObjectsRenderByLayer type:#Boolean;
	)
)

struct outliner_NestedLayers
(
	public function addLayerDeletedCallback =
	(
		local callbackStr = ("
			for def in custAttributes.getSceneDefs() while (attrDef == undefined) do
				if (def.name == #outlinerNestedLayerData) do attrDef = def;
			if (attrDef != undefined) do (
				local deletedLayer = callbacks.notificationParam();
				local deleteDef = true;
				for i = 0 to LayerManager.count - 1 do (
					local layer = (LayerManager.getLayer i).layerAsRefTarg;
					local ca = custAttributes.get layer attrDef;
					if (ca != undefined) do (
						if (ca.outliner_parentLayer == delLayer OR layer == deletedLayer) then
							custAttributes.delete layer attrDef;
						else
							deleteDef = false;
					)
				)
				if (deleteDef) do (
					callbacks.removeScripts id:#outliner_nestedlayers;
					if (outliner_NestedLayers == undefined) do custAttributes.deleteDef attrDef;
				)
			)
		")
		
		callbacks.addScript #layerDeleted callbackStr id:#outliner_nestedlayers persistent:true;
	),
	
		
	
	public function addLayerData layer =
	(
		if (not (isKindOf layer Base_Layer)) do
			layer = layer.layerAsRefTarg;
		
		outliner_NestedLayers.addLayerDeletedCallback();
			
		custAttributes.add layer outlinerNestedLayerData;
	),
	
	public function getLayerData layer =
	(
		if (not (isKindOf layer Base_Layer)) do
			layer = layer.layerAsRefTarg;
			
		custAttributes.get layer outlinerNestedLayerData
	),
	
	public function getAddLayerData layer =
	(
		local ca = outliner_NestedLayers.getLayerData layer;
		if (ca == undefined) do
		(
			if (outliner_NestedLayers.addLayerData layer) do
				ca = outliner_NestedLayers.getLayerData layer;
		)
			
		ca;
	),
	
	public function deleteLayerData layer =
	(
		if (not (isKindOf layer Base_Layer)) do
			layer = layer.layerAsRefTarg;
		
		custAttributes.delete layer outlinerNestedLayerData;
	),
	
	
	
	public function getLayerProperty layer prop =
	(
		try
		(
			local ca = outliner_NestedLayers.getLayerData layer;
			local value;
			
			if (ca != undefined AND (isProperty ca prop)) then
				value = getProperty ca prop;
			else if (isProperty layer prop) then
				value = getProperty layer prop;
				
			value;
		)
		catch
		(
			fileIn "crash_report.ms";
			outliner_crash_report.handle_exception();
		)
	),
	
	public function setLayerProperty layer prop value setByParent:false =
	(
		try
		(
			if (isProperty layer prop) do
			(
				local ca = outliner_NestedLayers.getLayerData layer;
				
				if (ca == undefined) then
					setProperty layer prop value;
				else
				(
					local ownValue;
					
					if (not setByParent AND (isProperty ca ("outliner_" + prop))) then
					(
						setProperty ca ("outliner_" + prop) value;
						ownValue = value;
					)
					else
						ownValue = getProperty ca ("outliner_" + prop);
						
					local parentValue = false;
					if (ca.outliner_parentLayer != undefined) do
						parentValue = getProperty ca.outliner_parentLayer prop;
						
					setProperty layer prop (parentValue OR ownValue);
				)
				
				for i = 0 to LayerManager.count - 1 do
				(
					local childLayer = (LayerManager.getLayer i).layerAsRefTarg;
					if (childLayer != layer) do
					(
						local childCA = outliner_NestedLayers.getLayerData childLayer;
						if (childCA != undefined AND childCA.outliner_parentLayer == layer) do
							outliner_NestedLayers.setLayerProperty childLayer prop value setByParent:true;
					)
				)
			)
		)
		catch
		(
			fileIn "crash_report.ms";
			outliner_crash_report.handle_exception();
		)
	),
	
	
	public function updateLayerProperties layer =
	(
		try
		(
			local propNames = getPropNames layer;
			local ca = outliner_NestedLayers.getLayerData layer;
			if (ca != undefined) do
			(
				for propName in propNames do
				(
					if (isProperty ca ("outliner_" + propName)) do
					(
						outliner_NestedLayers.setLayerProperty layer propName undefined setByParent:true;
					)
				)
			)
		)
		catch
		(
			fileIn "crash_report.ms";
			outliner_crash_report.handle_exception();
		)
	),
	
	
	
	
	public function getLayerParent layer =
	(
		try
		(
			local ca = outliner_NestedLayers.getLayerData layer;
			local parent;
			
			if (ca != undefined) do
				parent = ca.outliner_parentLayer;
				
			parent;
		)
		catch
		(
			fileIn "crash_report.ms";
			outliner_crash_report.handle_exception();
		)
	),
	
	

	
	
	
	public function setLayerParent layer parent =
	(
		local success = true;
		try
		(
			if (parent != undefined) then
			(
				local ca = outliner_NestedLayers.getAddLayerData layer;
				if (ca != undefined) then
				(
					if (not (isKindOf parent Base_Layer)) do
						parent = parent.layerAsRefTarg;
					
					if (layer != parent AND not (refs.dependencyLoopTest parent layer)) then
					(
						ca.outliner_parentLayer = parent;
						outliner_NestedLayers.updateLayerProperties layer;
					)
					else
						success = false;
				)
				else
					success = false;
			)
			else
			(
				local ca = outliner_NestedLayers.getLayerData layer;
				if (ca != undefined) then
				(
					ca.outliner_parentLayer = undefined;
					outliner_NestedLayers.updateLayerProperties layer;
					outliner_NestedLayers.deleteLayerData layer;
				)
				else
					success = false;
			)
		)
		catch
		(
			--Gather some info to trace root cause of dependency crash.
			local layerRefs = refs.dependents layer;
			local parentRefs = refs.dependents parent;
			local depLoopTest = refs.dependencyLoopTest layer parent;
			local depLoopTestRev = refs.dependencyLoopTest parent layer;
			--Generate crash report.
			fileIn "crash_report.ms";
			outliner_crash_report.handle_exception();
		)
		
		success;
	),
	
	
	
	public function getAllChildLayers layer =
	(
		try
		(
			if (not (isKindOf layer Base_Layer)) do
				layer = layer.layerAsRefTarg;
				
			local childLayers = #();
			for i = 0 to LayerManager.count - 1 do
			(
				local childLayer = (LayerManager.getLayer i).layerAsRefTarg;
				if (childLayer != layer) do
				(
					local childCA = outliner_NestedLayers.getLayerData childLayer;
					if (childCA != undefined AND childCA.outliner_parentLayer == layer AND (findItem childLayers childLayer) == 0) do
					(
						append childLayers childLayer;
						join childLayers (outliner_NestedLayers.getAllChildLayers childLayer);
					)
				)
			)
			
			childLayers;
		)
		catch
		(
			fileIn "crash_report.ms";
			outliner_crash_report.handle_exception();
		)
	),
	
	
	public function propagatePropertyToChildLayers layer prop value =
	(
		try
		(
			if (not (isKindOf layer Base_Layer)) do
				layer = layer.layerAsRefTarg;
			
			for i = 0 to LayerManager.count - 1 do
			(
				local childLayer = (LayerManager.getLayer i).layerAsRefTarg;
				if (childLayer != layer) do
				(
					local childCA = outliner_NestedLayers.getLayerData childLayer;
					if (childCA != undefined AND childCA.outliner_parentLayer == layer AND (isProperty childLayer prop)) do
					(
						setProperty childLayer prop value;
						outliner_NestedLayers.propagatePropertyToChildLayers childLayer prop value;
					)
				)
			)
		)
		catch
		(
			fileIn "crash_report.ms";
			outliner_crash_report.handle_exception();
		)
	)

)