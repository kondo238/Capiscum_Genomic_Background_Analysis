#######NOTE!!!_Please_prepare_population_list_file(pop_list.txt) in your working directory, which includes_sample_ID_with_population_information_for_each_filtered_data
##Please_define_your_working_directory
WD=/~

##Please_define_directory_containing_filtered_sequence_data(.fastq)_for_all_samles
Filtered_fastq=/~

#Go_to_Working_directory
cd ${WD}
mkdir result #Output_directory

#Stacks_analysis_using_stacks(v2.61)
denovo_map.pl -M 5 -T 16 \
              -o ./result \
              --popmap ./pop_list.txt \
              --samples ${Filtered_fastq} \
              --paired -X "ustacks:-M 5 -m 3 --force-diff-len" \
              -X "cstacks:-n 0" \
              -X "populations:--write-random-snp -r 0.16 -p 1 --vcf --plink --max-obs-het 1.0 --fasta-loci --fasta-samples --fasta-samples-raw"

#End

