struct outlinerCrashReport
(
exception,
stackStream,
stackSummary,
stackFirstLevel,

prefs_file = (GetDir #userScripts) + "/outliner_prefs.ini",
product_info_file = (GetDir #userScripts) + "/outliner_product_info.ini",



function createStackSummary stackStream firstLevelOnly:false =
(
   if (stackStream == undefined) do
      return "";
   
   local stackSummary = "";
   
   try
   (
      seek stackStream 0;
      
      local numLevelsParsed = 0;
      
      while (not (eof stackStream) AND \
            (not firstLevelOnly OR numLevelsParsed < 2)) do
      (
         numLevelsParsed += 1;
         
         --Stop reading if all stack levels have been parsed.
         if ((skipToString stackStream "**\t[stack level:") == undefined) do
            exit;
         
         --Skip the stack level 0.
         if (numLevelsParsed == 1) do
            continue;
         
         if (skipToString stackStream "**\t" != undefined) do
         (
            if (stackSummary != "") do
               stackSummary += "\n";
            
            stackSummary += (readDelimitedString stackStream ";\n");
   
            if (eof stackStream) do
               exit;
   
            
            
            local fileStr = readDelimitedString stackStream ";";
            local fileNamePos = findString fileStr "\\outliner\\";
            if (fileNamePos != undefined) do
            (
               stackSummary += " in ";
               stackSummary += substring fileStr (fileNamePos + 10) -1;
            )
            
            local lineStr = readDelimitedString stackStream "\n";
            local linePos = findString lineStr " line:";
            if (linePos != undefined) do
               stackSummary += substring lineStr linePos -1;
         )
      )
   )
   catch
   (
      stackSummary += "\n--Error summarizing stack--";
   )
   
   --Return summary string.
   stackSummary;
),



/**
 * WRITE EXCEPTION DATA TO FILE
 */
function writeExceptionDataToFile file =
(
   local stream;
   try
   (
      stream = createFile file;
      
      if (stream == undefined) then
         return false;
      
      format "Exception\n---------\n" to:stream;
      format "%\n\n" exception to:stream;
      
      format "Stack Summary\n------------\n" to:stream;
      format "%\n\n" stackSummary to:stream;
      
      format "Full Stack\n-----------\n" to:stream;
      format "%" (stackStream as string) to:stream;
      
      close stream;
   )
   catch 
   (
      try ( close stream; ) catch ();
   )
   
   true;
),



/**
 * WRITE OUTLINER STATUS TO STREAM
 */
function writeOutlinerStatus stream =
(
   format "Outliner Status\n--------------\n" to:stream;
   local errStr = "-Unable to retreive-\n\n";
   if (outliner_status == undefined) then
      format errStr to:stream;
   else
   (
      format ".windowOpen: " to:stream;
      try (
         format "%\n" outliner_status.windowOpen to:stream;
      ) catch (
         format errStr to:stream;
      )
      
      format ".optionsOpen: " to:stream;
      try (
         format "%\n" outliner_status.optionsOpen to:stream;
      ) catch (
         format errStr to:stream;
      )
      
      format ".filterConfigOpen: " to:stream;
      try (
         format "%\n" outliner_status.filterConfigOpen to:stream;
      ) catch (
         format errStr to:stream;
      )
      
      format ".sortModeOpen: " to:stream;
      try (
         format "%\n" outliner_status.sortModeOpen to:stream;
      ) catch (
         format errStr to:stream;
      )
      
      format ".closingOutliner: " to:stream;
      try (
         format "%\n\n" outliner_status.closingOutliner to:stream;
      ) catch (
         format errStr to:stream;
      )
   )
),





/**
 * DUMP SCENE
 */
function dumpScene stream nodeList depth =
(
   if (stream != undefined AND nodeList != undefined) do
   (
      for obj in nodeList do
      (
         for i = 1 to depth do format "|--" to:stream;
         local objHandle = GetHandleByAnim obj;
         local objClass = getClassName obj;
         format "% (% - %)\n" obj.name objHandle objClass to:stream;
         dumpScene stream obj.children (depth + 1);
      )
   )
),



/**
 * DUMP OUTLINER TREENODES
 */
function dumpTreeNodes stream nodeList depth =
(
   if (stream != undefined AND nodeList != undefined) do
   (
      local ienum = nodeList.GetEnumerator();
      while (ienum.MoveNext()) do
      (
         local tn = ienum.current;
         if (tn != undefined) do
         (
            for i = 1 to depth do format "|--" to:stream;
            local tagHandle = "undefined Tag";
            if (tn.Tag != undefined) do
               tagHandle = tn.Tag.Handle;
            format "% (%)\n" tn.Text tagHandle to:stream;
            dumpTreeNodes stream tn.Nodes (depth + 1)
         )
      )
   )
),


/**
 * DUMP OUTLINER SCENE HIERARCHY
 */
function dumpOutlinerSceneHierarchy stream nodeList depth =
(
   if (stream != undefined AND nodeList != undefined) do
   (
      local ienum = nodeList.GetEnumerator();
      while (ienum.MoveNext()) do
      (
         local n = ienum.current;
         if (n != undefined) do
         (
            for i = 1 to depth do format "|--" to:stream;
            format "% (%)\n" n.name n.handle to:stream;
            dumpOutlinerSceneHierarchy stream n.ChildNodes (depth + 1)
         )
      )
   )
),


/**
 * DUMP OUTLINER SCENE LAYERS
 */
function dumpOutlinerSceneLayers stream nodeList depth =
(
   if (stream != undefined AND nodeList != undefined) do
   (
      local ienum = nodeList.GetEnumerator();
      while (ienum.MoveNext()) do
      (
         local n = ienum.current;
         if (n != undefined) do
         (
            local t = (n.GetType()).ToString();
            for i = 1 to depth do format "|--" to:stream;
            
            if (t == "Outliner.Scene.OutlinerLayer") then
            (
               format "Layer: % (%)\n" n.name n.Handle to:stream;
               dumpOutlinerSceneLayers stream n.ChildNodes (depth + 1);
            )
            else
            (
               format "% (%)\n" n.name n.Handle to:stream;
            )
         )
      )
   )
),


function dumpOutlinerSceneObjectInfo stream =
(
   if (stream != undefined) do
   (
      local objs = outliner.tree.Scene.Objects;
      local ienum = objs.GetEnumerator();
      while (ienum.MoveNext()) do
      (
         local obj = ienum.current;
         format "name:\t\t%\n" obj.name to:stream;
         format "handle:\t\t%\n" obj.handle to:stream;
         format "parentHandle:\t%\n" obj.parentHandle to:stream;
         format "objectNr:\t%\n" obj.ObjectNr to:stream;
         format "max object:\t%\n" (GetAnimByHandle obj.handle) to:stream;
         format "----------------------------------\n" to:stream;
      )
   )
),


/**
 * WRITE OUTLINER DATA TO FILE
 */
function getOutlinerVersion =
(
   local outlinerVersion = "unknown";
   if (hasINISetting product_info_file "General" "version") then
      outlinerVersion = getINISetting product_info_file "General" "version";
      
   --Return outliner version.
   outlinerVersion;
),

function pTime t =
(
   if (t < 10) then
      "0" + (t as string);
   else
      t;
),
function doHeapCheck =
(
   local heapChk = heapCheck();
   if (heapChk == -1) then
      return "-1 - Heap has not been initialized (_HEAPEMPTY)";
   else if (heapChk == -3) then
      return "-3 - Initial header information is bad or cannot be found. (_HEAPBADBEGIN)";
   else if (heapChk == -4) then
      return "-4 - Bad node has been found or heap is damaged. (_HEAPBADNODE)";
   else if (heapChk == -6) then
      return "-6 - Pointer into Heap is not valid (_HEAPBADPTR)";
   else
      return "OK - Heap appears to be consistent (_HEAPOK)";
),
function writeOutlinerDataToFile file =
(
   local stream = createFile file;
   
   if (stream == undefined) then
      return false;
   
   --Write Date & Time
   local t = getLocalTime();
   format "Error occurred at: %-%-% %:%:%\n" (pTime t[4]) \
                                             (pTime t[2]) \
                                             t[1] \
                                             (pTime t[5]) \
                                             (pTime t[6]) \
                                             (pTime t[7]) to:stream;
   
   --Write 3dsmax version
   local maxv = maxVersion();
   format "3dsmax version: % %\n" (if (maxv[1] < 10) then maxv[1] \
                                                     else 2008 + (maxv[1] / 1000 - 10)) \
                                  (if (is64bitapplication()) then "64bit" \
                                                             else "32bit") to:stream;
   
   format "Heap Size: %\n" (heapSize as string) to:stream;
   format "Heap Free: %\n" (heapFree as string) to:stream;
   format "Heap Check: %\n\n" (doHeapCheck()) to:stream;
   
   --Write Outliner status to stream.
   writeOutlinerStatus stream;
   
   
   format "\n\nScene Hierarchy\n---------------\n" to:stream;
   try (
      local rootNodes = for o in objects where (o.parent == undefined) collect o;
      dumpScene stream rootNodes 0;
   ) catch (
      format "Error writing scene hierarchy\n%\n" (getCurrentException()) to:stream;
   )
   
   
   format "\n\nOutliner TreeNodes\n------------------\n" to:stream;
   try ( 
      dumpTreeNodes stream outliner.tree.Nodes 0;
   ) catch ( 
      format "Error writing treenodes\n%\n" (getCurrentException()) to:stream; 
   )
   
   
   format "\n\nOutliner Scene Hierarchy\n------------------------\n" to:stream;
   try (
      dumpOutlinerSceneHierarchy stream outliner.tree.Scene.RootObjects 0;
   ) catch (
      format "Error writing Outliner Scene Hierarchy\n%\n" (getCurrentException()) to:stream;
   )
   
   
   format "\n\nOutliner Scene Layers\n---------------------\n" to:stream;
   try (
      dumpOutlinerSceneLayers stream outliner.tree.Scene.RootLayers 0;
   ) catch (
      format "Error writing Outliner Scene Layers\n%\n" (getCurrentException()) to:stream;
   )
   
   
   format "\n\nOutliner Scene Object Info\n--------------------------\n" to:stream;
   try (
      dumpOutlinerSceneObjectInfo stream;
   ) catch (
      format "Error writing Outliner Scene Object Info\n%\n" (getCurrentException()) to:stream;
   )
   
   close stream;
      
   true;
),


stackFile,
writeStackSuccess,
outlinerDataFile,
writeOutlinerDataSuccess,
detailsFile,
packFile,
webClient,


function deleteTempFiles =
(
   try ( deleteFile stackFile; ) catch ()
   try ( deleteFile outlinerDataFile; ) catch ()
   try ( deleteFile detailsFile; ) catch ()
   try ( deleteFile packFile; ) catch ()
),

function uploadCompleted s e =
(
   local mb = dotNetClass "System.Windows.Forms.MessageBox";
   local mbBtn = dotNetClass "System.Windows.Forms.MessageBoxButtons";
   local mbIcon = dotNetClass "System.Windows.Forms.MessageBoxIcon";

   if (e.Error == undefined AND e.Result != undefined \
                            AND e.Result.count == 1 \
                            AND e.Result[1] == 49) then
   (
      mb.Show "Error report sent successfully.\nThank you." \
              "Report sent" \
              mbBtn.OK \
              mbIcon.Information;
   )
   else
   (
      local msg = "Failed to send error report.";
      if (e.Error != undefined) do
         msg += "\n" + e.Error.Message;
      mb.Show msg "Failed to send" mbBtn.OK mbIcon.Warning;
   )
   
   dotNet.removeEventHandlers e.UserState.value.webClient "UploadFileCompleted";
   e.UserState.value.webClient = undefined;
   
   e.UserState.value.deleteTempFiles();
),

function sendReport report_instance fromEmail details =
(
   local filesToPack = #(prefs_file, product_info_file);
   if (writeStackSuccess) do append filesToPack stackFile;
   if (writeOutlinerDataSuccess) do append filesToPack outlinerDataFile;
   if (fromEmail != "" OR details != "") do
   (
      detailsFile = (GetDir #temp) + "/outliner_crash_details.txt";
      local stream = createFile detailsFile;
      if (stream != undefined) do
      (
         format "Email address: %\n" fromEmail to:stream;
         format "Details: %" details to:stream;
         close stream;
         append filesToPack detailsFile;
      )
   )
   
   packFile = (GetDir #temp) + "/outliner_crash_report.zip";
   local packResult = maz packFile filesToPack;
   
   if (packResult > 0) then
   (
      try 
      (  
         webClient = dotNetObject "System.Net.WebClient";
         local url = "http://script.threesixty.nl/outliner/crash_report.php?from_email=";
         url += fromEmail;
         url += "&summary=Outliner version: ";
         try (
            url += getOutlinerVersion();
         ) catch (
            url += "-Unable to retrieve-";
         )
         url += "\r\n\r\nException:\r\n";
         url += report_instance.exception;
         url += "\r\n\r\nStack:\r\n";
         url += report_instance.stackSummary; --report_instance.stackFirstLevel;
         url += "\r\n\r\nEmail address: ";
         if (fromEmail != "") then
            url += fromEmail;
         else
            url += "-Not provided-";
         url += "\r\n\r\nDetails: ";
         if (details != "") then
            url += details;
         else
            url += "-Not provided-";
                  
            local uploadUri = dotNetObject "System.Uri" url;
            dotNet.addEventHandler webClient "UploadFileCompleted" uploadCompleted;
            
         
            webClient.UploadFileAsync uploadUri \
                                      "POST" \
                                      packFile \
                                      (dotNetMXSValue report_instance);
        ) catch 
        (
         messageBox "Failed to send error report." "Error";
         deleteTempFiles();
        )
   )
   else
      deleteTempFiles();
),


dialog_w = 360,
dialog_h = 535,

crashReport_rollout = rollout crashReport_rollout "Outliner Error Report"
(
   local report_instance;
   local send_report = false;
   local dialog_w = 360;
   local dialog_h = 535;
   local marginX = 5;
   local marginY = 5;
   local ctrlX = 15;
   local txtDY = 16;
   local ctrlDY = 18;
   
   local grpW = dialog_w - marginX * 2;
   local infoGrpH = 120;
   groupBox infoGrp "Information" width:grpW height:infoGrpH pos:[marginX, marginY];
   label errTitle "An error occurred in the Outliner." pos:[ctrlX, marginY + ctrlDY];
   label repInfoLbl1 "A report of this error has been generated. Please click 'Send Report'" pos:[ctrlX, marginY + ctrlDY * 2.5];
   label repInfoLbl2 "to send the report to the developer and help improve the quality of" pos:[ctrlX, marginY + ctrlDY * 2.5 + txtDY];
   label repInfoLbl3 "this tool. The collected data will be treated confidentially and used" pos:[ctrlX, marginY + ctrlDY * 2.5 + txtDY * 2];
   label repInfoLbl4 "only to analyse the cause of the crash." pos:[ctrlX, marginY + ctrlDY * 2.5 + txtDY * 3];
      
   local reportGrpY = marginY + infoGrpH + marginY;
   local reportGrpH = 100;
   groupBox reportGrp "Report Contents" width:grpW height:reportGrpH pos:[marginX, reportGrpY];
   hyperlink contentLink1 "- Information about the exception and a stack trace." pos:[ctrlX, reportGrpY + ctrlDY + 2];
   hyperlink contentLink2 "- The Outliner settings file." pos:[ctrlX, reportGrpY + ctrlDY * 2 + 2];
   hyperlink contentLink3 "- Information about the current scene." pos:[ctrlX, reportGrpY + ctrlDY * 3 + 2];
   label contentLbl3 "- Optional: your email address and supplied details." pos:[ctrlX, reportGrpY + ctrlDY * 4 + 2];
   
   local addInfoGrpY = reportGrpY + reportGrpH + marginY;
   local addInfoGrpH = 260;
   groupBox addInfoGrp "Additional Information" width:grpW height:addInfoGrpH pos:[marginX, addInfoGrpY];
   label repInfoLbl5 "In addition to the error data, you can provide a description of what" pos:[ctrlX, marginY + addInfoGrpY + ctrlDY];
   label repInfoLbl6 "you were doing when the error occured. If you supply your email" pos:[ctrlX, marginY + addInfoGrpY + ctrlDY + txtDY];
   label repInfoLbl7 "address, you'll be informed when the issue is resolved." pos:[ctrlX, marginY + addInfoGrpY + ctrlDY + txtDY * 2];
      
   label emailLbl "Your Email Address" pos:[ctrlX, addInfoGrpY + txtDY * 2.5 + ctrlDY * 2];
   edittext emailTxt "" pos:[ctrlX - 5, addInfoGrpY + txtDY * 2.5 + ctrlDY * 3];
   label detailsLbl "Details" pos:[ctrlX, addInfoGrpY + txtDY * 2.5 + ctrlDY * 4 + 5];
   edittext detailsTxt "" height:115 pos:[ctrlX - 5, addInfoGrpY + txtDY * 2.5 + ctrlDY * 5 + 5];
   
   
   local btnW = 80;
   local btnH = 24;
   button sendBtn "Send Report" width:btnW height:btnH pos:[dialog_w - btnW * 2 - marginX * 2, dialog_h - btnH - marginY];
   button cancelBtn "Don't Send" width:btnW height:btnH pos:[dialog_w - btnW - marginX, dialog_h - btnH - marginY];
   
   function close =
   (
      destroyDialog crashReport_rollout;
   )
   
   on sendBtn pressed do
   (
      setINISetting report_instance.product_info_file "General" "crashReportEmail" emailTxt.text;
      
      report_instance.sendReport report_instance emailTxt.text detailsTxt.text;
      send_report = true;
      close();
   )
   
   on cancelBtn pressed do
      close();
      
   on crashReport_rollout close do
   (
      if (not send_report) do
         report_instance.deleteTempFiles();  
         
      global outliner_handling_exception = false;
   )
),




function handle_exception report_instance =
(
   global outliner_handling_exception

   --not using "not" statement because the variable could be undefined.
   if (outliner_handling_exception != true) do
   (
      outliner_handling_exception = true;
      
      exception = getCurrentException();
      
      stackStream = stringStream "";
      stack to:stackStream;
      stackFirstLevel = createStackSummary stackStream firstLevelOnly:true;
      stackSummary = createStackSummary stackStream;
      
      
      stackFile = (GetDir #temp) + "/outliner_crash_stack.txt";
      writeStackSuccess = writeExceptionDataToFile stackFile;
      
      outlinerDataFile = (GetDir #temp) + "/outliner_crash_data.txt";
      writeOutlinerDataSuccess = writeOutlinerDataToFile outlinerDataFile;
   
      try (
         outliner.close();
      ) catch ()

      try 
      (
         createDialog crashReport_rollout dialog_w dialog_h;
         crashReport_rollout.report_instance       = report_instance;
         crashReport_rollout.contentLink1.address  = stackFile;
         crashReport_rollout.contentLink2.address  = prefs_file;
         crashReport_rollout.contentLink3.address  = outlinerDataFile;
         crashReport_rollout.emailTxt.text         = getINISetting product_info_file \
                                                                   "General" \
                                                                   "crashReportEmail";
      ) catch ()
   )
)

)--End struct.

outliner_crash_report = outlinerCrashReport();
outliner_crash_report.handle_exception outliner_crash_report;