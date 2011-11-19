struct outlinerStatus 
(
	public windowOpen,
	public optionsOpen,
	public filterConfigOpen,
	public sortModeOpen,
	public closingOutliner,
	
	public lastTreeAction,
	public expandedNodeHandles,
	
	--This function will set all status variables to their initial value.
	--ExpandedNodeHandles will not be reset!
	public function reset =
	(
		windowOpen = optionsOpen = filterConfigOpen = sortModeOpen = closingOutliner = false;
		rightClickedNode = undefined;
	),
	
	private init = reset();
)


rollout outliner_initializing "Outliner"
(
	label init_lbl "Initializing Outliner..." offset:[0, 8] align:#center;
)


struct outlinerUI 
(
	public mainMinWidth = 170,
	public mainMinHeight = 200,

	

	
	/**
	 * OPEN OUTLINER WINDOW
	 */
	public function openOutliner = 
	(
		try
		(
			if (outliner_status != undefined AND outliner_status.windowOpen AND outliner != undefined) do 
				outliner.close();
			
			if (outliner_status == undefined) then
				outliner_status = outlinerStatus();
			else
				outliner_status.reset();
	
			
			
			local prefs_getValueFn = outliner.prefs.getValue;
			
			local posx		= prefs_getValueFn #Window #posx;
			local posy		= prefs_getValueFn #Window #posy;
			local width		= prefs_getValueFn #Window #width;
			local height	= prefs_getValueFn #Window #height;
			local dockFlag	= prefs_getValueFn #Window #dockFlag;
			
			if (posx > sysInfo.DesktopSize[1]) do 
			(
				posx = (outliner.prefs.getEntry #Window #posx).default;
				outliner.prefs.setValue #Window #posx posx;
			)
			if (posy > sysInfo.DesktopSize[2]) do 
			(
				posy = (outliner.prefs.getEntry #Window #posy).default;
				outliner.prefs.setValue #Window #posy posy;
			)
			
			CreateDialog outliner_main width height pos:[posx, posy - 2] style:#(#style_toolwindow, #style_sysmenu, #style_resizing);	
			cui.RegisterDialogBar outliner_main minSize:[mainMinWidth, mainMinHeight] maxSize:[-1,-1] style:#(#cui_dock_vert, #cui_floatable);
			if (dockFlag != #cui_floatable) do cui.DockDialogBar outliner_main dockFlag;
	
			
			/*
			if (outliner_status.expandedNodeHandles != undefined) do
				outliner.tree.ExpandedNodeHandles = outliner_status.expandedNodeHandles;
	
			
			
			local listMode = prefs_getValueFn #Tree #listMode;
			local sortMode = prefs_getValueFn #Tree #sortMode;
			
			if (listMode == "Layer" OR sortMode == "Layer") then
				outliner_main.refreshLayerNamesTimer.active = true;
			else if (listMode == "Material" OR sortMode == "Material") then
				outliner_callbacks.createMaterialChangeHandlers();
	
			outliner_callbacks.selectionChanged();
			*/
			
			outliner_status.windowOpen = true;
			updateToolbarButtons();
			
			setFocus outliner_main.searchField;
		)
		catch
		(
			fileIn "crash_report.ms";
		)
	),
	
	
	
	
	/**
	 * CLOSE OUTLINER WINDOW
	 */
	public function closeOutliner = 
	(
		outliner_status.closingOutliner = true;
		
		--outliner_status.expandedNodeHandles = outliner.tree.ExpandedNodeHandles;
		
		if (outliner_main.dialogBar) do
		(
			outliner.prefs.setValue #Window #dockFlag (cui.getDockState outliner_main) write:false;
			cui.UnRegisterDialogBar outliner_main;
		)
		outliner.prefs.savePreferences();
		
		try ( destroyDialog outliner_main; ) catch ()
		try ( destroyDialog outliner_options; ) catch ()
		try ( destroyDialog outliner_sortmode; ) catch ()
		try ( destroyDialog outliner_filter_config; ) catch ()
		try ( destroyDialog outliner_update_rollout; ) catch ()
		
		outliner_status.windowOpen = false;
		updateToolbarButtons();
	),
	
	
	
	
	
	
	public function openFilterConfigWindow =
	(
		try
		(
			if (outliner_filter_config == undefined) do
				fileIn "ui/filter_config.ms";
				
			if (outliner_status != undefined AND outliner_status.windowOpen) do
			(
				if (outliner_status.filterConfigOpen) do
					destroyDialog outliner_filter_config;
	
				local width = 194;
				local height = 55;
				local dialog_pos = GetDialogPos outliner_main;
				local posx = dialog_pos.x + outliner_main.filter_enabled.pos.x - 69;
				local posy = dialog_pos.y + outliner_main.filter_enabled.pos.y - height - 30;
				CreateDialog outliner_filter_config width height pos:[posx, posy] style:#(#style_sysmenu, #style_toolwindow);
					
				outliner_status.filterConfigOpen = true;
			)
		)
		catch
		(
			fileIn "crash_report.ms";
		)
	),
	
	
	public function openSortModeWindow =
	(
		try
		(
			if (outliner_sortmode == undefined) do
				fileIn "ui/sortmode.ms";
				
			if (outliner_status != undefined AND outliner_status.windowOpen) do
			(
				if (outliner_status.sortModeOpen) do
					destroyDialog outliner_sortmode;
	
				local width = 156;
				local height = 31;
				local dialog_pos = GetDialogPos outliner_main;
				local posx = dialog_pos.x + outliner_main.sortmode_btn.pos.x;
				local posy = dialog_pos.y + outliner_main.sortmode_btn.pos.y - height - 30;
				CreateDialog outliner_sortmode width height pos:[posx, posy] style:#(#style_sysmenu, #style_toolwindow);
					
				outliner_status.sortModeOpen = true;
			)
		)
		catch
		(
			fileIn "crash_report.ms";
		)
	),
	
	
	
	
	public function openOptionsWindow = 
	(
		try
		(
			if (outliner_options == undefined) do
				fileIn "ui/options.ms";
			
			if (outliner_status != undefined AND outliner_status.windowOpen) do
			(
				if (outliner_status.optionsOpen) then
					setFocus outliner_options;
				else 
				(
					local dialog_pos = GetDialogPos outliner_main;
					CreateDialog outliner_options 320 515 style:#(#style_toolwindow, #style_sysmenu);
					outliner_status.optionsOpen = true;
				)
			)
		)
		catch
		(
			fileIn "crash_report.ms";
		)
	),
	
	
	public function openLayerProperties layers =
	(
		try
		(
			if (outliner_layerprops == undefined) do
				fileIn "ui/layer_properties.ms";
			
			CreateDialog outliner_layerprops 390 480;
			outliner_layerprops.setlayers layers;
		)
		catch
		(
			fileIn "crash_report.ms";
		)
	),
	
	
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
	
	function createTreeViewColors =
	(
		local treeViewColors = dotNetObject "Outliner.Controls.TreeViewColors";
		local iniFile = outliner.dir + "colorSchemes.ini";
		local invIcons = outliner.prefs.getValue #Visual #invertIcons;
		local colorScheme = outliner.prefs.getValue #Visual #colorscheme;
		/*
		if (colorScheme == "") do
		(
			if (ui.usingMaxDarkScheme()) then
			(
				colorScheme = "Dark";
				invIcons = true;
			)
			else
			(
				colorScheme = "Light";
				invIcons = false;
			)
				
			prefs.setValue #Visual #colorScheme colorScheme;
			prefs.setValue #Visual #invertIcons invIcons;
		)
		*/
		--tree.InvertIcons = invIcons;
		
		local colorClass = dotNetClass "System.Drawing.Color";
		local colors = getINISetting iniFile colorScheme;
		
		for i in colors do 
		(
			local color = getColorFromStr (getINISetting iniFile colorScheme i);
			setproperty treeViewColors i (colorClass.FromARGB color.r color.g color.b);
		)
		
		treeViewColors;
	)
)