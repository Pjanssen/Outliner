(
global outliner_layerprops;

local margin = 5;
local ctrlX = 10;
local chkbxDY = 18;


rollout outliner_layerprops_layerinfo "Layer information"
(
   label layerNameLbl "Name" pos:[margin + ctrlX, margin];
   edittext layerName "" width:310 readonly:true pos:[margin + ctrlX + 40, margin];
   label displayListLbl "Display" pos:[margin + ctrlX, margin + chkbxDY + 6];
   dropdownlist displayList "" width:100 items:#("Viewport", "Bounding Box", "Wireframe", "Shaded") pos:[margin + ctrlX + 44, margin + 3 + chkbxDY];
   label colorLbl "Active Color" pos:[margin + ctrlX + 242, margin + 6 + chkbxDY];
   colorpicker colorPick "" pos:[margin + ctrlX + 305, margin + 3 + chkbxDY];
   
   function setUIValues =
   (
      layerName.text = if (outliner_layerprops.layers.count > 1) then "Multiple layers selected" else outliner_layerprops.layers[1].name;
      colorPick.color = outliner_layerprops.layers[1].wirecolor;
      case outliner_layerprops.layers[1].display of
      (
         #viewport : displayList.selection = 1;
         #boundingbox : displayList.selection = 2;
         #wireframe : displayList.selection = 3;
         #shaded : displayList.selection = 4;
      )
   )
   
   on displayList selected e do
   (
      local disp;
      case e of (
         1: disp = #viewport;
         2: disp = #boundingbox;
         3: disp = #wireframe;
         4: disp = #shaded;
      )
      outliner_layerprops.setLayerProperty #display disp;
   )
   
   on colorPick changed e do
      outliner_layerprops.setLayerProperty #wirecolor e;
)



rollout outliner_layerprops_general "General"
(  
   local margin = 5;
   local interactGrpW = 165;
   local interactGrpH = 56;
   groupBox interactGrp "Interaction" width:interactGrpW height:interactGrpH pos:[margin, margin]
      checkbox hideChk "Hide" pos:[margin + ctrlX, margin + chkbxDY];
      checkbox freezeChk "Freeze" pos:[margin + ctrlX, margin + chkbxDY * 2];
   
   local displayGrpY = margin + 5 + interactGrpH;
   local displayGrpH = 218;
   groupBox displayGrp "Display Properties" width:interactGrpW height:displayGrpH pos:[margin, displayGrpY];
      checkbox seeThroughChk "See-Through" pos:[margin + ctrlX, displayGrpY + chkbxDY];
      checkbox displayAsBoxChk "Display as box" pos:[margin + ctrlX, displayGrpY + chkbxDY * 2];
      checkbox backfaceCullChk "Backface Cull" pos:[margin + ctrlX, displayGrpY + chkbxDY * 3];
      checkbox edgesOnlyChk "Edges Only" pos:[margin + ctrlX, displayGrpY + chkbxDY * 4];
      checkbox vertexTicksChk "Vertex Ticks" pos:[margin + ctrlX, displayGrpY + chkbxDY * 5];
      checkbox trajectoryChk "Trajectory" pos:[margin + ctrlX, displayGrpY + chkbxDY * 6];
      checkbox ignoreExtentsChk "Ignore Extents" pos:[margin + ctrlX, displayGrpY + chkbxDY * 7];
      checkbox showFrozenInGrayChk "Show Frozen in Gray" pos:[margin + ctrlX, displayGrpY + chkbxDY * 8];
      checkbox neverDegradeChk "Never Degrade" pos:[margin + ctrlX, displayGrpY + chkbxDY * 9];
      checkbox vertexColorsChk "Vertex Colors" pos:[margin + ctrlX, displayGrpY + chkbxDY * 10];
      checkbox vertexColorsShadedChk "Shaded Vertex Colors" pos:[margin + ctrlX, displayGrpY + chkbxDY * 11];
   
   local renderingGrpX = margin + interactGrpW + 8;
   local renderingGrpW = 190;
   local renderingGrpH = 188;
   groupBox renderingGrp "Rendering Control" width:renderingGrpW height:renderingGrpH pos:[renderingGrpX, margin];
      spinner visSpn "" width:50 range:[0, 1, 1] type:#float pos:[renderingGrpX + ctrlX - 1, margin + chkbxDY];
      label visLbl "Visibility" pos:[renderingGrpX + ctrlX + 55, margin + chkbxDY + 2];
      checkbox renderableChk "Renderable" pos:[renderingGrpX + ctrlX, margin + chkbxDY * 2 + 2];
      checkbox inheritVisChk "Inherit Visibility" pos:[renderingGrpX + ctrlX, margin + chkbxDY * 3 + 2];
      checkbox visToCamChk "Visible to Camera" pos:[renderingGrpX + ctrlX, margin + chkbxDY * 4 + 2];
      checkbox visToReflChk "Visible to Reflection/Refraction" pos:[renderingGrpX + ctrlX, margin + chkbxDY * 5 + 2];
      checkbox receiveShadowsChk "Receive Shadows" pos:[renderingGrpX + ctrlX, margin + chkbxDY * 6 + 2];
      checkbox castShadowsChk "Cast Shadows" pos:[renderingGrpX + ctrlX, margin + chkbxDY * 7 + 2];
      checkbox applyAtmChk "Apply Atmospherics" pos:[renderingGrpX + ctrlX, margin + chkbxDY * 8 + 2];
      checkbox renderOcclChk "Render Occluded Objects" pos:[renderingGrpX + ctrlX, margin + chkbxDY * 9 + 2];
      
   local mBlurGrpY = margin + renderingGrpH + 8
   local mBlurGrpH = 83;
   groupBox mBlurGrp "Motion Blur" width:renderingGrpW height:mBlurGrpH pos:[renderingGrpX, mBlurGrpY];
      spinner mBlurSpn "" width:50 range:[0, 100, 0] type:#float pos:[renderingGrpX + ctrlX - 1, mBlurGrpY + chkbxDY];
      label mBlurLbl "Multiplier" pos:[renderingGrpX + ctrlX + 55, mBlurGrpY + chkbxDY + 2];
      checkbox mBlurEnabledChk "Enabled" pos:[renderingGrpX + ctrlX, mBlurGrpY + chkbxDY * 2 + 4];
      radiobuttons mBlurType "" labels:#("None", "Object", "Image") pos:[renderingGrpX + ctrlX, mBlurGrpY + chkbxDY * 3 + 6];
      
   
   local checkBtns = #(hideChk, freezeChk, undefined, undefined, seeThroughChk, displayAsBoxChk, backfaceCullChk, 
      edgesOnlyChk, vertexTicksChk, trajectoryChk, ignoreExtentsChk, showFrozenInGrayChk, neverDegradeChk, 
      vertexColorsChk, vertexColorsShadedChk, undefined, renderableChk, inheritVisChk, 
      visToCamChk, visToReflChk, receiveshadowsChk, castShadowsChk, applyAtmChk, 
      renderOcclChk, mBlurEnabledChk, undefined, undefined)
   
   function setUIStates =
   (
      mBlurSpn.enabled = mBlurType.state == 3;
   )
   
   function setUIValues =
   (
      visSpn.value = outliner_layerprops.layers[1].visibility;
      mBlurSpn.value = outliner_layerprops.layers[1].imageMotionBlurMultiplier;
      
      case outliner_layerprops.layers[1].motionBlur of 
      (
         #none : mBlurType.state = 1;
         #object : mBlurType.state = 2;
         #image : mBlurType.state = 3;
      )
      
      for i = 1 to outliner_layerprops.layers.count do
      (
         local layer = outliner_layerprops.layers[i];
         for p = 1 to outliner_layerprops.propsToStore.count do
         (
            if (checkBtns[p] != undefined) do
            (
               local value = getProperty layer outliner_layerprops.propsToStore[p];
               local chkBtn = checkBtns[p];
               chkBtn.triState = if (value AND (chkBtn.triState == 1 OR i == 1)) then 1 else if (not value AND (chkBtn.triState == 0 OR i == 1)) then 0 else 2;
            )
         )
      )
      
      setUIStates();
   )
   
   
      
   on hideChk changed e do outliner_layerprops.setLayerProperty #isHidden e;
   on freezeChk changed e do outliner_layerprops.setLayerProperty #isFrozen e;
      
   on seeThroughChk changed e do outliner_layerprops.setLayerProperty #xray e;
   on displayAsBoxChk changed e do outliner_layerprops.setLayerProperty #boxmode e;
   on backfaceCullChk changed e do outliner_layerprops.setLayerProperty #backfacecull e;
   on edgesOnlyChk changed e do outliner_layerprops.setLayerProperty #alledges e;
   on vertexTicksChk changed e do outliner_layerprops.setLayerProperty #vertexTicks e;
   on trajectoryChk changed e do outliner_layerprops.setLayerProperty #showTrajectory e;
   on ignoreExtentsChk changed e do outliner_layerprops.setLayerProperty #ignoreExtents e;
   on showFrozenInGrayChk changed e do outliner_layerprops.setLayerProperty #showFrozenInGray e;
   on neverDegradeChk changed e do outliner_layerprops.setLayerProperty #degrade e;
   on vertexColorsChk changed e do outliner_layerprops.setLayerProperty #showVertexColors e;
   on vertexColorsShadedChk changed e do outliner_layerprops.setLayerProperty #vertexColorsShaded e;
   
   on visSpn changed e do outliner_layerprops.setLayerProperty #visibility e;
   on renderableChk changed e do outliner_layerprops.setLayerProperty #renderable e;
   on inheritVisChk changed e do outliner_layerprops.setLayerProperty #inheritVisibility e;
   on visToCamChk changed e do outliner_layerprops.setLayerProperty #primaryVisibility e;
   on visToReflChk changed e do outliner_layerprops.setLayerProperty #secondaryVisibility e;
   on receiveShadowsChk changed e do outliner_layerprops.setLayerProperty #receiveShadows e;
   on castShadowsChk changed e do outliner_layerprops.setLayerProperty #castShadows e;
   on applyAtmChk changed e do outliner_layerprops.setLayerProperty #applyAtmospherics e;
   on renderOcclChk changed e do outliner_layerprops.setLayerProperty #renderOccluded e;
   
   on mBlurSpn changed e do outliner_layerprops.setLayerProperty #imageMotionBlurMultiplier e;
   on mBlurEnabledChk changed e do outliner_layerprops.setLayerProperty #motionBlurOn e;
   on mBlurType changed e do
   (
      local mBlur;
      case e of (
         1: mBlur = #none;
         2: mBlur = #object;
         3: mBlur = #image;
      )
      outliner_layerprops.setLayerProperty #motionblur mBlur;
      setUIStates();
   )
)



