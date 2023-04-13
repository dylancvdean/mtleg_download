#!/bin/bash

echo "Enter hearing video link"
read hearing
wget --user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:118.0) Gecko/20100101 Firefox/118.0" -O html $hearing
grep m3u8 html > html2

# Read the file and search for the "Url" property
url=$(grep -oP '(?<="Url":")[^"]*' html2)

# Print the URL
echo $url > html
rm html2
grep -oP '.*(?=\/playlist\.m3u8)' html > html.tmp && mv html.tmp html
mv html url

url=$(cat url)

i=1

while true; do
  file_url="$url/media_$i.ts"
  wget -q --spider "$file_url"
  
  if [ $? -ne 0 ]; then
    break
  fi
  
  wget -q -O "$i.ts" "$file_url"
  
  i=$((i+1))
done
for file in *.ts; do [[ ${file%.*} =~ ^.{1,4}$ ]] && mv "$file" "$(printf "%05d%s" "${file%.*}" "${file##*.}")"; done

ffmpeg -i "concat:$(printf '%s|' *.ts)" -c copy output.mp4

# Clean up the .ts files
rm *.ts
