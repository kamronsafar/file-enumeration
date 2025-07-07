read -p "Enter the website URL (e.g. https://example.com): " url
mkdir -p downloads

echo "scaning page..."
html=$(curl -s "$url")

declare -A patterns=(
    [HTML]='href="\K[^"]+\.html?'
    [PHP]='href="\K[^"]+\.php'
    [CSS]='href="\K[^"]+\.css'
    [JS]='src="\K[^"]+\.js'
    [IMAGES]='src="\K[^"]+\.(png|jpg|jpeg|gif|svg|webp)'
    [AUDIO]='src="\K[^"]+\.(mp3|wav|ogg)'
    [VIDEO]='src="\K[^"]+\.(mp4|webm|avi)'
    [DOCS]='href="\K[^"]+\.(pdf|docx|xlsx|pptx)'
    [ARCHIVES]='href="\K[^"]+\.(zip|rar|tar\.gz|bak)'
    [CONFIG]='href="\K[^"]+\.(xml|json|env|txt)'
    [FONTS]='href="\K[^"]+\.(woff2?|ttf)'
)




declare -a choices
echo -e "\n📂 File types found:"
i=1
for type in "${!patterns[@]}"; do
    matches=$(echo "$html" | grep -oP "${patterns[$type]}" | cut -d'"' -f1 | sort -u)
    if [[ ! -z "$matches" ]]; then
        choices+=("$type")
        echo "$i) $type"
        ((i++))
    fi
done
echo "0) ALL"

read -p "Enter your choice(s) (e.g. 1 3 or 0): " -a selected

if [[ " ${selected[*]} " =~ " 0 " ]]; then
    selected=("${!choices[@]}")
fi

for index in "${selected[@]}"; do
    key="${choices[$((index-1))]}"
    echo -e "\n⬇️ Downloading $key filles..."
    matches=$(echo "$html" | grep -oP "${patterns[$key]}" | cut -d'"' -f1 | sort -u)
    
    for link in $matches; do
        if [[ $link != http* ]]; then
            full="$url/$link"
        else
            full="$link"
        fi
        echo " $full"
        wget -q --show-progress "$full" -P downloads/
    done
done

echo -e "\n All selected files downloaded to ./downloads/ enjoy bro"
