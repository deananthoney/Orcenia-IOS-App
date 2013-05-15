#!/bin/bash

mv "no_copy/grunt.js" "www/grunt.js"
mv "no_copy/node_modules/" "www/node_modules" 
mv "no_copy/index.html" "www/index.html" 
mv "no_copy/inspector.sh" "www/inspector.sh"
mv "no_copy/README.md" "www/README.md"

mv no_copy/assets/css/* www/assets/css
mv no_copy/assets/js/libs/* www/assets/js/libs

mv no_copy/src/ www
mv no_copy/templates/* www/templates
mv no_copy/tests/ www

rm -rf -- "no_copy/"
rm -rf -- "www/min/"
rm "www/assets/css/thinclient.min.css"
rm "www/templates/thinclient.tpl.html"

echo "Files relocated in the 'move.sh' script have been restored"
