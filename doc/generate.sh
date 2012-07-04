#!/bin/sh

(cd doc && asciidoc -b html5 -a icons -a toc2 -a theme=flask -a pygments index.asciidoc)
