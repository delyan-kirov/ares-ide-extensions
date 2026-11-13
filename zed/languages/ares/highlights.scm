; Ares highlighting for Zed (adapted from the Helix queries), over the grammar tools/editors/TREE_SITTER_GEN.ares
; generates from documentation/ares.y. When several patterns match a node,
; the first wins, so specific patterns come before general ones.

(comment) @comment
(str) @string
(int) @number
[(real) (imag)] @number
["@true" "@false"] @boolean
(hole) @variable.special

; What an item defines: the name after `$`.
(global "$" . (lident) @function)
(global "$" . (uident) @type)
(mod_decl (uident) @type)
(import) @type

; Types. A type is an expression, so an `@` name is a builtin type when it is
; capitalised (`@Int`) and an intrinsic otherwise (`@vec_len`), and a
; capitalised name heading an atom is a type (or the module of a qualified
; name); the constructor after its `.` is matched below.
(opt_type_params (lident) @type)
((plain (at_tycon) @type) (#match? @type "^@[A-Z]"))
(plain (uident) @type)
(eff_entry (uident) @type)
(eff_entry (at_tycon) @type)
(at_iface) @type

; Fields and parameters
(field_decl (lident) @property)
(dot_inits (lident) @property)
(field_init (lident) @property)
(rec_field (lident) @property)
(postfix (lident) @property)
(param (pat_plain (lident) @variable))

; Constructors: a variant after a `.`
(variant_decl (uident) @constructor)
(pat_plain (uident) @constructor)
(postfix (uident) @constructor)
(dot_primary (uident) @constructor)

; An `@` name used as a value is an intrinsic.
((plain (at_tycon) @function) (#match? @function "^@[a-z]"))

["let" "in"] @keyword
["if" "else"] @keyword
["do" "ctl"] @keyword
["@mod" "@struct" "@union" "@alias" "@effect" "@main" "@build" "&" "@use" "@private" "@import" "@extern" "@Array"] @keyword
"$" @punctuation.special

["=" "=>" "->" ":" "|" ";" "|>" "<|" "<|>" "::" "++" "+" "-" "*" "/" "%" "^" "==" "!=" "<" ">" "<=" ">=" "&&" "||" "!" "..." "<>" "\\"] @operator
["(" ")" "[" "]" "{" "}"] @punctuation.bracket
["," "."] @punctuation.delimiter

(lident) @variable
