# Unittest gotchas

## Beware of unittests in the same module

It’s idiomatic to write unittests in the same module of the constructs you’re testing. While this is very convenient, you should be aware of access level related bugs. In a module everything is visible. And once the module gets big enough, it’s basically impossible to see the line where you want to test the public API or the non-public API. 

The gotcha is basically this: you assume some unittests are what real-world client code can look like, but unfortunately real-world client code doesn’t have access to private names inside a module.

This means:
1. private member variables may be erroneously accessed in unittests
1. privately imported modules will not be accessible by client code

If D added an aggregate private access level. Then unittests would be more reliable.
