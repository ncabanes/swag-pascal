(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0023.PAS
  Description: Get the active code page
  Author: JOSE ALMEIDA
  Date: 08-18-93  12:20
*)

{ Gets the active (set by user) and system (at boot byte) code page.
  Part of the Heartware Toolkit v2.00 (HTelse.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

PROCEDURE Get_Code_Page(var Active_CP : word;
                       var System_CP : word;
                       var Error_Code : byte);
{ DESCRIPTION:
    Gets the active (set by user) and system (at boot byte) code page.
  SAMPLE CALL:
    Get_Code_Page(Active_CP,Default_CP,Error_Code);
  RETURNS:
    Active : active code page set by user
    System : system code page at boot time
    Error_Code
      0 : no error
      else : see The Programmers PC Source Book 3.191
  NOTES:
    Applies to all versions beginning with v3.3.
    See Get_Code_Page_Text() in order to get string text. }

var
  HTregs : registers;

BEGIN { Get_Code_Page }
  HTregs.AX := $6601;
  MsDos(HTregs);
  if HTregs.Flags and FCarry <> 0 then
    begin
      Active_CP := $FFFF;           { on error set to $FFFF }
      System_CP := $FFFF;           { on error set to $FFFF }
      Error_Code := HTregs.AL;
    end
  else
    begin
      Active_CP := HTregs.BX;
      System_CP := HTregs.DX;
      Error_Code := 0;
    end;
END; { Get_Code_Page }



FUNCTION Get_Code_Page_Text(CP : word) : String14;

{ DESCRIPTION:
    Gets the current active code page in string form.
  SAMPLE CALL:
    St := Get_Code_Page_Text(860);
  RETURNS:
    e.g.: 'Portugal'
  NOTES:
    None. }

BEGIN { Get_Code_Page_Text }
  case CP of
    437 : Get_Code_Page_Text := 'USA English';
    850 : Get_Code_Page_Text := 'Multilingual';
    852 : Get_Code_Page_Text := 'CZ/SL/HU/PL/YU';
          { CZ and SL = Czechoslovakia (Czech & Slovak) }
          { HU        = Hungary                         }
          { PL        = Poland                          }
          { YU        = Yugoslavia                      }
    854 : Get_Code_Page_Text := 'Spain';
    860 : Get_Code_Page_Text := 'Portugal';
    863 : Get_Code_Page_Text := 'Canada-French';
    865 : Get_Code_Page_Text := 'Norway/Denmark';
  else
    Get_Code_Page_Text := 'Unknown';
  end;
END; { Get_Code_Page_Text }

