" noctu.vim - Vim color scheme for 16-color terminals
" --------------------------------------------------------------
" Author:   Noah Frederick (http://noahfrederick.com/)
" Version:  1.7.0
" --------------------------------------------------------------

" Scheme setup {{{
set background=dark
set t_Co=8
set t_Sf=[3%dm
set t_Sb=[4%dm
hi! clear

if exists("syntax_on")
  syntax reset
endif

let colors_name="qnoctu8"

"}}}
" Vim UI {{{
hi MatchParen ctermfg=3 cterm=bold guifg=orange

hi StatusLineNC ctermfg=5 ctermbg=0 cterm=NONE guifg=purple guibg=black
hi! link TabLineFill StatusLineNC
hi StatusLine ctermfg=2 ctermbg=0 cterm=NONE guifg=green guibg=black
hi WildMenu ctermfg=5 ctermbg=0 cterm=NONE,bold guifg=purple guibg=black
hi! link Pmenu StatusLine
hi! link PmenuSel Wildmenu
hi! link TabLine StatusLineNC
hi! link TabLineSel StatusLine

hi SpellBad ctermfg=1 ctermbg=0 guifg=red guibg=black
hi SpellCap ctermfg=2 cterm=bold guifg=green
hi SpellRare ctermfg=3 cterm=bold guifg=orange
hi SpellLocal ctermfg=5 cterm=bold guifg=purple

hi Hidden ctermfg=0 guifg=grey

hi LineNr ctermfg=3 ctermbg=0 guifg=orange guibg=black
hi! link SignColumn LineNr
hi! link FoldColumn LineNr
hi CursorLineNr ctermfg=3 cterm=bold guifg=orange guibg=grey18
hi CursorLine ctermbg=0 cterm=bold,NONE guibg=grey18
hi VertSplit ctermbg=0 ctermfg=0 guifg=black guibg=grey18

hi Visual ctermbg=6 cterm=NONE guibg=darkslategrey

hi NonText ctermfg=5 cterm=NONE guifg=purple
hi Directory ctermfg=4 guifg=blue
hi Title ctermfg=3 cterm=bold guifg=orange
hi! link MoreMsg Title
hi! link Question Title
hi! link ModeMsg Title
hi ErrorMsg ctermfg=7 ctermbg=1 cterm=bold guifg=grey guibg=red
hi! link WarningMsg ErrorMsg
hi DiffAdd ctermbg=4 cterm=NONE guibg=blue
hi DiffChange ctermbg=5 cterm=NONE guibg=purple
hi DiffDelete ctermbg=6 ctermfg=6 cterm=bold,NONE guibg=cyan guifg=darkcyan
hi User1 ctermfg=7 ctermbg=5 cterm=bold guifg=grey guibg=purple
hi! link User5 User1
hi User2 ctermfg=7 ctermbg=0 cterm=bold guifg=grey
hi! link User9 User2
hi User3 ctermfg=7 ctermbg=3 cterm=bold guifg=grey guibg=orange
hi! link User8 User3
hi! link User4 User3
hi User6 ctermfg=7 ctermbg=6 cterm=bold guifg=grey guibg=cyan
hi User7 ctermfg=7 ctermbg=4 cterm=bold guifg=grey guibg=blue
hi Folded ctermfg=7 ctermbg=none guifg=grey27 guibg=black
hi! link Comment Folded
hi! link Ignore Folded
hi SpecialKey ctermfg=5 ctermbg=0 guifg=purple
" }}}
" Generic syntax {{{
hi Normal guibg=black guifg=grey50

hi Delimiter ctermfg=7 guifg=grey
hi! link Identifier Delimiter
hi! link Operator  Delimiter
hi! link Underlined Delimiter
" hi! link Boolean Underlined

hi Keyword ctermfg=5 guifg=darkviolet
hi! link Statement Keyword

hi Type ctermfg=7 guifg=grey

hi Number ctermfg=5 cterm=bold guifg=purple
hi! link Special Number

hi String ctermfg=1 guifg=red
hi Todo ctermfg=7 cterm=bold guifg=grey
hi Constant ctermfg=2 guifg=green
hi PreProc ctermfg=4 guifg=blue
hi! link Error ErrorMsg
"}}}
" C {{{
hi! link cTypeTag Type
hi! link cEnumTag Constant
hi! link cPreProcTag Constant
hi! link cFunctionTag Function
hi! link cMemberTag Identifier
"}}}
" HTML {{{
hi htmlTagName              ctermfg=2
hi htmlTag                  ctermfg=2
hi htmlArg                  ctermfg=10
hi htmlH1                   cterm=bold
hi htmlBold                 cterm=bold
hi htmlItalic               cterm=underline
hi htmlUnderline            cterm=underline
hi htmlBoldItalic           cterm=bold,underline
hi htmlBoldUnderline        cterm=bold,underline
hi htmlUnderlineItalic      cterm=underline
hi htmlBoldUnderlineItalic  cterm=bold,underline
hi! link htmlLink           Underlined
hi! link htmlEndTag         htmlTag

"}}}
" XML {{{
hi xmlTagName       ctermfg=5
hi xmlTag           ctermfg=5 cterm=bold
hi! link xmlString  String
hi! link xmlAttrib  Constant
hi! link xmlEndTag  xmlTag
hi! link xmlEqual   xmlTag

"}}}
" JavaScript {{{
hi! link javaScript        Normal
hi! link javaScriptBraces  Delimiter

"}}}
" PHP {{{
hi phpSpecialFunction    ctermfg=5 guifg=purple
hi phpIdentifier         ctermfg=11 guifg=yellow
hi! link phpVarSelector  phpIdentifier
hi! link phpHereDoc      String
hi! link phpDefine       Statement

"}}}
" Markdown {{{
hi! link markdownHeadingRule        NonText
hi! link markdownHeadingDelimiter   markdownHeadingRule
hi! link markdownLinkDelimiter      Delimiter
hi! link markdownURLDelimiter       Delimiter
hi! link markdownCodeDelimiter      NonText
hi! link markdownLinkTextDelimiter  markdownLinkDelimiter
hi! link markdownUrl                markdownLinkText
hi! link markdownAutomaticLink      markdownLinkText
hi! link markdownCodeBlock          String
hi markdownCode                     cterm=bold
hi markdownBold                     cterm=bold
hi markdownItalic                   cterm=underline

"}}}
" Ruby {{{
hi! link rubyDefine                 Statement
hi! link rubyLocalVariableOrMethod  Identifier
hi! link rubyConstant               Constant
hi! link rubyInstanceVariable       Number
hi! link rubyStringDelimiter        rubyString

"}}}
" Git {{{
hi gitCommitBranch               ctermfg=3
hi gitCommitSelectedType         ctermfg=10
hi gitCommitSelectedFile         ctermfg=2
hi gitCommitUnmergedType         ctermfg=9
hi gitCommitUnmergedFile         ctermfg=1
hi! link gitCommitFile           Directory
hi! link gitCommitUntrackedFile  gitCommitUnmergedFile
hi! link gitCommitDiscardedType  gitCommitUnmergedType
hi! link gitCommitDiscardedFile  gitCommitUnmergedFile

"}}}
" Vim {{{
hi! link vimSetSep    Delimiter
hi! link vimContinue  Delimiter
hi! link vimHiAttrib  Constant

"}}}
" LESS {{{
hi lessVariable             ctermfg=11
hi! link lessVariableValue  Normal

"}}}
" Help {{{
hi! link helpExample         String
hi! link helpHeadline        Title
hi! link helpSectionDelim    Comment
hi! link helpHyperTextEntry  Statement
hi! link helpHyperTextJump   Underlined
hi! link helpURL             Underlined
"}}}
" Shell {{{
hi shDerefSimple     ctermfg=3 cterm=bold
hi! link shDerefVar  shDerefSimple
"}}}
" Netrw {{{
hi netrwExe       ctermfg=1 cterm=bold
hi netrwClassify  ctermfg=0 cterm=bold
"}}}

" vim: fdm=marker:sw=2:sts=2:et
