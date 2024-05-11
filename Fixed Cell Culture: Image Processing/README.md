# Fixed Cell Culture 4i: Image Processing

Magda Bujnowska   
Date: May 1, 2024

This vignette provides step-by-step procedure for processing and analyzing Iterative Indirect Immunofluorescence Imaging (4i) data for fixed adherent cells obtained following the fixed cell 4i protocol from:   
   
Hsu J\*, Nguyen KT\*, Bujnowska M, Janes KA, Fallahi-Sichani M. Iterative indirect immunofluorescence imaging in cultured cells, tissue sections, and metaphase chromosome spreads. Submitted to STAR Protocols (Under minor revision, 2024). [\*Equal contributions]

## Required software
- Fiji
  - version 2.14.0/1.54f
  - https://imagej.net/software/fiji/
  - RRID: SCR_002285
- CellProfiler
  - version 4.2.5
  - https://cellprofiler.org/
  - RRID: SCR_007358
- MATLAB
  - version 9.14.0.2206163 (R2023a)
  - https://www.mathworks.com/
  - RRID: SCR_001622


## Example Images
Example images are provided for learning the image processing pipeline. The images are of COLO858 melanoma cell line and contain only the middle field of view in three separate wells. When imaging your own plates, we recommend imaging all fields of view in each well. Here, we are including only a few images to save on space and analysis time. It includes three rounds with four channels each. The first and second channel is the same across all rounds. First channel is Hoechst staining, which is used for the alignment and segmentation of the nuclei. The second channel is CellMask Green staining, which is used for segmentation of the cytoplasm. The remaining two channels are different in each round.   
  
Round 1: FRA1 (Channel 3; nuclear) and MITF (Channel 4; nuclear)  
Round 2: NGFR (Channel 3; cytoplasm) and SOX10 (Channel 4; nuclear)   
Round 3: AXL (Channel 3; cytoplasm) and cJUN (Channel 4; nuclear)   
Note: The expression of some of these proteins is low in COLO858, particularly NGFR, AXL, and cJUN. 

Folders called "Background_Subtracted_Images", "Alignment_results", "Aligned_Images", "Segmeneted_Images_Hoechst", "Segmented_Images_Cell_Mask", "TrackedNuclei", and "Analysis" contain intermediate and final files from the analysis of the Example Images.

## Background subtraction
Perform background subtraction using the rolling ball subtraction algorithm in ImageJ Fiji<Sup>1</Sup> with a ball radius of 50. 

1. Download and open the IMJ batch script file: Fixed_Cell_Culture_BG_Subtraction.ijm with Fiji.
2. Create a directory for the background subtracted images. Change the input and output paths to the images.
The following is an example:
```
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
```
3. Press "Run" button.
4. Repeat for the rest of the directories that contain images (ex. Round_2 and Round_3 in the Example Images).

## Alignment
To account for small shifts in image position across rounds, images are aligned using CellProfiler<sup>2</sup> Align Module and the provided  MATLAB script. First, use the CellProfiler pipeline Fixed_Cell_Culture_4i_Align.cpproj to determine how many pixels the Hoechst image shifted in the X and Y directions in each round relative to the first round. Next, use the MATLAB script Fixed_Cell_Culture_4i_Image_Shift_and_Crop.m to shift each image based on the X and Y values obtained from CellProfiler and crop images to the same size. 

### Align Hoechst images across all rounds using CellProfiler
1. Open CellProfiler. Drag and drop the Fixed_Cell_Culture_4i_Align.cpproj pipeline to the left panel.
2. The left panel will now show all of the modules included in the pipeline. Carefully check each of the six modules:

	<ins>**2.1 Images module**:</ins> Load background subtracted images. Apply the "Images only" filter to the file list.   
	
	<ins>**2.2 Metadata module**:</ins> At this point, ensure that the folders and tiff files have a consistent naming convention that contains all of the necessary metadata to distinguish each condition. In the Metadata module, extract the following metadata information from the file names and/or folder names using regular expressions: round, well row, well column, site (9 fields of view), channel, and plate numbers if your experiment has multiple plates. After regular expressions are written press "Update" and check if all of the metadata was correctly extracted. 
	
	For Example Images, extract `Round` numbers from the folder names:  
	- Example folder name: "Round_1"
	- The regular expression used to extract the `Round` numbers: `Round_(?P<Round>\d)`
	
	Extract `Row`, `Column`, `Site`, and `Channel` numbers from the file names:
	- Example file name: "r02c02f01p01-ch1sk1fk1fl1.tiff"
	- The regular expression used to extract the `Row`, `Column`, `Site`, and `Channel` numbers: `r0(?P<Row>\d)c0(?P<Column>\d)f0(?P<Site>\d)p01-ch(?P<Channel>\d)sk1fk1fl1.tiff`
	
	This is how the table at the bottom should look like after pressing "Update" for the Example Images.   
	<img width="675" alt="Align_metadata" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/107584055/35abfa57-eab6-464a-adec-48663a72787a">

	Note: The example images are all from the same row and field of view, so to analyze these images it is not technically necessary to extract `Row` and `Site`. Here, I am showing how to extract all of the metadata information because typical experiments contain more wells. 
	
	<ins>**2.3 NameAndTypes module**:</ins> Assign names to each round number. Only use images with channel number matching 1 (Hoechst stain) because we only want to use the nuclei stain for obtaining the alignment information. Note: If you are getting an error, ensure that the Groups module is updated to your own experimental conditions. Press update and check if images are categorized correctly.
	This is how the table at the bottom should look like after pressing "Update" for the Example Images.  
	<img width="495" alt="Align_names" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/107584055/d488c431-4981-4da6-b030-8b425f0688d7">

	<ins>**2.4 Groups module**:</ins> Group the images by `Well` and `Site`. If your experiment includes multiple plates, then group the images by plate number. We want each Group to contain one image for each round.
	This is how the Image Sets table  should look like for the Example Images.  
 	<img width="1125" alt="Align_groups" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/107584055/08a00ad4-6438-4d2d-af69-1e3b1d5dbf47">

	<ins>**2.5 Align module**:</ins> Set the alignment method to “Normalized Cross Correlation”, crop mode to “Keep size” and input all of the rounds of imaging as the first input image, second input image, etc. In this example, there are only three rounds. 
	 
	<ins>**2.6 Export to spreadsheet module**:</ins> When selecting measurements, make sure to export the results from Align module and all Metadata, both of which are under Image.  

4. At the bottom left corner, press "Output Settings". Change the Default Input Folder to the directory with all Background Subtracted Images. Change the Default Output Folder to the main project directory.

5. Press "Analyze Images" to run the pipeline.

 6. After the CellProfiler finishes to run, check the output file. It is saved as “Image.csv” in “Alignment_results” folder. The file will contain information about how many pixels images in each round have to be shifted in the X and Y directions in order to be aligned with round 1 images. If there are any images that have to be shifted by over 50 pixels, check the raw images for quality. The following X and Y shift numbers are expected for the Example Images.

|Align_Xshift_Aligned_Round_1|Align_Xshift_Aligned_Round_2|Align_Xshift_Aligned_Round_3|Align_Yshift_Aligned_Round_1|Align_Yshift_Aligned_Round_2|Align_Yshift_Aligned_Round_3|
| :---: | :---: | :---: | :---: | :---: | :---: |
|0|-5|-3|0|-3|-3|
|0|-3|-1|0|-2|-2|
|0|-3|-1|0|-3|-2|  

### Shift and crop images from all channels using MATLAB script
Use the X and Y shifts saved from CellProfiler to align and crop images from all fluorescence channels using the provided MATLAB script. The script uses the `imtranslate`and `imcrop` functions to shift and crop images, respectively.

1. Open “Fixed_Cell_Culture_4i_Image_shift_and_crop” script in MATLAB.
2. Change the following variable in the top section: `project path, output_path, number_of_rounds, original_image_size, channels` according to your experimental design. The example images have 3 rounds, 1080x1080 pixel size, and there are 4 channels in each round.
3. Press "Run". The aligned and cropped images will be saved in the output folder. Inspect images in Fiji to ensure that the images are aligned across each round. The MATLAB script includes the round number in the file name. If the entire output folder is opened with Fiji, the images from the same row, column, and field of view should be grouped together, making it easier to check for changes in the alignment across all rounds.     
	 <img width="500" alt="Before_and_after_aligment1" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/107584055/d63aeac1-c319-48cc-a357-a25f468a2225">    
	Figure 1: Merged Hoechst images from round 1 (red), round 2 (green), and round 3 (blue) before and after alignment (Example images with the prefix "r02c02f01").

## Segmentation and Tracking
Segmentation and Tracking is done using CellProfiler. Tracking module is particularly  computationally time consuming, so we recommend to initially analyze the images without tracking to ensure that the chosen segmentation method works on all images. Segmentation of nuclei and cell cytoplasm is made based on the Hoechst stain and CellMask Green stain, respectively. 

