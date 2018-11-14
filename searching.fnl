;;; searching for the perfect abstraction

(local md { "module"    []
            "dot_fns"   {}
            "colon_fns" {} })

(local st { "headings"     {}
            "global_fns"   {}
            "local_fns"    {}
            "local_table"  {}
            "module_return"{ "num" "line"}
            "TODO"         {} })

(local pprint_metadata (fn [meta]
    (print "module name\t" (. meta.module 1))
    (print "dot functions")
    (each [line string (pairs meta.dot_fns)]
        (print "\t" line string))
    (print "colon functions")
    (each [line string (pairs meta.colon_fns)]
        (print "\t" line string))))

(local pprint_structure (fn [struct]
    (each [k v (pairs st)]
        (print k)
        (each [num line (pairs v)]
            (print "\t" num line)))))

(global main (fn [filename]
    (var i 1)
    ; match patterns and store the line# and contents in st
    (each [l (io.lines filename)]
        (do
            (if (string.match l "^%-%-%-")
                (tset st.headings i (string.sub l 5))
                (string.match l "^function")
                (tset st.global_fns i l)
                (string.match l "^local function")
                (tset st.local_fns i l)
                (string.match l "^local %a+%s*=%s*{%s*}")
                (tset st.local_table i l)
                (string.match l "^return %a+")
                (do
                    (tset st.module_return "num" i)
                    (tset st.module_return "line" l))
                (string.match l "TODO")
                (tset st.TODO i l))
            (set i (+ i 1))))
    (if (~= nil st.module_return.num)
        (do
            (tset md.module 1 (string.sub st.module_return.line 8))
            (each [line content (pairs st.global_fns)]
                (let [my_fn (string.sub content
                                        10
                                        (string.find content ")"))]
                    (if (~= nil (string.find my_fn
                                             (.. (. md.module 1) "%.")))
                        (tset md.dot_fns
                              line
                              (string.sub my_fn
                                          (+ 2 (# (. md.module 1)))))
                        (~= nil (string.find my_fn
                                             (.. (. md.module 1) "%:")))
                        (tset md.colon_fns
                              line
                              (string.sub my_fn
                                          (+ 2 (# (. md.module 1))))))))))
    (pprint_metadata md)))
    ;(pprint_structure st)))

(main "asl.lua")

; need a heavy duty parser/lexer to make some decisions about what to
; display and what to hide. what is important, vs what is implementation
; detail that should be hidden.

; search for first '--- ' which is the name of module
; all trailing '-- ' lines are the description

; search for any later '--- ' lines which are separators / headings

; search for any 'TODO' which should show an '!' next to the fn

; search for 'local ___' from top, then search for matching 'return ___'
; at bottom, meaning this is a library / class.

; search for all 'function ___'
; subset those whose names are preceded with the class name.
; subset those preceded with 'local'
; subset those using self : syntax
