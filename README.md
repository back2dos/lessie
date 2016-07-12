[![Build Status](https://travis-ci.org/back2dos/lessie.svg?branch=master)](https://travis-ci.org/back2dos/lessie)

# Lessie - builds your less stylesheets for you

Lessie is a helper for making it easier to build less files.

The basic idea is to allow adding `@:less("<filePath>")` to any class and have Lessie deal with the rest. Lessie will then find all these occurence, discard those eliminated by DCE, and finally generate output. 

By default, lessie will assume you're using the compiler server and therefore remember the less files included (as well as their dependencies) and will not compile them again until they change, i.e. their mtime is updated. You can opt out of this behavior by `-D forceLessie`.

The default output is a `styles.css` located "next to" your output. You can overwrite this with `-D lessieOutput=/absolute/path` or `-D lessieOutput=./path/relative/to/cwd` or `-D lessieOutput=path/relative/to/output`.

## Postprocessing

You may wish to use CSS postprocessors. To do so, register a callback with `lessie.Lessie.postProcess` (must be called from a macro). You will be given the name of the generated file and can do pretty much whatever you want (autoprefix, minify, etc.)