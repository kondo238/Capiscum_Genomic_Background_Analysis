# Capiscum_Genomic_Background_Analysis
# Information

***Research Paper*** **:** Nepalese landrace chili pepper Dalle Khursani (*Capsicum* sp.) is tetraploid possessing unique genetic background derived from both *C*. *annuum* and *C*. *chinense*
                      Kondo et al. (Under review) 

***Summary of this paper*** **:** In this paper, we aimed to clarify the genetic background of the Nepalese landrace chili pepper Dalle Khursani (tetraploid and alloploid: 2n = 2x = 48). For this analysis, we designed an approach to characterize the derivation of the genomic fragments called 'stacks', based on commonality of their existence and sequences with five *Capsicum* species (*C.annuum*, *C.chinense*, *C.frutescens*, *C.baccatum*, *C.pubescens*). Finally, we revealed that almost all stacks that existed in Dalle Khursani were derived from *C.annuum* and *C.chinense*. Finally, we concluded Dalle Khursani was tetraploid, derived from both *C*. *annuum* and *C*. *chinense*

***NOTE*** **:** This repository was prepared to share the dataset and scripts related to the publication of the above manuscript. 

 This repository includes two main directories

**・All_scripts** **:** This directory contains scripts (shell, R) related to genetic background analysis of Dalle Khursani and positive control accessions of C. annuum-complex. The summarized explanation of this analysis (Step.1 ~ Step.2) is described below.

**・Dataset_used_for_publication** **:** This directory contains datasets used for this publication. The detailed information for each dataset was saved as a NOTE in each directory.

# Summary of genetic background analysis
# Step.1
**!!!Attention!!!** **:** This repository doesn't contain fastq data, so it's impossible to run this job for readers.

In the Step.1, stack analysis was performed with the shell command **'denoveo_map.pl' in stacks (v2.61)**.

This pipeline includes five jobs (‘1.ustacks’, ‘2.cstacks’, ‘3.sstacks’, ‘4.gstacks’, and ‘5.population’) as below.

**1.ustacks** **:** construct short contigs called ‘stacks’ by de novo assembly from filtered reads (.fastq) of all samples and defined loci called ‘catalogs’ 

**2.cstacks** **:** develop catalog list

**3.sstacks** **:** explore the stacks that matched each catalog

**4.gstacks** **:** merge similar stacks and detect SNPs among all samples

**5.population** **:** generated the output file **'(populations.haplotypes.tsv)'** called **catalog_dataset** in the present study.　Then, the representative stacks tag (sequence) file 'catalog.tags.tsv' was also obtained, which were used for positional analysis of stacks in Dalle Khursani.

Script and 'population.txt' were saved in https://github.com/kondo238/Capiscum_Genomic_Background_Analysis/tree/main/All_scripts/Step.1

**population.txt** **:** list for sample ID and population (In our case, "annuum", "chinense", "frutescens", "baccatum", "pubescens", "dalle", "annuum_test", "chinense_test", "frutescens_test")

The summarized script is shown below: 
```
denovo_map.pl -M 5 -T 16 \
              -o ${Output_directory} \
              --popmap ${WD}/pop_list.txt \
              --samples ${Filtered_fastq} \
              --paired -X "ustacks:-M 5 -m 3 --force-diff-len" \
              -X "cstacks:-n 0" \
              -X "populations:--write-random-snp -r 0.16 -p 1 --vcf --plink --max-obs-het 1.0 --fasta-loci --fasta-samples --fasta-samples-raw"
```


# Step.2
In the Step.2,  

# Step.3
**!!!Attention!!!** **:** This repository contains all input data and scripts, so anyone can run this job.

In the Step.3, admixture analysis was performed in more than two species-common catalogs using shell command **'admixture' in admixture (v1.3.0)**.

Script and input directory was saved in https://github.com/kondo238/Capiscum_Genomic_Background_Analysis/tree/main/All_scripts/Step.2


**Input directory** **:** directory containing all input data for admixture analysis (https://github.com/kondo238/Capiscum_Genomic_Background_Analysis/tree/main/All_scripts/Step.2/Admixture_dataset):

This directory first contains four directories for unknown samples as below,

**annuum_test**: for positive control six samples of *C.annuum*

**chinense_test**: for positive control six samples of *C.chinense*, 

**frutescens_test**: for positive control six samples of *C.frutescens*

**dalle**: for six lines of Dalle Khursani


In each above directory, four directories were prepared for catalog group as below,

**group1**: for *C.annuum*&*C.chinense*-common catalog 

**group2**: for *C.annuum*&*C.frutescens*-common catalog 

**group3**: for *C.chinense*&*C.frutescens*-common catalog 

**group4**: for Three-species-common catalogs 


In each above directory, two input data ('dataset.ped' and 'dataset.map') were prepared.


This script includes two tasks as below.

**1. Create bed file** **:** Create bed format file (dataset.bed) from input data (dataset.ped and dataset.map), which were all necessary for admixture analysis.

**2. Admixture analysis** **:** Perform admixture analysis in each catalog dataset.

For running this job, please copy and paste the input directory (Admixture_dataset) in your working directory

The summarized script is shown below: 
```
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
plink --file dataset --make-bed --out dataset

##Admixture_analysis_K=1~2
mkdir result
cd ./result
##This_is_the_loop_for_K
for K in {1..2}
do
admixture -C 10 -s time --cv ../dataset.bed $K | tee log${K}.out
done

##Admixture_analysis_for_group2_catalog(C.annuum_and_C.frutescens-common_catalog)
##Make_bed_file_by_plink
cd ${WD}/Admixture_dataset/${i[@]}/group2
plink --file dataset --make-bed --out dataset

##Admixture_analysis_K=1~2
mkdir result
cd ./result
for K in {1..2} ##This_is_the_loop_for_K
do
admixture -C 10 -s time --cv ../dataset.bed $K | tee log${K}.out
done

##Admixture_analysis_for_group3catalog(C.chinense_and_C.frutescens-common_catalog)
##Make_bed_file_by_plink
cd ${WD}/Admixture_dataset/${i[@]}/group3
plink --file dataset --make-bed --out dataset

##Admixture_analysis_K=1~2
mkdir result
cd ./result
for K in {1..2} ##This_is_the_loop_for_K
do
admixture -C 10 -s time --cv ../dataset.bed $K | tee log${K}.out
done


##Admixture_analysis_for_group3catalog(Three_species-common_catalog)
cd ${WD}/Admixture_dataset/${i[@]}/group4
singularity exec /usr/local/biotools/p/plink:1.90b4--1 plink --file dataset --make-bed --out dataset

##Admixture_analysis_K=1~3
mkdir result
cd ./result
for K in {1..3} ##This_is_the_loop_for_K
do
admixture -C 10 -s time --cv ../dataset.bed $K | tee log${K}.out
done

done

#end
```


