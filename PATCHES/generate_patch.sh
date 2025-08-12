#!/bin/bash
# After copying files into your repo, run:
git checkout -b sprint/1-full
git add .
git commit -m "sprint(1): backend+frontend+ci+promo"
git format-patch origin/develop --stdout > sprint1-full.patch
echo "Patch written to sprint1-full.patch"
