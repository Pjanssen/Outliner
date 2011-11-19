macroScript removeNestedLayerWarning 
	category:"Outliner" 
	toolTip:"Remove Outliner nested layer warning" 
	buttonText:"Remove Outliner nested layer warning"
(
	rollout removeWarning_rollout "Remove Outliner nested layer warning"
	(
		function getFilesRecursive root pattern =
		(
			local files = getFiles (root + "/" + pattern);
			local subDirs = GetDirectories (root + "/*");
			for d in subDirs do
				join files (getFilesRecursive d pattern);
			
			files;
		)
		
		function removePersistentCallback = 
		(
			callbacks.removeScripts #filePostOpen id:#outliner_nestedlayers;
		)



		local marginX = 5;
		local marginY = 5;
		local dialogW = 300;
		local grpW = dialogW - (marginX * 2);
		local ctrlX = 14;
		local ctrlDY = 20;
		
		
		local currentSceneGrpH = 50;
		groupBox currentSceneGrp "Current Scene" width:grpW height:currentSceneGrpH pos:[marginX, marginY];
			button removeFromCurrentSceneBtn "Remove Nested Layer Warning" width:(dialogW - ctrlX * 2) pos:[ctrlX, marginY + ctrlDY];
		
		local batchGrpY = currentSceneGrpH + marginY * 2;
		local batchGrpH = 75;
		groupBox batchGrp "Batch" width:grpW height:batchGrpH pos:[marginX, batchGrpY];
			edittext folderTxt "" width:(dialogW - ctrlX * 2 - 53) pos:[ctrlX - 3, batchGrpY + ctrlDY + 1];
			button browseBtn "Browse" width:50 pos:[dialogW - ctrlX - 50, batchGrpY + ctrlDY];
			button removeBatchBtn "Remove Nested Layer Warning" width:(dialogW - ctrlX * 2);
		
		local resultGrpY = batchGrpY + batchGrpH + marginY * 2;
		local resultGrpH = 125;
		groupBox resultGrp "Result" width:grpW height:resultGrpH pos:[marginX, resultGrpY];
			edittext resultTxt "" text:"Waiting for input..." readOnly:true width:(dialogW - ctrlX * 2) height:95 pos:[ctrlX - 3, resultGrpY + ctrlDY + 1];
		
		button closeBtn "Close" width:(dialogW - marginX * 2) pos:[marginX, resultGrpY + resultGrpH + marginY];

		
		
		on removeFromCurrentSceneBtn pressed do
		(
			removePersistentCallback();
			resultTxt.text = "Removed nested layer warning from current scene.\n" + resultTxt.text;
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
						removePersistentCallback();
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
			destroyDialog removeWarning_rollout;
	
	)
	
	
	on execute do
	(
		CreateDialog removeWarning_rollout width:300 height:300;
	)
)