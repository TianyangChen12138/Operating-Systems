In this assignment, you will implement pieces of a UNIX shell, and get some familiarity with  some UNIX library calls and the UNIX process model. By the end of the assignment, you will  have a shell that can run complex pipelines of commands, such as:  

$ cat /usr/share/dict/words | grep cat | sed s/cat/dog/ > doggerel.txt  

The above pipeline takes /usr/share/dict/words (a file generally installed on UNIX systems that contains a list of English words), selects out the words containing the string "cat", and then uses sed to replace "cat" with "dog", so that, for example, "concatenate" becomes "condogenate". The results are output to "doggerel.txt".

Next, try to compile the source code to the shell:  $ gcc shell.c -o shell  

You can then run and interact with the shell by typing ./shell :  

user@cs6233:~$ ./shell 

cs6233> ls 
exec not implemented 

You can quit your shell by typing Control-C or  Control-D.
