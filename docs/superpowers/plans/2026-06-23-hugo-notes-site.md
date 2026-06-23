# Hugo Notes Site Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and deploy a personal learning journal using Hugo + PaperMod on Cloudflare Pages, with search, categories, tags, series, TOC, and a light CSS customization.

**Architecture:** Static Hugo site using PaperMod as a git submodule. All content lives under `content/posts/<topic>/`. Features are wired entirely through `hugo.toml` params and a two-rule `custom.css`. Cloudflare Pages builds from `main` on every push.

**Tech Stack:** Hugo (v0.112+), PaperMod theme, Git, GitHub, Cloudflare Pages

## Global Constraints

- Hugo v0.112 or later required — verify with `hugo version` before starting
- PaperMod added as git submodule only — no Go modules
- All posts go in `content/posts/<topic>/` — never flat in `content/`
- `draft: true` posts are excluded from production builds (`hugo --minify`)
- Update `baseURL` in `hugo.toml` to the actual Cloudflare Pages URL before first deploy

---

### Task 1: Initialize Hugo site and git repository

**Files:**
- Create: `.gitignore`
- Create: `hugo.toml` (scaffold — replaced fully in Task 3)
- Create: `archetypes/`, `content/`, `layouts/`, `static/`, `themes/` (Hugo scaffold dirs)

**Interfaces:**
- Produces: valid Hugo scaffold that runs with `hugo server` (empty site, no theme yet)

- [ ] **Step 1: Verify Hugo is installed**

```bash
hugo version
```

Expected: `hugo v0.1xx.x ...` — must be v0.112 or later.
If not installed: `brew install hugo` (Mac) or see https://gohugo.io/installation/

- [ ] **Step 2: Initialize git repo**

```bash
cd /Users/jasper/Downloads/jasper/Hobby/Project/ml-notes
git init
```

Expected: `Initialized empty Git repository in .../ml-notes/.git/`

- [ ] **Step 3: Scaffold Hugo site**

```bash
hugo new site . --force
```

Expected output ends with: `Congratulations! Your new Hugo site was created in .../ml-notes/`

The `--force` flag allows scaffolding into a non-empty directory (the existing `docs/` folder is preserved).

- [ ] **Step 4: Verify scaffold**

```bash
ls
```

Expected to see: `archetypes  content  docs  hugo.toml  layouts  static  themes`

- [ ] **Step 5: Create .gitignore**

Write `/Users/jasper/Downloads/jasper/Hobby/Project/ml-notes/.gitignore`:

```
public/
resources/
.hugo_build.lock
.DS_Store
```

- [ ] **Step 6: Commit scaffold**

```bash
git add .
git commit -m "chore: initialize Hugo site scaffold"
```

Expected: commit lists new files including `hugo.toml`, `archetypes/default.md`, `.gitignore`.

---

### Task 2: Add PaperMod as git submodule

**Files:**
- Create: `themes/PaperMod/` (via git submodule)
- Create: `.gitmodules` (auto-created)
- Modify: `hugo.toml` — add minimal `theme` and `baseURL` entries

**Interfaces:**
- Consumes: initialized git repo from Task 1
- Produces: `hugo server` renders PaperMod default at `http://localhost:1313` with no errors

- [ ] **Step 1: Add PaperMod submodule**

```bash
git submodule add --depth=1 https://github.com/adityatelange/hugo-PaperMod themes/PaperMod
```

Expected: clones PaperMod into `themes/PaperMod/`, creates `.gitmodules`.

- [ ] **Step 2: Set minimal hugo.toml**

Replace the entire contents of `hugo.toml` with:

```toml
baseURL = "http://localhost:1313/"
title   = "Learning Journal"
theme   = "PaperMod"
```

- [ ] **Step 3: Start dev server and verify theme loads**

```bash
hugo server
```

Open `http://localhost:1313` in a browser.
Expected: PaperMod default homepage renders (blank content is fine). No error lines in terminal output.

Stop server: `Ctrl+C`

- [ ] **Step 4: Commit**

```bash
git add .gitmodules themes/PaperMod hugo.toml
git commit -m "chore: add PaperMod theme as git submodule"
```

---

### Task 3: Full site configuration

**Files:**
- Modify: `hugo.toml` — replace minimal config with full production config

**Interfaces:**
- Consumes: PaperMod theme from Task 2
- Produces: site with nav menu (Posts / Categories / Tags / Series / Search), taxonomies enabled, JSON output for search, all PaperMod display params set

- [ ] **Step 1: Write full hugo.toml**

