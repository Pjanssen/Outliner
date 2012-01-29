struct outlinerPrefsEntry
(
public
   section,
   key,
   value,
   default,
   
   on create do 
      value = default;
)


struct outlinerPreferences (

public iniFile,
public entries = #(),

private function readEntry entry =
(
   if (iniFile == undefined) do
      return false;
      
   local val = (getINISetting iniFile entry.section entry.key);
   
   try
   (
      local valueClass = classof entry.default;
      
      if (val == "") then
         entry.value = entry.default;
      else if (valueClass == String) then
         entry.value = val;
      else if (valueClass == BitArray) then
         entry.value = execute val;
      else
         entry.value = val as valueClass;
   )
   catch
   (
      entry.value = entry.default;
   )
),



private function writeEntry entry =
(
   if (iniFile == undefined) do
      return false;
      
   setINISetting iniFile entry.section entry.key (entry.value as String);
),



private function getEntry section key =
(
   local entry;
   local notfound = true;
   for p in entries while notfound do
   (
      if (p.key == key AND p.section == section) do
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




public function getValue section key =
(
   local entry = getEntry section key;
   entry.value;
),

public function setValue section key value write:true =
(
   local entry = getEntry section key;
   entry.value = value;
   if (write) do writeEntry entry;
),

public function getDefault section key =
(
   local entry = getEntry section key;
   entry.default;
),



public function loadPreferences = 
(
   for entry in entries do
      readEntry entry;
),


public function savePreferences = 
(
   for entry in entries do
      writeEntry entry;
),

public function createPreferenceEntries =
(
#(
   --General section
   (outlinerPrefsEntry section:#General key:#openAtStartup               default:false),
   (outlinerPrefsEntry section:#General key:#checkForUpdates             default:true),
   (outlinerPrefsEntry section:#General key:#checkUpdatesInterval        default:1),
   (outlinerPrefsEntry section:#General key:#accept_trial                default:false),
   (outlinerPrefsEntry section:#General key:#lastUpdateCheck             default:0L),
   (outlinerPrefsEntry section:#General key:#ignore_update_version       default:0.0),
   (outlinerPrefsEntry section:#General key:#focusSearchFieldOnOpen      default:true),
   (outlinerPrefsEntry section:#General key:#clearSearchFieldAfterSelect default:true),
   
   --Window section
   (outlinerPrefsEntry section:#Window key:#posx     default:500),
   (outlinerPrefsEntry section:#Window key:#posy     default:50),
   (outlinerPrefsEntry section:#Window key:#width    default:250),
   (outlinerPrefsEntry section:#Window key:#height   default:400),
   (outlinerPrefsEntry section:#Window key:#dockFlag default:#cui_floatable),

   --Tree section
   (outlinerPrefsEntry section:#Tree key:#listMode                  default:"Hierarchy"),
   (outlinerPrefsEntry section:#Tree key:#sortMode                  default:"Alphabetical"),
   (outlinerPrefsEntry section:#Tree key:#objFilter                 default:#{1..12}),
   (outlinerPrefsEntry section:#Tree key:#objFilterEnabled          default:false),
   (outlinerPrefsEntry section:#Tree key:#objFilterAffectLayers     default:false),
   (outlinerPrefsEntry section:#Tree key:#objFilterAffectVpt        default:false),
   (outlinerPrefsEntry section:#Tree key:#searchCaseSensitive       default:false),
   (outlinerPrefsEntry section:#Tree key:#dragMouseButton           default:"Left"),
   (outlinerPrefsEntry section:#Tree key:#expandHierarchyKey        default:"Control"),
   (outlinerPrefsEntry section:#Tree key:#doubleClickAction         default:"Rename"),
   (outlinerPrefsEntry section:#Tree key:#highlightLastSel          default:false),
   (outlinerPrefsEntry section:#Tree key:#hideGroupMembersLayerMode default:false),
   (outlinerPrefsEntry section:#Tree key:#editNewLayerName          default:true),
   (outlinerPrefsEntry section:#Tree key:#setNewLayerActive         default:true),
   (outlinerPrefsEntry section:#Tree key:#autoExpandHierarchy       default:false),
   (outlinerPrefsEntry section:#Tree key:#autoExpandLayer           default:false),
   (outlinerPrefsEntry section:#Tree key:#autoExpandMaterial        default:false),
   (outlinerPrefsEntry section:#Tree key:#expandSelPolicyHierarchy  default:"WhenNecessary"),
   (outlinerPrefsEntry section:#Tree key:#expandSelPolicyLayer      default:"Never"),
   (outlinerPrefsEntry section:#Tree key:#expandSelPolicyMaterial   default:"WhenNecessary"),
   (outlinerPrefsEntry section:#Tree key:#showNodeHideButton        default:true),
   (outlinerPrefsEntry section:#Tree key:#nodeHideButtonLocation    default:"BeforeNode"),
   (outlinerPrefsEntry section:#Tree key:#showNodeFreezeButton      default:true),
   (outlinerPrefsEntry section:#Tree key:#nodeFreezeButtonLocation  default:"BeforeNode"),
   (outlinerPrefsEntry section:#Tree key:#showNodeBoxModeButton     default:false),
   (outlinerPrefsEntry section:#Tree key:#nodeBoxModeButtonLocation default:"BeforeNode"),
   (outlinerPrefsEntry section:#Tree key:#showNodeAddButton         default:true),
   (outlinerPrefsEntry section:#Tree key:#nodeAddButtonLocation     default:"AfterNode"),
   (outlinerPrefsEntry section:#Tree key:#iconClickAction           default:"SetActive"),
   (outlinerPrefsEntry section:#Tree key:#invertNodeHideButton      default:false),
   
   --Visual section
   (outlinerPrefsEntry section:#Visual key:#iconset         default:"Max"),
   (outlinerPrefsEntry section:#Visual key:#invertIcons     default:true),
   (outlinerPrefsEntry section:#Visual key:#colorscheme     default:""),
   (outlinerPrefsEntry section:#Visual key:#buttonsAtTop    default:false),
   (outlinerPrefsEntry section:#Visual key:#showSearchBar   default:true),
   (outlinerPrefsEntry section:#Visual key:#searchBarAtTop  default:true)
)--End preference entries.
),

public function createProductEntries =
(
#(
   (outlinerPrefsEntry section:#General key:#version                default:0.0),
   (outlinerPrefsEntry section:#General key:#versionString          default:""),
   (outlinerPrefsEntry section:#General key:#product_id_a           default:0),
   (outlinerPrefsEntry section:#General key:#product_id_b           default:0),
   (outlinerPrefsEntry section:#General key:#outlinerInstalled      default:false),
   (outlinerPrefsEntry section:#General key:#workflowToolsInstalled default:false),
   (outlinerPrefsEntry section:#General key:#crashReportEmail       default:"")
)--End product entries.
)

)--End struct.