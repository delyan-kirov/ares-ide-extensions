; Ares highlighting for Helix, over the grammar tools/editors/TREE_SITTER_GEN.ares
; generates from documentation/syntax/ares.y. When several patterns match a node,
; the first wins, so specific patterns come before general ones.

(comment) @comment
(str) @string
(int) @constant.numeric.integer
[(real) (imag)] @constant.numeric.float
["@true" "@false"] @constant.builtin.boolean
(hole) @special

; What an item defines: the name after `$`.
(global "$" . (lident) @function)
(global "$" . (uident) @type)
(mod_decl (uident) @namespace)
(import) @namespace

; Types. A type is an expression, so an `@` name is a builtin type when it is
; capitalised (`@Int`) and an intrinsic otherwise (`@vec_len`), and a
; capitalised name heading an atom is a type (or the module of a qualified
; name); the constructor after its `.` is matched below.
(opt_type_params (lident) @type.parameter)
((plain (at_tycon) @type.builtin) (#match? @type.builtin "^@[A-Z]"))
(plain (uident) @type)
(eff_entry (uident) @type)
(eff_entry (at_tycon) @type.builtin)
(at_iface) @type.builtin

; Fields and parameters
(field_decl (lident) @variable.other.member)
(dot_inits (lident) @variable.other.member)
(field_init (lident) @variable.other.member)
(rec_field (lident) @variable.other.member)
(postfix (lident) @variable.other.member)
(param (pat_plain (lident) @variable.parameter))

; Constructors: a variant after a `.`
(variant_decl (uident) @constructor)
(pat_plain (uident) @constructor)
(postfix (uident) @constructor)
(dot_primary (uident) @constructor)

; An `@` name used as a value is an intrinsic.
((plain (at_tycon) @function.builtin) (#match? @function.builtin "^@[a-z]"))

["let" "in"] @keyword
["if" "else"] @keyword.control.conditional
["do" "ctl"] @keyword.control
["@mod" "@struct" "@union" "@alias" "@effect" "@main" "@build" "&" "@use" "@private" "@import" "@extern" "@Array"] @keyword.directive
"$" @punctuation.special

["=" "=>" "->" ":" "|" ";" "|>" "<|" "<|>" "::" "++" "+" "-" "*" "/" "%" "^" "==" "!=" "<" ">" "<=" ">=" "&&" "||" "!" "..." "<>" "\\"] @operator
["(" ")" "[" "]" "{" "}"] @punctuation.bracket
["," "."] @punctuation.delimiter

(lident) @variable
