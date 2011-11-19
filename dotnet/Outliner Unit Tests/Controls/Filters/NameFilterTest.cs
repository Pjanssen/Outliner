using Outliner.Controls.Filters;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Outliner.Scene;
using System;

namespace Outliner_Unit_Tests
{
    
    
    /// <summary>
    ///This is a test class for NameFilterTest and is intended
    ///to contain all NameFilterTest Unit Tests
    ///</summary>
    [TestClass()]
    public class NameFilterTest
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
        ///A test for NameFilter Constructor
        ///</summary>
        [TestMethod()]
        public void NameFilterConstructorTest() 
        {
            NameFilter target = new NameFilter();
            Assert.AreEqual(String.Empty, target.SearchString);
            Assert.AreEqual(false, target.CaseSensitive);
        }

        /// <summary>
        ///A test for SearchString
        ///</summary>
        [TestMethod()]
        public void SearchStringTest() 
        {
            NameFilter target = new NameFilter();
            string expected = string.Empty;
            target.SearchString = expected;
            Assert.AreEqual(String.Empty, target.SearchString);

            target.SearchString = "t";
            Assert.AreEqual("t", target.SearchString);

            target.SearchString = "*test";
            Assert.AreEqual("*test", target.SearchString);

            target.SearchString = "";
            Assert.AreEqual(String.Empty, target.SearchString);
        }



        /// <summary>
        ///A test for CaseSensitive
        ///</summary>
        [TestMethod()]
        public void CaseSensitiveTest()
        {
            NameFilter target = new NameFilter();
            target.CaseSensitive = true;
            Assert.IsTrue(target.CaseSensitive);

            target.CaseSensitive = false;
            Assert.IsFalse(target.CaseSensitive);
        }
         
        /// <summary>
        ///A test for ShowNode
        ///</summary>
        [TestMethod()]
        public void ShowNodeTest()
        {
            /*
            NameNodeFilter target = new NameNodeFilter();
            OutlinerNode l = new OutlinerLayer(1, -1, "test_sphere", false, false, false, false);
            Assert.Equals(target.ShowNode(l), FilterResult.Show);

            target.SearchString = "t";
            Assert.IsTrue(target.ShowNode(l));

            target.SearchString = "*t";
            Assert.IsTrue(target.ShowNode(l));

            target.SearchString = "*sphere";
            Assert.IsTrue(target.ShowNode(l));

            target.SearchString = "a";
            Assert.IsFalse(target.ShowNode(l));

            target.SearchString = "*a";
            Assert.IsFalse(target.ShowNode(l));

            target.SearchString = "test_sphere_a";
            Assert.IsFalse(target.ShowNode(l));

            OutlinerScene s = new OutlinerScene();
            s.AddNode(l);
            OutlinerNode n  = new OutlinerObject(2, -1, "kip", 1, -1, "", "", false, false, false, false,false);
            s.AddNode(n);
            s.AddNode(new OutlinerObject(3, 2, "henk", 1, -1, "", "", false, false, false, false,false));
            target.SearchString = "kip";
            Assert.IsTrue(target.ShowNode(n));
            target.SearchString = "he";
            Assert.IsTrue(target.ShowNode(n));
            Assert.IsTrue(target.ShowNode(l));

            target.Enabled = false;
            target.SearchString = "asd";
            Assert.IsTrue(target.ShowNode(n));
             */
        }

        [TestMethod()]
        public void UseWildcardTest()
        {
            NameFilter f = new NameFilter();
            f.SearchString = "test";

            OutlinerLayer layer1 = new OutlinerLayer(-1, -1, "test_a", false, false, false, false);
            OutlinerLayer layer2 = new OutlinerLayer(-1, -1, "a_test", false, false, false, false);
            Assert.AreEqual(FilterResult.Show, f.ShowNode(layer1));
            Assert.AreEqual(FilterResult.Hide, f.ShowNode(layer2));

            f.UseWildcard = true;
            Assert.AreEqual(FilterResult.Show, f.ShowNode(layer1));
            Assert.AreEqual(FilterResult.Show, f.ShowNode(layer2));

            f.UseWildcard = false;
            Assert.AreEqual(FilterResult.Show, f.ShowNode(layer1));
            Assert.AreEqual(FilterResult.Hide, f.ShowNode(layer2));

        }
    }
}
