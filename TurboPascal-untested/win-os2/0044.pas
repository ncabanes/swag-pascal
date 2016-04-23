{ I made a small ASM-routine for accessing 4 GB data in 4 instructions: }

PROGRAM test32; {Works for TPW1.5}
{$R-}
{Wim Smit 4-9-1994
Thanx to Jimmy Athens!}
USES WinTypes,WinProcs,WinCrt;
TYPE
    word_array = ARRAY[0..0] OF WORD;
    Pword_array = ^word_array;

VAR P:PWORD_Array;
    H:THandle;
    sub1,sub2, 
    segt: WORD;
    i,
    ofst: LONGINT;
BEGIN
WRITELN('BEGIN');

h := GlobalAlloc(GMEM_MOVEABLE OR GMEM_SHARE,2*70000);
IF (h = 0) THEN
    Halt;
P := GlobalLock(h);
IF (P = NIL) THEN
    Halt;

segt := SEG(p^);
FOR i := 0 TO 69999 DO           {fill the words with their index}
    BEGIN
    ASM
        mov es,segt
        db 66h                   {66h for 386 opcode}              
        mov bx, WORD(i)          {WORD() to fool Pascal}
        db 66h
        shl bx,1                 {ebx times 2: WORDs}
        db 66h
        mov ax, WORD(i)
        db 26h
        db 67h
        db 89h
        db 03h                   {these produce: mov  es:[ebx],ax}
    END;{asm}
    END;{i}
{Now test it by reading the words:}
FOR i := 32762 to 32770 DO       {read over a segment-boundary}
    BEGIN
    ASM
        mov es,segt
        db 66h
        mov bx, WORD(i)          {= mov ebx, i}
        db 66h
        shl bx,1                 {times 2: we're indexing WORDs}
        db 26h
        db 67h
        db 8bh
        db 03h                   {= mov ax, es:[ebx]}
        mov sub2, ax
    END;{asm}
    sub1 := p^[i];
    WRITELN(i:3,':',sub2,' ',sub1);
    END;{i}

GlobalUnlock(h);
GlobalFree(h);
WRITELN('DONE');
END.

{
Run the program and see the difference:
BEGIN
32762:32762 32762
32763:32763 32763
32764:32764 32764
32765:32765 32765
32766:32766 32766
32767:32767 32767
32768:32768 0      <-Here 16 bit index will wraparound to p^[0]!
32769:32769 1
32770:32770 2
DONE

Thus, by choosing the right db's, one can access huge arrays of bytes,
words and longints etc.
Isn't that great?
OK, it needs a 386 or better, but don't we all have that?
}