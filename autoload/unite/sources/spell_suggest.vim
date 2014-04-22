" unite-spell-suggest.vim - a spelling suggestion source for Unite
" Maintainer: Martin Kopischke <http://martin.kopischke.net>
"             based on work by MURAOKA Yusuke <yusuke@jbking.org>
" License:    MIT (see LICENSE.md)
" Version:    1.0
if !has('spell') || &compatible || v:version < 700
  finish
endif

" 'spell_suggest' source: spelling suggestions for Unite
function! unite#sources#spell_suggest#define()
  return get(s:, 'unite_source', [])
endfunction

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

  " highlight replaceable word
  function! s:cword.highlight() dict
    try
      highlight default link uniteSource_spell_suggest_Replaceable Search
      let self.hi_id = matchadd('uniteSource_spell_suggest_Replaceable',
        \ '^\%'.self.lnum.'l\M'.self.before.'\zs'.self.word)
    catch
      let self.hi_id = 0
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
      let l:kind  = 'substitution'
      call s:cword.highlight()
    else
      let l:kind  = 'word'
    endif

    let l:limit       = get(g:, 'unite_spell_suggest_limit', 0)
    let l:suggestions = l:limit > 0 ? spellsuggest(l:word, l:limit) : spellsuggest(l:word)
      \  "kind": l:kind}')
  endif
  return map(l:suggestions,
    \'{"word"               : v:val,
    \  "abbr"               : printf("%2d: %s", v:key+1, v:val),
    \  "kind"               : l:kind,
    \  "source__target_word": l:word}')
endfunction

" * syntax highlighting
function! s:unite_source.hooks.on_syntax(args, context)
  syntax match uniteSource_spell_suggest_LineNr /^\s\+\d\+:/
  highlight default link uniteSource_spell_suggest_LineNr LineNr
endfunction

" * remove replaceable word highlighting on close
function! s:unite_source.hooks.on_close(args, context)
  if s:cword.hi_id > 0
    execute 'autocmd BufEnter <buffer='.s:cword.bufnr.'> call matchdelete('.s:cword.hi_id.') | autocmd! BufEnter <buffer>'
  endif
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
