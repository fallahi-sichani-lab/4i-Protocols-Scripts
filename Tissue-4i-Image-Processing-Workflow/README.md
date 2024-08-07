# Tissue 4i Image Processing Workflow

This vignette provides step-by-step processing and visualizing instructions for Iterative Indirect Immunofluorescence Imaging (4i) data for formalin-fixed paraffin embedded tissue sections obtained following the tissue-4i protocol from:

Hsu J*, Nguyen KT*, Bujnowska M, Janes KA, Fallahi-Sichani M. Protocol for iterative indirect immunofluorescence imaging in cultured cells, tissue sections, and metaphase chromosome spreads. STAR Protocols (2024). [\*Equal contributions]

In this protocol, we utilized the Revvity Operetta CLS High-Content analysis system to generate whole slide images of multiplexed protein localization on tissue. The Operetta consecutively images up to four slides at once and deposits those raw images into the same output folder. Thus, in this workflow, we have ASHLAR utilize the Index.idx.xml metadata to determine which TIFF files are attributed to each slide. ASHLAR then runs stitching and registration for all four slides consecutively to create four outputs. However, we are showing one slide for this vignette.

If not using the Operetta, the Index.idx.xml file can be replaced with a pyramidal image file that represents a single slide of imaging (ex.Melanoma1.lif for images obtained on a Leica). Alternatively, one can solely use the MCMICRO workflow starting from illumination correction if the input file is compatible (which Operetta outputs are not). Depending on the microscopy platform, input may require regular expressions to define the filenames. Please refer to [MCMICRO documentation](https://mcmicro.org/io.html) to determine the correct input.  

## Requirements

* [Nextflow](https://www.nextflow.io/)
* [Docker](https://docs.docker.com/install/)
* [Python 3.10+](https://www.python.org/downloads/)
* [Anaconda](https://www.anaconda.com/download)
* [ASHLAR](https://github.com/labsyspharm/ashlar)
* [ImageJ](https://imagej.net/ij/download.html)
* [BaSiC](https://github.com/marrlab/BaSiC)
* [imagej_basic_ashlar.py](https://github.com/labsyspharm/basic-illumination)

## Experimental set-up

In this vignette, we demonstrate the workflow we used to visualize the data in Figure 4. For a tutorial, we provided three folders of raw images from Operetta imaging, including:
* Postquench images taken after autofluorescence quenching, for the purpose of subtraction in later rounds
* Round 1 images where we immunostained for differentiation state markers NGFR (AF488), SOX10 (AF568), and MITF (AF647)
* Round 2 images where we immunostained for a pan-immune cell marker, CD45 (AF568) and a T-cell marker, CD3 (AF647).

These files can be found here: https://figshare.com/s/750147eec9e819ecc7a5

On this Github, we also include the markers.csv and params.yml files required to run MCMICRO. 

## BaSiC Illumination Correction 
Set PROJECT_DIR as the directory that contains imagej_basic_ashlar.py, params.yml, markers.csv, and the Operetta output folders that contain the raw images.
Change directory to the project directory to complete the remaining commands.


```bash
PROJECT_DIR="~/Vignette"
cd $PROJECT_DIR
```
The Operetta output "Images" folder should contain individual tiff files of each channel image of each field of view, as well as an Index.idx.xml file that contains the metadata.
To process the images in an order that parallels the order of the 4i rounds, we follow the convention of naming output folders as "Postquench_","Round1_","Round2_", and so on. Folders are later sorted in ascending numerical order.  
 
Using a regular expression that identifies your Operetta output folders, run the ImageJ plugin BaSiC on each round of imaging by iterating through each folder and running the imagej_basic_ashlar.py on the Operetta index files (Index.idx.xml). Here, we use "*__*"

To run the ImageJ BaSiC plugin on the command line, ensure the path to the application is correct.
Here, it is "/Applications/Fiji.app/Contents/MacOS/ImageJ-macosx". 

```bash
for DIR in *__*
    do
        experiment_name=${DIR%__*}
        mkdir -p $DIR/basic 
        /Applications/Fiji.app/Contents/MacOS/ImageJ-macosx --ij2 --headless --run imagej_basic_ashlar.py "filename='"$DIR"/Images/Index.idx.xml',output_dir='"$DIR"/basic/',experiment_name='$experiment_name'"
          
    done
```

After running BaSiC on each Operetta output folder, the Operetta output folders should have a new subfolder named "basic" containing dark field and flat field profiles for that round of imaging.
<p align="center">
<img width="694" alt="ffp_dfp_generation" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/cdf78eea-cfd6-4126-bb5a-a70dca1b2592">

</p>

##  ASHLAR Stitching and Registration
Here, we use ASHLAR to stitch together individual image tiles and register nuclei from data across rounds of 4i. Please refer to [ASHLAR documentation](https://github.com/labsyspharm/ashlar) for details.  


First, activate the Conda environment containing ASHLAR
```bash
conda activate ashlar
```

Create a registration folder within the project directory to direct the ASHLAR output.
```bash
mkdir -p registration
```
ASHLAR input for Operetta images required one Index.idx.xml files for each round. To correct illumination artifacts using the BaSiC-generated flat field and dark field profiles, the ffp.tif and dfp.tif files are inputted under the -ffp and -dfp flags in the same order as the Index files.
We generate arrays containing the necessary inputs by finding the files within our current project directory and sorting them
```bash
index_files_array=$(find . -name "Index.idx.xml" | sort -n)
ffp_files_array=$(find . -name "*ffp.tif" | sort -n)
dfp_files_array=$(find . -name "*dfp.tif" | sort -n)
```
Confirm the arrays contain all the index files, flat field profiles, and dark field profiles in the correct order.
```bash
echo $index_files_array
echo $ffp_files_array
echo $dfp_files_array
```
Expected output:
```
>./PostQuench__Mel1/Images/Index.idx.xml ./Round1__Mel1/Images/Index.idx.xml ./Round2__Mel1/Images/Index.idx.xml
>./PostQuench__Mel1/basic/PostQuench-ffp.tif ./Round1__Mel1/basic/Round1-ffp.tif ./Round2__Mel1/basic/Round2-ffp.tif
>./PostQuench__Mel1/basic/PostQuench-dfp.tif ./Round1__Mel1/basic/Round1-dfp.tif ./Round2__Mel1/basic/Round2-dfp.tif
```
Run ASHLAR with index files, flat field profiles and dark field profiles arrays as input. If desired, include a name for the output before the .ome.tif suffix: ./registration/<name>.ome.tif. Here, we include "Melanoma1" in the output file name.

Running ASHLAR on Operetta images requires the --plates flag for running four slides at a time.  The --flip-y flag corrects the orientation of the images. These flags may not be necessary depending on the microscopy platform.

We optimized this registration example with modifying parameters filter-sigma = 2 and maximum-shift = 60. Please refer to the [ASHLAR documentation](https://github.com/labsyspharm/ashlar) for more details. If there are stitching and registration artefacts, these parameters can be optimized through trial and error. 

```bash
ashlar $index_files_array --plates --flip-y -o ./registration/Melanoma1.ome.tif --ffp $ffp_files_array --dfp $dfp_files_array --filter-sigma 2 -m 60
```
ASHLAR will simultaneously stitch and register the images, and then write the output, per slide, to an .ome.tif. Output for one slide should start as follows:

<p align="center">

<img width="810" alt="ashlar_output" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/8d3bab7d-02dd-4e42-9ee0-c8ea0dd89efb">

</p>

The registration folder will populate with a "Postquench" folder containing the stitched and registered tissue images. Move the stitched image out of the subfolder, to be directly in /registration/

<p align="center">
<img width="687" alt="registered_image_generation" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/9ec89416-e1c4-4b91-b388-f0d9c051ecfa">

</p>
Drag and drop the registered ome.tif file, or move it from the command line using the following code:

```bash
mv ./registration/PostQuench/A02_Melanoma1.ome.tif ./registration/
```

## Background Subtraction using MCMICRO 

To computationally remove the remaining autofluorescence after the autofluorescence quenching step, we use the background subtraction module on MCMICRO.
The inputs required to run background subtraction on MCMICRO are as follows:
* a params.yml file directing MCMICRO to run background subtraction only
* a markers.csv file naming the cycles of imaging, imaging channels, and exposure times. Exposure times can be found in the index file. Our marker.csv file is provided as an example. Please see [MCMICRO background subtraction](https://mcmicro.org/parameters/core.html#backsub) documentation for more details. 
* a stitched and registered .ome.tif file (ASHLAR output) within the registration folder.
<p align="center">
<img width="690" alt="background_subtraction_run" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/8d6ccff9-e523-4fb6-9935-f8bef2c24c32">

</p>

```bash
nextflow run labsyspharm/mcmicro --in $PROJECT_DIR --params params.yml
```

The project directory will populate with work, qc, and background directories. The background directory contains the new ome.tif fill with Postquench channels completely removed, and remaining autofluorescence comptuationally subtracted from the channels as indicated in markers.csv. The new markers_bs.csv will indicate the new channels order in the .ome.tiff file
<p align="center">
<img width="485" alt="bgsub_generation" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/8bb60f41-1fa9-449f-a508-4e0d3bdc9e22">
</p>

## Visualization and quality control on ImageJ

To quickly visualize the background-subtracted, stitched and registered whole-tissue representation of the 4i experiment, open the ome.tiff file on ImageJ. ImageJ will display the BioFormats imports options. Check "Split Channels" to have each channel open separately.

<p align="center">
<img width="603" alt="bioformats" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/15b2a640-68b8-4706-a1e5-174821f936cd">
</p>

Choose a resolution to open the images. 

<p align="center">
<img width="452" alt="resolution" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/a1f6f3ce-15f2-4096-bf93-1133535d4170">

</p>

Select Window > Tile to see each channel at once. 

<p align="center">
<img width="1200" alt="window_tile" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/24e0b90d-09eb-4882-bc57-6ae6b8d02c54">

</p>

Each channel will have varying intensity ranges. The individual channels will likely be very dark and hard to visualize. Click on each channel image and implement auto-contrast by selecting Image > Adjust > Brightness/Contrast and applying autocontrast.

<p align="center">
<img width="1200" alt="autocontrast" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/4ca81ac4-130e-44ba-a11f-357c749971c3">

</p>

### ASHLAR quality control

To confirm that nuclei from each round of imaging were successfully stitched registered using ASHLAR, overlay the hoechst stain channels from Postquench, Round 1, and Round 2 in different colors using Image > Color > Merge Channels. 
<p align="center">
<img width="584" alt="mergehoechst" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/692742d9-77f8-4b28-bc5c-cac300863221">

</p>

A new composite image will generate overlaying the three nuclei channels. Here, the Postquench Hoechst (C=0) is green, Round 1 Hoechst (C=0) is gray, and Round 2 Hoechst (C=5) is cyan.  


<p align="center">
 
<img width="656" alt="mergehoechst2" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/d803828a-ebc4-4287-8d84-d6804bbd41f8">
</p>
Zoom in using the magnifying glass tool and inspect several field of view in areas of varying cell density and at the edges if the tissue. Confirm that nuclei are overlaid correctly at a single cell resolution, ie. there are no noticeable "shadows" of shifted nuclei. Loss of nuclei through mechanical damage, especially at the edges of the tissue, is expected over time. 


<p align="center">
<img width="400" alt="fov1" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/63a2b5c4-bbf6-4920-b99e-2e60b3b16c8b"><img width="400" alt="fov2" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/d18c0361-b125-4a54-bb08-633dbc8ea011">
</p>

After confirming proper stitching and registration, save the Postquench Hoechst as the representative nuclei stain (File > Save as > Tiff)

### Rolling-ball background subtraction

ImageJ's built in rolling-ball background subtraction helps to remove uneven background across the slide from the protein stains for figure-quality images. For quick visualization, this step can be skipped and Image > Color > Merge Channels can be used with images as-is. 

To perform rolling-ball background subtraction on all protein stains at once, close all channels such that only the protein stains are remaining. Here, we stained for NGFR, SOX10, MITF, CD45, and CD3.

Select Images > Stack > Images to Stack 

<p align="center">
<img width="1323" alt="proteinstack" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/8ff04e11-b205-4892-a02a-c9ca2cd8905c">

</p>
Click on the stack. Select Process > Subtract Background... Set radius to 5px.

ImageJ will run rolling-ball background subtraction on each image in the stack.

<p align="center">
<img width="282" alt="subtractbg" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/51d4ea8e-bd2d-4ad7-9e83-3a3be7d178c1">
<img width="281" alt="rollingball_stack" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/90d8e518-d2a8-4482-b3bd-c0a1840945ec">

</p>

After rolling ball background subtraction is completed, the images should have increased signal-to-noise ratio. Save each channel in the stack by selecting File > Save As > Image Sequence...

<p align="center">
<img width="442" alt="Save as image sequence " src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/45f85fd9-a830-436f-bb8a-19415adbef5d">

</p>

## Multiplexed image generation

Rename the tif files of individual channels accordingly. markers_bs.csv can be used as a reference. 
<p align="center">
<img width="290" alt="Files" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/992bfc4d-b57c-4e09-a9e1-5ceaef300d27">
<img width="182" alt="files renamed" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/ce0c3427-c1dc-401e-8412-ecbf0bef022f">



</p>
Drag the files to ImageJ to open the images of each channel. After illumination correction, stitching, registration, and two forms of background subtraction, these baseline images are ready for cropping and contrast enhancements for figure generation.

To quickly visualize the merged, multiplexed image, auto-contrast the individual channels (Image > Adjust > Brightness/Contrast). Select Image > Color > Merge Channels 
<p align="center">
<img width="1175" alt="merge_multiplex" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/2ad52380-15dc-43d8-a708-3f8067100959">

</p>

The final composite image should show the 5 proteins markers, NGFR, SOX10, MITF, CD45 and CD3 overlaid on nuclei. To isolate one or more channels for visualization, use the Channels Tool under Image > Color > Channels Tool...
<p align="center">
<img width="630" alt="channels tool" src="https://github.com/fallahi-sichani-lab/4i-Protocols-Scripts/assets/169082290/2563c397-f580-4eb4-9a4a-267ad4efca29">

</p>

Use File > Save as > Tiff to save a copy of the composite. Using the channels tool and the crop tool, regions of interest and individual channels can be highlighted for inspection and figure generation.

## References
1. Muhlich, J.L., Chen, Y.-A., Yapp, C., Russell, D., Santagata, S., and Sorger, P.K. Stitching and registering highly multiplexed whole-slide images of tissues and tumors using ASHLAR.
1. Peng, T., Thorn, K., Schroeder, T., Wang, L., Theis, F.J., Marr, C., and Navab, N. (2017). A BaSiC tool for background and shading correction of optical microscopy images. Nat Commun 8, 14836. 10.1038/ncomms14836.
2. Schapiro, D., Sokolov, A., Yapp, C., Chen, Y.-A., Muhlich, J.L., Hess, J., Creason, A.L., Nirmal, A.J., Baker, G.J., Nariya, M.K., et al. (2022). MCMICRO: a scalable, modular image-processing pipeline for multiplexed tissue imaging. Nat Methods 19, 311–315. 10.1038/s41592-021-01308-y.

