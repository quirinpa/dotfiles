filetype plugin indent on
syntax on
color desert

set grepprg=ag\ --vimgrep\ --hidden\ --ignore\ .git\ --nogroup\ --nocolor
set rtp+=~/bin

set guifont=Consolas:h16

nnoremap <leader>* yw:Grepper -tool ag -noprompt -query \b"<C-R>0"\b<cr>
nnoremap <leader>g :Grepper -tool ag<cr>
nmap gs  <plug>(GrepperOperator)
xmap gs  <plug>(GrepperOperator)

let g:lsp_server = empty($LSP_SERVER) ? 'deno' : $LSP_SERVER

function! s:configure_lsp() abort
  if g:lsp_server ==# 'deno'
    let g:lsc_server_commands = {
      \ 'typescript': 'deno lsp',
      \ 'typescriptreact': 'deno lsp',
      \ 'javascript': 'deno lsp',
      \ 'javascriptreact': 'deno lsp',
      \ 'c': 'clangd --log=error',
      \ 'cpp': 'clangd --log=error',
      \}
  else
    let g:lsc_server_commands = {
      \ 'typescript': 'typescript-language-server.cmd --stdio --log-level 4',
      \ 'javascript': 'typescript-language-server.cmd --stdio --log-level 4',
      \ 'typescriptreact': 'typescript-language-server.cmd --stdio --log-level 4',
      \ 'javascriptreact': 'typescript-language-server.cmd --stdio --log-level 4',
      \}
  endif
endfunction

call s:configure_lsp()

command! ToggleLspServer let g:lsp_server = (g:lsp_server ==# 'deno' ? 'ts' : 'deno') | call s:configure_lsp()
nnoremap <leader>ls :ToggleLspServer<cr>

let g:lsc_auto_map = v:true
let g:lsc_enable_diagnostics = v:true
