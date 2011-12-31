--This method converts all pre 2.1 nested layer definitions to the new
--nested layer definition and then removes the old CA sets from the scene.
function outliner_convertLegacyNestedLayers =
(
   --Skip if loaded file was a render preset.
   if (callbacks.notificationParam() == 2) do
      return ok;
   
   local mb = dotNetClass "System.Windows.Forms.MessageBox";
	local mbBtn = dotNetClass "System.Windows.Forms.MessageBoxButtons";
	local mbIcon = dotNetClass "System.Windows.Forms.MessageBoxIcon";
		
   try
   (
      local numConverted = 0;
      local defName = #outlinerNestedLayerData;
      --Loop through all CA definitions.
      for def in custAttributes.getSceneDefs() where (def.name == defName) do
      (
         local instances = custAttributes.getDefInstances def;
         for i in instances \
               where (l = custAttributes.getOwner i) != undefined do
         (
            --Set parent layer in new nested layers system.
            outlinerNestedLayers.setParent l l.outliner_parentLayer;
            
            --Loop through all ca sets on the owner object and find one that
            --matches the one we want to remove. Delete has to be done using 
            --the index, since it has to be made unique first.
            for caIndex = 1 to (custAttributes.count l) do
            (
               if (((custAttributes.get l caIndex).name as name) == defName) do
               (
                  --Make CA set unique first, otherwise delete won't work..
                  custAttributes.makeUnique l caIndex;
                  custAttributes.delete l caIndex;
               )
            )
            
            numConverted += 1;
         )
         --Remove the nested layer custom attributes definition from the scene.
         custAttributes.deleteDef def;
      )
      
      if (numConverted > 0) do
      (
         --Refresh Outliner.
         if (outliner_status != undefined AND outliner_status.windowOpen) do
         (
            outliner.pushSceneToTree();
   			outliner.tree.FillTree();
         )
         
         mb.Show ("Successfully converted " + (numConverted as string) + \
                  " nested layer definitions.\n" + \
                  "Please save the scene.") \
                  "Outliner Nested layers conversion" \
                  mbBtn.OK \
                  mbIcon.Information;
      )
   )
   catch
   (
      format "Converting nested layer definitions failed.\n";
      format "%\n" (getCurrentException());
      mb.Show ("Converting nested layers definitions failed.\n" + \
              "See maxscript listener for details") \
              "Outliner nested layers conversion" \
              mbBtn.OK \
              mbIcon.Warning;
   )
)


callbacks.removeScripts id:#outliner_legacy_nestedlayers;
callbacks.addScript #filePostOpen \
                    "outliner_convertLegacyNestedLayers()" \
                    id:#outliner_legacy_nestedlayers;