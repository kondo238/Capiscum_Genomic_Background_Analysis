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
# Step.1: Stacks analysis
In the Step.1, stack analysis was performed with the shell command **'denoveo_map.pl' in stacks (v2.61)**.

Script and 'population.txt' were saved in https://github.com/kondo238/Capiscum_Genomic_Background_Analysis/tree/main/All_scripts/Step.1

This analysis generates **stacks by *de novo* assembly from RAD-seq reads (.fastq)** of all samples in the present study.

Then, **catalog_dataset ('populations.haplotypes.tsv')** will be obtained, containing SNP genotype for all catalog (loci) and all samples.

For runnning this job, the population.txt is nessesary including sample ID and population (In our case, "annuum", "chinense", "frutescens", "baccatum", "pubescens", "dalle", "annuum_test", "chinense_test", "frutescens_test")

The summarized script was shown below: 
```
git status
git add
git commit
```




# Step.2: Stacks analysis
This is the repository 

