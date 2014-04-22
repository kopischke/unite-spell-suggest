" mklib.vim - another VimL non-standard library
" Maintainer: Martin Kopischke <http://martin.kopischke.net>
" License:    same as Vim (:h license)
" Version:    0.1.0

" Trim leading and trailing white space
function! mklib#string#trim(string)
  return matchstr(a:string, '\S.\+\S')
endfunction

" vim:set sw=2 sts=2 ts=8 et fdm=marker fdo+=jump fdl=1:
