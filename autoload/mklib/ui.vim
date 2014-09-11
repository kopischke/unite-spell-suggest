" mklib.vim - another VimL non-standard library
" Maintainer: Martin Kopischke <http://martin.kopischke.net>
" License:    same as Vim (:h license)

" Echo a highlighted message, optionally as a true message:
" @signature:  mklib#ui#echo({message:String}[, {options:Dictionary}])
" @options:    'log'    1 to echo a true message (default: 0)
"              'group'  highlight group to use (default: None)
function! mklib#ui#echo(message, ...) " {{{
  let l:opts = a:0 ? a:1 : {}
  let l:echo_cmd = get(l:opts, 'log', 0) ? 'echomsg' : 'echo'
  execute 'echohl' get(l:opts, 'group', 'None')
  try
    execute l:echo_cmd '"'.a:message.'"'
  finally
    echohl None
  endtry
endfunction " }}}

" Convenience wrappers around mklib#ui#echo() {{{
" * echo a message highlighted as WarningMsg
function! mklib#ui#warn(message)
  call mklib#ui#echo(a:message, {'group': 'WarningMsg'})
endfunction

" * echomsg a message highlighted as WarningMsg
function! mklib#ui#warnmsg(message)
  call mklib#ui#echo(a:message, {'log': 1, 'group': 'WarningMsg'})
endfunction " }}}

" vim:set sw=2 sts=2 ts=8 et fdm=marker fdo+=jump fdl=0:
