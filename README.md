## Unite spelling suggestion source

A [unite.vim](https://github.com/Shougo/unite.vim) source that displays Vim’s spelling suggestions for a word.

### Usage

No Vim documentation, but `:Unite spell_suggest[:word]` will display a list of suggestions in the Unite interface. The selected candidate will replace the current word, if applicable, else Unite’s default word handling applies. The replaceable word is highlighted in the buffer to provide visual feedback.

* an argument of `?` will prompt for a word to base suggestions on;
* without an argument, suggestions are based on the current word (Vim’s `<cword>`, which is not strictly equivalent to the word under the cursor);
* the highlighting group for the replaceable word is `uniteSource_spell_suggest_Replaceable`, which is linked to `Search` by default; 
* set `g:unite_spell_suggest_limit` to limit the number of suggestions retrieved by Vim’s `spellsuggest()` (by default, this variable is unset).

### Caveats

Vim’s `spellsuggest()` only returns suggestions if `spell` is set in the current buffer (see `:h spellsuggest()`), and hence the Unite source will remain empty if it is unset. Use the `-no-empty` option to skip empty suggestion lists.

The replace operation *will* take multi-byte characters in the word to be replaced in stride; its correctness when replacing double wide characters, however, has not been tested (reports are welcome).
