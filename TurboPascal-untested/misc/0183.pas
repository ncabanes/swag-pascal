{
Err.. RACER programmed by Scott Tunstall 1994.
(When I first got me PC at the age of 22)

Update in March 95 (Also by Scott Tunstall) - to piss off the
B.Sc chaps. And what's more folks it's already on BBS's so
ripping off me code will mean I sue you for (C).

Renamed to The Dave Norrie Driving Simulator just to piss the c**t
right off!! :) sorry Dave mate but this is easily the best game
you'll play on your PC cos :

       (A) I programmed it
       (B) Your f***ing name is on it. :) :) :)

Even SHITTER than the lawnmower simulator.. it's me racing game
which has absolutely NO collision detection whatever. I done this
just for a laugh see?

And to practise assembler. Compared to me efforts now the assembler
code in this really SUCKS!! (But why should I optimize a piece of
shit like this? :) )

(And no commenting either.. tut tut)

Oh by the way Ronny seeing as you don't believe I wrote space lords
I thought I'd update me copy just for you... EAT YOUR WORDS
}

Program Norrie_Simulator;

Uses Crt;

Var CarX: byte;
    CarY: byte;
    OldCarX : byte;
    OldCarY : byte;
    Speed: byte;
    CaveY: byte;
    CaveHeight: byte;
    Dead: boolean;






{
OH NO! I AM SO EMBARASSED BY THIS CODE IT IS SHIT!!
}


Procedure ScrollLeft; Assembler;
label outer,shift;

asm
     push ds
     mov ax,$b800               { Want me to explain this eh? }
     mov ds,ax

     mov bx,0
     mov dl,22

outer:
      mov cx,38                 { Woulda been better with CL }
      push bx                   { ain't altered it to show you
                                  how shit it is - if you understand asm }

shift:
      mov ax,[bx+2]
      mov [bx],ax
      add bx,2
      loop shift                { Err... don't tell anyone I wrote this OK }

      pop bx
      add bx,80

      dec dl
      jne outer

      pop ds
End;







Procedure WriteNewTrack;
var y:byte;
Begin
     If CaveY <> 1 Then
        Begin
        TextBackground(Green);
        For Y:=1 to CaveY do
        Begin
            GotoXY(39,Y);
            Write(' ');
        End;
     End;

     gotoxy(39,CaveY);
     TextColor(White);
     Write('O');

     gotoxy(39,CaveY+CaveHeight);
     Write('O');

     TextBackground(LightGray);
     For Y:=CaveY + 1 to (CaveY + (CaveHeight-1)) do
     begin
          gotoXY(39,Y);
          Write(' ');
     End;

     TextBackground(Green);
     For Y:= (CaveY + CaveHeight + 1) to 22 do
     begin
          gotoxy(39,Y);
          write(' ');
     end;
end;






Procedure DrawScreen;
Var Action:byte;
Begin
     GotoXY(OldCarX,OldCarY);
     TextBackground(LightGray);
     Write(' ');

     ScrollLeft;
     WriteNewTrack;


     Action:= Random(30);
     Case Action Of
          1: If CaveY > 1 Then Dec(CaveY);
          2: If (CaveY + CaveHeight)< 22 Then Inc(CaveY);
          3: If CaveHeight > 6 Then Dec(CaveHeight);
          4: If (CaveY + CaveHeight)< 22 Then Inc(CaveHeight);
     End;

End;





Procedure Setup;
Var X:byte;
Begin
     TextMode(CO40);
     CaveY:=5;
     CaveHeight:=15;
     CarX:=1;
     CarY:=12;
     OldCarX:=CarX;
     OldCarY:=CarY;

     Speed:=100;

{ I added this bit to piss Dave off }

     gotoxy(4,24);
     textcolor(WHITE);
     textbackground(black);
     write('The Dave Norrie Driving Simulator');

{ This bit was in the original }

     For X:=1 to 38 do
         DrawScreen;



End;







Procedure MovePlayer;
Begin
     TextColor(LightGray);
     TextBackground(Blue);
     GotoXY(CarX,CarY);
     Write('>');

     OldCarX:=CarX;
     OldCarY:=CarY;

     If KeyPressed Then
        Begin
        Case Upcase(Readkey) of
             'Q': If CarY>1 Then Dec(CarY);
             'A': If CarY<22 Then Inc(CarY);
             'O': If CarX>1 Then
                     Begin
                     Speed:=Speed+5;
                     Dec(CarX);
                     End;
             'P': If CarX<20 Then
                     Begin
                     Speed:=Speed-5;
                     Inc(CarX);
                     End;
        End;
     End;
End;







Begin
SetUp;
Repeat
     Delay(Speed);
     DrawScreen;
     MovePlayer;
Until Dead;
End.



{    Here's a few possible additions for you sad fucks who
     actually like this trash:

     1. Collision detection (Not too good though - ruins the fun!)
     2. Graphics ! (No then again maybe not)
     3. Some sound (Keep it crap)
     4. Err.. playability?
}