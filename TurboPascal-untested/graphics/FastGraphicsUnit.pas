(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0244.PAS
  Description: Fast Graphics Unit
  Author: SWAG SUPPORT TEAM
  Date: 03-04-97  13:18
*)

{$F+,O+}
UNIT GAPP2;
{-----------}INTERFACE{------------}

USES Graph,crt,dos;

VAR
   Size,Result: word;
   p: Pointer;
   f: File;
   g : file of word;
   Regs : Registers;
   Count, Count2 : Byte;
   Pal1, Pal2 : Array [0..255, 0..2] of Byte;

CONST
  Speed1 = 75;

Procedure FadeOut;
{This procedure fades out a screen}
Procedure Fadein;
{This procedure fades in a screen}
PROCEDURE StatusBar(x,y,snum,enum : integer);
{This procedure animates the status bar}
PROCEDURE Status_Bar(x,y : Integer);
{Establishes the status bar}
PROCEDURE Animate_Bar(x,y,Snum,Enum : Integer);
{a second animation}
PROCEDURE ReadLnXY(X,Y,t: Integer;VAR S: String;col1,col2: Word);
{A graphics readln}
PROCEDURE shadow(x,y : integer;f,s : word;st : string);
{Shadows the text}
PROCEDURE frame(x,y,x1,y1 : integer;c1,c2 : word);
{frames a given area}
PROCEDURE dobutton(x,y : integer; s : string);
{draws the button}
PROCEDURE banimate(x,y : integer; s : string);
{animates the button}
FUNCTION CButton(x,y : integer; s : string) : Boolean;
{checks the button}
PROCEDURE SaveXY(X1,Y1,X2,Y2: Integer;s : string);
PROCEDURE showXY(x,y : integer;s : string);
PROCEDURE erase_file(s : string);
{Those procedures save, restores a saved screen, or deletes a file}
{Mouse Functions}
FUNCTION Mouseinbox(x,y,x1,y1 : integer) : boolean;
FUNCTION InitMouse : Boolean;
FUNCTION GetXPosition : Word;
FUNCTION GetYPosition : Word;
FUNCTION GetButtonPressed : Byte;
PROCEDURE ShowMouseCursor;
PROCEDURE HideMouseCursor;
PROCEDURE SetMousePosition(X, Y : Word);
{The following procedures draw a windows like line}
PROCEDURE Rectangle2(x,y,x1,y1 : Integer);
PROCEDURE Line2(x,y,x1,y1 : Integer);
PROCEDURE boxit(x,y : integer; S: String;St : Boolean);

{-------}IMPLEMENTATION{----------}

PROCEDURE status_Bar;
VAR
   x1,y1 : Integer;
BEGIN
     x1 := x + 306;
     y1 := y + 30;
     Setfillstyle(solidfill,white);
     Bar(x,y,x1,y1);
     Setcolor(Darkgray);
     Line(x,y,x,y1);
     line(x,y,x1,y);
     Setcolor(White);
     line(x,y1,x1,y1);
     line(x1,y,x1,y1);
     Setcolor(Black);
     Line(x+1,y+1,x+1,y1-1);
     line(x+1,y+1,x1-1,y+1);
     Setcolor(Lightgray);
     line(x+1,y1-1,x1-1,y1-1);
     line(x1-1,y+1,x1-1,y1-1);
END;

PROCEDURE animate_Bar;
BEGIN
     Setfillstyle(solidfill,blue);
     bar(x+3,y+3,round(snum / enum * 300)+x+3,y+27);
END;

PROCEDURE ReadLnXY;
VAR
  Ch       : Char;
  Done     : boolean;
  OldX     : Integer;
  limit    : integer;
  refresh,dele : Word;

          procedure prompt;
          begin
               Moveto(x,y);
               Outtext('_');
          end;
          procedure del;
          begin
               Setcolor(dele);
               Outtext('_');
               Oldx := getx - textwidth(S[Length(S)]);
               Moveto(oldx,y);
          end;
          procedure show;
          begin
               Setcolor(refresh);
               Outtext('_');
               Oldx := getx - textwidth(S[Length(S)]);
               Moveto(oldx,y);
          end;
          Procedure Blink;
          Begin
               Show;
               delay(10);
               del;
               delay(10)
          end;
