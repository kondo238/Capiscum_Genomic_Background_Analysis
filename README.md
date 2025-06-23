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

This pipeline includes five jobs (‘1.ustacks’, ‘2.cstacks’, ‘3.sstacks’, ‘4.gstacks’, and ‘5.population’) as below.

**1.ustacks** **:** construct short contigs called ‘stacks’ by de novo assembly from filtered reads (.fastq) of all samples and defined loci called ‘catalogs’ 

**2.cstacks** **:** develop catalog list

**3.sstacks** **:** explore the stacks that matched each catalog

**4.gstacks** **:** merge similar stacks and detect SNPs among all samples

**5.population** **:** generated the output file **'(populations.haplotypes.tsv)'** called **catalog_dataset** in the present study.　Then, the representative stacks tag (sequence) file 'catalog.tags.tsv' was also obtained, which were used for positional analysis of stacks in Dalle Khursani.

Script and 'population.txt' were saved in https://github.com/kondo238/Capiscum_Genomic_Background_Analysis/tree/main/All_scripts/Step.1

For running this job, the population.txt is necessary, including sample ID and population (In our case, "annuum", "chinense", "frutescens", "baccatum", "pubescens", "dalle", "annuum_test", "chinense_test", "frutescens_test")

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




# Step.2: Stacks analysis
This is the repository 

