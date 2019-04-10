In this assignment, you will implement pieces of a UNIX shell, and get some familiarity with  some UNIX library calls and the UNIX process model. By the end of the assignment, you will  have a shell that can run complex pipelines of commands, such as:  $ cat /usr/share/dict/words | grep cat | sed s/cat/dog/ > doggerel.txt  The above pipeline takes​ /usr/share/dict/words​ (a file generally installed on  UNIX systems that contains a list of English words), selects out the words containing the  
string "cat", and then uses sed to replace "cat" with "dog", so that, for example,  
"concatenate" becomes "condogenate". The results are output to "doggerel.txt". (You can  
find detailed descriptions of each of the commands in the pipeline by consulting the  
manual page for the command; e.g.: "man grep" or "man sed".)  
Start by downloading the ​shell.c​ skeleton file attached to this homework. You don't have  
to understand how the parser works in detail, but you should have a general idea of how the  
flow of control works in the program. You will also see the ​"// your code here"  
comments, which is where you will implement the functionality to make the shell actually  
work.  
Next, try to compile the source code to the shell:  $ gcc shell.c -o shell  
 
You can then run and interact with the shell by typing ​./shell :  
 user@cs6233:~$ ./shell cs6233> ls exec not implemented cs6233>  ​Note: ​The command prompt for our shell is set to ​cs6233​>​ to make it easy to tell the  difference between it and the Linux/macOS shell. You can quit your shell by typing Control-C or  Control-D.
