macroScript removeNestedLayers 
	category:"Outliner" 
	toolTip:"Remove Outliner nested layers" 
	buttonText:"Remove Outliner nested layers"
(
	rollout removeNestedLayers_rollout "Remove Outliner nested layers"
	(
		function getFilesRecursive root pattern =
		(
			local files = getFiles (root + "/" + pattern);
			local subDirs = GetDirectories (root + "/*");
			for d in subDirs do
				join files (getFilesRecursive d pattern);
			
			files;
		)
		
		function removeNestedLayers = 
		(
			--Try closing the Outliner first.
			try (
				outliner.close();
			) catch ()
			
			--Find the custom attributes definition in the scene.
			local attrDefs = custAttributes.getSceneDefs();
			local nestedLayerData;
			for i = 1 to attrDefs.count do
			(
				if (attrDefs[i].name == #outlinerNestedLayerData) do
					nestedLayerData = attrDefs[i];
			)
			
			--Remove the nested layer data from layers.
			local numLayers = LayerManager.count - 1;
			for i = 0 to numLayers do 
			(
				try (
					local layer = ILayerManager.getLayerObject i;
					if ((custattributes.get layer nestedLayerData) != undefined) do
						custAttributes.delete layer nestedLayerData;
				)catch()
			)
			
			--Remove the nested layer custom attributes definition from the scene.
			custAttributes.deleteDef nestedLayerData;
			
			--Remove persistent callbacks.
			callbacks.removeScripts #filePostOpen id:#outliner_nestedlayers;
			callbacks.removeScripts #layerDeleted id:#outliner_nestedlayers;
			callbacks.removeScripts #filePostOpen id:#outliner_nestedlayers;
		)



		local marginX = 5;
		local marginY = 5;
		local dialogW = 300;
		local grpW = dialogW - (marginX * 2);
		local ctrlX = 14;
		local ctrlDY = 20;
		
		label infoLbl "This will remove any layer nesting created by the Outliner." pos:[marginX, marginY];
		label infoLbl2 "The layers themselves will not be removed from the scene." pos:[marginX, marginY + 16];
		
		local currentSceneGrpH = 50;
		groupBox currentSceneGrp "Current Scene" width:grpW height:currentSceneGrpH pos:[marginX, marginY + ctrlDY * 2];
			button removeFromCurrentSceneBtn "Remove Nested Layers" width:(dialogW - ctrlX * 2) pos:[ctrlX, marginY + ctrlDY * 3];
		
		local batchGrpY = currentSceneGrpH + ctrlDY * 2 + marginY * 2;
		local batchGrpH = 75;
		groupBox batchGrp "Batch" width:grpW height:batchGrpH pos:[marginX, batchGrpY];
			edittext folderTxt "" width:(dialogW - ctrlX * 2 - 53) pos:[ctrlX - 3, batchGrpY + ctrlDY + 1];
			button browseBtn "Browse" width:50 pos:[dialogW - ctrlX - 50, batchGrpY + ctrlDY];
			button removeBatchBtn "Remove Nested Layers" width:(dialogW - ctrlX * 2);
		
		local resultGrpY = batchGrpY + batchGrpH + marginY * 2;
		local resultGrpH = 125;
		groupBox resultGrp "Result" width:grpW height:resultGrpH pos:[marginX, resultGrpY];
			edittext resultTxt "" text:"Waiting for input..." readOnly:true width:(dialogW - ctrlX * 2) height:95 pos:[ctrlX - 3, resultGrpY + ctrlDY + 1];
		
		button closeBtn "Close" width:(dialogW - marginX * 2) pos:[marginX, resultGrpY + resultGrpH + marginY];

		
		
		on removeFromCurrentSceneBtn pressed do
		(
			removeNestedLayers();
			resultTxt.text = "Removed nested layers from current scene.\n" + resultTxt.text;
		)
		
		on browseBtn pressed do
		(
			local batchPath = getSavePath initialDir:folderTxt.text;
			if (batchPath != undefined AND batchPath != "") do
				folderTxt.text = batchPath;
		)
		
		on removeBatchBtn pressed do
		(
			local batchPath = folderTxt.text;
			if (batchPath != undefined AND doesFileExist batchPath) do
			(
				local batchFiles = getFilesRecursive batchPath "*.max";
				local openSuccess;
				local saveSuccess;
				local resultText;
				for maxFile in batchFiles do
				(
					openSuccess = loadMaxFile maxFile useFileUnits:true quiet:true;
					if (openSuccess) then
					(
						removeNestedLayers();
						saveSuccess = saveMaxFile maxFile quiet:true;
						if (saveSuccess) then
							resultText = "Success";
						else
							resultText = "Failed to save scene";
					)
					else
						resultText = "Failed to open scene";
					
					resultText += " - " + maxFile;
					resultTxt.text = resultText + "\n" + resultTxt.text;
				)
			)
			resultTxt.text = "Batch completed." + "\n" + resultTxt.text;
		)
		
		
		
		on closeBtn pressed do
			destroyDialog removeNestedLayers_rollout;
	
	)
	
	
	on execute do
	(
		CreateDialog removeNestedLayers_rollout width:300 height:340;
	)
)