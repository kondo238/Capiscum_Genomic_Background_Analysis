#Necessary_packages
library(progress)
library(stringr)
setwd(getwd())
unlink("./Output", recursive = TRUE)
dir.create("./Output")
dir.create("./Output/Admixture_dataset/")

################Data_Loading##########################################################################################################
#Loading_Sample_ID_list
sample_ID_list <- as.data.frame(read.csv("./Dataset/sample_id.csv"))

#Loading_catalog_dataset_for_all_samples(each six_accessions_of_Capsicum_five_species & additional six accessions of C.annuum, C.chinense, C.frutescens, and Dalle Khursani)
catalog_dataset <- read.delim("./Dataset/populations.haplotypes.tsv", header = T, sep = "") #genotype_data_of_all_samples
#modify_the_mismatch_between_column_name_and_the_data
a <- catalog_dataset[,-c(57:59)]
colnames(a) <- colnames(catalog_dataset)[-c(1,3,4)]
catalog_dataset <- a
rownames(catalog_dataset) <- catalog_dataset$Catalog
rm(a)

#Calculate_stacks(genome fragment)_count_at_each_catalog_for_each_refecense_species_and_Unknown_samples
#Define_Group_list:annuum, chinense, frutescens, baccatum, and pubescens are group including each six reference accessions, while annuum_test, chinense_test, frutescens_test, and dalle are group including each six accessions used as unknown samples    
group_list <- c("annuum", "chinense", "frutescens", "baccatum", "pubescens", "annuum_test", "chinense_test", "frutescens_test", "dalle")

#Prepare_data_frame_to_save_stacks_count_data_at_each_catalog
count_df <- as.data.frame(matrix(0,
                                 ncol = (length(group_list) + 1),
                                 nrow = nrow(catalog_dataset)))

colnames(count_df) <- c("RAD_catalog", group_list)
count_df[,1] <- catalog_dataset$Catalog
rownames(count_df) <- count_df$RAD_catalog

#Calculate_stacks_counts_for_each_group_and_save_them_on_count_df
N <- length(group_list)
PB <- progress_bar$new(total = N)

for(i in 1:length(group_list)){
  PB$tick()
  for(j in 1:nrow(catalog_dataset)){
    df <- t(catalog_dataset[j,-c(1,2)]) #Extract_genotype_for_catalog_j
    df <- t(df[sample_ID_list[which(sample_ID_list$Group == group_list[i]),2],]) #Extract_the_genotype_for_group_i_in_catalog_j 
    
    no <- as.numeric(length(which(df[1,] != "-"))) #Count_stacks_count (the number of character without "-") 
    count_df[j,(i+1)] <- no #save_the_stacks_counts_in_count_df
  }
  Sys.sleep(1/N)
}

rm(i, j, df, PB, i, j, N, no)

#Save_catalog_dataset_with_stacks_count_data
a <- cbind(catalog_dataset, count_df[,-1])
write.csv(a, "./Output/Catalog_dataset_with_stacks_count_data.csv", row.names = F)
rm(a)

########################################Genomic_background_analysis_for_unknown_samples(Step1.catalog_exsistance-based_characterization_&_preparation_of_genotype_data_for_Step2.catalog_sequence-based_characterization)#######################################################
############Preparation_of_for_genomic_bacground_analysis############
#Define_group_for_reference_species_and_unknown_samples
reference_spesies <- c("annuum", "chinense", "frutescens", "baccatum", "pubescens") #For_reference_species
unknown_samples <- c("annuum_test", "chinense_test", "frutescens_test", "dalle")  #For_unknown_samples

#Prepare_the_data_frame_to_save_counts_and_proportion_of_catalog_derivation_for_unknown_samples(This is for Step1.catalog_existance-based_characterization)
Derivation_df <- as.data.frame(matrix(NA,
                                      nrow = 0,
                                      ncol = 5))
colnames(Derivation_df) <-  c("UnknownSamples", "CharacterizeMethod", "Group", "CatalogCounts", "Proportion_percent")

