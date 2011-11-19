using Outliner.Scene;
using Microsoft.VisualStudio.TestTools.UnitTesting;
namespace Outliner_Unit_Tests
{
    
    
    /// <summary>
    ///This is a test class for OutlinerObjectTest and is intended
    ///to contain all OutlinerObjectTest Unit Tests
    ///</summary>
    [TestClass()]
    public class OutlinerObjectTest
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

        internal virtual OutlinerObject CreateOutlinerNode()
        {
            // TODO: Instantiate an appropriate concrete class.
            OutlinerObject target = new OutlinerObject(100, OutlinerScene.ObjectRootHandle, "obj", 1, 2, "sphere", MaxTypes.Geometry, false, false, false, false, false);
            return target;
        }

        /// <summary>
        ///A test for SuperClass
        ///</summary>
        [TestMethod()]
        public void SuperClassTest()
        {
            OutlinerObject o = CreateOutlinerNode();
            Assert.AreEqual(MaxTypes.Geometry, o.SuperClass);

            o.SuperClass = MaxTypes.Bone;
            Assert.AreEqual(MaxTypes.Bone, o.SuperClass);
        }

        /// <summary>
        ///A test for IsHidden
        ///</summary>
        [TestMethod()]
        public void IsHiddenTest()
        {
            OutlinerObject target = CreateOutlinerNode();
            Assert.IsFalse(target.IsHidden);

            target.IsHidden = true;
            Assert.IsTrue(target.IsHidden);

            target.IsHidden = false;
            Assert.IsFalse(target.IsHidden);
        }

        /// <summary>
        ///A test for IsGroupMember
        ///</summary>
        [TestMethod()]
        public void IsGroupMemberTest()
        {
            OutlinerObject target = CreateOutlinerNode();
            Assert.IsFalse(target.IsGroupMember);

            target.IsGroupMember = true;
            Assert.IsTrue(target.IsGroupMember);

            target.IsGroupMember = false;
            Assert.IsFalse(target.IsGroupMember);
        }

        /// <summary>
        ///A test for IsGroupHead
        ///</summary>
        [TestMethod()]
        public void IsGroupHeadTest()
        {
            OutlinerObject target = CreateOutlinerNode();
            Assert.IsFalse(target.IsGroupHead);

            target.IsGroupHead = true;
            Assert.IsTrue(target.IsGroupHead);

            target.IsGroupHead = false;
            Assert.IsFalse(target.IsGroupHead);
        }

        /// <summary>
        ///A test for IsFrozen
        ///</summary>
        [TestMethod()]
        public void IsFrozenTest()
        {
            OutlinerObject target = CreateOutlinerNode();
            Assert.IsFalse(target.IsFrozen);

            target.IsFrozen = true;
            Assert.IsTrue(target.IsFrozen);

            target.IsFrozen = false;
            Assert.IsFalse(target.IsFrozen);
        }



        /// <summary>
        ///A test for DisplayName
        ///</summary>
        [TestMethod()]
        public void DisplayNameTest()
        {
            OutlinerObject o = CreateOutlinerNode();
            Assert.AreEqual("obj", o.DisplayName);

            o.IsGroupHead = true;
            Assert.AreEqual("[ obj ]", o.DisplayName);
            o.IsGroupMember = true;
            Assert.AreEqual("[ obj ]", o.DisplayName);
            o.IsGroupHead = false;
            Assert.AreEqual("[ obj ]", o.DisplayName);

            o.IsGroupMember = false;
            o.Class = MaxTypes.XrefObject;
            Assert.AreEqual("{ obj }", o.DisplayName);
            o.IsGroupMember = true;
            Assert.AreEqual("{[ obj ]}", o.DisplayName);
            o.IsGroupHead = true;
            Assert.AreEqual("{[ obj ]}", o.DisplayName);
            o.IsGroupMember = false;
            Assert.AreEqual("{[ obj ]}", o.DisplayName);
        }

        /// <summary>
        ///A test for Class
        ///</summary>
        [TestMethod()]
        public void ClassTest()
        {
            OutlinerObject target = CreateOutlinerNode();
            Assert.AreEqual("sphere", target.Class);

            target.Class = "editable_poly";
            Assert.AreEqual("editable_poly", target.Class);
        }

        /// <summary>
        ///A test for BoxMode
        ///</summary>
        [TestMethod()]
        public void BoxModeTest()
        {
            OutlinerObject target = CreateOutlinerNode();
            Assert.IsFalse(target.BoxMode);

            target.BoxMode = true;
            Assert.IsTrue(target.BoxMode);

            target.BoxMode = false;
            Assert.IsFalse(target.BoxMode);
        }

        /// <summary>
        ///A test for OutlinerObject Constructor
        ///</summary>
        [TestMethod()]
        public void OutlinerObjectConstructorTest()
        {
            OutlinerObject o = new OutlinerObject(1, 2, "a", 3, 4, "sphere", "geometry", false, true, false, true, false);
            Assert.AreEqual(1, o.Handle);
            Assert.AreEqual(2, o.ParentHandle);
            Assert.AreEqual("a", o.Name);
            Assert.AreEqual(3, o.LayerHandle);
            Assert.AreEqual(4, o.MaterialHandle);
            Assert.AreEqual("sphere", o.Class);
            Assert.AreEqual("geometry", o.SuperClass);
            Assert.IsFalse(o.IsGroupHead);
            Assert.IsTrue(o.IsGroupMember);
            Assert.IsFalse(o.IsHidden);
            Assert.IsTrue(o.IsFrozen);
            Assert.IsFalse(o.BoxMode);
        }
    }
}
