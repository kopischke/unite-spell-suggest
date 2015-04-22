" Autoload utility module for unite-spell-suggest
" Maintainer: Martin Kopischke <http://martin.kopischke.net>
" License:    MIT (see LICENSE.md)
" Version:    1.1.2

" Check if the compatibility requirements for unite-spell-suggest are met:
" @signature:  spellsuggest#compatible()
" @returns:    Boolean
function! spellsuggest#compatible() abort
  return has('spell') && &compatible is 0
endfunction

" Get the current word according to the spell checker:
" @signature:  spellsuggest#cword()
" @returns:    String
function! spellsuggest#cword() abort
  if &spell && exists('*spellbadword')
    let l:curpos = getpos('.')
    try
      let l:spellword = spellbadword()[0]
      " `spellbadword()` only moves left to the start of the word if currently on
      " a spelling error; if we are right of our position after calling it, it
      " has jumped to another error (see `:h spellbadword()`).
      if !empty(l:spellword) && col('.') <= l:curpos[2]
        return l:spellword
      endif
    finally
      noautocmd call setpos('.', l:curpos)
    endtry
  endif
  return expand('<cword>')
endfunction

" Remove trailing and leadings spaces from {string}:
" @signature:  spellsuggest#trimstr({string:String})
" @returns:    String
function! spellsuggest#trimstr(string) abort
  return matchstr(a:string, '^\m\s*\zs.\{-}\ze\s*$')
endfunction

" vim:set sw=2 sts=2 ts=2 et fdm=marker fmr={{{,}}}:
