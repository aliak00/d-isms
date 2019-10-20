# Where be thy access level?

Since D decided to use the module as the main unit of encapsulation, there are a few patterns that come up in software development that D either cannot be done, or requires jumping through some hoops to achieve.

## Class private is not really private

```d
module a;

class A {
  private int counter = 0;
  private int _i = 0;
  @property public int i() {
    counter++;
    return _i;
  }
  @property public int i(int newValue) {
    if (counter > 10) {
      _i = newValue * 2;
    } else {
      _i = 0;
    }
  }
}

public void doAmazingStuff(A a) {
  if (a._i % 2 == 0) { // accesses _i but it shouldn't.
    // do some even amazing stuff
  } else {
    // do some odd amazing stuff
  }
}

module main;

void main() {
  auto a = new A()
  a.doAmazingStuff;
  a.counter.writeln; // ouch
  A.i = 3; // ouch
}
```

You must be thinking what’s wrong with the above. Well, the thing is that private is module level in D. So that means if you declare a variable as a private part of a class then the module can still change it. This can lead to very annoying and hard to find state-related bugs within a module.

In the example above, `class A`’s API is such that you want to count all the times the variable `i` was read. But, since private is not really private, one particular function in that module has just accessed `_i` directly, so everything is now off.

**Parital-Fix**:

If a class has any internal state that is hidden within private access, put that class in its own module.

```d
module a.impl;

class A { ... }

Module a;

public import a.impl: A;
public void doAmazingStuff(A a) { ... }
```

Now `doAmazingStuff` cannot access private members of `A`. The potential downside of this is of course that you now cannot access private members of `A`. So your extension function is not a “first class” citizen of `class A` anymore.

**Fix**

In the case where you want `doAmazingStuff` to be able to access some non-publicly accessible variables of a type, but you still want the type to be able to protect its own data, you can use a package:

```
=== type/package.d
module type;

struct Type {
  public a;
  package b; // can be a property with hidden state.
  private c;
}

=== type/friends.d
module type.friends;

void doAmazingStuff(Type t) {
  t.b; // ok
  // t.c; // error
}

=== somemodule.d
import type;
Type t; // ok
t.a; // ok
// t.b; // nope
// t.c; // nope
```

## No sealed classes

If you have a situation where you want a class to be inheritable at module scope, but not publicly, as in Scala sealed classes, there is no explicit access level that supports this.

**Partial-Fix**:

You can use private constructors to partially achieve the same functionality:

```d
class Sealed {
  private this() { ... }
}
class Public : Sealed { ... }
```

But then you can't instantiate the class outside the module.

**Fix**

You can instantiate the class outside the module, however, of you create a type constructor for `Sealed`. So:

```d
// Inside same file as class Sealed
auto makeSealed() {
  return Searled();
}
```
