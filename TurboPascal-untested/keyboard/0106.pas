{
 BI> In TP, when you do a 'ReadKey', the keyboard buffer is
 BI> 'updated'. When use 'KeyPressed' it just tells you whether
 BI> a key has been pressed. Does anyone have any source etc on
 BI> how to see if a specific key has been pressed, but which
 BI> leaves the other keys alone?
 BI> 

If I understand you correctly, this should interest you:


    Check enhanced keystroke (Int 16/11)

 INT 16 - KEYBOARD - (AT model 339,XT2,XT286,PS)
     AH = 11h

 Return: ZF clear if keystroke available
         AH = scan code \ meaningless if ZF = 1
         AL = character /
     ZF set if kbd buffer empty

 SeeAlso: AH=01h,10h
             ^^^ use this if you own an XT
}

PROGRAM Check_Keyboard_Buffer;

USES Crt;

FUNCTION KeyAvailable(VAR Keystroke: word): boolean; ASSEMBLER;
ASM xor dx, dx            { -- DX has the result of the function;
                            -- initialize to FALSE. }

    mov ah, $11
    int $16               { -- Ask the BIOS. }

    jz @@Exit             { -- No key waiting, so quit. }

    les di, Keystroke     { -- Key waiting; move it to Keystroke. }
    mov es:[di], ax
    inc dx                { -- Function result := TRUE. }

@@Exit:
    mov ax, dx            { -- TP expects a boolean function result to be
                            -- in AX, so move DX to AX. }
END;

PROCEDURE MakeKbdBufferEmpty;
BEGIN WHILE keypressed DO readkey END;

FUNCTION HexB(CONST B: byte): STRING;
{ -- Return hex string for byte. }
CONST Digits: ARRAY[$00 .. $0F] OF char = '0123456789ABCDEF';
BEGIN HexB[0]:= #3;
      HexB[1]:='$';
      HexB[2]:=Digits[B SHR 4];
      HexB[3]:=Digits[B AND $0F]
END;

{ -- Main: }

CONST Esc = $011B;

VAR key     : word;
    X, Y, TA: byte;

BEGIN clrscr;
      MakeKbdBufferEmpty;  { -- "Eat" any still available keys. }

      REPEAT write('*'); delay(10);
             IF KeyAvailable(key)
             THEN BEGIN X:=WhereX; Y:=WhereY;
                        TA:=TextAttr; TextAttr:=$30;
                        gotoxy(25, 12);
                        write('Scancode: ', HexB(hi(key)),
                              '  Character: ', HexB(lo(key)));
                        delay(100);
                        MakeKbdBufferEmpty;
                        { -- Remove that key from the buffer, otherwise
                          -- it will remain there forever ! }
                        gotoxy(X, Y); TextAttr:=TA
                  END
      UNTIL key = Esc
END.
