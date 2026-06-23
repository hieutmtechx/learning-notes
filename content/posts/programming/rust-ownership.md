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
