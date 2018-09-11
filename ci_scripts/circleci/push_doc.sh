#!/bin/bash
# This script is meant to be called in the "deploy" step defined in 
# circle.yml. See https://circleci.com/docs/ for more details.
# The behavior of the script is controlled by environment variable defined
# in the circle.yml in the top level folder of the project.

set -e

MSG="Pushing the docs for revision for branch: $CIRCLE_BRANCH, commit $CIRCLE_SHA1"

GENERATED_DOC_DIR=$1
GENERATED_DOC_DIR=$(readlink -f $GENERATED_DOC_DIR)

# Clone the docs repo if it isnt already there
cd $HOME
if [ ! -d $DOC_REPO ];
    then git clone "git@github.com:$USERNAME/"$DOC_REPO".git";
fi

cd $DOC_REPO
git branch gh-pages
git checkout -f gh-pages
git reset --hard origin/gh-pages
git clean -dfx

for name in $(ls -A $HOME/$DOC_REPO); do
    case $name in
        .nojekyll) # So that github does not build this as a Jekyll website.
        ;;
        circle.yml) # Config so that build gh-pages branch.
        ;;
        .git)
        ;;
        *)
        git rm -rf $name
        ;;
    esac
done

# Copy the new build docs
cp -R $GENERATED_DOC_DIR ./

git config --global user.email $EMAIL
git config --global user.name $USERNAME
git config push.default matching
git add -f ./
git commit -m "$MSG"
git push -f origin gh-pages
if [ $? -ne 0 ]; then
    echo "Pushing docs failed"
    echo
    exit 1
fi

echo $MSG 
