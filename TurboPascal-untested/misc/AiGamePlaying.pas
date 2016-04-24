(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0160.PAS
  Description: AI Game Playing
  Author: BRAD ZAVITSKY
  Date: 09-04-95  10:57
*)

{$IFDEF DEBUG}
{$A+,B-,D+,F-,G-,I-,K-,L-,N-,E-,P-,Q+,R+,S+,T-,V-,W+,X+,Y-}
{$ELSE}
{$A+,B-,D-,F-,G-,I-,K-,L-,N-,E-,P-,Q-,R-,S-,T-,V-,W+,X+,Y-}
{$ENDIf}

{************************************************}
{                                                }
{   SNAiL ViSiON Demo  v1.00.00                  }
{   Strange Logic Software <=> Brad Zavitsky     }
{   All Rights Reserved (1995)                   }
{                                                }
{************************************************}

{
 | NOTES:
 \-------

  There are no known bugs.

  Some people have been wondering about computer games so-called AI,
  this is a demo of PAI (Psuedo Artificial Inteligence <g>)

  Sorry, no graphics :-), this is just ascii.

  I have made most of the games settings constants for changing various
  things around.

  If compiling in G+ mode, change COMPSPEED accordingly the enemies
  go MUCH faster.

  This will even work on a 8088 in REAL TIME! It has been pretty optimized
  for speed and size, notice, it does not use any units, cut back in a
  ton of linking.

  SWAG use it allowed (that is really the goal)

VERSIONS --
   1.00.00 : First public release. Since I first posted this in the
             PASCAL LESSONS confrence I have made MANY changes to make
             it more of a game/run faster/ and have more configurable
             settings.  Est.. *OPERATING Speed is 200%-500% faster.

  * I do have a delay which slows things down to regulate speeds.

}

Program Snaildemo;
{$M $400,0,0}


