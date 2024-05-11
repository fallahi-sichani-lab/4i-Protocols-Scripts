# Tissue-4i-Image-Processing-Workflow

This vignette provides step-by-step processing and visualizing instructions for Iterative Indirect Immunofluorescence Imaging (4i) data for formalin-fixed paraffin embedded tissue sections obtained following the tissue-4i protocol from:

In this protocol, we utilized the Revity Operetta CLS High-Content analysis system to generate whole slide images of multiplexed protein localization on tissue. The Operetta consecutively images up to four slides at once and deposits those raw images into the same output folder. Thus, in this workflow, we have ASHLAR utilize the Index.idx.xml metadata to determine which TIFF files are attributed to each slide. ASHLAR then runs stitching and registration for all four slides consecutively to create four outputs. However, we are showing one slide for this vignette.

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

In this vignette, we demonstrate the workflow we used to visualize the data in Figure 4. For a tutorial, we provided three folders of raw images from Operetta imaging that can be found (INSERT LINK)
* Postquench images taken after autofluorescence quenching, for the purpose of subtraction in later rounds
* Round 1 images where we immunostained for differentiation state markers NGFR (AF488), SOX10 (AF568), and MITF (AF647)
* Round 2 images where we immunostained for a pan-immune cell marker (CD45) and T-cell marker (CD3).

We also include the markers.csv and params.yml files required to run MCMICRO. 

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

After running BaSiC on each Operatta output folder, the Operetta output folders should have a new subfolder named "basic" containing dark field and flat field profiles for that round of imaging.
<p align="center">
<img width="694" alt="ffp_dfp_generation" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/485914a3-b388-4cad-af64-dc8a59ca9fa2">
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
ASHLAR input for Operetta images required one Index.idx.xml files for each round.. To correct illumination artifacts using the BaSiC-generated flat field and dark field profiles, the ffp.tif and dfp.tif files are inputted under the -ffp and -dfp flags in the same order as the Index files.
We generate arrays containing the necessary inputs by find the files within our current project directory and sorting them
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

<img width="810" alt="ashlar_output" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/4fb34348-ea2c-4e8a-830a-d85e31a6f113">
</p>

The registration folder will populate with a "Postquench" folder containing the stitched and registered tissue images. Move the stitched image out of the subfolder, to be directly in /registration/

<p align="center">
<img width="687" alt="registered_image_generation" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/31f4be08-b365-471b-abfe-bbe27ae2156c">
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
* a stitched and registed .ome.tif file (ASHLAR output) within the registration folder.
<p align="center">
<img width="690" alt="background_subtraction_run" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/e0a300b3-57da-4093-9fab-d4bc4e9fdfb1">
</p>

```bash
nextflow run labsyspharm/mcmicro --in $PROJECT_DIR --params params.yml
```

The project directory will populate with work, qc, and background directories. The background directory contains the new ome.tif fill with Postquench channels completely removed, and remaining autofluorescence comptuationally subtracted from the channels as indicated in markers.csv. The new markers_bs.csv will indicate the new channels order in the .ome.tiff file
<p align="center">
<img width="485" alt="bgsub_generation" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/adcd5a43-b5be-4841-8eef-7c7ae57563db">

## Visualization and quality control on ImageJ

To quickly visualize the background-subtracted, stitched and registered whole-tissue representation of the 4i experiment, open the ome.tiff file on ImageJ. ImageJ will display the BioFormats imports options. Check "Split Channels" to have each channel open separately.

<p align="center">
<img width="603" alt="bioformats" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/4bcb80b9-0508-41a2-ae0a-0f368ac8056e">
</p>

Choose a resolution to open the images. 

<p align="center">
<img width="452" alt="resolution" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/5fcf9a67-eef9-4fe7-a367-836a8625f1e2">
</p>

Select Window > Tile to see each channel at once. 

<p align="center">
<img width="2218" alt="Screenshot 2024-05-05 at 6 20 31 PM" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/4ab20341-8b01-4a00-994c-91bcdd38e014">
</p>

Each channel will have varying intensity ranges. The individual channels will likely be very dark and hard to visualize. Click on each channel image and implement auto-contrast by selecting Image > Adjust > Brightness/Contrast and applying autocontrast

<p align="center">
<img width="2219" alt="autocontrast" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/4e446c06-2829-405c-96e2-988fb976491d">
</p>

### ASHLAR quality control

