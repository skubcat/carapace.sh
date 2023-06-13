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
	echo -n $HEADER    
    fi
    echo -n "<header> <a href="https://bugmancooking.neocities.org/">[bugman.cooking]</a>"
    echo -n "<a href="https://bugmancooking.neocities.org/about">[about]</a>"
    echo -n "<a href="https://bugmancooking.neocities.org/tags">[recipe tags]</a>"
    echo -n "<a href="https://github.com/skubcat/carapace.sh/archive/refs/heads/main.zip">[download]</a>"
    echo -n "</header>" 
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
        {
	echo -n "$HEADER"
        echo -n "<main><article><h1>$RECIPE_NAME</h1><h3>Ingredients</h3>"
        echo -n "<ul>$INGREDIENTS</ul>" 
        echo -n "<h3>Instructions</h3><ul>$INSTRUCTIONS</ul></main></article>"
        } >> "$GEN_PATH"
    done
}

gen_nav() {
    echo "Generating nav-menu"
    echo -n "$HEADER" >> ./generated-website/index.html
    echo -n "<header><nav><ul>" >> ./generated-website/index.html

    RECIPE_COUNT=0
    for f in $FILES
    do
        RECIPE_COUNT=$((RECIPE_COUNT + 1))
        RECIPE_CLEANED_FILENAME=$(echo "$f" | sed 's/\.\/recipes\///; s/.txt//') 
        recipetitle=$(head -q -n 1 "$f")
        echo -n "<li><a href='./$RECIPE_CLEANED_FILENAME.html'>$recipetitle</a></li>" >> ./generated-website/index.html
    done

    echo "</nav></ul></header>" >> ./generated-website/index.html
}

gen_tags() {
    HEADER="<!DOCTYPE html><html lang ='en'><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1'><title>bugman.cooking</title><link rel='stylesheet' href='../styles.css'><meta name='vegnav' content='pagedesc'></head>"
    echo $HEADER >> ./generated-website/tags.html
    gen_header ./generated-website/tags.html

    for f in $FILES; do
        recipetags=$(sed -n '2p' "$f")
	stringarray=($recipetags)
	for i in $recipetags; do
	    ARRAYHOLDER+=("$i")
	done
    done
   
    ARRAYHOLDER=$(echo ${ARRAYHOLDER[@]} | sed 's/ /\n/g' | sort | uniq) # Get only unique tags, the set of all tags. We don't want repeats.
    
    echo "<main><article>" >> ./generated-website/tags.html
    echo "<h1>Tags</h1>" >> ./generated-website/tags.html
    echo "<ul>" >> ./generated-website/tags.html
    
    for i in $ARRAYHOLDER; do # Generate each tag page.
	echo $HEADER >> ./generated-website/tags/$i.html
	gen_header ./generated-website/tags/$i.html
	{
	echo "<article>"
	echo "<h1>$(echo $i | sed 's/_/ /g; s/\b\(.\)/\u\1/g')</h1>"
	echo "<nav><ul>"
	} >> ./generated-website/tags/$i.html
	echo "<li><a href='tags/$i.html'>$(echo $i | sed 's/_/ /g; s/\b\(.\)/\u\1/g')</a></li>" >> ./generated-website/tags.html
	echo $i
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
	    } >> ./generated-website/tags/$i.html
	done
    done

    for i in $ARRAYHOLDER; do
    {
	echo "</nav</ul>"
	echo "</article>"
    } >> ./generated-website/tags/$i.html
    done
}

gen_footer() {
    echo "Generating footer"
    {
    echo -n "<footer>"
    echo -n "<p>Powered by <a href="https://github.com/skubcat/carapace.sh">carapace.sh</a></p><br>"
    echo -n "</footer>"
    } >> $1
}

gen_about() {
    {
        echo -n "<article>"
        echo -n "<p>I made this website in response to https://based.cooking/. They kept rejecting vegan recipes, and they said it would best fit {bugman.cooking} instead. I needed a css/html only website for vegan recipes, so I made it!</p><br>"
        echo -n "<p>Forever without ads, bloat, or javascript. <3</p><br>"
        echo -n "<p>Submit recipes <a href='https://github.com/skubcat/carapace.sh'>{here}</a><p>"
        echo -n "</article>"
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
