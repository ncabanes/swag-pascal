{

Q:  How can I readln() from a file when the lines are longer
than 255 bytes?

A:  ReadLn will accept an array [0..something] of Char as
buffer to put the read characters in and it will make a proper
zero-terminated char out of them. The only limitation is this:
the compiler needs to be able to figure out the size of the
buffer at compile time, which makes the use of a variable
declared as PChar and allocated at run-time impossible.

Workaround:
}

 Type
   {use longest line you may encounter here}
   TLine = Array [0..1024] of Char; 

   PLine = ^TLine;

 Var
   pBuf: PLine;
 ...
   New( pBuf );

 ...
   ReadLn( F, pBuf^ );

To pass pBuf to functions that take a parameter of type Pchar, 
use a typecast like PChar( pBuf ).

Note:  you can use a variable declared as of type TLine or an
equivalent array of char directly, of course, but I tend to
allocate anything larger than 4 bytes on the heap...
