(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0022.PAS
  Description: Good Mouse Support
  Author: FRED JOHNSON
  Date: 08-24-94  13:46
*)


unit mouse3;
{-------------------------------------------------------------------------
Reference Table
  M1 M2 M3 M4
  1  0  0  0   = Turn Mouse on with cursor.
  2  0  0  0   = Turn Mouse Off.
  3  ?  ?  ?   = To see if buttons are pressed.
                  Test registers with logical AND   (M2 is BX register)
                  M2 and 1 = Left Button
                  M2 and 2 = Right Button
                  M2 and 3 = Left and Right Buttons
                  M2 and 4 = Middle Button
                  M2 and 5 = Left and Middle Buttons
                  M2 and 6 = Right and Middle Buttons
                  M2 and 7 = Left, Middle and Right Buttons

  3  0  X  Y  = Get Mouse Cursor position.
                 M3 (CX) will return Mouse X coordinates. ( 0   = left wall)
                 M4 (DX) will return Mouse Y coordinates. ( 632 = right wall)
                 Divide by 8 and add 1 for Turbo Pascal XY position.

  4  0  X  Y  = Set Mouse Cursor position.
                 M3 (CX) set for Mouse X coordinate.      ( 0   = left wall)
                 M4 (DX) set for Mouse Y coordinate.      ( 632 = right wall)

  6  ?  0  0  = Mouse Button Release Status.              M2 (BX) set if True
}

interface

USES dos,crt;

TYPE
   xMouseFuncs = record
      bFunction : function : boolean;
   end;

VAR
   M1,M2,M3,M4 : word;
   Regs        : Registers;  { MS DOS Registers }

PROCEDURE Mouse( var M1,M2,M3,M4 : word );
PROCEDURE DeInitMouse;
PROCEDURE InitMouse;
PROCEDURE GetMousePos;
PROCEDURE GetMouseStats;
PROCEDURE SetMousePos(xM3, yM4:word);

FUNCTION  MPos(wPosition : word) : word;
FUNCTION  LeftButton             : Boolean;
FUNCTION  LeftAndRightButtons    : Boolean;
FUNCTION  LeftAndMiddleButtons   : Boolean;
FUNCTION  RightAndMiddleButtons  : Boolean;
FUNCTION  LeftMidAndRightButtons : Boolean;
FUNCTION  MiddleButton           : Boolean;
FUNCTION  RightButton            : Boolean;
FUNCTION  MouseRelease           : boolean;

const
   MouseButton : array[1..7] of xMouseFuncs =
      (
      (bFunction : LeftButton),
      (bFunction : RightButton),
      (bFunction : LeftAndRightButtons),
      (bFunction : MiddleButton),
      (bFunction : LeftAndMiddleButtons),
      (bFunction : RightAndMiddleButtons),
      (bFunction : LeftMidAndRightButtons)
      );

   MOUSE_REST  = 0;
   MOUSE_L     = 1;
   MOUSE_R     = 2;
   MOUSE_L_R   = 3;
   MOUSE_M     = 4;
   MOUSE_L_M   = 5;
   MOUSE_R_M   = 6;
   MOUSE_L_M_R = 7;

implementation


FUNCTION MPos(wPosition : word) : word;
   begin
      MPos := (wPosition div 8)+1;
   end;

FUNCTION LeftButton : Boolean;
   begin
      LeftButton := FALSE;
      if (M2 and 1) <> MOUSE_REST then
         begin                { if left button pressed }
            LeftButton := TRUE;
         end;
   end;

FUNCTION RightButton : Boolean;
   begin
      RightButton := FALSE;
      if (M2 and 2) <> MOUSE_REST then
         begin                { if right button pressed }
            RightButton := TRUE;
         end;
   end;

FUNCTION LeftAndRightButtons : Boolean;
   begin
      LeftAndRightButtons := FALSE;
      if (M2 and 3) = 3 then
         begin
            LeftAndRightButtons := TRUE;
         end;
   end;

