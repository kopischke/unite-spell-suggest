" unite-spell-suggest.vim - a spelling suggestion source for Unite
" Maintainer: Martin Kopischke <http://martin.kopischke.net>
"             based on work by MURAOKA Yusuke <yusuke@jbking.org>
" License:    MIT (see LICENSE.md)
" Version:    1.1.0
if !has('spell') || &compatible
  finish
endif

let s:old_cpo = &cpo
set cpo&vim " ensure we can use line continuation

" 'spell_suggest' source: spelling suggestions for Unite
function! unite#sources#spell_suggest#define()
  return get(s:, 'unite_source', [])
endfunction

let s:unite_source = {
  \ 'name'       : 'spell_suggest',
  \ 'description': 'candidates from spellsuggest()',
  \ 'hooks'      : {},
  \ }

" * candidate listing
function! s:unite_source.gather_candidates(args, context) abort
  " get word to base suggestions on
  if len(a:args) == 0
    let s:cword = s:do_outside_unite(a:context, function('s:cword_info'))
    let l:word  = s:cword.word
    let l:kind  = s:cword.modifiable ? 'suggestion' : 'word'
  else
    let s:cword = {}
    let l:word  = mklib#string#trim(
    \   a:args[0] == '?'
    \   ? input('Suggest spelling for: ', '', 'history')
    \   : a:args[0]
    \ )
    let l:kind  = 'word'
  endif

  " get suggestions
  let l:suggestions = s:do_outside_unite(a:context, function('spellsuggest'), l:word)
  return map(l:suggestions, '{
  \                     "word": v:val,
  \                     "kind": l:kind,
  \                     "abbr": printf("%2d: %s", v:key+1, v:val),
  \      "source__target_word": l:word,
  \ "source__suggestion_index": v:key+1
  \ }')
endfunction

" * syntax highlighting
function! s:unite_source.hooks.on_syntax(args, context)
  syntax match uniteSource_spell_suggest_LineNr /^\s\+\d\+:/
  highlight default link uniteSource_spell_suggest_LineNr LineNr
endfunction

" * set up handling autocmd groups
function! s:unite_source.hooks.on_init(args, context)
  if !empty(a:context) && empty(a:args)
    if a:context.split
      " live sync setup
      let s:context = a:context
      augroup unite_spell_suggest
        autocmd!
        autocmd BufEnter,CursorMoved,CursorMovedI * call s:unite_source.source__update()
      augroup END
    elseif &startofline
      " cursor position restoration
      let l:autocmd_group = 'unite_spell_suggest_nosplit:'.bufnr('%')
      execute 'augroup '.l:autocmd_group
        autocmd!
        execute 'autocmd BufWinEnter <buffer> call winrestview('
        \ .string(winsaveview())
        \ .') | autocmd! '.l:autocmd_group
      augroup END
    endif
  endif
endfunction

" * remove live sync autocmd group
function! s:unite_source.hooks.on_close(args, context)
  call s:unite_source.source__cleanup()
endfunction

" * trigger suggestion update if cword changes
function! s:unite_source.source__update() dict
  try
    if &spell && empty(&buftype) && s:cword != s:cword_info()
      call unite#force_redraw(unite#helper#get_unite_winnr(s:context.buffer_name))
    endif
  catch
    call s:unite_source.source__cleanup()
  endtry
endfunction

" * clean up after source
function! s:unite_source.source__cleanup() dict
  silent! autocmd! unite_spell_suggest
  silent! augroup! unite_spell_suggest
endfunction

" Helper functions: {{{1
" * get info about word under cursor
"   (making sure we are looking at the same word as `z=` along the way)
function! s:cword_info() abort
  return {
  \       'word': mklib#cursor#spellstatus()[0],
  \ 'modifiable': &modifiable
  \ }
endfunction

" * execute function out of Unite context
function! s:do_outside_unite(unite_context, funcref, ...) abort
  let l:unite_winnr = !empty(a:unite_context)
  \ ? unite#helper#get_unite_winnr(a:unite_context.buffer_name)
  \ : -1
  if l:unite_winnr > -1 && winnr() == l:unite_winnr
    wincmd p
    try
      return call(a:funcref, a:000)
    finally
      execute l:unite_winnr.'wincmd w'
    endtry
  else
    return call(a:funcref, a:000)
  endif
endfunction " }}}

let &cpo = s:old_cpo

" vim:set sw=2 sts=2 ts=8 et fdm=marker fdo+=jump fdl=1:
