using System.IO;
using System;

namespace Outliner
{
    public class MXSFileWatcher : FileSystemWatcher
    {
        public Object MXSObject { get; set; }

        public void WatchFileChange(String file)
        {
            if (File.Exists(file))
            {
                FileInfo f = new FileInfo(file);
                Path = f.DirectoryName;
                Filter = f.Name;
                EnableRaisingEvents = true;
                NotifyFilter = NotifyFilters.LastWrite;
            }
        }
    }
}
