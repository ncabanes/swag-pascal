(*
  Category: SWAG Title: TEXT WINDOWING ROUTINES
  Original name: 0006.PAS
  Description: WINDOWS3.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  14:08
*)

DS>  Like say there is a Text Window that pops up when someone makes a
DS>choice. Then they select something else and a Text Window is made that
DS>overlaps the previous one.  Then I'd like to have it so if the user
DS>were to press, say, escape, the current Text Window would be "removed"
DS>and the old Window would still be there as is was....
DS>How can this be done??  Please keep in mind that I'm still sort of

Here's two Procedures a friend of mine wrote (David Thomas: give credit
whree credit is due).  It works great With regular Text screens.


Put This in you Type section:

  WindowStatus = (OnScreen, OffScreen);
  WindowType = Record
                 Point    : Pointer;
                 Status   : WindowStatus;
                 Col,
                 Row,
                 SaveAttr : Byte;
               end;

Procedure GetWindow (Var Name : WindowType);
Var
  Size,
  endOffset,
  StartOffset  : Integer;
begin   { GetWindow }

  With Name Do
    begin
      Col := WhereX;
      Row := WhereY;
      SaveAttr := TextAttr;

      StartOffset := 0;
      endOffset   := 25 * 160;
      Size := endOffset - StartOffset;
      GetMem (Point, Size);

      Move (Mem[$B800:StartOffset], Point^, Size);
      Status := OnScreen;
    end; { With }

end;    { GetWindow }
{--------------------------------------------------------------------}
Procedure PutWindow (Var Name : WindowType);
Var
  Size,
  endOffset,
  StartOffset  : Integer;
begin   { PutWindow }

  With Name Do
    begin
      StartOffset := 0;
      endOffset   := 25 * 160;
      Size := endOffset - StartOffset;

      Move (Point^, Mem[$B800:StartOffset], Size);

      FreeMem (Point, Size);
      Status := OffScreen;

      TextAttr := SaveAttr;
      GotoXY (Col, Row);
    end; { With }

end;    { PutWindow }


Very easy to use.  Just declare a Varibale of WindowType, call the
GETWindow routine, then display whatever.  When you're done, call the
PUTWindow routine and it Zap, it's back to how it was.  Very face, very
nice.

