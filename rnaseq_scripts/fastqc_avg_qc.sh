for i in $(ls */*/fastqc_data.txt)

do

filename=$(grep "Filename" $i | awk '{print $2}' | sed 's/.fastq.gz//')
#filename=$(grep "Filename" $i | awk '{print $2}')
#echo $filename
#filename=$(grep "Filename" $i | awk '{print $2}' | sed 's/.fastq.gz//')

echo $filename $(awk '/>>Per base sequence quality/{flag=1;next}/>>END_MODULE/{flag=0}flag' $i | awk '{ total += $2 } END { print total/NR }')

done 
