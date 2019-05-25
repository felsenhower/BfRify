#!/usr/bin/env bash

set -e

input_pdf="$1"
output_pdf="$2"

usage() {
  echo 'usage: ./BfRify.sh <input pdf> <output pdf>'
}

if [ -z "$input_pdf" ] ; then
  echo 'Must specify input file.',
  usage
  exit 1
fi

if [ -z "$output_pdf" ] ; then
  echo 'Must specify output file.'
  usage
  exit 1
fi

tempdir="$(mktemp -d)"

convert -density 150 \
        -background white \
        -alpha remove \
        -quality 25% \
        "$input_pdf" \
        "$tempdir"'/page_%09d.jpeg'

for f in "$tempdir"'/page_'*'.jpeg' ; do
  convert -composite "$f" 'watermark.png' "$tempdir"'/temp.jpeg'
  mv "$tempdir"'/temp.jpeg' "$f"
done

convert "$tempdir"'/page_'*'.jpeg' "$tempdir"'/temp.pdf'

pdftk "$tempdir"'/temp.pdf' multibackground "$input_pdf" output "$output_pdf"

# rm -rf "$tempdir"
