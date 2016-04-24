(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0116.PAS
  Description: Get/Set environment vars
  Author: KAI PIJPSTRA
  Date: 08-30-97  10:09
*)

{----------------------------------------------------------}
{  Unit to get/set environment vars                        }
{  Kai Pijpstra, Groningen, the Netherlands, 1996          }
{----------------------------------------------------------}
unit Environ;
{$R-,X+}
interface

type
  PCharArray = ^TCharArray;
  TCharArray = array[0..0] of char;

  PPSP = ^TPSP;
  TPSP = record
    Int20hInstruction   : word;
    MemorySize          : word;
    Reserved1           : byte;
    DOSFuncDispatcher   : array[0..4] of byte;
    Int22h              : pointer;
    Int23h              : pointer;
    Int24h              : pointer;
    ParentSegment       : word;
    FileHandleArray     : array[0..19] of byte;
    EnvSegment          : word;
    LastSSSP            : pointer;
    HandleArraySize     : word;
    HandleArrayPtr      : pointer;
    PreviousPSP         : pointer;
    Reserved3           : array[0..19] of byte;

    Int21hRetf          : array[0..2] of byte;
    Reserved4           : array[0..8] of byte;
    FCB1                : array[0..15] of byte;
    FCB2                : array[0..19] of byte;
    ParamString         : string[127];
  end;

function  GetPSP:PPSP;
{ Get current PSP }

function  GetMasterPSP:PPSP;
{ Get PSP of Master COMMAND.COM }

function  EnvFromPSP(PSP:PPSP):PCharArray;
{ Retrieve pointer to environment from PSP }

function  GetEnvStr(Env:PCharArray; SubStr:string):PCharArray;
{ Find a substring in the environment }

procedure DelEnvStr(Env:PCharArray; SubStr:string);
{ Delete a substring in the environment }

procedure AddEnvStr(Env:PCharArray; SubStr:string);
{ Add a substring to the environment }

implementation
uses dos;
type
  PMCB = ^TMCB;
  TMCB = record
    Ident               : char;
    OwnerPSPSeg         : word;
    Size                : word;
    reserved            : array[0..10] of byte;
    ProgramName         : array[0..7] of char;
    Data                : array[0..0] of byte;
  end;

function ASCIIZLength(S:PCharArray):integer;
var I:integer;
begin
  I:=0;
  while S^[I]<>#0 do Inc(I);
  ASCIIZLength:=I;
end;

function PtrVal(P:Pointer):LongInt;
begin
  PtrVal:=Seg(P^)*16+Ofs(P^)
end;

function PtrDiff(P1,P2:pointer):LongInt;
begin
  PtrDiff:=PtrVal(P2)-PtrVal(P1);
end;

{----------------------------------------------------------}
const
  EnvSize       : word = 0;

function GetFP(S:String):string;
var I:Integer;
begin
  I:=Pos('=',S);
  if I=0 then GetFP:=''
  else GetFP:=Copy(S,1,I);
end;

function GetEnvSize(PSP:PPSP):word;
begin
  GetEnvSize:=PMCB(ptr(PSP^.EnvSegment-1,0))^.Size*16;
end;

function GetPSP:PPSP;
var regs:registers; PSP:PPSP;
begin
  with regs do begin
    ah:=$62;
    MsDos(regs);
    PSP:=ptr(bx,0);
    EnvSize:=GetEnvSize(PSP);
  end;
  GetPSP:=PSP;
end;

function GetMasterPSP:PPSP;
var DPSP,PSP:PPSP;
begin
  DPSP:=GetPSP;
  repeat
    PSP:=DPSP;
    DPSP:=ptr(PSP^.ParentSegment,0);
  until(PSP=DPSP);
  EnvSize:=GetEnvSize(PSP);
  GetMasterPSP:=PSP;
end;

function GetEnvStr(Env:PCharArray; SubStr:string):PCharArray;
var I,Start:word; S:String;
  function GetNextString(var S:String):boolean;
  begin
    GetNextString:=Env^[I]<>#0;
    S:='';
    while Env^[I]<>#0 do begin
      S:=S+Env^[I];
      Inc(I);
    end;
  end;
begin
  GetEnvStr:=nil;
  I:=0; Start:=0;
  SubStr:=GetFP(SubStr);
  repeat
    if not GetNextString(S) then exit;
    if Pos(SubStr,S)<>0 then begin
      GetEnvStr:=ptr(Seg(Env^),Start);
      exit;
    end;
    Inc(I);
    Start:=I;
  until 1+1=3;
end;

function FindEnvEnd(Env:PCharArray):word;
var I:word;
begin
  I:=0;
  while Env^[I]<>#0 do begin
    while Env^[I]<>#0 do Inc(I);
    Inc(I);
  end;
  FindEnvEnd:=I;
end;

procedure DelEnvStr(Env:PCharArray; SubStr:string);
var NewEnv:PCharArray; S:PCharArray; Diff,SSize:word;
begin
  GetMem(NewEnv,EnvSize);
  Move(Env^,NewEnv^,EnvSize);
  S:=GetEnvStr(NewEnv,SubStr);
  if S<>nil then begin
    SSize:=ASCIIZLength(S)+1;
    Diff:=PtrDiff(NewEnv,S);
    Move(NewEnv^[Diff+SSize],NewEnv^[Diff],EnvSize-(Diff+SSize));
    Move(NewEnv^,Env^,EnvSize);
  end;
  FreeMem(NewEnv,EnvSize);
end;

procedure AddEnvStr(Env:PCharArray; SubStr:string);
var NewEnv:PCharArray; EEnd,SSize:word;
begin
  GetMem(NewEnv,EnvSize);
  Move(Env^,NewEnv^,EnvSize);
  DelEnvStr(NewEnv,SubStr);
  EEnd:=FindEnvEnd(NewEnv);
  SubStr:=SubStr+#0#0;
  SSize:=Length(SubStr);
  while(SSize>0)and(SSize+EEnd>EnvSize) do Dec(SSize);
  if SSize>0 then begin
    Move(SubStr[1],NewEnv^[EEnd],SSize);
    Move(NewEnv^,Env^,EnvSize);
  end;
  FreeMem(NewEnv,EnvSize);
end;

function EnvFromPSP;
begin
  EnvFromPSP:=ptr(PSP^.EnvSegment,0);
end;

{----------------------------------------------------------}

end.

{TEST PROGRAM

uses Crt,Environ;

procedure WriteLnASCIIZ(S:PCharArray);
var I:integer;
begin
  I:=0;
  while S^[I]<>#0 do begin
    Write(S^[I]);
    Inc(I);
  end;
end;

procedure WriteEnv(Env:PCharArray);
var I:integer;
begin
  I:=0;
  while Env^[I]<>#0 do begin
    while Env^[I]<>#0 do begin
      Write(Env^[I]);
      Inc(I);
    end;
    WriteLn;
    Inc(I);
  end;
end;

var ENV:PCharArray; PSP:PPSP;
  I:integer;
begin
  ClrScr;
  PSP:=GetMasterPSP;
  Env:=EnvFromPSP(PSP);
  DelEnvStr(Env,'KAI=');
  WriteEnv(Env);
  WriteLn('--');
  AddEnvStr(Env,'KAI=GEK !!');
  WriteEnv(Env);
end.
