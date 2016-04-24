(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0008.PAS
  Description: BYTE2BIN.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{
Byte to Binary...
}

Type
  String8 = String[8];


Function Byte2Bin(byTemp : Byte) : String8;
Var
  Count : Integer;
begin
  Byte2Bin[0] := #8;
  For Count := 0 to 7 do
    Byte2Bin[8 - Count] := Char(((byTemp shr Count) and 1) + ord('0'));
end;

Function Byte2BinAsm(byTemp : Byte) : String8; Assembler;
Asm
  push    ds
  les     di,@result
  mov     ah,byTemp
  mov     cl,8
  mov     al,cl
  stosb
@loop:
  mov     al,24
  add     ah,ah
  adc     al,al
  stosb
  loop    @loop
  pop     ds
end;

begin
  Writeln;
  Writeln('10 in Binary = ',Byte2Bin(10));
  Writeln;
  Writeln('The same thing With assembly code: ',Byte2BinAsm(10));
  Writeln;
  Readln;
end.
