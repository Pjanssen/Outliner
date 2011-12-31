outlinerNestedLayersCA = attributes outlinerNestedLayersCA \
                                    version:1 \
                                    attribID:#(0x2f06392b, 0x6e1e1077)
(
   parameters layerNesting
   (
      child_layers type:#maxObjectTab tabSizeVariable:true;
      parent_layers type:#maxObjectTab tabSizeVariable:true;
   )
   parameters layerProperties
   (
      layer_isHidden type:#boolTab tabSizeVariable:true;
      layer_isFrozen type:#boolTab tabSizeVariable:true;
      layer_boxMode type:#boolTab tabSizeVariable:true;
   )
   

   
   --Gets the index where the properties for the supplied layer are stored.
   function getLayerIndex layer = 
   (
      layer = layer.layerAsRefTarg;
      findItem child_layers layer;
   )
   
   --Adds an index entry for the supplied layer if it doesn't exist already.
   --Returns the index.
   function addLayerIndex layer = 
   (
      local layerIndex = this.getLayerIndex layer;
      
      if (layerIndex == 0) do
      (
         layerIndex = child_layers.count + 1;
         child_layers[layerIndex] = layer.layerAsRefTarg;
         parent_layers[layerIndex] = undefined;
         layer_isHidden[layerIndex] = layer.isHidden;
         layer_isFrozen[layerIndex] = layer.isFrozen;
         layer_boxMode[layerIndex] = layer.boxMode;
      )
      
      layerIndex;
   )
   
   --Removes the properties index from the property arrays.
   function deleteIndex index =
   (
      local propNames = getPropNames this;
      for p in propNames do
      (
         local prop = getProperty this p;
         if (((classof prop) == ArrayParameter) AND prop.count >= index) do
         (
            deleteItem prop index;
            setProperty this p prop;
         )
      )
   )
   
   function deleteLayerIndex layer =
   (
      local layerIndex = this.getLayerIndex layer;
      this.deleteIndex layerIndex;
   )
   
   
   
   --Removes this CA definition from the scene.
   function removeFromScene = 
   (
      local defName = #outlinerNestedLayersCA;
      --Loop through all CA definitions.
      for def in custAttributes.getSceneDefs() where (def.name == defName) do
      (
         --Remove the CA set from layers.
         local instances = custAttributes.getDefInstances def;
         for i in instances \
               where (owner = custAttributes.getOwner i) != undefined do
         (
            --Loop through all ca sets on the owner object and find one that
            --matches the one we want to remove. Delete has to be done using 
            --the index, since it has to be made unique first.
            for caIndex = 1 to (custAttributes.count owner) do
            (
               if (((custAttributes.get owner caIndex).name as name) == defName) do
               (
                  --Make CA set unique first, otherwise delete won't work..
                  custAttributes.makeUnique owner caIndex;
                  custAttributes.delete owner caIndex;
               )
            )
         )
         
         --Remove the nested layer custom attributes definition from the scene.
         try
         	custAttributes.deleteDef def;
         catch ()
      )
   )
   
   function removeDeletedLayers arr =
   (
      --Collect the indices of child layers that are not in the scene.
      local del = for i = 1 to arr.count \
                  where (c = arr[i]; \
                        (c == undefined OR \
                        (LayerManager.getLayerFromName c.name) == undefined)) \
                  collect i;
                        
      if (del.count == arr.count AND del.count > 0) then
         --Delete CA completely.
         this.removeFromScene();
      else
      (
         --Reverse-iterate through layers to delete (since items will be deleted).
         for i = del.count to 1 by -1 do
            this.deleteIndex del[i];
      )
   )
   
   --Cleans up this CA set.
   --Removes any entries of layers that are no longer in the scene.
   function cleanUp =
   (  
      removeDeletedLayers child_layers;
      removeDeletedLayers parent_layers;
   )
   
   
   function createPreSaveCallback =
   (
      callbacks.removeScripts id:#outliner_NestedLayers;
      
      local cbStr = ("
       local s = (refs.dependents rootnode)[1];
       for i = 1 to (custAttributes.count s) \
       where ((ca = custAttributes.get s i).name == \"outlinerNestedLayersCA\") do 
         ca.cleanUp();"
      );
      callbacks.addScript #filePreSave cbStr id:#outliner_NestedLayers;
      
      cbStr = ("
       local s = (refs.dependents rootnode)[1];
       for i = 1 to (custAttributes.count s) \
       where ((ca = custAttributes.get s i).name == \"outlinerNestedLayersCA\") do 
         ca.removeFromScene();"
      );
      callbacks.addScript #systemPreNew cbStr id:#outliner_NestedLayers;
   )
   
   
   on postCreate do
   (
      createPreSaveCallback();
   )
   
   on postLoad do 
   (
      createPreSaveCallback();
      
      --Check if the Outliner is installed, and print a message to the
      --Maxscript Listener if it isn't.
      global outlinerNestedLayersCA;
      if (not (GetQuietMode()) AND outlinerNestedLayersCA == undefined) do
      (
         local outliner_prefs_file = (GetDir #userScripts) + "/outliner_prefs.ini";
         if (not (doesFileExist outliner_prefs_file)) do
         (
            outlinerNestedLayersCA = this;
            
            format "Scene contains nested layers, but the Outliner was not found.\n";
            format "Visit http://outliner.threesixty.nl for more information.\n";
            format "To remove the nested layer data, use:\n";
            format "outlinerNestedLayersCA.removeFromScene()\n";
         )
      )
   )
)--End CA definition.



/*
The Nested Layers struct provides static methods to create and manage nested 
layers in 3dsmax, using a central CustomAttributes set on the rootnode of a 
scene. The CA set should not be used directly.
*/
struct outlinerNestedLayers
(

--Returns the CustomAttributes set on the rootnode.
function getCA = 
(
   try
   (
      custAttributes.get (refs.dependents rootnode)[1] outlinerNestedLayersCA;
   )
   catch fileIn "crash_report.ms";
),

--Adds the CustomAttributes set to the rootNode if it isn't on there already.
--Returns the CA set.
function addCA =
(
   try
   (
      local ca = outlinerNestedLayers.getCA();
      if (ca == undefined) do
      (
         if (custAttributes.add (refs.dependents rootnode)[1] outlinerNestedLayersCA) do
            ca = outlinerNestedLayers.getCA();
      )
      ca;
   )
   catch fileIn "crash_report.ms";
),





--Returns the parent layer for the supplied layer argument, 
--returns undefined for a rootlayer.
function getParent layer =
(
   try
   (
      local parentLayer = undefined;
      
      local ca = outlinerNestedLayers.getCA();
      if (ca != undefined) do
      (
         local layerIndex = ca.getLayerIndex layer;
         if (layerIndex > 0) do
         (
            --Using getLayerFromName to avoid returning a deleted layer.
            local l = ca.parent_layers[layerIndex];
            if (l != undefined AND (LayerManager.getLayerFromName l.name) != undefined) do
               parentLayer = l;
         )
      )
      
      parentLayer;
   )
   catch fileIn "crash_report.ms";
),


--Sets the parent layer for the supplied layer argument. 
--Use undefined to unlink the layer.
mapped function setParent layer parentLayer =
(
   try
   (
      local ca = outlinerNestedLayers.addCA();
      if (ca != undefined) do
      (
         local layerIndex = ca.addLayerIndex layer;
         if (layerIndex > 0) do
         (
            if (parentLayer == undefined) then
            (
               --Reset the layer's original properties first.
               outlinerNestedLayers.resetLayerProperties layer;
               --Then delete the layer's data from the CA.
               ca.deleteIndex layerIndex;
            )
            else
            (
               --Set the parent handle in the CA.
               ca.parent_layers[layerIndex] = parentLayer.layerAsRefTarg;
               --Then update the layer's properties based on it's new parent.
               outlinerNestedLayers.updateLayerProperties layer;
            )
         )
      )
      
      --Update tree.
      if (outliner_status != undefined AND outliner_status.windowOpen) do
      (
      	local pHandle = if (parentLayer == undefined) then outliner.tree.Scene.RootHandle \
      																 else (getHandleByAnim parentLayer.layerAsRefTarg);
      	outliner.tree.SetLayerParent (getHandleByAnim layer.layerAsRefTarg) \
      										   pHandle;
      )
      
      ok;
   )
   catch fileIn "crash_report.ms";
),



--Returns an array with layers that are children of the supplied layer.
--If recursive is not supplied or false, then only layers directly beneath
--the supplied layer are included. Otherwise it includes the entire layer 
--hierarchy downwards.
function getChildren layer recursive:false =
(
   try
   (
      local children = #();
      
      local ca = outlinerNestedLayers.getCA();
      if (ca != undefined) do
      (
         layer = layer.layerAsRefTarg;
            
         for i = 1 to ca.child_layers.count \
                   where (ca.parent_layers[i] == layer) do
         (
            local childLayer = ca.child_layers[i];
            
            append children childLayer;
            
            if (recursive) do
            (
               join children (outlinerNestedLayers.getChildren childLayer \
                                                         recursive:recursive);
            )
         )
      )
         
      --Return children array.
      children;
   )
   catch fileIn "crash_report.ms";
),





--Returns the value of a property on the layer. It will return the layer's 
--own value, regardless of whether it has been overridden by a parent layer.
function getLayerProperty layer prop = 
(
   try
   (
      local ca = outlinerNestedLayers.getCA();
      local value;
      
      if (ca != undefined AND (isProperty ca ("layer_" + prop))) do
      (
         local layerIndex = ca.getLayerIndex layer;
         local propArray = getProperty ca ("layer_" + prop);
         if (layerIndex != 0 AND propArray[layerIndex] != undefined) do
            value = propArray[layerIndex];
      )
      
      if (value == undefined AND (isProperty layer prop)) then
         value = getProperty layer prop;
         
      value;
   )
   catch fileIn "crash_report.ms";
),


--Sets a property on the layer and propagates it to its children.
mapped function setLayerProperty layer prop value isSetByParent:false = 
(
   try
   (
      if (isProperty layer prop) do
      (
         local ca = outlinerNestedLayers.getCA();
         local parentLayer = outlinerNestedLayers.getParent layer;
         if (parentLayer != undefined AND ca != undefined \
                                      AND (isProperty ca ("layer_" + prop))) then
         (           
            local parentValue = getProperty parentLayer prop;
            local ownValue;
            
            --Get / store own value.
            if (not isSetByParent AND not parentValue) then
            (
               local layerIndex = ca.getLayerIndex layer;
               local propArray = getProperty ca ("layer_" + prop);
               propArray[layerIndex] = value;
               setProperty ca ("layer_" + prop) propArray;
               ownValue = value;
            )
            else
               ownValue = outlinerNestedLayers.getLayerProperty layer prop;
               
            setProperty layer prop (parentValue OR ownValue);
         )
         else
         (
            --Only set the property on the layer itself.
            setProperty layer prop value;
         )
         
         --Propagate to children.
         outlinerNestedLayers.setLayerProperty \
               (outlinerNestedLayers.getChildren layer) \
               prop value isSetByParent:true;
      )
      
      ok;
   )
   catch fileIn "crash_report.ms";
),


--Updates the properties of the layer to incorporate the parent's values.
function updateLayerProperties layer = 
(
   try
   (
      local parentLayer = outlinerNestedLayers.getParent layer;

      if (parentLayer != undefined) then
      (
         outlinerNestedLayers.setLayerProperty layer "isHidden" \
               (outlinerNestedLayers.getLayerProperty layer "isHidden" OR \
               ((parentLayer != layer) AND parentLayer.isHidden)) \
               isSetByParent:true;
                   
         outlinerNestedLayers.setLayerProperty layer "isFrozen" \
               (outlinerNestedLayers.getLayerProperty layer "isFrozen" OR \
               ((parentLayer != layer) AND parentLayer.isFrozen)) \
               isSetByParent:true;
                   
         outlinerNestedLayers.setLayerProperty layer "boxMode" \
               (outlinerNestedLayers.getLayerProperty layer "boxMode" OR \
               ((parentLayer != layer) AND parentLayer.boxMode)) \
               isSetByParent:true;
      )
      
      ok;
   )
   catch fileIn "crash_report.ms";
),

--Sets the properties of the layer to those stored in the CA.
function resetLayerProperties layer =
(
   try
   (
      setProperty layer #isHidden \
                  (outlinerNestedLayers.getLayerProperty layer "isHidden");
      setProperty layer #isFrozen \
                  (outlinerNestedLayers.getLayerProperty layer "isFrozen");
      setProperty layer #boxMode \
                  (outlinerNestedLayers.getLayerProperty layer "boxMode");
                  
      ok;
   )
   catch fileIn "crash_report.ms";
)

)--End struct.