FUNCTION MiddleButton : Boolean;
   begin
      MiddleButton := FALSE;
      if (M2 and 4) <> MOUSE_REST then
         begin
            MiddleButton := TRUE;
         end;
   end;

FUNCTION LeftAndMiddleButtons : Boolean;
   begin
      LeftAndMiddleButtons := FALSE;
      if (M2 and 5) = MOUSE_L_M then
         begin
            LeftAndMiddleButtons := TRUE;
         end;
   end;

FUNCTION RightAndMiddleButtons : Boolean;
   begin
      RightAndMiddleButtons := FALSE;
      if (M2 and 6) = MOUSE_R_M then
         begin
            RightAndMiddleButtons := TRUE;
         end;
   end;

FUNCTION LeftMidAndRightButtons : Boolean;
   begin
      LeftMidandRightButtons := FALSE;
      if (M2 and 7) = MOUSE_L_M_R then
         begin
            LeftMidAndRightButtons := TRUE;
         end;
   end;

FUNCTION MouseRelease : boolean;
  begin
     MouseRelease := FALSE;
     M1 := 6;
     Mouse( M1,M2,M3,M4 ); { Set mouse cursor ON }
     if MOUSE_REST <> M2 then
        begin
           MouseRelease := TRUE;
        end;
  end;

PROCEDURE Mouse( var M1,M2,M3,M4 : word );
   begin
      With Regs DO
         begin
            AX := M1;
            BX := M2;
            CX := M3;
            DX := M4;
         end;
      intr($33,Regs); { Interrupt $33, the mouse interrupt }

      With Regs DO
         begin
            M1 := AX;
            M2 := BX;
            M3 := CX;
            M4 := DX;
         end;
  end;

PROCEDURE InitMouse;
  begin
     M1 := 1;
     Mouse( M1,M2,M3,M4 ); { Set mouse cursor ON }
  end;

PROCEDURE DeInitMouse;
  begin
     M1 := 2;
     Mouse( M1,M2,M3,M4 ); { Set mouse cursor OFF }
  end;

PROCEDURE GetMousePos;
   begin
      M1 := 3;
      Mouse(M1, M2, M3, M4);
   end;


PROCEDURE GetMouseStats;
   begin
      M1 := 3;
      M2 := 0;
      M3 := 0;
      m4 := 0;
      Mouse(M1, M2, M3, M4);
   end;

PROCEDURE SetMousePos(xM3, yM4:word);
   begin
      M1 := 4;
      Mouse(M1, M2, xM3, yM4);
   end;

begin
   initmouse; {Take this out if you do not wish mouse to auto initialize}
end.

{-----------------------------   DEMO PROGRAM ---------------------}

USES dos, crt, mouse3, Frame2;

VAR
   satisfied  : boolean;    { if mouse pos and button are together }

CONST
   Menu_ClrScr = 'C';
   Menu_Quit   = 'Q';

PROCEDURE DO_Mssg;
   begin
      gotoxy(1,24);
      writeln('Push Middle Button or L/R buttons together for menu');
      write('XY Coordinates totalling 40 will produce beep');
   end;

FUNCTION MenuHit(cChar : char) : Boolean;
   begin
      GetMousePos;
      MenuHit := FALSE;
      if (27 = MPos(M3)) and (MouseButton[MOUSE_L].bFunction) then
         begin
            if (Menu_ClrScr = cChar) and (11 = MPos(M4)) then
               begin
                  MenuHit := TRUE;
                  ClrScr;
                  Do_Mssg;
                  exit;
               end;

            if (Menu_Quit = cChar) and (12 = MPos(M4)) then
               begin
                  MenuHit := TRUE;
                  exit;
               end;
         end;
   end;