#Prepare_the_'Reference_array'_including_presence-absence_information_of_stacks_in_each_catalog_for_Capsicum_five_species(This is for Step1.catalog_existance-based_characterization)
reference_array <- count_df[,c(1:6)]
for(i in 1:length(reference_spesies)){ #Put_Presence(stacks >= 1)_and_Absence(stacks = 0)_information
  reference_array[which(reference_array[,(i+1)] >= 1),(i+1)] <- "Presence"
  reference_array[which(reference_array[,(i+1)] == 0),(i+1)] <- "Absence"
}
rownames(reference_array) <- reference_array$RAD_catalog
rm(i)

#Prepare_data_frame_to_save_Number_of_catalogs_used_for_Admixture_analysis(This is for Step2.catalog_sequence-based_characterization)
Admix_catalog_counts <- as.data.frame(matrix(NA,
                                             ncol = 3,
                                             nrow = 0))
colnames(Admix_catalog_counts) <- c("UnknownSamples", "Group", "CatalogCounts")

####################Step1.catalog_existance-based_characterization#################################
#Calculation_of_the_commonality_of_present_stacks_between_unknown_samples_and_Capsicm_species_with_preparing_genotype_data_for_futher_Admixture_analysis_for_multiple_species-shared_catalogs
for(g in 1:length(unknown_samples)){
dir.create(paste("./Output",
                 "/Admixture_dataset/",
                 unknown_samples[g],
                 sep = ""))
  
#Prepare_the_'Test_array'_including_presence-absence_information_of_stacks_in_each_catalog_for_unknown_samples
test_array <- count_df[,c(1, which(colnames(count_df) == unknown_samples[g]))]
colnames(test_array) <- c("RAD_catalog", "Count")
test_array <- test_array[test_array$Count  == 6,] #Extract_catalots_that_all_six_accessions_possessed_stacks
test_array[,2] <- "Presence"
rownames(test_array) <- test_array$RAD_catalog
  
#Prepare_the_"Merged_array"("reference_array"+"test_array")_including_presence-absence_information_of_stakcs_in_each_species_for_unknown_sample-present_catalogs###########################################
merged_array <- cbind(reference_array[rownames(test_array),], UnknownSample=test_array[,2])

############Five_Capsicum_species-based_characterization############
#Convert_presence-absence_information_of_five_Capsicum_species_to_binary_data(1:Precense, 0:Absence)
df <- merged_array[,c(2:6)]
for(i in 1:5){
  df[which(df[,i] == "Presence"),i] <- 1
  df[which(df[,i] == "Absence"),i] <- 0
  df[i] <- as.numeric(df[,i])
}

rm(i)

#Prepare_data_frame_to_save_result
#This_analysis_calculates_the_number_and_proportion_of_unknown_sample-present_catalog_shared_with_each_Group(1.C.annuum-specific catalog, 2.C.chinense-specific catalog, 3.C.frutescens-specific catalog, 4.C.baccatum-specific_ atalog, 5.C.pubescens-specific catalog, 6.five species-common catalogs, 7.Other catalog. 8.Non-shared catalog)
FiveSpeciesBased <- as.data.frame(matrix(NA,
                                   ncol = 3,
                                   nrow = 8))

colnames(FiveSpeciesBased) <- c("Group", "CatalogCounts", "Proportion_percent")
FiveSpeciesBased[,1] <- c(paste(rep("C.", length(reference_spesies)),
                                reference_spesies,
                                rep("-specific", length(reference_spesies)),
                                sep = ""),
                          "Five_species-common",
                          "Others",
                          "Non-shared")


#Calculation_for_species-specific_catalogs
di <- diag(1, nrow = 5, ncol = 5)
for(i in 1:5){
  FiveSpeciesBased[i,2] <-  length(df[which(df$annuum == di[i,1] &
                                        df$chinense == di[i,2] &
                                        df$frutescens == di[i,3] &
                                        df$baccatum == di[i,4] &
                                        df$pubescens == di[i,5]),1])
  FiveSpeciesBased[i,3] <- FiveSpeciesBased [i,2]/nrow(df)*100
}
rm(i)

#Calculation_for_for_five_species-common_catalogs
FiveSpeciesBased[6,2] <-  length(df[which(df$annuum == 1 &
                                      df$chinense == 1 &
                                      df$frutescens == 1 &
                                      df$baccatum == 1 &
                                      df$pubescens == 1),1])
FiveSpeciesBased[6,3] <- FiveSpeciesBased[6,2]/nrow(df)*100

#Calculation_for_Non-shared_catalogs
FiveSpeciesBased[8,2] <-  length(df[which(df$annuum == 0 &
                                       df$chinense == 0 &
                                       df$frutescens == 0 &
                                       df$baccatum == 0 &
                                       df$pubescens == 0),1])
FiveSpeciesBased[8,3] <- FiveSpeciesBased[8,2]/nrow(df)*100

#Calculation_for_other_catalogs
FiveSpeciesBased[7,2] <- nrow(df) - sum(FiveSpeciesBased[c(1:6,8),2])
FiveSpeciesBased[7,3] <- FiveSpeciesBased[7,2]/nrow(df)*100

FiveSpeciesBased <- cbind(UnknownSamples=rep(unknown_samples[g],8), CharacterizeMethod=rep("Five_species-based", 8), FiveSpeciesBased)
Derivation_df <- rbind(Derivation_df, FiveSpeciesBased)

rm(FiveSpeciesBased, df, di)

############Three_Capsicum_species(C.annuum-complex)-based_characterization############
#Convert_presence-absence_information_of_three_Capsicum_species_to_binary_data(1:Precense, 0:Absence)
df <- merged_array[,c(2:4)]
for(i in 1:3){
  df[which(df[,i] == "Presence"),i] <- 1
  df[which(df[,i] == "Absence"),i] <- 0
  df[i] <- as.numeric(df[,i])
}

rm(i)

#Prepare_data_frame_to_save_result
#This_analysis_calculates_the_number_and_proportion_of_unknown_sample-present_catalog_shared_with_each_Group(1.C.annuum-specific catalog, 2.C.chinense-specific catalog, 3.C.frutescens-specific catalog, 4.C.annuum&C.chinense-common catalogs, 5.C.annuum&C.frutescens-common catalogs, 6.C.chinense&C.frutescens-common catalogs, 7.three_species-common catalogs, 8.Non-shared catalog)
ThreeSpeciesBased <- as.data.frame(matrix(NA,
                                         ncol = 3,
                                         nrow = 8))

colnames(ThreeSpeciesBased) <- c("Group", "CatalogCounts", "Proportion_percent")
ThreeSpeciesBased[,1] <- c(paste(rep("C.", length(reference_spesies[1:3])),
                                reference_spesies[1:3],
                                rep("-specific", length(reference_spesies[1:3])),
                                sep = ""),
                           "C.annuum&C.chinense-common",
                           "C.annuum&C.frutescens-common",
                           "C.chinense&C.frutescens-common",
                          "Three_species-common",
                          "Non-shared")


#Calculation_for_species-specific_catalogs
di <- diag(1, nrow = 3, ncol = 3)
for(i in 1:3){
  ThreeSpeciesBased[i,2] <-  length(df[which(df$annuum == di[i,1] &
                                              df$chinense == di[i,2] &
                                              df$frutescens == di[i,3]),1])
  ThreeSpeciesBased[i,3] <- ThreeSpeciesBased [i,2]/nrow(df)*100
}
rm(i, di)

#Calculation_for_two_species-common_catalogs
di <- diag(0, nrow = 3, ncol = 3)
di[,] <- 1
di[1,3] <- di[2,2] <- di[3,1] <- 0
for(i in 1:3){
  ThreeSpeciesBased[(i+3),2] <-  length(df[which(df$annuum == di[i,1] &
                                               df$chinense == di[i,2] &
                                               df$frutescens == di[i,3]),1])
  ThreeSpeciesBased[(i+3),3] <- ThreeSpeciesBased [(i+3),2]/nrow(df)*100
}
rm(i, di)

#Calculation_for_for_Three_species-common_catalogs
ThreeSpeciesBased[7,2] <-  length(df[which(df$annuum == 1 &
                                            df$chinense == 1 &
                                            df$frutescens == 1),1])
ThreeSpeciesBased[7,3] <- ThreeSpeciesBased[7,2]/nrow(df)*100



#Calculation_for_Non-shared_catalogs
ThreeSpeciesBased[8,2] <-  length(df[which(df$annuum == 0 &
                                            df$chinense == 0 &
                                            df$frutescens == 0),1])
ThreeSpeciesBased[8,3] <- ThreeSpeciesBased[8,2]/nrow(df)*100


ThreeSpeciesBased <- cbind(UnknownSamples=rep(unknown_samples[g],8), CharacterizeMethod=rep("Three_species-based", 8), ThreeSpeciesBased)
Derivation_df <- rbind(Derivation_df, ThreeSpeciesBased)
rm(ThreeSpeciesBased, df)

############Preparation_for_genotype_dataset_for_Step2.catalog_sequence-based_characterization############
#Define_catalog_group(group1:C.annuum&C.chinense-common_catalog, group2:C.annuum&C.frutescens-common_catalog,group3:C.chinense&C.frutescens-common_catalog, group4:Three_species-common_catalog,)
Catalog_group_info <- data.frame(Group=c("group1", "group2", "group3", "group4"),
                                 FistSpecies=c("annuum", "annuum", "chinense", "annuum"),
                                 SecondSpecies=c("chinense", "frutescens", "frutescens", "chinense"),
                                 ThirdSpecies=c("None", "None", "None", "frutescens"))

#Make_binary_presence-absence_data_in_Three_species_for_unknown_samples_present_catalogs
df <- merged_array[,c(2:4)]
for(i in 1:3){
  df[which(df[,i] == "Presence"),i] <- 1 #1:Presence
  df[which(df[,i] == "Absence"),i] <- 0 #A0:bsence
  df[i] <- as.numeric(df[,i])
}

rm(i)

di <- diag(0, nrow = 3, ncol = 3)
di[,] <- 1
di[1,3] <- di[2,2] <- di[3,1] <- 0
di <- rbind(di, c(1, 1, 1))

#Extraction_of_genotypes_for_each_group2_in_each_group-related_accessions
for(h in 1:nrow(Catalog_group_info)){
#Make_output_directory_to_save_genotype_data
    dir.create(paste("./Output",
                   "/Admixture_dataset/",
                   unknown_samples[g],
                   "/",
                   Catalog_group_info[h,1],
                   sep = ""))  

d <- df[which(df$annuum == di[h,1] &
                df$chinense == di[h,2] &
                df$frutescens == di[h,3]),]
marker <- as.character(rownames(d)) #Genotypes_only_for_unknown_sample-present_catalogs_were_extracted
geno <- catalog_dataset[marker,]
geno <- geno[,-c(1,2)]
geno <- t(geno)

Related_SampleID <- sample_ID_list[which(sample_ID_list$Group == Catalog_group_info[h,2] |
                                           sample_ID_list$Group == Catalog_group_info[h,3] |
                                           sample_ID_list$Group == Catalog_group_info[h,4] |
                                           sample_ID_list$Group == unknown_samples[g]),c(2,5)]
geno <- geno[Related_SampleID$Rad.tag,] #Genotypes_only_for_related_species_were_extracted

#Make_genotype_ID_and_genotype_file
s <- as.character(Related_SampleID$Group)
s_mt <- as.data.frame(cbind(s,
                            1:length(s),
                            rep(0, length(s)),
                            rep(0, length(s)),
                            rep(0, length(s)),
                            rep(0, length(s))
))
colnames(s_mt) <- c("FamID", "Individual ID", "Paternal ID", "Maternal ID", "Sex", "Phenotype")

#Change_the_genotype_format_("consensus(non-alleic), "-"(missing_stacks), "N/N"(stacks_existed_but_missing_genotype)_were_changed_to_"0,0". Then, the_haplotye_information_was_ignored;A/B and B/A were commonly regarded as "A,B")
g1 <- c("A/A", "T/T", "G/G", "C/C", "A/T", "T/A", "A/G", "G/A", "A/C", "C/A", "T/G", "G/T", "T/C", "C/T", "G/C", "C/G", "N/N", "-", "consensus")
g2 <- c("A,A", "T,T", "G,G", "C,C", "A,T", "A,T",  "A,G", "A,G", "A,C", "A,C", "T,G", "T,G", "T,C", "T,C", "G,C", "G,C", "0,0", "0,0", "0,0")

for(i in 1:length(geno[,1])){
  for(j in 1:length(g1)){
    no <- which(geno[i,] == g1[j])
    if(length(no) != 0){
      geno[i,no] <- g2[j]
    }else{
    }
  }
}

rm(i, j, g1, g2, no, s, d)


#Filteling_genotype
#1st_filtering_for_few_genotyped_catalog(remove catalog that less than 4 stacks)
Needed_reads <- 4 #Threshold_for_genotyped_samples

if(h != 4){ #In case of two_species-common catalogs (group1, group2, and group3)
#Prepare_data_frame_to_save_stacks_count_data_at_each_catalog
c_df <- count_df[marker,
                 c(1,
                   which(colnames(count_df) == Catalog_group_info[h,2]),
                   which(colnames(count_df) == Catalog_group_info[h,3]),
                   which(colnames(count_df) == unknown_samples[g]))]
colnames(c_df) <- c("RAD_catalog", "FirstSpecies", "SecondSpecies", "UnknownSamples")

#Extract_catalogID_that_satisfied_genotype_threshold
validRAD_catalog <- as.character(c_df[c_df$FirstSpecies >= Needed_reads &
                                        c_df$SecondSpecies >= Needed_reads &
                                        c_df$UnknownSamples >= Needed_reads,1])
#Extract_genotype_for_the_extracted_catalogID
geno <- geno[,validRAD_catalog]

}else{  #In case of three_species-common catalogs (group4)
  #Prepare_data_frame_to_save_stacks_count_data_at_each_catalog
  c_df <- count_df[marker,
                   c(1,
                     which(colnames(count_df) == Catalog_group_info[h,2]),
                     which(colnames(count_df) == Catalog_group_info[h,3]),
                     which(colnames(count_df) == Catalog_group_info[h,4]),
                     which(colnames(count_df) == unknown_samples[g]))]
  colnames(c_df) <- c("RAD_catalog", "FirstSpecies", "SecondSpecies", "ThirdSpecies", "UnknownSamples")
  
  #Extract_catalogID_that_satisfied_genotype_threshold
  validRAD_catalog <- as.character(c_df[c_df$FirstSpecies >= Needed_reads &
                                          c_df$SecondSpecies >= Needed_reads &
                                          c_df$ThirdSpecies >= Needed_reads &
                                          c_df$UnknownSamples >= Needed_reads,1])
  #Extract_genotype_for_the_extracted_catalogID
  geno <- geno[,validRAD_catalog]
}

rm(c_df, validRAD_catalog, Needed_reads)

if(ncol(geno) < 5){ #If_the_extracted_catalogs_were_less_than_five, the further_analysis_were_given_up
  #The_number_of_extracted_catalogs_for_each_group_was_saved_in_Admix_catalog_counts
  a <- data.frame(UnknownSamples=unknown_samples[g], Group=Catalog_group_info[h,1], CatalogCounts=ncol(geno))
  Admix_catalog_counts <- rbind(Admix_catalog_counts, a)
  rm(geno, s_mt, marker, a)

  }else{ #If_the_extracted_catalogs_were_less_more_than_five, the further_filtering_was_performed

#2nd_filtering_for_removing_non-alleic_and_multi-alleic_catalogs
#Calculate_the_kinds_of_allele_in_each_catalog
allele_no <- vector()
for(i in 1:ncol(geno)){
  a <- unique(geno[,i])
  n <- which(a == "0,0")
  if(length(n) != 0){
    a <- a[-n]
    rm(n)
  }else{
    rm(n)
  }
  a <- as.vector(str_split_fixed(a, pattern = ",", n =2))
  a <- length(unique(a))
  allele_no <- c(allele_no, a)
}

#Extract bi-alleic genoytpes
geno <- geno[,which(allele_no == 2)] #genotypes possessing two kinds of alleles were only extracted

rm(i, a, allele_no)  

if(ncol(geno) < 5){  #If_the_extracted_catalogs_were_less_than_five, the further_analysis_were_given_up
  #The_number_of_extracted_catalogs_for_each_group_was_saved_in_Admix_catalog_counts
  a <- data.frame(UnknownSamples=unknown_samples[g], Group=Catalog_group_info[h,1], CatalogCounts=ncol(geno))
  Admix_catalog_counts <- rbind(Admix_catalog_counts, a)
  rm(geno, s_mt, marker, a)
}else{ #If_the_extracted_catalogs_were_less_more_than_five, the further_filtering_was_performed


#3rd_filtering_for_catalogs_where_missing_genotype_ratio_exceeds_more_than_30%_among_all_samples
  no_vec <- vector()
  for(i in 1:ncol(geno)){
    no_comp <- length(which(geno[,i] == "0,0"))
    no_vec <- c(no_vec, no_comp)
}
  
geno <- geno[,which(no_vec < 0.3*nrow(geno))] #Threshold_of_missing_ratio
rm(no_vec, i, no_comp)
  
  
#Final_preparation_of_genotype_data(.ped and .map)_for_Admixture_analysis
#For_PED_file_containing_population,Accession,Sex, and Genotypes
geno2 <-as.data.frame(str_split_fixed(geno[,1], ",", 2))
for(i in 2:length(geno[1,])){
  a <- as.data.frame(str_split_fixed(geno[,i], ",", 2))
  geno2 <- cbind(geno2, a)
}

rm(a, i)

for(i in 1:ncol(geno2)){
  geno2[which(geno2[,i] == "0"),i] <- NA
}

rm(i)

geno2 <- cbind(s_mt, geno2)

#Save_PED_file
write.table(geno2, file=paste("./Output",
                              "/Admixture_dataset/",
                              unknown_samples[g],
                              "/",
                              Catalog_group_info[h,1],
                              "/dataset.ped",
                              sep = ""),
            sep="\t",col.names=F,row.names=F,quote=F)  

#For_MAP_file_containing_potisional_information_for_each_catalog
map <- as.data.frame(cbind(
  chromosome=rep("0", length(colnames(geno))),
  locus=as.character(colnames(geno)),
  distance=rep("0", length(colnames(geno))),
  site=as.character(colnames(geno))
))

#Save_MAP_file
write.table(map, file=paste("./Output",
                            "/Admixture_dataset/",
                            unknown_samples[g],
                            "/",
                            Catalog_group_info[h,1],
                            "/dataset.map",
                            sep = ""),
            sep="\t",col.names=F,row.names=F,quote=F)

#The_number_of_extracted_catalogs_for_each_group_was_saved_in_Admix_catalog_counts
a <- data.frame(UnknownSamples=unknown_samples[g], Group=Catalog_group_info[h,1], CatalogCounts=ncol(geno))
Admix_catalog_counts <- rbind(Admix_catalog_counts, a)

rm(geno, geno2, map, s_mt, marker, a)
}
}
}

rm(h, df, di, Catalog_group_info, merged_array, test_array)

}

rm(unknown_samples, reference_spesies, g)

write.csv(Derivation_df, "./Output/Output_of_catalog_derivation_for_unknown_samples_based_on_step1_analysis.csv", row.names = F)
write.csv(Admix_catalog_counts, "./Output/The_number_of_catalogs_used_for_admixture_analysis.csv", row.names = F)

