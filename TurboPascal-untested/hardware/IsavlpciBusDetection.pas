(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0051.PAS
  Description: ISA/VL/PCI bus detection
  Author: CRAIG HART
  Date: 08-30-96  09:35
*)

{
 > Does anyone here have code to detect if a system got ISA, VL or PCI-bus
 > ?
 > Please respond with code.

An extract of my system diagnostics tools. Have fun.. :) (Put this in SWAG if
you want...)
}

procedure getbustype;
var
  works         : boolean;
  data_seg      : word;
  data_ofs      : word;
  test          : string[4];


begin
  bustype:='';
  works:=false;

  if not works then                     { EISA }
  begin
    test:='EISA';
    test[2]:=chr(mem[$f000:$ffd9]);
    test[1]:=chr(mem[$f000:$ffda]);
    test[4]:=chr(mem[$f000:$ffdb]);
    test[3]:=chr(mem[$f000:$ffdc]);
    if test='EISA'  then
    begin
      works:=true;
      bustype:='EISA';
    end;
  end;

  if not works then                     { MCA }
  begin
    asm
      mov ah,0c0h
      int 15h
      cmp ah,0
      jnz @nope

      mov works,true

      mov data_seg,es
      mov data_ofs,bx

    @nope:
    end;
    if works then if (mem[data_seg:data_ofs+5] and 2)=2 then bustype:='MCA'
else works:=false;  end;

  if not works then                     { PCI }
  begin
    asm
      mov ax,$b101
      int $1a
      cmp ah,00
      jne @nope
      mov works,true
    @nope:
    end;
    if works then bustype:='ISA/PCI';
  end;
  if not works then bustype:='ISA';     { ISA ? }
end;

