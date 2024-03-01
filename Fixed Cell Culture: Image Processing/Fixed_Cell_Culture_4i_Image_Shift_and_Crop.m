%% Align images and crop
% This script uses X and Y shifts from CellProfiler to align and crop
% images from all fluorescence channels. The X and Y shifts are stored in
% "Image.csv" file. 

% Date: 02/04/2024

clear; clc; close all;

% Import alignment information stored in Image.csv file 
project_path = "/Users/mb8rg/Desktop/Fixed_Cell_Culture_4i_image_analysis";
alignment_data_filepath = sprintf('%s/Alignment_results/Image.csv', project_path);
alignment_data = readtable(alignment_data_filepath, "ReadVariableNames",true);

% Determine the maximum X_shift and Y_shift
max_Xshift = max(max(abs([alignment_data.Align_Xshift_aligned_round_1; ...
    alignment_data.Align_Xshift_aligned_round_2; ...
    alignment_data.Align_Xshift_aligned_round_3])));

max_Yshift = max(max(abs([alignment_data.Align_Yshift_aligned_round_1; ...
    alignment_data.Align_Yshift_aligned_round_2; ...
    alignment_data.Align_Yshift_aligned_round_3])));

% The limits for cropping are determined based on the maximum X and Y
% shifts. If X and Y shifts are large, inspect original images to ensure
% that cell loss across imaging cycles was not significant. 
crop_limits = [max_Xshift max_Yshift 1080-max_Xshift, 1080-max_Yshift];


%% Shift and crop images 

% number of channels in each round
channels = [4 4 4];

% number of rounds
n_rounds = 3;

for well_id = 1:height(alignment_data)
    for round_id = 1:n_rounds
        
        % get Xshift and Yshift values for this round in this well
        variable_xshift = sprintf('Align_Xshift_aligned_round_%d', round_id);
        variable_yshift = sprintf('Align_Yshift_aligned_round_%d', round_id);
        Xshift = -1*alignment_data.(variable_xshift)(well_id);
        Yshift = -1*alignment_data.(variable_yshift)(well_id);

        % obtain metadata
        row_id = alignment_data.Metadata_Row(well_id);
        col_id = alignment_data.Metadata_Column(well_id);
        site_id = alignment_data.Metadata_Site(well_id);

        for channel_id = 1:channels(round_id)

            % determine filepath and name using the image metadata
            filepath = sprintf('%s/Sample_background_subtracted_images/Round%d/r%02dc%02df%02dp01-ch%dsk1fk1fl1.tiff', ...
                project_path, round_id, row_id, col_id, site_id, channel_id);

            % read in the background subtracted image
            bg_sub_image = imread(filepath);

            % shift the image by [Xshift, Yshift]            
            translated_image = imtranslate(bg_sub_image,[Xshift, Yshift]); 

            % crop the shifted image
            cropped_image = imcrop(translated_image, crop_limits);

            % save the sifted and cropped image in an output folder named
            % "Aligned_Images
            fileout = sprintf('%s/Aligned_Images/r%02dc%02df%02d_round%d-ch%dsk1fk1fl1.tiff', ...
                project_path, row_id, col_id, site_id, round_id, channel_id);
            imwrite(cropped_image, fileout)

        end
    end
end







































