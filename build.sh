#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BUILD="$ROOT/build"
MEDIA="$ROOT/media"

cd "$ROOT"

mkdir -p "$MEDIA"

[ -f "$MEDIA/sample1.jpg" ] || curl -fsSL "https://picsum.photos/seed/1/400/600" -o "$MEDIA/sample1.jpg"
[ -f "$MEDIA/sample2.jpg" ] || curl -fsSL "https://picsum.photos/seed/2/400/400" -o "$MEDIA/sample2.jpg"
[ -f "$MEDIA/sample3.jpg" ] || curl -fsSL "https://picsum.photos/seed/3/400/500" -o "$MEDIA/sample3.jpg"
[ -f "$MEDIA/sample4.jpg" ] || curl -fsSL "https://picsum.photos/seed/4/800/400" -o "$MEDIA/sample4.jpg"

rm -rf "$BUILD"
mkdir -p "$BUILD"

pandoc \
    --from=markdown-citations-implicit_figures \
    --to=latex \
    --standalone \
    --template="$ROOT/content.tex" \
    --lua-filter="$ROOT/layout.lua" \
    --resource-path="$ROOT" \
    --output="$BUILD/portfolio.tex" \
    "$ROOT/content.md"

latexmk \
    -pdf \
    -interaction=nonstopmode \
    -halt-on-error \
    -file-line-error \
    -outdir="$BUILD" \
    "$BUILD/portfolio.tex"
