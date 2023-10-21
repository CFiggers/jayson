(import spork/json)
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

  (def json-parser 
    {:null (if nils
             ~(/ (<- (+ "null" "Null")) nil)
             ~(/ (<- (+ "null" "Null")) :json/null))
     :bool-t ~(/ (<- (+ "true")) true)
     :bool-f ~(/ (<- (+ "false")) false)
     :number ~(/ (<- (* (? "-") :d+ (? (* "." :d+)))) ,|(scan-number $))
     :string ~(/ (* "\"" (<- (to (* (> -1 (not "\\")) "\""))) 
                    (* (> -1 (not "\\")) "\"")) ,|$) 
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

(defn- encodeone [encoder x depth]
  (if (> depth 1024) (error "recurred too deeply"))
  (cond
    (= x :json/null) "null"
    (bytes? x) (string "\"" x "\"")
    (indexed? x) (string "[" (string/join (map |(encodeone encoder $ (inc depth)) x) ", ") "]")
    (dictionary? x) (string "{" (string/join
                                 (seq [[k v] :in (pairs x)]
                                   (string (encodeone encoder k (inc depth)) ": " (encodeone encoder v (inc depth)))) ", ") "}")
    (case (type x)
      :nil "null"
      :boolean (string x)
      :number (string x)
      (error "type not supported"))))

(defn encode 
  `` 
  Encodes a janet value in JSON (utf-8). tab and newline are optional byte sequence which are used 
  to format the output JSON. if buf is provided, the formated JSON is append to buf instead of a new buffer.
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
          ret)))