Replace the entire contents of `hugo.toml` with:

```toml
baseURL = "http://localhost:1313/"
title   = "Learning Journal"
theme   = "PaperMod"

paginate        = 10
enableRobotsTXT = true

[params]
  env         = "production"
  description = "Notes on things I'm figuring out."
  homeInfoParams = { Title = "Learning Journal", Content = "Notes on machine learning, programming, books, and ideas — written down while they're still fresh." }

  ShowReadingTime     = true
  ShowShareButtons    = false
  ShowPostNavLinks    = true
  ShowBreadCrumbs     = true
  ShowCodeCopyButtons = true
  ShowToc             = true
  TocOpen             = false
  ShowFullTextinRSS   = false

[taxonomies]
  category = "categories"
  tag      = "tags"
  series   = "series"

[outputs]
  home = ["HTML", "RSS", "JSON"]

[[menu.main]]
  name   = "Posts"
  url    = "/posts/"
  weight = 1

[[menu.main]]
  name   = "Categories"
  url    = "/categories/"
  weight = 2

[[menu.main]]
  name   = "Tags"
  url    = "/tags/"
  weight = 3

[[menu.main]]
  name   = "Series"
  url    = "/series/"
  weight = 4

[[menu.main]]
  name   = "Search"
  url    = "/search/"
  weight = 5
```

- [ ] **Step 2: Verify in browser**

```bash
hugo server
```

Open `http://localhost:1313`. Check:
- Nav bar shows: Posts · Categories · Tags · Series · Search
- Homepage shows the info card with "Learning Journal" heading
- Moon/sun theme toggle appears in nav (PaperMod built-in)
- No build errors in terminal

Stop server: `Ctrl+C`

- [ ] **Step 3: Commit**

```bash
git add hugo.toml
git commit -m "feat: full site config — taxonomies, nav, PaperMod params"
```

---

### Task 4: Search page

PaperMod's client-side search requires a dedicated page with `layout: "search"` and the JSON output already set in Task 3.

**Files:**
- Create: `content/search.md`

**Interfaces:**
- Consumes: `outputs.home = ["HTML", "RSS", "JSON"]` from Task 3
- Produces: functional search page at `/search/`

- [ ] **Step 1: Create search page**

Write `content/search.md`:

```markdown
---
title: "Search"
layout: "search"
summary: "search"
placeholder: "Search notes..."
---
```

- [ ] **Step 2: Verify search page**

```bash
hugo server
```

