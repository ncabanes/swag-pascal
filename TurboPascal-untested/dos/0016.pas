{ Gets the program name.
  Part of the Heartware Toolkit v2.00 (HTfile.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION Get_Prg_Name : String8;

{ DESCRIPTION:
    Gets the program name.
  SAMPLE CALL:
    St := Get_Prg_Name;
  RETURNS:
    The program name, e.g., '12345678'
                      or    '$$$$$$$$' if not available.
  NOTES:
    This function excludes the .EXE extension of the program. }

var
  St    : string;
  F     : byte;
  Found : boolean;

BEGIN { Get_Prg_Name }
  St := ParamStr(0);
  Found := No;
  F := Length(St);
  while (F > 0) and (not Found) do
    begin
      if St[F] = '\' then
        Found := Yes
      else
        Dec(F);
    end;
  St := Copy(St,Succ(F),255);
  F:= Pos('.',St);
  Delete(St,F,255);
  if St = '' then
    St := '$$$$$$$$';
  Get_Prg_Name := St;
END; { Get_Prg_Name }
