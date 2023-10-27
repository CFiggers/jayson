# `jayson` Encodes and Decodes JSON

Hey, you there! Are you trying to encode and decode standard UTF-8 JSON strings in your Janet program? Well then you're almost certainly in the wrong place! You should *almost definitely* go use [Spork's JSON module](https://GitHub.com/janet-lang/spork) instead of this library. It's fast, accurate, easy to use, and it's maintained by the creator of the Janet language, so you know it's competently designed. Sound good? Ok, great! Thanks for coming by and do enjoy 

Oh, you're back! How unexpected. What's that? `spork/json` is fantastic and perfect for 99% of use cases, with the notable exception that it's implemented in C and packaged into a native module, which means *its `encode` and `decode` functions can't be marshalled into .jimage files?*

In that case, this might be just the janky, painfully slow, _probably_ badly bug-ridden, but _pure Janet_ JSON serialization/deserialization library for you!

## Getting Started 

Requires [Janet](https://janet-lang.org). Best with [jpm](https://github.com/janet-lang/jpm) too.

1. Install `jayson` (the easiest way to do that is with jpm: `$ jpm install https://github.com/CFiggers/jayson`. But you could also save the `/src/jayson.janet` file in this repo somewhere convenient).

2. `(import jayson)` in a to your .janet file.

3. Use 

## Hack on `jayson`



