

######Workflow for BaSIC illumination correction -> ASHLAR registration -> MCMICRO background subtraction on Operetta images using the command line
######Requires prior installation of BaSIC, ASHLAR, and Nextflow 
######Iterates through ALL rounds
######Image measurement folders should be in the format of PostQuench, Round1_, Round2_ and so on. If not, edit folder names to represent rounds. ASHLAR works on Operetta Index files as input.
######imagej_basic_ashlar.py (found on github), markers.csv, and params.yml should be downloaded into the project directory

#set project directory as the main folder containing all operetta outputs 
PROJECT_DIR="<path>"

#Load required environments. Ashlar conda environment should already be installed, only need to activate it

conda activate ashlar #conda python environment required for ashlar. 

#####Running BASiC illumination correction
#iterate across each round folder and do basic illumination correction. Deposits dark field and flat field correction profiles in /basic directory.
cd $PROJECT_DIR
for DIR in *
    do
        experiment_name=${DIR%__*} #use regex that identifies all folders containing images. Operetta output uses "__"
        mkdir -p $DIR/basic 
        ImageJ-linux64 --ij2 --headless --run imagej_basic_ashlar.py "filename='"$DIR"/Images/Index.idx.xml',output_dir='"$DIR"/basic/',experiment_name='$experiment_name'"
          
    done

#####Running ASHLAR for stitching and registration
#Prep for ashlar. Arrays include each round's Index, ffp, and dfp folders are sorted in numerical order. To sort correctly, it is important to have Round1,Round2... in name
mkdir -p registration
index_files_array=$(find -name "Index.idx.xml" | sort -n)
ffp_files_array=$(find -name "*ffp.tif" | sort -n)
dfp_files_array=$(find -name "*dfp.tif" | sort -n)

#check to make sure rounds show the correct quantity in the correct order 
echo $index_files_array 
echo $ffp_files_array 
echo $dfp_files_array 

#run ashlar with raw image tiles, flat field profiles and dark field profiles as input. Name output file in <name>
#operetta images require the --plates and --flip-y format. Will vary with microscope
ashlar $index_files_array --plates --flip-y -o ./registration/<name>.ome.tif --ffp $ffp_files_array --dfp $dfp_files_array 

###Running background subtraction with MCMICRO
#remember to edit markers.csv file to reflect cycles. See https://mcmicro.org/parameters/core.html#backsub
#params.yml file has to reflect background subtraction step only
nextflow run labsyspharm/mcmicro --in $PROJECT_DIR --params params.yml
