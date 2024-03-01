% Extracting BRC Autofluorescence Quenching data 
%==========================================================================%
tic
BRC_im_vol = tiffreadVolume("/Volumes/Maize-Data/Operetta-CLS/Tissue4i/MCMICRO_Analysis/AFQuench_3samples_Updated/AFQuench_3samples_Pixel_Analysis_Matlab_R/KN_A03_BRC_AFQuench_noBGsub.tif");
BRC_BGSub_im_vol = tiffreadVolume("/Volumes/Maize-Data/Operetta-CLS/Tissue4i/MCMICRO_Analysis/AFQuench_3samples_Updated/AFQuench_3samples_Pixel_Analysis_Matlab_R/KN_BRC_backsub_7only.tif");
BRC_im_vol_2610 = BRC_im_vol(:,:,[2 6 10]);
BRC_BGSub_im_vol_7 = BRC_BGSub_im_vol(:,:,7);

BRC_all = cat(3, BRC_im_vol_2610, BRC_BGSub_im_vol_7); % concatenate at the 3rd dimension 
%size(BRC_all,1)*size(BRC_all,2)
BRC_all_col_datamatrix = reshape(BRC_all,[],4);
toc
writematrix(BRC_all_col_datamatrix, "BRC_AFQuench.csv");
toc

% Extracting Mel1 Autofluorescence Quenching data 
%==========================================================================%
tic
Mel1_im_vol = tiffreadVolume("/Volumes/Maize-Data/Operetta-CLS/Tissue4i/MCMICRO_Analysis/AFQuench_3samples_Updated/AFQuench_3samples_Pixel_Analysis_Matlab_R/KN_A02_Mel1_AFQuench_noBGsub.tif");
toc
Mel1_BGSub_im_vol = tiffreadVolume("/Volumes/Maize-Data/Operetta-CLS/Tissue4i/MCMICRO_Analysis/AFQuench_3samples_Updated/AFQuench_3samples_Pixel_Analysis_Matlab_R/KN_Mel1_backsub_7only.tif");
toc

Mel1_im_vol_2610 = Mel1_im_vol(:,:,[2 6 10]);
Mel1_BGSub_im_vol_7 = Mel1_BGSub_im_vol(:,:,7);

Mel1_all = cat(3, Mel1_im_vol_2610, Mel1_BGSub_im_vol_7); % concatenate at the 3rd dimension 
%size(Mel1_all,1)*size(Mel1_all,2)
Mel1_all_col_datamatrix = reshape(Mel1_all,[],4);
writematrix(Mel1_all_col_datamatrix, "Mel1_AFQuench.csv");


% Extracting Tonsil1 Autofluorescence Quenching data
%==========================================================================%
tic
Tonsil1_im_vol = tiffreadVolume("/Volumes/Maize-Data/Operetta-CLS/Tissue4i/MCMICRO_Analysis/AFQuench_3samples_Updated/AFQuench_3samples_Pixel_Analysis_Matlab_R/KN_A01_Tonsil1_AFQuench_noBGsub.tif");
Tonsil1_BGSub_im_vol = tiffreadVolume("/Volumes/Maize-Data/Operetta-CLS/Tissue4i/MCMICRO_Analysis/AFQuench_3samples_Updated/AFQuench_3samples_Pixel_Analysis_Matlab_R/KN_Tonsil1_backsub_7only.tif");

Tonsil1_im_vol_2610 = Tonsil1_im_vol(:,:,[2 6 10]);
Tonsil1_BGSub_im_vol_7 = Tonsil1_BGSub_im_vol(:,:,7);

Tonsil1_all = cat(3, Tonsil1_im_vol_2610, Tonsil1_BGSub_im_vol_7); % concatenate at the 3rd dimension 
%size(Tonsil1_all,1)*size(Tonsil1_all,2)
Tonsil1_all_col_datamatrix = reshape(Tonsil1_all,[],4);
toc
writematrix(Tonsil1_all_col_datamatrix, "Tonsil1_AFQuench.csv");
toc
