(*
>>   var sp: ^string;  { a pointer that points to a string }
>>   getmem(sp, 256);  { Allocate memory on the heap.  "sp" points

>So, the (better) way to use GetMem is:
>  GetMem (SP,Length(S)+1)
>which will get the minimum Heap for the string (rounded to the nearest
>mod-8 boundary).

> The way I have pulled it off in code, is to make a li'l record structure:
>   type heapstring = record
>        sptr: ^string;
>        allocsize: word;
>        end;

> That way, I always know how much memory I allocated.

   Scuze me for butting in here, but here's a much more efficient
   way to do this, using absolute declarations and a cute typecast:


   When allocating the string (or whatever) code it like this:
   (Actual production code follows)

   Var
       st    : string[linelength];
       stlen : byte absolute st;

             GetMem(DosPtr^[NumberLines],succ(stlen));
             if DosPtr^[NumberLines] = Nil then
                 {do error handling}

   In this case, DosPtr is a pointer to an array of pointers, so we
   need the double dereference. Numberlines is an index into the
   array. As you can see, we've only allocated enuf memory for the
   actual length of the string, plus one for the length byte.....

   Now, when you're done with the string, dump the memory in a loop
   like so:

   Procedure Dumpit;
   Type
      len = ^byte;
   Var
      i   : longint;

       if DosPtr <> Nil then
         begin
           for i := pred(NumberLines) downto 0 do
               FreeMem(DosPtr^[i],succ(len(DosPtr^[i])^));
           FreeMem(DosPtr,MaxLines*SizeOf(LinePtr));
           DosPtr := Nil;
        end;

   The way this works is, the type declaration of len as a pointer 
   to a byte forces the compiler to consider the begining address as 
   a byte, which, in this case, it is, eg: the length byte at the 
   front of the string. By incrementing it with succ(), you get the 
   actual amount of memory to release. The above code will dump 350 
   K's worth of strings so fast you can't see it happen.

   The niftyest part of this is it generates *no* instructions !

