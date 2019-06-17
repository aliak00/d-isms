# WAT!

## You can call all functions as if they were setters

```d
writeln = “foo”; // prints "foo"
```

## Ref members share the same init value

Member variable that have class/struct declaration level initializers share the same instance of the value they’re initialized to.

```d
class A { int i; this(int i) { this.i = i; } }
class B {
  A a = new A(3);
}
auto b1 = new B();
auto b2 = new B();
assert(b1.a is b2.a); // wat
b1.a.i = 4;
assert(b2.a.i == 4); // wat
```

This is because field initializers are run at compile time. So `A a = new A()` is setting B.init.a to the compile time value of a reference type

## Inout changes your types for you

Inout is great in the simple case. But as soon as you start getting in to heavy template development, inout decides to go and do things behind your back.

## You cannot have a default struct constructor

Yep, you heard that right. D differentiates between initialization and construction. The former is a compile time concept and the latter is a runtime concept.

```d
struct S {
  int i = 4; // initialization
  this(int i) { // construction
    this.i = i;
  }
}
```

So when you instantiate an array:

```d
S[] a = new S[4];
```

It actually gets “initialized” and not constructed. So if you defined a default constructor, it would still get initialized and not constructed. E.g:

```d
struct S {
  int i;
  this() {
    this.i = 4;
  }
}

auto a = new S[10];
```

The variable a would not contain S’s with an i value of 4, but would contain S’s with an i value of 0 (which is the value of int.init).

**Hack-Fix**:

Make a factory function:

```d
S makeS() pure {
  S s;
  S.i = 4;
  return s;
}
```

### Default array construction (not initialization):

If you have a factory function, here is a small function that you can use to create an array using the factory function:

```d
auto factoryArray(alias maker)(int length) {
  import std.array: uninitializedArray;
  import std.algorithm: fill;
  import std.range: generate;
  alias T = typeof(maker());
  auto a = uninitializedArray!(T[])(length);
  fill(a, generate!maker);
  return a;
}

factoryArray!makeS(4).writeln; // [S(410), S(410), S(410), S(410)]
```