Open `http://localhost:1313/search/`.
Expected: a search input field renders. The page is titled "Search". (No results yet — that's fine.)

Stop server: `Ctrl+C`

- [ ] **Step 3: Commit**

```bash
git add content/search.md
git commit -m "feat: add PaperMod search page"
```

---

### Task 5: Post archetype

**Files:**
- Modify: `archetypes/default.md` — replace Hugo default with custom frontmatter template

**Interfaces:**
- Produces: `hugo new posts/<topic>/<name>.md` creates a file pre-filled with `categories`, `tags`, `series`, and `draft: true`

- [ ] **Step 1: Write archetype**

Replace the entire contents of `archetypes/default.md` with:

```
---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
categories: []
tags: []
series: []
draft: true
---
```

- [ ] **Step 2: Test archetype output**

```bash
hugo new posts/machine-learning/test-post.md
```

Expected: creates `content/posts/machine-learning/test-post.md`.

Open the file and verify:
- `title` is `"Test Post"` (generated from the filename)
- `date` is today's date
- `categories`, `tags`, `series` are `[]`
- `draft: true` is present

- [ ] **Step 3: Clean up test file**

```bash
rm content/posts/machine-learning/test-post.md
rmdir content/posts/machine-learning
rmdir content/posts
```

- [ ] **Step 4: Commit**

```bash
git add archetypes/default.md
git commit -m "feat: post archetype with categories/tags/series frontmatter"
```

---

### Task 6: Light CSS customization

PaperMod auto-loads any file at `assets/css/extended/custom.css`. Two rules only: teal accent color and wider content column.

**Files:**
- Create: `assets/css/extended/custom.css`

**Interfaces:**
- Produces: teal accent (`#0d9488`) applied site-wide; post content max-width set to 780px

- [ ] **Step 1: Create directory and file**

```bash
mkdir -p assets/css/extended
```

Write `assets/css/extended/custom.css`:

```css
:root {
  --accent: #0d9488;
}

.post-content {
  max-width: 780px;
}
```

- [ ] **Step 2: Verify in browser**

```bash
hugo server
```

Open `http://localhost:1313`. Hover over a nav link or any interactive element.
Expected: hover/focus color is teal (`#0d9488`), not PaperMod's default blue.

Stop server: `Ctrl+C`

- [ ] **Step 3: Commit**

```bash
git add assets/css/extended/custom.css
git commit -m "feat: custom CSS — teal accent, wider content column"
```

---

### Task 7: Sample content

Create four real posts so every feature — TOC, tags, categories, series navigation — can be verified end-to-end before deploying.

**Files:**
- Create: `content/posts/machine-learning/gradient-descent.md`
- Create: `content/posts/machine-learning/understanding-attention.md`
- Create: `content/posts/programming/rust-ownership.md`
- Create: `content/posts/books/four-thousand-weeks.md`

**Interfaces:**
- Consumes: archetype from Task 5 (use `hugo new` or write files directly — both produce the same result)
- Produces: populated site with working taxonomy pages, series prev/next links, TOC on each post

- [ ] **Step 1: Create ML post 1 (series)**

Write `content/posts/machine-learning/gradient-descent.md`:

```markdown
---
title: "Gradient Descent: From Intuition to Implementation"
date: 2026-05-19
categories: ["Machine Learning"]
tags: ["optimization", "math", "deep-learning"]
series: ["ML Fundamentals"]
draft: false
---

## What is Gradient Descent?

Gradient descent minimizes a function by iteratively stepping in the direction of steepest descent.

## The Intuition

Imagine standing blindfolded on a hilly landscape. You want the lowest point. Strategy: feel the slope, step downhill, repeat.

## The Math

Given a loss function $L(\theta)$, update parameters as:

$$\theta = \theta - \alpha \nabla L(\theta)$$

where $\alpha$ is the learning rate.

## A Simple Implementation

```python
def gradient_descent(grad_fn, theta, lr=0.01, steps=100):
    for _ in range(steps):
        theta -= lr * grad_fn(theta)
    return theta
```

## Key Takeaways

- Learning rate too large: diverges. Too small: slow.
- Vanilla GD uses the full dataset per step.
- Mini-batch GD is the practical default in deep learning.
```

- [ ] **Step 2: Create ML post 2 (same series)**

Write `content/posts/machine-learning/understanding-attention.md`:

```markdown
---
title: "Understanding Attention Mechanisms in Transformers"
date: 2026-06-18
categories: ["Machine Learning"]
tags: ["transformers", "deep-learning", "nlp"]
series: ["ML Fundamentals"]
draft: false
---

## The Core Idea

Attention lets each token in a sequence "look at" every other token and decide how much to weight its contribution.

## Query, Key, Value

Three projections of the input:

- **Query (Q):** what this token is looking for
- **Key (K):** what each token offers
- **Value (V):** what each token contributes if selected

$$\text{Attention}(Q, K, V) = \text{softmax}\!\left(\frac{QK^T}{\sqrt{d_k}}\right)V$$

## Why It Works

The dot product of Q and K measures compatibility. Dividing by $\sqrt{d_k}$ prevents softmax from saturating in high dimensions.

## Multi-Head Attention

Running attention in parallel across multiple learned subspaces lets the model attend to different relationship types simultaneously.

## Key Takeaways

- Self-attention is permutation-equivariant — position encodings add order.
- Complexity is O(n²) in sequence length.
- The transformer replaced recurrence with attention entirely.
```

- [ ] **Step 3: Create programming post**

Write `content/posts/programming/rust-ownership.md`:

```markdown
---
title: "Rust Ownership: Mental Models That Finally Clicked"
date: 2026-06-10
categories: ["Programming"]
tags: ["rust", "systems", "memory"]
series: []
draft: false
---

## The Problem Rust Solves

Memory bugs — use-after-free, double-free, dangling pointers — are the root of most systems security vulnerabilities. Rust eliminates them at compile time.

## The Three Rules

1. Every value has exactly one owner.
2. When the owner goes out of scope, the value is dropped.
3. Ownership can be transferred (moved) or temporarily lent (borrowed).

## What Finally Clicked

I stopped thinking about the borrow checker as a restriction and started thinking about it as a guarantee: **there is always exactly one place responsible for cleanup**.

## Borrowing in Practice

```rust
fn print_len(s: &String) {   // borrows, does not own
    println!("{}", s.len());
}

fn main() {
    let s = String::from("hello");
    print_len(&s);            // s still valid after this
    println!("{}", s);        // works fine
}
```

## Key Takeaways

- Move semantics are the default; `clone()` is explicit.
- `&T` is a shared borrow (read-only); `&mut T` is exclusive.
- The borrow checker enforces all of this at compile time, not runtime.
```

- [ ] **Step 4: Create books post**

Write `content/posts/books/four-thousand-weeks.md`:

```markdown
---
title: "Notes: Four Thousand Weeks — Oliver Burkeman"
date: 2026-06-03
categories: ["Books"]
tags: ["philosophy", "time"]
series: []
draft: false
---

## The Core Argument

The average human life is about four thousand weeks. You will never clear your to-do list. Accepting this — really accepting it — changes how you make decisions.

## What Struck Me

The book's central move is to reframe the productivity trap: the reason "getting on top of things" never works is that it's based on a false premise — that a state of being on top of things is achievable.

## Useful Takeaways

**Choose what to fail at.** Every yes is a no to everything else. Better to choose consciously than to let urgency choose for you.

**Settle.** The fear of commitment is partly fear of cutting off alternatives. But an unchosen life — kept permanently open — is its own trap.

**Resist instrumentalizing leisure.** Rest that exists to make you more productive isn't rest.

## Verdict

Not a productivity book — an argument against the productivity mindset. Worth reading slowly.
```

- [ ] **Step 5: Verify all features in browser**

```bash
hugo server
```

Check each URL:

| URL | Expected |
|-----|----------|
| `http://localhost:1313/posts/` | All 4 posts listed with dates and reading times |
| `http://localhost:1313/categories/` | Machine Learning, Programming, Books |
| `http://localhost:1313/tags/` | Tag cloud: transformers, rust, philosophy, etc. |
| `http://localhost:1313/series/` | ML Fundamentals series |
| Open either ML post | Table of Contents sidebar shows headings |
| Open either ML post | Series nav at bottom links to sibling post |
| `http://localhost:1313/search/` | Typing "rust" returns the Rust post |

Stop server: `Ctrl+C`

- [ ] **Step 6: Commit**

```bash
git add content/
git commit -m "feat: sample posts — ML series, Programming, Books"
```

---

### Task 8: Production build and Cloudflare Pages deployment

**Files:**
- Modify: `hugo.toml` — update `baseURL` to the actual Cloudflare Pages domain

**Interfaces:**
- Consumes: complete site from Tasks 1–7
- Produces: live site on Cloudflare Pages, auto-deploying from `main`

- [ ] **Step 1: Create a GitHub repository**

On GitHub, create a new repository named `ml-notes` (public or private).

- [ ] **Step 2: Push to GitHub**

```bash
git remote add origin https://github.com/<your-username>/ml-notes.git
git branch -M main
git push -u origin main
```

- [ ] **Step 3: Connect to Cloudflare Pages**

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com) → **Pages** → **Create a project**
2. Choose **Connect to Git** → select the `ml-notes` repo
3. Set build configuration:
   - **Framework preset:** Hugo
   - **Build command:** `hugo --minify`
   - **Build output directory:** `public`
