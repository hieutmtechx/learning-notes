# Hugo Notes Site — Design Spec

**Date:** 2026-06-23  
**Status:** Approved

---

## Overview

A personal learning journal published as a static site using Hugo + PaperMod, hosted on Cloudflare Pages. Covers multiple topics (machine learning, programming, books, ideas). Content is organized by both category and date, with search, tags, series, and table of contents enabled.

---

## Architecture

- **Framework:** Hugo (latest stable)
- **Theme:** PaperMod, added as a git submodule (`themes/PaperMod/`)
- **Hosting:** Cloudflare Pages — connected to the GitHub repo, auto-deploys on push to `main`
- **Setup method:** Hugo CLI + git submodule (no Go modules required)

---

## Project Structure

```
ml-notes/
├── archetypes/
│   └── default.md              # post template with pre-filled frontmatter
├── assets/
│   └── css/
│       └── extended/
│           └── custom.css      # light color/style overrides (loaded by PaperMod automatically)
├── content/
│   ├── posts/                  # all notes, organized by topic subfolder
│   │   ├── machine-learning/
│   │   ├── programming/
│   │   ├── books/
│   │   └── learning/
│   └── search.md               # required by PaperMod for client-side search
├── static/                     # favicon, images
├── themes/
│   └── PaperMod/               # git submodule
├── hugo.toml                   # site config
└── .gitmodules
```

---

## Hugo Configuration (`hugo.toml`)

```toml
baseURL = "https://your-site.pages.dev/"
title   = "Learning Journal"
theme   = "PaperMod"
paginate = 10
enableRobotsTXT = true

[params]
  homeInfoParams    = { Title = "Learning Journal", Content = "Notes on things I'm figuring out." }
  ShowReadingTime   = true
  ShowShareButtons  = false
  ShowPostNavLinks  = true
  ShowBreadCrumbs   = true
  ShowCodeCopyButtons = true
  ShowToc           = true
  TocOpen           = false

[taxonomies]
  category = "categories"
  tag      = "tags"
  series   = "series"

[outputs]
  home = ["HTML", "RSS", "JSON"]   # JSON required for PaperMod search

[menu]
  [[menu.main]]
    name = "Posts"
    url  = "/posts/"
  [[menu.main]]
    name = "Categories"
    url  = "/categories/"
  [[menu.main]]
    name = "Tags"
    url  = "/tags/"
  [[menu.main]]
    name = "Series"
    url  = "/series/"
  [[menu.main]]
    name = "Search"
    url  = "/search/"
```

---

## Light Customization (`assets/css/extended/custom.css`)

Two CSS rules only — PaperMod loads this file automatically:

```css
:root {
  --accent: #0d9488;   /* teal accent — swap freely */
}

.post-content {
  max-width: 780px;    /* slightly wider than PaperMod default for readability */
}
```

Dark/light mode is handled by PaperMod's built-in toggle (moon/sun icon in the nav).

---

## Post Archetype (`archetypes/default.md`)

```markdown
---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
categories: []
tags: []
series: []
draft: true
---
```

New notes are created with `hugo new posts/<topic>/<note-name>.md`.

---

## Features Enabled

| Feature | How |
|---|---|
| Search | `content/search.md` + `outputs.home` includes JSON |
| Tags page | `/tags/` taxonomy route, linked in nav |
| Categories page | `/categories/` taxonomy route, linked in nav |
| Series | `series` taxonomy; posts link to sibling entries |
| Table of contents | `ShowToc = true`, collapsed by default (`TocOpen = false`) |
| Reading time | `ShowReadingTime = true` |
| Code copy buttons | `ShowCodeCopyButtons = true` |
| RSS feed | Included in `outputs.home` |

---

## Visual Design (mockup approved)

Palette (dark mode default, light mode via toggle):

| Token | Dark | Light |
|---|---|---|
| Ground | `#171C2A` | `#F5F6FA` |
| Text | `#E2E8F4` | `#1A2038` |
| Accent (amber/teal) | `#F0B040` | `#B8781A` |
| Accent-2 (blue) | `#6090E0` | `#3A6BC4` |

The visual mockup is implemented in PaperMod via `custom.css`. The approved mockup used system fonts (SF Pro / Segoe UI Variable) at weight 800 for display headings, with monospace for all metadata (dates, tags, reading time).

---

## Deployment

1. Push repo to GitHub
2. Connect to Cloudflare Pages → select repo → set build command: `hugo` → publish dir: `public`
3. Set `HUGO_VERSION` environment variable to match local Hugo version
4. Every push to `main` triggers a rebuild and deploy

---

## Out of Scope

- Comments system
- Analytics
- Custom domain (can be added later via Cloudflare DNS)
- CMS / admin UI
