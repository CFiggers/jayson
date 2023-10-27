# `jayson` Encodes and Decodes JSON

Hey, you there! Are you trying to encode and decode standard UTF-8 JSON strings in your Janet program? Well then you're almost certainly in the wrong place! **You should *almost definitely* go use [Spork's JSON module](https://GitHub.com/janet-lang/spork) instead of this library.** `spork/json` is fast, accurate, easy to use, and it's maintained by the creator of the Janet language, so you know it's competently designed (unlike this piece of whatever it is). Sound good? Ok, great! Thanks for coming by, enjoy reliably and quickly encoding and decoding JSON with `spork/json`!

...Oh, you're back! How unexpected. What's that? `spork/json` is fantastic and perfect for 99% of use cases, **with the notable exception** that it's implemented in C and packaged into a native module, which means that **`spork/json`'s `encode` and `decode` functions can't be marshalled into .jimage files?**

In that case, this might be just the janky, painfully slow, _probably_ badly bug-ridden, but **_pure Janet_** JSON serialization/deserialization library for you!

## Using `jayson`

Requires [Janet](https://janet-lang.org). Best with [jpm](https://github.com/janet-lang/jpm) too.

1. Install `jayson` 

   - The easiest way to do this is with jpm: `$ jpm install https://github.com/CFiggers/jayson`, or `jpm deps` after adding this repo to the `:deps` in your project.janet file. 
   - You could also save the `/src/jayson.janet` file in this repo somewhere convenient).

2. `(import jayson)` in a to a .janet file of your choosing (or use a relative path, like `(import ./jayson)` if you just downloaded the single .janet file).

3. Use `jayson` to encode and decode you some JSON

    - Encoding: `(jayson/encode {:a "is true"})`
    - Decoding: `(jayson/decode (slurp "json-file.json"))` 

For general usage, refer to the docstrings of each function (type `(doc jayson/encode)` and `(doc jayson/encode)` at your Janet REPL).

## Of Note: Regarding `null`

`jayson` departs from `spork/json` in only one major way, and that is the way it handles JSON `null` in both encoding and decoding.

- `(jayson/decode)` renders `null`s as `:json/null` by default, as opposed to `spork/json`'s `:null` (without the '`json/`' namespace prefix). 
- `(jayson/encode)` will encode `null` values into JSON, even as the value in a Janet dictionary (table/struct), if you pass in the keyword `:json/null`. 

## Contributing

Issues and pull requests welcome.

## Prior Art

Obviously, [`spork/json`](https://github.com/janet-lang/spork/blob/master/src/json.c), which is Copyright (c) 2022 Calvin Rose.

