(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0084.PAS
  Description: Filling Memory
  Author: SWAG SUPPORT TEAM
  Date: 09-04-95  10:49
*)


program FillMem;

uses
  OpRoot;

const
  FillCh : Byte = 0;

var
  P : Pointer;
  A : Word;
  B : Boolean;
  S : String[3];


begin
  if ParamCount <> 0 then begin
    S := ParamStr(1);
    if S[1] <> '$' then
      S := '$'+S;
    Val(S, FillCh, A);
    if A <> 0 then exit;
  end;

  A := $8000;
  while True do begin
    B := GetMemCheck(P, A);
    if B then
      FillChar(P^, A, FillCh)
    else begin
      if A <= 8 then exit;
      A := A shr 1;
    end;
  end;
end.



