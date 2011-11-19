outlinerNestedLayerData = attributes outlinerNestedLayerData version:1 attribID:#(0x7f85134a, 0x2ec90557)
(
	parameters main
	(
		outliner_parentLayer type:#MaxObject;
		outliner_isHidden type:#Boolean;
		outliner_isFrozen type:#Boolean;
	)
)

struct outliner_NestedLayers
(
	function addLayerDeletedCallback =
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
	
	
	function addFileOpenCallback =
	(
		local callbackStr = ("
			local outliner_prefs_file = (GetDir #userScripts) + \"/outliner_prefs.ini\";
			if (not (doesFileExist outliner_prefs_file)) do (
				local containsNestedLayers = false;
				for def in custAttributes.getSceneDefs() while (not containsNestedLayers) do
					if (def.name == #outlinerNestedLayerData) do containsNestedLayers = true;
				if (containsNestedLayers) do (
					(dotNetClass \"MessageBox\").Show \"This scene contains nested layer data created by the Outliner Scene Management tool.\nThe Outliner can be downloaded from www.scriptspot.com.\n\nThis will not interfere with regular layer or layer manager behavior.\" \"Outliner nested layer data found\" (dotnetclass \"MessageBoxButtons\").OK (dotnetclass \"MessageBoxIcon\").Information;
					callbacks.removeScripts #filePostOpen id:#outliner_nestedlayers;
				)
			)
		")
		
		callbacks.addScript #filePostOpen callbackStr id:#outliner_nestedlayers persistent:true;
	),
	
	
	function addLayerData layer =
	(
		if (not (isKindOf layer Base_Layer)) do
			layer = layer.layerAsRefTarg;
		
		outliner_NestedLayers.addLayerDeletedCallback();
		
		if (outliner.prefs.getValue #General #addNestedLayerMessage) do
			outliner_NestedLayers.addFileOpenCallback();
			
		custAttributes.add layer outlinerNestedLayerData;
	),
	
	function getLayerData layer =
	(
		if (not (isKindOf layer Base_Layer)) do
			layer = layer.layerAsRefTarg;
			
		custAttributes.get layer outlinerNestedLayerData
	),
	
	function getAddLayerData layer =
	(
		local ca = outliner_NestedLayers.getLayerData layer;
		if (ca == undefined) do
		(
			if (outliner_NestedLayers.addLayerData layer) do
				ca = outliner_NestedLayers.getLayerData layer;
		)
			
		ca;
	),
	
	function deleteLayerData layer =
	(
		if (not (isKindOf layer Base_Layer)) do
			layer = layer.layerAsRefTarg;
		
		custAttributes.delete layer outlinerNestedLayerData;
	),
	
	
	
	function getLayerProperty layer prop =
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
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	function setLayerProperty layer prop value setByParent:false =
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
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	
	function updateLayerProperties layer =
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
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	
	
	
	function getLayerParent layer =
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
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	
	
	
	function setLayerParent layer parent =
	(
		try
		(
			if (parent != undefined) then
			(
				local ca = outliner_NestedLayers.getAddLayerData layer;
				if (ca != undefined) do
				(
					if (not (isKindOf parent Base_Layer)) do
						parent = parent.layerAsRefTarg;
						
					ca.outliner_parentLayer = parent;
					outliner_NestedLayers.updateLayerProperties layer;
				)
			)
			else
			(
				local ca = outliner_NestedLayers.getLayerData layer;
				if (ca != undefined) do
				(
					ca.outliner_parentLayer = undefined;
					outliner_NestedLayers.updateLayerProperties layer;
					outliner_NestedLayers.deleteLayerData layer;
				)
			)
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	)

)