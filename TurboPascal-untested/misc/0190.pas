
{ I found this very usefull for showing hints in a program. I was using
  some "windowing" routines and needed to write outside the *active*
  window so I needed something to do direct screen writes, for this I
  used the qwrite procedure which I obtained from SWAG, sorry I can't
  remember the authors name;-(
  Ok, to business! Write a simple ascii text file using no more than
  62 chars per line(you may want to change this) and compile using
  the makehnt.pas (source at end). The following source can then be
  used to display this on screen.
  by Geoff Bassett 1996
 }

Program Ahint;

procedure qwrite(x, y: byte; s: string; f, b: byte);
{ Does a direct video write -- extremely fast.
 x,y = co-ordinates
 s = string to display
 f,b = foreground/background colours }
begin
  asm
    mov dh, y         { move X and Y into DL and DH }
    mov dl, x
    xor al, al
    mov ah, b         { load background into AH }
    mov cl, 4         { shift background over to next nibble }
    shl ax, cl
    add ah, f         { add foreground }
    push ax           { PUSH color combo onto the stack }
    mov bx, 0040h     { look at 0040h:0049h to get video mode }
    mov es, bx
    mov bx, 0049h
    mov al, es:[bx]
    cmp al, 7         { see if mode = 7 (i.e., monochrome) }
    je @mono_segment
    mov ax, 0b800h    { it's color: use segment B800h }
    jmp @got_segment
    @mono_segment:
    mov ax, 0b000h    { it's mono: use segment B000h }
    @got_segment:
    push ax           { PUSH video segment onto stack }
    mov bx, 004ah     { check 0040h:0049h to get number of screen columns }
    xor ch, ch
    mov cl, es:[bx]
    xor ah, ah        { move Y into AL; decrement to convert Pascal coords }
    mov al, dh
    dec al
    xor bh, bh        { shift X over into BL; decrement again }
    mov bl, dl
    dec bl
    cmp cl, $50       { see if we're in 80-column mode }
    je @eighty_column
    mul cx            { multiply Y by the number of columns }
    jmp @multiplied
    @eighty_column:   { 80-column mode: it may be faster to perform the }
    mov cl, 4         {   multiplication via shifts and adds: remember  }
    shl ax, cl        {   that 80d = 1010000b , so one can SHL 4, copy  }
    mov dx, ax        {   the result to DX, SHL 2, and add DX in.       }
    mov cl, 2
    shl ax, cl
    add ax, dx
    @multiplied:
    add ax, bx        { add X in }
    shl ax, 1         { multiply by 2 to get offset into video segment }
    mov di, ax        { video pointer is in DI }
    lea si, s         { string pointer is in SI }
    SEGSS lodsb
    cmp al, 00h       { if zero-length string, jump to end }
    je @done
    mov cl, al
    xor ch, ch        { string length is in CX }
    pop es            { get video segment back from stack; put in ES }
    pop ax            { get color back from stack; put in AX (AH = color) }
    @write_loop:
    SEGSS lodsb       { get character to write }
    mov es:[di], ax   { write AX to video memory }
    inc di            { increment video pointer }
    inc di
    loop @write_loop  { if CX > 0, go back to top of loop }
    @done:            { end }
    end;
  end;

Procedure Hint(Index:Integer);
Type  Hints = Record
         Hint : String[62];
      End;
var
   F : File of Hints;
   Hold : String;
   H : Hints;
BEGIN
    {generate a blank string to clear any previous hint line and write
    to the screen}
    Hold:='                                                               ';
    Qwrite(17,24,Hold,0,0);
    { assign and reset our hints file }
    Assign(F, 'TEST.HNT');
    Reset(F);
    { seek to the position in the file }
    Seek(F, Index-1);
    {read the hint}
    Read(F, H);
    {write the hint to our output string}
    Hold:=H.Hint;
    {close the hints file}
    Close(F);
    {write the hint to the screen}
    Qwrite(15,24,Hold,11,0);
END;

{now the test!}
Begin
   Hint(1);
   readln;
   hint(2);
   readln;
   hint(3);
   readln;
end.
--------------- cut ----------------------------------------
{ source for the hint compiler - very simple, you may wish to add
some kind of minor encryption but I didn't see the point!}

Program makehint;
uses dos,crt;

Type  Hints = Record
         Hint : String[62];
      End;
var
   S : Text;
   F : File of Hints;
   Hold : String;
   H : Hints;
BEGIN
    Assign(S, 'HINTS.TXT');
    Assign(F, 'TEST.HNT');
    Rewrite(F);
    Reset(S);
    While NOT eof(S) do
    Begin
      Readln(S, Hold);
      H.hint:=hold;
      Write(F, H);
    end;
    Close(F);
    Close(S);
END.

-- cut ---------------- sample hints.txt ---------------
The First hint line
The second hint line
the last hint line!
-- cut --------------------------------------------
