<div align="center">

[![Linktree](https://img.shields.io/badge/linktree-1de9b6?logo=linktree&style=flat-square&color=029900)](https://www.sousastep.quest/links/)

</div>


<a href="#studio_microphone-introduction">![rainbow](./media/rainbow.png)</a>

# :studio_microphone: Introduction

This repository contains ai-generated rnbo codebox~ effects that I intend to incorporate into [SousaFX-rnbo](https://github.com/Sousastep/SousaFX-rnbo).

papers_library/ contains academic PDFs (mainly DAFx) that are downloaded with tools/fetch_papers.py and converted into a corpus with tools/build_corpus.py that can be explored with tools/search.py

repos/ contains some choice submodules of open-source fx to port from.

generated_fx/ contains the ai fx. A prompt such as "Convert JSFXClones" would likely work just fine, given the AGENTS.md file. The fx are verified with tools/verify_codebox.js

generated_maxpat/ and generated_v8ui/ are gitignored and generated from the scripts in tools/generate_maxpats.py and tools/generate_v8uis.py

main_test_patcher.maxpat loads the generated maxpats and v8uis via file_list.html in jweb. Star ratings in jweb are saved to ratings.json

The gh-pages branch contains one html file that displays data from generated_fx/ and ratings.json via https://aifx.sousastep.quest/ 

If you find an effect useful, consider donating to whoever is cited as the originator :pray:


<a href="#books-disclaimer">![rainbow](./media/rainbow.png)</a>

# :books: Disclaimer

sousa_fx_generator is an independent project unaffiliated with, 
endorsed by, or sponsored by any of the companies, authors, or their respective trademarks.

All product names, trademarks, and registered trademarks mentioned or implied
in sousa_fx_generator are the property of their respective owners. Any
reference to commercial products is for descriptive purposes only and does
not constitute an endorsement or affiliation.


<a href="#lock_with_ink_pen-licenses">![rainbow](./media/rainbow.png)</a>

# :lock_with_ink_pen: Licenses

All fx generated from repos/ maintain their original license, of course.

With respect to any other code in this repo, in place of a legal notice, here is a blessing:

> May you do good and not evil.

> May you find forgiveness for yourself and forgive others.

> May you share freely, never taking more than you give.


<a href="#studio_microphone-introduction">![rainbow](./media/rainbow.png)</a>
