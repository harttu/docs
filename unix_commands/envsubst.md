envsubst
===
Suppose you have a file called template.txt that contains the following text:
```
Hello, my name is $${NAME} and I am $${AGE} years old.
```
And you have the following environment variables set:
```
NAME=John
AGE=30
```
You can use envsubst to replace the placeholders in the template with their corresponding values like this:
```bash
$ envsubst '$${NAME} $${AGE}' < template.txt
```
This command would output the following:
__Hello, my name is John and I am 30 years old.__

You can also redirect the output to a new file
```bash
$ envsubst '$${NAME} $${AGE}' < template.txt > newfile.txt
```
This command would create a newfile.txt with the output of the command above.
