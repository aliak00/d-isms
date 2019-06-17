# Introspection traps

## VRP trap when introspecting on integral operations

```d
void main() {
  struct B {
    B opBinary(string op : "+")(int b) { return this; }
  }
  static if (is(typeof(B.init + size_t.init))) {
    size_t x = 1;
    B b1, b2;
    b1 = b2 + x; // fails here
  }
}
```

The thing is that `typeof(B.init + size_t.init)` passes so you expect that you can add a `B` to a `size_t`. But this only passes because of D’s VRP (Value Range Propagation) semantics, which states that if a value is in range, allow a cast. And it completely ignores the explicit type.

In the static if, `size_t.init` is a static value (0) that the compiler can prove is within range of an int. Since the compiler is very selective with when and where it performs flow analysis, it does not attempt to prove the failing case. 

**Hack-Fix**s:

1. If you want to properly check the static if use a lambda:

    ```d
    static if (is(typeof((B a, size_t b) => a + b))) { ... }
    ```

1. If you want VRP to do it’s thing inside the if then use an immutable:

    ```d
    immutable size_t x = 1;
    ```

1. Use `size_t.max` instead of `size_t.init`:

    ```d
    static if (is(typeof(B.init + size_t.max))) { ... }
    ```

## Hidden this member in inner structs

```d
void main() {
  struct B {
    int a;
    void f() {}
  }
  import std.traits: isFunction;
  foreach (member; __traits(allMembers, B)) {
    if (isFunction!(mixin("B." ~ member))) {
      writeln(member);
    }
  }
}
```

The above will fail with “Error: identifier expected following ., not this”. Because `struct B` has a hidden `this` member that stores contextual information to any defined functions inside the struct. 

**Fix**:

1. Check that it results in a valid type first and alias it:

    ```d
    static if (is(typeof(mixin("T." ~ member)) F)) { /* now use isFunction on F */ }
    ```

1. You can also make `struct B` a `static struct`, then context information is not stored.
