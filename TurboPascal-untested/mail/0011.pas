{
WILLIAM MCBRINE

>I have this File here that tells me the format of QWK stuff, and it
>says that the messages.dat File is a whole bunch of Strings of length 128...

This is wrong. They aren't Pascal Strings, simply 128-Byte blocks.
Within the Text blocks, each line is terminated by a "pi" Character
($E3).

>I dont know if I did this right but what I load the data into is
>this:  (I have an Array[1..100] of messagedata).

>Type
>  MessageData = Record
>    Rec : String[128];
>  end;

For blocks of Text, you want someting like this:

Type
  messagedata = Array[0..127] of Char;

For the message HEADER, you need something more complex. Here's the
structure I use in my QWK door:
}
qwkhead = Record
  status   : Char;
  messnum  : Array [1..7] of Char;
  date     : Record
    month : Array [1..2] of Char;
    dash1 : Char;
    day   : Array [1..2] of Char;
    dash2 : Char;
    year  : Array [1..2] of Char
  end;
  time     : Record
    hour   : Array [1..2] of Char;
    colon  : Char;
    minute : Array [1..2] of Char
  end;
  toname   : Array [1..25] of Char;
  from     : Array [1..25] of Char;
  subject  : Array [1..25] of Char;
  passwd   : Array [1..12] of Char;
  refnum   : Array [1..8] of Char;
  length   : Array [1..6] of Char;
  killflag : Byte;
  confnum  : Word;
  null     : Word;
  nettag   : Char
end;

{
This is also 128 Bytes.

>1).  A tiny little thing that's not too important right now, but it's
>bugging me.  When I try to load the first Record (which is supposed
>to be a packet header) from messages.dat, I seem to be not reading in
>the first Character... Like, Constantly it'll skip the first
>Character... it'll say "roduced by Qmail..." instead of "Produced by
>Qmail..."

The first Character is going into the length field of the String.
Position [0] of the String contains the length.

Your "problem 2" is the same thing. 128 Bytes are actually read, but
only the erroneous length's worth of them are printed out.

Here's some pseudocode to read a whole packet:

 Open MESSAGES.DAT
 Skip the first Record (128 Bytes)
 While not EOF do
  begin
   Read a message header
   Get length of Text in blocks from qwkhead.length (in ASCII) -1
   Reserve memory For 128 Bytes*number of blocks
   Read Text blocks
   Parse Text
   Release memory
  end
 Close MESSAGES.DAT, cleanup

"Parse Text" is the hard part. I wrote an Asm routine to convert the
pi-delimited Text into Strings, pointed to by an Array of Pointers.
(This is the format used by the Searchlight Programmer's Library message
routines; pretty easy to work With.) Pointer "a" points to this:

 msgType = Record
            msglen:Word;
            msglin:Array[1..400] of Pointer
           end;

The "raw data" (Pointer b) below starts one Byte before the actual QWK
data. The purpose of this is to hold the first String length after
conversion. "d" should be the maximum number of lines to convert (400,
in this case); "e" should be about 79 (though it can be set all the way
up to 255 if desired).
}

Procedure mangle(a, b : Pointer; c, d, e : Word); Assembler;
Asm
  push ds
  mov  ax,c           {# of blocks loaded (maximum length)}
  les  di,b           {raw data; lines terminated With pi Chars}
  lds  si,a           {msgType: Word:linecount, 1..400:Pointers}
  xor  bx,bx          {line count=0}
  inc  si             {to first line Pointer}
  inc  si
  mov  dx,di
  mov  cl,7
  shl  ax,cl          {blocks * 128 = maximum Bytes in message}
  mov  cx,ax
  cld
 @mloop:
  push  ax
  inc   di
  mov   al, $E3       {pi Character; QWK packet line delimiter}
  repnz scasb         {find one}
  pop   ax            {ax = length before search, cx = length left}
  jnz   @notfound     {if there aren't any, done With message}
  sub   ax, cx
  dec   ax            {length of line}
  cmp   ax, e
  jle   @placelen
  mov   ax, e         {limit line length}
 @placelen:
  xchg  di, dx        {beginning of String in raw data}
  seges mov [di], al  {wow, now it's a Pascal String!}
  mov   [si], di
  mov   [si+2], es
  add   si, 4         {set the Pointer to it}
  dec   dx            {DX was at $E3 + 1}
  mov   di, dx
  mov   ax, cx
  inc   bx
  cmp   bx, d         {maximum number of lines}
  jle   @mloop        {start next line/String}
 @notfound:
  lds   si, a         {line counter in msgType}
  mov   [si], bx      {store # of lines}
  pop   ds            {magically a message!}
end;

{then, to print this Text, you'd do something like this: }

Procedure dump;
Var
  i : Word;
begin
  For i := 1 to a^.msglen do
    Writeln(a^.msglin[i]^);
end;
