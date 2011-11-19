using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Outliner.Scene
{
public static class MaxTypes
{
    public const String Object = "Object";
    public const String XrefObject = "ReferenceTarget";//getClassname for xrefobject returns referencetarget?? classof == "XRefObject";
    public const String Layer = "Layer";
    public const String Material = "Material";
    public const String XrefMaterial = "XRef";

    public const String Biped = ""; //getClassName for biped returns empty string?? classof == "Biped_Object";
    public const String Bone = "Bone";
    public const String Camera = "camera";
    public const String Container = "Container";
    public const String Geometry = "GeometryClass";
    public const String Helper = "helper";
    public const String Light = "light";
    public const String NurbsPtSurf = "Point Surf";
    public const String NurbsCvSurf = "CV Surf";
    public const String PatchEditable = "PatchObject";
    public const String PatchQuad = "QuadPatchObject";
    public const String PatchTri = "TriPatchObject";
    public const String PArray = "PArray";
    public const String PBlizzard = "Blizzard";
    public const String PCloud = "PCloud";
    public const String PfSource = "PF Source";
    public const String PSnow = "Snow";
    public const String PSpray = "Spray";
    public const String PSuperSpray = "SuperSpray";
    public const String PBirthTexture = "Birth Texture";
    public const String PSpeedByIcon = "SpeedByIcon";
    public const String PGroupSelection = "Group Select";
    public const String PFindTarget = "Find Target";
    public const String PInitialState = "Initial State";
    public const String ParticlePaint = "Particle Paint";
    public const String Shape = "shape";
    public const String Spacewarp = "SpacewarpObject";
    public const String Target = "Target";
    public const String PowerNurbsPrefix = "Pwr_";

    public static readonly HashSet<String> hidden_particle_classes = new HashSet<String>() 
    { 
        "Age Test", "Birth", "Birth Paint", "Birth Script", "Cache", "Collision", "Collision Spawn", 
        "DeleteParticles", "DisplayParticles", "Event", "Force", "Go To Rotation", "Group Operator", 
        "Keep Apart", "Lock/Bond", "Mapping", "Material Dynamic", "Material Frequency", "Mapping Object", 
        "Material Static", "Notes", "Particle_Bitmap", "Particle View", "ParticleGroup", "PFArrow", /*"PFEngine",*/
        "PFActionListPool", "Placement Paint", "Position Icon", "Position Object", "PView_Manager", "Rotation", "RenderParticles",
        "ScaleParticles", "Scale Test", "Script Operator", "Script Test", "Send Out", "Shape Facing", "Shape Instance", 
        "ShapeLibrary", "Shape Mark", "shapeStandard", "Spawn", "Speed", "Speed By Surface", "Speed Test", "Spin", 
        "Split Amount", "Split Group", "Split Selected", "Split Source"
    };
}
}
