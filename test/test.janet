(use /src/jayson)
(import spork/json)
(use judge)

(deftest "decode a simple json"
  (trust (decode "{\"thing1\":\"a thing\",\"thing2\":\"another thing\", \"thing3\": null}")
         @{"thing1" "a thing"
           "thing2" "another thing"
           "thing3" :json/null}))

(deftest "decode a simple json, with keywords"
  (trust (decode "{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}" true nil)
         @{:thing1 "a thing"
           :thing2 "another thing"}))
    
(deftest "decode a simple json, with nils"
  (trust (decode "{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}" nil true)
         @{"thing1" "a thing"
           "thing2" "another thing"}))
    
(deftest "decode a simple json, keywords and nils"
  (trust (decode "{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}" true true)
         @{:thing1 "a thing"
           :thing2 "another thing"}))
    
(deftest "decode a more complex json"
  (trust (decode "{\"nil\": Null, \"integer\":123,\"array\":[123,456,789],\"boolean-t\":true,\"boolean-f\":false,\"float\":123.456,\"string\":\"a thing\",\"object\":{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}}")
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
  (trust (decode "{\"nil\": Null, \"integer\":123,\"array\":[123,456,789],\"boolean-t\":true,\"boolean-f\":false,\"float\":123.456,\"string\":\"a thing\",\"object\":{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}}" true nil)
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
  (trust (decode "{\"nil\": Null, \"integer\":123,\"array\":[123,456,789],\"boolean-t\":true,\"boolean-f\":false,\"float\":123.456,\"string\":\"a thing\",\"object\":{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}}" nil true)
         @{"array" @[123 456 789]
           "boolean-f" false
           "boolean-t" true
           "float" 123.456
           "integer" 123
           "object" @{"thing1" "a thing"
                      "thing2" "another thing"}
           "string" "a thing"}))
    
(deftest "decode a more complex json, keywords and nils"
  (trust (decode "{\"nil\": Null, \"integer\":123,\"array\":[123,456,789],\"boolean-t\":true,\"boolean-f\":false,\"float\":123.456,\"string\":\"a thing\",\"object\":{\"thing1\":\"a thing\",\"thing2\":\"another thing\"}}" true true)
         @{:array @[123 456 789]
           :boolean-f false
           :boolean-t true
           :float 123.456
           :integer 123
           :object @{:thing1 "a thing"
                     :thing2 "another thing"}
           :string "a thing"}))

(deftest "misc encode tests"
  (trust (map encode
              [nil true false
               123 456.789 "hello"
               :hello 'hello @"hello"
               "👎" "šč" [1 2 3]
               [:array :of :keywords]
               {:a 1}
               {:a 1 "mee" :two "key" {:c false 'd 'free}}])
         @[@"null"
           @"true"
           @"false"
           @"123"
           @"456.789"
           @"\"hello\""
           @"\"hello\""
           @"\"hello\""
           @"\"hello\""
           @"\"\\uD83D\\uDC4E\""
           @"\"\\u0161\\u010D\""
           @"[1,2,3]"
           @"[\"array\",\"of\",\"keywords\"]"
           @"{\"a\":1}"
           @"{\"mee\":\"two\",\"key\":{\"c\":false,\"d\":\"free\"},\"a\":1}"]))

(deftest "misc decode tests"
  (trust (map decode @["null" "true" "false"
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

(deftest "encodes :json/null"
  (trust (encode {:this-key :json/null}) @"{\"this-key\":null}"))

(deftest "encodes nil"
  (trust (encode [1 2 nil 3]) @"[1,2,null,3]"))

### Spork tests

(defn check-object [x]
  (def y (decode (encode x)))
  # (def y1 (decode (encode x " " "\n")))
  (assert (deep= x y) (string/format "failed roundtrip 1: %p" x))
  # (assert (deep= x y1) (string/format "failed roundtrip 2: %p" x))
  )

(deftest "test json 0"
  (trust (check-object :json/null) true))

(deftest "test json 1"
  (trust (check-object 1) true))

(deftest "test json 2"
  (trust (check-object 100) true))

(deftest "test json 3"
  (trust (check-object true) true))

(deftest "test json 4"
  (trust (check-object false) true))

(deftest "test json 5"
  (trust (check-object (range 1000)) true))

(deftest "test json 6"
  (trust (check-object @{"two" 2 "four" 4 "six" 6}) true))

(deftest "test json 7"
  (trust (check-object @{"hello" "world"}) true))

(deftest "test json 8"
  (trust (check-object @{"john" 1 "billy" "joe" "a" @[1 2 3 4 -1000]}) true))

(deftest "test json 9"
  (trust (check-object @{"john" 1 "∀abcd" "joe" "a" @[1 2 3 4 -1000]}) true))

(deftest "test json 10"
  (trust (check-object
         "ᚠᛇᚻ᛫ᛒᛦᚦ᛫ᚠᚱᚩᚠᚢᚱ᛫ᚠᛁᚱᚪ᛫ᚷᛖᚻᚹᛦᛚᚳᚢᛗ
 ᛋᚳᛖᚪᛚ᛫ᚦᛖᚪᚻ᛫ᛗᚪᚾᚾᚪ᛫ᚷᛖᚻᚹᛦᛚᚳ᛫ᛗᛁᚳᛚᚢᚾ᛫ᚻᛦᛏ᛫ᛞᚫᛚᚪᚾ
 ᚷᛁᚠ᛫ᚻᛖ᛫ᚹᛁᛚᛖ᛫ᚠᚩᚱ᛫ᛞᚱᛁᚻᛏᚾᛖ᛫ᛞᚩᛗᛖᛋ᛫ᚻᛚᛇᛏᚪᚾ᛬") true))

(deftest "test json 11" 
  (trust (check-object @["šč"]) true))

(deftest "test json 12" 
  (trust (check-object "👎") true))

# Decoding utf-8 strings 
(deftest "utf-8 strings" 
  (trust (deep= "šč" (decode `"šč"`)) true))

# Recursion guard
(deftest "recursion guard"
  (def one @{:links @[]})
  (def two @{:links @[one]})
  (array/push (one :links) two)
  (def objects @{:one one :two two})
  (test-error (encode objects) "recurred too deeply"))

# Validate against spork/json

# Decoding utf-8 strings 
(deftest "utf-8 strings" 
  (trust (deep= "šč" (decode `"šč"`)) true))

(deftest "decode a string with line breaks"
  (def strs
    [1
     100
     true
     false
     (range 100)
     @{"two" 2 "four" 4 "six" 6}
     @{"hello" "world"}
     @{"john" 1 "billy" "joe" "a" @[1 2 3 4 -1000]}
     @{"john" 1 "∀abcd" "joe" "a" @[1 2 3 4 -1000]}
     "ᚠᛇᚻ᛫ᛒᛦᚦ᛫ᚠᚱᚩᚠᚢᚱ᛫ᚠᛁᚱᚪ᛫ᚷᛖᚻᚹᛦᛚᚳᚢᛗ
 ᛋᚳᛖᚪᛚ᛫ᚦᛖᚪᚻ᛫ᛗᚪᚾᚾᚪ᛫ᚷᛖᚻᚹᛦᛚᚳ᛫ᛗᛁᚳᛚᚢᚾ᛫ᚻᛦᛏ᛫ᛞᚫᛚᚪᚾ
 ᚷᛁᚠ᛫ᚻᛖ᛫ᚹᛁᛚᛖ᛫ᚠᚩᚱ᛫ᛞᚱᛁᚻᛏᚾᛖ᛫ᛞᚩᛗᛖᛋ᛫ᚻᛚᛇᛏᚪᚾ᛬"
     @["šč"]
     "👎"])
  
  (trust (deep= (map |(json/encode $) strs)
                (map |(encode $) strs)) true)
  (trust (deep= (map |(json/decode (json/encode $)) strs)
                (map |(decode (encode $)) strs)) true)
  (trust (deep= (map |(json/decode (json/encode $)) strs)
                (map |(decode (json/encode $)) strs)) true)
  (trust (deep= (map |(json/decode (encode $)) strs)
                (map |(json/decode (json/encode $)) strs)) true)
  (trust (deep= (map |(json/decode (encode $)) strs)
                (map |(decode (json/encode $)) strs)) true))

(deftest "misc0"
  (trust (deep= (json/encode "šč")
                (encode "šč")) true)
  (trust (deep= (json/decode (json/encode "šč"))
                (json/decode (encode "šč"))) true)
  (trust (deep= (decode (json/encode "šč"))
                (decode (encode "šč"))) true)
  (trust (deep= (json/decode (json/encode "šč"))
                (decode (encode "šč"))) true)
  (trust (deep= (decode (json/encode "šč"))
                (json/decode (encode "šč"))) true))

(deftest "misc1"
  (trust (deep= (json/encode @["šč"])
                (encode @["šč"])) true)
  (trust (deep= (json/decode (json/encode @["šč"]))
                (json/decode (encode @["šč"]))) true)
  (trust (deep= (decode (json/encode @["šč"]))
                (decode (encode @["šč"]))) true)
  (trust (deep= (json/decode (json/encode @["šč"]))
                (decode (encode @["šč"]))) true)
  (trust (deep= (decode (json/encode @["šč"]))
                (json/decode (encode @["šč"]))) true))

(comment

  (peg/match utf-8->bytes "\\u0161\\u010D")

  (def high (scan-number (string "0x" "0161")))
  (def low (scan-number (string "0x" "010D")))

  (>= high 0xDC00)

  (def codepoint (+ (blshift (- high 0xD800) 10)
                    (- low 0xDC00)
                    0x10000))
  
  (<= codepoint 0x7f)

  )

(deftest "misc2"
  (trust (deep= (json/encode "👎")
                (encode "👎")) true)
  (trust (deep= (json/decode (json/encode "👎"))
                (json/decode (encode "👎"))) true)
  (trust (deep= (decode (json/encode "👎"))
                (decode (encode "👎"))) true)
  (trust (deep= (json/decode (json/encode "👎"))
                (decode (encode "👎"))) true)
  (trust (deep= (decode (json/encode "👎"))
                (json/decode (encode "👎"))) true))

(deftest "ensure parses empty strings"
  (trust (decode (json/encode {"empty" ""})) @{"empty" ""}))

(deftest "parse a real-world json"
  (def real-world-json (slurp "./test/full-json.json"))
  (trust (decode real-world-json) @{"id" 0
                                    "jsonrpc" "2.0"
                                    "method" "initialize"
                                    "params" @{"capabilities" @{"general" @{"markdown" @{"parser" "marked" "version" "1.1.0"}
                                                                            "positionEncodings" @["utf-16"]
                                                                            "regularExpressions" @{"engine" "ECMAScript"
                                                                                                   "version" "ES2020"}
                                                                            "staleRequestSupport" @{"cancel" true
                                                                                                    "retryOnContentModified" @["textDocument/semanticTokens/full"
                                                                                                                               "textDocument/semanticTokens/range"
                                                                                                                               "textDocument/semanticTokens/full/delta"]}}
                                                                "notebookDocument" @{"synchronization" @{"dynamicRegistration" true
                                                                                                         "executionSummarySupport" true}}
                                                                "textDocument" @{"callHierarchy" @{"dynamicRegistration" true}
                                                                                 "codeAction" @{"codeActionLiteralSupport" @{"codeActionKind" @{"valueSet" @[""
                                                                                                                                                             "quickfix"
                                                                                                                                                             "refactor"
                                                                                                                                                             "refactor.extract"
                                                                                                                                                             "refactor.inline"
                                                                                                                                                             "refactor.rewrite"
                                                                                                                                                             "source"
                                                                                                                                                             "source.organizeImports"]}}
                                                                                                "dataSupport" true
                                                                                                "disabledSupport" true
                                                                                                "dynamicRegistration" true
                                                                                                "honorsChangeAnnotations" true
                                                                                                "isPreferredSupport" true
                                                                                                "resolveSupport" @{"properties" @["edit"]}}
                                                                                 "codeLens" @{"dynamicRegistration" true}
                                                                                 "colorProvider" @{"dynamicRegistration" true}
                                                                                 "completion" @{"completionItem" @{"commitCharactersSupport" true
                                                                                                                   "deprecatedSupport" true
                                                                                                                   "documentationFormat" @["markdown" "plaintext"]
                                                                                                                   "insertReplaceSupport" true
                                                                                                                   "insertTextModeSupport" @{"valueSet" @[1 2]}
                                                                                                                   "labelDetailsSupport" true
                                                                                                                   "preselectSupport" true
                                                                                                                   "resolveSupport" @{"properties" @["documentation"
                                                                                                                                                     "detail"
                                                                                                                                                     "additionalTextEdits"]}
                                                                                                                   "snippetSupport" true
                                                                                                                   "tagSupport" @{"valueSet" @[1]}}
                                                                                                "completionItemKind" @{"valueSet" @[1
                                                                                                                                    2
                                                                                                                                    3
                                                                                                                                    4
                                                                                                                                    5
                                                                                                                                    6
                                                                                                                                    7
                                                                                                                                    8
                                                                                                                                    9
                                                                                                                                    10
                                                                                                                                    11
                                                                                                                                    12
                                                                                                                                    13
                                                                                                                                    14
                                                                                                                                    15
                                                                                                                                    16
                                                                                                                                    17
                                                                                                                                    18
                                                                                                                                    19
                                                                                                                                    20
                                                                                                                                    21
                                                                                                                                    22
                                                                                                                                    23
                                                                                                                                    24
                                                                                                                                    25]}
                                                                                                "completionList" @{"itemDefaults" @["commitCharacters"
                                                                                                                                    "editRange"
                                                                                                                                    "insertTextFormat"
                                                                                                                                    "insertTextMode"
                                                                                                                                    "data"]}
                                                                                                "contextSupport" true
                                                                                                "dynamicRegistration" true
                                                                                                "insertTextMode" 2}
                                                                                 "declaration" @{"dynamicRegistration" true
                                                                                                 "linkSupport" true}
                                                                                 "definition" @{"dynamicRegistration" true
                                                                                                "linkSupport" true}
                                                                                 "diagnostic" @{"dynamicRegistration" true
                                                                                                "relatedDocumentSupport" false}
                                                                                 "documentHighlight" @{"dynamicRegistration" true}
                                                                                 "documentLink" @{"dynamicRegistration" true
                                                                                                  "tooltipSupport" true}
                                                                                 "documentSymbol" @{"dynamicRegistration" true
                                                                                                    "hierarchicalDocumentSymbolSupport" true
                                                                                                    "labelSupport" true
                                                                                                    "symbolKind" @{"valueSet" @[1
                                                                                                                                2
                                                                                                                                3
                                                                                                                                4
                                                                                                                                5
                                                                                                                                6
                                                                                                                                7
                                                                                                                                8
                                                                                                                                9
                                                                                                                                10
                                                                                                                                11
                                                                                                                                12
                                                                                                                                13
                                                                                                                                14
                                                                                                                                15
                                                                                                                                16
                                                                                                                                17
                                                                                                                                18
                                                                                                                                19
                                                                                                                                20
                                                                                                                                21
                                                                                                                                22
                                                                                                                                23
                                                                                                                                24
                                                                                                                                25
                                                                                                                                26]}
                                                                                                    "tagSupport" @{"valueSet" @[1]}}
                                                                                 "foldingRange" @{"dynamicRegistration" true
                                                                                                  "foldingRange" @{"collapsedText" false}
                                                                                                  "foldingRangeKind" @{"valueSet" @["comment" "imports" "region"]}
                                                                                                  "lineFoldingOnly" true
                                                                                                  "rangeLimit" 5000}
                                                                                 "formatting" @{"dynamicRegistration" true}
                                                                                 "hover" @{"contentFormat" @["markdown" "plaintext"]
                                                                                           "dynamicRegistration" true}
                                                                                 "implementation" @{"dynamicRegistration" true
                                                                                                    "linkSupport" true}
                                                                                 "inlayHint" @{"dynamicRegistration" true
                                                                                               "resolveSupport" @{"properties" @["tooltip"
                                                                                                                                 "textEdits"
                                                                                                                                 "label.tooltip"
                                                                                                                                 "label.location"
                                                                                                                                 "label.command"]}}
                                                                                 "inlineValue" @{"dynamicRegistration" true}
                                                                                 "linkedEditingRange" @{"dynamicRegistration" true}
                                                                                 "onTypeFormatting" @{"dynamicRegistration" true}
                                                                                 "publishDiagnostics" @{"codeDescriptionSupport" true
                                                                                                        "dataSupport" true
                                                                                                        "relatedInformation" true
                                                                                                        "tagSupport" @{"valueSet" @[1 2]}
                                                                                                        "versionSupport" false}
                                                                                 "rangeFormatting" @{"dynamicRegistration" true
                                                                                                     "rangesSupport" true}
                                                                                 "references" @{"dynamicRegistration" true}
                                                                                 "rename" @{"dynamicRegistration" true
                                                                                            "honorsChangeAnnotations" true
                                                                                            "prepareSupport" true
                                                                                            "prepareSupportDefaultBehavior" 1}
                                                                                 "selectionRange" @{"dynamicRegistration" true}
                                                                                 "semanticTokens" @{"augmentsSyntaxTokens" true
                                                                                                    "dynamicRegistration" true
                                                                                                    "formats" @["relative"]
                                                                                                    "multilineTokenSupport" false
                                                                                                    "overlappingTokenSupport" false
                                                                                                    "requests" @{"full" @{"delta" true} "range" true}
                                                                                                    "serverCancelSupport" true
                                                                                                    "tokenModifiers" @["declaration"
                                                                                                                       "definition"
                                                                                                                       "readonly"
                                                                                                                       "static"
                                                                                                                       "deprecated"
                                                                                                                       "abstract"
                                                                                                                       "async"
                                                                                                                       "modification"
                                                                                                                       "documentation"
                                                                                                                       "defaultLibrary"]
                                                                                                    "tokenTypes" @["namespace"
                                                                                                                   "type"
                                                                                                                   "class"
                                                                                                                   "enum"
                                                                                                                   "interface"
                                                                                                                   "struct"
                                                                                                                   "typeParameter"
                                                                                                                   "parameter"
                                                                                                                   "variable"
                                                                                                                   "property"
                                                                                                                   "enumMember"
                                                                                                                   "event"
                                                                                                                   "function"
                                                                                                                   "method"
                                                                                                                   "macro"
                                                                                                                   "keyword"
                                                                                                                   "modifier"
                                                                                                                   "comment"
                                                                                                                   "string"
                                                                                                                   "number"
                                                                                                                   "regexp"
                                                                                                                   "operator"
                                                                                                                   "decorator"]}
                                                                                 "signatureHelp" @{"contextSupport" true
                                                                                                   "dynamicRegistration" true
                                                                                                   "signatureInformation" @{"activeParameterSupport" true
                                                                                                                            "documentationFormat" @["markdown" "plaintext"]
                                                                                                                            "parameterInformation" @{"labelOffsetSupport" true}}}
                                                                                 "synchronization" @{"didSave" true
                                                                                                     "dynamicRegistration" true
                                                                                                     "willSave" true
                                                                                                     "willSaveWaitUntil" true}
                                                                                 "typeDefinition" @{"dynamicRegistration" true
                                                                                                    "linkSupport" true}
                                                                                 "typeHierarchy" @{"dynamicRegistration" true}}
                                                                "window" @{"showDocument" @{"support" true}
                                                                           "showMessage" @{"messageActionItem" @{"additionalPropertiesSupport" true}}
                                                                           "workDoneProgress" true}
                                                                "workspace" @{"applyEdit" true
                                                                              "codeLens" @{"refreshSupport" true}
                                                                              "configuration" true
                                                                              "diagnostics" @{"refreshSupport" true}
                                                                              "didChangeConfiguration" @{"dynamicRegistration" true}
                                                                              "didChangeWatchedFiles" @{"dynamicRegistration" true
                                                                                                        "relativePatternSupport" true}
                                                                              "executeCommand" @{"dynamicRegistration" true}
                                                                              "fileOperations" @{"didCreate" true
                                                                                                 "didDelete" true
                                                                                                 "didRename" true
                                                                                                 "dynamicRegistration" true
                                                                                                 "willCreate" true
                                                                                                 "willDelete" true
                                                                                                 "willRename" true}
                                                                              "foldingRange" @{"refreshSupport" true}
                                                                              "inlayHint" @{"refreshSupport" true}
                                                                              "inlineValue" @{"refreshSupport" true}
                                                                              "semanticTokens" @{"refreshSupport" true}
                                                                              "symbol" @{"dynamicRegistration" true
                                                                                         "resolveSupport" @{"properties" @["location.range"]}
                                                                                         "symbolKind" @{"valueSet" @[1
                                                                                                                     2
                                                                                                                     3
                                                                                                                     4
                                                                                                                     5
                                                                                                                     6
                                                                                                                     7
                                                                                                                     8
                                                                                                                     9
                                                                                                                     10
                                                                                                                     11
                                                                                                                     12
                                                                                                                     13
                                                                                                                     14
                                                                                                                     15
                                                                                                                     16
                                                                                                                     17
                                                                                                                     18
                                                                                                                     19
                                                                                                                     20
                                                                                                                     21
                                                                                                                     22
                                                                                                                     23
                                                                                                                     24
                                                                                                                     25
                                                                                                                     26]}
                                                                                         "tagSupport" @{"valueSet" @[1]}}
                                                                              "workspaceEdit" @{"changeAnnotationSupport" @{"groupsOnLabel" true}
                                                                                                "documentChanges" true
                                                                                                "failureHandling" "textOnlyTransactional"
                                                                                                "normalizesLineEndings" true
                                                                                                "resourceOperations" @["create" "rename" "delete"]}
                                                                              "workspaceFolders" true}}
                                               "clientInfo" @{"name" "Visual Studio Code"
                                                              "version" "1.83.1"}
                                               "locale" "en"
                                               "processId" 9055
                                               "rootPath" "/home/caleb/projects/janet/janet-bluesky"
                                               "rootUri" "file:///home/caleb/projects/janet/janet-bluesky"
                                               "trace" "off"
                                               "workspaceFolders" @[@{"name" "janet-bluesky"
                                                                      "uri" "file:///home/caleb/projects/janet/janet-bluesky"}]}}))

(deftest "parse a real-world json correctly"
  (def real-world-json (slurp "./test/full-json.json"))
  (trust (deep= (json/decode real-world-json)
                (decode real-world-json)) true))

(deftest "encode a real-world JSON"
  (trust (encode @{"id" 0
                   "jsonrpc" "2.0"
                   "method" "initialize"
                   "params" @{"capabilities" @{"general" @{"markdown" @{"parser" "marked" "version" "1.1.0"}
                                                           "positionEncodings" @["utf-16"]
                                                           "regularExpressions" @{"engine" "ECMAScript"
                                                                                  "version" "ES2020"}
                                                           "staleRequestSupport" @{"cancel" true
                                                                                   "retryOnContentModified" @["textDocument/semanticTokens/full"
                                                                                                              "textDocument/semanticTokens/range"
                                                                                                              "textDocument/semanticTokens/full/delta"]}}
                                               "notebookDocument" @{"synchronization" @{"dynamicRegistration" true
                                                                                        "executionSummarySupport" true}}

                                               "window" @{"showDocument" @{"support" true}
                                                          "showMessage" @{"messageActionItem" @{"additionalPropertiesSupport" true}}
                                                          "workDoneProgress" true}
                                               "workspace" @{"applyEdit" true
                                                             "codeLens" @{"refreshSupport" true}
                                                             "configuration" true
                                                             "diagnostics" @{"refreshSupport" true}
                                                             "didChangeConfiguration" @{"dynamicRegistration" true}
                                                             "didChangeWatchedFiles" @{"dynamicRegistration" true
                                                                                       "relativePatternSupport" true}
                                                             "executeCommand" @{"dynamicRegistration" true}
                                                             "fileOperations" @{"didCreate" true
                                                                                "didDelete" true
                                                                                "didRename" true
                                                                                "dynamicRegistration" true
                                                                                "willCreate" true
                                                                                "willDelete" true
                                                                                "willRename" true}
                                                             "foldingRange" @{"refreshSupport" true}
                                                             "inlayHint" @{"refreshSupport" true}
                                                             "inlineValue" @{"refreshSupport" true}
                                                             "semanticTokens" @{"refreshSupport" true}
                                                             "symbol" @{"dynamicRegistration" true
                                                                        "resolveSupport" @{"properties" @["location.range"]}
                                                                        "symbolKind" @{"valueSet" @[1
                                                                                                    2
                                                                                                    3
                                                                                                    4
                                                                                                    5
                                                                                                    6
                                                                                                    7
                                                                                                    8
                                                                                                    9
                                                                                                    10
                                                                                                    11
                                                                                                    12
                                                                                                    13
                                                                                                    14
                                                                                                    15
                                                                                                    16
                                                                                                    17
                                                                                                    18
                                                                                                    19
                                                                                                    20
                                                                                                    21
                                                                                                    22
                                                                                                    23
                                                                                                    24
                                                                                                    25
                                                                                                    26]}
                                                                        "tagSupport" @{"valueSet" @[1]}}
                                                             "workspaceEdit" @{"changeAnnotationSupport" @{"groupsOnLabel" true}
                                                                               "documentChanges" true
                                                                               "failureHandling" "textOnlyTransactional"
                                                                               "normalizesLineEndings" true
                                                                               "resourceOperations" @["create" "rename" "delete"]}
                                                             "workspaceFolders" true}}
                              "clientInfo" @{"name" "Visual Studio Code"
                                             "version" "1.83.1"}
                              "locale" "en"
                              "processId" 9055
                              "rootPath" "/home/caleb/projects/janet/janet-bluesky"
                              "rootUri" "file:///home/caleb/projects/janet/janet-bluesky"
                              "trace" "off"
                              "workspaceFolders" @[@{"name" "janet-bluesky"
                                                     "uri" "file:///home/caleb/projects/janet/janet-bluesky"}]}}) @"{\"params\":{\"clientInfo\":{\"name\":\"Visual Studio Code\",\"version\":\"1.83.1\"},\"processId\":9055,\"workspaceFolders\":[{\"uri\":\"file:///home/caleb/projects/janet/janet-bluesky\",\"name\":\"janet-bluesky\"}],\"trace\":\"off\",\"locale\":\"en\",\"rootPath\":\"/home/caleb/projects/janet/janet-bluesky\",\"rootUri\":\"file:///home/caleb/projects/janet/janet-bluesky\",\"capabilities\":{\"general\":{\"markdown\":{\"parser\":\"marked\",\"version\":\"1.1.0\"},\"regularExpressions\":{\"version\":\"ES2020\",\"engine\":\"ECMAScript\"},\"positionEncodings\":[\"utf-16\"],\"staleRequestSupport\":{\"retryOnContentModified\":[\"textDocument/semanticTokens/full\",\"textDocument/semanticTokens/range\",\"textDocument/semanticTokens/full/delta\"],\"cancel\":true}},\"workspace\":{\"inlineValue\":{\"refreshSupport\":true},\"workspaceFolders\":true,\"fileOperations\":{\"willDelete\":true,\"willCreate\":true,\"dynamicRegistration\":true,\"willRename\":true,\"didDelete\":true,\"didCreate\":true,\"didRename\":true},\"semanticTokens\":{\"refreshSupport\":true},\"didChangeWatchedFiles\":{\"relativePatternSupport\":true,\"dynamicRegistration\":true},\"applyEdit\":true,\"codeLens\":{\"refreshSupport\":true},\"didChangeConfiguration\":{\"dynamicRegistration\":true},\"foldingRange\":{\"refreshSupport\":true},\"inlayHint\":{\"refreshSupport\":true},\"executeCommand\":{\"dynamicRegistration\":true},\"workspaceEdit\":{\"resourceOperations\":[\"create\",\"rename\",\"delete\"],\"failureHandling\":\"textOnlyTransactional\",\"changeAnnotationSupport\":{\"groupsOnLabel\":true},\"normalizesLineEndings\":true,\"documentChanges\":true},\"symbol\":{\"symbolKind\":{\"valueSet\":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26]},\"resolveSupport\":{\"properties\":[\"location.range\"]},\"dynamicRegistration\":true,\"tagSupport\":{\"valueSet\":[1]}},\"configuration\":true,\"diagnostics\":{\"refreshSupport\":true}},\"notebookDocument\":{\"synchronization\":{\"executionSummarySupport\":true,\"dynamicRegistration\":true}},\"window\":{\"showMessage\":{\"messageActionItem\":{\"additionalPropertiesSupport\":true}},\"workDoneProgress\":true,\"showDocument\":{\"support\":true}}}},\"id\":0,\"jsonrpc\":\"2.0\",\"method\":\"initialize\"}"))

(deftest "encode a real-world JSON correctly"
  (def real-world-dictionary (json/decode (slurp "./test/full-json.json")))
  (trust (deep= (json/encode real-world-dictionary)
                (encode real-world-dictionary)) true))

(comment

  (peg/match utf-8->bytes "\\uD83D\\uDC4E")

  (def high (scan-number (string "0x" "D83D")))
  (def low (scan-number (string "0x" "DC4E")))

  (def codepoint (+ (blshift (- high 0xD800) 10)
                    (- low 0xDC00)
                    0x10000))

  (<= codepoint 0x7f)
  (<= codepoint 0x7ff)
  (<= codepoint 0xffff)
  (<= codepoint)

  (string/from-bytes ;[(bor (band (brshift codepoint 18) 0x07) 0xF0)
                      (bor (band (brshift codepoint 12) 0x3F) 0x80)
                      (bor (band (brshift codepoint  6) 0x3F) 0x80)
                      (bor (band (brshift codepoint  0) 0x3F) 0x80)])

  )

