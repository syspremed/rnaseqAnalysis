# Create the folder structure and put respective scripts to the folders

path=$1

mkdir -p $path/scripts/fastqcScriptDir $path/scripts/rsemScriptDir $path/scripts/samtoolScriptDir $path/scripts/rna_quality/rna_rsem_scriptDir $path/scripts/rna_quality/picardDir $path/results/QC $path/results/rsem_results $path/results/rna_rsem_results

cp -r fastqc.pl rsem_run.pl samtool_run.pl $path/scripts

cp -r getperc.sh $path/results/rsem_results 

cp -r getperc.sh $path/results/rna_rsem_results

cp -r fastqc_avg_qc.sh $path/results/QC

cp -r rna_rsem_run.pl picard_run.pl $path/scripts/rna_quality

cp -r getBaseperc.sh $path/results/rna_rsem_results

