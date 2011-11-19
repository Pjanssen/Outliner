struct outlinerStatus 
(
   windowOpen,
   optionsOpen,
   filterConfigOpen,
   sortModeOpen,
   closingOutliner,
   
   selectedInOutliner,
   hiddenInOutliner,
   frozenInOutliner,
   renamedInOutliner,
   linkedInOutliner,
   layerChangedInOutliner,
   matChangedInOutliner,
   
   expandedNodeHandles,
   
   --This function will set all status variables to their initial value.
   --ExpandedNodeHandles will not be reset!
   function reset =
   (
      windowOpen = optionsOpen = filterConfigOpen = sortModeOpen = false;
      closingOutliner = selectedInOutliner = hiddenInOutliner = false;
      frozenInOutliner = renamedInOutliner = linkedInOutliner = false;
      layerChangedInOutliner = matChangedInOutliner = false;
   ),
   
   init = reset();
)--End struct.


rollout outliner_initializing "Outliner"
(
   label init_lbl "Initializing Outliner..." offset:[0, 8] align:#center;
)


struct outlinerUI 
(

mainMinWidth = 170,
mainMinHeight = 200,

function usingMaxDarkScheme =
(
   local windowColor = (colorman.getcolor #window) * 255;
   (windowColor[1] < 120 AND windowColor[2] < 120 AND windowColor[3] < 120)
),


/**
 * OPEN OUTLINER WINDOW
 */
function openOutliner = 
(
   try
   (
      if (outliner_status != undefined AND outliner_status.windowOpen \
                                       AND outliner != undefined) do 
         outliner.close();
      
      if (outliner_status == undefined) then
         outliner_status = outlinerStatus();
      else
         outliner_status.reset();

      --Create keyboard actions object.
      outliner.loadKbdFile();
      
      --Load window preferences.
      local prefs_getValueFn = outliner.prefs.getValue;
      local posx     = prefs_getValueFn #Window #posx;
      local posy     = prefs_getValueFn #Window #posy;
      local width    = prefs_getValueFn #Window #width;
      local height   = prefs_getValueFn #Window #height;
      local dockFlag = prefs_getValueFn #Window #dockFlag;
      
      --Make sure the main window position is within the screen bounds.
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
      
      --Create main window.
      CreateDialog outliner_main width \
                                 height \
                                 pos:[posx, posy] \
                                 style:#(#style_toolwindow, #style_sysmenu, #style_resizing);   

      cui.RegisterDialogBar outliner_main \
                            minSize:[mainMinWidth, mainMinHeight] \
                            maxSize:[-1,10000] \
                            style:#(#cui_dock_vert, #cui_floatable, #cui_handles);
                            
      if (dockFlag != #cui_floatable) do cui.DockDialogBar outliner_main dockFlag;


      --Create callbacks object (global), register callbacks and 
      --emulate selection changed event.
      outliner_callbacks = outlinerCallbacks();
      outliner_callbacks.createCallbacks();
      
      local listMode = prefs_getValueFn #Tree #listMode;
      local sortMode = prefs_getValueFn #Tree #sortMode;
      
      if (listMode == "Layer" OR sortMode == "Layer") then
         outliner_callbacks.createLayerChangeHandlers();
      else if (listMode == "Material" OR sortMode == "Material") then
         outliner_callbacks.createMaterialChangeHandlers();

      outliner_status.windowOpen = true;
      updateToolbarButtons();
      
      --Fill the tree.
      outliner.refresh();
      
      if (outliner_status.expandedNodeHandles != undefined) do
         outliner.tree.ExpandedNodeHandles = outliner_status.expandedNodeHandles;

      
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
function closeOutliner = 
(
   outliner_status.closingOutliner = true;
   
   outliner_status.expandedNodeHandles = outliner.tree.ExpandedNodeHandles;
   
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

   
   outliner.removeKbdFileWatch();
   if (outliner_callbacks != undefined) do
      outliner_callbacks.removeCallbacks();
   
   --outliner.dispose();
   outliner.disposeFunctionCache();
   
   gc light:true;
   
   outliner_status.windowOpen = false;
   updateToolbarButtons();
),






function openFilterConfigWindow =
(
   try
   (
      if (outliner_status != undefined AND outliner_status.windowOpen) do
      (
         if (outliner_status.filterConfigOpen) do
            destroyDialog outliner_filter_config;

         local width = 194;
         local height = 55;
         local dialog_pos = GetDialogPos outliner_main;
         local posx = dialog_pos.x + outliner_main.filter_enabled.pos.x - 69;
         local posy = dialog_pos.y + outliner_main.filter_enabled.pos.y - height - 30;
         CreateDialog outliner_filter_config width \
                                             height \
                                             pos:[posx, posy] \
                                             style:#(#style_sysmenu, #style_toolwindow);
            
         outliner_status.filterConfigOpen = true;
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),


function openSortModeWindow =
(
   try
   (
      if (outliner_status != undefined AND outliner_status.windowOpen) do
      (
         if (outliner_status.sortModeOpen) do
            destroyDialog outliner_sortmode;

         local width = 156;
         local height = 31;
         local dialog_pos = GetDialogPos outliner_main;
         local posx = dialog_pos.x + outliner_main.sortmode_btn.pos.x;
         local posy = dialog_pos.y + outliner_main.sortmode_btn.pos.y - height - 30;
         CreateDialog outliner_sortmode width \
                                        height \
                                        pos:[posx, posy] \
                                        style:#(#style_sysmenu, #style_toolwindow);
            
         outliner_status.sortModeOpen = true;
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),




function openOptionsWindow = 
(
   try
   (
      if (outliner_status != undefined AND outliner_status.windowOpen) do
      (
         if (outliner_status.optionsOpen) then
            setFocus outliner_options;
         else 
         (
            CreateDialog outliner_options 320 \
                                          515 \
                                          style:#(#style_toolwindow, #style_sysmenu);
                                          
            outliner_status.optionsOpen = true;
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),


function openLayerProperties layers =
(
   try
   (
      CreateDialog outliner_layerprops 390 480;
      outliner_layerprops.setlayers layers;
   )
   catch
   (
      fileIn "crash_report.ms";
   )
)

)--End struct.