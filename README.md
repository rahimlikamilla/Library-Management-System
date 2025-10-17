### Library Management System
A simple **Prolog-based** library system that stores books, tracks borrowed items, and checks availability and due dates.

## Overview
This project implements a small **knowledge base in Prolog** to simulate a library system.
It allows adding books, borrowing and returning them, and determining whether a book is available or overdue.


## Core Predicates
- Search books by ID, title, or author
- Borrow and return books
- Check availability (is_available/1)
- Compute due dates (calculate_due_date/6)
- Detect overdue books (is_due/1)

## Core Predicates
| Predicate                   | Description                            |
| --------------------------- | -------------------------------------- |
| `book(ID, Title, Author).`  | Stores book information                |
| `borrow(BookID, MemberID).` | Borrows a book if available            |
| `return(BookID).`           | Returns a borrowed book                |
| `is_available(BookID).`     | True if the book isn’t borrowed        |
| `is_due(BookID).`           | True if the book’s due date has passed |
