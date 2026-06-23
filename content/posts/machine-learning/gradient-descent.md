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