rollout outliner_layerprops_advlighting "Advanced Lighting"
(

local margin = 5;
local grpW = 365;
local radiosityGrpH = 135;
groupBox radiosityGrp "Radiosity Properties" width:grpW height:radiosityGrpH pos:[margin, margin];
   checkbox excludeFromRadChk "Exclude from Radiosity Processing" pos:[margin + ctrlX, margin + chkbxDY];
   checkbox castShadowsChk "Cast Shadows" pos:[margin + ctrlX * 2.5, margin + chkbxDY * 2];
   checkbox receiveIllumChk "Receive Illumination" pos:[margin + ctrlX * 2.5, margin + chkbxDY * 3];
   checkbox diffuseChk "Diffuse (reflective && translucent)" pos:[margin + ctrlX * 2.5, margin + chkbxDY * 4];
   checkbox specChk "Specular (reflective & translucent)" pos:[margin + ctrlX * 2.5, margin + chkbxDY * 5];
   checkbox excludeFromRegatherChk "Exclude from Regathering" pos:[margin + ctrlX * 2.5, margin + chkbxDY * 6];

local subDivGrpY = margin + radiosityGrpH + margin;
local subDivGrpH = 80;
groupBox subDivGrp "Object Subdivision Properties" width:grpW height:subDivGrpH pos:[margin, subDivGrpY];
   checkbox useGlobalSubDivChk "Use Global Subdivision Settings" pos:[margin + ctrlX, subDivGrpY + chkbxDY];
   checkbox subDivChk "Subdivide" pos:[margin + ctrlX * 2.5, subDivGrpY + chkbxDY * 2];
   checkbox adaptiveSubDivChk "Use Adaptive Subdivision" pos:[margin + ctrlX * 4, subDivGrpY + chkbxDY * 3];

local meshGrpY = subDivGrpY + subDivGrpH + margin;
local meshGrpH = 60;
groupBox meshGrp "Mesh Settings" width:grpW height:meshGrpH pos:[margin, meshGrpY];
   spinner maxMeshSizeSpn "Max Mesh Size  " fieldWidth:40 range:[0.01, 1000000, 0.01] pos:[margin + ctrlX, meshGrpY + chkbxDY];
   spinner contrastSpn "Contrast Threshold  " fieldWidth:40 range:[0, 100, 50] pos:[margin + ctrlX + 180, meshGrpY + chkbxDY];
   spinner minMeshSizeSpn "Min Mesh Size " fieldWidth:40 range:[0.01, 1000000, 0.01] pos:[margin + ctrlX + 7, meshGrpY + chkbxDY * 2];
   spinner initMeshSizeSpn "Initial Mesh Size " fieldWidth:40 range:[0.01, 1000000, 12] pos:[margin + ctrlX + 199, meshGrpY + chkbxDY * 2];
   
   
   
local checkBtns = #(excludeFromRadChk, castShadowsChk, receiveIllumChk, diffuseChk, specChk,
   excludeFromRegatherChk, useGlobalSubDivChk, subDivChk, adaptiveSubDivChk, 
   undefined, undefined, undefined, undefined);

