global outlinerInstaller;
global outliner_restart_required;

--Re-init update.ms to work around update bug in 2.1 (outlinerInstaller is undefined).
try ( fileIn ((GetDir #userScripts) + "/outliner/update.ms"); ) catch ()

rollout outliner_install ""
(
   edittext progress_txt height:200 readonly:true width:278 align:#center offset:[-1, 0];
   progressbar progress_bar value:0 width:273 align:#center;
   button close_btn "Close" enabled:false width:273 align:#center    
   on close_btn pressed do
      destroyDialog outliner_install;
)

struct outliner_installer (


--Directories and files.
private tempDir              = (GetDir #temp) + "/outliner",
private strings_file         = tempDir + "/installer/strings.ini",
private installer_data_file  = tempDir + "/installer/installer_data.ini",
private userUIDir            = pathConfig.removePathLeaf (GetDir #userIcons),
private userScriptDir        = (GetDir #userScripts) + "/outliner",
private userStartupScriptDir = (GetDir #userStartupScripts) + "/outliner",
private userIconsDir         = (GetDir #userIcons),
private prefs_file           = (GetDir #userScripts) + "/outliner_prefs.ini",
private product_info_file    = (GetDir #userScripts) + "/outliner_product_info.ini",



--Retrieves the string from the strings ini file.
public function getString key section:#Strings = 
(
   local str;
   if (section != undefined AND key != undefined) do
      str = getINISetting strings_file section key;
   
   if (str == undefined) do 
   (
      print ("Outliner installer: cannot find string " + key + " in section " + section);
      str = "";
   )
   
   --Replace escaped newline characters and return result.
   substituteString str "\\n" "\n";
),


--Returns the version of this installer.
public function getVersion asString:false =
(
   if (not asString) then
      (getINISetting installer_data_file #Version #version) as float;
   else
      getINISetting installer_data_file #Version #versionString
),



--Returns the version of the currently installed Outliner.
public function getInstalledVersion =
(
   local v = 0.0;
   if (hasINISetting product_info_file #General #version) then
      v = (getINISetting product_info_file #General #version) as float;
   else if (hasINISetting prefs_file #General #version) then
      v = (getINISetting product_info_file #General #version) as float;
   
   v;
),


--Returns true if the Outliner is installed for this 3dsmax installation.
public function getIsOutlinerInstalled =
(
   (getINISetting product_info_file #General #outlinerInstalled) == "true";
),

private function setIsOutlinerInstalled i =
(
   setINISetting product_info_file #General #outlinerInstalled (i as string);
),


--Returns true if the Workflow Tools are installed for this 3dsmax installation.
public function getIsWorkflowToolsInstalled =
(
   (getINISetting product_info_file #General #workflowtoolsinstalled) == "true";
),

private function setIsWorkflowToolsInstalled i =
(
   setINISetting product_info_file #General #workflowtoolsinstalled (i as string);
),


--Load an assembly with shadow-copy enabled.
private function loadAssembly dll =
(
   local AppDomain    = dotNetClass "System.AppDomain";
   local AssemblyName = dotNetClass "System.Reflection.AssemblyName";

   AppDomain.CurrentDomain.SetShadowCopyPath (GetDir #temp);
   AppDomain.CurrentDomain.SetShadowCopyFiles();

   local assemblyName = AssemblyName.GetAssemblyName dll;
   AppDomain.CurrentDomain.Load assemblyName;
),


--Closes the Outliner if it's still opened.
private function closeOutliner =
(
   try ( outliner.ui.closeOutliner(); ) catch ()
   try ( outliner.destroy(); ) catch ()
   global outliner = undefined;
),


--Prints an exception message to the maxscript listener.
private function printException executingFn exception =
(
   format "** Outliner installer exception **\n%\n%\n" executingFn exception;
),


--Adds a post-system-shutdown callback that removes the temporary files.
public function clearTempDir =
(
   local scriptStr = ("local d = (GetDir #temp) + \"/outliner\";
      if ((dotNetClass \"System.IO.Directory\").Exists d) do 
         try ( (dotNetClass \"System.IO.Directory\").Delete d true; ) catch ()");
   
   callbacks.removeScripts #preSystemShutdown id:#outliner_installer;
   callbacks.addScript #preSystemShutdown scriptStr id:#outliner_installer;
),


private function restartRequired =
(
   (dotNetClass "Outliner.TreeView") != undefined;
),




/**
 * UNINSTALL FUNCTIONS
 */
private function removeScriptFiles =
(
   local success = true;
   
   closeOutliner();
   
   local System_IO_Directory = dotNetClass "System.IO.Directory";
   
   --Delete all script files (old and current).
   local oldOutlinerDirs = #(((GetDir #startupScripts) + "/outliner"), 
                       ((GetDir #startupScripts) + "/grin_tools/outliner"), 
                       ((GetDir #Scripts) + "/outliner"), 
                       ((GetDir #maxroot) + "/stdplugs/stdscripts/outliner"),
                       ((GetDir #ui) + "/macroscripts/outliner"),
                       ((GetDir #userMacros) + "/outliner"),
                       userScriptDir,
                       userStartupScriptDir
                      );
   for d in oldOutlinerDirs where (System_IO_Directory.Exists d) do 
   (
      try (
         System_IO_Directory.Delete d true;
      ) catch 
      (
         printException "removeScriptFiles" (getCurrentException());
         success = false;
      )
   )
   
   --Delete other startup files. (in stdscripts)
   local otherStartupFiles = getFiles ((GetDir #maxroot) + "/stdplugs/stdscripts/outliner*");
   for f in otherStartupFiles do
   (
      if (not (deleteFile f)) do
         success = false;
   )
   
   --Remove icon files 
   --old location
   local iconFiles = getFiles ((GetDir #ui) + "/icons/*Outliner*");
   for ico in iconFiles do
   (
      if ((findString ico "_wftools_") == undefined) do
      (
         if (not (deleteFile ico)) do 
            success = false;
      )
   )
   --new location
   iconFiles = getFiles (userIconsDir + "/*Outliner*");
   for ico in iconFiles do
   (
      if ((findString ico "_wftools_") == undefined) do
      (
         if (not (deleteFile ico)) do 
            success = false;
      )
   )
   


   -- Remove user macros
   local userMacroDir = (GetDir #userMacros);
   local oldUserMacros = (getFiles (userMacroDir + "/*Outliner*"));
   for mcr in oldUserMacros do 
   (
      if (not (matchPattern mcr pattern:"*Outliner Workflow Tools*")) do
      (
         if (not (deleteFile mcr)) do 
            success = false;
      )
   )

   success;
),

private function removeWorkflowTools =
(
   local success = true;
   
   local System_IO_Directory = dotNetClass "System.IO.Directory";
   local oldWfToolsDir = (GetDir #userMacros) + "/outliner_workflowtools";
   if (System_IO_Directory.Exists oldWfToolsDir) do
   (
      try (
         System_IO_Directory.delete workflowtoolsDir true;
      ) catch 
      (
         printException "removeWorkflowTools" (getCurrentException());
         success = false;
      )
   )
   
   -- Remove icon files
   local iconFiles = getFiles ((GetDir #ui) + "/icons/*Outliner_wftools*");
   for ico in iconFiles do
   (
      if (not (deleteFile ico)) do 
         success = false;
   )
   iconFiles = getFiles (userIconsDir + "/*Outliner_wftools*");
   for ico in iconFiles do
   (
      if (not (deleteFile ico)) do 
         success = false;
   )


   -- Remove user macros
   local userMacroDir = (GetDir #userMacros);
   local oldUserMacros = (getFiles (userMacroDir + "/*Outliner Workflow Tools*"));
   for mcr in oldUserMacros do 
   (
      if (not (deleteFile mcr)) do success = false;
   )
   
   setIsWorkflowToolsInstalled false; 

   success;
),




private function removePreferencesFile =
(
   if (doesFileExist prefs_file) then
      deleteFile prefs_file;
   else
      true;
),



private function removeHotkeys =
(
   local success = true;
   try
   (
      local kbdFileClass = dotnetClass "ScriptCenter.Max.KbdFile";
      local kbdFile      = dotnetObject "ScriptCenter.Max.KbdFile" \
                                        (kbdFileClass.MaxGetActiveKbdFile());
      
      if ((kbdFile.RemoveAction "Outliner") > 0) do
      (
         kbdFile.Write();
         kbdFile.MaxLoadKbdFile();
      )
   )
   catch 
   (
      printException "removeHotkeys" (getCurrentException());
      success = false;
   )
   
   success;
),





/**
 * INSTALL FUNCTIONS
 */
 
--Returns true if this max version is equal to or above the required version.
private function checkMaxVersion =
(
   local reqMaxVersion = (getINISetting installer_data_file #Requirements \
                                                            #maxVersion) as float;
   ((maxVersion())[1] >= (reqMaxVersion - 1998) * 1000);
),


--Returns true if the .NET Framework 3.5 registry key could be opened.
private function checkDotNetVersion =
(
   local rKey;
   local success = registry.openkey HKEY_LOCAL_MACHINE \
                                    "SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" \
                                    key:&rKey accessright:#readonly;
   if (success) do
      registry.closeKey rKey;
   
   if (not success) do
   (
      success = registry.openkey HKEY_LOCAL_MACHINE \
                                 "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4" \
                                 key:&rKey accessright:#readonly;
      if (success) do
         registry.closeKey rKey;
   )
   
   success;
),



private function updatePreferencesFile =
(
   local oldVersion = getInstalledVersion();

   --Pre 2.0.9
   --Remove deprecated inisettings.
   if (oldVersion < 2.09) do
   (
      delINISetting prefs_file #General #matModeFirstRun;
      delINISetting prefs_file #General #product_id;
      if ((hasINISetting prefs_file #General #checkUpdatesInterval) AND 
          (getINISetting prefs_file #General #checkUpdatesInterval) == "7") do
         setINISetting prefs_file #General #checkUpdatesInterval "1";
   )

   --Pre 2.0.94
   --Move product_info inisettings to separate file.
   if (oldVersion < 2.094) do
   (
      --Copy existing entries from prefs_file to product_info_file.
      if (hasINISetting prefs_file #General #product_id_a) do 
      (
         setINISetting product_info_file \
                       #General \
                       #product_id_a \
                       (getINISetting prefs_file #General #product_id_a);
      )                 
      if (hasINISetting prefs_file #General #product_id_b) do 
      (
         setINISetting product_info_file \
                       #General \
                       #product_id_b \
                       (getINISetting prefs_file #General #product_id_b);
      )                
      if (hasINISetting prefs_file #General #workflowToolsInstalled) do 
      (
         setINISetting product_info_file \
                       #General \
                       #workflowToolsInstalled \
                       (getINISetting prefs_file #General #workflowToolsInstalled);
      )                
      if (hasINISetting prefs_file #General #crashReportEmail) do 
      (
         setINISetting product_info_file \
                       #General \
                       #crashReportEmail \
                       (getINISetting prefs_file #General #crashReportEmail);
      )
       
      --Remove old entries in prefs_file.
      delINISetting prefs_file #General #version;
      delINISetting prefs_file #General #versionString;
      delINISetting prefs_file #General #product_id_a;
      delINISetting prefs_file #General #product_id_b;
      delINISetting prefs_file #General #workflowToolsInstalled;
      delINISetting prefs_file #General #crashReportEmail;
   )
   
   --Pre 2.1
   if (oldVersion < 2.1) do
   (
      --Remove nested layer warning preference.
      delINISetting prefs_file #General #addNestedLayerMessage;
      --Update filters (shift indices 10, 11 to 11, 12).
      try (
         local filter = execute (getINISetting prefs_file #Tree #objFilter);
         if (filter[11]) then filter[12] = true;
         filter[11] = false;
         if (filter[10]) then filter[11] = true;
         filter[10] = true;
         setINISetting prefs_file #Tree #objFilter (filter as string);
      ) catch (
         delINISetting prefs_file #Tree #objFilter;
      )
   )

   
   --Generate product id's if necessary.
   if ((getINISetting product_info_file #General #product_id_a) == "" OR 
       (getINISetting product_info_file #General #product_id_b) == "") do
   (
      local class_id = genClassId returnValue:true;
      class_id[1] = bit.set class_id[1] 32 false;
      class_id[2] = bit.set class_id[2] 32 false;
      setINISetting product_info_file #General #product_id_a (class_id[1] as string);
      setINISetting product_info_file #General #product_id_b (class_id[2] as string);
   )
   
   --Write version and update settings.
   setINISetting product_info_file #General #version ((getVersion()) as string);
   setINISetting product_info_file #General #versionString (getVersion asString:true);
   setINISetting prefs_file #General #ignore_update_version "0.0";
   setINISetting prefs_file #General #lastUpdateCheck "0";
   
   true;
),



private function copyDirectory sourceDir targetDir =
(
   local Directory    = dotNetClass "System.IO.Directory";
   local SearchOption = dotNetClass "System.IO.SearchOption";
   local File         = dotNetClass "System.IO.File";
   local allFiles = Directory.GetFiles sourceDir \
                                       "*.*" \
                                       SearchOption.AllDirectories;
   
   for sourceFile in allFiles do
   (
      local targetFile = targetDir + (substring sourceFile (sourceDir.count + 1) -1);
      local targetFileDir = getFilenamePath targetFile;
      if (not (Directory.Exists targetFileDir)) do
         Directory.CreateDirectory targetFileDir;
      File.Copy sourceFile targetFile;
   )
),



private function copyScriptFiles = 
(
   local success = true;
   
   local Directory = dotNetClass "System.IO.Directory";
   local File      = dotNetClass "System.IO.File";
   
   try 
   (
      copyDirectory (tempDir + "/script") userScriptDir;
      copyDirectory (tempDir + "/startupScript") userStartupScriptDir;
      
      local iconDir = tempDir + "/script/ui/icons_";
      local windowColor = (colorman.getcolor #window) * 255;
      if (windowColor[1] < 120 AND windowColor[2] < 120 AND windowColor[3] < 120) then
         iconDir += "dark";
      else
         iconDir += "light";
         
      local iconFiles = Directory.getFiles iconDir "*.bmp";
      for ico in iconFiles do
      (
         local newIco = (userIconsDir + "/Outliner_" + (filenameFromPath ico));
         File.Move ico newIco;
      )
   )
   catch 
   (
      printException "copyScriptFiles" (getCurrentException());
      success = false;
   )
   
   success;
),




private function loadMacroScripts =
(
   local success = true;
   try
   (
      colorman.reInitIcons();
      
      local files = GetFiles (tempDir + "/macroscripts/*.mcr");
      for file in files do
         fileIn file;
   )
   catch
   (
      printException "loadMacroScripts" (getCurrentException());
      success = false;
   )
   
   success;
),


--Returns the currently active cui file if it can be written to,
--otherwise it saves a new config file in the userUI dir.
private function getActiveCuiFile =
(
   local configFile = cui.getConfigFile();
   if (not (getFileSecurityInfo configFile #write)) then
   (
      configFile = pathConfig.appendPath userUIDir (filenameFromPath configFile);
   )
   
   cui.saveConfigAs configFile;
   
   configFile;
),

private function removeToolbars =
(
   local success = true;
   
   try
   (
      local cuiFileClass = dotnetClass "ScriptCenter.Max.CuiFile";
      local cuiFile      = dotnetObject "ScriptCenter.Max.CuiFile" \
                                        (getActiveCuiFile());
      
      local removedSortTb   = cuiFile.RemoveToolbar "Outliner SortMode";
      local removedFilterTb = cuiFile.RemoveToolbar "Outliner Filters";
      
      if (removedSortTb OR removedFilterTb) do
      (
         cuiFile.Write();
         cuiFile.MaxLoadCuiFile();
      )
   )
   catch
   (
      printException "removeToolbars" (getCurrentException());
      success = false;
   )
   
   success;
),

private function createToolbars =
(
   local success = true;
   
   try
   (
      local cuiFileClass = dotnetClass "ScriptCenter.Max.CuiFile";
      local cuiFile      = dotnetobject "ScriptCenter.Max.CuiFile" \
                                        (getActiveCuiFile());
      local mcrCat = "Outliner";
      local writeCuiFile = false;

      --Sortmode toolbar.
      local tbName = "Outliner SortMode";
      local sortmodes = #("Alphabetical", "Chronological", "Layer", \
                          "Material", "Type", "Visibility");
      
      if (not cuiFile.ContainsToolbar tbName) do
      (
         local toolbar = cuiFile.AddToolbar tbName sortmodes.count 0;
         toolbar.Bounds.Y += 80;
      
         for s in sortmodes do
            toolbar.AddButton ("outliner_sortmode_" + s) mcrCat;
         
         writeCuiFile = true;
      )


      --Filter toolbar.
      tbName = "Outliner Filters";
      local filters = #("Geometry", "Shapes", "Lights", "Cameras", "Helpers", \
                        "SpaceWarps", "Bones", "Particles", "Xrefs", "Groups", \
                        "Hidden", "Frozen");
      
      if (not cuiFile.ContainsToolbar tbName) do
      (
         local toolbar = cuiFile.AddToolbar tbName (2 + filters.count) 2;
      
         toolbar.AddButton "outliner_filter_toggle" "Outliner";
         toolbar.AddSeparator();
      
         for f in filters do
            toolbar.AddButton ("outliner_filter_" + f) mcrCat;
      
         toolbar.AddSeparator();
         toolbar.AddButton "outliner_filter_affectvpt" "Outliner";
      
         writeCuiFile = true;
      )
      
      --Write and reload cui file.
      if (writeCuiFile) do 
      (
         cuiFile.Write();
         cuiFile.MaxLoadCuiFile();
      )
   )
   catch
   (
      printException "createToolbars" (getCurrentException());
      success = false;
   )
   
   success;
),




--Returns the currently active kbd file if it can be written to,
--otherwise it saves a new config file in the userUI dir.
private function getActiveKbdFile =
(
   local configFile = actionMan.getKeyboardFile();
   if (not (getFileSecurityInfo configFile #write)) do
   (
      configFile = pathConfig.appendPath userUIDir (filenameFromPath configFile);
   )
   
   actionMan.saveKeyboardFile configFile;
   
   configFile;
),
private function containsHotkeyAction macroName macroCategory =
(
   local result = false;
   try
   (
      local kbdFileClass = dotnetClass "ScriptCenter.Max.KbdFile";
      local kbdFile      = dotnetObject "ScriptCenter.Max.KbdFile" \
                                        (getActiveKbdFile());
                                        
      result = kbdFile.ContainsAction macroName macroCategory;
   )
   catch 
   (
      printException "getHotkeyAction" (getCurrentException());
   )
   
   result;
),

private function getHotkeyAction =
(
   local action;
   try
   (
      local keysClass    = dotnetClass "System.Windows.Forms.Keys";
      local kbdFileClass = dotnetClass "ScriptCenter.Max.KbdFile";
      local kbdFile      = dotnetObject "ScriptCenter.Max.KbdFile" \
                                        (getActiveKbdFile());
                                        
      action = kbdFile.GetAction keysClass.H;
   )
   catch 
   (
      printException "getHotkeyAction" (getCurrentException());
   )
   
   action;
),


private function assignHotkey = 
(
   local success = true;
   try
   (  
      local keysClass    = dotnetClass "System.Windows.Forms.Keys";
      local kbdFileClass = dotnetClass "ScriptCenter.Max.KbdFile";
      local kbdFile      = dotnetObject "ScriptCenter.Max.KbdFile" \
                                        (getActiveKbdFile());
      
      if (kbdFile.AddAction "toggleOutliner" "Outliner" keysClass.H) do
      (
         kbdFile.Write();
         kbdFile.MaxLoadKbdFile();
      )
   )
   catch
   (
      printException "assignHotkey" (getCurrentException());
      success = false;
   )
   
   success;
),





public function openInstallWindow height =
(
   try ( destroyDialog outliner_install ) catch ()
   
   createDialog outliner_install 300 \
                                 height \
                                 lockWidth:true \
                                 lockHeight:true \
                                 style:#(#style_sysmenu, #style_toolwindow)
   
   outliner_install.progress_txt.height = height - 60;
   outliner_install.progress_bar.pos.y  = height - 48;
   outliner_install.close_btn.pos.y     = height - 28;
),



private function setStatusTitle txt =
(
   if (outliner_install.open) do
      outliner_install.title = txt;
),

private function addStatusText txt newline:true progress:0 =
(
   if (outliner_install.open) do
   (
      if (newline AND outliner_install.progress_txt.text != "") do 
         txt = "\n" + txt;
      
      outliner_install.progress_txt.text += txt;
      outliner_install.progress_bar.value += progress;
   )
),



private function installation_success inst silent:false showHowToUse:false =
(
   if (not silent) do
   (
      local inst_txt = (getString #instSuccess);
      
      addStatusText "";
      addStatusText inst_txt progress:100;
      
      outliner_install.close_btn.enabled = true;
      
      if (showHowToUse) do
         inst_txt += (getString #howto);
      if (outliner_restart_required == true) do
         inst_txt += (getString #restartRequired);
      
      local mb     = dotNetClass "System.Windows.Forms.MessageBox";
      local mbBtn  = dotNetClass "System.Windows.Forms.MessageBoxButtons";
      local mbIcon = dotNetClass "System.Windows.Forms.MessageBoxIcon";
      mb.Show inst_txt \
              (getString #instSuccess)\
              mbBtn.OK \
              mbIcon.Information;
   )
),

private function uninstallation_success silent:false =
(
   if (not silent) do
   (
      addStatusText "";
      addStatusText (getString #uninstSuccess) progress:100;
      outliner_install.close_btn.enabled = true;
      
      local mb     = dotNetClass "System.Windows.Forms.MessageBox";
      local mbBtn  = dotNetClass "System.Windows.Forms.MessageBoxButtons";
      local mbIcon = dotNetClass "System.Windows.Forms.MessageBoxIcon";
      mb.Show (getString #uninstSuccessMsg) \
              (getString #uninstSuccess) \
              mbBtn.OK \
              mbIcon.Information;
   )
),

private function installation_failed inst msg silent:false =
(
   if (not silent) do
   (
      addStatusText ("\n\n" + inst + " " + (getString #failed));
      outliner_install.close_btn.enabled = true;
      messageBox msg title:(getString #error);
   )
),




/**
 * RUN UNINSTALL
 */
public function uninstall silent:false =
(
   local progressDelta = ceil (100.0 / 5); --where 5 is the number of uninstallation steps.
   
   if (not silent) do
   (
      openInstallWindow 170;
      setStatusTitle ((getString #title) + " " + (getString #uninst));
      addStatusText (getString #begUnInst);
   )
   
   
   --Remove script files.
   addStatusText (getString #remScriptFiles);
   if (removeScriptFiles()) then
      addStatusText (getString #done) newline:false progress:progressDelta;
   else
   (
      addStatusText (getString #failed) newline:false;
      installation_failed (getString #uninst) \
                          (getString #remScriptFiles section:#Error) \
                          silent:silent;
      return false;
   )
   
   
   --Remove workflow tools.
   if (getIsWorkflowToolsInstalled()) do
   (
      addStatusText (getString #remWFTools);
      if (queryBox (getString #remWFTools section:#Queries) \
                   title:(getString #remWFToolsTitle section:#Queries)) then
      (
         if (removeWorkflowTools()) then
            addStatusText (getString #done) newline:false progress:progressDelta;
         else
         (
            addStatusText (getString #failed) newline:false;
            installation_failed (getString #uninst) \
                                (getString #remWFTools section:#Error) \
                                 silent:silent;
            return false;
         )
      )
      else
         addStatusText (getString #skipped) newline:false;
   )
   
   
   --Remove toolbars.
   addStatusText (getString #remToolbars);
   if (removeToolbars()) then
      addStatusText (getString #done) newline:false progress:progressDelta;
   else
   (
      addStatusText (getString #failed) newline:false;
      installation_failed (getString #uninst) \
                          (getString #remToolbars section:#Error);
      return false;
   )
   
   
   --Remove hotkey.
   addStatusText (getString #remHotkeys);
   if (removeHotkeys()) then
      addStatusText (getString #done) newline:false progress:progressDelta;
   else
   (
      addStatusText (getString #failed) newline:false;
      installation_failed (getString #uninst) \
                          (getString #remHotkeys section:#Error) \
                           silent:silent;
      return false;
   )
   
   
   --Remove preferences.
   addStatusText (getString #remPrefsFile);
   if (not silent AND querybox (getString #remPrefsFile section:#Queries) \
                               title:(getString #remPrefsFileTitle section:#Queries)) then
   (
      if (removePreferencesFile()) then
         addStatusText (getString #done) newline:false progress:progressDelta;
      else
      (
         addStatusText (getString #failed) newline:false;
         installation_failed (getString #uninst) \
                             (getString #remPrefsFile section:#Error) \
                              silent:silent;
         return false;
      )
   )
   else
      addStatusText (getString #skipped) newline:false;


   
   setIsOutlinerInstalled false;
   
   uninstallation_success silent:silent;
   
   true;
),--End uninstall function.





/**
 * RUN INSTALL
 */
public function install silent:false =
(
   local progressDelta = ceil (100.0 / 8); --where 8 is the number of installation steps.
   if (not silent) do
   (
      openInstallWindow 230;
      setStatusTitle ((getString #title) + " " + (getString #inst));
      addStatusText (getString #begInst);
   )
   
   addStatusText (getString #checkReq);
   if (not checkMaxVersion()) do
   (
      addStatusText (getString #failed) newline:false;
      installation_failed (getString #inst) \
                          (getString #maxVersion section:#Error) \
                          silent:silent;
      return false;
   )
   
   if (not checkDotNetVersion()) do
   (
      addStatusText (getString #failed) newline:false;
      installation_failed (getString #inst) \
                          (getString #dotNetVersion section:#Error) \
                          silent:silent;
      return false;
   )
   addStatusText (getString #done) newline:false progress:progressDelta;
   
   
   --Uninstall previous version.
   addStatusText (getString #uninstPrevVer);
   if (removeScriptFiles()) then
      addStatusText (getString #done) newline:false progress:progressDelta;
   else
   (
      addStatusText (getString #failed) newline:false;
      installation_failed (getString #inst) \
                          (getString #uninstPrev section:#Error) \
                          silent:silent;
      return false;
   )
   
   
   
   --Update preferences.
   addStatusText (getString #updPrefFile);
   if (updatePreferencesFile()) then
      addStatusText (getString #done) newline:false progress:progressDelta;
   else
   (
      addStatusText (getString #failed) newline:false;
      installation_failed (getString #inst) \
                          (getString #updatePrefsFile section:#Error) \
                          silent:silent;
      return false;
   )

   
   --Copy new files.
   addStatusText (getString #cpNewFiles);
   if (copyScriptFiles()) then
      addStatusText (getString #done) newline:false progress:progressDelta;
   else
   (
      addStatusText (getString #failed) newline:false;
      installation_failed (getString #inst) \
                          (getString #copyNewFiles section:#Error) \
                          silent:silent;
      return false;
   )
      
   
   
   --Load macroscripts
   addStatusText (getString #loadMcr);
   if (loadMacroScripts()) then
      addStatusText (getString #done) newline:false progress:progressDelta;
   else
   (
      addStatusText (getString #failed) newline:false;
      installation_failed (getString #inst) \
                          (getString #loadMcr section:#Error) \
                          silent:silent;
      return false;
   )
      
      
   --Create toolbars.
   addStatusText (getString #createToolbars);
   if (createToolbars()) then
      addStatusText (getString #done) newline:false progress:progressDelta;
   else
   (
      addStatusText (getString #failed) newline:false;
      installation_failed (getString #inst) \
                          (getString #createToolbars section:#Error);
      return false;
   )
      
   
   --Assign hotkey.
   addStatusText (getString #assignHotkey);
   local showHelp = false;
   if (not (containsHotkeyAction "toggleOutliner" "Outliner")) then
   (
      local queryStr   = getString #assignHotkey section:#Queries;
      local queryTitle = getString #assignHotkeyTitle section:#Queries
      local existingAction = getHotkeyAction();
      if (existingAction != undefined) do
      (
         if (existingAction.PersistentId != 0) then
         (
            if (existingAction.PersistentId == "50029" AND existingAction.TableId == 0) then
               queryStr += getString #replaceSelectByName section:#Queries;
            else
               queryStr += getString #replaceOtherHotkey section:#Queries;
         )
         else
         (
            queryStr += (getString #replaceOtherHotkey section:#Queries) + ":\n";
            queryStr += existingAction.MacroCategory + " - " + existingAction.MacroName;
         )
      )
      
      local do_assignHotkey = queryBox queryStr title:queryTitle;
      showHelp = not do_assignHotkey;
      
      if (not silent AND do_assignHotkey) then
      (
         if (assignHotkey()) then
            addStatusText (getString #done) newline:false progress:progressDelta;
         else
         (
            addStatusText (getString #failed) newline:false;
            installation_failed (getString #inst) \
                                (getString #assignHotkey section:#Error) \
                                silent:silent;
            return false;
         )
      )
      else
         addStatusText (getString #skipped) newline:false progress:progressDelta;
   )
   else
      addStatusText (getString #skipped) newline:false progress:progressDelta;
   
   
   
   
   --Check if 3dsmax restart is required.
   addStatusText (getString #checkRestartReq);
   outliner_restart_required = restartRequired();
   if (outliner_restart_required) then
      addStatusText "yes" newline:false progress:progressDelta;
   else
      addStatusText "no" newline:false progress:progressDelta;
   
   
   setIsOutlinerInstalled true;
   
   installation_success (getString #inst) \
                        silent:silent \
                        showHowToUse:showHelp;
                        
   
   true;
),--End install function.


on create do
(
   clearTempDir();
   loadAssembly (tempDir + "/script/ScriptCenter.Max.dll");
)


)

outlinerInstaller = outliner_installer();