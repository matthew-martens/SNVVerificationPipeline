#!/bin/bash

#Step 1: Access and trim reads from paired-end Illumina NextSeq sequencing,ensuring sufficient quality and read size for subsequent steps.
/PATH_TO_FILE/prinseq-lite-0.20.4/prinseq-lite.pl -fastq /PATH_TO_FILE/Reads_R1_001.fastq -fastq2 /PATH_TO_FILE/Reads_R2_001.fastq -out_format 3 -out_bad null -out_good stdout -trim_right 1 -trim_left 12|/PATH_TO_FILE/prinseq-lite-0.20.4/prinseq-lite.pl -fastq /PATH_TO_FILE/Reads_R1_001.fastq -fastq2 /PATH_TO_FILE/Reads_R2_001.fastq -out_format 3 -out_bad null -out_good 3B_H11 -line_width 0 -trim_qual_left 35 -trim_qual_right 35 -trim_ns_left 1 -trim_ns_right 1 -min_len 30 &&

#Step 2: Align the reads to the parental GT1 (annotated) reference genome using Bowtie2.2.
./bowtie2-2.2.9/bowtie2 --seed 1 --very-sensitive-local -p 30 -x /PATH_TO_GT1Chromosomes/gt1chromo -1 /PATH_TO_FILE/Reads_1.fastq -2 /PATH_TO_FILE/Reads2.fastq -S /PATH_TO_FILE/FILENAME.sam &&

#Step 3: Prepare the reads for appropriate annotation through FreeBayes by (1) converting to a BAM file, (2) sorting the reads in the BAM file, and (3) indexing the sorted reads.
samtools view -@4 -S -b FILENAME.sam > FILENAME.bam &&
samtools sort -@4 FILENAME.bam > FILENAME.sorted.bam &&
samtools index FILENAME.bam &&

#Step 4: Run FreeBayes under the specified parameters to generate a .VCF file showing mutations (insertions, deletions, SNVs) based on the reference sequence.
freebayes -f /PATH_TO_FILE/gt1_chromosomes.fasta /PATH_TO_FILE/FILENAME.sorted.bam  -C 8 -p 1 -q 30 > FILENAME.vcf &&

#Step 5: Annotate the FreeBayes-generated mutations with SNPEff, providing the gene name, mutation annotation, and much more information.
	#IF needed, make the database for TGGT_1:
        	#Add a genome to the config file FIRST, in the appropriate section (Genomes) as follows: nameofdirectorycontainingfiles.genome:Toxoplasma_gondii_GT1
        	#Then make the database:java -jar snpEff.jar build -gff3 -v 20150830_ToxoDB_Tg_GT1 for GFF files.
		#Then run the SNPEff command below.

java -Xmx4g -jar snpEff.jar -v TGGT1DATABASENAME  FILENAME.vcf > FILENAMEANNOTATED.vcf


