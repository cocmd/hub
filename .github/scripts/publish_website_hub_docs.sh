#!/bin/bash

set -e

WEBSITE_PATH="../cocmd-website"

cocmd install -y ./packages
# rm -rf $WEBSITE_PATH/docs/packages/from_hub/
mkdir -p $WEBSITE_PATH/docs/packages/from_hub/

# for each direcroty in packages, run cocmd docs <package>
for dir in ./packages/*/
do
    dir=${dir%*/}
    dir=${dir##*/}

    echo "# $dir" > $WEBSITE_PATH/docs/packages/from_hub/$dir.md

    # echo to the md file a link to the github of this package in "https://github.com/cocmd/hub/tree/master/packages/$dir"
    echo "### [ Package Source Code ]("https://github.com/cocmd/hub/tree/master/packages/$dir")" >> $WEBSITE_PATH/docs/packages/from_hub/$dir.md

    echo ":::info How To Install?" >> $WEBSITE_PATH/docs/packages/from_hub/$dir.md
    echo "run in terminal:" >> $WEBSITE_PATH/docs/packages/from_hub/$dir.md
    echo "\`\`\`bash" >> $WEBSITE_PATH/docs/packages/from_hub/$dir.md
    echo "cocmd install -y $dir" >> $WEBSITE_PATH/docs/packages/from_hub/$dir.md
    echo "\`\`\`" >> $WEBSITE_PATH/docs/packages/from_hub/$dir.md
    echo ":::" >> $WEBSITE_PATH/docs/packages/from_hub/$dir.md

    cocmd docs $dir --raw-markdown>> $WEBSITE_PATH/docs/packages/from_hub/$dir.md
    
    # remove line that contains "location:" from md file
    sed -i '' '/location:/d' $WEBSITE_PATH/docs/packages/from_hub/$dir.md

    # remove original title
    sed -i '' "/## $dir/d" $WEBSITE_PATH/docs/packages/from_hub/$dir.md

    # set var with home_dir ~ and dir '.cocmd/runtime/$dir'
    
    home_dir=$(echo ~)
    runtime_dir="./packages/$dir"
    # get the absolute path
    abs_dir=$(cd "$runtime_dir" && pwd)

    # replace in md file all abs_dir with '.'
    sed -i '' "s|$abs_dir|.|g" $WEBSITE_PATH/docs/packages/from_hub/$dir.md
    

    
done

cd $WEBSITE_PATH
sed "s/CURRENT_STABLE_VERSION = .*/CURRENT_STABLE_VERSION = 'v$VERSION';/" docusaurus.config.js > docusaurus.config.js.bak
mv docusaurus.config.js.bak docusaurus.config.js

yarn
yarn build && yarn deploy

echo "Committing version update"
git add docusaurus.config.js
git commit -m "Version bump: $VERSION"

echo "Pushing changes"
git push


echo "Done!"