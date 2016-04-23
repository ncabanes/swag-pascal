
unit xdos;

Interface
  function  GetVolSerialNo(DriveNo:Byte): string;
  Procedure PutVolSerialNo(DriveNo:Byte;SerialNo:longint);

Implementation
uses dos,crt;

type
  SerNo_type       =
                     record
                     case integer of
                       0: (SerNo1, SerNo2    : word);
                       1: (SerNo              : longint);
                     end;

  DiskSerNoInfo_type = record
                     Infolevel : word;
                     VolSerNo  : SerNo_Type;
                     VolLabel  : array[1..11] of char;
                     FileSys   : array[1..8] of char;
                     end;


function HexDigit(N : Byte) : char;
begin
  if n < 10 then HexDigit := Chr(Ord('0')+n)
  else           HexDigit := Chr(Ord('A') + (n - 10));
end;


function GetVolSerialNo(DriveNo:Byte): string;
var
  ReturnArray                  : DiskSerNoInfo_type;
  Regs                         : Registers;
begin
  with regs do begin
    AX := $440d;
    BL := DriveNo;
    CH := $08;
    CL := $66;
    DS := Seg(ReturnArray);
    DX := Ofs(ReturnArray);
    Intr($21,Regs);
    if (Flags and FCarry)<>0 then GetVolSerialNo := '' else
    with ReturnArray.VolSerNo do
    GetVolSerialNo :=HexDigit(Hi(SerNo2) Div 16) + HexDigit(Hi(SerNo2) Mod 16)
+
                     HexDigit(Lo(SerNo2) Div 16) + HexDigit(Lo(SerNo2) Mod 16)
+
                     HexDigit(Hi(SerNo1) Div 16) + HexDigit(Hi(SerNo1) Mod 16)
+
                     HexDigit(Lo(SerNo1) Div 16) + HexDigit(Lo(SerNo1) Mod 16);
  end;
end;

Procedure PutVolSerialNo(DriveNo:Byte;SerialNo:longint);
var
  ReturnArray                  : DiskSerNoInfo_type;
  Regs                         : Registers;
begin
  with regs do begin
    AX := $440d;
    BL := DriveNo;
    CH := $08;
    CL := $66;
    DS := Seg(ReturnArray);
    DX := Ofs(ReturnArray);
    Intr($21,Regs);
    if (Flags and FCarry)=0 then begin
       ReturnArray.VolSerNo.SerNo := SerialNo;
       AH := $69;
       BL := DriveNo;
       AL := $01;
       DS := Seg(ReturnArray);
       DX := Ofs(ReturnArray);
       Intr($21,Regs);
    end;
  end;
end;

end.
