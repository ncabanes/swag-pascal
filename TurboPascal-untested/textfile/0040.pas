{
The most important thing when processing text files is to allocate
a large buffer for reading & writing the files.  By default, TP
allocates 2k for reads & writes. Increasing this buffer to as little
(111 min left), (H)elp, More? as 10k significantly speeds up programs.
Using larger text buffers is painless: you simply set a text buffer.
Before closing the files, you really should do a flush() on any output
text file you're buffering.

The following code segment is what I use in my programs to establish
the largest possible text buffer (64k-8, if memory available):
The lines below create a maximum size file buffer for a text file from
memory available on the heap.  Once the buffer has been created and assigned
to the file, i/o can proceed with normal READLN commands.
The buffer is automatically created to the maximum possible size permitted
by TP (64k - 8 bytes), or the largest size permitted by available memory.

"Tbuffsize" can be any variable of type LongInt.  It is only used during
the creation of the buffer and can be reused for any purpose.
}

{Declarations..}

Var
  Target    : Text;    { Text file handle }
  TBuff     : Pointer; { Buffer }
  TBuffsize : LongInt; { Size of buffer }

{Code}
 tbuffsize:=Maxavail;                 {Find available memory block}
 if tbuffsize > $fff0                 {Limit to max. data object size}
    then tbuffsize := $fff0;
 getmem(tbuff,tbuffsize);             {Grab memory, hook to pointer}
 settextbuf(target,tbuff^,tbuffsize); {Attach new buffer to text file}
 reset(target);                               {Open file with buffer}

{
When processing text on floppy disks, I find this frequently reduces the
program to executing only a single read - which speeds up execution by
a factor of 10.
}
