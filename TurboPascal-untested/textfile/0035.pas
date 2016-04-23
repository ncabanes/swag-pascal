{

     This is not related to the original topic ".. w/exe!!", but
     if somebody is interested, at least I found this one a bit
     excited piece of code. It makes an executable com-file from
     your text and you can easily extend it to the limits you
     need. Just remember that you can't call any pascal routines,
     you have to write it in pure assembler. (would .80xxx have been
     a better area..?) Anyway, here it is:

 --!clip!-- { Code by Kimmo Fredrikson }

  {$A+,D-,G-,I-,R-,S-}

  program txt2com;

  var
    src                 : file;
    dst                 : file;
    buff                : array [0..2047] of byte;
    bytesRead           : word;
    bytesWritten        : word;
    fSize               : word;


  function t2c: word; far; assembler;
  asm
        jmp     @tail           { 2 bytes }

  @head:mov     ax, 0003h       { -- here starts the code part of }
        int     10h             {    the txt-show-proggie.. }

        mov     cx, word ptr [@tail+100h-2]     { length of text }
        lea     si, [@tail+100h-2+2]            { address of txt }

  @nxtC:mov     dl, [si]        { read a character to dl }
        mov     ah, 2
        int     21h
        inc     si
        loop    @nxtC

        mov     ax, 4c00h
        int     21h             { terminate, back to dos }

  @tail:mov     ax, offset [@tail]              { length of t2c }
        sub     ax, offset [@head] { this returns the length of the  }
  end;                     { assembler code when called within this pascal }
                                                { program }
  begin
    if paramCount <> 2 then halt;
    assign (src, paramStr (1));
    assign (dst, paramStr (2));
    reset (src, 1);
    if ioResult <> 0 then halt;
    if fileSize (src) > 64000 then halt;
    fSize := fileSize (src) - 1;                { get rid of the ctrl-z }
    reWrite (dst, 1);
    if ioResult <> 0 then halt;
    blockWrite (dst, pointer (longint (@t2c) + 2)^, t2c);  { the code }
    blockWrite (dst, fSize, 2);                  { the length of text }
    repeat
      blockRead (src, buff, 2048, bytesRead);
      blockWrite (dst, buff, bytesRead, bytesWritten);     { the text }
    until (bytesRead = 0) or (bytesWritten <> bytesRead);
    close (src);
    close (dst);
  end.
