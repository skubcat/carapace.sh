Code to generate the vegetarian/vegan plain-text website [bugman.cooking](https://bugmancooking.neocities.org/).


---
Have a recipe? Send a pull request. The file must be in txt and in this format:

```
Recipe Name (1st line will *always* be recipe name)

Ingredients as a list seperated by newlines.
x
x
x


Instructions as a list seperated by newlines.
y
y
y
y

```

This would roughly output: 

``` html
<!DOCTYPE html>
<html lang ='en'>
<head>
  <meta charset='UTF-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1'>
  <title>Recipe Name</title>
  <link rel='stylesheet' href='./styles.css'>
  <meta name='description' content='Page description'>
</head>
<main>
  <article>
    <h1>Recipe Name</h1>
    <h2>Ingredients</h2>
    <ul>
      <li>Ingredients as a list seperated by newlines</li>
      <li>x</li>
      <li>x</li>
      <li>x</li>
     </ul>
     <h2>Preperation</h2>
     <ul>
      <li>Instructions as a list seperated by newlines.</li>
      <li>y</li>
      <li>y</li>
      <li>y</li>
     </ul>
    </article>
  </main>
  </article>
```
