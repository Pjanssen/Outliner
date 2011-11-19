/**
 * The KeyboardAction represents a single action assigned to a shortcut key combination.
 *
 * The shortcut is combined by mod_key_code and key_code. Both of these can be easily obtained from a string or flags
 * through the KeyboardActionManager.getModKeyCode and similar functions.
 *
 * A KeyboardAction should always have a table_id, but depending on the type (Action or Macro), it can have either a persisten_id,
 * or a combination of macro_name and macro_category.
 *
 * The run() function runs executes the action or macro.
 */
struct KeyboardAction
(
	mod_key_code,
	key_code,
	
	table_id,
	persistent_id,
	
	macro_name,
	macro_category,
	
	
	function isAction =
	(
		(persistent_id != undefined AND table_id != 647394);
	),
	
	function isMacro =
	(
		(macro_name != undefined AND macro_category != undefined AND table_id == 647394);
	),
	
	function run =
	(
		if (isAction()) then
			actionMan.executeAction table_id persistent_id;
		else if (isMacro()) then
			macros.run macro_category macro_name;
	),
	
	
	function compare a1 a2 =
	(
		case of
		(
			(a1.table_id < a2.table_id): -1
			(a1.table_id > a2.table_id): 1
			default: 0
		)
	)
)


/**
 * The KeyboardActionManager struct handles reading and writing kbd files.
 *
 * After being instantiated, the readActions functions should be run, to load the users shortcuts.
 * The actions property is an array containing all loaded actions.
 *
 * This struct was written for some specific needs, and not necessarily to provide a complete interface to kbd files.
 */
