(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0012.PAS
  Description: ST-CASE6.PAS
  Author: NORBERT IGL
  Date: 05-28-93  13:58
*)

{
NORBERT IGL

> Note that your uppercase characters do not include the german Umlauts
> and overlap sometimes with other foreign characters. There is a DOS
> function call to convert a string to all upcercase letters. Norbert
> Igl and I wrote a ASM end implementation, maybe he could repost his all-
> Pascal version that conforms to the DOS country information.

}

Unit Upper;
{ Country-independent upcase-procedures          (c) 1992  N.Igl

  Uses the COUNRY=??? from your CONFIG.SYS to get the correct uppercase.
  SpeedUp with a table-driven version to avoid multiple DOS-Calls.

  Released to the public domain ( FIDO: PASCAL int'l ) in 12/92 }


Interface

function UpCase(ch : char) : Char;
function UpCaseStr(S : String) : String;

Implementation uses Dos;

Const
  isTableOk : Boolean = FALSE;
Var
  theTable  : Array[0..255] of Char;

Procedure SetUpTable;                          { called only at Unit-init }
var
  Regs: Registers;
  x   : byte;
begin
  FillChar(theTable, Sizeof( theTable ), #0);  { Fill with NULL }
  For x := 1 to 255 do
    theTable[x] := CHAR(x);                    { predefined values }
  if Lo(DosVersion) < 4 then                   { n/a in this DOS... }
  begin                                        { use Turbo's Upcase }
    for x := 1 to 255 do
      theTable[x] := System.Upcase(CHAR(x));
    exit;
  end;
  Regs.AX := $6521;                            { "Capitalize String" }
  Regs.CX := 255;                              { "string"-length }
  Regs.DS := Seg(theTable);                    { DS:DX... }
  Regs.DX := Ofs(theTable[1]);                 {  ...points to the "string"}
  Intr($21,Regs);                              { let DOS do it ! }
  isTableOK := (Regs.Flags and FCarry = 0);    { OK ? }
end;

function UpCase(ch : char) : char;
begin
  UpCase := theTable[BYTE(ch)]
end;

function UpCaseStr(S : String) : String;
var x: Byte;
begin
  for x := 1 to length(S) do
    S[x]:= theTable[BYTE(S[x])];
  UpCaseStr := S
end;

begin
  SetUpTable
end.


