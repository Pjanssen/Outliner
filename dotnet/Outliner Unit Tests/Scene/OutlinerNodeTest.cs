using Outliner.Scene;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Collections.Generic;

namespace Outliner_Unit_Tests
{
    
    
    /// <summary>
    ///This is a test class for OutlinerNodeTest and is intended
    ///to contain all OutlinerNodeTest Unit Tests
    ///</summary>
    [TestClass()]
    public class OutlinerNodeTest
    {
        private OutlinerScene _scene;

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
        [TestInitialize()]
        public void MyTestInitialize()
        {
            _scene = new OutlinerScene();
            _scene.AddNode(new OutlinerLayer(1, -1, "layer", true, false, false, false));
            _scene.AddNode(new OutlinerMaterial(2, -1, "mat", "standard"));
            _scene.AddNode(new OutlinerObject(3, -1, "obj_a", 1, 2, "sphere", MaxTypes.Geometry, false, false, false, false, false));
            _scene.AddNode(new OutlinerObject(4, 3, "obj_b", 1, 2, "sphere", MaxTypes.Geometry, false, false, false, false, false));
        }
        //
        //Use TestCleanup to run code after each test has run
        //[TestCleanup()]
        //public void MyTestCleanup()
        //{
        //}
        //
        #endregion

        internal virtual OutlinerNode CreateOutlinerNode()
        {
            // TODO: Instantiate an appropriate concrete class.
            OutlinerNode target = new OutlinerObject(100, -1, "obj_target", 1, 2, "sphere", MaxTypes.Geometry, false, false, false, false, false);
            return target;
        }


        /// <summary>
        ///A test for Scene
        ///</summary>
        [TestMethod()]
        public void SceneTest()
        {
            OutlinerNode target = CreateOutlinerNode();
            Assert.IsNull(target.Scene);
            _scene.AddNode(target);
            Assert.AreEqual(_scene, target.Scene);
            _scene.RemoveNode(target);
            Assert.IsNull(target.Scene);
        }

        /// <summary>
        ///A test for ParentHandle
        ///</summary>
        [TestMethod()]
        public void ParentHandleTest()
        {
            OutlinerNode target = CreateOutlinerNode();
            int expected = 3;
            int actual;
            target.ParentHandle = expected;
            actual = target.ParentHandle;
            Assert.AreEqual(expected, actual);

            _scene.AddNode(target);
            List<OutlinerNode> children = _scene.GetChildNodes(3);
            Assert.IsTrue(children.Contains(target));

            target.ParentHandle = -1;
            Assert.AreEqual(-1, target.ParentHandle);
            children = _scene.GetChildNodes(-1);
            Assert.IsTrue(children.Contains(target));
        }

        /// <summary>
        ///A test for Parent
        ///</summary>
        [TestMethod()]
        public void ParentTest()
        {
            OutlinerNode target = CreateOutlinerNode();
            _scene.AddNode(target);
            Assert.IsNull(target.Parent);
            
            target.ParentHandle = 3;
            Assert.IsNotNull(target.Parent);
            Assert.AreEqual(_scene.GetNodeByHandle(3), target.Parent);

            target.Parent = null;
            Assert.IsNull(target.Parent);

            target.Parent = _scene.GetNodeByHandle(4);
            Assert.IsNotNull(target.Parent);
            Assert.AreEqual(_scene.GetNodeByHandle(4), target.Parent);
        }

        /// <summary>
        ///A test for Layer
        ///</summary>
        [TestMethod()]
        public void LayerTest()
        {
            OutlinerNode target = CreateOutlinerNode();
            _scene.AddNode(target);
            Assert.IsNotNull(target.Layer);

            OutlinerLayer newLayer = new OutlinerLayer(10, -1, "", false, false, false, false);
            _scene.AddNode(newLayer);
            target.Layer = newLayer;
            Assert.AreEqual(newLayer, target.Layer);

            target.LayerHandle = 1;
            Assert.AreEqual(_scene.GetNodeByHandle(1), target.Layer);
        }

