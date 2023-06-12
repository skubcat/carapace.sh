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
    echo $HEADER
    echo "<header> <a href="https://bugmancooking.neocities.org/">[bugman.cooking]</a>"
    echo "<a href="https://bugmancooking.neocities.org/about">[about]</a>"
    echo "<a href="https://github.com/skubcat/carapace.sh/archive/refs/heads/main.zip">[download]</a>"
    echo "</header>" 
    
    } >> $1
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
        gen_header $GEN_PATH
        { echo "$HEADER"  
        echo "<main><article><h1>$RECIPE_NAME</h1><h3>Ingredients</h3>"
        echo "<ul>$INGREDIENTS</ul>" 
        echo "<h3>Instructions</h3><ul>$INSTRUCTIONS</ul></main></article>"
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
    } >> $1
}

gen_about() {
    {
        echo "<article>"
        echo "<p>I made this website in response to https://based.cooking/. They kept rejecting vegan recipes, and they said it would best fit {bugman.cooking} instead. I needed a css/html only website for vegan recipes, so I made it!</p><br>"
        echo "<p>Forever without ads, bloat, or javascript. <3</p><br>"
        echo "<p>Submit recipes <a href='https://github.com/skubcat/carapace.sh'>{here}</a><p>"
        echo "</article>"
    } >> ./generated-website/about.html

}

clean_up
gen_header "./generated-website/index.html"
gen_header "./generated-website/about.html"
gen_recipes
gen_nav
gen_about
gen_footer "./generated-website/index.html"
gen_footer "./generated-website/about.html"

