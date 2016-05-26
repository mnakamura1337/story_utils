A few useful tools for dealing with translation of visual novels in
story format.

## translate_story2yaml

Usage: translate_story2yaml in.story trans.yaml

Generates a YAML file `trans.yaml` for translation with all the text
strings in a story file `in.story`.

## translate_yaml2story

Usage: translate_story2yaml in.story trans.yaml out.story

Merges back translation prepared in a YAML file into story. Requires
original story file (`in.story`) and YAML translation file
(`trans.yaml`) and generates new story file (`out.story`) with all the
contents of original story file and translations merged from
`trans.yaml` file.

## story_merge

Usage: story_merge 1.story 2.story ... >out.story

Merges several stories together, dumps resulting story to stdout
(usually should be redirected to a file). `meta` must match fully,
`imgs` and `chars` should be non-conflicting (i.e. there shouldn't be
different values for the same key), `script` entries will be appended
in an order of stories specified in command line.
