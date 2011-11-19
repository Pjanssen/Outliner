struct outliner_crash_report
(
	exception,
	stackFull,
	stackSummary,
	
	/**
	 * WRITE EXCEPTION DATA TO FILE
	 */
	function writeExceptionDataToFile file =
	(
		local stream = createFile file;
		
		if (stream == undefined) then
			return false;
		
		format "Exception\n---------\n" to:stream;
		format "%\n\n" exception to:stream;
		
		format "Stack\n------\n" to:stream;
		format "%" stackFull to:stream;
		
		close stream;
		
		true;
	),
	
	
	
	
	/**
	 * WRITE OUTLINER SETTINGS TO STREAM
	 */
	function writeOutlinerSettings stream =
	(
		format "Outliner Settings\n-----------------\n" to:stream;
		local errStr = "Unable to retreive\n";
		if (outliner == undefined) then
			format errStr to:stream;
		else
		(
			format "ListMode: " to:stream;
			try (
				local lMode = outliner.tree.listmode.value__;
				format "%\n" (if (lMode == 0) then "Hierarchy" else if (lMode == 1) then "Layer" else "Material") to:stream;
			) catch (
				format errStr to:stream;
			)
			
			format "SortMode: " to:stream;
			try (
				format "%\n" (outliner.prefs.getValue #Tree #sortMode) to:stream;
			) catch (
				format errStr to:stream;
			)
			
			format "HideGroupMembersInLayerMode: " to:stream;
			try (
				format "%\n" outliner.tree.HideGroupMembersLayerMode to:stream;
			) catch (
				format errStr to:stream;
			)
			
			format "Filter Enabled: " to:stream;
			try (
				format "%\n" outliner.tree.Filter.Enabled to:stream;
			) catch (
				format errStr to:stream;
			)
			
			format "Filter: " to:stream;
			try (
				format "%\n" (outliner.prefs.getValue #Tree #objFilter) to:stream;
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
	function pTime t =
	(
		if (t < 10) then
			"0" + (t as string);
		else
			t;
	),
	function writeOutlinerDataToFile file =
	(
		local stream = createFile file;
		
		if (stream == undefined) then
			return false;
		
		--Write Date & Time
		local t = getLocalTime();
		format "Error occurred at: %-%-% %:%:%\n" (pTime t[4]) (pTime t[2]) t[1] (pTime t[5]) (pTime t[6]) (pTime t[7]) to:stream;
		
		--Write 3dsmax version
		local maxv = maxVersion();
		format "3dsmax version: % %\n" (if (maxv[1] < 10) then maxv[1] else 2008 + (maxv[1] / 1000 - 10)) (if (is64bitapplication()) then "64bit" else "32bit") to:stream;
		
		--Write Outliner version.
		local outlinerVersion = "unknown";
		if (outliner != undefined) do outlinerVersion = outliner.version;
		format "Outliner version: %\n\n" outlinerVersion to:stream;
		
		
		--Write Outliner settings to stream.
		writeOutlinerSettings stream;
		
		
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
	packFile,
	webClient,
	
	function uploadCompleted s e =
	(
		local mb = dotNetClass "System.Windows.Forms.MessageBox";
		local mbBtn = dotNetClass "System.Windows.Forms.MessageBoxButtons";
		local mbIcon = dotNetClass "System.Windows.Forms.MessageBoxIcon";

		if (e.Error == undefined AND e.Result != undefined AND e.Result.count == 1 AND e.Result[1] == 49) then
			mb.Show "Error report sent successfully.\nThank you." "Report sent" mbBtn.OK mbIcon.Information;
		else
		(
			local msg = "Failed to send error report.";
			if (e.Error != undefined) do
				msg += "\n" + e.Error.Message;
			mb.Show msg "Failed to send" mbBtn.OK mbIcon.Warning;
		)
		
		dotNet.removeEventHandlers e.UserState.value.webClient "UploadFileCompleted";
		e.UserState.value.webClient = undefined;
		
		deleteFile e.UserState.value.packFile;
	),
	
	function sendReport report_instance fromEmail details =
	(
		local filesToPack = #();
		if (writeStackSuccess) do append filesToPack stackFile;
		if (writeOutlinerDataSuccess) do append filesToPack outlinerDataFile;
		if (fromEmail != "" OR details != "") do
		(
			local detailsFile = (GetDir #temp) + "/outliner_crash_details.txt";
			local stream = createFile detailsFile;
			if (stream != undefined) do
			(
				format "Email address:\n%\n\n" fromEmail to:stream;
				format "Details:\n%" details to:stream;
				close stream;
				append filesToPack detailsFile;
			)
		)
		
		packFile = (GetDir #temp) + "/outliner_crash_report.zip";
		local packResult = maz packFile filesToPack;
		
		for f in filesToPack do deleteFile f;
		
		if (packResult > 0) do
		(
			try 
			(	
				webClient = dotNetObject "System.Net.WebClient";
				local url = "http://script.threesixty.nl/outliner/crash_report.php?from_email=";
				url += fromEmail;
				url += "&summary=Exception:\r\n";
				url += report_instance.exception;
				url += "\r\n\r\nStack summary:\r\n";
				url += report_instance.stackSummary;
				url += "\r\n\r\nEmail address:\r\n";
				if (fromEmail != "") then
					url += fromEmail;
				else
					url += "-Not provided-";
				url += "\r\n\r\nDetails:\r\n";
				if (details != "") then
					url += details;
				else
					url += "-Not provided-";
							
	            local uploadUri = dotNetObject "System.Uri" url;
	            dotNet.addEventHandler webClient "UploadFileCompleted" uploadCompleted;
	            
            
	            webClient.UploadFileAsync uploadUri "POST" packFile (dotNetMXSValue report_instance);
	        ) catch 
	        (
	        	messageBox "Failed to send error report." "Error";
	        )
		)
	),
	
	dialog_w = 360,
	dialog_h = 520,
	
	crashReport_rollout = rollout crashReport_rollout "Outliner Error Report"
	(
		local report_instance;
		local dialog_w = 360;
		local dialog_h = 520;
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
			label repInfoLbl4 "only to analyse the cause of the error." pos:[ctrlX, marginY + ctrlDY * 2.5 + txtDY * 3];
			
		local reportGrpY = marginY + infoGrpH + marginY;
		local reportGrpH = 80;
		groupBox reportGrp "Report Contents" width:grpW height:reportGrpH pos:[marginX, reportGrpY];
			hyperlink contentLink1 "- Information about the Outliner settings and the current scene." pos:[ctrlX, reportGrpY + ctrlDY + 2];
			hyperlink contentLink2 "- Information about the exception and a stack trace." pos:[ctrlX, reportGrpY + ctrlDY * 2 + 2];
			label contentLbl3 "- Optional: your email address and supplied details." pos:[ctrlX, reportGrpY + ctrlDY * 3 + 2];
		
		local addInfoGrpY = reportGrpY + reportGrpH + marginY;
		local addInfoGrpH = 260;
		groupBox addInfoGrp "Additional Information" width:grpW height:addInfoGrpH pos:[marginX, addInfoGrpY];
			label repInfoLbl5 "In addition to the error data, you can provide a description of what" pos:[ctrlX, marginY + addInfoGrpY + ctrlDY];
			label repInfoLbl6 "you were doing when the error occured. Please also supply your" pos:[ctrlX, marginY + addInfoGrpY + ctrlDY + txtDY];
			label repInfoLbl7 "email address so I can contact you should I require more information." pos:[ctrlX, marginY + addInfoGrpY + ctrlDY + txtDY * 2];
			
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
			try (
				outliner.prefs.setValue #General #crashReportEmail emailTxt.text;
			) catch ()
			
			report_instance.sendReport report_instance emailTxt.text detailsTxt.text;
			close();
		)
		
		on cancelBtn pressed do
			close();
			
		on crashReport_rollout close do
		(
			global outliner_handling_exception = false;
		)
	),
	

	
	
	function handle_exception report_instance additionalInfo:"" =
	(
		global outliner_handling_exception

		if (outliner_handling_exception != true) do
		(
			outliner_handling_exception = true;
			
			exception = getCurrentException();
			
			local tmpStack = stringStream "";
			stack to:tmpStack;
			seek tmpStack 0;
			skipToString tmpStack "**	[stack level: 1]";
			local pos = (filePos tmpStack) - 19;
			skipToNextLine tmpStack;
			stackSummary = readLine tmpStack;
			seek tmpStack pos;
			stackFull = readDelimitedString tmpStack "";
			
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
				crashReport_rollout.report_instance			= report_instance;
				crashReport_rollout.contentLink1.address	= outlinerDataFile;
				crashReport_rollout.contentLink2.address	= stackFile;
				crashReport_rollout.emailTxt.text			= outliner.prefs.getValue #General #crashReportEmail;
			) catch ()
		)
	)
)