struct outlinerCore
(
	version				= 2.0,
	versionStr			= "2.0",
	maxV				= (maxVersion())[1] / 1000,
	dir					= ((GetDir #Scripts) + "/outliner/"),
	icondir				= dir + "ui/icons/",
	prefs,
	ui,

	tree,
	kbd_actions,




	/**
	 * .NET HELPER FUNCTIONS
	 */
	 
	--Load an assembly with shadow-copy enabled.
	function loadAssembly dll =
	(
		local AppDomain = dotNetClass "System.AppDomain";
		local AssemblyName = dotNetClass "System.Reflection.AssemblyName";

		AppDomain.CurrentDomain.SetShadowCopyPath dir;
		AppDomain.CurrentDomain.SetShadowCopyFiles();

		local assemblyName = AssemblyName.GetAssemblyName (dir + dll);
		AppDomain.CurrentDomain.Load assemblyName;
	),
	
	
	--Returns a dotnet enum value from the supplied type and value strings.
	function parseDotNetEnum enumType enumValue =
	(
		(dotNetClass "System.Enum").Parse (dotNet.getType enumType) enumValue;
	),


	--Return the names in the enum as an array.
	function getNamesDotNetEnum enumType =
	(
		(dotNetClass "System.Enum").GetNames (dotNet.getType enumType);
	),




	function askDownloadUpdate latestVersion =
	(
		if (queryBox ("A new Outliner version (" + latestVersion as String + ") is available!\nWould you like to download and install it now?") title:"Update available") do
		(
			local client = dotNetObject "System.Net.WebClient";
			local getInstallerUri = dotnetObject "System.Uri" "http://script.threesixty.nl/outliner/get_latest.php?fn=getInstallerUrl";
			local installerUrl = client.DownloadString getInstallerUri;
			local dragDropDir = dragAndDrop.getDownloadDirectory();
			local downloadSuccess = dragAndDrop.downloadPackage #(installerUrl) dragDropDir true;
			if (downloadSuccess) then
			(
				local dropFile = dragDropDir + "/" + (filenameFromPath installerUrl);
				dragAndDrop.dropPackage (windows.getMAXHWND()) [0, 0] dropFile;
				deleteFile dropFile;
			)
			else
				messageBox "Failed to download installer." title:"Error";
		)
	),
	
	--note: To work around instance access bug for .NET handlers, this function refers to the outliner object directly.
	function onUpdateDownloadCompleted s e =
	(
		if (not e.Cancelled AND e.Error == undefined) do
		(
			latestVersion = e.Result as float;
			if (latestVersion != undefined AND outliner.version < latestVersion) do
			(
				outliner.askDownloadUpdate latestVersion;
			)
		)
	),
	
	function onUpdateDownloadCompletedFull s e =
	(
		if (not e.Cancelled) do
		(
			if (e.Error != undefined) then
				messageBox ("Error retreiving update information:\n" + e.Error.Message) title:"Error";
			else
			(
				latestVersion = e.Result as float;
				if (latestVersion != undefined) do
				(
					if (outliner.version < latestVersion) then
						outliner.askDownloadUpdate latestVersion;
					else
					(
						local mb = dotNetClass "System.Windows.Forms.MessageBox";
						local mbBtn = dotNetClass "System.Windows.Forms.MessageBoxButtons";
						local mbIcon = dotNetClass "System.Windows.Forms.MessageBoxIcon";
						mb.Show ("You are running the latest Outliner version (" + (outliner.version as string) + ")") "No update available" mbBtn.OK mbIcon.Information;
					)
				)
			)
		)
		
		if (outliner_options_general != undefined) do
		(
			outliner_options_general.checkNowBtn.text = "Check now";
			outliner_options_general.checkNowBtn.checked = false;
		)
	),
	
	webClient,
	
	function getUpdateVersionAsync showLatestInstalledMessage =
	(
		webClient = dotNetObject "System.Net.WebClient";
		local getLatestUri = dotnetObject "System.Uri" "http://script.threesixty.nl/outliner/get_latest.php?fn=getVersionNr";
		
		if (showLatestInstalledMessage) then
			dotnet.addEventHandler webClient "DownloadStringCompleted" onUpdateDownloadCompletedFull;
		else
			dotnet.addEventHandler webClient "DownloadStringCompleted" onUpdateDownloadCompleted;
			
		webClient.DownloadStringAsync getLatestUri;
	),
	
	--Checks if a new version is available.
	function checkUpdate =
	(
		local checkUpdates = prefs.getValue #General #checkForUpdates;
		if (checkUpdates) do
		(
			local checkInterval = prefs.getValue #General #checkUpdatesInterval;
			local lastCheckTicks = prefs.getValue #General #lastUpdateCheck;
			local nowTicks = (dotNetClass "System.DateTime").Now.Ticks;
			local lastCheckSpan = dotNetObject "System.TimeSpan" (nowTicks - lastCheckTicks);
			if (lastCheckSpan.TotalDays > checkInterval) do
				getUpdateVersionAsync false;

			prefs.setValue #General #lastUpdateCheck nowTicks;
		)
	),






	/**
	 * SCENE FUNCTIONS
	 */
	--function cache for tree functions
	tree_Scene_AddObjectFn,
	tree_Scene_AddLayerFn,
	tree_Scene_AddMaterialFn,
	tree_setObjectLayerFn,
	tree_setLayerActiveFn,
	tree_setLayerParentFn,
	tree_GetSelectedNodeHandles,

	function setTreeInst t =
	(
		tree = t;
		tree_Scene_AddObjectFn		= tree.Scene.AddObject;
		tree_Scene_AddLayerFn		= tree.Scene.AddLayer;
		tree_Scene_AddMaterialFn	= tree.Scene.AddMaterial;
		tree_setObjectLayerFn		= tree.SetObjectLayer;
		tree_setLayerActiveFn		= tree.SetLayerActive;
		tree_setLayerParentFn		= tree.SetLayerParent;
		tree_GetSelectedNodeHandles = tree.GetSelectedNodeHandles;
	),


	--Add an object to the Scene in the treeview. (doesn't add it to the tree nodes itself though!)
	function addObjectToTree o layerHandle: =
	(
		if (layerHandle == unsupplied) do
			layerHandle = GetHandleByAnim o.layer.layerAsRefTarg;
			
		local parentHandle = if (o.parent != undefined) then (GetHandleByAnim o.parent) else -1;
		local matHandle = if (o.material != undefined) then (GetHandleByAnim o.material) else -1;
		tree_Scene_AddObjectFn (GetHandleByAnim o) parentHandle layerHandle matHandle o.name (getClassName o) ((superclassof o) as string) o.isNodeHidden o.isNodeFrozen (isGroupHead o) (isGroupMember o);
	),
	
	
	--Add a layer to the Scene in the treeview. (doesn't add it to the tree nodes itself though!)
	function addLayerToTree layer layerHandle: = 
	(
		if (layerHandle == unsupplied) do
			layerHandle = GetHandleByAnim layer.layerAsRefTarg;
			
		local parentLayer = outliner_NestedLayers.getLayerParent layer;
		local parentHandle = if (parentLayer != undefined) then (GetHandleByAnim parentLayer) else -1;
			
		tree_Scene_AddLayerFn layerHandle parentHandle layer.name (outliner_NestedLayers.getLayerProperty layer #isHidden) (outliner_NestedLayers.getLayerProperty layer #isFrozen) layer.current;
	),
	
	
	function addMaterialToTree mat parentHandle =
	(
		tree_Scene_AddMaterialFn (GetHandleByAnim mat) parentHandle mat.name (getClassName mat);
		
		/*
		for m = 1 to (getNumSubMtls mat) do 
			addMaterialToTree (getSubMtl mat m) (GetHandleByAnim mat);
				
		for m = 1 to (getNumSubTexmaps mat) do
		(
			if ((getSubTexMap mat m) != undefined) do
				addMaterialToTree (getSubTexmap mat m) (GetHandleByAnim mat);
		)
		*/
	),



	function pushMaterialsToTree =
	(
		tree.Scene.ClearMaterials();
		for mat in scenematerials do
			addMaterialToTree mat -1;
	),

	function pushSceneToTree =
	(
		try
		(
			tree.Scene.Clear();
	
			--Add layers to tree.
			local layerCount = LayerManager.count - 1;
			for i = 0 to layerCount do
			(
				local layer = LayerManager.getLayer i;
				local layerHandle = GetHandleByAnim layer.layerAsRefTarg;
				
				addLayerToTree layer layerHandle:layerHandle;
				
				--Add all objects on this layer
				local nodes;
				layer.nodes &nodes;
				for n in nodes do
					addObjectToTree n layerHandle:layerHandle;
			)
			
			--Add materials to tree if necessary.
			if ((prefs.getValue #Tree #listMode) == "Material" OR (prefs.getValue #Tree #sortMode) == "Material") do
				pushMaterialsToTree();
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),



	function switchListMode listMode =
	(
		local listModeEnum = parseDotNetEnum "Outliner.OutlinerListMode" listMode;
		if (tree.ListMode != listModeEnum) do
		(
			if (listMode == "Layer" OR (prefs.getValue #Tree #sortMode) == "Layer") then
			(
				outliner_main.refreshLayerNamesTimer.active = true;
				outliner_callbacks.createLayerChangeHandlers();
			)
			else
			(
				outliner_main.refreshLayerNamesTimer.active = false;
				outliner_callbacks.removeLayerChangeHandlers();
			)
				
			if (listMode == "Material" OR (prefs.getValue #Tree #sortMode) == "Material") then
			(
				pushMaterialsToTree();
				outliner_callbacks.createMaterialChangeHandlers();
			)
			else
				outliner_callbacks.removeMaterialChangeHandlers();

			prefs.setValue #Tree #listMode listMode;
			tree.ListMode = listModeEnum;
			tree.FillTree();
		)
	),


	function switchSortMode sortMode =
	(
		outliner.prefs.setValue #Tree #sortmode sortMode;
		
		if ((prefs.getValue #Tree #listMode) == "Layer" OR sortMode == "Layer") then
		(
			outliner_main.refreshLayerNamesTimer.active = true;
			outliner_callbacks.createLayerChangeHandlers();
		)
		else
		(
			outliner_main.refreshLayerNamesTimer.active = false;
			outliner_callbacks.removeLayerChangeHandlers();
		)
			
		if ((prefs.getValue #Tree #listMode) == "Material" OR sortMode == "Material") then
		(
			pushMaterialsToTree();
			outliner_callbacks.createMaterialChangeHandlers();
		)
		else
			outliner_callbacks.removeMaterialChangeHandlers();
				
		local sorterClass = "Outliner.NodeSorters." + sortMode + "Sorter";
		outliner.tree.TreeViewNodeSorter = dotNetObject sorterClass;
		
		outliner_main.setSortModeBtnImages();
	),





	

	/**
	 * HANDLE AUTOMATIC GROUP OPENING/CLOSING
	 *
	 * This function will open any groups containing nodes from the passed selnodes array.
	 * It will also close any groups opened previously that no longer need to stay opened.
	 */
	openGroupHeads = #{},
	function handleGroupOpeningClosing selnodes selectedInOutliner =
	(
		try
		(
			-- New bitarray containing all groupheads that should be opened or remain opened.
			local newOpenGroupHeads = #{};
	
			for n in selNodes do
			(
				if (isValidNode n) do
				(
					if (isGroupMember n) do
					(
						--Find any groupheads that have to be opened. Groups can be nested, so loop until root is reached.
						local n_parent = n.parent;
						while (n_parent != undefined) do
						(
							if (isGroupHead n_parent) do
							(
								local groupHeadHandle = GetHandleByAnim n_parent;
								if (isOpenGroupHead n_parent) then
								(
									if (openGroupHeads[groupHeadHandle]) do
										newOpenGroupHeads[groupHeadHandle] = true;
								)
								else if (selectedInOutliner OR not n_parent.isSelected) then
								(
									setGroupOpen n_parent true;
									newOpenGroupHeads[groupHeadHandle] = true;
								)
							)
		
							n_parent = n_parent.parent;
						)
					)
				)
			)
	
			-- Close groups that should node longer be opened. -groups that were opened by the outliner, but are no longer selected-
			local groupHeadsToClose = openGroupHeads - newOpenGroupHeads;
			for groupHandle in groupHeadsToClose do
			(
				local groupHead = GetAnimByHandle groupHandle;
				if (isValidNode groupHead AND isGroupHead groupHead) do setGroupOpen groupHead false;
			)
	
			openGroupHeads = newOpenGroupHeads;
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),












	/**
	 * HELPER FUNCTIONS
	 */

	function deleteLayer layer = 
	(
		try
		(
			local deflayer = LayerManager.getLayer 0;
			local nodes;
			layer.nodes &nodes;
	
			local result = #yes;
			
			if (nodes.count > 0) do
			(
				result = yesNoCancelBox ("Delete objects on layer " + layer.name + " too?\nIf you choose 'no', the objects will be moved to layer 0.") title:"Delete objects on layer?";
				
				if (result == #no) then
				(
					for n in nodes do 
					(
						outliner_callbacks.nodeLayerChangedIntern n defLayer;
						defLayer.addNode n;
					)
				)
				else
					delete nodes;
			)
			
			if (result != #cancel) do
			(
				if (layer.current) do defLayer.current = true;
				outliner_callbacks.layerDeletedIntern layer;
				LayerManager.deleteLayerByName layer.name;
			)
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	
	



	function setActiveLayer layer =
	(
		try
		(
			tree_setLayerActiveFn (GetHandleByAnim (LayerManager.current).layerAsRefTarg) false;
			layer.current = true;
			tree_setLayerActiveFn (GetHandleByAnim layer.layerAsRefTarg) true;
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	function setActiveLayerSelected =
	(
		try
		(
			local selLayerHandles = tree.SelectedLayerHandles;
			if (selLayerHandles.count > 0) do
				setActiveLayer (GetAnimByHandle selLayerHandles[1]);
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),





	function setPropertyOnAllSelectedLayerObjects prop value =
	(
		try
		(
			local layerHandles = tree_GetSelectedNodeHandles false true false;
			for layerHandle in layerHandles do
			(
				local layer = GetAnimByHandle layerHandle;
				if (layer != undefined) do
				(
					local nodes;
					layer.nodes &nodes;
					for n in nodes do
						setProperty n prop value;
				)
			)
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),

	function setPropertyOnSelection prop value includeObjects:false includeLayers:false includeMaterials:false =
	(
		try
		(
			local nodeHandles = tree_GetSelectedNodeHandles includeObjects includeLayers includeMaterials;
			for handle in nodeHandles do
			(
				local n = GetAnimByHandle handle;
				if (n != undefined AND (isProperty n prop)) do
					setProperty n prop value;
			)
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),




	function deleteSelection =
	(
		try
		(
			undo "Delete" on
			(
				with redraw off
				(
					local handles = tree_GetSelectedNodeHandles true true false;
					for handle in handles do
					(
						local n = GetAnimByHandle handle;
						if (n != undefined) do
						(
							if (isKindOf n Node) then
								delete n;
							else if (isKindOf n Base_Layer AND n.name != "0") then
								deleteLayer n;
						)
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
	
	
	function hideSelection hide =
	(
		try
		(
			local undoString = if hide then "Hide" else "Unhide";
			undo undoString on
			(
				with redraw off
				(
					local handles = tree_GetSelectedNodeHandles true true false;
					for handle in handles do
					(
						local n = GetAnimByHandle handle;
						if (n != undefined) do
						(
							if (isKindOf n Node) then
								n.isNodeHidden = hide;
							else if (isKindOf n Base_Layer) then
								outliner_NestedLayers.setLayerProperty n #isHidden hide;
						)
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



	function freezeSelection freeze =
	(
		try
		(
			local undoString = if freeze then "Freeze" else "Unfreeze";
			undo undoString on
			(
				with redraw off
				(
					local handles = tree_GetSelectedNodeHandles true true false;
					for handle in handles do
					(
						local n = GetAnimByHandle handle;
						if (n != undefined) do
						(
							if (isKindOf n Node) then
								n.isNodeFrozen = freeze;
							else if (isKindOf n Base_Layer) then
								outliner_NestedLayers.setLayerProperty n #isFrozen freeze;
						)
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



	function unlinkSelection =
	(
		try
		(
			undo "Unlink" on
			(
				with redraw off
				(
					local handles = tree.GetSelectedParentObjectHandles();
					for handle in handles do
					(
						local n = GetAnimByHandle handle;
						if (n != undefined) do
						(
							if (isGroupMember n) do
								setGroupMember n false;
							n.parent = undefined;
						)
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



	function moveObjectToLayer obj targetLayer =
	(
		targetLayer.addNode obj;
		outliner_callbacks.nodeLayerChangedIntern obj targetLayer;
	),
	
	function moveGroupToLayer obj targetLayer =
	(
		moveObjectToLayer obj targetLayer;
		for c in obj.children do
		(
			if (isGroupMember c) do
				moveGroupToLayer c targetLayer;
		)
	),

	function moveSelectionToLayer targetLayer =
	(
		try
		(
			if (targetLayer != undefined) do
			(
				undo "Move to layer" on
				(
					with redraw off
					(
						local handles = tree_GetSelectedNodeHandles true true false;
						for handle in handles do
						(
							local n = GetAnimByHandle handle;
							if (n != undefined) do
							(
								if (isKindOf n Node) then
								(
									if (isGroupHead n AND tree.HideGroupMembersLayerMode) then
										moveGroupToLayer n targetLayer;
									else
										moveObjectToLayer n targetLayer;
								)
								else if (isKindOf n Base_Layer AND n != targetLayer AND n.name != "0") then
								(
									outliner_NestedLayers.setLayerParent n targetLayer;
									tree_setLayerParentFn handle (GetHandleByAnim targetLayer);
								)
							)
						)
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


	function addSelectionToNewLayer =
	(
		try
		(
			local newLayer;
			undo "Create new layer" on
			(
				newLayer = (LayerManager.newLayer()).layerAsRefTarg;
			)
			moveSelectionToLayer newLayer;
	
			if (outliner.prefs.getValue #Tree #editNewLayerName) do
				outliner.tree.EditNodeName (GetHandleByAnim newLayer);
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	function addSelectionToNewContainer =
	(
		try
		(
			local c = Containers.CreateContainer (getCurrentSelection());
			
			if (outliner.prefs.getValue #Tree #editNewLayerName) do
				outliner.tree.EditNodeName (GetHandleByAnim c);
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	function addSelectionToNewGroup =
	(
		try 
		(
			local g = group (getCurrentSelection());
			
			if (outliner.prefs.getValue #Tree #editNewLayerName) do
				outliner.tree.EditNodeName (GetHandleByAnim g);
		)
		catch
		(
			local crashReport = outliner_crash_report();
			crashReport.handle_exception crashReport;
		)
	),
	
	
	
	
	
	


	/**
	 * SET TREE COLOR SCHEME
	 */
	function getColorFromStr colorStr = 
	(
		local newColor;
		try (
			newColor = (execute colorStr);
		) catch ()
		if ((classof newColor) != Color) do 
		(
			try (
				newColor = ((colorMan.getColor colorStr) * 255) as color;
			) catch ()
		)
		if ((classof newColor) == Color) then
			newColor;
		else
			color 122 122 122;
	),
	
	
	
	function setTreeColorScheme schemeName =
	(
		local iniFile = dir + "colorSchemes.ini";
		
		local invIcons = prefs.getValue #Visual #invertIcons;
		
		--Guess scheme name (light or dark) if no name was provided.
		if (schemeName == "") do
		(
			if (ui.usingMaxDarkScheme()) then
			(
				schemeName = "Dark";
				invIcons = true;
			)
			else
			(
				schemeName = "Light";
				invIcons = false;
			)
				
			prefs.setValue #Visual #colorScheme schemeName;
			prefs.setValue #Visual #invertIcons invIcons;
		)
		
		tree.InvertIcons = invIcons;
		
		local colorClass = dotNetClass "System.Drawing.Color";
		local colors = getINISetting iniFile schemeName;
		
		for i in colors do 
		(
			local color = getColorFromStr (getINISetting iniFile schemeName i);
			setproperty tree.Style i (colorClass.FromARGB color.r color.g color.b);
		)
		
		try 
		(
			outliner_main.setButtonImages(); 
			outliner_main.setSortModeBtnImages();
		) catch()
		try ( outliner_filter_config.setButtonImages(); ) catch()
		
		tree.ResetAllNodesStyle();
	),






	/**
	 * Key Up handling (running actions while focus is on tree).
	 */
	function handleKeyUp e =
	(
		try
		(
			local mod_key_code = kbd_actions.getModKeyCode altPressed:e.Alt ctrlPressed:e.Control shiftPressed:e.Shift;
			kbd_actions.runActionFromKeyCode mod_key_code e.KeyValue table_id1:kbd_actions.main_table_id table_id2:kbd_actions.macro_table_id;
			
			if (outliner_status != undefined AND outliner_status.windowOpen == true AND not outliner_status.closingOutliner) do
				setFocus tree;
		) catch ()
	),
	
	
	/**
	 * FILE WATCH (KEYBOARDFILE)
	 */
	
	--The .NET FileSystemWatcher object.
	kbd_fileWatch,
	
	--Handle the Changed event.
	function fileWatch_Changed sender e =
	(
		try
		(
			--Disable further events until handling is completed. (Multiple Changed events are fired, we only need to handle one).
			sender.EnableRaisingEvents = false;
			
			if (sender.MXSObject != undefined AND sender.MXSObject.value != undefined) do
				sender.MXSObject.value.read();
			
			sender.EnableRaisingEvents = true;
		) catch ()
	),
	
	--actionMan.getKeyboardFile sometimes returns a path with a double backslash at the end, .NET doesn't like that.
	function stripTrailingSlashes str =
	(
		local n = str.count;
		while (n > 0 AND str[n] == "\\") do n -= 1;
		substring str 1 (n + 1);
	),

	
	--Adds the filesystemwatch changed event.
	--MAKE SURE YOU CALL REMOVEKBDFILEWATCH() WHEN THE KEYACTIONSFILE OBJECT IS NO LONGER USED!
	function addKbdFileWatch =
	(
		if (doesFileExist kbd_actions.file) do
		(
			kbd_fileWatch = dotnetObject "Outliner.MXSFileWatcher";
			kbd_fileWatch.MXSObject = dotNetMXSValue kbd_actions;
			kbd_fileWatch.WatchFileChange(kbd_actions.file);

			dotNet.addEventHandler kbd_fileWatch "Changed" fileWatch_Changed;
		)
	),
	
	function removeKbdFileWatch =
	(
		if (kbd_fileWatch != undefined) do
		(
			dotNet.removeEventHandlers kbd_fileWatch "Changed";
			kbd_fileWatch.MXSObject = undefined;
			kbd_fileWatch = undefined;
			(dotnetclass "System.GC").Collect();
		)
	),

	
	
	
	
	/**
	 * Open & close Outliner
	 */
	function open =
	(
		ui.openOutliner();
	),
	
	function close =
	(
		ui.closeOutliner();
	),
	
	
	/**
	 * Initialize Outliner.
	 */
	function init = 
	(
		local success = true;
		
		CreateDialog outliner_initializing 150 40 style:#(#style_toolwindow);;
		
		try
		(
			loadAssembly "Outliner.dll";
			
			prefs = outlinerPreferences iniFile:((GetDir #userScripts) + "/outliner_prefs.ini");
			prefs.loadPreferences();
			prefs.setValue #General #version version;
			
			ui = outlinerUI();
			
			checkUpdate();
		)
		catch
		(
			print (getCurrentException());
			messageBox "Loading Outliner core failed.\n\nTip: make sure you have the latest .NET Framework installed.\nPlease see the Maxscript Listener (F11) for details." title:"Error";
			success = false;
		)
		
		destroyDialog outliner_initializing;
		
		success;
	),





	/**
	 * Destroy outliner structs and objects
	 */
	function disposeFunctionCache =
	(
		tree = undefined;
		tree_Scene_AddObjectFn 		= undefined;
		tree_Scene_AddLayerFn 		= undefined;
		tree_Scene_AddMaterialFn	= undefined;
		tree_setObjectLayerFn 		= undefined;
		tree_setLayerActiveFn 		= undefined;
		tree_setLayerParentFn 		= undefined;
		tree_GetSelectedNodeHandles	= undefined;
		(dotnetClass "System.GC").Collect();
	),
	
	function dispose =
	(
		outliner_main = undefined;
		outliner_sortmode = undefined;
		outliner_options = undefined;
		outliner_filter_config = undefined;
		outliner_initializing = undefined;
		outlinerUI = undefined;
	
		callbacks.removeScripts id:#outliner;		
		outliner_callbacks = undefined;
		outlinerCallbacks = undefined;

		outlinerPrefsEntry = undefined;
		outlinerPreferences = undefined;
		outliner_status = undefined;
		outlinerStatus = undefined;
		
		if (webClient != undefined) do
		(
			dotnet.removeEventHandlers webClient "DownloadStringCompleted";
			webClient = undefined;
		)
		outliner = undefined;
		outlinerCore = undefined;
	)
)