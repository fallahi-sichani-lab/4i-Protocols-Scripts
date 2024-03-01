// ImageJ script for background subtraction using the rolling ball subtraction algorithm


function action(inputFolder, outputFolder, filename) {
        open(inputFolder + filename);
	run("Subtract Background...", "rolling=50");
        save(outputFolder + filename);
        close();
}

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

// Change folder names below for input and output directories

inputFolder = "<Path to the input directory with original images>"
outputFolder = "<Path to the output directory>"

setBatchMode(true);
images = getFileList(inputFolder);
for (i = 0; i < images.length; i++)
	if (endsWith(images[i], ".tiff"))
        	action(inputFolder, outputFolder, images[i]);
setBatchMode(false);

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////





