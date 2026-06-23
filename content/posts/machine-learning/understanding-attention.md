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
