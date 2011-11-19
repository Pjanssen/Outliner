using Outliner.Controls.Filters;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Outliner.Scene;

namespace Outliner_Unit_Tests
{


    [TestClass()]
    public class NodeFilterCollectionTest
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



        [TestMethod()]
        public void ShowNodeTest() 
        {
            NodeFilterCollection target = new NodeFilterCollection();
            
            OutlinerObject a = new OutlinerObject(1, OutlinerScene.ObjectRootHandle, "test_A", 10, OutlinerScene.MaterialUnassignedHandle, "Sphere", MaxTypes.Geometry, false, false, false, false, false);
            OutlinerObject b = new OutlinerObject(2, OutlinerScene.ObjectRootHandle, "test_B", 10, OutlinerScene.MaterialUnassignedHandle, "Line", MaxTypes.Shape, false, false, false, false, false);
            OutlinerScene scene = new OutlinerScene();
            scene.AddNode(a);
            scene.AddNode(b);

            Assert.AreEqual(FilterResult.Show, target.ShowNode(a));
            Assert.AreEqual(FilterResult.Show, target.ShowNode(b));

            target.Add(new GeometryFilter());
            Assert.AreEqual(FilterResult.Hide, target.ShowNode(a));
            Assert.AreEqual(FilterResult.Show, target.ShowNode(b));

            target.Enabled = false;
            Assert.AreEqual(FilterResult.Show, target.ShowNode(a));
            Assert.AreEqual(FilterResult.Show, target.ShowNode(b));
            target.Enabled = true;

            OutlinerObject c = new OutlinerObject(3, 1, "C", 10, OutlinerScene.MaterialUnassignedHandle, "Dummy", MaxTypes.Helper, false, false, false, false, false);
            scene.AddNode(c);
            Assert.AreEqual(FilterResult.ShowChildren, target.ShowNode(a));
            Assert.AreEqual(FilterResult.Show, target.ShowNode(c));

            NameFilter nameFilter = new NameFilter();
            nameFilter.SearchString = "test_";
            target.Add(nameFilter);
            Assert.AreEqual(FilterResult.Hide, target.ShowNode(a));
            Assert.AreEqual(FilterResult.Hide, target.ShowNode(c));
        }

        [TestMethod()]
        public void RemoveTest() 
        {
            NodeFilterCollection target = new NodeFilterCollection();
            NodeFilter filter = new GeometryFilter();
            bool permanent = true;
            target.Add(filter, permanent);

            target.Remove(filter);

            NodeFilterCollection_Accessor acc = new NodeFilterCollection_Accessor(target);
            Assert.IsFalse(acc._permanentFilters.Contains(filter));

            target.Add(filter, false);
            target.Remove(filter);
            Assert.IsFalse(acc._filters.Contains(filter));
        }

        [TestMethod()]
        public void ClearTest1() 
        {
            NodeFilterCollection target = new NodeFilterCollection();
            NodeFilter filter = new GeometryFilter();
            bool permanent = true;
            target.Add(filter, permanent);
            target.Add(new GeometryFilter());

            target.Clear();

            NodeFilterCollection_Accessor acc = new NodeFilterCollection_Accessor(target);
            Assert.AreEqual(0, acc._filters.Count);
            Assert.AreEqual(1, acc._permanentFilters.Count);
        }

        [TestMethod()]
        public void ClearTest() 
        {
            NodeFilterCollection target = new NodeFilterCollection();
            NodeFilter filter = new GeometryFilter();
            bool permanent = true;
            target.Add(filter, permanent);
            target.Add(new GeometryFilter());

            NodeFilterCollection_Accessor acc = new NodeFilterCollection_Accessor(target);

            target.Clear(true);
            Assert.AreEqual(0, acc._filters.Count);
            Assert.AreEqual(0, acc._permanentFilters.Count);
        }

        [TestMethod()]
        public void AddTest1() 
        {
            NodeFilterCollection target = new NodeFilterCollection();
            NodeFilter filter = new GeometryFilter();
            target.Add(filter);

            //NodeFilterCollection_Accessor acc = new NodeFilterCollection_Accessor(target);
            //Assert.IsTrue(acc._filters.Contains(filter));
            //Assert.IsFalse(acc._permanentFilters.Contains(filter));
        }

        [TestMethod()]
        public void AddTest() 
        {
            NodeFilterCollection target = new NodeFilterCollection();
            NodeFilter filter = new GeometryFilter();
            bool permanent = true;
            target.Add(filter, permanent);

            NodeFilterCollection_Accessor acc = new NodeFilterCollection_Accessor(target);
            Assert.IsFalse(acc._filters.Contains(filter));
            Assert.IsTrue(acc._permanentFilters.Contains(filter));
        }

        [TestMethod()]
        public void NodeFilterCollectionConstructorTest1() 
        {
            NodeFilterCollection target = new NodeFilterCollection();
            Assert.IsTrue(target.Enabled);
        }

        [TestMethod()]
        public void NodeFilterCollectionConstructorTest() 
        {
            NodeFilterCollection collection = new NodeFilterCollection();
            collection.Add(new GeometryFilter());
            collection.Add(new NameFilter(), true);
            collection.Enabled = false;

            NodeFilterCollection target = new NodeFilterCollection(collection);
            NodeFilterCollection_Accessor acc = new NodeFilterCollection_Accessor(target);

            Assert.IsFalse(target.Enabled);
            Assert.AreEqual(1, acc._filters.Count);
            Assert.AreEqual(1, acc._permanentFilters.Count);
        }

        [TestMethod()]
        public void FlatListNodeFilterCollectionShowNodeTest() 
        {
            FlatListNodeFilterCollection target = new FlatListNodeFilterCollection();

            OutlinerObject a = new OutlinerObject(1, OutlinerScene.ObjectRootHandle, "test_A", 10, OutlinerScene.MaterialUnassignedHandle, "Sphere", MaxTypes.Geometry, false, false, false, false, false);
            OutlinerObject b = new OutlinerObject(2, OutlinerScene.ObjectRootHandle, "test_B", 10, OutlinerScene.MaterialUnassignedHandle, "Line", MaxTypes.Shape, false, false, false, false, false);
            OutlinerScene scene = new OutlinerScene();
            scene.AddNode(a);
            scene.AddNode(b);

            Assert.AreEqual(FilterResult.Show, target.ShowNode(a));
            Assert.AreEqual(FilterResult.Show, target.ShowNode(b));

            target.Add(new GeometryFilter());
            Assert.AreEqual(FilterResult.Hide, target.ShowNode(a));
            Assert.AreEqual(FilterResult.Show, target.ShowNode(b));

            target.Enabled = false;
            Assert.AreEqual(FilterResult.Show, target.ShowNode(a));
            Assert.AreEqual(FilterResult.Show, target.ShowNode(b));
            target.Enabled = true;

            OutlinerObject c = new OutlinerObject(3, 1, "C", 10, OutlinerScene.MaterialUnassignedHandle, "Dummy", MaxTypes.Helper, false, false, false, false, false);
            scene.AddNode(c);
            Assert.AreEqual(FilterResult.Hide, target.ShowNode(a));
            Assert.AreEqual(FilterResult.Show, target.ShowNode(c));

            NameFilter nameFilter = new NameFilter();
            nameFilter.SearchString = "test_";
            target.Add(nameFilter);
            Assert.AreEqual(FilterResult.Hide, target.ShowNode(a));
            Assert.AreEqual(FilterResult.Hide, target.ShowNode(c));
        }
    }
}
