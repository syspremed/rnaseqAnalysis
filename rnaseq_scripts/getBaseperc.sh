for i in $(ls */*_RNA*.txt)
do

file="${i%.*}"
#echo "$file"
echo "$file" >> ribosomal
sed -n '/PF_BASES/{n;p;}' $i | awk -F "\t" '{print $11*100}' | sort >> ribosomal

echo "$file" >> coding
sed -n '/PF_BASES/{n;p;}' $i | awk -F "\t" '{print $12*100}' | sort >> coding

echo "$file" >> utr
sed -n '/PF_BASES/{n;p;}' $i | awk -F "\t" '{print $13*100}' | sort >> utr

echo "$file" >> intronic
sed -n '/PF_BASES/{n;p;}' $i | awk -F "\t" '{print $14*100}' | sort >> intronic

echo "$file" >> intergenic
sed -n '/PF_BASES/{n;p;}' $i | awk -F "\t" '{print $15*100}' | sort >> intergenic


done

perl -i -p -e 's/_Metrics\n/\t/' ribosomal
perl -i -p -e 's/_Metrics\n/\t/' coding
perl -i -p -e 's/_Metrics\n/\t/' utr
perl -i -p -e 's/_Metrics\n/\t/' intronic
perl -i -p -e 's/_Metrics\n/\t/' intergenic

#echo "Samples	Ribosomal	Coding	UTR	Intronic	Intergenic" > rna_species_human_panNet_mayo_kannan_84.txt
paste ribosomal coding utr intronic intergenic | awk '{print $1"\t"$2"\t"$4"\t"$6"\t"$8"\t"$10}'      