BEGIN
  Settextstyle(font8x8,0,2);
  S := '';
  limit := 0;
  MoveTo(X, Y);
  Dele := Col1;
  Refresh := Col2;
  prompt;
  MoveTo(X, Y);
  Done := False;
  WHILE NOT Done DO
  BEGIN
     While not keypressed do Blink;
     Ch := Readkey;
    CASE Ch of
      #0  : Ch := Readkey;
      #13 : Done := true;
      #27 : Begin
                 S := 'ESCAPE KEY';
                 Done := True;
            End;
      'A'..'Z','a'..'z','0'..'9','.','-':
        BEGIN
          if limit <> 10 then
          begin
               del;
               setcolor(Col2);
               Outtext(ch);
               show;
               S := Concat(S, Ch);
               inc(limit);
          end;
        END;

      #8  : IF Length(S) > 0 THEN
        BEGIN
          del;
          dec(limit);
          OldX := GetX - TextWidth(S[Length(S)]);
          MoveTo(OldX, GetY);
          setcolor(dele);
          OutText('█');
          SetColor(refresh);
          MoveTo(OldX, GetY);
          Delete(S, Length(S), 1);
          show;
        END;
    END;
  END;
  del;
  setcolor(refresh);
END;

PROCEDURE Shadow;
BEGIN
     SetTextStyle(F,0,S);
     SetColor(Black);
     OutTextXY(x,y,st);
     Outtextxy(x-1,y-1,st);
     Outtextxy(x-2,y-2,st);
     SetColor(White);
     OutTextXY(x+1,y+1,st);
END;

PROCEDURE Frame;
VAR
   I : Integer;
BEGIN
     FOR I := 0 TO 1 DO
     BEGIN
          setcolor(c1);
          line(x+i,y+i,x+i,y1-i);
          line(x+i,y+i,x1-i,y+i);
          setcolor(C2);
          line(x1-i,y+i,x1-i,y1-i);
          line(x1-i,y1-i,x+i,y1-i);
     END;
     Setcolor(Black);
     Rectangle(x,y,x1,y1);
END;

procedure dobutton;
begin
     setfillstyle(solidfill,blue);
     Settextstyle(7,0,1);
     bar(x-10,y-3,x+5+textwidth(s)+10,y+5+textheight(s)+3);
     frame(x-10,y-3,x+5+textwidth(s)+10,y+5+textheight(s)+3,white,blue);
     Setcolor(Black);
     Outtextxy(x+5,y,s);
     Setcolor(white);
     Outtextxy(x+4,y+1,s);
     Setcolor(black);
     rectangle(x-10,y-3,x+5+textwidth(s)+10,y+5+textheight(s)+3);
end;

procedure banimate;
begin
     hidemousecursor;
     setfillstyle(solidfill,blue);
     bar(x-10,y-3,x+5+textwidth(s)+10,y+5+textheight(s)+3);
     Settextstyle(7,0,1);
     frame(x-10,y-3,x+5+textwidth(s)+10,y+5+textheight(s)+3,darkgray,blue);
     Setcolor(white);
     Outtextxy(x+4,y+1,s);
     Setcolor(black);
     rectangle(x-10,y-3,x+5+textwidth(s)+10,y+5+textheight(s)+3);
     showmousecursor;
     repeat
     until (getbuttonpressed <> 1);
     hidemousecursor;
     dobutton(x,y,s);
     showmousecursor;
end;

FUNCTION CButton;
BEGIN
     Settextstyle(7,0,1);
     CButton := MouseinBox(x-10,y-3,x+5+textwidth(s)+10,y+5+textheight(s)+3);
END;

PROCEDURE saveXY;
BEGIN
     Assign(F,s+'.kis');
     {$I-}
     rewrite(F,1);
     Assign(g,s+'1.kis');
     rewrite(g);
     size := imagesize(x1,y1,x2,y2);
     Write(G,size);
     close(g);
     getmem(P,size);
     getimage(x1,y1,x2,y2,p^);
     Blockwrite(F,P^,Size,result);
     close(f);
     freemem(P,size);
     size := 0;
END;

PROCEDURE ShowXY;
BEGIN
     Assign(F,s+'.kis');
     {$I-}
     reset(F,1);
     Assign(g,s+'1.kis');
     reset(g);
     read(g,size);
     close(g);
     getmem(P,size);
     blockread(F,P^,size,result);
     putimage(x,y,P^,normalput);
     Freemem(P,size);
     close(f);
     size := 0;
END;

PROCEDURE erase_file;
VAR
   q : file;
   r : file of word;
BEGIN
     assign(q,s+'.kis');
     erase(q);
     assign(r,s + '1.kis');
     erase(r);
END;

FUNCTION InitMouse;
Begin
  Regs.AX := 0;
  Regs.BX := 0;
  Intr($33, Regs);
  InitMouse := (Regs.AX <> 0);
End;

PROCEDURE ShowMouseCursor;
Begin
  Regs.AX := 1;
  Intr($33, Regs);
End;

PROCEDURE HideMouseCursor;
Begin
  Regs.AX := 2;
  Intr($33, Regs);
End;

FUNCTION GetXPosition;
Begin
  Regs.AX := 3;
  Intr($33, Regs);
  GetXPosition := Regs.CX;
End;

FUNCTION GetYPosition;
Begin
  Regs.AX := 3;
  Intr($33, Regs);
  GetYPosition := Regs.DX;
End;

FUNCTION GetButtonPressed;
Begin
  Regs.AX := 3;
  Intr($33, Regs);
  GetButtonPressed := Regs.BX
End;

PROCEDURE SetMousePosition;
Begin
  Regs.AX := 4;
  Regs.CX := X;
  Regs.DX := Y;
  Intr($33, Regs);
End;

FUNCTION Mouseinbox;
begin
     if (getxposition < x1) and (getxposition > x) and (getyposition < y1)
     and (getyposition > y ) then mouseinbox := true
                             else mouseinbox := false;
end;

Procedure Vret;
VAR b : byte;
label l1,l2;
BEGIN
l1:
     IF port[$3da] and 8 <> 0 THEN goto l1;
l2 :
     If port[$3da] and 8 <> 0 THEN goto l2;
End;

Procedure Getpalette;
begin
  For Count := 0 to 255 DO
  begin
    PORT [$03C7] := Count;            {Gets colour number}
    Pal1 [Count, 0] := PORT [$03C9];  {Gets red Setting}
    Pal1 [Count, 1] := PORT [$03C9];  {Gets Green Setting}
    Pal1 [Count, 2] := PORT [$03C9];  {Gets Blue Setting}
   end;
  Pal2 := Pal1;
end;

Procedure SetPalette;
begin
  For Count := 0 to 255 DO
  begin
    PORT [$03C8] := Count;           {Sets Colour}
    PORT [$03C9] := Pal1 [Count, 0]; {Sets red}
    PORT [$03C9] := Pal1 [Count, 1]; {Sets Green}
    PORT [$03C9] := Pal1 [Count, 2]; {Sets Blue}
  end;
end;

Procedure FadeOut;
begin
  Getpalette;
  For Count := 1 to Speed1 DO
  begin
    For Count2 := 0 to 255 DO
    begin
      if Pal2 [Count2, 0] > 0 then DEC (Pal2 [Count2, 0]);
      if Pal2 [Count2, 1] > 0 then DEC (Pal2 [Count2, 1]);
      if Pal2 [Count2, 2] > 0 then DEC (Pal2 [Count2, 2]);
      PORT [$03C8] := Count2;
      PORT [$03C9] := Pal2 [Count2, 0];
      PORT [$03C9] := Pal2 [Count2, 1];
      PORT [$03C9] := Pal2 [Count2, 2];
      Vret;
    end;
    delay(5);
  end;
