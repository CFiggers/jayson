(import spork/json)
(use judge)

(defmacro letv [bindings & body]
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
     :array ~(/ (* "[" :s* (? (* :value (any (* :s* "," :value)))) "]") ,|$&)
     :key-value (if keywords
                  ~(* :s* (/ :string ,|(keyword $)) :s* ":" :value)
                  ~(* :s* :string :s* ":" :value))
     :object ~(/ (* "{" :s* (? (* :key-value (any (* :s* "," :key-value)))) "}") 
                 ,|(table/to-struct (from-pairs (partition 2 $&))))
     :value ~(* :s* (+ :null :bool-t :bool-f :number :string :array :object) :s*)
     :unmatched ~(/ (<- (some 1)) ,|[:unmatched $])
     :main ~(some (+ :value "\n" :unmatched))})
  
  (first (peg/match (peg/compile json-parser) json-source)))

(defn encode [])
