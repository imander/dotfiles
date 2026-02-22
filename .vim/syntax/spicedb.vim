" Vim syntax file
" Language: SpiceDB Schema

" if exists("b:current_syntax")
"   finish
" endif

" Keywords
" syn match spicedbFoo "\w\+\ze\s*(\?.*{"
syn match spicedbFoo "\w\+\ze\s*\((.*)\)\?\s*{"
syn keyword spicedbDefinition definition partial caveat nextgroup=spicedbFoo skipwhite
syn keyword spicedbRelation relation
syn keyword spicedbPermission permission

syn match spicedbDelimiter "{"
syn match spicedbDelimiter "}"
syn match spicedbDelimiter "("
syn match spicedbDelimiter ")"
syn match spicedbDelimiter "\["   " Escaped because [ is special in regex
syn match spicedbDelimiter "\]"   " Escaped because ] is special in regex
syn match spicedbDelimiter "|"    " Pipe for union types
syn match spicedbDelimiter "#"    " Hash for relation references

" ============================================================================
" OPERATORS
" ============================================================================
" syn keyword for word operators (and, or, etc.)
syn keyword spicedbOperator or and but not

" syn match uses regex patterns to match operators
" These match literal strings (escaped where needed for special chars)
syn match spicedbOperator "-"     " Exclusion operator
syn match spicedbOperator "->"    " Arrow operator for set operations
syn match spicedbOperator "+"     " Union operator
syn match spicedbOperator "&"     " Intersection operator
syn match spicedbOperator "|"     " Union operator (alternative)

" ============================================================================
" TYPES AND IDENTIFIERS
" ============================================================================

" Types and identifiers
" syn match spicedbType "\<definition\s\+\zs\w\+\>" nextgroup=spicedbBlock skipwhite
" syn match spicedbRelationName "\<relation\s\+\zs\w\+\>" nextgroup=spicedbRelationDef skipwhite
" syn match spicedbPermissionName "\<permission\s\+\zs\w\+\>" nextgroup=spicedbPermissionDef skipwhite
" syn match spicedbCaveatName "\<caveat\s\+\zs\w\+\>" contained

" Type references (like document, user, etc. in type specifications)
" syn match spicedbTypeRef "\w\+\ze\(#\|\s*|\s*\w\+#\)" contained
" syn match spicedbTypeRef "\w\+:\ze" contained

" syn match spicedbType "\<definition\s\+\zs\w>" nextgroup=spicedbBlock skipwhite

" ============================================================================
" COMMENTS
" ============================================================================
" Match single-line comments from // to end of line
" .*$       - any character, any number of times, until end of line
syn match spicedbComment "//.*$"

" syn region defines a region with start and end patterns
" Multi-line comments from /* to */
syn region spicedbComment start="/\*" end="\*/"

" ============================================================================
" REGIONS
" ============================================================================
" Define block regions (between curly braces)
" fold          - allows code folding in Vim
" transparent   - allows contained items to be highlighted with their own rules
" contains=ALL  - all syntax groups can appear inside
syn region spicedbBlock start="{" end="}" fold transparent contains=ALL

" Highlights
hi def link spicedbDefinition Define
hi def link spicedbPermission Identifier
hi def link spicedbRelation Keyword
hi def link spicedbDelimiter Delimiter
hi def link spicedbComment Comment
hi def link spicedbOperator Operator

hi def link spicedbFoo Function
" hi def link spicedbTypeRef Type
" hi def link spicedbRelationName Function
" hi def link spicedbPermissionName Function
" hi def link spicedbCaveatName Identifier


