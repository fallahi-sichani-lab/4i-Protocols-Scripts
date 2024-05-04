// ImageJ script for background subtraction using the rolling ball subtraction algorithm

function action(inputFolder, outputFolder, filename) {
        open(inputFolder + filename);
	run("Subtract Background...", "rolling=50");
        save(outputFolder + filename);
        close();
}

// Change folder names below for input and output directories

inputFolder = "/Users/mb8rg/Desktop/Fixed_Cell_Culture_Image_Processing/Example_Images/Round_1/"
outputFolder = "/Users/mb8rg/Desktop/Fixed_Cell_Culture_Image_Processing/Background_Subtracted_Images/Round_1/"

setBatchMode(true);
images = getFileList(inputFolder);
for (i = 0; i < images.length; i++)
	if (endsWith(images[i], ".tiff"))
        	action(inputFolder, outputFolder, images[i]);
setBatchMode(false);






