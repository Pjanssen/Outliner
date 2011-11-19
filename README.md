Outliner
========
The Outliner 2.0 is a fast and easy to use scene management tool. It has a wide 
range of features, including selecting, hiding, freezing, linking and grouping 
objects in the "Hierarchy Mode". In the "Layer Mode" you can organize your scene 
by dragging & dropping objects from one layer to the other. 
What's more, the Outliner offers support for nested layers, to organize scenes 
more efficiently. The interface is nimble enough to keep it open constantly.

License
-------
This project is licensed under the BSD license. 
For the complete license, see LICENSE.txt


Requirements
------------
* 3dsmax 2010
* .NET Framework v3.5
* 7zip (to build an installer from the source)


Building
--------

1. Obtain a copy of the source. You can do this by using the git version control
   system (http://git-scm.com/) to pull the project in. 
   If you're unsure how this works, you can download a .zip from one of these sources:
   https://github.com/Pjanssen/Outliner/zipball/master (Master/Release branch)
   https://github.com/Pjanssen/Outliner/zipball/develop (Development/Beta branch)
   https://github.com/Pjanssen/Outliner/zipball/experiment (Experimental branch)
   
2. Make sure you have the .NET Framework 3.5 or above. Since 3dsmax has the 
   same requirement, you should be fine here.
   http://www.microsoft.com/net

3. Download and install 7-zip
   http://www.7-zip.org/

4. Run buildandbundle.bat
   This will compile the .NET code and create a .mzp installer.

5. Drag & drop the created file outliner.mzp into 3dsmax to start the installer.