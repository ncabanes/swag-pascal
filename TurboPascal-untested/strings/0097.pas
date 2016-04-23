
   (*

   For the SWAGS...

   To the best of my knowledge this is the fastest routine for 
   up/low-casing strings in Turbo Pascal. The difference from 
   previous versions is that it uses seges for segment override 
   and within the loop it replaces loadsb and stosb with mov 
   operations. It is also independent from the segment in which 
   Source and Table are created. 
   
   If anyone finds a bug or has a suggestion, or has a faster 
   looking routine for string translations, just leave me a 
   message here. I'll benchmark the new routine against the 
   collection I have gathered already from the SWAGS and 
   elsewhere and will post the results. 

   The following benchmarking was done in a 486/DX 60 MHz using 
   Neil Rubenking's TimeTick unit while upcasing a full string 
   (255 chars) 400,000 times (100 million characters): 

   For-Do loop using TP7 UpCase() .......... 315.5 secs.
   UpperCase (Assembler classical approach)   53.9 secs. (1)
   My old TXlat3 ...........................  28.3 secs. (2)
   Translate ...............................  26.8 secs. (3)
   TXlat5 (the one in this message) ........  21.2 secs.

   (1) There are several routines using this approach in the 
       SWAGS. See also HAX 144 in PC-Techniques. 
   (2) See "St-case4.pas" in STRINGS.SWG, it contains an earlier 
       (and buggy...) version.
   (3) See "Translate upper/lower case" in STRINGS.SWG

   -Jose-
   Jose Campione, 1:163.513.3
   *)

    Program TXlate;

    type
      ByteArray = array[0..255] of byte;
    var
      Source  : string;
      Table   : ByteArray;
      i       : byte;

    Procedure TXlat5(var Source: string; var Table: ByteArray);assembler;
    asm
        mov  dx, ds       { save ds }
        lds  bx,Table     { load ds:bx with Table address }
        les  di,Source    { load es:di with Source address }
        seges             { override ds segment}
        mov  al,[di]      { load al with length of source }
        xor  ah, ah       { set ah to zero, we need a word for cx }
        mov  cx,ax        { assign length of source to counter }
        jcxz @end         { if cx = 0 exit}
        inc  di           { increment di & skip length byte on 1st pass }
      @filter:
        mov  al,[di]      { load byte in ax from es:di }
        xlat              { tan-xlat-e... }
        mov  [di],al      { send byte to es:di }
        inc  di           { increment di }
        loop @filter      { decrement cx and loop back if cx > 0 }
      @end: mov  ds, dx   { restore ds }
    end;

    begin
      {...}
      {Fill Table for UpCase translation}
      for i:= 0 to 255 do
        if i in [$61..$7A] then Table[i]:= i - $20 else Table[i]:= i;
      {...}
      Source: 'this string is to be upcased ';
      WriteLn(Source);
      TXlat5(Source,Table);
      WriteLn(Source);
      {...}
    end.

   
