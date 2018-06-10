[![Project status][badge-status]][vimscripts]
[![Current release][badge-release]][releases]
[![Open issues][badge-issues]][issues]
[![License][badge-license]][license]

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

[badge-status]: http://img.shields.io/badge/status-EOL-red.svg?style=flat-square
[badge-release]: http://img.shields.io/github/release/kopischke/unite-spell-suggest.svg?style=flat-square
[badge-issues]: http://img.shields.io/github/issues/kopischke/unite-spell-suggest.svg?style=flat-square
[badge-license]: http://img.shields.io/badge/license-MIT-blue.svg?style=flat-square
[doc]:      doc/unite-spell-suggest.txt
[issues]: https://github.com/kopischke/unite-spell-suggest/issues
[license]:  LICENSE.md
[releases]: https://github.com/kopischke/unite-spell-suggest/releases
[unite]:    https://github.com/Shougo/unite.vim
[vimscripts]: http://www.vim.org/scripts/script.php?script_id=4929
