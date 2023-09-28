#!/bin/bash

set -e

WEBSITE_PATH="../cocmd-website"

cocmd install -y ./packages
rm -rf $WEBSITE_PATH/docs/hub/packages/
mkdir -p $WEBSITE_PATH/docs/hub/packages/

# for each direcroty in packages, run cocmd docs <package>
for dir in ./packages/*/
do
    dir=${dir%*/}
    dir=${dir##*/}

    echo "# $dir" > $WEBSITE_PATH/docs/hub/packages/$dir.md
    echo ":::info How To Install?" >> $WEBSITE_PATH/docs/hub/packages/$dir.md
    echo "run in terminal:" >> $WEBSITE_PATH/docs/hub/packages/$dir.md
    echo "\`\`\`bash" >> $WEBSITE_PATH/docs/hub/packages/$dir.md
    echo "cocmd install -y $dir" >> $WEBSITE_PATH/docs/hub/packages/$dir.md
    echo "\`\`\`" >> $WEBSITE_PATH/docs/hub/packages/$dir.md
    echo ":::" >> $WEBSITE_PATH/docs/hub/packages/$dir.md

    cocmd docs $dir --raw-markdown>> $WEBSITE_PATH/docs/hub/packages/$dir.md
    
    # remove line that contains "location:" from md file
    sed -i '' '/location:/d' $WEBSITE_PATH/docs/hub/packages/$dir.md

    # remove original title
    sed -i '' "/## $dir/d" $WEBSITE_PATH/docs/hub/packages/$dir.md
    
done


# sed "s/CURRENT_STABLE_VERSION = .*/CURRENT_STABLE_VERSION = 'v$VERSION';/" docusaurus.config.js > docusaurus.config.js.bak
# mv docusaurus.config.js.bak docusaurus.config.js

# yarn
# yarn build && yarn deploy

# echo "Committing version update"
# git add docusaurus.config.js
# git commit -m "Version bump: $VERSION"

# echo "Pushing changes"
# git push


echo "Done!"