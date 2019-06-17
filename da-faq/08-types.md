# What the type!

## Enums with base types

```d
auto f(short s) { return "short"; }
auto f(int i) { return "int"; }
enum : int { a = 0 }
enum A : int { a = 0 }

void main() {
  writeln(f(a));
  writeln(f(A.a));
  auto a = A.a;
  writeln(a);
}
```

What would the above print? Not what you expect. This is what happens:

* `a` is a constant of type `int`.
* `A.a` is a constant of type `A`.

`f(int)` matches `a` perfectly, right from the get go, without any conversions necessary.

`A.a` doesn’t fit in either `f(int)`, `f(short)` so it has to go through some conversions to get in to any of them, and all conversions are folded in to one conversion so converting from `A` -> `int` -> `short` carried the same weight as converting from `A` -> `int`. And so we have two conversion paths from an `A` type, and one can be given to `f(int)` and the other to `f(short)`. Now D chooses the most specialized one, which is the short version.

## Bools are numbers, kinda.

In a nutshell booleans are there to represent values in logic and boolean algebra, and are mostly used for making decisions. I.e. control flow. The main operations on booleans are conjunction (&), disjunction (|), and negation (!).

Numbers, on the other hand, are the values used in elementary algebra, have operations like multiplication, and addition, and are used to count, measure, and label.

You’d think that D would treat them differently because they are different. But, the developers of D have decided that it’s easier to be implemented as an integer, but without operations like `++`/`--`/`+=`/etc, so it’s restricted. And in doing so, you essentially have a 1-bit data type, not a boolean.

And because of VRP, and how implicit conversions are collapsed, we also end up with this wonderfully backwards situation:

```d
void f(bool) { writeln("bool"); }
void f(short) { writeln("short"); }

enum A { a, b, c }

void main() {
  A.a.f; // prints “bool”
  A.b.f; // prints “bool”
  A.c.f; // prints “short”
}
```
