; Thrax highlighting for Zed (adapted from the Helix queries), over the grammar tools/editors/TREE_SITTER_GEN.thx
; generates from documentation/thrax.y. When several patterns match a node,
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

; Types
(opt_type_params (lident) @type)
(type_atom (lident) @type)
(type_atom (uident) @type)
(type_app_head (uident) @type)
(type_atom (at_tycon) @type)
(type_app_head (at_tycon) @type)
(eff_entry (uident) @type)
(eff_entry (at_tycon) @type)
(at_iface) @type

; Fields and parameters
(field_decl (lident) @property)
(dot_inits (lident) @property)
(field_init (lident) @property)
(rec_field (lident) @property)
(atom "." (lident) @property)
(param (pat_atom (lident) @variable))

; Constructors, and the module part of a qualified name
(variant_decl (uident) @constructor)
(pat_atom (uident) @constructor)
(atom (uident) @constructor)

; An `@` name used as a value is an intrinsic.
(atom (at_tycon) @function)

["let" "in" "with"] @keyword
["if" "else"] @keyword
["do" "ctl"] @keyword
["@mod" "@struct" "@union" "@alias" "@effect" "@main" "@build" "@e" "@run" "@use" "@private" "@extern" "@Array"] @keyword
"$" @punctuation.special

["=" "=>" "->" ":" "|" ";" "|>" "<|" "<|>" "::" "++" "+" "-" "*" "/" "%" "^" "==" "!=" "<" ">" "<=" ">=" "&&" "||" "!" "..." "<>" "\\"] @operator
["(" ")" "[" "]" "{" "}"] @punctuation.bracket
["," "."] @punctuation.delimiter

(lident) @variable
