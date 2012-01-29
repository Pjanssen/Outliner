struct outlinerCore
(
maxV           = (maxVersion())[1] / 1000,
dir            = pathConfig.appendPath (GetDir #userScripts) "outliner\\",
prefs,
product_info,
ui,

tree,
kbdFile,




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
   tree_Scene_AddObjectFn     = tree.Scene.AddObject;
   tree_Scene_AddLayerFn      = tree.Scene.AddLayer;
   tree_Scene_AddMaterialFn   = tree.Scene.AddMaterial;
   tree_setObjectLayerFn      = tree.SetObjectLayer;
   tree_setLayerActiveFn      = tree.SetLayerActive;
   tree_setLayerParentFn      = tree.SetLayerParent;
   tree_GetSelectedNodeHandles = tree.GetSelectedNodeHandles;
),


--Add an object to the Scene in the treeview. 
--(doesn't add it to the tree nodes itself though!)
function addObjectToTree o layerHandle: =
(
   if (isValidNode o) do
   (
      if (layerHandle == unsupplied) do
         layerHandle = GetHandleByAnim o.layer.layerAsRefTarg;
         
      local parentHandle = if (o.parent != undefined) then (GetHandleByAnim o.parent) else -1;
      local matHandle = if (o.material != undefined) then (GetHandleByAnim o.material) else -1;
      tree_Scene_AddObjectFn (GetHandleByAnim o) \
                             parentHandle \
                             layerHandle \
                             matHandle \
                             o.name \
                             (getClassName o) \
                             ((superclassof o) as string) \
                             (isGroupHead o) \
                             (isGroupMember o) \
                             o.isNodeHidden \
                             o.isNodeFrozen \
                             o.boxMode;
   )
),


--Add a layer to the Scene in the treeview. 
--(doesn't add it to the tree nodes itself though!)
function addLayerToTree layer layerHandle: = 
(
   if (layerHandle == unsupplied) do
      layerHandle = GetHandleByAnim layer.layerAsRefTarg;
      
   local parentLayer = outlinerNestedLayers.getParent layer;
   local parentHandle = if (parentLayer != undefined) then (GetHandleByAnim parentLayer) else -1;
      
   tree_Scene_AddLayerFn layerHandle \
                         parentHandle \
                         layer.name \
                         layer.current \
                         layer.isHidden \
                         layer.isFrozen \
                         layer.boxMode;
),


function addMaterialToTree mat parentHandle =
(
   tree_Scene_AddMaterialFn (GetHandleByAnim mat) \
                            parentHandle mat.name \
                            (getClassName mat);
   
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
   for mat in scenematerials where ((superclassof mat) == material) do
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
      if ((prefs.getValue #Tree #listMode) == "Material" OR \
          (prefs.getValue #Tree #sortMode) == "Material") do
         pushMaterialsToTree();
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),


--Completely refreshes the .NET scene definition and re-fills the treeview.
function refresh =
(
   if (outliner_status != undefined AND outliner_status.windowOpen) do
   (
      pushSceneToTree();
      tree.FillTree();
   
      if (outliner_callbacks != undefined) do
         outliner_callbacks.selectionChanged #selectionChanged #();
   )
   OK;
),



function switchListMode listMode =
(
   try
   (
      local listModeEnum = parseDotNetEnum "Outliner.OutlinerListMode" listMode;
      if (tree.ListMode != listModeEnum) do
      (
         if (listMode == "Layer" OR (prefs.getValue #Tree #sortMode) == "Layer") then
            outliner_callbacks.createLayerChangeHandlers();
         else
            outliner_callbacks.removeLayerChangeHandlers();
            
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
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),


function getSortMode =
(
   prefs.getValue #Tree #sortMode;
),

function switchSortMode sortMode =
(
   try
   (
      outliner.prefs.setValue #Tree #sortmode sortMode;
      
      if ((prefs.getValue #Tree #listMode) == "Layer" OR sortMode == "Layer") then
         outliner_callbacks.createLayerChangeHandlers();
      else
         outliner_callbacks.removeLayerChangeHandlers();
         
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
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),



function getFilterEnabled =
(
   prefs.getValue #Tree #objFilterEnabled;
),

function setFilterEnabled enabled =
(
   prefs.setValue #Tree #objFilterEnabled enabled;
   
   outliner_main.setHideByCategory();
   
   outliner_main.filter_enabled.checked = enabled;
   tree.Filter.Enabled = enabled;
   tree.FillTree();
),

function getObjectFilter i =
(
   (prefs.getValue #Tree #objFilter)[i];
),

function setObjectFilter i enabled =
(
   (outliner.prefs.getValue #Tree #objFilter)[i] = enabled;
   
   if (getFilterEnabled()) do
   (
      local filter_enum = #(&tree.Filter.showGeometry, &tree.Filter.showShapes, 
                            &tree.Filter.showLights,   &tree.Filter.showCameras,
                            &tree.Filter.showHelpers,  &tree.Filter.showSpaceWarps, 
                            &tree.Filter.showBones,    &tree.Filter.showParticles,
                            &tree.Filter.showXRefs,    &tree.Filter.showGroups,
                            &tree.Filter.showHidden,   &tree.Filter.showFrozen);

      *filter_enum[i] = enabled;
      outliner.tree.FillTree();
      
      if (outliner.prefs.getValue #Tree #objFilterAffectVpt) do
         outliner_main.setHideByCategory();
   )
   
   outliner.prefs.savePreferences();
),



/**
 * HANDLE AUTOMATIC GROUP OPENING/CLOSING
 *
 * This function will open any groups containing nodes from the passed selnodes 
 * array. It will also close any groups opened previously that no longer need 
 * to remain opened.
 */
openGroupHeads = #{},
function handleGroupOpeningClosing selnodes selectedInOutliner =
(
   try
   (
      -- New bitarray containing all groupheads that should be opened.
      local newOpenGroupHeads = #{};

      for n in selNodes do
      (
         if (isValidNode n) do
         (
            if (isGroupMember n) do
            (
               --Find any groupheads that have to be opened. 
               --Groups can be nested, so loop until root is reached.
               local n_parent = n.parent;
               while (isValidNode n_parent) do
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

      -- Close groups that should node longer be opened.
      local groupHeadsToClose = openGroupHeads - newOpenGroupHeads;
      for groupHandle in groupHeadsToClose do
      (
         local groupHead = GetAnimByHandle groupHandle;
         if (isValidNode groupHead AND isGroupHead groupHead) do 
            setGroupOpen groupHead false;
      )

      openGroupHeads = newOpenGroupHeads;
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),












/**
 * HELPER FUNCTIONS
 */

function createNewLayer parentLayer =
(
   local layer = (LayerManager.NewLayer()).layerAsRefTarg;
   --Set new layer's parent. 
   --(either clicked layer or layer of clicked node).
   if (parentLayer != undefined) do
      outlinerNestedLayers.setParent layer parentLayer;
      
   --Set layer active.
   if (prefs.getValue #Tree #setNewLayerActive) do
      outliner.setActiveLayer layer;
   
   --Edit name of new layer.
   if (prefs.getValue #Tree #editNewLayerName) do
      outliner.tree.EditNodeName (GetHandleByAnim layer);
),


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
         local msg = "Delete objects on layer " + layer.name + " too?\n" + \
                     "If you choose 'no', the objects will be moved to layer 0."
         result = yesNoCancelBox msg title:"Delete objects on layer?";
         
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
      fileIn "crash_report.ms";
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
      fileIn "crash_report.ms";
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
      fileIn "crash_report.ms";
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
      fileIn "crash_report.ms";
   )
),

function setPropertyOnSelection prop value includeObjects:false \
                                           includeLayers:false \
                                           includeMaterials:false =
(
   try
   (
      local nodeHandles = tree_GetSelectedNodeHandles includeObjects \
                                                      includeLayers \
                                                      includeMaterials;
      for handle in nodeHandles do
      (
         local n = GetAnimByHandle handle;
         if (n != undefined) do
         (
            if (isKindOf n Node AND (isProperty n prop)) then
               setProperty n prop value;
            else if (isKindOf n Base_Layer AND (isProperty n prop)) then
            (
               setProperty n prop value;
               setProperty (outlinerNestedLayers.getChildren n recursive:true) \
                           prop value;
            )
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
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
               
               --Remove the node from the tree if it has no scene representation.
               --This should never happen, but apparently sometimes it does...
               if (n == undefined OR isDeleted n) then
                  tree.DeleteObject handle;
               --Otherwise, delete the node or layer from the scene.
               else
               (
                  if (isValidNode n) then
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
      fileIn "crash_report.ms";
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
                     outlinerNestedLayers.setLayerProperty n #isHidden hide;
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
                     outlinerNestedLayers.setLayerProperty n #isFrozen freeze;
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
      fileIn "crash_report.ms";
   )
),



function moveObjectToLayer obj targetLayer =
(
   targetLayer.addNode obj;
   outliner_callbacks.nodeLayerChangedIntern obj targetLayer;
   
   --Also move dependencies in case of a PFSource 
   --(in particular PFEngine, which affects visibility of actual particles).
   if ((classof obj) == PF_Source) do
   (
      local depNodes = refs.dependentNodes obj;
      for d in depNodes do
         targetLayer.addNode d;
   )
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
                        outlinerNestedLayers.setParent n targetLayer;
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
      fileIn "crash_report.ms";
   )
),


function addSelectionToNewLayer =
(
   try
   (
      local newLayer;
      undo "Create new layer" on
      (
         newLayer = LayerManager.newLayer();
      )
      
      if (newLayer != undefined) do
      (
         newLayer = newLayer.layerAsRefTarg;
         moveSelectionToLayer newLayer;

         if (outliner.prefs.getValue #Tree #editNewLayerName) do
            outliner.tree.EditNodeName (GetHandleByAnim newLayer);
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),

function addSelectionToNewContainer =
(
   try
   (
      local sel = getCurrentSelection();
      if (sel.count > 0) do
      (
         local c = Containers.CreateContainer sel;
         
         if (isValidNode c) do
         (
            if (outliner.prefs.getValue #Tree #editNewLayerName) do
               outliner.tree.EditNodeName (GetHandleByAnim c);
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),

function addSelectionToNewGroup =
(
   try 
   (
      local sel = getCurrentSelection();
      if (sel.count > 0) do
      (
         local g = group sel;
         
         if (isValidNode g) do
         (
            if (outliner.prefs.getValue #Tree #editNewLayerName) do
               outliner.tree.EditNodeName (GetHandleByAnim g);
         )
      )
   )
   catch
   (
      fileIn "crash_report.ms";
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
   
   local iniFile = pathConfig.appendPath (GetDir #userScripts) "outliner_user_colors.ini";
   if (not (hasINISetting iniFile schemeName)) do
   (
      iniFile = pathConfig.appendPath dir "colorSchemes.ini";
      if (not (hasINISetting iniFile schemeName)) do
      (
         messageBox ("Color scheme '" + schemeName + "' not found.")
         setTreeColorScheme ""
      )
   )      
   
   local colors = getINISetting iniFile schemeName;
   local colorClass = dotNetClass "System.Drawing.Color";
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
   
   local windowColor = (colorman.getcolor #window) * 255;
   local textColor = (colorman.getcolor #windowtext) * 255;
   outliner_main.searchField.BackColor = (dotNetClass "System.Drawing.Color").FromARGB 255 windowColor[1] windowColor[2] windowColor[3];
   outliner_main.searchField.ForeColor = (dotNetClass "System.Drawing.Color").FromARGB 255 textColor[1] textColor[2] textColor[3];
),






/**
 * Key Up handling (running actions while focus is on tree).
 */
function handleKeyUp e =
(
   try
   (
      if (kbdFile != undefined) do
      (
         kbdFile.MaxExecuteAction e.KeyData;
         setFocus tree;
      )
   ) catch ()
),


/**
 * FILE WATCH (KEYBOARDFILE)
 */

--The .NET FileSystemWatcher object.
kbdFileWatch,

--Handle the Changed event.
function fileWatch_Changed sender e =
(
   try
   (
      --Disable further events until handling is completed. 
      --(Multiple Changed events are fired, we only need to handle one).
      sender.EnableRaisingEvents = false;
      
      if (sender.MXSObject != undefined AND sender.MXSObject.value != undefined) do
         sender.MXSObject.value.Read();
      
      sender.EnableRaisingEvents = true;
   ) catch ()
),

--actionMan.getKeyboardFile sometimes returns a path with a double backslash at 
--the end, .NET doesn't like that.
function stripTrailingSlashes str =
(
   local n = str.count;
   while (n > 0 AND str[n] == "\\") do n -= 1;
   substring str 1 (n + 1);
),


--Adds the filesystemwatch changed event.
--MAKE SURE YOU CALL REMOVEKBDFILEWATCH() WHEN THE KEYACTIONSFILE OBJECT 
--IS NO LONGER USED!
function addKbdFileWatch =
(
   if (kbdFile != undefined) do
   (
      if (doesFileExist kbdFile.File) do
      (
         kbdFileWatch = dotnetObject "Outliner.MXSFileWatcher";
         kbdFileWatch.MXSObject = dotNetMXSValue kbdFile;
         kbdFileWatch.WatchFileChange(kbdFile.file);
   
         dotNet.addEventHandler kbdFileWatch "Changed" fileWatch_Changed;
      )
   )
),

function removeKbdFileWatch =
(
   if (kbdFileWatch != undefined) do
   (
      dotNet.removeEventHandlers kbdFileWatch "Changed";
      kbdFileWatch.MXSObject = undefined;
      kbdFileWatch = undefined;
      (dotnetclass "System.GC").Collect();
   )
),


--Returns the currently active kbd file if it can be written to,
--otherwise it saves a new config file in the userUI dir.
function getActiveKbdFile =
(
   local configFile = actionMan.getKeyboardFile();
   if (not (getFileSecurityInfo configFile #write)) do
   (
      userUIDir = pathConfig.removePathLeaf (GetDir #userIcons);
      configFile = pathConfig.appendPath userUIDir (filenameFromPath configFile);
   )
   
   actionMan.saveKeyboardFile configFile;
   
   configFile;
),


function loadKbdFile =
(
   local kbdFileClass = dotnetClass "ScriptCenter.Max.KbdFile";
   
   try (
      kbdFile = dotnetObject "ScriptCenter.Max.KbdFile" (getActiveKbdFile());
      addKbdFileWatch();
   ) catch (
      format "** Outliner exception **\n%\n" (getCurrentException());
      messageBox ("An error occured while trying to load keyboard shortcuts.\n" \
                  + "See the maxscript listener (F11) for details.\n" \
                  + "\nContact me through http://outliner.threesixty.nl if the problem persists.") \
                 title:"Failed to load shortcuts";
      kbdFile = dotnetObject "ScriptCenter.Max.KbdFile";
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
   
   try
   (
      CreateDialog outliner_initializing 150 40 style:#(#style_toolwindow);
      
      try
      (
         loadAssembly "Outliner.dll";
         loadAssembly "ScriptCenter.Max.dll";
      )
      catch
      (
         print (getCurrentException());
         messageBox ("Loading Outliner core failed.\n\n" + \
            "Tip: make sure you have the latest .NET Framework installed.\n" + \
            "Please see the Maxscript Listener (F11) for details.") title:"Error";
            
         destroyDialog outliner_initializing;
         
         return false;
      )
      
      prefs = outlinerPreferences();
      prefs.iniFile = (GetDir #userScripts) + "/outliner_prefs.ini";
      prefs.entries = outlinerPreferences.createPreferenceEntries();
      prefs.loadPreferences();
      
      product_info = outlinerPreferences();
      product_info.iniFile = (GetDir #userScripts) + "/outliner_product_info.ini";
      product_info.entries = outlinerPreferences.createProductEntries();
      product_info.loadPreferences();
         
      ui = outlinerUI();
      
      --Check for updates.
      outliner_update.checkUpdateAuto();
      
      --Convert nested layers for <2.1 nested layers.
      outliner_convertLegacyNestedLayers();
   )
   catch
   (
      fileIn "crash_report.ms";
      
      success = false;
   )
   
   
   try ( destroyDialog outliner_initializing; ) catch ()
   
   success;
),





/**
 * Destroy outliner structs and objects
 */
function disposeFunctionCache =
(
   tree                          = undefined;
   tree_Scene_AddObjectFn        = undefined;
   tree_Scene_AddLayerFn         = undefined;
   tree_Scene_AddMaterialFn      = undefined;
   tree_setObjectLayerFn         = undefined;
   tree_setLayerActiveFn         = undefined;
   tree_setLayerParentFn         = undefined;
   tree_GetSelectedNodeHandles   = undefined;
   (dotnetClass "System.GC").Collect();
),

function dispose =
(
   outliner_main           = undefined;
   outliner_sortmode       = undefined;
   outliner_options        = undefined;
   outliner_filter_config  = undefined;
   outliner_initializing   = undefined;
   outlinerUI              = undefined;

   callbacks.removeScripts id:#outliner;     
   outliner_callbacks      = undefined;
   outlinerCallbacks       = undefined;

   outlinerPrefsEntry      = undefined;
   outlinerPreferences     = undefined;
   outliner_status         = undefined;
   outlinerStatus          = undefined;

   if (outliner_update != undefined) do
   (
      outliner_update.dispose();
      outliner_update = undefined;
   )
   
   outliner     = undefined;
   outlinerCore = undefined;
)

)--End struct.