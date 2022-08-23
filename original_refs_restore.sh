#!/usr/bin/env bash

# Restore original git history after rewrite
#
# Usage: original_refs_restore.sh

echo 'Restoring the original history back-up'
# Original refs after history rewrite are stored in refs/original/
for ORIGINAL_REF in $(git for-each-ref --format="%(refname)" refs/original/); do
    git update-ref "${ORIGINAL_REF#refs/original/}" $ORIGINAL_REF
    git update-ref -d $ORIGINAL_REF
done
git reset --hard

