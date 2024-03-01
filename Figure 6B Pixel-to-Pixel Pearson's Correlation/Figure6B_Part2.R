setwd("/Volumes/FallahiLab/Maize-Data/Operetta-CLS/Tissue4i/MCMICRO_Analysis/WholeTonsil/ashlar_mod/Tonsil1B/October_updated")

install.packages(c("corrplot","data.table","ggplot2"))
library(corrplot)
library(data.table)
library(ggplot2)

# ============================= 5x5 Pixel Mean Filter Script =================== #
R1to8_1B_5x5smoothed_data = fread("R1-R8_CD19CD3_wholeTonsil_Pixel_Intensities_5x5smoothed_OctUpdated.csv")
colnames(R1to8_1B_5x5smoothed_data) = c("R1 CD19","R2 CD3","R3 CD19","R4 CD3","R5 CD19","R6 CD3","R7 CD19","R8 CD3")

# calculating pearson correlation coefficient 
cor_1B_5x5smoothed_data = cor(R1to8_1B_5x5smoothed_data) 
#pdf(file = "/Volumes/FallahiLab/Maize-Data/Operetta-CLS/Tissue4i/MCMICRO_Analysis/WholeTonsil/ashlar_mod/Tonsil1B/October_updated/Tonsil1B_CD19CD3_5x5meansmoothed_correlogram_OctUpdated_v3.pdf", width = 8, height = 8)
#png(file = "/Volumes/FallahiLab/Maize-Data/Operetta-CLS/Tissue4i/MCMICRO_Analysis/WholeTonsil/ashlar_mod/Tonsil1B/October_updated/Tonsil1B_CD19CD3_5x5meansmoothed_correlogram_OctUpdated_v2.pdf", width = 8, height = 8, units = "in", res = 600)
setEPS()
postscript("Tonsil1B_CD19CD3_5x5meansmoothed_correlogram_OctUpdated_v3.eps")
corrplot(cor_1B_5x5smoothed_data, 
         type="upper", 
         tl.col = "black",  
         tl.srt = 45,  
         col.lim = c(0,1), 
         addCoef.col = "red", 
         method = "color")
dev.off()

