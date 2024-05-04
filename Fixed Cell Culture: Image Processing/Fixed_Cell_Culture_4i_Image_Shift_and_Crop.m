%% Shift and Crop Images
% This script uses X and Y shifts from CellProfiler to align and crop
% images from all fluorescence channels. The X and Y shifts are stored in
% "Image.csv" file. 

% Date: 02/04/2024
% Updated: 05/02/2024
clear; clc; close all;

% Change the following variables:
project_path = "/Users/mb8rg/Desktop/Fixed_Cell_Culture_Image_Processing";
output_path = "/Users/mb8rg/Desktop/Fixed_Cell_Culture_Image_Processing/Aligned_Images"; 
number_of_rounds = 3;
original_image_size = [1080, 1080]; % in pixels
channels = [4 4 4]; % number of channels in each round

%% Import alignment information and determine crop limits

% Import alignment information stored in Image.csv file 
alignment_data_filepath = sprintf('%s/Alignment_results/Image.csv', project_path);
alignment_data = readtable(alignment_data_filepath, "ReadVariableNames",true);

% Determine how much to crop the images based on the maximum and minimum X and Y
% shifts. If X and Y shifts are large, inspect original images to ensure
% that cell loss across imaging cycles was not significant. 
min_Xshift = abs(min(min(alignment_data{:,1:number_of_rounds})));
max_Xshift = abs(max(max(alignment_data{:,1:number_of_rounds})));
min_Yshift = abs(min(min(alignment_data{:,number_of_rounds+1:2*number_of_rounds})));
max_Yshift = abs(max(max(alignment_data{:,number_of_rounds+1:2*number_of_rounds})));
crop_limits = [min_Xshift, min_Yshift, original_image_size(1)-max_Xshift, original_image_size(2)-max_Yshift];

%% Shift and crop images 

for well_id = 1:height(alignment_data)
    for round_id = 1:number_of_rounds
        
        % get Xshift and Yshift values for this round in this well
        variable_xshift = sprintf('Align_Xshift_Aligned_Round_%d', round_id);
        variable_yshift = sprintf('Align_Yshift_Aligned_Round_%d', round_id);
        Xshift = -1*alignment_data.(variable_xshift)(well_id);
        Yshift = -1*alignment_data.(variable_yshift)(well_id);
        % obtain metadata
        row_id = alignment_data.Metadata_Row(well_id);
        col_id = alignment_data.Metadata_Column(well_id);
        site_id = alignment_data.Metadata_Site(well_id);

        for channel_id = 1:channels(round_id)

            % determine filepath and name using the image metadata
            filepath = sprintf('%s/Background_Subtracted_Images/Round_%d/r%02dc%02df%02dp01-ch%dsk1fk1fl1.tiff', ...
                project_path, round_id, row_id, col_id, site_id, channel_id);

            % read in the background subtracted image
            bg_sub_image = imread(filepath);

            % shift the image by [Xshift, Yshift]            
            translated_image = imtranslate(bg_sub_image,[Xshift, Yshift]); 

            % crop the shifted image
            cropped_image = imcrop(translated_image, crop_limits);

            % save the sifted and cropped image in an output folder named
            % "Aligned_Images
            fileout = sprintf('%s/r%02dc%02df%02d_round%d-ch%dsk1fk1fl1.tiff', ...
                output_path, row_id, col_id, site_id, round_id, channel_id);
            imwrite(cropped_image, fileout)

        end
    end
end







































