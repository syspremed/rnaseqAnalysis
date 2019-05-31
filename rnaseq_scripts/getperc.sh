for i in $(ls */*_flagstat_mapping)
do

echo $i $(grep "paired (" $i | awk '{print $6}' | sed 's/(//g;s/%//g')

done
