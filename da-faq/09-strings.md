# I can haz string?

Here we look at some gotchas with strings and some design issues that result in a bit of awkwardness when handling strings in D. To say the least, D does not have the best design over strings.

## It’s an alias to an array type

D strings are defined as an `alias` to an immutable array of chars. So they are implemented as an array. Which means when you are writing a generic algorithm on an array, you have to know that your array could be a `string`. Then you need to decide if the algorithm makes sense on a `string`, and if it does, you then have to decide is it for ascii only or for unicode. And if you decide if it’s for unicode, then you need to decide if it needs to operate on code units, code points, or graphemes.

The problem is exacerbated by the fact that arrays in D are treated as ranges. So you can use any of the algorithms on a `string`, but there’s no guarantee that the algorithm treats the range as a unicode string.

The bottom line is that you need to know what you’re doing and be aware of applying algorithms on `string` types.

## Autodecoding: hidden, unwanted processing on strings

When you treat a `string` as a range, D does something magical by default - autodecoding. And there’s no way to turn this off. This means that calling `.front` on a `string` will:

1. Be a performance hit because it calls `std.utf.decode`.
1. Return type `dchar`, which is neither a proper unicode character nor a code unit. It’s a code point. And operating on code points are quite useless

In short:

```d
alias T1 = typeof("hello"[0]);
alias T2 = typeof("hello".front);
static assert(!is(T1 == T2));
static assert(is(T1 == immutable(char)));
static assert(is(T2 == dchar));
```

## You can have neither correctness nor performance by default

Because of autodecoding, you cannot be correct by default, nor can you be performant. If you are only working on the latin 1 character set, and using a `string` as a range, you’re going to be calling `std.utf.decode` EVERY.SINGLE.TIME. And if you are working on unicode, then you better pray your characters all fit inside a code point or else you’re going to get incorrect behavior. Let’s take two unicode characters: á and á. Some fonts may display them differently, but with many fonts they will look exactly the same. Note exhibit A:

```d
writeln("á".canFind("á")); // false
```

The real difference is in the code units that make up those characters:

* á = decoded to C2 A1
* á = decoded to 61 CC 81

These two characters are the same characters though. The first is “latin small letter A with acute” and the second is “latin small letter A + combining acute accent”

If you understand how some individual functions operate on strings, you’ll see why this happens:

```d
"\xC3\xA1".length.writeln; // 2
"\xC3\xA1".walkLength.writeln; // 1
"\xC3\xA1".byGrapheme.walkLength.writeln; // 1
"\x61\xCC\x81".length.writeln; // 3
"\x61\xCC\x81".walkLength.writeln; // 2
"\x61\xCC\x81".byGrapheme.walkLength.writeln; // 1
```

## When dealing with strings, remember the following:

1. When you know it’s ascii, use string.byChar
1. When you want individual unicode characters use string.byGrapheme
1. When you want to operate on unicode then call string.normalize first
1. Do not treat strings as bytes. If you want bytes there’s a type for that.
