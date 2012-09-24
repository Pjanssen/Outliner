global outliner_update;
global outlinerInstaller;

rollout outlinerUpdateRollout "Outliner Update Available"
(
label update_lbl "" align:#left offset:[0, 5];
label changelog_lbl "Changelog:" align:#left offset:[0, 5];
dotnetControl changelog_txt "System.Windows.Forms.TextBox" align:#left width:475 height:210;

button skip_btn "Skip this version" pos:[12, 270] height:22;
button later_btn "Remind me later" pos:[110, 270] height:22;
button install_btn "Download \x26 install now" pos:[361, 270] height:22;


function onChangelogDownloadCompleted s e =
(
   if (e.Cancelled) then
      outlinerUpdateRollout.changelog_txt.text = "Changelog download was cancelled.";
   else if (e.Error != undefined) then
      outlinerUpdateRollout.changelog_txt.text = "Changelog download error.\r\n" + e.Error.Message;
   else
      outlinerUpdateRollout.changelog_txt.text = e.result;      
)

function getChangelog =
(
   local webClient = dotNetObject "System.Net.WebClient";
   local url = "http://script.threesixty.nl/outliner/get_changelog.php?html=0&";
   url += outliner_update.createUpdateArgStr();
   
   dotnet.addEventHandler webClient "DownloadStringCompleted" onChangelogDownloadCompleted;
   webClient.DownloadStringAsync (dotnetObject "System.Uri" url);
)

function close =
(
   destroyDialog outlinerUpdateRollout;
)

on outlinerUpdateRollout open do
(
   update_lbl.text = "A new Outliner version (" + (outliner_update.latestVersion as string) + ") is available and can be downloaded and installed now!";
   changelog_txt.Text = "Retrieving changelog...";
   changelog_txt.Multiline = true;
   changelog_txt.ReadOnly = true;
   changelog_txt.WordWrap = false;
   changelog_txt.ScrollBars = (dotNetClass "System.Windows.Forms.Scrollbars").Both;
   local windowColor = (colorman.getcolor #window) * 255;
   local textColor = (colorman.getcolor #windowtext) * 255;
   changelog_txt.BackColor = (dotNetClass "System.Drawing.Color").FromARGB 255 windowColor[1] windowColor[2] windowColor[3];
   changelog_txt.ForeColor = (dotNetClass "System.Drawing.Color").FromARGB 255 textColor[1] textColor[2] textColor[3];
   
   getChangelog();
)

on skip_btn pressed do
(
   outliner.prefs.setValue #General #ignore_update_version outliner_update.latestVersion;
   close();
)

on later_btn pressed do
(
   outliner.prefs.setValue #General #ignore_update_version 0.0;
   close();
)

on install_btn pressed do
(
   close();
   outliner_update.installUpdate(); 
)

)--End rollout.



struct outlinerUpdate
(
webClient,
manualUpdate = false,
checkCompleteFn,
latestVersion,


function createUpdateArgStr =
(
   local args = "";
   args += "product_id_a=" + ((outliner.product_info.getValue #General #product_id_a) as string);
   args += "&product_id_b=" + ((outliner.product_info.getValue #General #product_id_b) as string);
   args += "&outliner_version=" + ((outliner.product_info.getValue #General #version) as string);
   args += "&max_version=" + (outliner.maxV as string);
   args += "&is_64bit=";
   if (is64bitApplication()) then 
      args += "1";
   else
      args += "0";
   args += "&accept_trial=";
   if ((outliner.prefs.getValue #General #accept_trial)) then 
      args += "1";
   else
      args += "0";

   --return arguments string.
   args;
),

function installUpdate =
(
   local client = dotNetObject "System.Net.WebClient";
   local getInstallerUri = dotnetObject "System.Uri" ("http://script.threesixty.nl/outliner/get_latest.php?fn=getInstallerUrl&" + createUpdateArgStr());
   local installerUrl = client.DownloadString getInstallerUri;
   local dragDropDir = dragAndDrop.getDownloadDirectory();
   local downloadSuccess = dragAndDrop.downloadPackage #(installerUrl) dragDropDir true;
   if (downloadSuccess) then
   (
      local mzp = pathConfig.appendPath dragDropDir (filenameFromPath installerUrl);
      
      local extractDir = "";
      local dropFile = ""

      if msZip.unloadPackage mzp &extractDir &dropFile then
      (
         try (
            fileIn (pathConfig.appendPath extractDir "installer\\installer.ms");
            outlinerInstaller.install();
         ) catch (
            format "** Outliner: automatic installer failed. **\n"
            format "%\n" (getCurrentException());
            MessageBox "It seems that something went wrong with the installer!\nPlease download the latest installer from the website and start the installation manually." title:"Outliner installer error";
         )
         
      )
      
      deleteFile dropFile;
   )
   else
      messageBox "Failed to download installer." title:"Error";
),



function onUpdateDownloadCompleted s e =
(
   try
   (
      dotnet.removeEventHandlers outliner_update.webClient "DownloadStringCompleted";

      if (outliner == undefined) do
         return false;
               
      if (e.Cancelled) do
         return false;
         
      if (e.Error != undefined) do
      (
         if (outliner_update.manualUpdate) do
            messageBox ("Error retreiving update information:\n" + e.Error.Message) title:"Error";
         
         return false;
      )
      

      
      outliner_update.latestVersion = e.Result as float;
      local ignoreVersion = outliner.prefs.getValue #General #ignore_update_version;
      local currentVersion = outliner.product_info.getValue #General #version;
      
      if (outliner_update.latestVersion != undefined \
          AND outliner_update.latestVersion > currentVersion \
          AND (outliner_update.latestVersion > ignoreVersion \
               OR outliner_update.manualUpdate)) then
      (
         createDialog outlinerUpdateRollout 500 300;
      )
      else if (outliner_update.manualUpdate) do
      (
         local mb = dotNetClass "System.Windows.Forms.MessageBox";
         local mbBtn = dotNetClass "System.Windows.Forms.MessageBoxButtons";
         local mbIcon = dotNetClass "System.Windows.Forms.MessageBoxIcon";
         mb.Show ("You are running the latest Outliner version (" + \
                  (currentVersion as string) + ")") \
                  "No update available" \
                  mbBtn.OK \
                  mbIcon.Information;
      )
      
      if (outliner_update.checkCompleteFn != undefined) do
      (
         outliner_update.checkCompleteFn();
         outliner_update.checkCompleteFn = undefined;
      )
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),


   


function getUpdateVersionAsync =
(
   webClient = dotNetObject "System.Net.WebClient";
   
   local url = "http://script.threesixty.nl/outliner/update.php?";
   local args = createUpdateArgStr();        
   local getLatestUri = dotnetObject "System.Uri" (url + args);
   
   dotnet.addEventHandler webClient "DownloadStringCompleted" onUpdateDownloadCompleted;
   webClient.DownloadStringAsync getLatestUri;
),




function checkUpdateManual =
(
   manualUpdate = true;
   --outliner.prefs.setValue #General #ignore_update_version 0.0;
   getUpdateVersionAsync();
),

function checkUpdateAuto =
(
   try
   (
      local checkUpdates = outliner.prefs.getValue #General #checkForUpdates;
      if (not checkUpdates) do
         return false;

      local checkInterval = outliner.prefs.getValue #General #checkUpdatesInterval;
      local lastCheckTicks = outliner.prefs.getValue #General #lastUpdateCheck;
      local nowTicks = (dotNetClass "System.DateTime").Today.Ticks;
      local lastCheckSpan = dotNetObject "System.TimeSpan" (nowTicks - lastCheckTicks);
      if (lastCheckSpan.TotalDays < checkInterval) do
         return false;
      
      manualUpdate = false;   
      getUpdateVersionAsync();
      outliner.prefs.setValue #General #lastUpdateCheck nowTicks;
      
      return true;
   )
   catch
   (
      fileIn "crash_report.ms";
   )
),

function cancelCheckUpdate =
(
   webClient.CancelAsync();
),


function dispose =
(
   if (webClient != undefined) do
   (
      dotnet.removeEventHandlers webClient "DownloadStringCompleted";
      webClient = undefined;
   )
)

)--End struct.

outliner_update = outlinerUpdate();