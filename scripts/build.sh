#!/usr/bin/env sh
# Build every class deck: dark slides, light slides, and an A4 handout with notes.
set -eu
cd "$(dirname "$0")/.."
mkdir -p build
for deck in decks/class*.typ; do
  name=$(basename "$deck" .typ)
  typst compile --root . "$deck" "build/$name.pdf"
  typst compile --root . --input projection=light "$deck" "build/$name-light.pdf"
  typst compile --root . --input mode=handout "$deck" "build/$name-handout.pdf"
done