1. Open CellProfiler and drag and drop the Fixed_Cell_Culture_4i_Segmentation_and_Tracking.cpproj pipeline to the left panel.
   
2. The left panel will now show all of the modules included in the pipeline. Carefully check each of the 19 modules:

	<ins>**2.1 Images module**:</ins> Load Aligned Images. Apply the "Images only" filter to the file list. 
	
	<ins>**2.2 Metadata module**:</ins> Extract the following metadata information from the file names and/or folder names using regular expressions: round, well row, well column, site (9 fields of view), channel, and plate numbers if your experiment has multiple plates. After regular expressions are written press "Update" and check if all of the metadata was correctly extracted. 
		
	For Example Images, extract `Round`, `Row`, `Column`, `Site`, and `Channel` numbers from the file names:
	- Example file name: "r02c02f01_round1-ch1sk1fk1fl1.tiff"
	- The regular expression used to extract the `Row`, `Column`, `Site`, `Round`, and `Channel` numbers: `^r0(?P<Row>\d)c0(?P<Column>\d)f0(?P<Site>\d)_round(?P<Round>\d)-ch(?P<Channel>\d)sk1fk1fl1.tiff`
		
	<ins>**2.3 NameAndTypes module**:</ins> Assign names to each channel. Press update and check if images are categorized correctly.   
  	<img width="675" alt="Segmentation_names" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/107584055/45798271-b392-4e1f-8ae5-79f5d2728e79">

	<ins>**2.4 Groups module**:</ins> Group the images by `Well`, `Site`, and any condition other than round number. The number of images in each group should be equal to the number of rounds. 
	<img width="1700" alt="Segmentation_groups" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/107584055/0d6cd87d-c9e8-4fb7-a565-325d4a87023d"> 

	<ins>**2.5 IdentifyPrimaryObjects module**:</ins> Using minimum cross-entropy thresholding method, identify nuclei based on DAPI/Hoechst signal. If the segmentation does not look good, this step can be optimized by changing threshold smoothing scale, threshold correction factor or trying other thresholding methods. In particular, if there is a lot of background noise, Manual thresholding method works well. You can use the Test Mode to determine settings that work best for your images. 
	
	<ins>**2.6 IdentifySecondaryObjects module**:</ins> Use CellMask Green images to determine the outline of the cell around the nuclei identified from the IdentifyPrimaryObjects module. The thresholding method, threshold smoothing scale, and threshold correction factor should be adjusted based on your images. 
	
	<ins>**2.7 IdentifyTertiaryObjects module**:</ins> This module identifies the cytoplasm by subtracting nuclei from the cell outline.
	
	The following three modules are used to check the quality of the nuclei segmentation in IndentifyPrimaryObjects module.   
	<ins>**2.8 First ImageMath module**:</ins> Multiply the intensity of Hoechst image by 30 and name the output image `Hoechst_Times30`. 
	
	<ins>**2.9 First OverlayOutline module**:</ins> Overlay `Hoechst_Times30` image with the outline of nuclei (from IdentifyPrimaryObjects module) and name the output image as `Hoechst_Nuclei_overlay`. 
	
	<ins>**2.10 First SaveImages module**:</ins> Save the `Hoechst_Nuclei_overlay` image. These images should be used to check for proper nuclei segmentation after the analysis is done. It is important to check every image, because a segmentation method may work well for the majority of the images and not work for a few images. 

	 <img width="400" alt="r02c02f01_round1-ch1sk1fk1fl1_Round1_Seg" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/107584055/fc74686a-3385-49e3-8de1-937eba281f6a">

	Figure 2: Example `Hoechst_Nuclei_overlay` image (r02c02f01_round1).

	The following three modules are used to check the quality of the cell segmentation in IndentifySecondaryObjects module.    
	<ins>**2.11 Second ImageMath module**:</ins> Multiply the intensity of CellMask_Green image by 30 and name the output image `CellMask_Times30`. 

	<ins>**2.12 Second OverlayOutline module**:</ins> Overlay `CellMask_Times30` image with the outline of cells (from IdentifySecondaryObjects module) and name the image as `CellMask_overlay`. 
	
	<ins>**2.13 Second SaveImages module**:</ins> Save the `CellMask_overlay` image. These images should be used to check for proper cell segmentation after the analysis is done. 

	 <img width="400" alt="r02c02f01_round1-ch2sk1fk1fl1_Round1_Seg" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/107584055/594df78e-232b-4941-abdf-5daf9117370c">

 	Figure 3: Example `CellMask_overlay` image (r02c02f01_round1).
 
	<ins>**2.14 TrackObjects module**:</ins> Use the Follow Neighbors method to track nuclei across each round. Each nucleus will be given a unique identifier number across the rounds. If a new nucleus appears in later rounds, it will be given new number. This can occur because it is difficult to obtain perfect nuclei segmentation. However, most of the nuclei should be tracked across all rounds. If majority of nuclei are not tracked across all rounds, it is an indication of either poor segmentation or cell detachment/movement during the different rounds of the experiment. 
	
	<ins>**2.15 Third SaveImages module**:</ins> Save TrackedNuclei images.  
	
 	<img width="1000" alt="Tracking" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/107584055/9f344e6b-b09c-421c-bb61-45042b3152a4">
  	Figure 4: Example images from tracking. The numbers are unique identifiers of each nuclei across the rounds. In this example, most of the nuclei have the same numbers in each of the three rounds. However, it is normal for there to be a few nuclei that are not tracked throughout all of the rounds due to imperfect segmentation (white arrow in the zoomed images shows an example). 
	
	<ins>**2.16 MeasureObjectIntensity module**:</ins> Select Hoechst, CellMask_Green, and any other channel from which you want to measure the intensity. Select Nucleus, Cell, and Cytoplasm as objects to be measured. 
	
	<ins>**2.17 MeasureObjectSizeShape module**:</ins> Select Nucleus, Cell, and Cytoplasm as objects to be measured. 
	
	<ins>**2.18 ExportToSpreadsheet module**:</ins> Export intensity measurements for Nucleus, Cell, and Cytoplasm. Also, export "Image" and "Experiment" to save information about the analysis pipeline. Important: When selecting measurements ensure to at minimum select "TrackObjects" under "Nucleus" and "MeanIntensity" under "Nucleus", "Cell", and "Cytoplasm". The "TrackObjects" will record a unique identifier for each nucleus and other important information necessary to link cells across multiple rounds of imaging. 
	
	<ins>**2.19 CreateBatchFiles module (Optional)**:</ins> This module will create a "BatchFile" that will allow you to run the CellProfiler pipeline from the terminal. Each Batch file will be run on only one core. If you have a lot of conditions, it might be optimal to divide up the images (making sure that each batch contains all rounds) by plate, row, or column and making one batch file for each set of images. Then run each batch file from a separate terminal window or tab depending on the number of available cores on your computer. 

