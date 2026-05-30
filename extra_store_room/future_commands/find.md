# Shell Find Techniques for Android Debugging

```bash
#!/bin/bash
sourcePath="/mnt/usb/"
extensions=('*.java' '*.c' '*.sh' '*.pl' '*.md')
matchFgColor='141'
matchBgColor='234'
searchPattern='(AT[+%$]([A-Z]+|\d+)|PACMD|weaver)'
outputDir=~/search_index
mkdir -p "$outputDir"
fileExtArgs=()
for ext in "${extensions[@]}"; do
    fileExtArgs+=(-g "$ext")
done
rg --max-filesize 1M \
    -N \
    --stats \
    --no-column \
    --colors "match:fg:$matchFgColor" \
    --colors "match:bg:$matchBgColor" \
    "${fileExtArgs[@]}" \
    "$searchPattern" "$sourcePath" | while read -r line; do
        # Extract just the file name from the line
        filename=$(basename "$line")
        echo -e "$filename"
        if [[ "$line" =~ PACMD ]]; then
            echo "$filename" >> "$outputDir/pacmd.log"
        elif [[ "$line" =~ AT[+%$] ]]; then
            echo "$filename" >> "$outputDir/at-commands.log"
        elif [[ "$line" =~ weaver ]]; then
            echo "$filename" >> "$outputDir/weaver-commands.log"
        fi
        # Add similar if conditions for other patterns
done
```
