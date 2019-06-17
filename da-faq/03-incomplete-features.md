# Incomplete features

There are features which are desired, or have not been negatively bashed, or have open issues that have not been rejected.

* Lazy vars:
    * cannot be @nogc
* Ranges:
    * cannot be used with const
* Delegates:
    * cannot capture context by value (i.e. cannot be @nogc)
* Inout:
    * cannot be used with template wrappers
* Invariants:
    * cannot be used with runtime constructions
* Encapsulation:
    * cannot be done within a user defined type
* Shared:
    * provides only conventional protection
* Dictionaries:
    * cannot be created as a global
