#!/bin/bash
#code that counts reccurence of politician names in Ynet articles

# Define the website URL for Ynet articles on politicians
site="https://ynetnews.com/category/3082"

# Retrieve data from the specified URL and extract unique article URLs
data=$(wget --no-check-certificate -O - "$site" 2>/dev/null)
articles=$(echo "$data" |
 grep -oP "https://(www.)?ynetnews.com/article/[0-9a-zA-Z]+" | sort | uniq)

# Count the total number of unique article URLs and save it in results.csv
echo "$(echo "$articles" | wc -l)" > results.csv

# Array containing names of politicians to search for in the articles
name_array=("Netanyahu" "Gantz" "Bennett" "Peretz")
# Array to store the recurrence count of each politician's name in the articles
recurrence=(0 0 0 0)
count=0

# Loop through each article URL, retrieve its content, count the recurrence of names, and print results
echo "$articles" | 
		while read -r  line;
		do

		# Retrieve the content of each article from its URL
		article=$(wget --no-check-certificate -O - "$line" 2>/dev/null)	

			# Iterate through the politician names and count their recurrence in the article
			for i in ${!recurrence[@]}; do
				recurrence[$i]=$(echo "$article" |
				 grep ${name_array[$i]} | wc -l)
				
				# Accumulate the total count of name recurrences
				count=$((count + ${recurrence[$i]}))
			done

				# If no recurrence of names found, add a placeholder in results.csv
				if [[ $count -eq 0 ]]
				then 
					echo "$line, -" >> results.csv
				else
					# Add article URL and politician recurrence counts to results.csv
					echo -n "$line" >> results.csv
					for i in ${!recurrence[@]}; do
						echo -n ", ${name_array[$i]}, ${recurrence[$i]}" \
						>> results.csv
					done
					echo "" >> results.csv
				fi
				
		# Reset count and recurrence arrays for the next article
		count=0
		recurrence=(0 0 0 0)
			
		done
