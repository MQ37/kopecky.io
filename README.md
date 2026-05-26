# kopecky.io

Personal website at [kopecky.io](https://kopecky.io).

## How it works

Zero-dependency static site generator — just `bash`, `cat`, `sed`, and `find`.

- **`templates/header.html`** — everything before the page content (`<!DOCTYPE html>` … `<main>`)
- **`templates/footer.html`** — everything after (`</main>` … `</html>`)
- **`pages/*.html`** — content snippets (just the body, no `<html>` wrapper)
- **`static/`** — CSS, images, and other assets (copied as-is to `public/`)
- **`build.sh`** — concatenates header + page + footer for every `.html` in `pages/`, auto-generates the blog index from post metadata
- **`deploy.sh`** — builds then `rsync`s `public/` to a server

### Page metadata

Each page starts with HTML comments for metadata:

```html
<!-- title: My Post Title -->
<!-- date: 2024-03-30 -->
```

`build.sh` reads these to set the `<title>` tag and auto-generate the blog listing.

### Workflow

```bash
./build.sh                           # build the site → public/
./deploy.sh user@host:/var/www/...   # build + deploy
```

### Adding a blog post

1. Create `pages/blog/YYYY-MM-DD-slug.html` with `<!-- title: -->` and `<!-- date: -->` metadata
2. Run `./build.sh` — the blog index updates automatically
3. Deploy