function setUIStates =
(
   castShadowsChk.enabled = receiveIllumChk.enabled = diffuseChk.enabled = specChk.enabled = excludeFromRegatherChk.enabled = not excludeFromRadChk.checked;
   useGlobalSubDivChk.enabled = not excludeFromRadChk.checked;
   subDivChk.enabled = not excludeFromRadChk.checked AND not useGlobalSubDivChk.checked;
   adaptiveSubDivChk.enabled = not excludeFromRadChk.checked AND not useGlobalSubDivChk.checked AND subDivChk.checked;
   
   maxMeshSizeSpn.enabled = not excludeFromRadChk.checked AND not useGlobalSubDivChk.checked AND subDivChk.checked;
   minMeshSizeSpn.enabled = not excludeFromRadChk.checked AND not useGlobalSubDivChk.checked AND subDivChk.checked AND adaptiveSubDivChk.checked;
   contrastSpn.enabled = not excludeFromRadChk.checked AND not useGlobalSubDivChk.checked AND subDivChk.checked AND adaptiveSubDivChk.checked;
   initMeshSizeSpn.enabled = not excludeFromRadChk.checked AND not useGlobalSubDivChk.checked AND subDivChk.checked AND adaptiveSubDivChk.checked;
)

function setUIValues =
(
   maxMeshSizeSpn.value = outliner_layerprops.layers[1].INodeGIProperties.GIMeshSize;
   minMeshSizeSpn.value = outliner_layerprops.layers[1].INodeGIProperties.GIMinMeshSize;
   contrastSpn.value = outliner_layerprops.layers[1].INodeGIProperties.GIContrastThreshold;
   initMeshSizeSpn.value = outliner_layerprops.layers[1].INodeGIProperties.GIInitialMeshSize;
   
   for i = 1 to outliner_layerprops.layers.count do
   (
      local layer = outliner_layerprops.layers[i];
      for p = 1 to outliner_layerprops.giPropsToStore.count do
      (
         if (checkBtns[p] != undefined) do
         (
            local value = getProperty layer.INodeGIProperties outliner_layerprops.giPropsToStore[p];
            local chkBtn = checkBtns[p];
            chkBtn.triState = if (value AND (chkBtn.triState == 1 OR i == 1)) then 1 else if (not value AND (chkBtn.triState == 0 OR i == 1)) then 0 else 2;
         )
      )
   )
   setUIStates();
)


