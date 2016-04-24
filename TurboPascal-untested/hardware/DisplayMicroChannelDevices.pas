(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0061.PAS
  Description: Display Micro Channel Devices
  Author: FRANK BARTNITZKI
  Date: 01-02-98  07:35
*)

Program MCAView;
uses
  CRT,
  DOS;
var
  Regs   : Registers;
  DT_MCA : Array[1..8] of String[10];
  I      : Integer;
  MCA_ID : Word;
{ ------------------------------------------------------------------------- }
Function B2H(B : Byte): String;                { returns byte as hex string }
const
  Hex : Array[0..15] of Char='0123456789ABCDEF';
Begin;
  B2H:=Hex[(B shr 4)]+Hex[(B and $0F)];
end;
{ ------------------------------------------------------------------------- }
Function I2S(I: Longint): String;           { returns any integer as string }
var
	S: String[11];
Begin
	Str(I,S);
	I2S := S;
end;
{ ------------------------------------------------------------------------- }
Function ChkBit(OP : LongInt;           { checks whether bit N is set in OP }
                N  : LongInt): Boolean;
Begin
  ChkBit:=OP and (1 shl N)= 1 shl N;
end;
{ ------------------------------------------------------------------------- }
Function DetectMCA : Boolean; { Ermittelt, ob Micro-Channel installiert ist }
{ "system - get configuration" }
{ Lit:PCI-JK-03-11             }
{ Int 15h, function C0h        }
var
	Regs : Registers;
	Buff : Array[0..$20] of Byte;
Begin
	DetectMCA:=False;
	with Regs do
	Begin
		AH:=$C0;
		AL:=$00;
		Intr($15,Regs);
		if AH = 0 then
		Begin
			Move(Mem[Regs.ES:Regs.BX],Buff,$21);
			if ChkBit(Buff[5],1)then DetectMCA:=True else DetectMCA:=false;
		end;
	end
end;
{ ------------------------------------------------------------------------- }
Procedure CheckMCA;
{ "programmable option select(PS50+)"  }
{ Lit: PCI-RB-04-entry)                }
{ Int 15h, function C4h                }

Begin
  For I:=1 to 8 do                             { 8 slots                    }
  Begin
    Regs.AH:=$C4;                              { function C4h               }
    Regs.AL:=$01;                        { subf. 01h,"enable slot for setup"}
    Regs.BL:=I;                                { slot number                }
    Intr($15,Regs);                            { int 15h                    }
    if (((Fcarry and Regs.Flags)=0) and (Regs.DX=0))  then {CF set on error }
    Begin
      if (Port[$100]=$FF) and (Port[$101]=$FF) { slot empty                 }
         then DT_MCA[I]:=I2S(I)+ '    -'
         else DT_MCA[I]:=I2S(I)+'  $'          { adapter id ...             }
                   +B2H(Port[$101])            { ...low byte                }
                   +B2H(Port[$100]);           { ...high byte               }
    end;
  end;
end;
{ ------------------------------------------------------------------------- }
Begin
  ClrScr;
  If DetectMCA then
  Begin
    CheckMCA;
    Writeln('Slot Ad-ID');
    Writeln('----------');
    I:=1;
    While Length(DT_MCA[I]) > 0 do
    Begin
      Writeln('  ',DT_MCA[I]);
      Inc(I);
    end;
  end
  else
    Writeln('no micro channel found.');
  Writeln(^J,'contact: compuserve 100321,570');
  ReadKey;
end.
