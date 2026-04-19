# 🤖 AI Assignments

This repository contains our Artificial Intelligence assignments implemented using **Prolog**.

---

## 📌 Assignment 1: Library System

A simple Prolog-based system that models:

* Students and books
* Borrowing records
* Book ratings
* Topics per book

### 🔹 Features

* List processing (member, append, length)
* Find borrowed books per student
* Count borrowers for each book
* Get most borrowed book
* Find top reviewer
* Analyze book topics

---

## 📌 Assignment 2:Rescue Robot Navigation (Prolog)

This project implements a rescue robot that navigates a grid-based environment using search algorithms in Prolog. The robot must avoid obstacles (debris and fire) and reach survivors efficiently.

The assignment is divided into two parts:

* **Part 1:** Uninformed search to reach the nearest survivor.
* **Part 2:** Informed search to maximize the number of rescued survivors.

---

## Grid Representation

The environment is represented as a 2D grid (list of lists):

* `r` → Robot (start position)
* `s` → Survivor (goal)
* `d` → Debris (blocked)
* `f` → Fire (blocked)
* `e` → Empty cell (free to move)

---

## Part 1 — Nearest Survivor

* Uses an **uninformed search algorithm** (e.g., UCS or BFS)
* Finds the **shortest path** to the nearest survivor
* Robot cannot revisit cells or pass obstacles
* Each move reduces battery by 10%

**Output:**

* Path
* Number of steps
* Remaining battery

---

## Part 2 — Maximize Survivors

* Uses **Greedy Best-First Search**
* Goal: rescue **maximum number of survivors**
* Not required to find optimal path
* Uses a heuristic function to guide search

**Output:**

* Path
* Number of steps
* Number of rescued survivors

---

## Contributors
- [Mohamed Ahmed](https://github.com/mohamed-hamza20)
- [Seif Waleed](https://github.com/Malware404seif)
