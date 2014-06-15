" unite-spell-suggest.vim - a spelling suggestion source for Unite
" Maintainer: Martin Kopischke <http://martin.kopischke.net>
"             based on work by MURAOKA Yusuke <yusuke@jbking.org>
" License:    MIT (see LICENSE.md)
" Version:    1.0.0
if &compatible || v:version < 700
  finish
endif

" 'substitution' Unite kind: allows replacing of the word under the cursor.
" Can be constrained to a defined target by giving the candidate
" a 'source__target_word' key.
function! unite#kinds#substitution#define()
  return get(s:, 'unite_kind', [])
endfunction

let s:unite_kind                = {'name': 'substitution'}
let s:unite_kind.default_action = 'replace'
let s:unite_kind.action_table   = {
  \ 'replace':
  \   {'description': "replace the current target word with the candidate"},
  \ 'replace_all':
  \   {'description': "replace all occurrences of the target word with the candidate"}
  \ }

" * 'replace' [occurrence of target under cursor] action
function! s:unite_kind.action_table.replace.func(candidate) abort
  let l:target = s:get_target(a:candidate)
  if !empty(l:target) && s:get_cword() ==# l:target
    " extract leading and trailing line parts using regexes only, as string
    " indexes are byte-based and thus not multi-byte safe to iterate
    let l:line = getline('.')
    let l:col  = col('.')
    if match(l:target, '\M'.mklib#text#curchar().'$') != -1 && match(l:target, '\M'.mklib#text#nextchar()) == -1
      " we are on the last character, but not on the end of the line:
      " using matchend() to the end of a word would get us the next word
      " instead of the current one
      let l:including = matchstr(l:line, '^.*\%'.l:col.'c.')
    else
      " we are somewhere inside, or before (as '<cword>' skips non-word
      " characters to get the next word), the word: use matchend() to locate the
      " end of the word (note: multi-byte alphabetic characters do not match
      " any word regex class, so we can't test for '\w')
      let l:including = l:line[: matchend(l:line[l:col :], '^.\{-}\(\>\|$\)') + l:col]
      " we get a trailing character everywhere but on line end: strip that
      if match(l:line, '\M'.l:target.'$') == -1
        let l:including = substitute(l:including, '.$', '', '')
      endif
    endif
    let l:before = substitute(l:including, '\M'.l:target.'$', '', '')
    let l:after  = substitute(l:line, '^\M'.l:including, '', '')
    call setline('.', l:before . a:candidate.word . l:after)
  endif
endfunction

" * 'replace all' [occurrences of target] action
function! s:unite_kind.action_table.replace_all.func(candidate) abort
  let l:target = s:get_target(a:candidate)
  if &gdefault == 0
    let l:gflag = 'g'
  else
    let l:gflag = ''
  endif
  if !empty(l:target)
    let l:save_view = winsaveview()
    execute '% substitute/\<'.l:target.'\>/'.a:candidate.word.'/I'. l:gflag
    call winrestview(l:save_view)
  endif
endfunction

" Helper functions {{{1
function! s:get_target(candidate)
  return get(a:candidate, 'source__target_word', s:get_cword())
endfunction

function! s:get_cword()
  return mklib#string#trim(expand('<cword>'))
endfunction " }}}

" vim:set sw=2 sts=2 ts=8 et fdm=marker fdo+=jump fdl=1:
