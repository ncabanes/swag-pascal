(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0014.PAS
  Description: Get a programs directory
  Author: JOSE ALMEIDA
  Date: 08-18-93  12:22
*)

{ Gets the program directory.
  Part of the Heartware Toolkit v2.00 (HTfile.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION Get_Prg_Dir : string;

{ DESCRIPTION:
    Gets the program directory.
  SAMPLE CALL:
    St := Get_Prg_Dir;
 RETURNS:
    The program directory, e.g., E:\TP\
 NOTES:
    The program directory is always where the program .EXE file is located.
    This function add a backslash at the end of string. }

var
  Tmp : string;

BEGIN { Get_Prg_Dir }
  Tmp := ParamStr(0);
  while (Tmp[Length(Tmp)] <> '\') and (Length(Tmp) <> 0) do
    Delete(Tmp,Length(Tmp),1);
  if Tmp = '' then
    Tmp := Get_Cur_Dir;
  Get_Prg_Dir := Tmp;
END; { Get_Prg_Dir }

