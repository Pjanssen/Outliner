(
	local version = 2.01;
	local versionStr = "2.0.1";
	
	global outliner_restart_required;
	
	local tempDir = (GetDir #temp) + "/outliner";
	local scriptDir = (GetDir #Scripts) + "/outliner";
	local stdscriptDir = (GetDir #maxroot) + "/stdplugs/stdscripts/outliner";
	local macroscriptsDir = (GetDir #ui) + "macroscripts/outliner"
	local workflowtoolsDir = stdscriptDir + "_workflowtools";
	local iconsDir = (GetDir #ui) + "/icons";
	local prefsFile = (GetDir #userScripts) + "/outliner_prefs.ini";
	
	
	local str_done = "done";
	local str_failed = "failed";
	local str_skipped = "skipped";
	
	local str_title				= "Outliner " + versionStr;
	local str_inst				= "Installation";
	local str_uninst			= "Uninstallation";
	local str_begUnInst			= "Beginning uninstallation.\n";
	local str_remScrFiles		= "\nRemoving script files...";
	local str_remPrefFiles		= "\nRemoving preferences file...";
	local str_remWFToolsFiles	= "\nRemoving Workflow Tools files...";
	local str_remScrFilesFailed = "Removing script files failed.\n\nIt is possible that 3dsmax is locking some files,\nsee the maxscript listener (F11) for details.\nRecommendation: restart 3dsmax and try again.     ";
	local str_remPrefFileFailed	= "Removing preferences file failed.  ";
	local str_remWFToolsFilesFailed = "Removed Workflow Tools files failed.\nSee the maxscript listener (F11) for details.";
	local str_remWFTools		= "Do you want to remove the Outliner Workflow Tools too?";
	
	local str_begInst			= "Beginning installation.\n";
	local str_uninstPrevVer		= "\nUninstalling previous version...";
	local str_updPrefFile		= "\nUpdating preferences file...";
	local str_cpNewFiles		= "\nCopying new files...";
	local str_assignHotkey		= "\nAssigning shortcut key...";
	local str_checkRestartReq	= "\nChecking if restart is required...";
	local str_loadMcr			= "\nLoading macroscripts...";
	local str_maxVersionFail	= "The Outliner requires 3dsmax 2008 or higher.";
	local str_uninstFailed		= "Uninstalling previous version failed.\n\nIt is possible that 3dsmax is locking some files,\nsee the maxscript listener (F11) for details.\nRecommendation: restart 3dsmax and try again.     ";
	local str_updPrefFileFailed	= "Updating preferences file failed.  ";
	local str_cpNewFilesFailed	= "Copying new files failed.\n\nPlease see the Maxscript Listener (F11) for details.   ";
	local str_assignHKFailed	= "Assigning shortcut failed.  ";
	local str_loadMcrFailed		= "Loading macroscripts failed.\n\nPlease see the Maxscript Listener (F11) for details.   ";
	
	
	function printException executingFn exception =
	(
		format "Installer exception:\n%\n%\n" executingFn exception;
	)
	
	
	function clearTempDir =
	(
		try 
		( 
			(dotNetClass "System.IO.Directory").Delete tempDir true; 
		) 
		catch
		(
			printException "clearTempDir" (getCurrentException()); 
		)
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
		
		local startupDir = (GetDir #startupScripts);
		local oldOutlinerDirs = #((startupDir + "/outliner"), (startupDir + "/grin_tools/outliner"), scriptDir, stdscriptDir);
		for d in oldOutlinerDirs do 
		(
			if ((getDirectories d).count > 0) do 
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
		
		-- Remove icon files
		local iconFiles = getFiles (iconsDir + "/*Outliner*");
		for ico in iconFiles do
		(
			if ((findString ico "_wftools_") == undefined) do
			(
				if (not (deleteFile ico)) do 
					success = false;
			)
		)
		
		-- Remove normal macros
		local oldMacros = (getFiles (macroscriptsDir + "/*"));
		for mcr in oldMacros do
		(
			if (not (deleteFile mcr)) do 
				success = false;
		)
		try ( System_IO_Directory.Delete macroScriptsDir true ) catch ()
	
	
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
		
		local dirIO = dotNetClass "System.IO.Directory";
		if ((getDirectories workflowtoolsDir).count > 0) do
		(
			try (
				dirIO.delete workflowtoolsDir true;
			) catch 
			(
				printException "removeWorkflowTools" (getCurrentException());
				success = false;
			)
		)
		
		-- Remove icon files
		local iconFiles = getFiles (iconsDir + "/*Outliner_wftools*");
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
		if (doesFileExist prefsFile) then
			deleteFile prefsFile;
		else
			true;
	)
	
	function updatePreferencesFile =
	(
		if (doesFileExist prefsFile) do
		(
			local oldVersion = (getINISetting prefsFile "General" "version") as float; 
			if (oldVersion == undefined OR oldVersion < version) then
				deleteFile prefsFile;
			--actual updating can be implemented for later versions...
		)
		
		setINISetting prefsFile "General" "version" (version as string);
		
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
	
	
	function copyDirectory sourceDir targetDir =
	(
		local Directory = dotNetClass "System.IO.Directory";
		local SearchOption = dotNetClass "System.IO.SearchOption";
		local File = dotNetClass "System.IO.File";
		local allFiles = Directory.GetFiles sourceDir "*.*" SearchOption.AllDirectories;
		
		
		for sourceFile in allFiles do
		(
			local targetFile = targetDir + (substring sourceFile (sourceDir.count + 1) -1);
			local targetFileDir = getFilenamePath targetFile;
			if (not (Directory.Exists targetFileDir)) do
				Directory.CreateDirectory targetFileDir;
			File.Copy sourceFile targetFile;
		)
	)
	
	
	function copyScriptFiles = 
	(
		local success = true;
		
		local dir = dotNetClass "System.IO.Directory";
		local file = dotNetClass "System.IO.File";
		
		try 
		(
			copyDirectory (tempDir + "/script") scriptDir;
			copyDirectory (tempDir + "/stdscript") stdscriptDir;
			copyDirectory (tempDir + "/macroscripts") macroscriptsDir;
			/*
			dir.Move (tempDir + "/script") scriptDir;
			dir.Move (tempDir + "/stdscript") stdscriptDir;
			dir.Move (tempDir + "/macroscripts") macroscriptsDir;
			*/
			iconFiles = dir.getFiles (tempDir + "/icons") "*.bmp";
			for ico in iconFiles do
				file.Move ico (iconsDir + "/" + (filenameFromPath ico));	
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
			
			local files = GetFiles (macroscriptsDir + "/*.mcr");
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
			fileIn (scriptDir + "/keyboardActionsFile.ms");
			
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
	
	function installation_success inst =
	(
		addStatusText ("\n\n" + inst + " succeeded.")
		outliner_install.close_btn.enabled = true;
		
		local inst_txt = inst + " complete.   \n";
		if (outliner_restart_required == true) do
			inst_txt += "You'll have to restart 3dsmax before using the Outliner!   ";
		
		local mb = dotNetClass "System.Windows.Forms.MessageBox";
		local mbBtn = dotNetClass "System.Windows.Forms.MessageBoxButtons";
		local mbIcon = dotNetClass "System.Windows.Forms.MessageBoxIcon";
		mb.Show inst_txt (inst + " complete") mbBtn.OK mbIcon.Information;
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
		if (doesFileExist prefsFile) do
		(
			if ((getINISetting prefsFile "General" "workflowtoolsinstalled") == "true") then
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
		if (removePreferencesFile()) then
			addStatusText str_done;
		else
		(
			addStatusText str_failed;
			installation_failed str_uninst str_remPrefFileFailed;
			return false;
		)
		
		installation_success str_uninst;
		true;
	)
	
	
	
	
	
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
			
		
		
		addStatusText str_checkRestartReq;
		outliner_restart_required = restartRequired();
		if (outliner_restart_required) then
			addStatusText "yes";
		else
			addStatusText "no";
		
		
		
		
		
		addStatusText str_loadMcr;
		if (not outliner_restart_required) then
		(
			if (loadMacroScripts()) then
				addStatusText str_done;
			else
			(
				addStatusText str_failed;
				installation_failed str_inst str_loadMcrFailed;
				return false;
			)
		)
		else
			addStatusText str_skipped;
			
			
		
		addStatusText str_assignHotkey;
		local action = getHotkeyAction();
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
			
			local do_assignHotkey = queryBox queryStr title:"Assign shortcut";
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
		
		installation_success str_inst;
		true;
	)
	

	
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
			createDialog outliner_install 300 height lockWidth:true lockHeight:true style:#(#style_sysmenu, #style_toolwindow)
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
	)
	
	
	createDialog outliner_pre_install 330 110 modal:true lockWidth:true lockHeight:true style:#(#style_sysmenu, #style_toolwindow)	
)