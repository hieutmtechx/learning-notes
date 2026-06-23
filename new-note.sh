#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== New Learning Note ==="
echo ""

# Title
read -p "Title: " TITLE
if [ -z "$TITLE" ]; then
  echo "Title is required."
  exit 1
fi

# Category
echo ""
echo "Category:"
echo "  1) Machine Learning"
echo "  2) Programming"
echo "  3) Books"
echo "  4) Ideas"
echo "  5) Other"
read -p "Choose (1-5): " CAT_CHOICE

case $CAT_CHOICE in
  1) CATEGORY="Machine Learning"; FOLDER="machine-learning" ;;
  2) CATEGORY="Programming";      FOLDER="programming" ;;
  3) CATEGORY="Books";            FOLDER="books" ;;
  4) CATEGORY="Ideas";            FOLDER="ideas" ;;
  *)
    read -p "Category name: " CATEGORY
    FOLDER=$(echo "$CATEGORY" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
    ;;
esac

# Tags
echo ""
read -p "Tags (comma-separated, e.g. python, nlp): " TAGS_RAW

# Series
echo ""
read -p "Series (optional, press Enter to skip): " SERIES

# Build slug from title
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
DATE=$(date +%Y-%m-%d)
FILE="$PROJECT_DIR/content/posts/$FOLDER/$SLUG.md"

mkdir -p "$PROJECT_DIR/content/posts/$FOLDER"

# Format tags as TOML array
if [ -n "$TAGS_RAW" ]; then
  TAGS_LINE=$(echo "$TAGS_RAW" | sed 's/^[[:space:]]*//' | sed 's/,[[:space:]]*/", "/g' | sed 's/^/"/' | sed 's/$/"/')
  TAGS_LINE="[$TAGS_LINE]"
else
  TAGS_LINE="[]"
fi

# Format series as TOML array
if [ -n "$SERIES" ]; then
  SERIES_LINE="[\"$SERIES\"]"
else
  SERIES_LINE="[]"
fi

cat > "$FILE" << EOF
---
title: "$TITLE"
date: $DATE
categories: ["$CATEGORY"]
tags: $TAGS_LINE
series: $SERIES_LINE
draft: true
---

## Summary

<!-- One paragraph: what is this and why does it matter? -->

## Key Concepts

<!-- The main ideas, defined clearly -->

## Notes

<!-- Your detailed notes -->

## Takeaways

<!-- What you'll actually remember -->

## References

<!-- Papers, articles, books, links -->
EOF

echo ""
echo "Created: content/posts/$FOLDER/$SLUG.md"
echo ""

# Open in editor
if command -v code &> /dev/null; then
  read -p "Open in VS Code? (y/n): " OPEN
  if [ "$OPEN" = "y" ]; then
    code "$FILE"
  fi
elif [ -n "$EDITOR" ]; then
  read -p "Open in $EDITOR? (y/n): " OPEN
  if [ "$OPEN" = "y" ]; then
    $EDITOR "$FILE"
  fi
fi

echo ""
echo "When ready to publish:"
echo "  1. Change 'draft: true' to 'draft: false'"
echo "  2. git add content/posts/$FOLDER/$SLUG.md"
echo "  3. git commit -m \"add: $TITLE\""
echo "  4. git push"