        /// <summary>
        ///A test for Material
        ///</summary>
        [TestMethod()]
        public void MaterialTest()
        {
            OutlinerNode target = CreateOutlinerNode();
            _scene.AddNode(target);
            Assert.IsNotNull(target.Material);

            OutlinerMaterial newMat = new OutlinerMaterial(10, -1, "", "");
            _scene.AddNode(newMat);
            target.Material = newMat;
            Assert.AreEqual(newMat, target.Material);

            target.MaterialHandle = 2;
            Assert.AreEqual(_scene.GetNodeByHandle(2), target.Material);
        }

        /// <summary>
        ///A test for IsRootNode
        ///</summary>
        [TestMethod()]
        public void IsRootNodeTest() 
        {
            OutlinerNode target = CreateOutlinerNode();
            Assert.IsTrue(target.IsRootNode);
            target.ParentHandle = 3;
            Assert.IsFalse(target.IsRootNode);
        }

        /// <summary>
        ///A test for Name
        ///</summary>
        [TestMethod()]
        public void NameTest() 
        {
            OutlinerNode target = CreateOutlinerNode(); // TODO: Initialize to an appropriate value
            Assert.AreEqual("obj_target", target.Name);
            target.Name = "test";
            Assert.AreEqual("test", target.Name);
            target.Name = null;
            Assert.AreEqual("", target.Name);
            target.Name = "test";
            target.Name = "";
            Assert.AreEqual("", target.Name);
        }

        /// <summary>
        ///A test for MaterialHandle
        ///</summary>
        [TestMethod()]
        public void MaterialHandleTest() 
        {
            OutlinerNode target = CreateOutlinerNode();
            Assert.AreEqual(2, target.MaterialHandle);

            target.MaterialHandle = 6;
            Assert.AreEqual(6, target.MaterialHandle);

            _scene.AddNode(target);
            target.MaterialHandle = OutlinerScene.MaterialUnassignedHandle;
            Assert.AreEqual(OutlinerScene.MaterialUnassignedHandle, target.MaterialHandle);
        }

        /// <summary>
        ///A test for LayerHandle
        ///</summary>
        [TestMethod()]
        public void LayerHandleTest() 
        {
            OutlinerNode target = CreateOutlinerNode(); // TODO: Initialize to an appropriate value
            Assert.AreEqual(1, target.LayerHandle);

            target.LayerHandle = OutlinerScene.LayerRootHandle;
            Assert.AreEqual(OutlinerScene.LayerRootHandle, target.LayerHandle);

            _scene.AddNode(target);
            target.LayerHandle = 1;
            Assert.AreEqual(1, target.LayerHandle);
        }





        /// <summary>
        ///A test for ChildNodesCount
        ///</summary>
        [TestMethod()]
        public void ChildNodesCountTest()
        {
            OutlinerNode target = CreateOutlinerNode();
            Assert.AreEqual(0, target.ChildNodesCount);

            OutlinerNode n = new OutlinerObject(101, target.Handle, "", -1, -1, "", "", false, false, false, false, false);
            _scene.AddNode(target);
            _scene.AddNode(n);

            Assert.AreEqual(1, target.ChildNodesCount);
        }

        /// <summary>
        ///A test for ChildNodes
        ///</summary>
        [TestMethod()]
        public void ChildNodesTest()
        {
            OutlinerNode target = CreateOutlinerNode(); // TODO: Initialize to an appropriate value
            Assert.IsNotNull(target.ChildNodes);

            _scene.AddNode(target);
            OutlinerNode child = new OutlinerObject(8, target.Handle, "", 1, 2, "", "", false, false, false, false, false);
            _scene.AddNode(child);
            Assert.AreEqual(1, target.ChildNodes.Count);
            Assert.IsTrue(target.ChildNodes.Contains(child));

            child.Parent = null;
            Assert.AreEqual(0, target.ChildNodes.Count);
        }

    }
}
