#!/bin/bash

# Minify HTML files in the redirect directory
# This script requires html-minifier-terser to be installed globally
# npm install -g html-minifier-terser

echo "Minifying HTML files..."

# Minify the redirect.html file
html-minifier-terser \
  --collapse-whitespace \
  --remove-comments \
  --remove-redundant-attributes \
  --remove-script-type-attributes \
  --remove-tag-whitespace \
  --use-short-doctype \
  --minify-css true \
  --minify-js true \
  -o /tmp/redirect.html \
  /home/thomas/Programming/BijbelQuiz/websites/bijbelquiz.app/redirect.html

# Move minified file back
mv /tmp/redirect.html /home/thomas/Programming/BijbelQuiz/websites/bijbelquiz.app/redirect.html

echo "HTML minification complete!"