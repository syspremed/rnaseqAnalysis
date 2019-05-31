#!/usr/bin/perl

#Usage : perl rsem_picard.pl rsem_out_dir rsem_script_dir fastq_path_file

$annot = "/scratch/DMP/SPRECMED/ypatil/annotation/human/genome";

$rsemDir = "$ARGV[0]";
$scriptDir = "$ARGV[1]";

mkdir -p "$rsemDir";

open(FH,"$ARGV[2]") || die($!);

@gz = <FH>;

for($i=0;$i<@gz;$i++){


if((($gz[$i] =~ /(.*)\/(.*)\/(.*)_(R1_*).*.gz/g) && ($gz[$i+1] =~ /(.*)\/(.*)\/(.*)_(R2_*).*.gz/g)) || (($gz[$i] =~ /(.*)\/(.*)\/(.*)_(R1_*).*.gz/g) && ($gz[$i+1] =~ /(.*)\/(.*)\/(.*)_(R2_*).*.gz/g))){


$fastqName = "$3";
       chomp($gz[$i]);
       chomp($gz[$i+1]);



open (OUTFILE, ">>$scriptDir/$fastqName.sh");

print OUTFILE "#!/bin/bash\n" ;
print OUTFILE "#BSUB -J Run.Picard.$fastqName\n" ;
print OUTFILE "#BSUB -n 1\n" ;
print OUTFILE "#BSUB -P DMPPHDAAZ\n" ;
print OUTFILE "#BSUB -W 6:00\n" ;
print OUTFILE "#BSUB -o RSEM.$fastqName.output.%J\n" ;
print OUTFILE "#BSUB -e RSEM.$fastqName.error.%J\n" ;
print OUTFILE "#BSUB -R span[hosts=1]\n\n\n" ;

print OUTFILE "# Alignment steps using RSEM\n" ;
print OUTFILE "module load CPAN/5.16.3\n" ;
print OUTFILE "module load rsem/1.2.29\n" ;
print OUTFILE "module load bowtie2/2.2.6\n" ;
print OUTFILE "module load samtools/1.3.1\n" ;
print OUTFILE "module load java/sun8/1.8.0u66\n" ;
print OUTFILE "module load picard-tools/2.1.0\n" ;

print OUTFILE "mkdir -p $rsemDir/$fastqName\n\n";


print OUTFILE "#Picard analysis\n";

print OUTFILE "samtools sort -o $rsemDir/$fastqName/$fastqName.transcript_sorted.bam $rsemDir/$fastqName/$fastqName.transcript.bam\n\n";

print OUTFILE "samtools index $rsemDir/$fastqName/$fastqName.transcript_sorted.bam\n\n";

print OUTFILE "samtools flagstat $rsemDir/$fastqName/$fastqName.transcript_sorted.bam >> $rsemDir/$fastqName/\"$fastqName\"_flagstat_mapping\n\n\n";


$PICARDHOME="/apps/picard-tools/2.1.0";

#print OUTFILE "java  -Xmx16G  -jar $PICARDHOME/picard.jar CreateSequenceDictionary R=$annot/Homo_sapiens.GRCh37.69.dna.primary_assembly_ref.transcripts.fa O=$annot/Homo_sapiens.GRCh37.69.dna.primary_assembly_ref.transcripts.dict\n\n";


print OUTFILE "java  -Xmx16G  -jar $PICARDHOME/picard.jar CollectAlignmentSummaryMetrics R=$annot/Homo_sapiens.GRCh37.69.dna.primary_assembly_ref.transcripts.fa I=$rsemDir/$fastqName/$fastqName.transcript_sorted.bam O=$rsemDir/$fastqName/\"$fastqName\"_alignment_summary_output.txt\n\n";


print OUTFILE "java  -Xmx16G  -jar $PICARDHOME/picard.jar CollectInsertSizeMetrics I=$rsemDir/$fastqName/$fastqName.transcript_sorted.bam O=$rsemDir/$fastqName/\"$fastqName\"_insert_size_metrics.txt H=$rsemDir/$fastqName/\"$fastqName\"_insert_size_histogram.pdf M=0.5\n\n";


print OUTFILE "java  -Xmx16G  -jar $PICARDHOME/picard.jar QualityScoreDistribution I=$rsemDir/$fastqName/$fastqName.transcript_sorted.bam O=$rsemDir/$fastqName/\"$fastqName\"_qual_score_dist.txt CHART=$rsemDir/$fastqName/\"$fastqName\"_qual_score_dist.pdf\n\n";

print OUTFILE "java  -Xmx16G  -jar $PICARDHOME/picard.jar CollectGcBiasMetrics I=$rsemDir/$fastqName/$fastqName.transcript_sorted.bam O=$rsemDir/$fastqName/\"$fastqName\"_gc_bias_metrics.txt CHART=$rsemDir/$fastqName/\"$fastqName\"_gc_bias_metrics.pdf S=$rsemDir/$fastqName/\"$fastqName\"_summary_metrics.txt R=$annot/Homo_sapiens.GRCh37.69.dna.primary_assembly_ref.transcripts.fa\n\n";

print OUTFILE "java -Xmx16G  -jar $PICARDHOME/picard.jar CollectRnaSeqMetrics I=$rsemDir/$fastqName/$fastqName.transcript_sorted.bam O=$rsemDir/$fastqName/\"$fastqName\"_output_RNA_Metrics.txt REF_FLAT=$annot/Homo_sapiens.GRCh37.69.refFlat_edited.txt STRAND=NONE CHART=$rsemDir/$fastqName/\"$fastqName\"_normalized_position_vs_coverage.pdf\n\n";


	}
close OUTFILE;
}

