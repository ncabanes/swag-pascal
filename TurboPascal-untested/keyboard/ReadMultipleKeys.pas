(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0113.PAS
  Description: Read Multiple Keys
  Author: SCOTT TUNSTALL
  Date: 05-31-96  09:17
*)

{
Unit for reading multiple keys... works brilliantly, 
although I (Scott Tunstall) didn't write it, I think it was
Lou Duchez. Thanks Lou!
}

Unit NWKBDINT ;         

Interface
Procedure HookKeyBoardInt;              { Take over Keyboard handler }
Procedure UnHookKeyBoardInt;            { Return control back to system }


Var
   KeyDown : Array[0..127 ] of Boolean ;

Implementation
Uses DOS;

Var
   OldInt09 : Pointer ;
   ExitSave : Pointer ;




{$F+}


procedure Newint09; assembler;       { new keyboard handler }
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



Procedure HookKeyBoardInt;            { Take over keyboard }
Var KeyCount: byte;
Begin
     For KeyCount:=0 to 127 do
         KeyDown[KeyCount]:=False;
     GetIntVec(9,OldInt09);
     SetIntVec(9,@NewInt09);
End;






Procedure UnHookKeyBoardInt;          { Let system do hard work now }
Begin
     SetIntVec(9,OldInt09);
     Mem[$40:$1c]:=Mem[$40:$1a];      { Flush key buffer so
                                        there's no phantom keys }
End;




Begin
     Writeln('Installing NEWKBDINT multiple key handler..');

End.

