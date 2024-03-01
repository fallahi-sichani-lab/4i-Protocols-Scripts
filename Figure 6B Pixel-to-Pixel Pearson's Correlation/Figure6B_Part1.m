% Reading 20230810_Tonsil1b_BgSub_1-8 Image Stack 
reg_im_vol = tiffreadVolume("/Volumes/FallahiLab/Maize-Data/Operetta-CLS/Tissue4i/MCMICRO_Analysis/WholeTonsil/ashlar_mod/Tonsil1B/October_updated/WholeTonsil_BgSub.tif");

% Creating a csv file of pixel intensities after mean 5x5 pixel smoothing
% 18583*14548 (27034484) pixels per tiff slice; 8 slices of interest
Bigdatamatrix_smooth_5x5 = zeros(270345484,8); 
smooth_param = fspecial("average", [5 5]); % creating a 5x5 mean kernel 
for i = 2:9 
    image_stack = reg_im_vol(:,:,i); % reading the pixel intensities of an image stack 
    image_stack_smooth = imfilter(image_stack, smooth_param); % smooths image with a 5x5 mean pixel filter
    [image_stack_smooth_reshape] = reshape(image_stack_smooth,[],1); % reshape matrix intensity to column vector 
    Bigdatamatrix_smooth_5x5(:,i-1) = image_stack_smooth_reshape; 
end
writematrix(Bigdatamatrix_smooth_5x5, "R1-R8_CD19CD3_wholeTonsil_Pixel_Intensities_5x5smoothed_OctUpdated.csv");
