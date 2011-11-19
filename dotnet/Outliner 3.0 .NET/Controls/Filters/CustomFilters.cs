using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Reflection;

namespace Outliner.Controls.Filters
{
    internal static class CustomFilters
    {
        private static List<Type> GetFilterClasses(Assembly assembly, Type baseType)
        {
            return assembly.GetTypes().Where(type => type.IsSubclassOf(baseType)).ToList();
        }

        public static List<Type> LoadFilterAssembly(String filterFile)
        {
            try
            {
                Assembly filterAssembly = Assembly.LoadFile(filterFile);
                return CustomFilters.GetFilterClasses(filterAssembly, typeof(CustomNodeFilter));
            }
            catch (Exception e) { Console.WriteLine(e); }

            return new List<Type>();
        }

        public static List<List<Type>> LoadFilterAssemblies(String filterDir)
        {
            List<List<Type>> filterTypes = new List<List<Type>>();

            if (System.IO.Directory.Exists(filterDir))
            {
                String[] filterFiles = System.IO.Directory.GetFiles(filterDir, "*.dll", System.IO.SearchOption.AllDirectories);
                foreach (String filterFile in filterFiles)
                {
                    filterTypes.Add(CustomFilters.LoadFilterAssembly(filterFile));
                }
            }

            return filterTypes;
        }
    }
}