4. Add environment variable:
   - Key: `HUGO_VERSION`
   - Value: output of `hugo version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'` (e.g. `0.147.0`)
5. Click **Save and Deploy**

After the first deploy, Cloudflare assigns a URL like `ml-notes-abc123.pages.dev`.

- [ ] **Step 4: Update baseURL**

In `hugo.toml`, replace the `baseURL` line:

```toml
baseURL = "https://ml-notes-abc123.pages.dev/"
```

(Use the actual domain Cloudflare assigned.)

- [ ] **Step 5: Verify production build locally**

```bash
hugo --minify
```

Expected: `Total in XXX ms` with no errors.

Then confirm search will work in production:

```bash
ls public/index.json
```

Expected: file exists. (This is what powers client-side search.)

- [ ] **Step 6: Push baseURL update**

```bash
git add hugo.toml
git commit -m "chore: set production baseURL to Cloudflare Pages domain"
git push
```

Expected: Cloudflare Pages detects the push and triggers a new build automatically.

- [ ] **Step 7: Verify live site**

Open `https://ml-notes-abc123.pages.dev/` and check:

| Check | Expected |
|-------|----------|
| Homepage | Info card renders with "Learning Journal" heading |
| Nav | Posts / Categories / Tags / Series / Search all link correctly |
| Search | `/search/` — typing "rust" returns the Rust post |
| Post page | TOC, reading time, breadcrumbs, code copy buttons all visible |
| Series | ML posts show series navigation at the bottom |
| Theme toggle | Moon/sun button in nav switches dark ↔ light |
