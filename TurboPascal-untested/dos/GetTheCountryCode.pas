(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0017.PAS
  Description: Get the Country Code
  Author: JOSE ALMEIDA
  Date: 08-18-93  12:30
*)

{ Gets the current country code number.
  Part of the Heartware Toolkit v2.00 (HTelse.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

PROCEDURE Get_Country_Code(var CC : word;
                   var Error_Code : byte);
{ DESCRIPTION:
    Gets the current country code number.
  SAMPLE CALL:
    Get_Country_Code(CC,Error_Code);
  RETURNS:
    CC         : country code number
                 or $FFFF if Error_Code <> 0
    Error_Code : see The Programmers PC Source Book 3.191
  NOTES:
    None. }

var
  TmpA   : array[1..34] of byte;
  HTregs : registers;

BEGIN { Get_Country_Code }
  FillChar(TmpA,SizeOf(TmpA),0);
  HTregs.AX := $3800;
  HTregs.DX := Ofs(TmpA);
  HTregs.DS := Seg(TmpA);
  MsDos(HTregs);
  if HTregs.Flags and FCarry <> 0 then
    begin
      CC := $FFFF;           { on error set to $FFFF }
      Error_Code := HTregs.AL;
    end
  else
    begin
      CC := HTregs.BX;
      Error_Code := 0;
    end;
END; { Get_Country_Code }



FUNCTION Get_Country_Code_Text(CC : word) : String25;

{ DESCRIPTION:
    Gets country code in string format.
  SAMPLE CALL:
    St := Get_Country_Code_Text(CC);
  RETURNS:
    Country code name.
  NOTES:
    None. }

BEGIN { Get_Country_Code_Text }
  case CC of
    001 : Get_Country_Code_Text := 'United States';
    002 : Get_Country_Code_Text := 'Canada (French)';
    003 : Get_Country_Code_Text := 'Latin America';
    031 : Get_Country_Code_Text := 'Netherlands';
    032 : Get_Country_Code_Text := 'Belgium';
    033 : Get_Country_Code_Text := 'France';
    034 : Get_Country_Code_Text := 'Spain';
    036 : Get_Country_Code_Text := 'Hungary';
    038 : Get_Country_Code_Text := 'Yugoslavia';
    039 : Get_Country_Code_Text := 'Italy';
    041 : Get_Country_Code_Text := 'Switzerland';
    042 : Get_Country_Code_Text := 'Czechoslovakia';
    044 : Get_Country_Code_Text := 'United Kingdom';
    045 : Get_Country_Code_Text := 'Denmark';
    046 : Get_Country_Code_Text := 'Sweden';
    047 : Get_Country_Code_Text := 'Norway';
    048 : Get_Country_Code_Text := 'Poland';
    049 : Get_Country_Code_Text := 'Germany';
    055 : Get_Country_Code_Text := 'Brazil';
    061 : Get_Country_Code_Text := 'International English';
    081 : Get_Country_Code_Text := 'Japan';
    082 : Get_Country_Code_Text := 'Korea';
    086 : Get_Country_Code_Text := 'Peoples Republic of China';
    088 : Get_Country_Code_Text := 'Taiwan';
    351 : Get_Country_Code_Text := 'Portugal';
    358 : Get_Country_Code_Text := 'Finland';
    785 : Get_Country_Code_Text := 'Middle East (Arabic)';
    972 : Get_Country_Code_Text := 'Israel (Hebrew)';
  else
    Get_Country_Code_Text := 'Unknown';
  end;
END; { Get_Country_Code_Text }

