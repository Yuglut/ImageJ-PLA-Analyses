// Macro
/*
This ImageJ script analyses PLA images. When running, the user is 
prompted to select the folder in which files to analyse are present and
their extension. Results will be stored where the output variable 
references to.
*/
#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".nd2") suffix

NucChan = 0; // Nucleus channel
PLAChan = 1; // PLA channel
output = input+File.separator+"ImageJ-PLA-Analysis.txt"; // Output results file
f = File.open(output);
File.close(f);
File.append("#Filename    Dots    Nuclei    Dots/nuclei", output);
processFolder(input,output,suffix);
print("\\Clear");
print("Finished execution");

function processFile(input, output, file) { 
// routine to process individual files
	run("Bio-Formats Importer", "open=[" + input  + File.separator + file + "] split_channels autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	images_list = getList("image.titles"); // List the images (or channels)
	for (i = 0; i < images_list.length; i++ ) {
		print(images_list[i]);
	}
	//imageCalculator("Subtract create", images_list[1],images_list[0]); // Subtract background
	//close(images_list[1]);
	//images_list[1] = "Result of "+images_list[1];
//	waitForUser("subtracted");
	for (i = 0; i < images_list.length; i++ ) {
// Actual data processing
		curr_name = images_list[i];
// 8-bit conversion
		selectWindow(curr_name);
		setOption("ScaleConversions", true);
		run("8-bit");
//PLA images
		if (i == 0) {
			rad = 4;
		}
		else {
			rad = 1;
		}
		Mean_Tresh(curr_name,rad);
//		run("Convert to Mask");
//		run("Close");
//		close(curr_name);
	}
// Nuclei
	curr_name = images_list[NucChan];
	selectWindow(curr_name);
	run("Fill Holes");
	run("Analyze Particles...","size=10-Infinity  show=Outlines summarize in_situ");
// PLA
	curr_name = images_list[PLAChan];
	selectWindow(curr_name);
	run("Analyze Particles...", "size=0.25-infinity show=Outlines summarize in_situ");
  	IJ.renameResults("Results");
  	nuclei = getResult("Count",0);
  	dots = getResult("Count",1);
  	File.append(file+"    "+dots+"    "+nuclei+"    "+parseFloat(dots)/parseFloat(nuclei), output);
  	close("Results");
	close_windows();
	}

function processFolder(input,output,suffix) {
// Proceses the whole folder
	list = getFileList(input);
	list = Array.sort(list);
//	i = 1;
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i],output,suffix);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
	print("\\Clear");
}

function Mean_Tresh(window,radius){
// Set a threshold
	selectWindow(window);
	run("Mean...", "radius="+radius);
//	setAutoThreshold("Default dark");
	setAutoThreshold("Otsu dark");
	setThreshold(25, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
//	waitForUser("mean");
}

function close_windows(){
// Close all windows
	images_list = getList("image.titles");
	for (i = 0; i < images_list.length; i++ ) {
		close(images_list[i]);
	}
}