on excludeFromRadChk changed e do 
( 
   outliner_layerprops.setLayerGIProperty #isGIExcluded e; 
   setUIStates(); 
)
on castShadowsChk changed e do outliner_layerprops.setLayerGIProperty #isGIOccluder e;
on receiveIllumChk changed e do outliner_layerprops.setLayerGIProperty #isGIReceiver e;
on diffuseChk changed e do outliner_layerprops.setLayerGIProperty #isGIDiffuse e;
on specChk changed e do outliner_layerprops.setLayerGIProperty #isGISpecular e;
on excludeFromRegatherChk changed e do outliner_layerprops.setLayerGIProperty #isGIExcludedFromRegather e;

on useGlobalSubDivChk changed e do 
(
   outliner_layerprops.setLayerGIProperty #GIUseGlobalMeshing e;
   setUIStates();
)
on subDivChk changed e do 
(
   outliner_layerprops.setLayerGIProperty #GIMeshingEnabled e;
   setUIStates();
)
on adaptiveSubDivChk changed e do 
(
   outliner_layerprops.setLayerGIProperty #GIUseAdaptiveSubdivision e;
   setUIStates();
)

on maxMeshSizeSpn changed e do 
(
   outliner_layerprops.setLayerGIProperty #GIMeshSize e;
   if (minMeshSizeSpn.value > e) do
   (
      minMeshSizeSpn.value = e;
      outliner_layerprops.setLayerGIProperty #GIMinMeshSize e;
   )
)
on minMeshSizeSpn changed e do
(
   outliner_layerprops.setLayerGIProperty #GIMinMeshSize e;
   if (maxMeshSizeSpn.value < e) do
   (
      maxMeshSizeSpn.value = e;
      outliner_layerprops.setLayerGIProperty #GIMeshSize e;
   )
)
on contrastSpn changed e do outliner_layerprops.setLayerGIProperty #GIContrastThreshold e;
on initMeshSizeSpn changed e do outliner_layerprops.setLayerGIProperty #GIInitialMeshSize e;
   
)--End rollout.




