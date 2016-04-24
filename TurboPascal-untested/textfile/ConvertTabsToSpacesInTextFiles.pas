(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0079.PAS
  Description: Convert tabs to spaces in text files
  Author: ANTON ZHUCHKOV
  Date: 05-30-97  18:17
*)

program DelTab;
uses Dos;

var
  F   : Text;
  FTo : Text;
  S : String;
  P,N,E : String;
  FName : String;
  CurF  : SearchRec;
  I     : Integer;

const
  Worked : Boolean = False;

begin
  Writeln('Tab-to-two-spaces exchanger v 1.0  (c) 1997 Tigers Of Softland');
  if ParamCount <> 0 then
    FName := ParamStr(1)
  else FName := '';
  FSplit(FName, P, N, E);
  if N = '' then N := '*';
  if E = '' then E := '.pas';
  FName := P + N + E;
  FindFirst(FName, Archive, CurF);
  while DosError = 0 do
  begin
    Write('Deleting tabs in ', CurF.Name);
    Assign(F, P + CurF.Name);
    Reset(F);
    Assign(FTo, P+'$TEMP$');
    Rewrite(FTo);
    while not EOF(F) do
    begin
      Readln(F, S);
      I := Pos(#9, S);
      while I <> 0 do
      begin
        Delete(S, I, 1);
        Insert('  ', S, I);
        I := Pos(#9, S);
      end;
      Writeln(FTo, S);
    end;
    Close(F);
    Close(FTo);
    Erase(F);
    Rename(FTo, CurF.Name);
    Writeln(', done.');
    Worked := True;
    FindNext(CurF);
  end;
  if not Worked then
    Writeln('Nothing to do!');
end.


