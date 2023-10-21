(use judge)

(defmacro- letv [bindings & body]
  ~(do ,;(seq [[k v] :in (partition 2 bindings)] ['var k v]) ,;body))

(defn decode 
  ``
  Returns a janet object after parsing JSON. If keywords is truthy,
  string keys will be converted to keywords. If nils is truthy, null
  will become nil instead of the keyword :json/null.
  ``
  [json-source &opt keywords nils] 

  (def unicode-map
    {"00" "\0" "01" "\x01" "02" "\x02" "03" "\x03" "04" "\x04"
     "05" "\x05" "06" "\x06" "07" "\a" "08" "\b" "09" "\t"
     "0A" "\n" "0B" "\v" "0C" "\f" "0D" "\r" "0E" "\x0E"
     "0F" "\x0F" "10" "\x10" "11" "\x11" "12" "\x12" "13" "\x13"
     "14" "\x14" "15" "\x15" "16" "\x16" "17" "\x17" "18" "\x18"
     "19" "\x19" "1A" "\x1A" "1B" "\e" "1C" "\x1C" "1D" "\x1D"
     "1E" "\x1E" "1F" "\x1F"})

  (def json-parser 
    {:null (if nils
             ~(/ (<- (+ "null" "Null")) nil)
             ~(/ (<- (+ "null" "Null")) :json/null))
     :bool-t ~(/ (<- (+ "true")) true)
     :bool-f ~(/ (<- (+ "false")) false)
     :number ~(/ (<- (* (? "-") :d+ (? (* "." :d+)))) ,|(scan-number $))
     :string ~(/ (* "\"" (<- (to (* (> -1 (not "\\")) "\"")))
                    (* (> -1 (not "\\")) "\""))
                 ,|(string (peg/replace '(* "\\u00" (<- 2))
                                 (fn [_ a] (get unicode-map a)) $))) 
     :array ~(/ (* "[" :s* (? (* :value (any (* :s* "," :value)))) "]") ,|(array ;$&))
     :key-value (if keywords
                  ~(* :s* (/ :string ,|(keyword $)) :s* ":" :value)
                  ~(* :s* :string :s* ":" :value))
     :object ~(/ (* "{" :s* (? (* :key-value (any (* :s* "," :key-value)))) "}")
                 ,|(from-pairs (partition 2 $&)))
     :value ~(* :s* (+ :null :bool-t :bool-f :number :string :array :object) :s*)
     :unmatched ~(/ (<- (some 1)) ,|[:unmatched $])
     :main ~(some (+ :value "\n" :unmatched))})
  
  (first (peg/match (peg/compile json-parser) json-source)))

(defn encode-string [x]
  (let [escape-lookup {"\\" "\\"
                       "\"" "\""
                       "\a" "\\u0007"
                       "\b" "\\u0008"
                       "\t" "\\u0009"
                       "\n" "\\u000A"
                       "\v" "\\u000B"
                       "\f" "\\u000C"
                       "\r" "\\u000D"}
        escape-char |(or (escape-lookup $) (string/format "u%04x" $))
        escape-seq-peg ~{:ascii0to31 (range "\0\x1F")
                         :backslash "\\"
                         :quote "\""
                         :main (+ :ascii0to31 :backslash :quote)}
        body (peg/replace-all escape-seq-peg escape-char x)]
    (string "\"" body "\"")))

(defn- encodeone [encoder x depth]
  (if (> depth 1024) (error "recurred too deeply"))
  (cond
    (= x :json/null) "null"
    (bytes? x) (encode-string x)
    (indexed? x) (string "[" (string/join (map |(encodeone encoder $ (inc depth)) x) ",") "]")
    (dictionary? x) (string "{" (string/join
                                 (seq [[k v] :in (pairs x)]
                                   (string (encodeone encoder k (inc depth)) ":" (encodeone encoder v (inc depth)))) ",") "}")
    (case (type x)
      :nil "null"
      :boolean (string x)
      :number (string x)
      (error "type not supported"))))

(defn encode 
  `` 
  Encodes a janet value in JSON (utf-8). `tab` and `newline` are optional byte sequence which are used 
  to format the output JSON. If `buf` is provided, the formated JSON is append to `buf` instead of a new buffer.
  Returns the modifed buffer.
  ``
  [x &opt tab newline buf]
  
  (letv [encoder {:indent 0
                  :buffer @""
                  :tab tab
                  :newline newline}
         ret (encodeone encoder x 0)]
        (if (and buf (buffer? buf))
          (buffer/push ret)
          (thaw ret))))
