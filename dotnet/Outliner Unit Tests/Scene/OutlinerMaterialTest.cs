using Outliner.Scene;
using Microsoft.VisualStudio.TestTools.UnitTesting;
namespace Outliner_Unit_Tests
{
    
    
    /// <summary>
    ///This is a test class for OutlinerMaterialTest and is intended
    ///to contain all OutlinerMaterialTest Unit Tests
    ///</summary>
    [TestClass()]
    public class OutlinerMaterialTest
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
        ///A test for Type
        ///</summary>
        [TestMethod()]
        [DeploymentItem("Outliner.dll")]
        public void TypeTest()
        {
            OutlinerMaterial m = new OutlinerMaterial(1, OutlinerScene.MaterialRootHandle, "mat_a", "Standard");
            Assert.AreEqual("Standard", m.Type);

        }

        /// <summary>
        ///A test for IsUnassigned
        ///</summary>
        [TestMethod()]
        public void IsUnassignedTest()
        {
            OutlinerMaterial m = new OutlinerMaterial(OutlinerScene.MaterialUnassignedHandle, -1, "", "");
            Assert.IsTrue(m.IsUnassigned);
        }

        /// <summary>
        ///A test for DisplayName
        ///</summary>
        [TestMethod()]
        public void DisplayNameTest()
        {
            OutlinerMaterial m = new OutlinerMaterial(OutlinerScene.MaterialUnassignedHandle, -1, "", "");
            Assert.AreEqual("-Unassigned-", m.DisplayName);

            m = new OutlinerMaterial(1, -1, "mat_a", "standard");
            Assert.AreEqual("mat_a", m.DisplayName);

            m = new OutlinerMaterial(1, -1, "mat_a", MaxTypes.XrefMaterial);
            Assert.AreEqual("{ mat_a }", m.DisplayName);
        }

        /// <summary>
        ///A test for CanEditName
        ///</summary>
        [TestMethod()]
        public void CanEditNameTest()
        {
            OutlinerMaterial m = new OutlinerMaterial(OutlinerScene.MaterialUnassignedHandle, -1, "", "");
            Assert.IsFalse(m.CanEditName);

            m = new OutlinerMaterial(1, -1, "mat_a", "standard");
            Assert.IsTrue(m.CanEditName);
        }

        /// <summary>
        ///A test for CanBeDeleted
        ///</summary>
        [TestMethod()]
        public void CanBeDeletedTest()
        {
            OutlinerMaterial m = new OutlinerMaterial(OutlinerScene.MaterialUnassignedHandle, -1, "", "");
            Assert.IsFalse(m.CanBeDeleted);

            m = new OutlinerMaterial(1, -1, "mat_a", "standard");
            Assert.IsFalse(m.CanBeDeleted);
        }

        /// <summary>
        ///A test for OutlinerMaterial Constructor
        ///</summary>
        [TestMethod()]
        public void OutlinerMaterialConstructorTest()
        {
            OutlinerMaterial m = new OutlinerMaterial(1, -1, "mat_a", "standard");
            Assert.AreEqual(1, m.Handle);
            Assert.AreEqual(-1, m.ParentHandle);
            Assert.AreEqual("mat_a", m.Name);
            Assert.AreEqual("standard", m.Type);
        }
    }
}
