" mklib.vim - another VimL non-standard library
" Maintainer: Martin Kopischke <http://martin.kopischke.net>
" License:    same as Vim (:h license)

" STRING HANDLING LIBRARY
" @notes:      all {string:Any} arguments are coerced to Vim Strings

" Convert non-String {value) into String:
" @signature:  mklib#string#string({value:Any})
" @returns:    String equivalent of {value}
" @notes:      unlike 'string()', this leaves String values untouched
function! mklib#string#string(value) abort " {{{
  return mklib#script#isstring(a:value) ? a:value : string(a:value)
endfunction " }}}

" Return a List of characters in {string};
" allows to iterate over characters instead of bytes:
" @signature:  mklib#string#chars({string:Any})
" @returns:    List of chars in order of {string}
function! mklib#string#chars(string) abort " {{{
  return split(mklib#string#string(a:string), '\zs')
endfunction " }}}

" Return a sub-String of {string} starting at {start}, with an
" optional length of {len} or until index {end}. If Vim is compiled with
" multi-byte support (+multi_byte), all indices are of *characters*, not bytes:
" @signature:  mklib#string#part({string:Any}, {start:Number}[, {end|len:Number}])
" @returns:    sub-String starting at {start} with length {len} or until {end}
function! mklib#string#part(string, start, ...) abort " {{{
  let l:len   = strchars(a:string)
  let l:start = a:start < 0 ? 0 : a:start
  let l:end   = a:0 ? (a:1 < 0 ? l:len + a:1 : a:1) : l:len - 1
  if has('multi_byte')
    return l:end < l:start ? '' : join(mklib#string#chars(a:string)[l:start : l:end], '')
  else
    return strpart(a:string, l:start, l:end)
  endif
endfunction " }}}

" Trim a leading and trailing {pattern} from {string}:
" @signature:  mklib#string#trim({string:Any}[, {pattern:String}])
" @returns:    {string} with leading and trailing matches of {pattern} removed
" @notes:      {pattern} defaults to whitespace if omitted
function! mklib#string#trim(string, ...) abort " {{{
  let l:string = mklib#string#string(a:string)
  return a:0 ?
  \ mklib#string#ltrim(mklib#string#rtrim(l:string, a:1), a:1) :
  \ matchstr(l:string, '\S.\+\S')
endfunction " }}} " }}}

" Like trim(), but only trim leading {pattern}:
" @signature:  mklib#string#ltrim({string:Any}[, {pattern:String}])
" @returns:    {string} with leading matches of {pattern} removed
" @notes:      {pattern} defaults to whitespace if omitted
function! mklib#string#ltrim(string, ...) abort " {{{
  let l:string = mklib#string#string(a:string)
  return a:0 ?
  \ substitute(l:string, '^\('.a:1.'\)\+', '', '') :
  \ matchstr(l:string, '\S.\+$')
endfunction " }}} " }}}

" Like trim(), but only trim trailing {pattern}:
" @signature:  mklib#string#rtrim({string:Any}[, {pattern:String}])
" @returns:    {string} with trailing matches of {pattern} removed
" @notes:      {pattern} defaults to whitespace if omitted
function! mklib#string#rtrim(string, ...) abort " {{{
  let l:string = mklib#string#string(a:string)
  return a:0 ?
  \ substitute(l:string, '\('.a:1.'\)\+$', '', '') :
  \ matchstr(l:string, '^.\+\S')
endfunction " }}} " }}}

" Ensure {string} is wrapped in {delimiter}:
" @signature:  mklib#string#wrap({string:Any}, {delimiter:String}[, {end_delimiter:String}])
" @returns:    {string} wrapped in {delimiter}, or {delimiter} left and {end_delimiter} right
" @notes:      delimiters are not added if {string} is already wrapped in them;
"              however, an unbalanced delimiter in {string} will be wrapped
" @examples:
" - mklib#string#wrap('Foo', '"')      => '"Foo"'
" - mklib#string#wrap('Foo', '>', '<') => '>Foo<'
" - mklib#string#wrap('"Foo"', '"')    => '"Foo"'
" - mklib#string#wrap('"Foo', '"')     => '""Foo"'
function! mklib#string#wrap(string, delimiter, ...) abort " {{{
  let l:string = mklib#string#string(a:string)
  let l:ldelim = a:delimiter
  let l:rdelim = a:0 ? a:1 : l:ldelim
  let l:string = substitute(l:string, '^\V'.l:ldelim.'\m\(.\{-}\)\V'.l:rdelim.'\$', '\1', '')
  return l:ldelim . l:string . l:rdelim
endfunction " }}} " }}}

" Capitalize {string}:
" @signature:  mklib#string#capitalize({string:String}[, {preserve:Number}])
" @returns:    {string} with the first letter upper case, the rest
"              - lower case if {preserve} is 0 or missing, i.e. 'fooBar' => 'Foobar'
"              - unmodified if {preserve} is 1,            i.e. 'fooBar' => 'FooBar'
function! mklib#string#capitalize(string, ...) abort " {{{
  let l:replace = '\u\1'.(get(a:, '1', 0) ? '\2' : '\L\2')
  return substitute(a:string, '^\(\S\)\(\S\+\)$', l:replace, '')
endfunction " }}} " }}}

" Return a pattern matching {string} case independently:
" @signature:  mklib#string#uncase({string:String})
" @returns:    a pattern String
" @examples:   'Foo-bar' => '[Ff][Oo][Oo][-][Bb][Aa][Rr]'
function! mklib#string#uncase(string) abort " {{{
  return substitute(
  \   '['.join(
  \     map(
  \       mklib#string#chars(a:string),
  \       'tolower(v:val) !=#  toupper(v:val) ? toupper(v:val).tolower(v:val) : v:val'
  \     ), ']['
  \   ).']', '\[\\\]', '\[\\\\\]', 'g'
  \ )
endfunction " }}} " }}}

" Extract a list of matches for {pattern} from {string}:
" @signature:  mklib#string#extract({string:Any}, {pattern:String}[, {unique:Number}])
" @returns:    a List of matches for {pattern}, de-duplicated if {unique} is 1
function! mklib#string#extract(string, pattern, ...) abort " {{{
  let l:string = mklib#string#string(a:string)
  let l:parts  = []
  while match(l:string, a:pattern, 0, len(l:parts)+1) > -1
    call add(l:parts, matchstr(l:string, a:pattern, 0, len(l:parts)+1))
  endwhile
  return a:0 && a:1 ? uniq(sort(l:parts)) : l:parts
endfunction " }}} " }}}

" Parse a String into a Dictionary of items matching {pattern}
" and of items not matching {pattern}, both indexed by position:
" @signature:  mklib#string#splice({string:Any}, {pattern:String})
" @returns:    a Dictionary with two keys:
"              -'matching': all {string} segments matching {pattern},
"                keyed by positional index in {string}
"              -'rest': all {string} segments not matching {pattern},
"                keyed by positional index in {string}
"              and these member functions:
"              - sets(): returns a List of all keys whose values are Dictionaries
"              - keys(): returns all keys of all sets, as Numbers, in numerical order
"              - len(): returns the sum count of all keys of all sets
"              - item({key}): returns the value for any index in keys()
"              - join([{string}]): returns a String of all items in order of keys()
" @exceptions: E605 in item() if {key} is not in either 'expr' or 'literal'
" @examples:   mklib#string#splice('fooBarBaz', '[Bb]ar') =>
"              {'matching': {'3': 'Bar'}, 'rest': {'0': 'foo', '6': 'Baz'}}
"              (funcrefs omitted for brevity)
function! mklib#string#splice(string, pattern) abort " {{{
  let l:string = mklib#string#string(a:string)

  " shortcut empty arguments
  let l:spliced = {'matching': {}, 'rest': {}}
  if empty(l:string) || empty(a:pattern)
    let l:spliced.rest = {'0': a;string}
    return l:spliced
  endif

  " gather segments
  let l:index    = match(l:string, a:pattern)
  let l:cursor   = 0
  while l:index > -1
    let l:match  = matchstr(l:string, a:pattern, l:cursor)
    let l:spliced.matching[l:index] = l:match
    let l:spliced.rest[l:cursor]    = substitute(l:string[l:cursor : l:index], '.$', '', '')
    let l:cursor = l:index + len(l:match)
    let l:index  = match(l:string, a:pattern, l:cursor)
  endwhile

  " gather trailing rest, trim empty head and tail
  let l:spliced.rest[l:cursor] = l:string[l:cursor :]
  call filter(l:spliced.rest, '!empty(v:val)')

  function l:spliced.sets()
    return filter(keys(self), 'mklib#script#isdict(self[v:val])')
  endfunction

  " all keys in 'rest' and 'matching', as Numbers, in numerical order
  function l:spliced.keys() dict abort
    let l:keys = []
    for l:key in self.sets()
      let l:keys += keys(self[l:key])
    endfor
    return sort(map(l:keys, 'str2nr(v:val)'), 'mklib#numeric#compare')
  endfunction

  " count of all keys in 'rest' and 'matching'
  function l:spliced.len() dict abort
    return len(self.keys())
  endfunction

  " items indexed by keys(), independently of their location
  function l:spliced.item(key) dict abort
    let l:keys = []
    for l:key in self.sets()
      if has_key(self[l:key], a:key)
        let l:item = self[l:key][a:key]
        break
      endif
    endfor
    if exists('l:item')
      return l:item
    endif
    throw "Not a valid key: ".string(a:key)
  endfunction

  " reconstructed String of all items
  function l:spliced.join(...) dict abort
    return join(map(self.keys(), 'self.item(v:val)'), a:0 ? a:1 : '')
  endfunction

  return l:spliced
endfunction " }}} " }}}

" vim:set sw=2 sts=2 ts=8 et fdm=marker fdo+=jump fdl=0:
