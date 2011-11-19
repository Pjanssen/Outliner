using Outliner.Controls.Filters;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Outliner.Scene;
using System;

namespace Outliner_Unit_Tests
{
    
    
    [TestClass()]
    public class NodeFilterTests
    {


        private TestContext testContextInstance;

        public TestContext TestContext
        {
            get
            {
                return testContextInstance;
            }
            set
            {
                testContextInstance = value;
            }
        }

        #region Additional test attributes
        // 
        //You can use the following additional attributes as you write your tests:
        //
        //Use ClassInitialize to run code before running the first test in the class
        //[ClassInitialize()]
        //public static void MyClassInitialize(TestContext testContext)
        //{
        //}
        //
        //Use ClassCleanup to run code after all tests in a class have run
        //[ClassCleanup()]
        //public static void MyClassCleanup()
        //{
        //}
        //
        //Use TestInitialize to run code before running each test
        //[TestInitialize()]
        //public void MyTestInitialize()
        //{
        //}
        //
        //Use TestCleanup to run code after each test has run
        //[TestCleanup()]
        //public void MyTestCleanup()
        //{
        //}
        //
        #endregion

        private OutlinerObject createObject(String objClass, String superClass)
        {
            return new OutlinerObject(1, OutlinerScene.ObjectRootHandle, "A", 2, OutlinerScene.MaterialUnassignedHandle, objClass, superClass, false, false, false, false, false);
        }

        private OutlinerLayer createLayer()
        {
            return new OutlinerLayer(3, OutlinerScene.LayerRootHandle, "test_layer", true, false, false, false);
        }

        private OutlinerMaterial createMaterial()
        {
            return new OutlinerMaterial(4, OutlinerScene.MaterialRootHandle, "test_mat", "Standard");
        }

        [TestMethod()]
        public void GeometryShowNodeTest() 
        {
            GeometryFilter filter = new GeometryFilter();
            
            Assert.AreEqual(FilterResult.Hide, filter.ShowNode(this.createObject("Sphere", MaxTypes.Geometry)));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createObject("Line", MaxTypes.Shape)));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createObject(MaxTypes.Biped, MaxTypes.Geometry)));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createObject(MaxTypes.Bone, MaxTypes.Geometry)));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createObject(MaxTypes.PfSource, MaxTypes.Geometry)));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createLayer()));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createMaterial()));
        }

        [TestMethod()]
        public void ShapeShowNodeTest() 
        {
            ShapeFilter filter = new ShapeFilter();

            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createObject("Sphere", MaxTypes.Geometry)));
            Assert.AreEqual(FilterResult.Hide, filter.ShowNode(this.createObject("Line", MaxTypes.Shape)));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createLayer()));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createMaterial()));
        }

        [TestMethod()]
        public void CameraShowNodeTest() 
        {
            CameraFilter filter = new CameraFilter();

            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createObject("Sphere", MaxTypes.Geometry)));
            Assert.AreEqual(FilterResult.Hide, filter.ShowNode(this.createObject("target_cam", MaxTypes.Camera)));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createLayer()));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createMaterial()));
        }

        [TestMethod()]
        public void LightShowNodeTest()
        {
            LightFilter filter = new LightFilter();

            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createObject("Sphere", MaxTypes.Geometry)));
            Assert.AreEqual(FilterResult.Hide, filter.ShowNode(this.createObject("point_light", MaxTypes.Light)));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createLayer()));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createMaterial()));
        }

        [TestMethod()]
        public void BoneFilterTest()
        {
            BoneFilter target = new BoneFilter();
            Assert.AreEqual(FilterResult.Show, target.ShowNode(this.createLayer()));
            Assert.AreEqual(FilterResult.Show, target.ShowNode(this.createObject(MaxTypes.Camera, MaxTypes.Camera)));
            Assert.AreEqual(FilterResult.Show, target.ShowNode(this.createObject("Sphere", MaxTypes.Geometry)));
            Assert.AreEqual(FilterResult.Hide, target.ShowNode(this.createObject(MaxTypes.Bone, MaxTypes.Geometry)));
            Assert.AreEqual(FilterResult.Hide, target.ShowNode(this.createObject(MaxTypes.Biped, MaxTypes.Geometry)));
        }

        [TestMethod()]
        public void FrozenFilterTest()
        {
            FrozenFilter filter = new FrozenFilter();
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createLayer()));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createMaterial()));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createObject("", "")));

            OutlinerObject frozenObject = this.createObject("","");
            frozenObject.IsFrozen = true;
            Assert.AreEqual(FilterResult.Hide, filter.ShowNode(frozenObject));
        }

        [TestMethod()]
        public void HiddenFilterTest()
        {
            HiddenFilter filter = new HiddenFilter();
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createLayer()));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createMaterial()));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createObject("", "")));

            OutlinerObject hiddenObject = this.createObject("", "");
            hiddenObject.IsHidden = true;
            Assert.AreEqual(FilterResult.Hide, filter.ShowNode(hiddenObject));
        }

        [TestMethod()]
        public void HelperFilterTest()
        {
            HelperFilter filter = new HelperFilter();
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createLayer()));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createMaterial()));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createObject("Sphere", MaxTypes.Geometry)));
            Assert.AreEqual(FilterResult.Hide, filter.ShowNode(this.createObject("point", MaxTypes.Helper)));
            Assert.AreEqual(FilterResult.Hide, filter.ShowNode(this.createObject("Target", MaxTypes.Geometry)));
        }

        [TestMethod()]
        public void ParticleFilterTest()
        {
            ParticleFilter filter = new ParticleFilter();
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createLayer()));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createMaterial()));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createObject("Sphere", MaxTypes.Geometry)));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createObject("Omni", MaxTypes.Light)));
            Assert.AreEqual(FilterResult.Hide, filter.ShowNode(this.createObject(MaxTypes.PfSource, MaxTypes.Geometry)));
            Assert.AreEqual(FilterResult.Hide, filter.ShowNode(this.createObject(MaxTypes.PSnow, MaxTypes.Geometry)));
        }

        [TestMethod()]
        public void SpaceWarpFilterTest()
        {
            SpacewarpFilter filter = new SpacewarpFilter();
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createLayer()));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createMaterial()));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createObject("Sphere", MaxTypes.Geometry)));
            Assert.AreEqual(FilterResult.Hide, filter.ShowNode(this.createObject("Bomb", MaxTypes.Spacewarp)));
        }

        [TestMethod()]
        public void UnassignedMaterialFilterTest()
        {
            UnassignedMaterialFilter filter = new UnassignedMaterialFilter();
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createLayer()));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createObject("Sphere", MaxTypes.Geometry)));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createMaterial()));
            OutlinerMaterial m = new OutlinerMaterial(OutlinerScene.MaterialUnassignedHandle, OutlinerScene.MaterialRootHandle, "", "");
            Assert.AreEqual(FilterResult.Hide, filter.ShowNode(m));
        }

        [TestMethod()]
        public void XRefFilterTest()
        {
            XRefFilter filter = new XRefFilter();
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createLayer()));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createObject("Sphere", MaxTypes.Geometry)));
            Assert.AreEqual(FilterResult.Show, filter.ShowNode(this.createMaterial()));
            Assert.AreEqual(FilterResult.Hide, filter.ShowNode(this.createObject(MaxTypes.XrefObject, MaxTypes.Geometry)));
            OutlinerMaterial m = new OutlinerMaterial(2, OutlinerScene.MaterialRootHandle, "", MaxTypes.XrefMaterial);
            Assert.AreEqual(FilterResult.Hide, filter.ShowNode(m));
        }
    }
}
