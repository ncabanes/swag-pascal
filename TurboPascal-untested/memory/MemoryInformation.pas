(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0086.PAS
  Description: Memory Information
  Author: JOSE ANTONIO NODA
  Date: 09-04-95  10:53
*)


(***************************************************************************)
(* Program   : Memory Information                                          *)
(* Author    : Jose Antonio Noda                                           *)
(* Date      : 26/06/95                                                    *)
(* Version   : 1.0                                                         *)
(*                                                                         *)     
(* Compuserve ID  :    100667,2523                                         *)
(*                                                                         *)
(***************************************************************************)

program MemoryInfo;
{$A+,B-,E-,G+,R-,S-,V-,X-,N+,D-}

Uses Dos,Crt;

var
  Regs          : registers;
  TotalRAM,
  AvailRAM,
  TotalXMS,
  PagesInst,
  PagesAvail,
  TotalEXP,
  AvailEXP,
  SystemEXP,
  OtherEXP,
  i,NumHandles  : word;
  EXTInfo,
  EXPInstalled  : boolean;
  EXPVersion    : string;
  PList         : array[1..512] of record
                                     Handle,Pages: word;
                                   end;

Function StrL(L : longint) : string;
var
  S : string;
begin
  Str(L,S);
  StrL := S;
end;

Function StrLF(L : longint;   Field : byte) : string;
var
  S : string;
begin
  Str(L:Field,S);
  StrLF := S;
end;

Procedure GetRAMInfo;
Begin
  FillChar(Regs,SizeOf(Regs),$00);
  Intr($12,Regs);
  TotalRAM := Regs.AX;                { Total RAM on system (usually 640 Kb) }
  AvailRAM := (MemAvail div 1000)+24; { Available RAM, 24 Kb used by program }
end;


procedure GetEXPInfo;
var
  v1,v2: byte;
begin
  { Check if installed expanded memory }
  FillChar(Regs,SizeOf(Regs),$00);
  Regs.AH := $40;
  Intr($67,Regs);
  EXPInstalled := (Regs.AH = 0);

  if not EXPInstalled then Exit;

  { Check number of installed and available 16K pages }
  FillChar(Regs,SizeOf(Regs),$00);
  Regs.AH := $42;
  Intr($67,Regs);
  PagesInst  := Regs.DX;
  PagesAvail := Regs.BX;
  TotalEXP   := 16*PagesInst;  { Total expanded in KBytes     }
  AvailEXP   := 16*PagesAvail; { Available expanded in KBytes }

  { Get LIM version number }
  FillChar(Regs,SizeOf(Regs),$00);
  Regs.AH := $46;
  Intr($67,Regs);
  v1 := Regs.AL shr 4;
  v2 := Regs.AL and $0F;
  EXPVersion := StrL(v1)+'.'+StrL(v2);

  { Get number of pages occupied by each handle }
  FillChar(Regs,SizeOf(Regs),$00);
  Regs.AH := $4D;
  Regs.ES := Seg(PList);
  Regs.DI := Ofs(PList);
  Intr($67,Regs);
  NumHandles := Regs.BX;
  SystemEXP := 16*PList[1].Pages;
  OtherEXP := 0;
  for i := 2 to NumHandles do
    OtherEXP := OtherEXP + 16*PList[i].Pages;
end;


procedure GetXMSInfo;
var
  b1,b2: word;
begin
  Port[$70] := $30;
  b1 := Port[$71];
  Port[$70] := $31;
  b2 := Port[$71];
  TotalXMS := (b2 shl 8) + b1;
end;


procedure DrawInfo;
const
  Max=60;
var
  MBUsed,
  MBFree,
  FractionFree,
  FractionUsed : single;
  Start,
  i,m          : byte;
  s            : string;

begin
  ClrScr;
  Regs.cx:=$2000;
  Regs.ah:=1;
  Intr($10,Regs);
  Gotoxy(20,2);Write('╔════════════════════════════════════════════════╗');
  Gotoxy(20,3);Write('║           - Memory Information -               ║');
  Gotoxy(20,4);Write('╚════════════════════════════════════════════════╝');
  Gotoxy(6,5);Write(' RAM      ');
  FractionFree := AvailRAM / TotalRAM;
  FractionUsed := 1-FractionFree;
  m := Max;
  for i := 1 to m do
  begin
    Gotoxy(16+i,6);Write('█');
    Delay(4);
  end;
  m := Round(Max*FractionUsed);
  for i := 1 to m do
  begin
    Gotoxy(16+i,6);Write('▒');
    Delay(5);
  end;
  Gotoxy(10,8);Write('▒▒▒');
  Write('  Used');
  Gotoxy(10,10);Write('███');
  Write('  Free');
  Gotoxy(40,8 );Write('Total system RAM   : - '+StrLF(TotalRAM,3)+' Kbytes');
  Gotoxy(40,9 );Write('Used RAM           : - '+StrLF(TotalRAM-AvailRAM,3)+' Kbytes');
  Gotoxy(40,10);Write('Available RAM      : - '+StrLF(AvailRAM,3)+' Kbytes');
    Gotoxy(5,12);Write(' EXTENDED ');
  if TotalXMS<=0 then
  begin
    Gotoxy(17,12);Write(' Not available ');
  end
  else begin
    s := ' '+StrL(TotalXMS)+' Kbytes (from CMOS) ';
    Gotoxy(17,12);Write(s);
  end;
  Gotoxy(5,14);Write(' EXPANDED ');
  if TotalEXP<=0 then
  begin
    Gotoxy(17,14);Write(' Not available ');
    Halt(1);
  end;
  FractionFree := AvailEXP / TotalEXP;
  FractionUsed := 1-FractionFree;
  m := Max;
  for i := 1 to m do
  begin
    Gotoxy(16+i,14);Write('█');
    {WriteStr(15,17+i,Blue+BlackBG,'▄');
    WriteStr(14,17+i,Blue+BlackBG,'▀');}
    Delay(4);
  end;
  m := Round(Max*FractionUsed);
  for i := 1 to m do
  begin
    Gotoxy(16+i,14);Write('▒');
    Delay(5);
  end;
  Gotoxy(40,17);Write('EMM Version : LIM '+EXPVersion);
  Gotoxy(40,19);Write('Total EMS memory   :   '+StrLF(TotalEXP,4)+' Kb');
  Gotoxy(40,20);Write('Reserved by system : - '+StrLF(SystemEXP,4)+' Kb');
  Gotoxy(40,21);Write('Allocated          : - '+StrLF(OtherEXP,4)+' Kb');
  Gotoxy(40,22);Write('Available          : = '+StrLF(AvailEXP,4)+' Kb');
end;


Begin
  EXTInfo:=true;
  GetRAMInfo;
  GetEXPInfo;
  GetXMSInfo;
  DrawInfo;
end.

