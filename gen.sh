#!/bin/bash 

HEADER="<!DOCTYPE html><html lang ='en'><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1'><title>nav-menu</title><link rel='stylesheet' href='./styles.css'><meta name='vegnav' content='pagedesc'></head>"
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
    echo "$HEADER" >> ./generated-website/nav-menu.html
    echo "<header><nav><ul>" >> ./generated-website/nav-menu.html

    RECIPE_COUNT=0
    for f in $FILES
    do
        RECIPE_COUNT=$((RECIPE_COUNT + 1))
        RECIPE_CLEANED_FILENAME=$(echo "$f" | sed 's/\.\/recipes\///; s/.txt//') 
        recipetitle=$(head -q -n 1 "$f")
        echo "<li><a href='./$RECIPE_CLEANED_FILENAME.html'>$recipetitle</a></li>" >> ./generated-website/nav-menu.html
    done

    echo "</nav></ul></header><p>Recipes: $RECIPE_COUNT</p>" >> ./generated-website/nav-menu.html
}

clean_up
gen_recipes
gen_nav
