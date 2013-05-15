#!/bin/bash

mkdir "no_copy"
mkdir "no_copy/assets"
mkdir "no_copy/assets/css"
mkdir "no_copy/assets/js"

mv "www/grunt.js" "no_copy/"
mv "www/node_modules/" "no_copy/node_modules"
mv "www/index.html" "no_copy/"
mv "www/inspector.sh" "no_copy/inspector.sh"
mv "www/README.md" "no_copy/README.md"
mv "www/tests/" "no_copy"

mv "www/assets/css/common.css" "no_copy/assets/css/"
mv "www/assets/css/glossary.css" "no_copy/assets/css/"
mv "www/assets/css/popups.css" "no_copy/assets/css/"

mv "www/assets/js/libs/" "no_copy/assets/js"
mkdir "www/assets/js/libs"
mv "no_copy/assets/js/libs/spin.min.js" "www/assets/js/libs/spin.min.js"
mv "www/src/" "no_copy"

mv "www/templates/" "no_copy"
mkdir "www/templates"
mv "no_copy/templates/thinclient.tpl.html" "www/templates/thinclient.tpl.html"

rm "www/min/thinclient.css"
rm "www/min/thinclient.js"

echo "All unnecessary files for the final build have been moved to 'no_copy' directory." 
echo "Run the 'restore.sh' script to move them back"

