# D(a)-faq

## Purpose

This document tries to highlight any gotchas, inconsistencies, and just general WTFs in the D programming language. I try and provide explanations of possible or workarounds if known and the reasons for the way things are.

## How to read

Fixes are marked as “Fix” if the fix is for a language feature that works "properly" - i.e as expected, sanely, rationally, intuitively. And “Hack-Fix”s are for deficiencies that can be fixed properly in the compiler but have not been (for whatever reason).

Throughout this document, the different sections will be marked with one of the following:

* **Gotcha**: this is something to watch out for.
* **WAT**: this is just something ridiculous, i.e. a wtf.
* **Trap**: this is bad language design that leads to bugs.