4. At the bottom left corner, press "Output Settings". Change the Default Input Folder to the directory with all Aligned Images. Change the Default Output Folder to the main project directory.

5. Press "Analyze Images" to run the pipeline. If using the terminal to run Batch files, use the following Unix commands:
```bash
		cd /Applications/CellProfiler.app/Contents/MacOS 
		./cp --get-batch-commands <path to Batch_data.h5 file> -r -c
		./cp -r -c -p <path to Batch_data.h5 file> -f 1 -l <number of the last image>
```

## Further analysis of the resulting text files
The resulting comma-separated text files for each image will contain one row for each cell. Columns will contain nucleus, cell, and cytoplasm intensity measurements for each fluorescence channel. Additionally, there will be a column with a unique identifier (called “TrackedObjects_Label_50”) for each cell and a column with the number of rounds in which each cell was detected (called “TrackedObjects_Lifetime_50"). When organizing the data, I like to use the “TrackedObjects_Lifetime_50” column from the Measurement.csv file from the final round to identify the cells/objects that are present in every round of the experiment. Then, I use the “TrackedObjects_Label_50” to identify the same cell/object in each round. Additional organization and analysis of data can be performed with MATLAB, R, or Python.   

The following is an example of “TrackedObjects_Label_50” and “TrackedObjects_Lifetime_50" for a few cells in round 3 of "r02c02f01" images.   
<img width="255" alt="tracking_table" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/107584055/64fd5e3a-8055-4928-b688-78540fdf9652">

## References
1. Schindelin, J., Arganda-Carreras, I., Frise, E., Kaynig, V., Longair, M., Pietzsch, T., Preibisch, S., Rueden, C., Saalfeld, S., Schmid, B., et al. (2012). Fiji: an open-source platform for biological-image analysis. Nat. Methods 9, 676–682. 10.1038/nmeth.2019.
2. Carpenter, A.E., Jones, T.R., Lamprecht, M.R., Clarke, C., Kang, I.H., Friman, O., Guertin, D.A., Chang, J.H., Lindquist, R.A., Moffat, J., et al. (2006). CellProfiler: image analysis software for identifying and quantifying cell phenotypes. Genome Biol. 7, R100. 10.1186/gb-2006-7-10-r100.







