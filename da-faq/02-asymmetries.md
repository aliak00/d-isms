# Asymmetries

## Difference between local and global functions

### Global functions can be called with UFCS, locals cannot

The reason is that member functions need to take priority when you call them, but also local functions need to be prioritised when you call them. So if UFCS were allowed with local functions, which would take priority?

**Fix**: You can use an identity template to explicitly call the local function

```d
alias I(T...) = T[0];

struct S {
  void f() { "member".writeln; }
}

void main() {
  void f(S s) { "local".writeln; }

  S s;
  s.I!f; // local
  s.f; // member
}
```

### Global functions can be overloaded, local ones cannot.

This is not a technical limitation though. It seems more of just a matter of someone needing to implement it. There’s also a proposal on how to do it here: https://issues.dlang.org/show_bug.cgi?id=12578.

Global functions can be forward declared, local ones cannot. This is because the initializers for variables in function scope are guaranteed to run in sequential order. So this will break that:

```d
int first() { return second(); }
int x = first();   // x depends on y, which hasn't been declared yet.
int y = x + 1;
int second() { return y; }
```

**Hack-Fix**: for mutually recursive function you can use templates:

```d
void foo() {
  void bar()(){ baz(); }
  void baz(){ bar(); }
}
```

## Difference between local and inner aggregates

Local aggregates require a pointer to their local context before they can be instantiated. This means that this will not work:

```d
void make(T)() { return new T; }
void local() {
  class C {}
  auto c = make!C; // error, context is needed to new nested class
}
```

**Fix**: Mark the aggregate as static and it won’t need a context

## Different scopes for different attributes

When you specify an attribute it applies to the entire scope it’s declared… sometimes. `@safe`, `private`, `public`, `@trusted` on the top of the file will apply all the way down. But, `pure`, `@nogc`, will only apply up to a non-function declaration scope. So:

```d
@safe:
pure:
void safeAndPure() {}
struct S {
  void safeButNotPure() {}
}
```

## New only works on some things

You can call new on classes, dynamic arrays, or structs, is what D claims. But you can also call new on function pointers:

```d
alias T = int function(int);
auto a = new T;
```

But not on delegates, static arrays or associative arrays:

```d
alias T = int delegate(int);
auto a = new T;
```

Error: new can only create structs, dynamic arrays or class objects, not int delegate(int)'s
