{
From: FRED JOHNSON
Subj: Mousey Control..
Can someone out there please explain how to read from the mouse?
}

{Explanation below in reference table}
USES dos,crt;

VAR
 M1,M2,M3,M4 : word;
 Regs        : Registers;  { MS DOS Registers }
 satisfied   : boolean;    { if mouse pos and button are together }

PROCEDURE mouse( var M1,M2,M3,M4 : word );
  begin
    With Regs DO
      begin
        AX := M1; BX := M2; CX := M3; DX := M4;
      end;
    intr($33,Regs); { Interrupt $33, the mouse interrupt }
    With Regs DO
      begin
        M1 := AX; M2 := BX; M3 := CX; M4 := DX;
      end;
  end;

PROCEDURE initmouse;
  begin
    M1 := 1 ; Mouse( M1,M2,M3,M4 ) { Set mouse cursor ON }
  end;

BEGIN
  satisfied := false;
  textcolor(7); { Grey }
  clrscr;
  initmouse;
 while not keypressed do { until  KEYBOARD key is pressed }
    begin
     M1 := 3;
      MOUSE(m1,M2,M3,M4);
      IF (M2 and 1) <> 0 then
        begin                { if left button pressed }
          writeln(' Left Button');
          write(' M3 =',M3 div 8); write(' M4 =',M4 div 8);
        end;
      if (M2 and 2) <> 0 then
        begin                { if rght button pressed }
          writeln(' Right Button');
          write(' M3 =',M3 div 8); write(' M4 =',M4 div 8);
        end;
      if (M2 and 4) <> 0 then                      {if midlbutton pressed}
        begin
          M1 := 4; M2 := 0; M3 := 30*8; M4 := 11*8; {Sets MCursor out of }
          mouse( M1,M2,M3,M4 );                     {the way }
          gotoxy(25,10); write('***************');
          gotoxy(25,11); write('* ');textcolor(14);
          write('C'); textcolor(07); write('learscreen *');
          gotoxy(25,12); write('* '); textcolor(14);
          write('Q'); textcolor(07); write('uit        *');
          gotoxy(25,13); write('***************');
          repeat
            M1 := 3;
            mouse(M1,M2,M3,M4);
            if (M3 div 8) = 26 then                 { Tests X position }
              if (M4 div 8) = 10 then               { Tests Y position }
                if (M2 and 1) <> 0 then             { Tests lft button }
                  begin
                    satisfied := true;
                    M1 := 4; M2  := 0; M3 :=0; M4 :=0;{MCursor out of way}
                    mouse( M1,M2,M3,M4 );
                    clrscr;
                  end;

            if (M3 div 8) = 26 then                { Tests X position }
              if (M4 div 8) = 11 then              { Tests Y position }
                if (M2 and 1) <> 0 then            { Tests lft button }
                  begin
                    satisfied := true;
                    M1 := 0; M2 :=0; M3 :=0; M4 := 0;  { Turn Mouse Off }
                    mouse( M1,M2,M3,M4 );
                    clrscr;
                    halt;
                  end;

          until satisfied = true;
          clrscr;
          end;
          satisfied := false;
   end;
   M1 := 0;                                            { Turn Mouse Off }
   mouse(M1,M2,M3,M4);
END.

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
                 M3 (CX) will return Mouse X coordinates. (0  =left wall)
                 M4 (DX) will return Mouse Y coordinates. (632= rght wall)
                 Divide by 8 and add 1 for Turbo Pascal XY position.

  4  0  X  Y  = Set Mouse Cursor position.
                 M3 (CX) set for Mouse X coordinate.      (0  = left wall)
                 M4 (DX) set for Mouse Y coordinate.      (632= rght wall)

  6  ?  0  0  = Mouse Button Release Status.             M2(BX)set if True

                          Assembly Language Example
mov ax,0001   ; (M1 := 1)
int 33h       ; Set Mouse cursor ON
here:         ;
mov ax,0003   ; (M1 := 3)
int 33h       ; Test for mouse Keypress
and bx,1      ; left button?
jne lft       ;
mov ax,0003   ;
int 33h       ;
and bx,2      ; right button?
jne rht       ;
mov ax,0003   ;
int 33h       ;
and bx,4      ; middle button?
jne mid       ;
jmp here      ; if not keep looping
lft:          ;
mov dx,lft_st ; address of string if left button
jmp prnt      ;
rht:          ;
mov dx,rht_st ; address of string if right button
