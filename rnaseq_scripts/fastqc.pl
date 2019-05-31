#!/usr/bin/perl

#Usage : perl fastqc.pl <fastqc results dir> <scripts dir where you can run> <fastq_path_file>


$fastqc_results = "$ARGV[0]"; # Give your fastqc results directory 

$fastqcScriptDir = "$ARGV[1]"; # number of jobs file will be created for all samples


open(FH,"$ARGV[2]") || die($!); # Give all fastq file paths file here 

@gz = <FH>;



# Reading a path for fastq file that is created

for($i=0;$i<@gz;$i++){ # Reading all fastq files
#print "$gz[$i]\n";

#if($gz[$i] =~ /(.*)\/(.*)\/(.*)-(.*).fq.gz/){

if($gz[$i] =~ /(.*)\/(.*).fq.gz/){

chomp($gz[$i]);

#print "$gz[$i]\n";

$fastqcDir="$2";

open (OUTFILE, ">>$fastqcScriptDir/$fastqcDir.sh"); # Writing the scripts for each sample into fastqScriptDir


print OUTFILE "#!/bin/bash\n" ;
#=head
print OUTFILE "#BSUB -J Runfastqc\n" ;
print OUTFILE "#BSUB -n 1\n" ;
print OUTFILE "#BSUB -P DMPCTFAAE\n" ;
print OUTFILE "#BSUB -W 8:00\n" ;
print OUTFILE "#BSUB -o RSEM.fastqc.output.%J\n" ;
print OUTFILE "#BSUB -e RSEM.fastqc.error.%J\n" ;
print OUTFILE "#BSUB -R span[hosts=1]\n\n\n" ;
#=cut

print OUTFILE "module load fastqc/0.11.4\n" ;


print OUTFILE "# Fastqc steps\n" ;
print OUTFILE "mkdir -p $fastqc_results/$fastqcDir\n" ;  # Creating the result dir for each sample
print OUTFILE "fastqc $gz[$i] -o $fastqc_results/$fastqcDir\n" ; # Running fastqc
print OUTFILE "unzip $fastqc_results/$fastqcDir/*.zip -d $fastqc_results/$fastqcDir\n" ; # Extracting the fastqc result
print OUTFILE "echo $fastqcDir \$(zcat < $gz[$i] | echo \$((`wc -l`/4))) >> $fastqc_results/fastq_read_counts\n\n\n" ; # counting of the reads for each samples  

        }
        close OUTFILE;

        }
