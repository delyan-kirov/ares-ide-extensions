; Thrax highlighting for Helix, over the grammar tools/editors/TREE_SITTER_GEN.thx
; generates from documentation/thrax.y. When several patterns match a node,
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

; Types
(opt_type_params (lident) @type.parameter)
(type_atom (lident) @type.parameter)
(type_atom (uident) @type)
(type_app_head (uident) @type)
(type_atom (at_tycon) @type.builtin)
(type_app_head (at_tycon) @type.builtin)
(eff_entry (uident) @type)
(eff_entry (at_tycon) @type.builtin)
(at_iface) @type.builtin

; Fields and parameters
(field_decl (lident) @variable.other.member)
(dot_inits (lident) @variable.other.member)
(field_init (lident) @variable.other.member)
(rec_field (lident) @variable.other.member)
(atom "." (lident) @variable.other.member)
(param (pat_atom (lident) @variable.parameter))

; Constructors, and the module part of a qualified name
(variant_decl (uident) @constructor)
(pat_atom (uident) @constructor)
(atom (uident) @constructor)

; An `@` name used as a value is an intrinsic.
(atom (at_tycon) @function.builtin)

["let" "in" "with" "defer"] @keyword
["if" "else"] @keyword.control.conditional
["do" "ctl"] @keyword.control
["@mod" "@struct" "@union" "@alias" "@effect" "@main" "@build" "@e" "@run" "@use" "@private" "@extern" "@Array"] @keyword.directive
"$" @punctuation.special

["=" "=>" "->" ":" "|" ";" "|>" "<|" "<|>" "::" "++" "+" "-" "*" "/" "%" "^" "==" "!=" "<" ">" "<=" ">=" "&&" "||" "!" "..." "<>" "\\"] @operator
["(" ")" "[" "]" "{" "}"] @punctuation.bracket
["," "."] @punctuation.delimiter

(lident) @variable
