{ Gets the cursor position for each of the eight display pages.
  Part of the Heartware Toolkit v2.00 (HTcursor.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

PROCEDURE Get_Cursor_Position(Page : byte;
                        var Column,
                               Row : byte);
{ DESCRIPTION:
    Gets the cursor position for each of the eight display pages.
  SAMPLE CALL:
    Get_Cursor_Position(0,Col,Row);
  RETURNS:

  NOTES:
    Page value must be from 0 to 7 }

BEGIN { Get_Cursor_Position }
  Column := Succ(Lo(MemW[$0000:$0450 + Page * 2]));
  Row := Succ(Hi(MemW[$0000:$0450 + Page * 2]));
END; { Get_Cursor_Position }
