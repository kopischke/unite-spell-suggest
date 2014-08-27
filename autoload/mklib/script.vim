" mklib.vim - another VimL non-standard library
" Maintainer: Martin Kopischke <http://martin.kopischke.net>
" License:    same as Vim (:h license)

" Parse an argument List into the arguments proper and an eventual trailing
" options Dictionary (allows for variable length argument lists with the
" options Dictionary always coming last):
" @signature:  mklib#script#optparse({args:List}[, {max_args:Number}])
" @returns:    a Dictionary with two keys:
"             'args': the List of arguments without the options Dictionary
"             'opts': the options Dictionary
" @exceptions: E605 if {args} is not a List
function! mklib#script#optparse(args, ...) abort " {{{
  if !mklib#script#islist(a:args)
    throw "Arguments must be passed as List: ".string(a:args)
  endif
  let l:args = copy(a:args)[: get(a:, 1, 0)-1]

  " a trailing Dictionary is always an opts Dictionary
  if mklib#script#isdict(l:args[-1])
    let l:opts = l:args[-1]
    let l:args = l:args[:-2]
  else
    let l:opts = {}
  endif
  return {'args': l:args, 'opts': l:opts}
endfunction " }}}

" Join an arbitrary number of {cmd} Strings or Lists into a one-line command:
" @signature:  mklib#script#joincmd({cmd:String|List}[, {cmd}[, ...]])
" @returns:    String usable for :execute
" @notes:      List {cmd} arguments are only flattened one level
function! mklib#script#joincmd(...) abort " {{{
  let l:sep  = ' | '
  let l:cmds = a:0 ? deepcopy(a:000) : []
  return join(map(l:cmds, 'mklib#script#islist(v:val) ? join(v:val, l:sep) : v:val'), l:sep)
endfunction " }}}

" Parse the output of {cmd} into a List by splitting on {sep}:
" @signature:  mklib#script#out2list({cmd:String}[, {sep:String}])
" @returns:    List of {cmd} output split on {sep} ('\n' if omitted)
" @notes:      execution of {cmd} is silent
function! mklib#script#out2list(cmd, ...) abort " {{{
  try
    redir => l:out
    silent execute a:cmd
  finally
    redir END
  endtry
  return split(l:out, a:0 ? a:1 : '\n')
endfunction " }}}

" Find script number by file name:
" @signature:  mklib#script#sid({script_path:String})
" @returns:    Number: the SID isf found, else -1
" @notes:      see http://stackoverflow.com/a/24027507
function! mklib#script#sid(script_path) abort " {{{
  let l:script    = expand(a:script_path)
  let l:funcmatch = matchstr(l:script,'^function <SNR>\zs\d\+\ze_')
  if !empty(l:funcmatch)
    return l:funcmatch
  else
    let l:scripts = mklib#script#out2list('scriptnames')
    let l:files   = map(copy(l:scripts), 'expand(split(v:val, ":\\s\\+")[1])')
    let l:index   = mklib#collection#match(
    \   l:files,
    \   fnamemodify(l:script, ':p'),
    \   {'ignorecase': 0, 'full': 1, 'pattern': 0}
    \ )
    return l:index > -1 ? str2nr(split(l:scripts[l:index], ':')[0]) : -1
  endif
endfunction " }}}

" Type checking convenience functions:
" @signature:  mklib#script#is{type}({value:Any})
" @returns:    1 if {value} is of {type}
" @notes:      Dictionary {type} is abbreviated to 'dict'
" {{{
function! mklib#script#isstring(value) abort
  return type(a:value) == type('')
endfunction

function! mklib#script#isnumber(value) abort
  return type(a:value) == type(1)
endfunction

function! mklib#script#isfloat(value) abort
  return type(a:value) == type(1.0)
endfunction

function! mklib#script#islist(value) abort
  return type(a:value) == type([])
endfunction

function! mklib#script#isdict(value) abort
  return type(a:value) == type({})
endfunction

function! mklib#script#isfuncref(value) abort
  return type(a:value) == type(function('tr'))
endfunction " }}}

" vim:set sw=2 sts=2 ts=8 et fdm=marker fdo+=jump fdl=0:
