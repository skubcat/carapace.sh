#!/bin/sh 
HEADER="<!DOCTYPE html><html lang ='en'><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1'><title>bugman.cooking</title><link rel='stylesheet' href='styles.css'><meta name='vegnav' content='pagedesc'></head>"
FILES=$(ls -1 ./recipes/*)

clean_up() {
    echo "Cleaning up!"
    if [ -d "./generated-website" ]; then
        rm -R ./generated-website
    fi
    if [ ! -d "./recipes" ]; then
        mkdir ./recipes
    fi
    mkdir ./generated-website
    mkdir ./generated-website/tags
    cp ./styles.css ./generated-website
}

gen_header() {
    {
    if [ "$2" = 1 ]; then
	echo "$HEADER"
    fi
    echo "<header> <a href='https://bugmancooking.neocities.org/'>[bugman.cooking]</a>"
    echo "<a href='https://bugmancooking.neocities.org/about'>[about]</a>"
    echo "<a href='https://bugmancooking.neocities.org/tags'>[recipe tags]</a>"
    echo "<a href='https://github.com/skubcat/carapace.sh/archive/refs/heads/main.zip'>[download]</a>"
    echo  "</header>" 
    } >> "$1"
}

gen_recipes() {
    echo "Generating recipes"
    for f in $FILES
    do
	RECIPE_NAME="$(head -1 "recipes/$(echo "$f" | sed 's/\.\/recipes\///')")"
	echo "Recipe name check at line 36: $RECIPE_NAME"
        RECIPE_CLEANED_FILENAME=$(echo "$f" | sed 's/\.\/recipes\///; s/.txt//') # The filename of a recipe without its extension.
        INGREDIENTS=$(awk -v RS='' 'NR==2' "$f" | sed 's/^/<li>/g; s/$/<\/li>/')
        INSTRUCTIONS=$(awk -v RS='' 'NR==3' "$f" | sed 's/^/<li>/g; s/$/<\/li>/')
        GEN_PATH="./generated-website/$RECIPE_CLEANED_FILENAME.html"
        gen_header "$GEN_PATH"
        {
	echo  "$HEADER"
        echo  "<main><article><h1>$RECIPE_NAME</h1><h3>Ingredients</h3>"
        echo  "<ul>$INGREDIENTS</ul>" 
        echo  "<h3>Instructions</h3><ul>$INSTRUCTIONS</ul></main></article>"
        } >> "$GEN_PATH"
    done
}

gen_nav() {
    echo "Generating nav-menu"
    echo  "$HEADER" >> ./generated-website/index.html
    echo  "<header><nav><ul>" >> ./generated-website/index.html

    RECIPE_COUNT=0
    for f in $FILES
    do
        RECIPE_COUNT=$((RECIPE_COUNT + 1))
        RECIPE_CLEANED_FILENAME=$(echo "$f" | sed 's/\.\/recipes\///; s/.txt//') 
        recipetitle=$(head -q -n 1 "$f")
        echo  "<li><a href='./$RECIPE_CLEANED_FILENAME.html'>$recipetitle</a></li>" >> ./generated-website/index.html
    done

    echo "</nav></ul></header>" >> ./generated-website/index.html
}

gen_tags() {
    HEADER="<!DOCTYPE html><html lang ='en'><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1'><title>bugman.cooking</title><link rel='stylesheet' href='../styles.css'><meta name='vegnav' content='pagedesc'></head>"
    echo "$HEADER" >> ./generated-website/tags.html

    gen_header ./generated-website/tags.html

    for f in $FILES; do
        recipetags=$(sed -n '2p' "$f")
	for i in $recipetags; do
	        RESULT="${RESULT:+${RESULT} }${i}" # https://chris-lamb.co.uk/posts/joining-strings-in-posix-shell
	        echo "Recipe tags: $RESULT"
	done
    done
   
    PLACEHOLDER=$(echo "${RESULT}" | sed 's/ /\n/g' | sort | uniq) # Get only unique tags, the set of all tags. We don't want repeats.
    echo "Placeholder value at line 82: $PLACEHOLDER"

    {
    echo "<main><article>"
    echo "<h1>Tags</h1>"
    echo "<ul>"
    } >> ./generated-website/tags.html
    for i in $PLACEHOLDER; do # Generate each tag page.
	echo "Placeholder value at line 91: $i"
	echo "$HEADER" >> "./generated-website/tags/$i.html"
	gen_header "./generated-website/tags/$i.html"
	{
	echo "<article>"
	echo "<h1>$(echo "$i" | sed 's/_/ /g; s/\b\(.\)/\u\1/g')</h1>"
	echo "<nav><ul>"
	} >> "./generated-website/tags/$i.html"
	echo "<li><a href='tags/$i.html'>$(echo "$i" | sed 's/_/ /g; s/\b\(.\)/\u\1/g')</a></li>" >> ./generated-website/tags.html
	echo "$i"
    done

    echo "</ul>" >> ./generated-website/tags.html
    echo "</main></article>" >> ./generated-website/tags.html

    for f in $FILES; do # Fetch each tag from the plain txt files, then proceed to fill in information for tag pages.
        recipetags=$(sed -n '2p' "$f")
        RECIPE_CLEANED_FILENAME=$(echo "$f" | sed 's/\.\/recipes\///; s/.txt//') 
        recipetitle=$(head -q -n 1 "$f")
	echo "File: $f"
	for i in $recipetags; do
	    {
	    echo "<li><a href='../$RECIPE_CLEANED_FILENAME.html'>$recipetitle</a></li>"
	    } >> "./generated-website/tags/$i.html"
	done
    done

    for i in $ARRAYHOLDER; do
    {
	echo "</nav</ul>"
	echo "</article>"
    } >> "./generated-website/tags/$i.html"
    done
}

gen_footer() {
    echo "Generating footer"
    {
    echo  "<footer>"
    echo  "<p>Powered by <a href='https://github.com/skubcat/carapace.sh'>carapace.sh</a></p><br>"
    echo  "</footer>"
    } >> "$1"
}

gen_about() {
    {
        echo  "<article>"
        echo  "<p>I made this website in response to https://based.cooking/. They kept rejecting vegan recipes, and they said it would best fit {bugman.cooking} instead. I needed a css/html only website for vegan recipes, so I made it!</p><br>"
        echo  "<p>Forever without ads, bloat, or javascript. <3</p><br>"
        echo  "<p>Submit recipes <a href='https://github.com/skubcat/carapace.sh'>{here}</a><p>"
        echo  "</article>"
    } >> ./generated-website/about.html
}

clean_up
gen_header "./generated-website/index.html" 1
gen_header "./generated-website/about.html" 1
gen_recipes
gen_nav
gen_about
gen_footer "./generated-website/index.html"
gen_footer "./generated-website/about.html"
gen_tags
