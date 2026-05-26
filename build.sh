#!/bin/bash
set -euo pipefail

echo "==> Cleaning public/"
rm -rf public

echo "==> Copying static assets"
cp -r static public

# ── Build all content pages ────────────────────────────────────────────────

echo "==> Building pages"
find pages -name '*.html' | while read -r page; do
    rel="${page#pages/}"
    slug="${rel%.html}"

    # Root index → public/index.html; everything else → public/<slug>/index.html
    if [ "$rel" = "index.html" ]; then
        out="public/index.html"
    else
        out="public/$slug/index.html"
    fi
    mkdir -p "$(dirname "$out")"

    # Extract title from <!-- title: ... --> meta comment
    title=$(grep -oP '(?<=^<!-- title: ).*(?= -->)' "$page" | head -1 || true)
    title="${title:-kopecky.io}"

    # Append site suffix for <title> tag unless it's the home page
    if [ "$rel" != "index.html" ]; then
        title_tag="$title – kopecky.io"
    else
        title_tag="$title"
    fi

    # Inject title into header, then concatenate
    sed "s|{{TITLE}}|$title_tag|" templates/header.html > /tmp/_header.html
    cat /tmp/_header.html "$page" templates/footer.html > "$out"

    echo "  /$slug/  ($title_tag)"
done

# ── Auto-generate blog index ───────────────────────────────────────────────

echo "==> Generating blog index"

# Build the listing content
{
    echo '<!-- title: Blog -->'
    echo '<h1>Posts</h1>'
    echo '<ul>'
} > /tmp/_blog-index.html

# Sort blog posts by date descending (newest first)
for post in $(find pages/blog -name '*.html' -not -name 'index.html' | sort -r); do
    title=$(grep -oP '(?<=^<!-- title: ).*(?= -->)' "$post" | head -1 || echo "Untitled")
    date=$(grep -oP '(?<=^<!-- date: ).*(?= -->)' "$post" | head -1 || true)
    slug=$(basename "$post" .html)
    echo "<li><a href=\"/blog/$slug/\">$title</a>$( [ -n "$date" ] && echo " <small>$date</small>")</li>" >> /tmp/_blog-index.html
done

echo '</ul>' >> /tmp/_blog-index.html

# Build the index page through the same pipeline
title="Blog – kopecky.io"
sed "s|{{TITLE}}|$title|" templates/header.html > /tmp/_header.html
mkdir -p public/blog
cat /tmp/_header.html /tmp/_blog-index.html templates/footer.html > public/blog/index.html

echo "==> Done — site built in public/"
