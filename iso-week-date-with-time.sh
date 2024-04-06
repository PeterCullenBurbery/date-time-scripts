#!/bin/bash

# Parse key=value arguments with an optional -- prefix
for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)
   VALUE="${ARGUMENT#*=}"

   # Remove the -- prefix from the key if present
   [[ $KEY == --* ]] && KEY=${KEY:2}

   export "$KEY"="$VALUE"
done

# Use the 'date' variable if provided, default to 'now' otherwise
if [ ! -z "$date" ]; then
    input_date="$date"
else
    input_date="now"
fi

# Format the date as ISO week date with time
formatted_date=$(date -d "$input_date" '+%G-W%V-%u %H.%M.%S %Z')

echo "$formatted_date"
