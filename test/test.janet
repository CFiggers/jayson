(use /src/jayson)
(use judge)

(deftest "decode a simple json"
  (test (decode "{\"thing1\":\"a thing\",\"thing2\":\"another thing\", \"thing3\": null}")
    @{"thing1" "a thing"
      "thing2" "another thing"
      "thing3" :json/null}))

(deftest "decode a simple json, with keywords"
  (test (decode "{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}" true nil)
    @{:thing1 "a thing"
      :thing2 "another thing"}))
    
(deftest "decode a simple json, with nils"
  (test (decode "{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}" nil true)
    @{"thing1" "a thing"
      "thing2" "another thing"}))
    
(deftest "decode a simple json, keywords and nils"
  (test (decode "{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}" true true)
    @{:thing1 "a thing"
      :thing2 "another thing"}))
    
(deftest "decode a more complex json"
  (test (decode "{\"nil\": Null, \"integer\":123,\"array\":[123,456,789],\"boolean-t\":true,\"boolean-f\":false,\"float\":123.456,\"string\":\"a thing\",\"object\":{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}}")
    @{"array" @[123 456 789]
      "boolean-f" false
      "boolean-t" true
      "float" 123.456
      "integer" 123
      "nil" :json/null
      "object" @{"thing1" "a thing"
                 "thing2" "another thing"}
      "string" "a thing"}))

(deftest "decode a more complex json, with keywords"
  (test (decode "{\"nil\": Null, \"integer\":123,\"array\":[123,456,789],\"boolean-t\":true,\"boolean-f\":false,\"float\":123.456,\"string\":\"a thing\",\"object\":{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}}" true nil)
    @{:array @[123 456 789]
      :boolean-f false
      :boolean-t true
      :float 123.456
      :integer 123
      :nil :json/null
      :object @{:thing1 "a thing"
                :thing2 "another thing"}
      :string "a thing"}))
    
(deftest "decode a more complex json, with nils"
  (test (decode "{\"nil\": Null, \"integer\":123,\"array\":[123,456,789],\"boolean-t\":true,\"boolean-f\":false,\"float\":123.456,\"string\":\"a thing\",\"object\":{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}}" nil true)
    @{"array" @[123 456 789]
      "boolean-f" false
      "boolean-t" true
      "float" 123.456
      "integer" 123
      "object" @{"thing1" "a thing"
                 "thing2" "another thing"}
      "string" "a thing"}))
    
(deftest "decode a more complex json, keywords and nils"
  (test (decode "{\"nil\": Null, \"integer\":123,\"array\":[123,456,789],\"boolean-t\":true,\"boolean-f\":false,\"float\":123.456,\"string\":\"a thing\",\"object\":{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}}" true true)
    @{:array @[123 456 789]
      :boolean-f false
      :boolean-t true
      :float 123.456
      :integer 123
      :object @{:thing1 "a thing"
                :thing2 "another thing"}
      :string "a thing"}))

(deftest "misc encode tests"
 (test (map encode
            [nil true false
            123 456.789 "hello" 
             :hello 'hello @"hello"
             "👎" "šč" [1 2 3]
             [:array :of :keywords]
             {:a 1}
             {:a 1 "mee" :two "key" {:c false 'd 'free}}])
   @["null" "true" "false"
     "123" "456.789" "\"hello\""
     "\"hello\"" "\"hello\"" "\"hello\""
     "\"\xF0\x9F\x91\x8E\"" "\"\xC5\xA1\xC4\x8D\"" "[1, 2, 3]"
     "[\"array\", \"of\", \"keywords\"]"
     "{\"a\": 1}"
     "{\"mee\": \"two\", \"key\": {\"c\": false, \"d\": \"free\"}, \"a\": 1}"]))

(deftest "misc decode tests"
  (test (map decode @["null" "true" "false" 
                      "123" "456.789" "\"hello\"" 
                      "\"hello\"" "\"hello\"" "\"hello\""
                      "\"\xF0\x9F\x91\x8E\"" "\"\xC5\xA1\xC4\x8D\"" "[1, 2, 3]"
                      "[\"array\", \"of\", \"keywords\"]"
                      "{\"a\": 1}"
                      "{\"mee\": \"two\", \"key\": {\"c\": false, \"d\": \"free\"}, \"a\": 1}"])
    @[:json/null true false
      123 456.789 "hello"
      "hello" "hello" "hello"
      "\xF0\x9F\x91\x8E" "\xC5\xA1\xC4\x8D" @[1 2 3]
      @["array" "of" "keywords"]
      @{"a" 1}
      @{"a" 1
        "key" @{"c" false "d" "free"}
        "mee" "two"}]))

### Spork tests

(defn check-object [x]
  (def y (decode (encode x)))
  (def y1 (decode (encode x " " "\n")))
  (assert (deep= x y) (string/format "failed roundtrip 1: %p" x))
  (assert (deep= x y1) (string/format "failed roundtrip 2: %p" x)))

(deftest "test json 0"
  (test (check-object :json/null) true))

(deftest "test json 1" 
  (test (check-object 1) true))

(deftest "test json 2" 
  (test (check-object 100) true))

(deftest "test json 3" 
  (test (check-object true) true))

(deftest "test json 4" 
  (test (check-object false) true))

(deftest "test json 5" 
  (test (check-object (range 1000)) true))

(deftest "test json 6" 
  (test (check-object @{"two" 2 "four" 4 "six" 6}) true))

(deftest "test json 7" 
  (test (check-object @{"hello" "world"}) true))

(deftest "test json 8" 
  (test (check-object @{"john" 1 "billy" "joe" "a" @[1 2 3 4 -1000]}) true))

(deftest "test json 9" 
  (test (check-object @{"john" 1 "∀abcd" "joe" "a" @[1 2 3 4 -1000]}) true))

(deftest "test json 10"
   (test (check-object
          "ᚠᛇᚻ᛫ᛒᛦᚦ᛫ᚠᚱᚩᚠᚢᚱ᛫ᚠᛁᚱᚪ᛫ᚷᛖᚻᚹᛦᛚᚳᚢᛗ
 ᛋᚳᛖᚪᛚ᛫ᚦᛖᚪᚻ᛫ᛗᚪᚾᚾᚪ᛫ᚷᛖᚻᚹᛦᛚᚳ᛫ᛗᛁᚳᛚᚢᚾ᛫ᚻᛦᛏ᛫ᛞᚫᛚᚪᚾ
 ᚷᛁᚠ᛫ᚻᛖ᛫ᚹᛁᛚᛖ᛫ᚠᚩᚱ᛫ᛞᚱᛁᚻᛏᚾᛖ᛫ᛞᚩᛗᛖᛋ᛫ᚻᛚᛇᛏᚪᚾ᛬") true))
(deftest "test json 11" (check-object @["šč"]))
(deftest "test json 12" (check-object "👎"))

# Decoding utf-8 strings 
(deftest "utf-8 strings" 
  (test (deep= "šč" (decode `"šč"`)) true))

# Recursion guard
(deftest "recursion guard"
  (def one @{:links @[]})
  (def two @{:links @[one]})
  (array/push (one :links) two)
  (def objects @{:one one :two two})
  (test-error (encode objects) "recurred too deeply"))