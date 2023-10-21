(use /src/jayson)
(use judge)

(deftest "decode a simple json"
  (test (decode "{\"thing1\":\"a thing\",\"thing2\":\"another thing\", \"thing3\": null}") {"thing1" "a thing" "thing2" "another thing" "thing3" :json/null}))

(deftest "decode a simple json, with keywords"
  (test (decode "{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}" true nil) {:thing1 "a thing" :thing2 "another thing"}))
    
(deftest "decode a simple json, with nils"
  (test (decode "{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}" nil true) {"thing1" "a thing" "thing2" "another thing"}))
    
(deftest "decode a simple json, keywords and nils"
  (test (decode "{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}" true true) {:thing1 "a thing" :thing2 "another thing"}))
    
(deftest "decode a more complex json"
  (test (decode "{\"nil\": Null, \"integer\":123,\"array\":[123,456,789],\"boolean-t\":true,\"boolean-f\":false,\"float\":123.456,\"string\":\"a thing\",\"object\":{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}}")
    {"array" [123 456 789]
     "boolean-f" false
     "boolean-t" true
     "float" 123.456
     "integer" 123
     "nil" :json/null
     "object" {"thing1" "a thing"
               "thing2" "another thing"}
     "string" "a thing"}))

(deftest "decode a more complex json, with keywords"
  (test (decode "{\"nil\": Null, \"integer\":123,\"array\":[123,456,789],\"boolean-t\":true,\"boolean-f\":false,\"float\":123.456,\"string\":\"a thing\",\"object\":{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}}" true nil) 
        {:nil :json/null
         :string "a thing"
         :integer 123
         :float 123.456
         :boolean-t true
         :boolean-f false
         :array [123 456 789]
         :object {:thing1 "a thing" :thing2 "another thing"}}))
    
(deftest "decode a more complex json, with nils"
  (test (decode "{\"nil\": Null, \"integer\":123,\"array\":[123,456,789],\"boolean-t\":true,\"boolean-f\":false,\"float\":123.456,\"string\":\"a thing\",\"object\":{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}}" nil true)
    {"array" [123 456 789]
     "boolean-f" false
     "boolean-t" true
     "float" 123.456
     "integer" 123
     "object" {"thing1" "a thing"
               "thing2" "another thing"}
     "string" "a thing"}))
    
(deftest "decode a more complex json, keywords and nils"
  (test (decode "{\"nil\": Null, \"integer\":123,\"array\":[123,456,789],\"boolean-t\":true,\"boolean-f\":false,\"float\":123.456,\"string\":\"a thing\",\"object\":{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}}" true true) 
        {:nil nil
         :string "a thing"
         :integer 123
         :float 123.456
         :boolean-t true
         :boolean-f false
         :array [123 456 789]
         :object {:thing1 "a thing" :thing2 "another thing"}}))