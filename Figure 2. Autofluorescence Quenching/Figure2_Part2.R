setwd("/Volumes/FallahiLab/Maize-Data/Operetta-CLS/Tissue4i/MCMICRO_Analysis/AFQuench_3samples_Updated/AFQuench_3samples_Pixel_Analysis_Matlab_R")
install.packages(c("data.table","dplyr","tidyr","ggplot2"))
library(data.table)
library(dplyr)
library(tidyr)
library(ggplot2)

Mel1_data = fread("Mel1_AFQuench.csv")
colnames(Mel1_data)=c("Pre-Quench","Post-Quench","CD45","CD45 BG Sub")
set.seed(001)
Mel1_data_subsamp = Mel1_data %>% slice_sample(n = round(0.50*dim(Mel1_data))[1], replace=FALSE) 
Mel1_data_subsamp_pivot = Mel1_data_subsamp %>% pivot_longer(cols=c("Pre-Quench", "Post-Quench", "CD45", "CD45 BG Sub"), 
                            values_to = "Pixel_Intensity", 
                            names_to = "Round")

BRC_data = fread("BRC_AFQuench.csv")
colnames(BRC_data)=c("Pre-Quench","Post-Quench","CD45","CD45 BG Sub")
set.seed(101)
BRC_data_subsamp = BRC_data %>% slice_sample(n=round(0.50*dim(BRC_data))[1], replace=FALSE)
BRC_data_subsamp_pivot = BRC_data_subsamp %>% pivot_longer(cols=c("Pre-Quench", "Post-Quench", "CD45", "CD45 BG Sub"), 
                                                             values_to = "Pixel_Intensity", 
                                                             names_to = "Round")

Tonsil1_data = fread("Tonsil1_AFQuench.csv")
colnames(Tonsil1_data)=c("Pre-Quench","Post-Quench","CD45","CD45 BG Sub")
set.seed(201)
Tonsil1_data_subsamp = Tonsil1_data %>% slice_sample(n=round(0.50*dim(Tonsil1_data))[1], replace=FALSE)
Tonsil1_data_subsamp_pivot = Tonsil1_data_subsamp %>% pivot_longer(cols=c("Pre-Quench", "Post-Quench", "CD45", "CD45 BG Sub"), 
                                                             values_to = "Pixel_Intensity", 
                                                             names_to = "Round")

# Tonsil1 Density Plot ============================================================#
Tonsil1_data_subsamp_pivot$Round = factor(Tonsil1_data_subsamp_pivot$Round, levels = c("Pre-Quench", "Post-Quench", "CD45", "CD45 BG Sub"))
ggplot(Tonsil1_data_subsamp_pivot, aes(x = log10(Pixel_Intensity+1), 
                                       fill = Round)) + 
  geom_density(alpha = 0.7, aes(y = after_stat(count / sum(count)))) +
  labs(x = "log10(Pixel Intensity+1)", 
       y = "Density", 
       fill = "Round",
       title = "Tonsil") + 
  facet_grid(rows = vars(Round)) +
  theme(text = element_text(size = 9, color = "black", face = "bold"), 
        axis.text.x = element_text(size = 8, color = "black", face = "plain"),
        axis.text.y = element_text(size = 8, color = "black", face = "plain"), 
        plot.title = element_text(hjust = 0.5),
        plot.margin = margin(10, 1, 10, 1),
        aspect.ratio = 1, 
        axis.ticks = element_line(color = "black"), 
        panel.background = element_blank(), 
        axis.line = element_line(colour = "black"),
        legend.position="none")+
  scale_fill_manual(values=
                      c("Pre-Quench"="#E69F00",
                        "Post-Quench"="#3DB7E9",
                        "CD45"="#359B73",
                        "CD45 BG Sub"="#F748A5"))+
  scale_x_continuous(limits = c(-0.02,5), expand = c(0,0), breaks = seq(0,5,by=1)) +
  scale_y_continuous(limits = c(-0.000,0.030), expand = c(0,0), breaks = seq(0,0.025,by=0.005))
ggsave("Tonsil_AFQuench_v5.svg", width = 2, height = 5, units = "in", dpi = 600)
#dev.off()

# Mel1 Density Plot ============================================================#
load("/Volumes/FallahiLab/Maize-Data/Operetta-CLS/Tissue4i/MCMICRO_Analysis/AFQuench_3samples_Updated/AFQuench_3samples_Pixel_Analysis_Matlab_R/Mel1_data_objects_50.RData")
Mel1_data_subsamp_pivot$Round = factor(Mel1_data_subsamp_pivot$Round, levels = c("Pre-Quench", "Post-Quench", "CD45", "CD45 BG Sub"))
ggplot(Mel1_data_subsamp_pivot, aes(x = log10(Pixel_Intensity+1), 
                                    fill = Round))+ 
  geom_density(alpha = 0.7, aes(y = after_stat(count / sum(count))))+
  labs(x = "log10(Pixel Intensity+1)", 
       y = "Density", 
       fill = "Round",
       title = "Melanoma")+ 
  facet_grid(rows = vars(Round))+
  theme(text = element_text(size = 9, color = "black", face = "bold"), 
        axis.text.x = element_text(size = 8, color = "black", face = "plain"),
        axis.text.y = element_text(size = 8, color = "black", face = "plain"), 
        plot.title = element_text(hjust = 0.5),
        plot.margin = margin(10, 1, 10, 1),
        aspect.ratio = 1, 
        axis.ticks = element_line(color = "black"), 
        panel.background = element_blank(), 
        axis.line = element_line(colour = "black"),
        legend.position="none")+
  scale_fill_manual(values=
                       c("Pre-Quench"="#E69F00",
                         "Post-Quench"="#3DB7E9",
                         "CD45"="#359B73",
                         "CD45 BG Sub"="#F748A5"))+
  scale_x_continuous(limits = c(-0.02,5), expand = c(0,0), breaks = seq(0,5,by=1)) +
  scale_y_continuous(limits = c(-0.000,0.030), expand = c(0,0), breaks = seq(0,0.025,by=0.005))
ggsave("Mel_AFQuench_v3.svg", width = 2, height = 5, units = "in", dpi = 600)

# BRC Density Plot ============================================================#
BRC_data_subsamp_pivot$Round = factor(BRC_data_subsamp_pivot$Round, levels = c("Pre-Quench", "Post-Quench", "CD45", "CD45 BG Sub"))
BRC_plot = ggplot(BRC_data_subsamp_pivot, aes(x = log10(Pixel_Intensity+1), 
                                    fill = Round)) + 
  geom_density(alpha = 0.7, aes(y = after_stat(count / sum(count)))) +
  labs(x = "log10(Pixel Intensity+1)", 
       y = "Density", 
       fill = "Round",
       title = "Breast Carcinoma") + 
  facet_grid(rows = vars(Round)) + 
  theme(text = element_text(size = 9, color = "black", face = "bold"), 
        axis.text.x = element_text(size = 8, color = "black", face = "plain"),
        axis.text.y = element_text(size = 8, color = "black", face = "plain"), 
        plot.title = element_text(hjust = 0.5),
        plot.margin = margin(10, 1, 10, 1),
        aspect.ratio = 1, 
        axis.ticks = element_line(color = "black"), 
        panel.background = element_blank(), 
        axis.line = element_line(colour = "black"),
        legend.position="none")+
  scale_fill_manual(values=
                      c("Pre-Quench"="#E69F00",
                        "Post-Quench"="#3DB7E9",
                        "CD45"="#359B73",
                        "CD45 BG Sub"="#F748A5"))+
  scale_x_continuous(limits = c(-0.02,5), expand = c(0,0), breaks = seq(0,5,by=1)) +
  scale_y_continuous(limits = c(-0.000,0.030), expand = c(0,0), breaks = seq(0,0.025,by=0.005))
ggsave("BRC_AFQuench_v3.svg", width = 4, height = 5, units = "in", dpi = 600)













