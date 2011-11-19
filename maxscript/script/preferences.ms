struct outlinerPrefsEntry
(
	section,
	key,
	value,
	default
)

struct outlinerPreferences (
	iniFile,

	
	function createEntriesEnum =
	(
		#(
			--General section
			(outlinerPrefsEntry section:#General key:#version					default:0.0),
			(outlinerPrefsEntry section:#General key:#versionString				default:""),
			(outlinerPrefsEntry section:#General key:#matModeFirstRun			default:true),
			(outlinerPrefsEntry section:#General key:#addNestedLayerMessage		default:true),
			(outlinerPrefsEntry section:#General key:#openAtStartup				default:false),
			(outlinerPrefsEntry section:#General key:#workflowToolsInstalled	default:false),
			(outlinerPrefsEntry section:#General key:#checkForUpdates			default:true),
			(outlinerPrefsEntry section:#General key:#checkUpdatesInterval		default:7),
			(outlinerPrefsEntry section:#General key:#lastUpdateCheck			default:0L),
			(outlinerPrefsEntry section:#General key:#crashReportEmail			default:""),
			
			--Window section
			(outlinerPrefsEntry section:#Window	key:#posx						default:500),
			(outlinerPrefsEntry section:#Window	key:#posy						default:50),
			(outlinerPrefsEntry section:#Window	key:#width						default:250),
			(outlinerPrefsEntry section:#Window	key:#height						default:400),
			(outlinerPrefsEntry section:#Window	key:#dockFlag					default:#cui_floatable),
	
			--Tree section
			(outlinerPrefsEntry section:#Tree	key:#listMode					default:"Hierarchy"),
			(outlinerPrefsEntry section:#Tree	key:#sortMode					default:"Alphabetical"),
			(outlinerPrefsEntry section:#Tree	key:#objFilter					default:#{1..11}),
			(outlinerPrefsEntry section:#Tree	key:#objFilterEnabled			default:false),
			(outlinerPrefsEntry section:#Tree	key:#objFilterAffectLayers		default:false),
			(outlinerPrefsEntry section:#Tree	key:#objFilterAffectVpt			default:false),
			(outlinerPrefsEntry section:#Tree	key:#searchCaseSensitive		default:false),
			(outlinerPrefsEntry section:#Tree	key:#dragMouseButton			default:"Middle"),
			(outlinerPrefsEntry section:#Tree	key:#expandHierarchyKey			default:"Control"),
			(outlinerPrefsEntry section:#Tree	key:#doubleClickAction			default:"Rename"),
			(outlinerPrefsEntry section:#Tree	key:#highlightLastSel			default:false),
			(outlinerPrefsEntry section:#Tree	key:#hideGroupMembersLayerMode	default:false),
			(outlinerPrefsEntry section:#Tree	key:#editNewLayerName			default:true),
			(outlinerPrefsEntry section:#Tree	key:#autoExpandHierarchy		default:false),
			(outlinerPrefsEntry section:#Tree	key:#autoExpandLayer			default:false),
			(outlinerPrefsEntry section:#Tree	key:#autoExpandMaterial			default:false),
			(outlinerPrefsEntry section:#Tree	key:#expandSelPolicyHierarchy	default:"WhenNecessary"),
			(outlinerPrefsEntry section:#Tree	key:#expandSelPolicyLayer		default:"Never"),
			(outlinerPrefsEntry section:#Tree	key:#expandSelPolicyMaterial	default:"WhenNecessary"),
			(outlinerPrefsEntry section:#Tree	key:#showNodeHideButton			default:true),
			(outlinerPrefsEntry section:#Tree	key:#showNodeFreezeButton		default:true),
			(outlinerPrefsEntry section:#Tree	key:#nodeButtonsLocation		default:"BeforeNode"),
			(outlinerPrefsEntry section:#Tree	key:#iconClickAction			default:"SetActive"),
			
			--Visual section
			(outlinerPrefsEntry	section:#Visual	key:#iconset					default:"Max"),
			(outlinerPrefsEntry	section:#Visual	key:#invertIcons				default:true),
			(outlinerPrefsEntry section:#Visual	key:#colorscheme				default:""),
			(outlinerPrefsEntry section:#Visual	key:#buttonsAtTop				default:false)
		  )
	),
	entries = createEntriesEnum(),
	
	
	
	
	function readEntry entry =
	(
		local val = (getINISetting iniFile entry.section entry.key);
				
		if val == "" then
			val = entry.default;
		else if ((classof entry.default) == BitArray) then
			val = execute val;
		else
			val = val as (classof entry.default);
		
		entry.value = val;
	),

	
	
	function writeEntry entry =
	(
		setINISetting iniFile entry.section entry.key (entry.value as String);
	),
	
	
	
	
	function getEntry section key =
	(
		local entry;
		local notfound = true;
		for p in entries while notfound do
		(
			if (p.section == section AND p.key == key) do
			(
				entry = p;
				notfound = false;
			)
		)
		
		if (notfound == true) then
			throw "Preference entry not found: " key;
		else
			entry;
	),
	
	
	
	
	function getValue section key =
	(
		local entry = getEntry section key;
		entry.value;
	),
	
	function setValue section key value write:true =
	(
		local entry = getEntry section key;
		entry.value = value;
		if (write) do writeEntry entry;
	),
	

	
	
	function loadPreferences = 
	(
		for entry in entries do
			readEntry entry;
	),
	
	
	function savePreferences = 
	(
		for entry in entries do
			writeEntry entry;
	)
)