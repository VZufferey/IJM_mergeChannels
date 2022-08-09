// Edited from http://dev.mri.cnrs.fr/projects/imagej-macros/wiki/Merge_channels
// This macro can be used to merge channels in a file list. It will look for the first channel of each image set, 
// and find the complementary channels basing on the shared filename and merge them into a composite tiff.

setBatchMode(true);
print ("\\Clear");

counter = 0;
baseChannel = channels[0];

//Here, ajust the channels' specifiers given in the filenames (ch1, ch23, ..., FITC, Cy3, Cy5, ..., etc) and the corresponding colormap to assign.
channels = newArray("BF", "WL508");
colors = newArray("Grays", "Green");

dir = getDirectory("input folder");

files = getFileList(dir);
for (i=0; i<files.length; i++) 
{
    merged = false;
    if (endsWith(files[0], "tif")||endsWith(files[0], "nd2"))
    {
        if (indexOf(files[i], baseChannel) != -1) 
        {
	        print("\\Update0:" + "file " + (i+1) + "/" + files.length + " - MERGING");
		    counter++;
		    run("Bio-Formats Importer", "open=["+dir+files[i]+"] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		    run("8-bit");
		    run(colors[0]);
		    names = newArray(channels.length);
		    names[0] = files[i];
		    
		    for (j=1; j<channels.length; j++) //open every related image // other channels and set defined colormap
		    {
		         channel = replace(files[i], channels[0], channels[j]);
		         run("Bio-Formats Importer", "open=["+dir+channel+"] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		         wait(1000);
		         run("8-bit");
		         names[j] = channel;
		         run(colors[j]);
			}
		
	    options = ""; //reinitialisation of merging options
	    for (j=0; j<names.length;j++) //make options string for subsequent Merge Channels ccommands == list the images names and asociate to a channel number.
	    {
	        options = options + "c" + (j+1) + "=" + names[j] + " ";
	    }
	    print(options);
        options = " " + options + "create";        
        run("Merge Channels...", options);
        Stack.setDisplayMode("Composite");
	
	    result = replace(files[i], "-"+channels[0], ""); //replace "" by  [toString(channels.length) + "Channels"] to specifiy channels number in output file name
	    saveAs("Tiff", dir + result);
	    close();
	    merged = true;
	    print(toString(i) + ": file " + files[i] + " - MERGED");
        }
	 } 
	    
	    if (!merged) 
	    {
	        print("\\Update0:" + "file " + (i+1) + "/" + files.length + " - SKIPPING");
	        print(toString(i) +": file " + files[i] + " - SKIPPED");
   		}
}

print("\nMERGE CHANNELS FINISHED (" + counter +" hyperstacks created)");
setBatchMode(false);
