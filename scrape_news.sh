#!/bin/bash
#code that counts reccurence of politician names in Ynet articles
site="https://ynetnews.com/category/3082"

#saves list of uniqe URL's and counts them.
data=$(wget --no-check-certificate -O - "$site" 2>/dev/null)
articles=$(echo "$data" |
 grep -oP "https://(www.)?ynetnews.com/article/[0-9a-zA-Z]+" | sort | uniq)
echo "$(echo "$articles" | wc -l)" > results.csv

name_array=("Netanyahu" "Gantz" "Bennett" "Peretz")
recurrence=(0 0 0 0)
count=0

#retrieve data from each article, count reccurence of names, and print results
echo "$articles" | 
		while read -r  line;
		do

		article=$(wget --no-check-certificate -O - "$line" 2>/dev/null)	

			for i in ${!recurrence[@]}; do
				recurrence[$i]=$(echo "$article" |
				 grep ${name_array[$i]} | wc -l)
				
				count=$((count + ${recurrence[$i]}))
			done

				if [[ $count -eq 0 ]]
				then 
					echo "$line, -" >> results.csv
				else
					echo -n "$line" >> results.csv
					for i in ${!recurrence[@]}; do
						echo -n ", ${name_array[$i]}, ${recurrence[$i]}" \
						>> results.csv
					done
					echo "" >> results.csv
				fi
				
		count=0
		recurrence=(0 0 0 0)
			
		done
