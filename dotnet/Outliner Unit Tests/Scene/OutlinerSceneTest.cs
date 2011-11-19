using Outliner.Scene;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Collections.Generic;
using System;

namespace Outliner_Unit_Tests
{
    
    
    /// <summary>
    ///This is a test class for OutlinerSceneTest and is intended
    ///to contain all OutlinerSceneTest Unit Tests
    ///</summary>
    [TestClass()]
    public class OutlinerSceneTest
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
        ///A test for OutlinerScene Constructor
        ///</summary>
        [TestMethod()]
        public void OutlinerSceneConstructorTest()
        {
            OutlinerScene target = new OutlinerScene();
            Assert.IsNotNull(target.Nodes);
            Assert.IsNotNull(target.RootNodes);
        }

        /// <summary>
        ///A test for Clear
        ///</summary>
        [TestMethod()]
        public void ClearTest()
        {
            OutlinerScene target = new OutlinerScene(); // TODO: Initialize to an appropriate value
            Int32 numNodes = target.Nodes.Count;
            target.Clear();
            Assert.IsNotNull(target.Nodes);
            Assert.IsNotNull(target.RootNodes);
            Assert.AreEqual(numNodes, target.Nodes.Count);
            Assert.AreEqual(0, target.RootNodes.Count);
            target.AddNode(new OutlinerMaterial(1, -1, "", ""));
            target.Clear();
            Assert.AreEqual(numNodes, target.Nodes.Count);
            Assert.AreEqual(0, target.RootNodes.Count);
        }


        /// <summary>
        ///A test for IsValidMaterialName
        ///</summary>
        [TestMethod()]
        public void IsValidMaterialNameTest()
        {
            OutlinerScene target = new OutlinerScene();
            OutlinerMaterial editingMaterial = new OutlinerMaterial(1, -1, "mat_a", "");
            target.AddNode(editingMaterial);
            editingMaterial = new OutlinerMaterial(2, 1, "mat_b", "");
            target.AddNode(editingMaterial);

            Assert.IsFalse(target.IsValidMaterialName(null));
            Assert.IsFalse(target.IsValidMaterialName(""));
            Assert.IsFalse(target.IsValidMaterialName("mat_a"));
            Assert.IsTrue(target.IsValidMaterialName("mat_c"));
            Assert.IsTrue(target.IsValidMaterialName("mat_b", editingMaterial));
            Assert.IsTrue(target.IsValidMaterialName("mat_c", editingMaterial));
            Assert.IsFalse(target.IsValidMaterialName("mat_b", null));
            Assert.IsTrue(target.IsValidMaterialName("mat_c", null));
        }

        /// <summary>
        ///A test for IsValidLayerName
        ///</summary>
        [TestMethod()]
        public void IsValidLayerNameTest()
        {
            OutlinerScene target = new OutlinerScene();
            OutlinerLayer editingLayer = new OutlinerLayer(1, -1, "layer_a", false, false, false, false);
            target.AddNode(editingLayer);
            editingLayer = new OutlinerLayer(2, 1, "layer_b", false, false, false, false);
            target.AddNode(editingLayer);

            Assert.IsFalse(target.IsValidLayerName(null));
            Assert.IsFalse(target.IsValidLayerName(""));
            Assert.IsFalse(target.IsValidLayerName("layer_a"));
            Assert.IsTrue(target.IsValidLayerName("layer_c"));
            Assert.IsTrue(target.IsValidLayerName("layer_b", editingLayer));
            Assert.IsTrue(target.IsValidLayerName("layer_c", editingLayer));
            Assert.IsFalse(target.IsValidLayerName("layer_b", null));
            Assert.IsTrue(target.IsValidLayerName("layer_c", null));
        }

        /// <summary>
        ///A test for GetNodeByHandle
        ///</summary>
        [TestMethod()]
        public void GetNodeByHandleTest()
        {
            OutlinerScene target = new OutlinerScene();
            int handle = 1;
            OutlinerNode expected = new OutlinerMaterial(handle, -1, "", "");
            OutlinerNode actual;
            target.AddNode(expected);
            actual = target.GetNodeByHandle(handle);
            Assert.AreEqual(expected, actual);

            handle = 2;
            actual = target.GetNodeByHandle(handle);
            Assert.IsNull(actual);
        }

        /// <summary>
        ///A test for GetChildNodes
        ///</summary>
        [TestMethod()]
        public void GetChildNodesTest()
        {
            OutlinerScene target = new OutlinerScene();
            int parentHandle = 0;
            List<OutlinerNode> actual;
            actual = target.GetChildNodes(parentHandle);
            Assert.IsNotNull(actual);
            Assert.IsTrue(actual is List<OutlinerNode>);

            OutlinerObject n = new OutlinerObject(1, -1, "", 0, 0, "", "", false, false, false, false, false);
            target.AddNode(n);
            actual = target.GetChildNodes(-1);
            Assert.IsNotNull(actual);
            Assert.IsTrue(actual is List<OutlinerNode>);
            Assert.AreEqual(1, actual.Count);
            Assert.AreEqual(n, actual[0]);

            n = new OutlinerObject(2, 1, "", 0, 0, "", "", false, false, false, false, false);
            target.AddNode(n);
            n = new OutlinerObject(3, 1, "", 0, 0, "", "", false, false, false, false, false);
            target.AddNode(n);
            actual = target.GetChildNodes(1);
            Assert.IsNotNull(actual);
            Assert.IsTrue(actual is List<OutlinerNode>);
            Assert.AreEqual(2, actual.Count);
        }

