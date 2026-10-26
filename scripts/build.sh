#!/usr/bin/env sh
# Build every class deck (dark slides, light slides, an A4 handout with notes), then the documents.
set -eu
cd "$(dirname "$0")/.."
mkdir -p build
for deck in decks/class*.typ; do
  name=$(basename "$deck" .typ)
  typst compile --root . "$deck" "build/$name.pdf"
  typst compile --root . --input projection=light "$deck" "build/$name-light.pdf"
  typst compile --root . --input mode=handout "$deck" "build/$name-handout.pdf"
done
typst compile --root . docs/prereading.typ build/prereading.pdf
for doc in docs/deeper/class*.typ; do
  typst compile --root . "$doc" "build/deeper-$(basename "$doc" .typ).pdf"
done
typst compile --root . docs/proposal.typ build/proposal.pdf
typst compile --root . docs/proposal-blank.typ build/proposal-blank.pdf