To confirm that nuclei from each round of imaging were successfully stitched registered using ASHLAR, overlay the hoechst stain channels from Postquench, Round 1, and Round 2 in different colors using Image > Color > Merge Channels. 
<p align="center">
<img width="584" alt="mergehoechst" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/50b90a7d-be73-4a23-9c59-ba3366a3d35b">
</p>
A new composite image will generate overlaying the three nuclei channels. Here, the Postquench Hoechst (C=0) is green, Round 1 Hoechst (C=0) is gray, and Round 2 Hoechst (C=5) is cyan.  
<p align="center">
<img width="400" alt="mergehoechst2" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/80286b13-3184-402d-87b2-b6d600ac853e">
</p>
Zoom in using the magnifying glass tool and inspect several field of view in areas of varying cell density and at the edges if the tissue. Confirm that nuclei are overlaid correctly at a single cell resolution, ie. there are no noticeable "shadows" of shifted nuclei. Loss of nuclei through mechanical damage, especially at the edges of the tissue, is expected over time. 
<p align="center">
<img width="400" alt="fov1" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/64c6ea2d-368d-4e26-96f7-5c969b64adac"><img width="400" alt="fov2" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/bfd0622d-e52b-4760-a72a-fd9f9c062913">
</p>

After confirming proper stitching and registration, save the Postquench Hoechst as the representative nuclei stain (File > Save as > Tiff)

### Rolling-ball background subtraction

ImageJ's built in rolling-ball background subtraction helps to remove uneven background across the slide from the protein stains for figure-quality images. For quick visualization, this step can be skipped and Image > Color > Merge Channels can be used with images as-is. 

To perform rolling-ball background subtraction on all protein stains at once, close all channels such that only the protein stains are remaining. Here, we stained for NGFR, SOX10, MITF, CD45, and CD3.

Select Images > Stack > Images to Stack 
<p align="center">
<img width="1323" alt="proteinstack" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/2d4de256-23ea-4cda-9e74-fc1f6c4e2639">
</p>
Click on the stack. Select Process > Subtract Background... Set radius to 5px.

ImageJ will run rolling-ball background subtraction on each image in the stack.
<p align="center">
<img width="282" alt="subtractbg" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/f88313e0-ec17-4449-8deb-6dc7493226a1">
<img width="281" alt="rollingball_stack" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/7b49ef1e-7ea9-4665-94b3-b42ec99f7233">
</p>
After rolling ball background subtraction is completed, the images should have increased signal-to-noise ratio. Save each channel in the stack by selecting File > Save As > Image Sequence...
<p align="center">
<img width="442" alt="Save as image sequence " src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/a0062c86-1d0e-42d8-97d8-5f5e2d2da2b3">
</p>

## Multiplexed image generation

Rename the tif files of individual channels accordingly. markers_bs.csv can be used as a reference. 
<p align="center">
<img width="290" alt="Files" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/992bfc4d-b57c-4e09-a9e1-5ceaef300d27">
 
<img width="182" alt="files renamed" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/fa34d201-7fad-4e27-b2a5-a3f07e6d75bd">
</p>
Drag the files to ImageJ to open the images of each channel. After illumination correction, stitching, registration, and two forms of background subtraction, these baseline images are ready for cropping and contrast enhancements for figure generation.

To quickly visualize the merged, multiplexed image, auto-contrast the individual channels (Image > Adjust > Brightness/Contrast). Select Image > Color > Merge Channels 
<p align="center">
<img width="1175" alt="merge_multiplex" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/842d71f0-76ac-4d76-bd33-0d597d4d3de2">
</p>

The final composite image should show the 5 proteins markers, NGFR, SOX10, MITF, CD45 and CD3 overlaid on nuclei. To isolate one or more channels for visualization, use the Channels Tool under Image > Color > Channels Tool...
<p align="center">
<img width="630" alt="channels tool" src="https://github.com/kimnguyen72/Tissue-4i-Image-Processing-Workflow/assets/169082290/eca1d890-8236-44fd-a6f1-39a37fb1decf">
</p>

Use File > Save as > Tiff to save a copy of the composite. Using the channels tool and the crop tool, regions of interest and individual channels can be highlighted for inspection and figure generation.

## References
1. Muhlich, J.L., Chen, Y.-A., Yapp, C., Russell, D., Santagata, S., and Sorger, P.K. Stitching and registering highly multiplexed whole-slide images of tissues and tumors using ASHLAR.
1. Peng, T., Thorn, K., Schroeder, T., Wang, L., Theis, F.J., Marr, C., and Navab, N. (2017). A BaSiC tool for background and shading correction of optical microscopy images. Nat Commun 8, 14836. 10.1038/ncomms14836.
2. Schapiro, D., Sokolov, A., Yapp, C., Chen, Y.-A., Muhlich, J.L., Hess, J., Creason, A.L., Nirmal, A.J., Baker, G.J., Nariya, M.K., et al. (2022). MCMICRO: a scalable, modular image-processing pipeline for multiplexed tissue imaging. Nat Methods 19, 311–315. 10.1038/s41592-021-01308-y.

