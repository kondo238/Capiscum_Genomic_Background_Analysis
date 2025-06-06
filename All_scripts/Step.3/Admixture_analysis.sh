######################NOTE############################################################################################################################
##This is the shell script to perform admixture analysis in each catalog group (group1, group2, group3, group4) for each unknown samples
##Please make directory 'admixture_analysis' as your working directory
##In 'admixture_analysis' directory, please copy&paste 'Admixture_dataset' directory including genotype data obtained by previous Rscript (see Step.2)
##Outputs will be saved in 'Admixture_dataset', so please download 'Admixture_dataset' again to perform futher analysis (Step.4)
######################################################################################################################################################

##Path_for_working_directory
WD=/.../admixture_analysis

##Define_the_group_list_for_unknown_samples
array=(annuum_test chinense_test frutescens_test dalle)

##Admixture_analysis_for_each_unknown_sample
##This_is_the_loop_for_unknown_samples
for i in ${array[@]}
do

##Admixture_analysis_for_group1_catalog(C.annuum_and_C.chinense-common_catalog)
##Make_bed_file_by_plink
cd ${WD}/Admixture_dataset/${i[@]}/group1
singularity exec /usr/local/biotools/p/plink:1.90b4--1 plink --file dataset --make-bed --out dataset

##Admixture_analysis_K=1~2
mkdir result
cd ./result
##This_is_the_loop_for_K
for K in {1..2}
do
singularity exec /usr/local/biotools/a/admixture\:1.3.0--0 admixture -C 10 -s time --cv ../dataset.bed $K | tee log${K}.out
done

##Admixture_analysis_for_group2_catalog(C.annuum_and_C.frutescens-common_catalog)
##Make_bed_file_by_plink
cd ${WD}/Admixture_dataset/${i[@]}/group2
singularity exec /usr/local/biotools/p/plink:1.90b4--1 plink --file dataset --make-bed --out dataset

##Admixture_analysis_K=1~2
mkdir result
cd ./result
for K in {1..2} ##This_is_the_loop_for_K
do
singularity exec /usr/local/biotools/a/admixture\:1.3.0--0 admixture -C 10 -s time --cv ../dataset.bed $K | tee log${K}.out
done

##Admixture_analysis_for_group3catalog(C.chinense_and_C.frutescens-common_catalog)
##Make_bed_file_by_plink
cd ${WD}/Admixture_dataset/${i[@]}/group3
singularity exec /usr/local/biotools/p/plink:1.90b4--1 plink --file dataset --make-bed --out dataset

##Admixture_analysis_K=1~2
mkdir result
cd ./result
for K in {1..2} ##This_is_the_loop_for_K
do
singularity exec /usr/local/biotools/a/admixture\:1.3.0--0 admixture -C 10 -s time --cv ../dataset.bed $K | tee log${K}.out
done


##Admixture_analysis_for_group3catalog(Three_species-common_catalog)
cd ${WD}/Admixture_dataset/${i[@]}/group4
singularity exec /usr/local/biotools/p/plink:1.90b4--1 plink --file dataset --make-bed --out dataset

##Admixture_analysis_K=1~3
mkdir result
cd ./result
for K in {1..3} ##This_is_the_loop_for_K
do
singularity exec /usr/local/biotools/a/admixture\:1.3.0--0 admixture -C 10 -s time --cv ../dataset.bed $K | tee log${K}.out
done

done

#end
