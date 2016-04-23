{ Heres a drawbox routine frum my popwindow units...  Its not very optimized,
but its does the job :). may have to change some references to procedures
(eg. txt_color) but thats pretty simple.

             x1 and y1 ... top left col/row
             x2 and y2 ... bottom right col/row
             Ft and Bk ... Sets the foreground/background
             Style ....... box style.
             MSG_S ....... Window ttitle }

Procedure Drawbox(x1, y1, x2, y2: byte; Ft, Bk, Style : Integer; MSG_S :
String);
Var TL, TR, BL, BR, HL, VL, msgl, msgr : Char; strlen : integer;
Begin
      case Style of
{         0 : new MS-DOS edit style.; }
          1 : begin { single line }
                   TL := #218; TR := #191; BL := #192; BR := #217;
                   VL := #179; HL := #196;
              end;
          2 : begin {double}
                   TL := #201; TR := #187; BL := #200; BR := #188;
                   VL := #186; HL := #205;
              end;
          3 : begin {Shaded}
                   TL := #176; TR := #176; BL := #176; BR := #176;
                   VL := #176; HL := #176;
              end;
          4 : begin {semishaded}
                   TL := #177; TR := #177; BL := #177; BR := #177;
                   VL := #177; HL := #177;
              end;
          5 : begin {shaded}
                   TL := #178; TR := #178; BL := #178; BR := #178;
                   VL := #178; HL := #178;
              end;
          6 : begin {Full block}
                  TL := #219; TR := #219; BL := #219; BR := #219;
                  VL := #219; HL := #219;
              end;
          7 : begin {double vert.}
                   TL := #214; TR := #183; BL := #211; BR := #189;
                   VL := #186; HL := #196;
              end;
          8 : begin {double horz.}
                   TL := #213; TR := #184; BL := #212; BR := #190;
                   VL := #179; HL := #205;
              end;
          9 : begin {double horz. vert single}
                   TL := #218; TR := #191; BL := #192; BR := #217;
                   VL := #179; HL := #205;
              end;
        else
             begin
                   TL := #32; TR := #32; BL := #32; BR := #32;
                   VL := #32; HL := #32;
             end;
      end;
  txt_color(Ft, Bk);
  gotoxy(x1,y1); write(tl);
  gotoxy(x2,y1); write(tr);
  gotoxy(x1,y2); write(bl);
  gotoxy(x2,y2); write(br);
  for Ctr := x1+1 to x2-1 do
  begin
       gotoxy(Ctr,y1);
       write(hl);
  end;
  for Ctr := x1+1 to x2-1 do
  begin
       gotoxy(Ctr,y2);
       write(hl);
  end;
  for Ctr := y1+1 to y2-1 do
  begin
       gotoxy(x1,Ctr);
       write(vl);
  end;
  for Ctr := y1+1 to y2-1 do
  begin
       gotoxy(x2,Ctr);
       write(vl);
  end;
  If MSG_S <> '' Then
     begin
          Strlen := Length(MSG_S) + 4;
          If Strlen > x2 - x1 Then EXIT;
          Gotoxy(x2 - strlen,y1);
          case Style of
             1,7 : begin
                        msgl := #180; msgr := #195;
                   end;
           2,8,9 : begin
                        msgl := #181; msgr := #198;
                   end;
               3 : begin
                        msgl := #176; msgr := #176;
                   end;
               4 : begin
                        msgl := #177; msgr := #177;
                   end;
               5 : begin
                        msgl := #178; msgr := #178;
                   end;
               6 : begin
                        msgl := #219; msgr := #219;
                   end;
               9 : begin
                        msgl := #180; msgr := #195;
                   end;
          end;
         Write(msgl); forecolor(14); rearcolor(0); Write(' ',MSG_S,' ');
         forecolor(Ft); rearcolor(Bk); Write(msgr);
     end;
End;
