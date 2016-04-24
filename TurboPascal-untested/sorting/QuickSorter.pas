(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0040.PAS
  Description: QUICK SORTER
  Author: BOB SWART
  Date: 11-21-93  09:46
*)

{
From: BOB SWART
Subj: Sorting...
---------------------------------------------------------------------------
 Does anyone know of a VERY fast way to sort something?  I would
 really like  to view some source code on this if possible.  I need to
 sort over 1200  strings, and do it rather quickly.

 Try this, it uses a TStringCollection...
}

{$IFDEF VER70}
{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S+,T-,V-,X-}
{$ELSE}
{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S+,V-,X-}
{$ENDIF}
{$M 16384,0,655360}
{
  Sorteer 3.0
  Borland Pascal (Objects) 7.0.
  Copr. (c) 9-29-1993 DwarFools & Consultancy drs. Robert E. Swart
                      P.O. box 799
                      5702 NP  Helmond
                      The Netherlands
  Code size: 5824 Bytes
  Data size: 1254 Bytes
  .EXE size: 4971 Bytes
  ----------------------------------------------------------------
  Authors: Bob Swart (2:281/256.12)
           Hans van der Veeke (2:282/517.2)
}
uses {$IFDEF WINDOWS}
     WinCrt,
     {$ENDIF}
     Objects;

Type
  PStr = ^TStr;
  TStr = object(TObject)
           StrName: PString;
           constructor Init(_StrName: String);
         end {TStr};

  constructor TStr.Init(_StrName: String);
  begin
    TObject.Init;
    StrName := NewStr(_StrName)
  end {Init};

Type
  PStrColl = ^TStrColl;
  TStrColl = object(TStringCollection)
               function KeyOf(Item: Pointer): Pointer; virtual;
             end {TStrColl};

  function TStrColl.KeyOf(Item: Pointer): Pointer;
  begin
    KeyOf := PStr(Item)^.StrName
  end {KeyOf};

var StrColl: PStrColl;
    Line: String;
    F: Text;
begin
  writeln('Sorteer - Sort strings (c) 1993 by Bob Swart & Hans van der Veeke.'#13#10);
  if ParamCount = 0 then
  begin
    writeln('Usage: Sorteer [ASCII file to be sorted]');
    Halt(0)
  end;
  Assign(F,ParamStr(1));
  reset(F);
  if IOResult <> 0 then
  begin
    writeln('Error - could not open file ',ParamStr(1));
    Halt(1)
  end;
  StrColl := New(PStrColl,Init(1000,500));
  StrColl^.Duplicates := True; { make False for NO duplicates }
  while not Eof(F) do
  begin
    readln(F,Line);
    if Length(Line) > 0 then StrColl^.Insert(New(PStr, Init(Line)))
  end;
  Close(F);
  while StrColl^.Count > 0 do
  begin
    writeln(PStr(StrColl^.At(0))^.StrName^); { print first element }
    StrColl^.AtFree(0); { delete and dispose first element StrColl }
  end
end.

