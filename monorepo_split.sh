#!/usr/bin/env bash

# Split monorepo and push all master branches and all tags into specified remotes
# You must first build the monorepo via "monorepo_build" (uses same parameters as "monorepo_split")
# If subdirectory is not specified remote name will be used instead
#
# Usage: monorepo_split.sh <remote-name>[:<subdirectory>] <remote-name>[:<subdirectory>] ...
#
# Example: monorepo_split.sh main-repository package-alpha:packages/alpha package-beta:packages/beta

# Check provided arguments
if [ "$#" -lt "1" ]; then
    echo 'Please provide at least 1 remote for splitting'
    echo 'Usage: monorepo_split.sh <remote-name>[:<subdirectory>] <remote-name>[:<subdirectory>] ...'
    echo 'Example: monorepo_split.sh main-repository package-alpha:packages/alpha package-beta:packages/beta'
    exit
fi
# Get directory of the other scripts
MONOREPO_SCRIPT_DIR=$(dirname "$0")
# Wipe original refs (possible left-over back-up after rewriting git history)
$MONOREPO_SCRIPT_DIR/original_refs_wipe.sh
for PARAM in $@; do
    # Parse parameters in format <remote-name>[:<subdirectory>]
    PARAM_ARR=(${PARAM//:/ })
    REMOTE=${PARAM_ARR[0]}
    SUBDIRECTORY=${PARAM_ARR[1]}
    if [ "$SUBDIRECTORY" == "" ]; then
        SUBDIRECTORY=$REMOTE
    fi
    # Rewrite git history of master branch
    echo "Splitting repository for the remote '$REMOTE'"
    git checkout master
    $MONOREPO_SCRIPT_DIR/rewrite_history_from.sh $SUBDIRECTORY master $(git tag)
    if [ $? -eq 0 ]; then
        echo "Pushing branch 'master' and all tags into '$REMOTE'"
        git push --tags $REMOTE master
    else
        echo "Splitting repository for the remote '$REMOTE' failed! Not pushing anything into it."
    fi
    # Restore the original history from back-up
    $MONOREPO_SCRIPT_DIR/original_refs_restore.sh
done

