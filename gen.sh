#!/bin/bash 

HEADER="<!DOCTYPE html><html lang ='en'><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1'><title>bugman.cooking</title><link rel='stylesheet' href='./styles.css'><meta name='vegnav' content='pagedesc'></head>"
FILES=$(ls -1 ./recipes/*)

clean_up() {
    echo "Cleaning up!"
    if [ -d "./generated-website" ]; then
        rm -R ./generated-website
    fi
    mkdir ./generated-website
    if [ ! -d "./recipes" ]; then
        mkdir ./recipes
    fi
    cp ./styles.css ./generated-website
}

gen_header() {
    {
    echo "<header> <a href="https://bugmancooking.neocities.org/">[bugman.cooking]</a>"
    echo "<a href="https://bugmancooking.neocities.org/about">[about]</a>"
    echo "<a href="https://bugmancooking.neocities.org/dlsite">[download]</a>"
    echo "</header>" 
    } >> ./generated-website/index.html
}

gen_recipes() {
    echo "Generating recipes"
    for f in $FILES
    do
        RECIPE_NAME=$(head -1 recipes/$(echo "$f" | sed 's/\.\/recipes\///'))
        RECIPE_CLEANED_FILENAME=$(echo "$f" | sed 's/\.\/recipes\///; s/.txt//') # The filename of a recipe without its extension.
        INGREDIENTS=$(awk -v RS='' 'NR==2' "$f" | sed 's/^/<li>/g; s/$/<\/li>/')
        INSTRUCTIONS=$(awk -v RS='' 'NR==3' "$f" | sed 's/^/<li>/g; s/$/<\/li>/')
        GEN_PATH="./generated-website/$RECIPE_CLEANED_FILENAME.html"
        { echo "$HEADER"  
        echo "<main><article><h1>$RECIPE_NAME</h1><h2>Ingredients</h2>"
        echo "<ul>$INGREDIENTS</ul>" 
        echo "<h2>Instructions</h2><ul>$INSTRUCTIONS</ul></main></article>"
        } >> "$GEN_PATH"
    done
}

## Gen navmenu ##

gen_nav() {
    echo "Generating nav-menu"
    echo "$HEADER" >> ./generated-website/index.html
    echo "<header><nav><ul>" >> ./generated-website/index.html

    RECIPE_COUNT=0
    for f in $FILES
    do
        RECIPE_COUNT=$((RECIPE_COUNT + 1))
        RECIPE_CLEANED_FILENAME=$(echo "$f" | sed 's/\.\/recipes\///; s/.txt//') 
        recipetitle=$(head -q -n 1 "$f")
        echo "<li><a href='./$RECIPE_CLEANED_FILENAME.html'>$recipetitle</a></li>" >> ./generated-website/index.html
    done

    echo "</nav></ul></header>" >> ./generated-website/index.html
}

gen_footer() {
    echo "Generating footer"
    {
    echo "<footer>"
    echo "<p>Powered by <a href="https://github.com/skubcat/carapace.sh">carapace.sh</a></p><br>"
    echo "</footer>"
    } >> ./generated-website/index.html
}

clean_up
gen_header
gen_recipes
gen_nav
gen_footer
