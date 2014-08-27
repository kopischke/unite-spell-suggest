" unite-spell-suggest.vim - a spelling suggestion source for Unite
" Maintainer: Martin Kopischke <http://martin.kopischke.net>
"             based on work by MURAOKA Yusuke <yusuke@jbking.org>
" License:    MIT (see LICENSE.md)
" Version:    1.0.0
if !has('spell') || &compatible
  finish
endif

let s:old_cpo = &cpo
set cpo&vim " ensure we can use line continuation

function! unite#kinds#suggestion#define()
  return get(s:, 'unite_kind', [])
endfunction

" 'suggestion' Unite kind: spelling suggestions from Vim's spell checker
let s:unite_kind                = {'name': 'suggestion'}
let s:unite_kind.default_action = 'replace'
let s:unite_kind.action_table   = {
\ 'replace':
\   {'description': "replace the target word with the suggested suggestion"},
\ 'replace_all':
\   {'description': "replace all occurrences of the target word with the suggested suggestion"}
\ }

" * 'replace' [occurrence of target under cursor] action
function! s:unite_kind.action_table.replace.func(candidate) abort
  if !empty(a:candidate.source__target_word)
\ && mklib#string#trim(expand('<cword>')) ==# a:candidate.source__target_word
    execute 'normal' a:candidate.source__suggestion_index.'z='
    return 1
  endif
  return 0
endfunction

" * 'replace all' [occurrences of target] action
function! s:unite_kind.action_table.replace_all.func(candidate) abort
  if s:unite_kind.action_table.replace.func(a:candidate)
    try
      execute 'spellrepall'
      return 1
    catch /^Vim\%((\a\+)\)\=:E753/
      " `:spellrepall`throws E753 when there are no more words to replace
      return 1
    endtry
  endif
  return 0
endfunction

let &cpo = s:old_cpo

" vim:set sw=2 sts=2 ts=8 et fdm=marker fdo+=jump fdl=1:
