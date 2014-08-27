## Unite spelling suggestion source

A [unite.vim][unite] source that displays Vim’s spelling suggestions for a word, updating live as the word under the cursor changes, and offering convenient replacement functionality to allow it to stand in stead of Vim’s `z=`.

If you have wished there was a slicker, less obtrusive interface than Vim’s modal full-screen one to spelling suggestions and corrections, *unite-spell-suggest* is for you.

### Installation

1. The old way: download and source the vimball from the [releases page][releases], then run `:helptags {dir}` on your runtimepath/doc directory. Or,
2. The plug-in manager way: using a git-based plug-in manager (Pathogen, Vundle, NeoBundle etc.), simply add `kopischke/unite-spell-suggest` to the list of plug-ins, source that and issue your manager's install command.

### Usage

TL;DR: `:Unite spell_suggest`. For more, see the [documentation][doc].

### License

*unite-spell-suggest* is licensed under [the terms of the MIT license according to the accompanying license file][license].

[doc]:      doc/unite-spell-suggest.txt
[license]:  LICENSE.md
[releases]: https://github.com/kopischke/unite-spell-suggest/releases
[unite]:    https://github.com/Shougo/unite.vim
