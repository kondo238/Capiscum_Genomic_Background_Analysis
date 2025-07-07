################################################NOTE############################################################################################################################################
#This is the R script to draw figures regarding population structures for the unknown samples (six lines of Dalle Khursani, and additional six accessions each from C. annuum complex species) in each catalog group (group1:C.a&C.c-common, group2:C.a&C.f-common, group3:C.c&C.f-common, group4:Three species-common).
#The dataset for ancestral population-belonging proportion was prepared by copying and pasting the directory 'Admixture_dataset' (after admixture analysis: see Step 2) to the Dataset directory (./Dataset)
#Finally, the barplot exhibiting population-belonging proportion will be obtained in the output directory (./Output), which will automatically be created.
################################################################################################################################################################################################

# Necessary libraries in this analysis
library(ggplot2)
library(tidyverse)

####################################Directory_Setting_&_loading_data_necessary_for_whole_process############################################
setwd(getwd()) #Setting working directory
unlink("./Output", recursive = TRUE) #If there is old output directory, it will be removed
dir.create("./Output") #Create_directory_to_save_output_data

#Loading_Sample_ID_list
sample_ID_list <- as.data.frame(read.csv("./Dataset/sample_id.csv"))

#Define_unknown_samples_list
unknown_samples <- c("annuum_test", "chinense_test", "frutescens_test", "dalle")  #For_unknown_samples

#Prepare_data_frame_containing_information_of_Catalog_group
Catalog_group_info <- data.frame(Group=c("group1", "group2", "group3", "group4"),
                                 FistSpecies=c("annuum", "annuum", "chinense", "annuum"),
                                 SecondSpecies=c("chinense", "frutescens", "frutescens", "chinense"),
                                 ThirdSpecies=c("None", "None", "None", "frutescens"))

#Loading_data_frame_to_indicate_order_and_color_samples_for_Admixture_figuration.
order_and_color_for_figration <- as.data.frame(read.csv("./Dataset/Group_order.csv"))


#################################Loading_each_Admixture_analysis_data_and_Drawing_Figure###########################
###Loop_for_each_unknown_samples
for(g in 1:length(unknown_samples)){
###Preapre_outpute_directory_for_each_unknown_samples
dir.create(paste("./Output/",
                   unknown_samples[g],
                   sep = ""))

###Loop_for_each_catalog_group
for(h in 1:nrow(Catalog_group_info)){
###Preapre_outpute_directory_for_each_catalog_group
  dir.create(paste("./Output/",
                   unknown_samples[g],
                   "/",
                   Catalog_group_info[h,1],
                   sep = ""))
if(h!=4){ #In case that catalog group is not "group 4" (in case "group1", "group2", and "group3")
###Extract_Sample_information_related_to_this_catalog_group
Related_sampleID <- sample_ID_list[sample_ID_list$Group == Catalog_group_info[h,2] |
                                   sample_ID_list$Group == Catalog_group_info[h,3] |
                                   sample_ID_list$Group == unknown_samples[g],]

###Define_total_number_of_ancestral_population (K): K=2  
Total_K <- 2

####Prepare_the_data_frame_to_save_the_ancestral_population-deriving_proportion
df <- as.data.frame(matrix(0,
                           ncol = 3 + Total_K,
                           nrow = length(Related_sampleID$Rad.tag)*Total_K))
colnames(df) <- c("K", "Group", "Accession", paste(rep("K", Total_K), 1:Total_K, sep = ""))

a <- vector()
for(i in 1:Total_K){
  b <- as.character(rep(i, length(Related_sampleID$Rad.tag)))
  a <- c(a, b)
}
rm(i)
df[,1] <- a
df[,2] <- rep(Related_sampleID$Group, Total_K)
df[,3] <- rep(Related_sampleID$Rad.tag, Total_K)
rm(a, b)


####Loading_data_of_ancestral_population-deriving_proportion_for_each_K_&_save_them_to_data_frame("df")
#Define_common_path_to_load_data
path <- paste("./Dataset/Admixture_dataset/",
              unknown_samples[g],
              "/",
              Catalog_group_info[h,1],
              "/",
              "result",
              sep = "")

#Confirm_wheter_the_loading_dataset_exist_or_not
if(file.exists(paste(path, #If_the_dataset_doesn't_exist,_further_task_will_not_be_performed.
                     "/dataset.1.Q",
                     sep = "")) == FALSE){
}else{ #If_the_dataset_exist,_further_task_will_be_performed.


for(i in 1:Total_K){
  #Load_data
  filename <- paste(path, "/dataset.", i, ".Q", sep = "")
  f <- read.delim(filename, header = F, sep = "")
  
  i_st <- 1 + (i - 1)*length(Related_sampleID$Rad.tag)
  i_end <- i*length(Related_sampleID$Rad.tag)
  df[i_st:i_end,(4:(4+i-1))] <- f[,1:i]
}



for(i in 1:Total_K){
  df[,(3+i)] <- as.numeric(df[,(3+i)])
}

rm(f, i, i_end, i_st, path, filename)


###Adjustment_of_data_frame("df")_for_drawing_figure_using_ggplot
i <- Total_K  
  df2 <- df[df$K == as.character(i),]
  
  vec <- vector()
  for(j in 1:i){
    a <- as.numeric(df2[,(3+j)])
    vec <- c(vec, a)
  }
  
  k <- vector()
  for(x in 1:i){
    a <- rep(x, length(Related_sampleID$Rad.tag))
    k <- c(k, a)
  }
  
  df3 <- as.data.frame(cbind(k,
               rep(df2$Group, i),
               rep(df2$Accession, i),
               vec))
  colnames(df3) <- c("K", "Group", "Accession", "Value")
  df3[,4] <- as.numeric(df3[,4])
  
#Change_the_order_of_samples_based_on_the_dataset("order_and_color_for_figuration")
  no <- vector()
  Cataloggroup_order <- order_and_color_for_figration[order_and_color_for_figration$UnknownSamples == unknown_samples[g] &
                                                        order_and_color_for_figration$CataloGroup == Catalog_group_info[h,1],c(3,4,5)]
  for(n in 1:ncol(Cataloggroup_order)){
    a <- which(Related_sampleID$Group == Cataloggroup_order[1,n])
    no <- c(no, a)
  }
   
df5 <- df3[0,]
for(l in 1:i){
  df4 <- df3[df3$K == l,]
  rownames(df4) <- df4$Accession
  df4 <- df4[no,]
  df4[,3] <- as.character(101:(100+nrow(df4)))
  df5 <- rbind(df5, df4)
}

df <- df5 #The_finale_adjusted_dataframe

rm(df2, df3, df4, df5, Related_sampleID, a, i, j, k, l, n, x, vec, no)


###Draw_barplot_exhibiting_ancestral_population-deriving_proportion_using_ggplot
###Draw_figure_without_sample_name_and_save
x <- ggplot(df, aes(x = Accession, y = Value, fill=K)) +
  geom_bar(stat="identity", width = 1.0, colour = "black", size = 0.5) +
  theme(axis.ticks = element_blank(),  
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.line = element_blank(),
        legend.position = "none")
   rm(fill_colors, color)

#Note:Position_of_each_barplot_from_left_side_is_consistent_with_sample_name_in_the_data_frame("df")

ggsave(file = paste("./Output/",
                 unknown_samples[g],
                 "/",
                 Catalog_group_info[h,1],
                 "/Admixture_for_K=",
                 as.character(Total_K),
                 ".png",
                 sep = ""),
       height = 0.7, width = 1.2, plot = x, dpi = 700)

#Save_raw_data_of_ancestral_population-deriving_proportion_which_wre_used_for_the_drawing_figure
df <- data.frame(RAD_tag=rownames(df), df)
write.csv(df, paste("./Output/",
                     unknown_samples[g],
                     "/",
                     Catalog_group_info[h,1],
                     "/K=",
                     as.character(Total_K),
                     "_poplation-deriving_proportion_data.csv",
                     sep = ""),
          row.names = F)
}

}else{ #In_case_that_Catalog_group_is_group4
  
  ###Extract_Sample_information_related_to_this_catalog_group
  Related_sampleID <- sample_ID_list[sample_ID_list$Group == Catalog_group_info[h,2] |
                                       sample_ID_list$Group == Catalog_group_info[h,3] |
                                       sample_ID_list$Group == Catalog_group_info[h,4] |
                                       sample_ID_list$Group == unknown_samples[g],]
  
  ###Define_total_number_of_ancestral_population (K): K=3 (for group 4)  
  Total_K <- 3
  
  ####Prepare_the_data_frame_to_save_the_ancestral_population-deriving_proportion
  df <- as.data.frame(matrix(0,
                             ncol = 3 + Total_K,
                             nrow = length(Related_sampleID$Rad.tag)*Total_K))
  colnames(df) <- c("K", "Group", "Accession", paste(rep("K", Total_K), 1:Total_K, sep = ""))
  
  a <- vector()
  for(i in 1:Total_K){
    b <- as.character(rep(i, length(Related_sampleID$Rad.tag)))
    a <- c(a, b)
  }
  rm(i)
  df[,1] <- a
  df[,2] <- rep(Related_sampleID$Group, Total_K)
  df[,3] <- rep(Related_sampleID$Rad.tag, Total_K)
  rm(a, b)
  
  
  ####Loading_data_of_ancestral_population-deriving_proportion_for_each_K_&_save_them_to_data_frame("df")
  #Define_common_path_to_load_data
  path <- paste("./Dataset/Admixture_dataset/",
                unknown_samples[g],
                "/",
                Catalog_group_info[h,1],
                "/",
                "result",
                sep = "")
  
  #Confirm_wheter_the_loading_dataset_exist_or_not
  if(file.exists(paste(path, #If_the_dataset_doesn't_exist,_further_task_will_not_be_performed.
                       "/dataset.1.Q",
                       sep = "")) == FALSE){
  }else{ #If_the_dataset_exist,_further_task_will_be_performed.
    
    
    for(i in 1:Total_K){
      #Load_data
      filename <- paste(path, "/dataset.", i, ".Q", sep = "")
      f <- read.delim(filename, header = F, sep = "")
      
      i_st <- 1 + (i - 1)*length(Related_sampleID$Rad.tag)
      i_end <- i*length(Related_sampleID$Rad.tag)
      df[i_st:i_end,(4:(4+i-1))] <- f[,1:i]
    }
    
    
    
    for(i in 1:Total_K){
      df[,(3+i)] <- as.numeric(df[,(3+i)])
    }
    
    rm(f, i, i_end, i_st, path, filename)
    
    
    ###Adjustment_of_data_frame("df")_for_drawing_figure_using_ggplot
    i <- Total_K  
    df2 <- df[df$K == as.character(i),]
    
    vec <- vector()
    for(j in 1:i){
      a <- as.numeric(df2[,(3+j)])
      vec <- c(vec, a)
    }
    
    k <- vector()
    for(x in 1:i){
      a <- rep(x, length(Related_sampleID$Rad.tag))
      k <- c(k, a)
    }
    
    df3 <- as.data.frame(cbind(k,
                               rep(df2$Group, i),
                               rep(df2$Accession, i),
                               vec))
    colnames(df3) <- c("K", "Group", "Accession", "Value")
    df3[,4] <- as.numeric(df3[,4])
    
    #Change_the_order_of_samples_based_on_the_dataset("order_and_color_for_figuration")
    no <- vector()
    Cataloggroup_order <- order_and_color_for_figration[order_and_color_for_figration$UnknownSamples == unknown_samples[g] &
                                                          order_and_color_for_figration$CataloGroup == Catalog_group_info[h,1],c(3,4,5,6)]
    for(n in 1:ncol(Cataloggroup_order)){
      a <- which(Related_sampleID$Group == Cataloggroup_order[1,n])
      no <- c(no, a)
    }
    
    df5 <- df3[0,]
    for(l in 1:i){
      df4 <- df3[df3$K == l,]
      rownames(df4) <- df4$Accession
      df4 <- df4[no,]
      df4[,3] <- as.character(101:(100+nrow(df4)))
      df5 <- rbind(df5, df4)
    }
    
    df <- df5 #The_finale_adjusted_dataframe
    
    rm(df2, df3, df4, df5, Related_sampleID, a, i, j, k, l, n, x, vec, no)
    ###Draw_barplot_exhibiting_ancestral_population-deriving_proportion_using_ggplot
    
    ###Draw_figure_without_sample_name_and_save
    x <- ggplot(df, aes(x = Accession, y = Value, fill = K)) +
      geom_bar(stat="identity", width = 1.0, colour = "black", size = 0.5) +
      theme(axis.ticks = element_blank(),  
            axis.text = element_blank(),
            axis.title = element_blank(),
            axis.line = element_blank(),
            legend.position = "none")

        #Note:Position_of_each_barplot_from_left_side_is_consistent_with_sample_name_in_the_data_frame("df")

    ggsave(file = paste("./Output/",
                           unknown_samples[g],
                           "/",
                           Catalog_group_info[h,1],
                           "/Admixture_for_K=",
                           as.character(Total_K),
                           ".png",
                           sep = ""),
           height = 0.7, width = 1.8, plot = x, dpi = 700)
    
    #Save_raw_data_of_ancestral_population-deriving_proportion_which_wre_used_for_the_drawing_figure
    df <- data.frame(RAD_tag=rownames(df), df)
    write.csv(df, paste("./Output/",
                        unknown_samples[g],
                        "/",
                        Catalog_group_info[h,1],
                        "/K=",
                        as.character(Total_K),
                        "_poplation-deriving_proportion_data.csv",
                        sep = ""),
              row.names = F)
  }
  
}
  
}
  
}
