
uses crt, dos;  {$R-}
(****************************************************************************)
(*           TPONG-1.PAS        Glenn A. Reiff    74035,400     4/5/85      *)
(*                                                                          *)
(*  Note:  While this program is usable and will provide some fun, the      *)
(*         Paddle control is not as responsive as it is in the original     *)
(*         Basic program.  Also, the side bounces could be better.  If      *)
(*         you are able to make any improvements I'd appreciate knowing     *)
(*         about them.                                                      *)
(****************************************************************************)
type Str80 = string[80];
procedure CENTER(Y:integer; Bt:Str80);
BEGIN gotoXY((80-Length(Bt)) div 2, Y); write(Bt) END;

procedure INTRODUCTION;
BEGIN
     clrscr;                    CENTER(5,'TURBO PONG');
     CENTER(8,'This is an adaption to Turbo Pascal of the Basic program  ');
     CENTER(9,'called PChallenge written by Karl Koessel and published in');
     CENTER(10,'a 1982 issue of PC Magazine.                              ');
     CENTER(12,'His was a simplification of Pong, the orignial video game.');
     CENTER(13,'Pong was developed in the early 1970''s by Nolan Bushnell. ');
     CENTER(20,'Tap a Key to Continue');
     writeln; gotoXY(80,25);
     repeat until keypressed;
END; { INTRODUCTION }


type       CharSet = set of Char;
           Str9    = string[9];

var        Paddle  : Str9;
           StartTime,
           EndTime,
           CurTime,
           BestTime,
           Drag : integer;
           Ch: char;


Procedure TEXTBORDER (color: integer);
  var regs: registers;
BEGIN
  With regs do begin
    AH := 11; BH := 0; BL := color end;
  Intr($10,regs)
END; { TEXTBORDER }

Procedure BEEP(N : Integer);
BEGIN   Sound(n);  Delay(100);  NoSound; END;

function GET_TIME: integer;
var regs: registers;
BEGIN
  with regs do begin
    ax := $2C * 256;
    MsDos(regs);
    GET_TIME := 3600 * ch + 60 * cl + dh
  end
END;  { GET_TIME }

procedure CHOOSE(    X,Y    : integer;
                     Prompt : Str80;
                     Term   : CharSet;
                 var TC     : Char    );
var   I  : integer;
      Ch : char;
BEGIN
  lowvideo; gotoXY(X,Y);
  for I:=1 to length(Prompt) do begin
      Ch:=Prompt[I];
      if I>4 then begin
        lowvideo;
        if (Prompt[I-2]=' ') and (Prompt[I-1]=' ') then highvideo;
        if (Prompt[I-1]='<') or  (Prompt[I-1]='/') then highvideo;
      end; { if I>3 }
      write(Ch)
  end; { for I }
  repeat
    TC := Upcase(ReadKey);
    if not (TC in Term) then BEEP(1000)
  until TC in Term
END; { CHOOSE }

procedure RESET(var Drag: integer;  var Paddle: Str9);
BEGIN
     TEXTBORDER(Black); textbackground(Black); clrscr;
     CENTER(10,'Left and right cursor keys move paddle.');
     textcolor(LightCyan);
     CENTER(12,'Input drag factor: (100 is Medium...0 is FAST!)  ');
read(Drag);     CHOOSE(17,14,'Pick a paddle size:  Small,  Medium or
Large',['S','M','L'],Ch);     if Ch = 'S' then Paddle := ' '+chr(27)+'
'+chr(26)+' '       else if Ch = 'M' then Paddle := ' '+chr(27)+'
'+chr(26)+' '          else if Ch = 'L' then Paddle := ' '+chr(27)+'
'+chr(26)+' 'END; { RESET }

procedure RUN;
label NewBall;
var   Used                                 :   array[1..10] of integer;
var   X,dX,Xpad,Y,dY,B,C,I,J,BallNr,Xstart :   integer;
      Flag                                 :   boolean;

  procedure RANDOMIZE;
  BEGIN
    dx := random(7)- integer (random(7));
    if dX < 0  then
      repeat
        dX := random(7) - integer (random(7));
        if dX=0 then dX:=-1;
      until (X-6)/dX=trunc((X-6)/dX);
    if dX > 0  then
      repeat
        dX := random(7) - integer (random(7));
        if dX=0 then dX:=1;
      until (59-X)/dX=trunc((59-X)/dX)
  END; { RANDOMIZE }

  procedure POSITION_PADDLE;
  BEGIN
    gotoXY(Xpad,22); textbackground(LightGray);
    textcolor(DarkGray); write(Paddle); textbackground(C);
  END; { POSITION_PADDLE }

  procedure ONKEY;
  BEGIN
    Ch := ReadKey;
    if Ch = #27 then  { it must be a function key }
      Ch := ReadKey;
    case Ch of
      'K':   if Xpad > 7 then begin
        Xpad:=Xpad-3; POSITION_PADDLE;
        gotoXY(Xpad+length(Paddle),22); write('   '); end;
      'M':   if Xpad + length(Paddle) < 60 then begin
        Xpad:=Xpad+2; POSITION_PADDLE;
        gotoXY(Xpad-3,22); write('   '); end;
    end;   { case }
  END; { ONKEY }


BEGIN
     J := 11; Xpad := 29; C := random(16);
     if c in [0, 1, 6..9, 12, 15] then C := 2;
     textbackground(C); clrscr; TEXTBORDER(C);

     for X:=8 to 17 do begin   { Setup  10 Balls }
         J := J + 4; textbackground(red); textcolor(white);
         gotoXY(J,2); write(#2); textbackground(C);
     end; { for X }
     textcolor(Blue);
     GotoXY (5, 3);
     for X:=5 to 59 do write(#219);  { Draw Backboard }
     for Y:=3 to 21 do begin         { Draw Walls  }
        gotoXY  (5,Y); write (#219#219);
        gotoXY (59,Y); write (#219#219);
     end;
     POSITION_PADDLE; textcolor(Black);
     gotoXY(5,24); write('Best Time so far is ',BestTime,' seconds.');
     gotoXY(66,3); write('TURBOPONG');
     gotoXY(63,6); write('Initial Drag ',Drag);
     FillChar (Used, 20, 0);
     BallNr := 10;
     StartTime := GET_TIME;

     while BallNr > 0 do begin
       repeat
         Xstart := 1 + random(10); Flag:=false;
         for I:=1 to 10 do if Used[I] = Xstart then Flag:=true;
       until not Flag;
       Used[BallNr]:=Xstart;
       Xstart := 11 + 4 * Xstart;
       gotoXY(Xstart,2); write(' ');
       X := Xstart; Y := 4; dY := 1; Flag := false;
       RANDOMIZE;
       while Y < 23 do begin
         if keypressed then ONKEY;
         textbackground(C);
         if (Y > 4)  and (X in [7..58]) then     { Erase Previous Ball Below }
           begin gotoXY(X,Y-1); write(' '); end;
         if (Y < 21) and (X in [7..58]) then
           begin gotoXY(X,Y+1); write(' '); end; { Erase Previous Ball Above }
         if (Y=21) and (X-Xpad in [0..length (Paddle)]) then
           begin gotoXY(X,Y); write(' '); end;   { Erase Ball On Paddle      }

         X:=X + dX;

         textbackground(red); textcolor(white);
         if X in [7..58] then begin
           gotoXY(X,Y); write(#1)         { Print New Ball Position }
         end;
         gotoXY(80,25);
         if not (x in [8..57]) then begin
           BEEP(300+random(80*BallNr)); dX:=-dX;
         end;    { Side Wall Bounce        }
         if keypressed then ONKEY;

         if (Y=21) and (X-Xpad in [0..length(Paddle)]) then begin
           dY := -dY; BEEP(700);      { Bounce Off Of Paddle }
           if dX = 0 then RANDOMIZE;
         end; { if Y=21 }

         if Y = 22 then begin
           textbackground(C); gotoXY(X,Y); write(' ');
           textbackground(red); textcolor(white);      { Park Used Ball }
           gotoXY(25+Xstart,Y+2); write(#1); gotoXY(80,25);
         end;
         if keypressed then ONKEY;

         if (Y = 4) and Flag then begin   { Bounce Off of Top Backboard }
           BEEP(300+random(80*BallNr));
           Drag := Drag - 5;  { Reduce Amout of Drag    }
           if dX = 0 then RANDOMIZE;
           inc (dX); dY := -dY; Y := Y + dY
         end else begin Y := Y + dY; Flag := true end;
         if Drag <0 then Drag := 0;
         delay(50+Drag);
       end; { while Y }
       BallNr := BallNr - 1; textbackground(C);
     end; { while BallNr }
     gotoXY(1,22); clreol;
     textcolor(Black); gotoXY(63,8); if Drag < 0 then Drag := 0;
     write('Final Drag   ',Drag);
     EndTime := GET_TIME;
     CurTime := EndTime - StartTime;
     if CurTime > BestTime then BestTime := CurTime;
     gotoXY  (5,24); write('Best Time so far is ',BestTime,' seconds.');
     gotoXY (63,11); write('This Run ', CurTime, ' sec.');
END; { RUN }

{MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM}
BEGIN
          BestTime := 0; Drag := 0; Paddle := '';
          INTRODUCTION;
          RESET(Drag,Paddle);
          repeat
            RUN;
            CHOOSE(19,22,'    Quit  Reset  Continue   ',['Q','R','C'],Ch);
            if Ch = 'R' then RESET(Drag,Paddle);
          until Ch = 'Q';
          TEXTBORDER(Black); textbackground(Black); clrscr;
END.

