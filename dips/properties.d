module properties;

import std.stdio : writeln;

// ===================================================================
// Summary
// ===================================================================

/*
    1. An @property attribute may be applied to free functions or methods
    1. Once an @property function is defined it may not be used with parens
    1. An @property free function may have zero, one, or two parameters
        1. Zero parameters implies a read-only operation (F0)
        1. One parameter implies a read-or-write operation (F1)
        1. Two parameters implies a write-only operation that can only be used via UFCS (F2)
    1. An @property method may have zero or one parameters
        1. Zero parameters implies a read-only operation (M0)
        1. One pamraeter implies a write-only operation (M1)
    1. A getter that returns a ref is also a setter
*/

alias Return = float;
alias Type = int;
alias Value = int;

// ===================================================================
// Free Functions
// ===================================================================

@property Return f0() { return Return.init; }
@property Return f1(Type) { return Return.init; }
@property Return f2(Type, Value) { return Return.init; }

/*
    F0: 0-ary free function property
*/
unittest {
    auto value = f0;
}

/* 
    F1: 1-ary property free function
    
    Can be a read or write property depending on how it's invoked
        * It is a read operation if invoked via UFCS with an implicit first parameter
        * It is a write operation if used as a lhs of an assignmnet
        * typeof on an @property single argument free function is the return type of the function
*/
unittest {
    auto value = Type.init.f1; // read
    f1 = Type.init; // write
}

/*
    F2: 2-ary property free function
    
    May only be invoked by UFCS with an implicit first parameter
*/
unittest {
    Type.init.f2 = Value.init;
}

// ===================================================================
// Methods
// ===================================================================

struct SType {
    @property Return m0() { return Return.init; }
    @property Return m1(Value) { return Return.init; }
}
SType stype;

/*
    M0: 0-ary property method 
    
    Same as read-only version of F1, where 'this' is the implicit first parameter
*/
unittest {
    auto value = stype.m0;
}

/*
    M1: 1-ary property method
    
    Same as F2, where 'this' is the implicit first parameter
*/
unittest {
    stype.m1 = 3;
}

// ===================================================================
// Typeof
// ===================================================================
/*
    The typeof any property should be the return type of said property
*/
unittest {
    static assert(is(typeof(f0) == Return));
    // static assert(is(typeof(f1) == Return)); // CHANGE
    // static assert(is(typeof(f2) == Return)); // CHANGE
    static assert(is(typeof(SType.m0) == Return));
    // static assert(is(typeof(SType.m1) == Return)); // CHANGE
}

// ===================================================================
// Parentheses
// ===================================================================
/*
    Parantheses at the end of an @property object are illegal.
*/
unittest {
    // static assert(!__traits(compiles, f0())); // CHANGE
    // static assert(!__traits(compiles, f1(Type.init))); // CHANGE
    // static assert(!__traits(compiles, Type.init.f1())); // CHANGE
    // static assert(!__traits(compiles, f2(Type.init, Value.init))); // CHANGE
    // static assert(!__traits(compiles, Type.init.f2(Value.init))); // CHANGE
    // static assert(!__traits(compiles, stype.m0())); // CHANGE
    // static assert(!__traits(compiles, stype.m1(Value.init))); // CHANGE
}

/*
    If the type of the property is a callable object than invoking the return type should require 
    a single set of parantheses and not the current double parantheses behaviour
*/
unittest {
    @property Return function() p() {
        return () => Return.init;
    }
    // assert(p() == Return.init); // CHANGE
    // static assert(is(typeof(p()) == Return)); // CHANGE
    static assert(is(typeof(p) == Return function()));
}

// ===================================================================
// Assignment
// ===================================================================
/*
    To be able to assign to an @property function one of the following must be true
        1. It is an @property free function with one parameter (F1)
        1. It is an @property free function with two parameters (F2)
        1. It is an @property method with one parameter (M1)
    
    It is illegal to assign to a free function with one parmeter that is not @property
    It is illegal to assign to a method with one parameter that is not @property
*/
unittest {
    void f(Value) {}
    struct S {
        void f(Value) {}
    }
    // static assert(!__traits(compiles, {f = Value.init;})); // CHANGE
    S s;
    // static assert(!__traits(compiles, {s.f = Value.init;})); // CHANGE
}

// ===================================================================
// Address of
// ===================================================================
/*
    If prop is a property, &prop or &a.prop obey the normal rules of function/delegate access.
    They do not take the address of the returned value implicitly. To do so, one must use &(prop) or &(a.prop).
*/

// ===================================================================
// Overriding
// ===================================================================
/*
    Override rules are the same as for functions
*/

// ===================================================================
// Overloading
// ===================================================================
/*
    Overload rules are the same as for functions
*/

// ===================================================================
// Ref returns (auxillary setters)
// ===================================================================
/*
    A getter may return a mutable ref type in which case it is an auxillary setter
*/
unittest {
    Return r;
    @property ref Return aux() {
        return r;
    }
    auto read = aux;
    aux = Return.init;
}

/*
    If a getter returns a mutable ref and a setter is also defined the setter takes precedence
*/
unittest {
    struct S {
        Value v_ = 1;
        @property ref Value prop() {
            return v_;
        }
        @property void prop(Value) {
            v_ = 2;
        }
    }
    S s;
    s.prop = 3;
    assert(s.prop == 2);
}

// ===================================================================
// Operators
// ===================================================================
/*
    Op= operators require a property to be read and write and are rewritten in terms of their read and write properties

    prop op= value;

    Lowered to:
    {
        auto __temp = prop;
        __temp op= value;
        prop = __temp;
    }

    alias R = typeof(typeof(prop).init op= value);
    static if (!is(R == void))
    {
         auto __temp = prop;
        __temp op= value;
        prop = __temp;
    }
    else
        if (!empty) {
            C();
        }
*/
unittest {
    struct SS {
        private int i_;
        @property Return r() { return 3; }
        @property Return rw() { return i_; }
        @property void rw(Value i) { i_ = i; }
        int m;
    }

    SS s;
    auto a1 = s.m++;
    auto a0 = s.r++;
}

void main() {}