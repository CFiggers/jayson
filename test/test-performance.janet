(import /src/jayson)
(import spork/json)

(use judge)

(defmacro timeit
  ```
  Time the execution of `form` using `os/clock` before and after,
  and print the result to stdout.  returns: result of executing `form`.
  Uses `tag` (default "Elapsed time:") to tag the printout.
  ```
  [form &opt dont-return tag]
  (default tag "Elapsed time:")
  (with-syms [start result end]
    ~(do
       (def ,start (os/clock))
       (def ,result ,form)
       (def ,end (os/clock))
       (print ,tag " " (- ,end ,start) " seconds")
       (unless ,dont-return 
         ,result))))

(def regular-json 
  (slurp "./test/full-json.json"))

(def large-json 
  (slurp "./test/large-file.json"))

(deftest "Testing spork/json, small file: "
  (test-stdout (timeit (json/decode regular-json) true) `
    Elapsed time: 6.96182250976562e-05 seconds
  `))

(deftest "Testing jayson, small file: "
  (test-stdout (timeit (jayson/decode regular-json) true) `
    Elapsed time: 0.0014345645904541 seconds
  `))

(deftest "Testing spork/json, large file: "
  (test-stdout (timeit (json/decode large-json) true) `
    Elapsed time: 0.243280410766602 seconds
  `))

(deftest "Testing jayson, large file: "
  (test-stdout (timeit (jayson/decode large-json) true) `
    Elapsed time: 19.2237403392792 seconds
  `))

(deftest "testing spork/json, encode large file"
  (def large-ds
    (json/decode large-json))
  (test-stdout (timeit (json/encode large-ds) true) `
    Elapsed time: 0.293018341064453 seconds
  `))

(deftest "testing jayson, encode large file"
  (def large-ds
    (json/decode large-json))
  (test-stdout (timeit (jayson/encode large-ds) true) `
    Elapsed time: 8.54112005233765 seconds
  `))