        /// <summary>
        ///A test for DeleteNode
        ///</summary>
        [TestMethod()]
        public void DeleteNodeTest1()
        {
            OutlinerScene target = new OutlinerScene(); // TODO: Initialize to an appropriate value
            Int32 numNodes = target.Nodes.Count;
            OutlinerNode n = null; // TODO: Initialize to an appropriate value
            target.RemoveNode(n);

            n = new OutlinerMaterial(1, -1, "", "");
            target.RemoveNode(n);
            Assert.AreEqual(numNodes, target.Nodes.Count);
            Assert.AreEqual(0, target.RootNodes.Count);
            target.AddNode(n);
            target.RemoveNode(n);
            Assert.AreEqual(numNodes, target.Nodes.Count);
            Assert.AreEqual(0, target.RootNodes.Count);

            Assert.IsNotNull(n);
        }

        /// <summary>
        ///A test for DeleteNode
        ///</summary>
        [TestMethod()]
        public void DeleteNodeTest()
        {
            OutlinerScene target = new OutlinerScene(); // TODO: Initialize to an appropriate value
            Int32 numNodes = target.Nodes.Count;

            OutlinerMaterial m = new OutlinerMaterial(1, -1, "", "");
            target.AddNode(m);
            target.RemoveNode(m);
            Assert.AreEqual(numNodes, target.Nodes.Count);
            Assert.AreEqual(0, target.RootNodes.Count);

            OutlinerObject o = new OutlinerObject(2, -1, "", 1, 1, "", "", false, false, false, false, false);
            target.AddNode(o);
            OutlinerObject p = new OutlinerObject(3, 2, "", 1, 1, "", "", false, false, false, false, false);
            target.AddNode(p);
            Assert.AreEqual(numNodes + 2, target.Nodes.Count);
            Assert.AreEqual(1, target.RootNodes.Count);
            target.RemoveNode(o);
            Assert.AreEqual(numNodes + 1, target.Nodes.Count);
            Assert.AreEqual(0, target.RootNodes.Count);
        }

        /// <summary>
        ///A test for AddNode
        ///</summary>
        [TestMethod()]
        public void AddNodeTest()
        {
            OutlinerScene target = new OutlinerScene(); // TODO: Initialize to an appropriate value
            OutlinerNode n = null; // TODO: Initialize to an appropriate value
            target.AddNode(n);
            Assert.AreEqual(1, target.Nodes.Count);
            Assert.AreEqual(0, target.RootNodes.Count);

            n = new OutlinerMaterial(1, -1, "", "");
            target.AddNode(n);
            Assert.AreEqual(2, target.Nodes.Count);
            Assert.AreEqual(1, target.RootNodes.Count);

            target.AddNode(n);
            Assert.AreEqual(2, target.Nodes.Count);
            Assert.AreEqual(1, target.RootNodes.Count);

            n = new OutlinerObject(2, OutlinerScene.ObjectRootHandle, "", 4, 1, "", "", false, false, false, false, false);
            target.AddNode(n);
            Assert.AreEqual(3, target.Nodes.Count);
            Assert.AreEqual(2, target.RootNodes.Count);

            n = new OutlinerObject(3, 2, "", 4, OutlinerScene.MaterialUnassignedHandle, "", "", false, false, false, false, false);
            target.AddNode(n);
            Assert.AreEqual(4, target.Nodes.Count);
            Assert.AreEqual(2, target.RootNodes.Count);

            n = new OutlinerObject(5, OutlinerScene.ObjectRootHandle, "", 4, OutlinerScene.MaterialUnassignedHandle, "", "", false, false, false, false, false);
            target.AddNode(n);
            Assert.AreEqual(5, target.Nodes.Count);
            Assert.AreEqual(3, target.RootNodes.Count);
        }

        [TestMethod()]
        public void GetChildNodesCountTest()
        {
            OutlinerScene target = new OutlinerScene();
            Assert.AreEqual(0, target.GetChildNodesCount(10));

            target.AddNode(new OutlinerObject(1, -1, "", -1, -1, "", "", false, false, false, false, false));
            Assert.AreEqual(0, target.GetChildNodesCount(1));

            target.AddNode(new OutlinerObject(2, 1, "", -1, -1, "", "", false, false, false, false, false));
            Assert.AreEqual(1, target.GetChildNodesCount(1));

            target.AddNode(new OutlinerObject(3, 1, "", -1, -1, "", "", false, false, false, false, false));
            Assert.AreEqual(2, target.GetChildNodesCount(1));
        }
    }
}
