using Outliner.Scene;
using Microsoft.VisualStudio.TestTools.UnitTesting;
namespace Outliner_Unit_Tests
{
    
    
    /// <summary>
    ///This is a test class for OutlinerLayerTest and is intended
    ///to contain all OutlinerLayerTest Unit Tests
    ///</summary>
    [TestClass()]
    public class OutlinerLayerTest
    {


        private TestContext testContextInstance;

        /// <summary>
        ///Gets or sets the test context which provides
        ///information about and functionality for the current test run.
        ///</summary>
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


        /// <summary>
        ///A test for IsHidden
        ///</summary>
        [TestMethod()]
        public void IsHiddenTest()
        {
            OutlinerLayer target = new OutlinerLayer(1, -1, "layer_a", false, false, false, false);
            Assert.IsFalse(target.IsHidden);

            target.IsHidden = true;
            Assert.IsTrue(target.IsHidden);

            target.IsHidden = false;
            Assert.IsFalse(target.IsHidden);
        }

        /// <summary>
        ///A test for IsFrozen
        ///</summary>
        [TestMethod()]
        public void IsFrozenTest()
        {
            OutlinerLayer target = new OutlinerLayer(1, -1, "layer_a", false, false, false, false);
            Assert.IsFalse(target.IsFrozen);

            target.IsFrozen = true;
            Assert.IsTrue(target.IsFrozen);

            target.IsFrozen = false;
            Assert.IsFalse(target.IsFrozen);
        }

        /// <summary>
        ///A test for IsDefaultLayer
        ///</summary>
        [TestMethod()]
        public void IsDefaultLayerTest()
        {
            OutlinerLayer target = new OutlinerLayer(1, -1, "0", false, false, false, false);
            Assert.IsTrue(target.IsDefaultLayer);

            target = new OutlinerLayer(2, -1, "layer_a", false, false, false, false);
            Assert.IsFalse(target.IsDefaultLayer);
        }

        /// <summary>
        ///A test for IsActive
        ///</summary>
        [TestMethod()]
        public void IsActiveTest()
        {
            OutlinerLayer target = new OutlinerLayer(1, -1, "layer_a", true, false, false, false);
            Assert.IsTrue(target.IsActive);

            target = new OutlinerLayer(1, -1, "layer_a", false, false, false, false);
            Assert.IsFalse(target.IsActive);

            target.IsActive = true;
            Assert.IsTrue(target.IsActive);

            target.IsActive = false;
            Assert.IsFalse(target.IsActive);
        }

        /// <summary>
        ///A test for DisplayName
        ///</summary>
        [TestMethod()]
        public void DisplayNameTest()
        {
            OutlinerLayer target = new OutlinerLayer(1, -1, "layer_a", false, false, false, false);
            Assert.AreEqual("layer_a", target.DisplayName);
            target.Name = "layer_b";
            Assert.AreEqual("layer_b", target.DisplayName);

            target = new OutlinerLayer(1, -1, "0", false, false, false, false);
            Assert.AreEqual("0 (default)", target.DisplayName);
        }

        /// <summary>
        ///A test for CanEditName
        ///</summary>
        [TestMethod()]
        public void CanEditNameTest()
        {
            OutlinerLayer target = new OutlinerLayer(1, -1, "layer_a", false, false, false, false);
            Assert.IsTrue(target.CanEditName);

            target = new OutlinerLayer(2, -1, "0", false, false, false, false);
            Assert.IsFalse(target.CanEditName);
        }

        /// <summary>
        ///A test for CanBeDeleted
        ///</summary>
        [TestMethod()]
        public void CanBeDeletedTest()
        {
            OutlinerLayer target = new OutlinerLayer(1, -1, "layer_a", false, false, false, false);
            Assert.IsTrue(target.CanBeDeleted);

            target = new OutlinerLayer(2, -1, "0", false, false, false, false);
            Assert.IsFalse(target.CanBeDeleted);
        }

        /// <summary>
        ///A test for BoxMode
        ///</summary>
        [TestMethod()]
        public void BoxModeTest()
        {
            OutlinerLayer target = new OutlinerLayer(1, -1, "layer_a", false, false, false, false);
            Assert.IsFalse(target.BoxMode);

            target.BoxMode = true;
            Assert.IsTrue(target.BoxMode);

            target.BoxMode = false;
            Assert.IsFalse(target.BoxMode);
        }

        /// <summary>
        ///A test for OutlinerLayer Constructor
        ///</summary>
        [TestMethod()]
        public void OutlinerLayerConstructorTest()
        {
            OutlinerLayer target = new OutlinerLayer(1, OutlinerScene.LayerRootHandle, "layer_a", false, true, false, true);
            Assert.AreEqual(1, target.Handle);
            Assert.AreEqual(0, target.ParentHandle);
            Assert.AreEqual(OutlinerScene.LayerRootHandle, target.LayerHandle);
            Assert.AreEqual(0, target.MaterialHandle);
            Assert.AreEqual("layer_a", target.Name);
            Assert.IsFalse(target.IsActive);
            Assert.IsTrue(target.IsHidden);
            Assert.IsFalse(target.IsFrozen);
            Assert.IsTrue(target.BoxMode);
        }
    }
}