Const
 Top       = 3;  {Specs of your screen -2/+2}
 Bottom    = 22; {""}
 RtSide    = 77; {""}
 LftSide   = 3;  {""}

 Version        : string[7] = '1.00.00';
 CompSpeed      : word = 6; {Higher = easier|Even = Easier}
 MaxEnemy              = 68;  {Should greater or equal to NumEnemy}
 NumEnemy       : word = 30;  {Number of enemies}
 AI             : Byte = 60; {random move chance}
 Rep            : Byte = 3;  {Energy replenish}
 JumpChance     : Byte = 90; {chance to make a jump}
 BadScore       : Integer = -5;  {Happens when a jump is failed}
 BadEnergy      : Integer = -75; {Happens after a jump is failed}
 MaxEnergy      : Word = 5000; {Max amount of energy}
 MaxScore       : Word = 65500;
 Drain          : Word = 2;    {Amount drained per keypress}
 StartingEnergy : Word = 200;  {Amount of starting energy}
 Scost          : Word = 2; {Shield Usage Cost, if half}
                            {then energy wont go down unless moving}
 SNeed          : Word = 10; {Energy needed mantain shields}
 StatUpDate     : Byte = 5; {When to update stats}
 ENeed          : Word = 2; {Energy needed to move}
 JNeed          : Word = 100; {Energy needed for hyper jump}
 SnailMan   : Char = '@'; {Our hero}
 Langolier  : Char = '#'; {Bad Guys}
 SoundOn    : Boolean = True; {Turn this off if you don't like noise}

Type
     {Directions used by MOVE}
     Dirtype = (North, East, West, South);

     {These are actually player/enemy records, you could probally
     add such things as hitpoints pretty easily}
     CursorRec = Record
                 X,Y:Byte;
                 End;

    { All the possible enemies, I have personally gone up
      to 1000 w/out changing memory! }
     AllEnemy = array[1..MaxEnemy] of CursorRec;


Var
    Dead   : Boolean; {Gee...what could this mean}
    Round, {Used to regulate stats updates}
    Turn   : Byte; {This regulates enemy movement}
    Temp   : AllEnemy; {BadGuy location, just what snailman needs to avoid}
    Loc    : CursorRec; {Snailmans Location}
    I      : Integer; {All purpose integer}
    Len    : Byte; {Stores length of previous string for status line}
    Score, { player score}
    Energy : integer; {players current energy}
    OneMs  : Word; {Used by delays, DO NOT TOUCH <g>}
    Ch     : Char; {IO char}
    ShieldOn : Boolean; {True if shields are on}
    PlayAnother : Boolean; {Play another game?}


Procedure CB;Inline($CD/$33); {Simulate a ^C}

Procedure DelayOneMS; assembler; {Better delay for 1ms}
  asm
     PUSH CX         { Save CX }
     MOV  CX, OneMS  { Loop count into CX }
  @1:
     LOOP @1         { Wait one millisecond }
     POP  CX         { Restore CX }
  end;

Procedure Delay(ms:Word); assembler; {better delay}
  asm
     MOV  CX, ms
     JCXZ @2
  @1:
     CALL DelayOneMS
     LOOP @1
  @2:
  end;

Procedure Calibrate_Delay; assembler; {makes delay accurate}
  asm
     MOV  AX,40h
     MOV  ES,AX
     MOV  DI,6Ch          { ES:DI is the low word of BIOS timer count }
     MOV  OneMS,55        { Initial value for One MS's time }
     XOR  DX,DX           { DX = 0 }
     MOV  AX,ES:[DI]      { AX = low word of timer }
  @1:
     CMP  AX,ES:[DI]      { Keep looking at low word of timer }
     JE   @1              { until its value changes... }
     MOV  AX,ES:[DI]      { ...then save it }
  @2:
     CAll DelayOneMs      { Delay for a count of OneMS (55) }
     INC  DX              { Increment loop counter }
     CMP  AX,ES:[DI]      { Keep looping until the low word }
     JE   @2              { of the timer count changes again }
     MOV  OneMS, DX       { DX has new OneMS }
  end;

Procedure Beep(Hz, MS:Word); assembler;
     { Make the Sound at Frequency Hz for MS milliseconds }
  ASM
    MOV  BX,Hz
    MOV  AX,34DDH
    MOV  DX,0012H
    CMP  DX,BX
    JNC  @Stop
    DIV  BX
    MOV  BX,AX
    IN          AL,61H
    TEST AL,3
    JNZ  @99
    OR          AL,3
    OUT  61H,AL
    MOV  AL,0B6H
    OUT  43H,AL
 @99:
    MOV  AL,BL
    OUT  42H,AL
    MOV  AL,BH
    OUT  42H,AL
 @Stop:
 {$IFOPT G+}
    PUSH MS
 {$ELSE }
    MOV  AX, MS   { push delay time }
    PUSH AX
  {$ENDIF }
    CALL Delay    { and wait... }

    IN   AL, $61  { Now turn off the speaker }
    AND  AL, $FC
    OUT  $61, AL
  end;

Procedure BoundsBeep; assembler; {Means you are touching an enemy}
  asm
  {$IFOPT G+ }
     PUSH 1234      { Pass the Frequency }
     PUSH 10        { Pass the delay time }
  {$ELSE}
     MOV  AX, 1234  { Pass the Frequency }
     PUSH AX
     MOV  AX, 10    { Pass the delay time }
     PUSH AX
   {$ENDIF }
     CALL Beep
  end;

Procedure ErrorBeep; assembler;{Means you have touched an enemy and died}
  asm
  {$IFOPT G+ }
     PUSH 800   { Pass the Frequency }
     PUSH 75    { Pass the delay time }
  {$ELSE}
     MOV  AX, 800  { Pass the Frequency }
     PUSH AX
     MOV  AX, 75   { Pass the delay time }
     PUSH AX
  {$ENDIF }
     CALL Beep
  end;

Procedure AttentionBeep; assembler; {Status Update beep}
  asm
  {$IFOPT G+ }
     PUSH 660   { Pass the Frequency }
     PUSH 50    { Pass the delay time }
  {$ELSE}
     MOV  AX, 660  { Pass the Frequency }
     PUSH AX
     MOV  AX, 50   { Pass the delay time }
     PUSH AX
  {$ENDIF }
     CALL Beep
  end;



Procedure WarpSound; {Attemped warp sound}
 Var I:Word;
  Begin
    For I:= 500 to 600 do Beep(I,10);
  End;

Procedure WarpDown; {Completed warp sound}
 Var I:Word;
  Begin
    For I:= 600 downto 500 do Beep(I,10);
    Delay(200);
    Beep(1000,10);
    Delay(200);
    Beep(1000,10);
  End;


Procedure FClr;Assembler; {ClrScr}
  Asm
   MOV AH,0Fh
   Int 10h
   MOV AH,0
   Int 10h
  End;

Procedure GotoXY(X,Y : Byte); Assembler;
Asm
  MOV DH, Y    { DH = Row (Y) }
  MOV DL, X    { DL = Column (X) }
  DEC DH       { Adjust For Zero-based Bios routines }
  DEC DL       { Turbo Crt.GotoXY is 1-based }
  MOV BH,0     { Display page 0 }
  MOV AH,2     { Call For SET CURSOR POSITION }
  INT 10h
end;

Function Int2Str(Number : LongInt): String;
Var
Temp : String[64];
Begin
   Str(Number,Temp);
   Int2Str := Temp;
End;

Procedure SetXY(x,y:byte;var A:CursorRec);
 Begin
  If (X > 0) and (X < 80) then A.x := x;
  If (Y > 0) and (Y < 25) then A.y := y;
 End;

Procedure ClearKeyBoard;{Fast key clearer}
Begin
 ASM CLI End;
 MemW[$40:$1A] := MemW[$40:$1C];
 ASM STI End;
End;

Procedure GoXY(A:CursorRec); {moves cursorrec to its position}
 Begin
  Gotoxy(a.x,a.y);
 End;

Procedure HideCursor; Assembler;
Asm
  MOV   ax,$0100
  MOV   cx,$2607
  INT   $10
end;

Procedure ShowCursor; Assembler;
Asm
  MOV   ax,$0100
  MOV   cx,$0506
  INT   $10
end;

Function WhereX : Byte;  Assembler;
Asm
  MOV     AH,3      {Ask For current cursor position}
  MOV     BH,0      { On page 0 }
  INT     10h       { Return inFormation in DX }
  INC     DL        { Bios Assumes Zero-based. Crt.WhereX Uses 1 based }
  MOV     AL, DL    { Return X position in AL For use in Byte Result }
end;

Function WhereY : Byte; Assembler;
Asm
  MOV     AH,3     {Ask For current cursor position}
  MOV     BH,0     { On page 0 }
  INT     10h      { Return inFormation in DX }
  INC     DH       { Bios Assumes Zero-based. Crt.WhereY Uses 1 based }
  MOV     AL, DH   { Return Y position in AL For use in Byte Result }
end;

Procedure GETXY(A:CursorRec); {set cursorrec}
 Begin
  A.x := WhereX;
  A.y := WhereY;
 End;

Procedure StatusBeep; {Look up, status line has been updated}
 Begin
  AttentionBeep;
  Delay(50);
  AttentionBeep;
 End;


Function Readkey:char;Inline($B4/$07/$CD/$21);

function KeyPressed:boolean;assembler;
 asm
 mov ah,$B;
 int $21;
 and al,$FE;
end;

Procedure ClrBox(X1,Y1,X2,Y2:Byte);
 Var
   OldX :Byte; AnyBt:Byte;
   OldY :Byte; AnyBt2:Byte;

 Begin
  OldX := WhereX;
  OldY := WhereY;
  gotoxy(x1,y1);
  For Anybt :=1 to Y2 do begin
   For AnyBt2 :=1 to X2 do write(#0);
   gotoxy(X1,Y1+AnyBt);
  End{For Loop};
  gotoxy(oldX,OldY);
  End;

Procedure Status(S:String;Clear:Boolean;UseSound:Boolean);
{Gives messages on first line}
 Begin
 If (Clear) and (SoundOn) and (UseSound) then StatusBeep;
 Gotoxy(1,1);
 If Clear then ClrBox(1,1,Len,1) else gotoxy(len,1);
 Write(S);
 If Clear then Len:= Length(S) else Len:= Len + Length(S)+1;
 inc(len);
 Goxy(Loc);
 End;

Function P100(Percent:Word):Boolean;  {Percentage 100}
  Begin
   P100 := False;
   If Random(100)+1 <= Percent then P100 := True;
  End;

Procedure StatInit; {Set up status bar |not status line|}
Begin
gotoxy(1,2);
Write('[ STATUS ]   ENERGY:            SHIELDS:            SCORE:');
End;

{The following procedure update the status bar}

Procedure UpDateEnergy;
 Var i:Byte;
 Begin
 Gotoxy(21,2);
 For I:=1 to 5 do write(#32);
 Gotoxy(21,2);
 Write(Energy);
 Goxy(Loc);
 End;

Procedure UpDateShields;
 Var i:Byte;
 Begin
 StatusBeep;
 Gotoxy(41,2);
 For I:=1 to 5 do write(#32);
 Gotoxy(41,2);
 Write(ShieldOn);
 Goxy(Loc);
 End;

Procedure UpDateScore;
 Var i:Byte;
 Begin
 Gotoxy(59,2);
 For I:=1 to Length(int2str(Energy))+2 do write(#32);
 gotoxy(59,2);
 Write(Score);
 Goxy(Loc);
 End;

Procedure EngageShields; {Change shield status}
Begin
 ShieldOn := not ShieldOn;
 UpDateShields;
End;

procedure Firephasers(A:CursorRec); {Check for collisions}
     begin
       If (A.x = Loc.x) and (A.Y = Loc.Y) then
       begin
        BoundsBeep;
        GoXy(A);
        Write(Langolier);
        If not shieldOn then
        begin
         If SoundOn then ErrorBeep;
         Dead := True;
        End;{ShieldOn}
      end;{If Locs match}
     End;{Fire}

Procedure CheckHits;  {Check for collisions}
 Var I:word;
  Begin
   While not dead and (I <> NumEnemy) do
    For I:= 1 to NumEnemy do Firephasers(Temp[I]);
  End;

Function Move(Dir:DirType;Var A:CursorRec;Ch:Char):Boolean;
{Move player/enemies}
 Begin
 Move := True;
 Case Dir of
  North: Begin
           If A.Y <= top then Move := False else
           begin
            goxy(A);
            Write(#0);
            Dec(A.Y);
            GoXY(A);
            Write(Ch);
           End;{If wherey}
           End;{K_Up}

  South: Begin
         If A.Y >= bottom then Move := False else
          begin
          goxy(A);
          Write(#0);
          Inc(A.Y);
          GoXY(A);
          Write(ch);
          End;{If wherey}
          End;{K_Down}

  East: Begin
           If A.X >= rtside then Move := False else
           begin
            goxy(A);
            Write(#0);
            Inc(A.X);
            GoXY(A);
            Write(Ch);
            End;{If wherex}
            End;{K_Right}

  West: Begin
         If A.X <= lftside then Move := False else
          begin
          goxy(A);
          write(#0);
          Dec(A.X);
          GoXY(A);
          Write(Ch);
          End;{If wherex}
          End;{K_Left}

 End;{Case}
 CheckHits;
 End;{Move}

Procedure Jump; {Hyper Jump}
 Begin
  Status('Attempting Jump...',True,False);
  If SoundOn then WarpSound;
  If Energy >= Jneed then
  begin
  If P100(JumpChance) then {If you don't fail...}
  begin
   Goxy(Loc);
   Write(#0);
   SetXy((random(rtside-lftside)+lftside+1),(random(bottom-top)+top+1)
   ,Loc);
   goxy(Loc);
   Write(snailman);
   Dec(Energy, Jneed); {Get rid of used energy}
   Status('successfull',false,True);
   If SoundOn then WarpDown; {make some noise}
  End Else
   Begin
   Delay(200);    {Failed Warp Noise}
   Beep(1500,20);
   Delay(200);
   Beep(1500,20);
   Delay(200);
   Beep(1500,20);
   Delay(200);
   Beep(1500,20);
   Status('Failed',False,True);
   Energy := BadEnergy; {Pay the price of a blown engine}
   Score := BadScore;   {""}
   End;
  End else Begin
    status('not enough energy!',false,True);
    Delay(200);
    Beep(1000,10);
   End;
 End;

procedure Movefoes; {The enemy is on the move}
     Var I:Word;
     begin
     Turn := 0; {reset turns}
     For I:=1 to numenemy do
     Begin

     If Temp[I].X > Loc.X then Move(West,Temp[I],langolier) else
     If Temp[I].X < Loc.X then Move(East,Temp[I],langolier);

     If Temp[I].Y > Loc.Y then Move(North,Temp[I],langolier) else
     If Temp[I].Y < Loc.Y then Move(South,Temp[I],langolier);


     If P100(AI) then {do they move on their own?}
     begin
      case (random(4)+1) of
       1: Move(North,Temp[I],langolier);
       2: Move(South,Temp[I],langolier);
       3: Move(West,Temp[I],langolier);
       4: Move(East,Temp[I],langolier);
       End;{Case}
      End;{Begin}
     end;{for to do}
     {EnemySave;}
     end;

procedure Addscore; {regulates energy use, this could use some work}
 begin
   if (energy < MaxEnergy) and (odd(turn)) then inc(energy,rep);
   if (score < MaxScore) and (turn = compspeed-1) then inc(score);
  end;


procedure Playgame; {Let the games begin}
     Var i:Word;
     begin
     For I:=1 to numenemy do {set up starting positions}
     begin
     SetXy((random(rtside-lftside)+lftside+1),(random(bottom-top)+top+1)
           ,Temp[I]);
     goxy(Temp[I]);
     Write(langolier);
     end;

     SetXy(3,5,Loc);
     goxy(loc);
     Write(snailman);
     repeat {begin}
        While keypressed do {MUCH faster than "If Keyressed"}
           Begin
            Ch := readkey;
            If (CH = #0) and (ENergy > ENeed) then
          {a function key means they are moving}
            BEGIN
            Dec(Energy, Drain);
            Ch := Readkey;
            Case CH of
   { left }   #75 : Move(West,Loc,snailman);
   { rite }   #77 : Move(East,Loc,snailman);
   {  Up  }   #72 : Move(North, Loc, snailman);
   { Down }   #80 : Move(South, Loc,snailman);
   { PGup }   #73 : Begin
                     Move(North, Loc, snailman);
                     Move(East,Loc,snailman);
                    End;

   { PDdn }   #81 : Begin
                     Move(South, Loc,snailman);
                     Move(East,Loc,snailman);
                    End;

   { Home }   #71 : Begin
                     Move(North, Loc, snailman);
                     Move(West,Loc,snailman);
                    End;

   { End  }   #79 : Begin
                     Move(South, Loc, snailman);
                     Move(West,Loc,snailman);
                    End;

            End;{Case}
            END ELSE
            Case Ch of
           'Q','q' : Dead := True;{Quit}
           'J','j' : Jump;  {Jump}
           'S','s' : EngageShields;{Engage/disEngage shields}
           'P','p' : Begin
                     Inc(Energy, Drain); {Reimburse energy}
                     Status('Paused... press <ENTER>',true,True);
                     repeat until readkey = #13;
                     Status('',True,True);
                     End;

               #3 :  CB;  {^C}
           End;{case}
           End;{While}

          If (Energy < SNeed) and (ShieldOn) then
           Begin
            ShieldOn := False;
            UpDateShields;
           End;

          If ShieldOn then Dec(Energy, SCost);
          ClearKeyBoard;

          If Round = StatUpDate then
           Begin
            GoXy(Loc);
            Write(SnailMan);
            UpDateEnergy;
            UpDateScore;
            Round := 0;
           End;
          inc(Round);

          If turn >= compspeed then movefoes;
          inc(turn);

          addscore;
          Delay(100);
          {end} until dead;
     end;

Procedure SayHi; {Internal Instructions}
Begin
Writeln('Welcome to SNAiL ViSiON -- The virtual snail network -- ');
Writeln('and only on channel 3031.  Tonight we bring you, once again,');
Writeln('SNAiL MAN!  Can the not-so-brave-and-not-too-tough SNAiLMAN');
Writeln('save the day?  Well, as you know, with ViRTUAL SNAiL REALiTY');
Writeln('you will decide.  And just how do you win you ask?  Well the');
Writeln('snail isn''t known for it''s ninja-like karate skills, so');
Writeln('you just have to run as only a snail can.');
Writeln('');
Writeln('Advice --');
Writeln(' When you here two beeps, look up, it means something has');
Writeln(' just been updated.  Also, be carefull when using');
Writeln(' HyperJump,if you fail you loose energy and points');
Writeln('');
Writeln('Instructions --');
Writeln(' Arrow keys move you in corresponding directions.');
Writeln(' PgUp, PgDn, Home, and End move diagonaly.');
Writeln(' P - Pause   Q - Commit Sucicide   S - Engage Snail Shields');
Writeln(' J - Snail HyperJump!');
Writeln('');
Writeln('Symbols --');
Writeln(' ',SnailMan,' - Snailman   ',Langolier,' - Langolier');
Writeln('');
Write('<Press Enter> [ ]'#8#8);
Repeat until readkey = #13;
Fclr;
End;

begin {main program}
(***********************************************************************)
 Calibrate_Delay;
 Delay(0);
 PlayAnother := True;

Repeat
 randomize;
 NumEnemy := Random(16)+15;
 Dead := False;
 Score := 0;
 Turn := 0;
 Fclr;
 SayHi;
 HideCursor;
 ClearKeyBoard;
 Energy := StartingEnergy;
 ShieldOn := False;
 StatInit;
 UpDateShields;
(***********************************************************************)

 Status('Welcome to SNAiL ViSiON v'+version+' ...',True,False);

 Playgame;


(***********************************************************************)
 ShowCursor;
 FCLR; {Not only clears the screen, but resets some things as well}
 Writeln('Score: ',Score);
 Write('Play again? (Y/n)');
 Repeat
 Ch := UpCase(Readkey);
 Until (Ch = 'Y') or (CH = 'N');
 If Ch = 'N' then playanother := False;
 Until not PlayAnother;
 Fclr;
(***********************************************************************)
end.

:::
