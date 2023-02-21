# Search through directories

Hae vain tietyistä tiedostoista
```bash
grep -r --include=*.{Rmd,R} 'hetukeitto' .
```


If you're looking for lines matching in files, my favorite command is:

```bash
grep -Hrn 'search term' path/to/files
```
- -H causes the filename to be printed (implied when multiple files are searched)
- -r does a recursive search
- -n causes the line number to be printed
path/to/files can be . to search in the current directory

Further options that I find very useful:

- -I ignore binary files (complement: -a treat all files as text)
- -F treat search term as a literal, not a regular expression
- -i do a case-insensitive search
- --color=always to force colors even when piping through less. To make less support colors, you need to use the -r option:

grep -Hrn search . | less -r
