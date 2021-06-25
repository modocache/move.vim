if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case match

" Syntax definitions {{{1
" Simple keywords {{{2
syn keyword moveConditional else if
syn keyword moveRepeat in loop forall where while
syn keyword moveKeyword
      \ abort acquires apply as assume break const continue decreases define
      \ friend invariant let module move native public return schema script spec
      \ use

" Built-in types {{{2
" FIXME: 'address' can also be a keyword when used in an address block, as in
"        `address 0x2 { ... }`. We classify it as a built-in type here, but
"        if we wish to classify the 'address' in an address block differently,
"        we need to peek at the surrounding context.
syn keyword moveType address bool u8 u64 u128 vector
syn keyword moveStorage mut

" Constants {{{2
syn keyword moveBoolean true false
syn match moveNumber /-\?\<\d\+\>/
syn match moveFloat  /\<0x\x\+\>/
syn match moveConstant /@0x\x*/
" FIXME: In this file most identifiers are pattern-matched with `[a-zA-Z_]`,
"        which is probably incorrect in most cases. For example, this wouldn't
"        match `var2`, although that's probably valid in most cases. The
"        patterns need to be improved to begin with an identifier-nondigit,
"        followed by any number of identifier or digit characters. I'm too
"        lazy to do this now.
syn match moveConstant /\<@[a-zA-Z_]*>/

" Struct declarations {{{2
syn region moveStructDeclaration
      \ end="}" matchgroup=moveKeyword start="struct"ms=s
      \ contains=moveStructDeclarationPrologue,moveStructFields
syn region moveStructDeclarationPrologue
      \ end="{"me=e-1 matchgroup=moveKeyword start="struct"
      \ contains=moveGenericRegion,moveHasKeyword,moveAbility
      \ nextgroup=moveStructFields
" NOTE: We highlight operators in generic regions, mostly in order to
"       highlight the `+` in `<T: copy + drop + store>`.
syn region moveGenericRegion
      \ start="<\(=\)\@!" end=">"
      \ contains=moveAbility,moveSigil,moveOperator
syn keyword moveHasKeyword contained has
" NOTE: Ability keywords are carefully marked as 'contained' only within
"       specific regions. We especially want to avoid 'key', a very common
"       local variable name in Move programs, from being highlighted as if it
"       were a special keyword when it is used in an ordinary function body.
syn keyword moveAbility contained copy drop key store
" For example: in `foo<T: copy>()`, `T` is a 'sigil'.
syn match moveSigil contained /[a-zA-Z_]*/
syn region moveStructFields contained
      \ start="{" end="}"
      \ contains=moveType,moveGenericRegion,moveStructField,moveCommentLine
syn match moveStructField contained /[a-zA-Z_]*:/

" Function declarations {{{2
syn region moveFunctionDeclaration
      \ end=/[{;]/ matchgroup=moveKeyword start="fun"
      \ contains=moveKeyword,moveType,moveGenericRegion,moveParameterRegion
syn region moveParameterRegion contained
      \ start="(" end=")"
      \ contains=moveType,moveStorage,moveGenericRegion,moveOperator

" Other syntax {{{2
syn keyword moveBuiltin assert move_to
syn keyword moveSpecification
      \ aborts_if aborts_with apply assume axiom emits ensures global include
      \ local modifies pragma requires with
" FIXME: This isn't even close to an exhaustive list of Move operators, which
"        also include '==>', etc.
syn match moveOperator /&\|\*\|=\|+\|-/
syn region moveCommentLine start="//" end="$" contains=moveTodo
syn keyword moveTodo contained TODO FIXME XXX NB NOTE SAFETY
" TODO: Add highlighting for module access, like
"       `Event::publish_generator(...)`.

" Default highlighting {{{1
hi def link moveConditional Conditional
hi def link moveRepeat Conditional
hi def link moveKeyword Keyword
hi def link moveType Type
hi def link moveStorage StorageClass
hi def link moveBoolean Boolean
hi def link moveNumber Number
hi def link moveFloat Float
hi def link moveConstant Constant
hi def link moveHasKeyword Keyword
hi def link moveAbility StorageClass
hi def link moveSigil Typedef
hi def link moveStructField Label
hi def link moveOperator Operator
hi def link moveBuiltin Macro
hi def link moveSpecification Precondit
hi def link moveCommentLine Comment
hi def link moveTodo Todo

let b:current_syntax = "move"
