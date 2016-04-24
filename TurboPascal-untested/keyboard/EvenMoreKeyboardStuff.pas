(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0100.PAS
  Description: Even More Keyboard Stuff!
  Author: LOU DUCHEZ
  Date: 05-26-95  23:33
*)

{
Well, I got it figured out now!  Kudos go to you, to Ralf Brown and his
list of ports, the great state of Ohio, the Church of the SubGenius, and
most of all, Bill Seiler.

Who is Bill Seiler?  Well, did any of you ever play that old (1985-1986)
game called "Space War"?  I did, and still do; and in fact, I registered
the game (it IS shareware, after all), and got the source code.  It's all
in ASM, and a lot of it still mystifies me; but I was able to figure out
how he does his keyboard interrupt.  Yet another advantage of registering
this shareware product, five years ago!

Here's my Pascal version, with significant line numbers:

    var port60h, port61h: byte;
        keydown: array[0 .. 127] of boolean;

    procedure newkbdint; interrupt;
    begin
1     port60h := port[$60];
2     keydown[port60h and $7f] := (port60h <= $7f);
3     port61h := port[$61];
4     port[$61] := port61h or $80;
5     port[$61] := port61h;
6     port[$20] := $20;
      end;

1 - Read the port.
2 - Store the new key status for whatever key: either up or down.
3 - Read in port 61h, the system control port.
4 - Send the value back to 61h with the high bit set to "1" to reset
    the keyboard.
5 - Send the original, unadulterated value back to 61h.
6 - The boring old End of Interrupt instruction.  This line might not
    even be necessary!  It was only after testing that procedure out
    and pasting it into this message, that I noticed that I had left
    the EOI off the procedure.  But it seemed to work all right without
    it.  It seems to work just fine *with* it too, so it's probably
    best to keep it.

And, for the pure of heart: the same routine in BASM, which does not
need "port60h" and "port61h" for intermediate storage:
}

procedure newkbdint; assembler;       { new keyboard handler }
  asm
    push ax                           { push registers }
    push bx
    push ds
    mov ax, SEG @Data
    mov ds, ax
    in  al, 60h
    mov bx, ax
    and bx, 007fh                     { switch high bit of BX to zero }
    and al, 80h                       { check high bit of port value }
    jz @press
    @release:                         { high bit = 1: "release" code }
    mov byte ptr keydown[bx], 00h     { write 00 to "down" array element }
    jmp @done
    @press:                           { high bit = 0: "press" code }
    mov byte ptr keydown[bx], 01h     { write 01 to "down" array element }
    @done:
    in al, 61h                        { read port 61h, system ctrl port }
    mov ah, al                        { save value to AH }
    or al, 80h                        { set top bit to "1" - reset kbd }
    out 61h, al                       { write out value to port }
    xchg ah, al                       { put original value back into AL }
    out 61h, al                       { rewrite original value in AL }
    mov al, 20h                       { generate End of Interrupt }
    out 20h, al
    pop ds                            { pop registers }
    pop bx
    pop ax
    iret                              { return }
    end;

