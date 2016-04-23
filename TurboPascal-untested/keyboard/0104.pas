$F+,O+}
Unit KeyServ;
Interface
{$IFNDEF VIRTUALPASCAL}
 Function GetKey(Var Key: Word): Boolean;
 Function ReadKey: Char;
 Function KeyPressed: Boolean;
 Procedure ClearKBD;
{$ENDIF}
Implementation
{$IFNDEF VIRTUALPASCAL}
Const
  MCh: Byte=0;

Function GetKey; Assembler;
Asm
  mov  ah,01h
  int  16h
  mov  al,00h
  je   @@1
  xor  ah,ah
  int  16h
  les  di,Key
  mov  word ptr es:[di],ax
  mov  al,01h
@@1:
End;

Function ReadKey; Assembler;
Asm
  mov  al,MCh
  mov  byte ptr MCh,00
  or   al,al { ??? }
  jne  @0338
  xor  ah,ah
  int  16h
  or   al,al
  jne  @0338
  mov  MCh,ah
  or   ah,ah { ??? }
  jne  @0338
  mov  al,03h
@0338:
End;

Function KeyPressed; Assembler;
Asm
  cmp  byte ptr MCh,00
  jne  @0317
  mov  ah,01h
  int  16h
  mov  al,00h
  je   @0319
@0317:
  mov  al,01h
@0319:
End;

Procedure ClearKBD; Assembler;
Asm
@@Begin:
  mov  ah,01h
  int  16h
  je   @@Exit
  xor  ah,ah
  int  16h
  jmp  @@Begin
@@Exit:
End;
{$ENDIF}
End.