BEGIN
   satisfied := false;
   textcolor(7); { Grey }
   ClrScr;
   Do_Mssg;

   while not keypressed do { until  KEYBOARD key is pressed }
      begin
         GetMouseStats;
         gotoxy(1,1);
         write('M3 =',MPos(M3):2,
            ' M4 =',MPos(M4):2);

         if (MPos(M3)+MPos(M4) = 40) then
            begin
               write(#7);
            end;

         if MouseButton[MOUSE_L].bFunction  then
            begin
               gotoxy(16,1);
               write('Left Button');
               clreol;
            end;

         if MouseButton[MOUSE_R].bFunction then
            begin
               gotoxy(16,1);
               write('Right Button');
               clreol;
            end;

         if (MouseButton[MOUSE_M].bFunction= TRUE) or      {Middle Button}
            (MouseButton[MOUSE_L_R].bFunction = TRUE) then  {Left & Right}
               begin
                  SetMousePos(30*8, 11*8);  { Sets MCursor out of way }
                  Frame(1,25,10,39,13);
                  gotoxy(26,11);
                  textcolor(14);
                  write(' ',Menu_ClrScr);
                  textcolor(07);
                  write('learscreen');
                  gotoxy(26,12);
                  textcolor(14);
                  write(' ',Menu_Quit);
                  textcolor(07);
                  write('uit');
                  repeat
                     if MenuHit(Menu_ClrScr) = TRUE then
                        begin
                           satisfied := true;
                           SetMousePos(0,0); {Sets MCursor out of way }
                        end;
                     gotoxy(1,1);
                     write('M3 =',MPos(M3):2,
                        ' M4 =',MPos(M4):2);
                     clreol;

                     if MenuHit(Menu_Quit) = TRUE then
                        begin
                           satisfied := true;
                           DeInitMouse;
                           ClrScr;
                           halt;
                        end;
                  until satisfied = true;
                  {ClrScr;}
               end;
         satisfied := false;
      end;
   DeInitMouse;                                        { Turn Mouse Off }
   ClrScr;
END.

{ ------------------   UNIT FOR DEMO ABOVE -------------------- }

unit frame2;
interface
uses crt;

CONST
   DtDs = 1;
   StSs = 2;
   DtSs = 3;
   StDs = 4;

   xSides : array[1..4, 1..6] of char = {xSides:array[1..4,1..6]of char =}
      (                                 {   (}
      (#201,#205,#187,#186,#200,#188),  {   ('╔','═','╗','║','╚','╝'),}
      (#218,#196,#191,#179,#192,#217),  {   ('┌','─','┐','│','└','┘'),}
      (#213,#205,#184,#179,#212,#190),  {   ('╒','═','╕','│','╘','╛'),}
      (#214,#196,#183,#186,#211,#189)   {   ('╓','─','╖','║','╙','╜')}
      );                                {   );}

procedure Frame(
   iSideType,
   iUpperLeftX,
   iUpperLeftY,
   iLowerRightX,
   iLowerRightY  : Integer);

implementation

procedure Frame(
   iSideType,
   iUpperLeftX,
   iUpperLeftY,
   iLowerRightX,
   iLowerRightY   : Integer);

var
   i: Integer;

begin
   GotoXY(iUpperLeftX, iUpperLeftY);
   Write(xSides[iSideType][1]);
   for i:= iUpperLeftX+1 to iLowerRightX-1 do
      begin
         Write(xSides[iSideType][2]);
      end;
   Write(xSides[iSideType][3]);
   for i:= iUpperLeftY+1 to iLowerRightY-1 do
     begin
       GotoXY(iUpperLeftX , i);
       Write(xSides[iSideType][4]);
       GotoXY(iLowerRightX, i);
       Write(xSides[iSideType][4]);
     end;
   GotoXY(iUpperLeftX, iLowerRightY);
   Write(xSides[iSideType][5]);
   for i:= iUpperLeftX+1 to iLowerRightX-1 do
      begin
         Write(xSides[iSideType][2]);
      end;
   Write(xSides[iSideType][6]);
end;

end.

