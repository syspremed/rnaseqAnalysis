#!/usr/bin/perl

#Usage : perl rsem_picard.pl rsem_out_dir rsem_script_dir fastq_path_file


#/data/rds/DMP/DUDMP/SPRECMED/DATA/EXTERNAL/murine_model_1/RNASeq/DZKP/DZKP-AN29718A/FCH3M7LALXX_L3_HKRDMOUoldTAAGRAAPEI-216_2.fq.gz
#/data/rds/DMP/DUDMP/SPRECMED/DATA/EXTERNAL/murine_model_1/RNASeq/DZKP/DZKP-AN29718A/FCH3M7LALXX_L2_HKRDMOUoldTAAGRAAPEI-216_1.fq.gz


$annot = "/scratch/DMP/SPRECMED/ypatil/annotation/human/genome";

$rsemDir = "$ARGV[0]";
$scriptDir = "$ARGV[1]";

mkdir -p "$rsemDir";

open(FH,"$ARGV[2]") || die($!);


@gz = <FH>;

for($i=0;$i<@gz;$i++){

#(.*)\/(.*)\/(.*).fq.gz


if((($gz[$i] =~ /(.*)\/(.*)\/(.*)_(R1_*).*.gz/g) && ($gz[$i+1] =~ /(.*)\/(.*)\/(.*)_(R2_*).*.gz/g)) || (($gz[$i] =~ /(.*)\/(.*)\/(.*)_(R1_*).*.gz/g) && ($gz[$i+1] =~ /(.*)\/(.*)\/(.*)_(R2_*).*.gz/g))){

$fastqName = "$3";
       chomp($gz[$i]);
       chomp($gz[$i+1]);



open (OUTFILE, ">>$scriptDir/$fastqName.sh");

print OUTFILE "#!/bin/bash\n" ;
print OUTFILE "#BSUB -J Run.RNA_Quality_RSEM.$fastqName\n" ;
print OUTFILE "#BSUB -n 8\n" ;
print OUTFILE "#BSUB -P DMPPHDAAZ\n" ;
print OUTFILE "#BSUB -W 14:00\n" ;
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

print OUTFILE "time rsem-calculate-expression -p 16 --paired-end $gz[$i] $gz[$i+1] --bowtie2 --estimate-rspd $annot/Homo_sapiens.GRCh37.69.dna.primary_assembly_ref $rsemDir/$fastqName/$fastqName\n\n\n";

	}
close OUTFILE;
}
