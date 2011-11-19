(

local version = 2.0977;
local versionStr = "2.1 beta3";

global outliner_restart_required;

local tempDir = (GetDir #temp) + "/outliner";
local userScriptDir = (GetDir #userScripts) + "/outliner";
local userStartupScriptDir = (GetDir #userStartupScripts) + "/outliner";
local userIconsDir = (GetDir #userIcons);

local prefs_file = (GetDir #userScripts) + "/outliner_prefs.ini";
local product_info_file = (GetDir #userScripts) + "/outliner_product_info.ini";


local str_done = "done";
local str_failed = "failed";
local str_skipped = "skipped";

local str_title                   = "Outliner " + versionStr;
local str_inst                    = "Installation";
local str_uninst                  = "Uninstallation";
local str_begUnInst               = "Beginning uninstallation.\n";
local str_remScrFiles             = "\nRemoving script files...";
local str_remPrefFiles            = "\nRemoving preferences file...";
local str_queryRemprefs_fileTitle = "Remove preferences file?";
local str_queryRemprefs_file      = "Do you want to remove the Outliner preferences file?";
local str_remWFToolsFiles         = "\nRemoving Workflow Tools files...";
local str_remScrFilesFailed       = "Removing script files failed.\n\nIt is possible that 3dsmax is locking some files,\nor administrator rights may be required.\nSee the maxscript listener (F11) for details.\nRecommendation: restart 3dsmax and try again.     ";
local str_remPrefFileFailed       = "Removing preferences file failed.  ";
local str_remWFToolsFilesFailed   = "Removed Workflow Tools files failed.\nSee the maxscript listener (F11) for details.";
local str_remWFTools              = "Do you want to remove the Outliner Workflow Tools too?";

local str_begInst           = "Beginning installation.\n";
local str_uninstPrevVer     = "\nUninstalling previous version...";
local str_updPrefFile       = "\nUpdating preferences file...";
local str_cpNewFiles        = "\nCopying new files...";
local str_assignHotkey      = "\nAssigning shortcut key...";
local str_checkRestartReq   = "\nChecking if restart is required...";
local str_loadMcr           = "\nLoading macroscripts...";
local str_maxVersionFail    = "The Outliner requires 3dsmax 2008 or higher.";
local str_dotnetVersionFail = "The Outliner requires .NET Framework 3.5 or higher.";
local str_uninstFailed      = "Uninstalling previous version failed.\n\nIt is possible that 3dsmax is locking some files,\nor administrator rights may be required.\nSee the maxscript listener (F11) for details.\nRecommendation: restart 3dsmax and try again.     ";
local str_updPrefFileFailed = "Updating preferences file failed.  ";
local str_cpNewFilesFailed  = "Copying new files failed.\n\nThis could be caused by high security settings.\nPlease see the Maxscript Listener (F11) for details.   ";
local str_assignHKFailed    = "Assigning shortcut failed.  ";
local str_loadMcrFailed     = "Loading macroscripts failed.\n\nPlease see the Maxscript Listener (F11) for details.   ";


function printException executingFn exception =
(
   format "Outliner installer exception:\n%\n%\n" executingFn exception;
)


function clearTempDir =
(
   local scriptStr = "local d = (GetDir #temp) + \"/outliner\"; if ((dotNetClass \"System.IO.Directory\").Exists d) do try ( (dotNetClass \"System.IO.Directory\").Delete d true; ) catch ()";
   callbacks.addScript #postSystemShutdown scriptStr id:#outliner_install;
)


/**
 * UNINSTALL FUNCTIONS
 */
function removeScriptFiles =
(
   local success = true;
   
   --Clear outliner global
   try ( outliner.ui.closeOutliner(); ) catch ()
   try ( outliner.destroy(); ) catch ()
   global outliner = undefined;
   
   local System_IO_Directory = dotNetClass "System.IO.Directory";
   
   local oldOutlinerDirs = #(((GetDir #startupScripts) + "/outliner"), 
                       ((GetDir #startupScripts) + "/grin_tools/outliner"), 
                       ((GetDir #Scripts) + "/outliner"), 
                       ((GetDir #maxroot) + "/stdplugs/stdscripts/outliner"),
                       ((GetDir #ui) + "macroscripts/outliner"),
                       ((GetDir #userMacros) + "/outliner"),
                       userScriptDir,
                       userStartupScriptDir
                      );
   for d in oldOutlinerDirs do 
   (
      if (System_IO_Directory.Exists d) do 
      (
         try (
            System_IO_Directory.Delete d true;
         ) catch 
         (
            printException "removeScriptFiles" (getCurrentException());
            success = false;
         )
      )
   )
   
   local otherStartupFiles = getFiles ((GetDir #maxroot) + "/stdplugs/stdscripts/outliner*");
   for f in otherStartupFiles do
   (
      if (not (deleteFile f)) do
         success = false;
   )
   
   -- Remove icon files 
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
)

function removeWorkflowTools =
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

   success;
)


function removePreferencesFile =
(
   if (doesFileExist prefs_file) then
      deleteFile prefs_file;
   else
      true;
)

function updatePreferencesFile =
(
   --Pre 2.0.94
   if (hasINISetting prefs_file "General" "version") then
   (
      local oldVersion = (getINISetting prefs_file "General" "version") as float; 
      if (oldVersion == undefined OR oldVersion < 2.0) then
         deleteFile prefs_file;
      else 
      (
         --Move product_info inisettings to separate file.
         if (oldVersion < 2.094) do
         (
            if (hasINISetting prefs_file "General" "product_id_a") do setINISetting product_info_file "General" "product_id_a" (getINISetting prefs_file "General" "product_id_a");
            if (hasINISetting prefs_file "General" "product_id_b") do setINISetting product_info_file "General" "product_id_b" (getINISetting prefs_file "General" "product_id_b");
            if (hasINISetting prefs_file "General" "workflowToolsInstalled") do setINISetting product_info_file "General" "workflowToolsInstalled" (getINISetting prefs_file "General" "workflowToolsInstalled");
            if (hasINISetting prefs_file "General" "crashReportEmail") do setINISetting product_info_file "General" "crashReportEmail" (getINISetting prefs_file "General" "crashReportEmail");
            delINISetting prefs_file "General" "version";
            delINISetting prefs_file "General" "versionString";
            delINISetting prefs_file "General" "product_id_a";
            delINISetting prefs_file "General" "product_id_b";
            delINISetting prefs_file "General" "workflowToolsInstalled";
            delINISetting prefs_file "General" "crashReportEmail";
         )
         --Remove deprecated inisettings.
         if (oldVersion < 2.09) do
         (
            delINISetting prefs_file "General" "matModeFirstRun";
            delINISetting prefs_file "General" "product_id";
            if (hasINISetting prefs_file "General" "checkUpdatesInterval" AND (getINISetting prefs_file "General" "checkUpdatesInterval") == "7") do
               setINISetting prefs_file "General" "checkUpdatesInterval" "1";
         )
         --Remove nested layer warning preference.
         if (oldVersion < 2.098) do
         (
            delINISetting prefs_file "General" "addNestedLayerMessage";
         )
      )
   )
   --Post 2.0.94
   else if (hasINISetting product_info_file "General" "version") then
   (
   )
   
   --Generate product id's if necessary.
   if ((getINISetting product_info_file "General" "product_id_a") == "" OR (getINISetting product_info_file "General" "product_id_b") == "") do
   (
      local class_id = genClassId returnValue:true;
      class_id[1] = bit.set class_id[1] 32 false;
      class_id[2] = bit.set class_id[2] 32 false;
      setINISetting product_info_file "General" "product_id_a" (class_id[1] as string);
      setINISetting product_info_file "General" "product_id_b" (class_id[2] as string);
   )
   
   --Write version and update settings.
   setINISetting product_info_file "General" "version" (version as string);
   setINISetting product_info_file "General" "versionString" versionStr;
   setINISetting prefs_file "General" "ignore_update_version" "0.0";
   setINISetting prefs_file "General" "lastUpdateCheck" "0";
   
   true;
)




/**
 * INSTALL FUNCTIONS
 */
function checkMaxVersion =
(
   --Returns true if version is equal to or above 10 (2008).
   ((maxVersion())[1] >= 10000);
)

function checkDotNetVersion =
(
   --Returns true if the .NET Framework 3.5 key could be opened.
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
)

function copyDirectory sourceDir targetDir =
(
   local System_IO_Directory = dotNetClass "System.IO.Directory";
   local System_IO_SearchOption = dotNetClass "System.IO.SearchOption";
   local System_IO_File = dotNetClass "System.IO.File";
   local allFiles = System_IO_Directory.GetFiles sourceDir "*.*" System_IO_SearchOption.AllDirectories;
   
   
   for sourceFile in allFiles do
   (
      local targetFile = targetDir + (substring sourceFile (sourceDir.count + 1) -1);
      local targetFileDir = getFilenamePath targetFile;
      if (not (System_IO_Directory.Exists targetFileDir)) do
         System_IO_Directory.CreateDirectory targetFileDir;
      System_IO_File.Copy sourceFile targetFile;
   )
)


function copyScriptFiles = 
(
   local success = true;
   
   local System_IO_Directory = dotNetClass "System.IO.Directory";
   local System_IO_File = dotNetClass "System.IO.File";
   
   try 
   (
      copyDirectory (tempDir + "/script") userScriptDir;
      copyDirectory (tempDir + "/startupScript") userStartupScriptDir;
      
      local iconFiles = System_IO_Directory.getFiles (tempDir + "/icons") "*.bmp";
      for ico in iconFiles do
         System_IO_File.Move ico (userIconsDir + "/" + (filenameFromPath ico));  
   )
   catch 
   (
      printException "copyScriptFiles" (getCurrentException());
      success = false;
   )
   
   success;
)


function restartRequired =
(
   (dotNetClass "Outliner.TreeView") != undefined;
)




function loadMacroScripts =
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
)


function getHotkeyAction =
(
   local action;
   try
   (
      global KeyboardActionsFile;
      fileIn (userScriptDir + "/keyboardActionsFile.ms");
      
      local kbd_man = KeyboardActionsFile file:(KeyboardActionsFile.getDefaultKeyboardFile());
      action = kbd_man.getActionFromKeyCode (kbd_man.getModKeyCodeFromString "") (kbd_man.getKeyCodeFromString "H") table_id1:kbd_man.macro_table_id table_id2:kbd_man.main_table_id;
   )
   catch 
   (
      printException "getHotkeyAction" (getCurrentException());
   )
   
   action;
)


function assignHotkey = 
(
   local success = true;
   try
   (  
      local kbd_man = KeyboardActionsFile file:(KeyboardActionsFile.getDefaultKeyboardFile());
      kbd_man.addActionFromKeyString "H" kbd_man.macro_table_id macro_name:"toggleOutliner" macro_category:"Outliner" replace:true;
      kbd_man.write();
   )
   catch
   (
      printException "assignHotkey" (getCurrentException());
      success = false;
   )
   
   success;
)





/**
 * INSTALL STATUS DIALOG
 */
rollout outliner_install ""
(
   edittext progress_txt height:200 readonly:true;
   button close_btn "Close" enabled:false width:273 align:#center    
   on close_btn pressed do
      destroyDialog outliner_install;
)

function addStatusText txt =
(
   outliner_install.progress_txt.text += txt;
)

function installation_success inst showHowToUse:false =
(
   addStatusText ("\n\nInstallation succeeded.")
   outliner_install.close_btn.enabled = true;
   
   local inst_txt = "Installation complete.";
   if (showHowToUse) do
      inst_txt += "\nYou can assign the Outliner to a shortcut or toolbar button using:\nCustomize > Customize User Interface > Open/Close Outliner";
   if (outliner_restart_required == true) do
      inst_txt += "\nYou'll have to restart 3dsmax before using the Outliner!   ";
   
   local mb = dotNetClass "System.Windows.Forms.MessageBox";
   local mbBtn = dotNetClass "System.Windows.Forms.MessageBoxButtons";
   local mbIcon = dotNetClass "System.Windows.Forms.MessageBoxIcon";
   mb.Show inst_txt "Installation complete" mbBtn.OK mbIcon.Information;
)

function uninstallation_success =
(
   addStatusText ("\n\nUninstallation succeeded.")
   outliner_install.close_btn.enabled = true;
   
   local mb = dotNetClass "System.Windows.Forms.MessageBox";
   local mbBtn = dotNetClass "System.Windows.Forms.MessageBoxButtons";
   local mbIcon = dotNetClass "System.Windows.Forms.MessageBoxIcon";
   mb.Show "Uninstallation complete.\nPlease restart 3dsmax" "Uninstallation complete" mbBtn.OK mbIcon.Information;
)

function installation_failed inst msg =
(
   addStatusText ("\n\n" + inst + " failed.");
   outliner_install.close_btn.enabled = true;
   messageBox msg title:"Error";
)




/**
 * RUN UNINSTALL
 */
function uninstall =
(
   outliner_install.title = str_title + " uninstallation";
   addStatusText str_begUnInst;
   
   addStatusText str_remScrFiles;
   if (removeScriptFiles()) then
      addStatusText str_done;
   else
   (
      addStatusText str_failed;
      installation_failed str_uninst str_remScrFilesFailed;
      return false;
   )
   
   
   addStatusText str_remWFToolsFiles;
   if (doesFileExist prefs_file) do
   (
      if ((getINISetting prefs_file "General" "workflowtoolsinstalled") == "true") then
         if (queryBox str_remWFTools title:"Remove Workflow Tools") then
         (
            if (removeWorkflowTools()) then
               addStatusText str_done;
            else
            (
               addStatusText str_failed;
               installation_failed str_uninst str_remWFToolsFilesFailed;
               return false;
            )
         )
         else
            addStatusText str_skipped;
      else
         addStatusText str_skipped;
   )
   
   
   addStatusText str_remPrefFiles;
   if (querybox str_queryRemprefs_file title:str_queryRemprefs_fileTitle) then
   (
      if (removePreferencesFile()) then
         addStatusText str_done;
      else
      (
         addStatusText str_failed;
         installation_failed str_uninst str_remPrefFileFailed;
         return false;
      )
   )
   else
      addStatusText str_skipped;
   
   uninstallation_success();
   true;
)--End uninstall function.





/**
 * RUN INSTALL
 */
function install =
(
   outliner_install.title = str_title + " installation";
   addStatusText str_begInst;
   
   if (not checkMaxVersion()) do
   (
      installation_failed str_inst str_maxVersionFail;
      return false;
   )
   
   if (not checkDotNetVersion()) do
   (
      installation_failed str_inst str_dotNetVersionFail;
      return false;
   )
   
   addStatusText str_uninstPrevVer;
   if (removeScriptFiles()) then
      addStatusText str_done;
   else
   (
      addStatusText str_failed;
      installation_failed str_inst str_uninstFailed;
      return false;
   )
   
   
   addStatusText str_updPrefFile;
   if (updatePreferencesFile()) then
      addStatusText str_done;
   else
   (
      addStatusText str_failed;
      installation_failed str_inst str_updPrefFileFailed;
      return false;
   )

   
   
   addStatusText str_cpNewFiles;
   if (copyScriptFiles()) then
      addStatusText str_done;
   else
   (
      addStatusText str_failed;
      installation_failed str_inst str_cpNewFilesFailed;
      return false;
   )
      
   
   
   
   
   
   addStatusText str_loadMcr;
   if (loadMacroScripts()) then
      addStatusText str_done;
   else
   (
      addStatusText str_failed;
      installation_failed str_inst str_loadMcrFailed;
      return false;
   )
      
      
   
   addStatusText str_assignHotkey;
   local action = getHotkeyAction();
   local do_assignHotkey = false;
   if (action == undefined OR action.macro_name != "toggleOutliner" OR action.macro_category != "Outliner") then
   (
      local queryStr = "Do you want to assign opening the outliner to 'H' ?";
      if (action != undefined) do
      (
         if (action.isAction() == true) then
         (
            if (action.persistent_id == "50029" AND action.table_id == 0) then
               queryStr += "\n Warning: this will replace the currently assigned action:\nSelect by Name";
            else
               queryStr += "\n Warning: this will replace the currently assigned action";
         )
         else if (action.isMacro() == true) then
         (
            queryStr += "\n Warning: this will replace the currently assigned action:\n";
            queryStr += action.macro_category + " - " + action.macro_name;
         )
      )
      
      do_assignHotkey = queryBox queryStr title:"Assign shortcut";
      if (do_assignHotkey) then
      (
         if (assignHotkey()) then
            addStatusText str_done;
         else
         (
            addStatusText str_failed;
            installation_failed str_inst str_assignHKFailed;
            return false;
         )
      )
      else
         addStatusText str_skipped;
   )
   else
      addStatusText str_skipped;
   
   try ( KeyboardActionsFile.maxReloadKeyboardFile(); ) catch()
   
   
   
   addStatusText str_checkRestartReq;
   outliner_restart_required = restartRequired();
   if (outliner_restart_required) then
      addStatusText "yes";
   else
      addStatusText "no";
   
   
   
   installation_success str_inst showHowToUse:(not do_assignHotkey);
   true;
)--End install function.



/**
 * PRE INSTALL DIALOG (CHOOSE INSTALL / UNINSTALL)
 */
rollout outliner_pre_install (str_title + " installation")
(
   label title_lbl "" offset:[0, 5];
   label descr_lbl "This script will install/uninstall the Outliner scene management tool." offset:[0, 5];
   label descr_lbl2 "Any previous installation will be uninstalled automatically." offset:[0, -2];
   button install_btn "Install" width:60 offset:[0, 10] across:3
   button uninstall_btn "Uninstall" width:60 offset:[0, 10]
   button close_btn "Close" width:60 offset:[0, 10]
   
   on outliner_pre_install open do
   (
      title_lbl.text = str_title;
   )
   
   function openInstallWindow height =
   (
      destroyDialog outliner_pre_install;
      createDialog outliner_install 300 \
                                    height \
                                    lockWidth:true \
                                    lockHeight:true \
                                    style:#(#style_sysmenu, #style_toolwindow)
      outliner_install.progress_txt.height = height - 40;
      outliner_install.close_btn.pos.y = height - 28;
   )
   
   on install_btn pressed do 
   (
      openInstallWindow 180;
      install();
      clearTempDir();
   )
   
   on uninstall_btn pressed do
   (
      openInstallWindow 150;
      uninstall();
      clearTempDir();
   )
   
   on close_btn pressed do
   (
      clearTempDir();
      destroyDialog outliner_pre_install;
   )
)--End rollout.


createDialog outliner_pre_install 330 \
                                  110 \
                                  modal:true \
                                  lockWidth:true \
                                  lockHeight:true \
                                  style:#(#style_sysmenu, #style_toolwindow);

)