rollout outliner_layerprops "Layer Properties"
(

local propsToStore = #(#isHidden, #isFrozen, #wireColor, #display, #xray, #boxmode, 
                       #backfacecull, #alledges, #vertexTicks, #showTrajectory, 
                       #ignoreExtents, #showFrozenInGray, #degrade, 
                       #showVertexColors, #vertexColorsShaded, #visibility, 
                       #renderable, #inheritVisibility, #primaryVisibility, 
                       #secondaryVisibility, #receiveshadows, #castShadows, 
                       #applyAtmospherics, #renderOccluded, #motionBlurOn, 
                       #motionblur, #imageMotionBlurMultiplier);
                       
local giPropsToStore = #(#isGIExcluded, #isGIOccluder, #isGIReceiver, 
                         #isGIDiffuse, #isGISpecular, #isGIExcludedFromRegather, 
                         #GIUseGlobalMeshing, #GIMeshingEnabled, 
                         #GIUseAdaptiveSubdivision, #GIMeshSize, #GIMinMeshSize, 
                         #GIContrastThreshold, #GIInitialMeshSize);
   
local layers;
local oldValues;
   
function storeOldProperties =
(
   oldValues = #();
   
   for layer in layers do
   (
      local props = #();
      
      for propName in propsToStore do
      (
         if (isProperty layer propName) do
            append props (getProperty layer propName);
      )
      
      local giProperties = layer.INodeGIProperties;
      for propName in giPropsToStore do
      (
         if (isProperty giProperties propName) do
            append props (getProperty giProperties propName);
      )
      
      append oldValues props;
   )
)

function setLayers l =
(
   if (l == undefined OR l.count == 0) then
      outliner_layerprops.closeDialog();
   else
   (
      layers = l;
      storeOldProperties();
   
      --set UI states.
      outliner_layerprops_general.setUIValues();
      outliner_layerprops_advlighting.setUIValues();
      outliner_layerprops_layerinfo.setUIValues();
   )
)

function setLayerProperty prop value =
(
   for layer in layers do
   (
      if (isProperty layer prop) do
         setProperty layer prop value;
   )
)

function setLayerGIProperty prop value =
(
   for layer in layers do
   (
      if (isProperty layer.INodeGIProperties prop) do
         setProperty layer.INodeGIProperties prop value;
   )
)

function cancelChanges =
(
   for i = 1 to layers.count do
   (
      local layerValues = oldValues[i];
      local layer = layers[i];
      local giProperties = layer.INodeGIProperties;
      
      for p = 1 to propsToStore.count do
         setProperty layer propsToStore[p] layerValues[p];
      for p = 1 to giPropsToStore.count do
         setProperty giProperties giPropsToStore[p] layerValues[propsToStore.count + p];
   )
   
   for i = 1 to propsToStore.count do
   (
      local prop = propsToStore[i];
      
      for l = 1 to layers.count do
      (
         setProperty layers[l] prop oldValues[l][i];
      )
   )
)


subrollout rollouts "" width:390 height:445 pos:[2, 0];

button okBtn "OK" width:70 height:24 align:#right across:2 offset:[100, 0]
button cancelBtn "Cancel" width:70 height:24 align:#right offset:[5, 0];

function closeDialog cancel:false =
(
   if (cancel) do cancelChanges();
   destroyDialog outliner_layerprops;
)

on okBtn pressed do
   closeDialog();
on cancelBtn pressed do
   closeDialog cancel:true;
   
on outliner_layerprops open do
(
   AddSubRollout rollouts outliner_layerprops_layerinfo;
   AddSubRollout rollouts outliner_layerprops_general;
   AddSubRollout rollouts outliner_layerprops_advlighting rolledUp:true;
)

)--End rollout.

)