struct outlinerCore
(
	public maxV				= (maxVersion())[1] / 1000,
	public dir				= ((GetDir #userScripts) + "/outliner/"),
	public icondir			= dir + "ui/icons/",
	
	public prefs,
	public product_info,

	public ui,
	public treeController,



	/**
	 * KEYBOARD ACTIONS
	 */
	
	private kbd_actions,
	private kbd_fileWatch,
	
	--Handle the Changed event.
	private function fileWatch_Changed sender e =
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
	

	
	--Adds the filesystemwatch changed event.
	--MAKE SURE YOU CALL REMOVEKBDFILEWATCH() WHEN THE KEYACTIONSFILE OBJECT IS NO LONGER USED!
	private function addKbdFileWatch =
	(
		try
		(
			if (doesFileExist kbd_actions.file) do
			(
				kbd_fileWatch = dotnetObject "Outliner.MXSFileWatcher";
				kbd_fileWatch.MXSObject = dotNetMXSValue kbd_actions;
				kbd_fileWatch.WatchFileChange(kbd_actions.file);
	
				dotNet.addEventHandler kbd_fileWatch "Changed" fileWatch_Changed;
			)			
		)
		catch 
		(
			fileIn "crash_report.ms";
			outliner_crash_report.handle_exception();
		)
	),
	
	private function removeKbdFileWatch =
	(
		try
		(
			if (kbd_fileWatch != undefined) do
			(
				dotNet.removeEventHandlers kbd_fileWatch "Changed";
				kbd_fileWatch.MXSObject = undefined;
				kbd_fileWatch = undefined;
				(dotnetclass "System.GC").Collect();
			)
		)
		catch 
		(
			fileIn "crash_report.ms";
			outliner_crash_report.handle_exception();
		)
	),

	
	
	private function addTreeControllerEventHandlers =
	(
		dotNet.addEventHandler treeController "SelectionChanged" (fn delegateFn s e = ( outliner_TreeEventHandlers.SelectionChanged e; ) );
		dotNet.addEventHandler treeController "NodesParentChanged" (fn delegateFn s e = ( outliner_TreeEventHandlers.NodesParentChanged e; ) );
		--dotNet.addEventHandler treeController "NodeBoxModeChanged" (fn delegateFn s e = ( outliner_TreeEventHandlers.NodeBoxModeChanged s e; ) );
		--dotNet.addEventHandler treeController "NodeHiddenChanged" (fn delegateFn s e = ( outliner_TreeEventHandlers.NodeHiddenChanged s e; ) );
		--dotNet.addEventHandler treeController "NodeFrozenChanged" (fn delegateFn s e = ( outliner_TreeEventHandlers.NodeFrozenChanged s e; ) );
		--dotNet.addEventHandler treeController "NodeNameChanged" (fn delegateFn s e = ( outliner_TreeEventHandlers.NodeNameChanged s e; ) );
	),
	
	private function removeTreeControllerEventHandlers =
	(
		dotNet.removeAllEventHandlers treeController;
	),
	
	
	/**
	 * Open & Close Outliner
	 */
	public function open =
	(
--		try
--		(
			treeController = dotNetObject "Outliner.OutlinerTreeController";
			addTreeControllerEventHandlers();
			
			ui.openOutliner();
				
			kbd_actions = KeyboardActionsFile file:(KeyboardActionsFile.getDefaultKeyboardFile());
			addKbdFileWatch();
			
			outliner_callbacks = outlinerCallbacks();
			outliner_callbacks.createCallbacks();
			
			treeController.RegisterContainer outliner_main.mainContainer;
			outliner_main.mainContainer.Tree_Bottom.Mode = dotNetObject "Outliner.Controls.TreeViewModes.LayerMode";
			
			treeController.SetTreeViewColors (ui.createTreeViewColors());
			
			outliner_sceneFunctions.pushSceneToTreeController treeController;
--		)
--		catch 
--		(
--			fileIn "crash_report.ms";
--			outliner_crash_report.handle_exception();
--		)
	),
	
	public function close =
	(
		try
		(
			ui.closeOutliner();
			
			if (treeController != undefined) do
			(
				removeTreeControllerEventHandlers();
				treeController.Dispose();
			)
			
			if (outliner_callbacks != undefined) do
				outliner_callbacks.removeCallbacks();
				
			if (outliner_sceneFunctions != undefined) do
				outliner_sceneFunctions.disposeFunctionCache();
				
			removeKbdFileWatch();
			
			(dotnetClass "System.GC").Collect();
			gc light:true;
		)
		catch 
		(
			fileIn "crash_report.ms";
			outliner_crash_report.handle_exception();
		)
	),
	
	
	/**
	 * Initialize Outliner.
	 */
	public function init = 
	(
		local success = true;
		
		try
		(
			CreateDialog outliner_initializing 150 40 style:#(#style_toolwindow);;
			
			try
			(
				outlinerHelperFunctions.loadDotNetAssembly dir "Outliner.dll";
			)
			catch
			(
				try ( destroyDialog outliner_initializing; ) catch ()
				print (getCurrentException());
				messageBox "Loading Outliner core failed.\n\nTip: make sure you have the latest .NET Framework installed.\nPlease see the Maxscript Listener (F11) for details." title:"Error";
				return false;
			)
			
			ui = outlinerUI();
			outliner_sceneFunctions = OutlinerSceneFunctions();
			
			prefs = outlinerPreferences();
			prefs.iniFile = (GetDir #userScripts) + "/outliner_prefs.ini";
			prefs.entries = outlinerPreferences.createPreferenceEntries();
			prefs.loadPreferences();
			
			product_info = outlinerPreferences();
			product_info.iniFile = (GetDir #userScripts) + "/outliner_product_info.ini";
			product_info.entries = outlinerPreferences.createProductEntries();
			product_info.loadPreferences();
			
			
			outliner_update.checkUpdateAuto();
		)
		catch
		(
			fileIn "crash_report.ms";
			outliner_crash_report.handle_exception();
			
			success = false;
		)
		
		
		try ( destroyDialog outliner_initializing; ) catch ()
		
		success;
	),





	/**
	 * Destroy outliner structs and objects
	 */
	public function disposeFunctionCache =
	(
	),
	
	public function dispose =
	(
	)
)