struct KeyboardActionsFile
(
	file,
	actions,
	
	main_table_id = 0,
	macro_table_id = 647394,	
	
	

	
	/**
	 * MAX KEYBOARD FILE FUNCTIONS.
	 */
	function getDefaultKeyboardFile =
	(
		local kbd_file = actionMan.getKeyboardFile();
		if (not doesFileExist kbd_file) do
			actionMan.saveKeyboardFile kbd_file;
		
		kbd_file;
	),
	
	function maxReloadKeyboardFile =
	(
		actionMan.loadKeyboardFile (actionMan.getKeyboardFile());
	),
	
	
	
	/**
	 * GET (MOD)KEYCODE FUNCTIONS
	 */
	 
	-- Returns the mod_key_code based on the modifier key flags provided to the function.
	function getModKeyCode altPressed:false ctrlPressed:false shiftPressed:false =
	(
		local mod_key_code = 3;
		if (shiftPressed) do mod_key_code = bit.or mod_key_code 4;
		if (ctrlPressed) do mod_key_code = bit.or mod_key_code 8;
		if (altPressed) do mod_key_code = bit.or mod_key_code 16;
		
		-- Return mod_key_code.
		mod_key_code;
	),
	
	--Returns the mod_key_code for the supplied string. Format: "ctrl+alt+x"
	function getModKeyCodeFromString key_str =
	(
		key_str = toUpper key_str;
		local str_split = filterString key_str "+";
		local mod_key_code = 3;
		for key in str_split do
		(
			case key of
			(
				"SHIFT" : mod_key_code = bit.or mod_key_code 4;
				"CTRL" : mod_key_code = bit.or mod_key_code 8;
				"CONTROL" : mod_key_code = bit.or mod_key_code 8;
				"ALT" : mod_key_code = bit.or mod_key_code 16;
			)
		)
		
		-- Return mod_key_code.
		mod_key_code;
	),
	
	--Returns the uppercase key_code of the first occurrence of a single character in a string with the format : "ctrl+alt+x"
	function getKeyCodeFromString key_str =
	(
		key_str = toUpper key_str;
		local str_split = filterString key_str "+";
		
		local notfound = true;
		local key_code = 0;
		for key in str_split while notfound do
		(
			if (key.count == 1) do
			(
				key_code = bit.charasint key;
				notfound = false;
			)
		)
		
		--Return the key_code.
		key_code
	),

	
	
	
	
	/**
	 * GET / RUN ACTIONS FUNCTIONS
	 */
	function getActionFromKeyCode mod_key_code key_code table_id1:undefined table_id2:undefined =
	(
		if (actions == undefined) do
			throw "No actions loaded.";
		
		local notfound = true;
		local action;
		for a in actions while notfound do
		(
			if (a.key_code == key_code AND a.mod_key_code == mod_key_code) do
			(
				if (table_id1 == undefined OR a.table_id == table_id1 OR a.table_id == table_id2) do
				(
					action = a;
					notfound = false;
				)
			)
		)
		
		-- Return found action (or undefined if no action was found).
		action;
	),
	
	
	function runActionFromKeyCode mod_key_code key_code table_id1:undefined table_id2:undefined =
	(
		local action = getActionFromKeyCode mod_key_code key_code table_id1:table_id1 table_id2:table_id2;
		if (action != undefined) do
			action.run(); 
	),
	
	
	function runActionFromKeyString str =
	(
		local mod_key_code = getModKeyCodeFromString str;
		local key_code = getKeyCodeFromString str;
		runActionFromKeyCode mod_key_code key_code table_id1:main_table_id table_id2:macro_table_id;
	),
	
	
	
	/**
	 * ADD ACTION TO ACTIONSET
	 */
	function addAction mod_key_code key_code table_id persistent_id:undefined macro_name:undefined macro_category:undefined replace:false =
	(
		if (persistent_id == undefined AND (macro_name == undefined OR macro_category == undefined)) do
			throw "Either persistent_id or macro_name + macro_category parameter required.";
			
		if (persistent_id != undefined AND (macro_name != undefined OR macro_category != undefined)) do
			throw "Using both persistent_id and macro_name + macro_category is not allowed.";

		if (actions == undefined) do
			throw "No actions defined.";
			
		-- Actions that have to be removed are stored in this array to be removed after iteration is completed.
		local removeActions = #();
		
		-- Iterate through actions and check for conflicting actions.
		for a = 1 to actions.count do
		(
			local action = actions[a];
			
			if (action.table_id == table_id OR (action.table_id == main_table_id AND table_id == macro_table_id) OR (action.table_id == macro_table_id AND table_id == main_table_id)) do
			(
				local conflict = false;
				
				-- Check for duplicate key combination.
				if (action.mod_key_code == mod_key_code AND action.key_code == key_code) do conflict = true;
				
				-- Check for duplicate persistent_id if necessary.
				if (persistent_id != undefined) do
					if (action.persistent_id == persistent_id) do 
						conflict = true;

				-- Check for duplicate macro_name and macro_category if necessary.
				if (macro_name != undefined AND macro_category != undefined) do
					if (action.macro_name == macro_name AND action.macro_category == macro_category) do 
						conflict = true;
						
				-- Flag action for removal if it is conflicting with new action and replace is true.
				-- If there are conflicts and replace is false, return false.
				if (conflict AND not replace) then
					return false;
				else if (conflict AND replace) do
					append removeActions a;
			)
		)
		
		-- Remove conflicting actions.
		for a in removeActions do deleteItem actions a;
		
		-- Append new action.
		append actions (KeyboardAction mod_key_code:mod_key_code key_code:key_code table_id:table_id persistent_id:persistent_id macro_name:macro_name macro_category:macro_category);
		
		--Adding was successful, return true;
		true;
	),
	
	
	function addActionFromKeyString key_str table_id persistent_id:undefined macro_name:undefined macro_category:undefined replace:false =
	(
		local mod_key_code = getModKeyCodeFromString key_str;
		local key_code = getKeyCodeFromString key_str;
		addAction mod_key_code key_code table_id persistent_id:persistent_id macro_name:macro_name macro_category:macro_category replace:replace;
	),
	
	
	
	/**
	 * WRITE ACTIONS FILE
	 */
	function write = 
	(
		if (file == undefined) do
			throw "File cannot be undefined.";
		if (actions == undefined) do
			throw "No actions defined.";
	
		qsort actions KeyboardAction.compare;
		
		--Create a backup of the file we're going to write to.
		local backup_file = file + ".bak";
		if ((getFileSize file) > 0) do
		(
			if ((getFileSize backup_file) > 0) do
				deleteFile backup_file;
				
			if (not (copyFile file backup_file)) do
				throw "Unable to make a backup kbd file. This is a bit tricky to do without.";
		)
			
		
		local kbd_fileStream = openFile file mode:"w";
		if (kbd_fileStream == undefined) do
			throw "Unable to write to file." kbdFile;
		
		try (	
			local i = 0;
			local prev_table_id;
			for a in actions do
			(
				if (a.table_id != prev_table_id) do
					i = 0;
					
				if (a.isAction()) then
					format "%=% % % %\n" i a.mod_key_code a.key_code a.persistent_id a.table_id to:kbd_fileStream;
				else if (a.isMacro()) then
					format "%=% % %`% %\n" i a.mod_key_code a.key_code a.macro_name a.macro_category a.table_id to:kbd_fileStream;
					
				prev_table_id = a.table_id;
				i += 1;
			)
		)
		catch
		(
			-- Restore backup and throw exception.
			close kbd_fileStream;
			deleteFile file;
			copyFile backup_file file;
			--deleteFile backup_file;
			
			throw();
		)
		
		close kbd_fileStream;
	),
	
	
	
	/**
	 * READ & PARSE ACTIONS FILE
	 */
	function read =
	(
		if (file == undefined) do
			throw "File cannot be undefined.";
			
		local kbd_fileStream = openFile file mode:"rS"
		
		if (kbd_fileStream == undefined) do
			throw "Keyboard-File could not be opened." file;
		
		actions = #();
		
		while (not eof kbd_fileStream) do
		(
			local kbd_line = readLine kbd_fileStream;
			local split_line = filterString kbd_line "= ";
			if (split_line.count > 4) do
			(
				local action = KeyboardAction mod_key_code:(split_line[2] as integer) key_code:(split_line[3] as integer) table_id:(split_line[split_line.count] as integer);
				
				if (split_line.count > 5 OR (matchPattern split_line[4] pattern:"*`*")) then
				(
					--Macro.
					local macro = split_line[4];
					if (split_line.count > 5) do
					(
						for i = 5 to (split_line.count - 1) do 
							macro += " " + split_line[i];
					)
					
					local split_macro = filterString macro "`";
					action.macro_name = split_macro[1];
					action.macro_category = split_macro[2];
				)
				else
				(
					--Action.
					action.persistent_id = split_line[4];
				)
				
				append actions action;
			)
		)
		
		close kbd_fileStream;
	),
	
	
	
	
	function init =
	(
		if (file != undefined) do
			read();
	),
	
	_init = init()
)