end;

Procedure FadeIn;
begin
  For Count := 1 to Speed1 DO
  begin
    For Count2 := 0 to 255 DO
    begin
      if Pal2 [Count2, 0] < Pal1 [Count2, 0] then INC (Pal2 [Count2, 0]);
      if Pal2 [Count2, 1] < Pal1 [Count2, 1] then INC (Pal2 [Count2, 1]);
      if Pal2 [Count2, 2] < Pal1 [Count2, 2] then INC (Pal2 [Count2, 2]);
      PORT [$03C8] := Count2;
      PORT [$03C9] := Pal2 [Count2, 0];
      PORT [$03C9] := Pal2 [Count2, 1];
      PORT [$03C9] := Pal2 [Count2, 2];
      Vret;
    end;
   delay(5);
  end;
  SetPalette;
end;

PROCEDURE rectangle2(x,y,x1,y1 : Integer);
begin
     Setcolor(Darkgray);
     Line(x,y,x,y1);
     line(x,y,x1,y);
     Setcolor(White);
     line(x,y1,x1,y1);
     line(x1,y,x1,y1);
     Setcolor(Black);
     Line(x+1,y+1,x+1,y1-1);
     line(x+1,y+1,x1-1,y+1);
     Setcolor(Lightgray);
     line(x+1,y1-1,x1-1,y1-1);
     line(x1-1,y+1,x1-1,y1-1);
end;

PROCEDURE Line2(x,y,x1,y1 : Integer);
begin
     Setcolor(Darkgray);
     Line(x,y,x1,y1);
     Setcolor(White);
     Line(x,y+1,x1,y1+1);
End;

procedure boxit(x,y : integer; S: String;St : Boolean);
var
   size : word;
   p : pointer;
begin
     Case st of
     True :
     begin
          SettextStyle(Font8x8,0,0);
          size := imagesize(x-2,y-2,x+textwidth(S)+2,y+textheight(s)+2);
          getmem(P,size);
          getimage(x-2,y-2,x+textwidth(S)+2,y+textheight(s)+2,P^);
          Setfillstyle(Solidfill,yellow);
          Bar(x-2,y-2,x+textwidth(S),y+textheight(s));
          Setcolor(Black);
          Rectangle(x-2,y-2,x+textwidth(S)+1,y+textheight(s)+1);
          Line(x+textwidth(S)+2,y-1,x+textwidth(S)+2,y+textheight(s)+2);
          Line(x-1,y+textheight(s)+2,x+textwidth(S)+2,y+textheight(s)+2);
          Outtextxy(x,y,S);
     End;
     False :
     begin
          Putimage(X-2,y-2,P^,Normalput);
          Freemem(P,size);
     end;
    end;
end;

PROCEDURE StatusBar;
Var
   per : Longint;
   perc : string;
   done : boolean;

   procedure inits;
   begin
        setfillstyle(solidfill,15);
        bar(x+4,y+4,x+303,y+28);
        done := true;
   end;
BEGIN
     if not done then inits;
     per := round(snum  / enum * 100);
     setfillstyle(solidfill,white);
     bar(x+per*3+3,y+3,x+303,y+27);
     setfillstyle(solidfill,LightBlue);
     bar(x+3,y+3,x+3 + per * 3 ,y+27);
     str(per,perc);
     Settextstyle(font8x8,0,0);
     If Per > 20 then
     BEgin
          Setcolor(White);
          Outtextxy(x + round(Per*1.4) ,y + 12,perc);
          Outtextxy(x + round(per*1.4+20),y+ 12,' %');
     End;
END;

END.

