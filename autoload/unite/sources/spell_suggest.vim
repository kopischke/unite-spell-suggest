"=============================================================================
" FILE: spell_suggest.vim
" AUTHOR:  MURAOKA Yusuke <yusuke@jbking.org>
"          Martin Kopischke <martin@kopischke.net>
" Last Change: 2014-04-10.
" License: MIT license  {{{1
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================
if !has('spell') || &compatible || !exists('*unite#define_kind')
  finish
endif

function! unite#sources#spell_suggest#define()
  return get(s:, 'unite_source', [])
endfunction

" Define 'substitution' kind: {{{1
" defined here because of its tight coupling to s:cword
let s:unite_kind_substitution                = {'name': 'substitution'}
let s:unite_kind_substitution.default_action = 'replace'
let s:unite_kind_substitution.action_table   = {
  \ 'replace':
  \   {'description': 'replace the current word with the candidate'},
  \ 'replace_all':
  \   {'description': 'replace all occurences of the current word with the candidate'}
  \ }

" * 'replace' [word under cursor] action
function! s:unite_kind_substitution.action_table.replace.func(candidate) abort
  if s:cword.focus() && match(getline(s:cword.lnum), '^\M' . s:cword.before . s:cword.word) == 0
    call setline(s:cword.lnum, s:cword.before . a:candidate.word . s:cword.after)
    call cursor(s:cword.lnum, len(s:cword.before) + len(a:candidate.word))
  endif
  call matchdelete(s:hi_id)
endfunction

" * 'replace all' [occurrences] action
function! s:unite_kind_substitution.action_table.replace_all.func(candidate) abort
  if s:cword.focus()
    execute '% substitute/\<'.s:cword.word.'\>/'.a:candidate.word.'/Ig'
  endif
endfunction

call unite#define_kind(s:unite_kind_substitution)

" Define 'spell_suggest' source: {{{1
let s:unite_source = {
  \ 'name'        : 'spell_suggest',
  \ 'description' : 'candidates from spellsuggest()',
  \ 'hooks'       : {},
  \ }

" * candidate listing
function! s:unite_source.gather_candidates(args, context) abort
  if &spell == 0
    return []
  endif

  " get info about word under cursor
  let s:cword       = {}
  let s:cword.word  = s:trim(expand('<cword>'))
  let s:cword.bufnr = bufnr('%')
  let s:cword.lnum  = line('.')
  let s:cword.col   = col('.')

  " return to position of word under cursor
  function! s:cword.focus() dict
    try
      execute 'buffer' self.bufnr
      if line('$') < self.lnum || col([self.lnum, '$']) < self.col
        return 0
      endif
      call cursor(self.lnum, self.col)
      return 1
    catch
      return 0
    endtry
  endfunction

  " extract leading and trailing line parts using regexes only, as string
  " indexes are byte-based and thus not multi-byte safe to iterate
  let l:line = getline(s:cword.lnum)
  if match(s:cword.word, '\M'.s:curchar().'$') != -1 && match(s:cword.word, '\M'.s:nextchar()) == -1
    " we are on the last character, but not on the end of the line:
    " using matchend() to the end of a word would get us the next word
    " instead of the current one
    let l:including = matchstr(l:line, '^.*\%'.s:cword.col.'c.')
  else
    " we are somewhere inside, or before (as '<cword>' skips non-word
    " characters to get the next word), the word: use matchend() to locate the
    " end of the word (note: multi-byte alphabetic characters do not match
    " any word regex class, so we can't test for '\w')
    let l:including = l:line[: matchend(l:line[s:cword.col :], '^.\{-}\(\>\|$\)') + s:cword.col]
    " we get a trailing character everywhere but on line end: strip that
    if match(l:line, '\M'.s:cword.word.'$') == -1
      let l:including = substitute(l:including, '.$', '', '')
    endif
  endif
  let s:cword.before = substitute(l:including, '\M'.s:cword.word.'$', '', '')
  let s:cword.after  = substitute(l:line, '^\M'.l:including, '', '')

  " get word to base suggestions on
  let l:word = len(a:args) > 0 ?
    \ a:args[0] == '?' ? s:trim(input('Suggest spelling for: ', '', 'history')) : a:args[0] :
    \ s:cword.word

  " get suggestions
  if l:word == ''
    return []
  else
    if s:cword.word != '' && &modifiable
      " we have a substitution: highlight it in the text for emphasis
      let l:kind  = 'substitution'
      highlight default link uniteSource_spell_suggest_Replaceable Search
      let s:hi_id = matchadd('uniteSource_spell_suggest_Replaceable',
        \ '^\%'.s:cword.lnum.'l\M'.s:cword.before.'\zs'.s:cword.word)
    else
      let l:kind  = 'word'
    endif

    let l:limit       = get(g:, 'unite_spell_suggest_limit', 0)
    let l:suggestions = l:limit > 0 ? spellsuggest(l:word, l:limit) : spellsuggest(l:word)
    return map(l:suggestions,
      \'{"word": v:val,
      \  "abbr": printf("%2d: %s", v:key+1, v:val),
      \  "kind": l:kind}')
  endif
endfunction

" * syntax highlighting
function! s:unite_source.hooks.on_syntax(args, context)
  syntax match uniteSource_spell_suggest_LineNr /^\s\+\d\+:/
  highlight default link uniteSource_spell_suggest_LineNr LineNr
endfunction

" Helper functions: {{{1
" * get character under cursor
function! s:curchar()
  return matchstr(getline('.'), '\%'.col('.').'c.')
endfunction

" * get character before the cursor
function! s:nextchar()
  return matchstr(getline('.'), '\%>'.col('.').'c.')
endfunction

" * get character after the cursor
function! s:prevchar()
  return matchstr(getline('.'), '.*\zs\%<'.col('.').'c.')
endfunction

" * trim leading and trailing whitespace
function! s:trim(string)
  return matchstr(a:string, '\S.\+\S')
endfunction
" }}}
" vim:set sw=2 sts=2 ts=8 et fdm=marker fdo+=jump fdl=1:
