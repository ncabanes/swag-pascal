(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0242.PAS
  Description: Lars Koudal
  Author: CHAMI
  Date: 05-30-97  18:17
*)


{
Hello Gayle Davis...

I would just like to say how pleased i am with the continuing success of
SWAGS..

Below I have included some source of my own. a cd-player, that Iábelieve
is quite nifty, anyways I like it.

I would be very pleased and honored if it was included in SWAGS...

Yours truly,

Lars Koudal


Denmark, 25th of february 1997

A bit of history:
------------------
   I am one of those people who use my cd-rom drive for playing music while I am working,
eventhough at home I have my left shoulder about 5 inches from the volume knop on my
somewhat larger stereo..

   This is a habbit from my good old days where I worked in far less equipped environments.

   Nowadays I have what I need in win95... 

   Back then though, I was never really satisfied with the cd-players out there. So I wrote
my own... I used a lot of routines grabbed from SWAGS.. (Thanks...) I always intended this
to be only for personal use, but as the program grew larger I felt like I perhaps could
earn some bucks selling the damn thing... THAT was in my young and restless days...

   I recently picked up a newer version of swags (haven't done that in more than a year),
and was very thrilled to see how alive this wonderful source of information is..

   Therefore I decided to post the small version of my program... If people want it, I will
ofcourse send the full-scale version as well.. That hasn't been fully written yet, but
the damn thing works...

   This version is called mini... Probaply due to it's small size (compared to the larger one),
but since it is some years ago, I am not quite sure... :-)

   This program uses, as mentioned before, a lot of routines and units from other people. All
grabbed here from swags... Remember! Credit where credit is due!

   When you run this damn thing, it pops up on your dos-screen with a single line...
It shows what song is playing, and how long it has been playing...

  When you press Pgup, it goes one song up. Guess what happens when you press PgDn! :-)

   Press '.' and up comes a list of songs you can pick. Just use up- and down-keys to scroll
and ENTER to make your selection...

The whole thing ends when you press ESC...

   Try to press F1 from inside the player... I had forgotten this little nifty detail until I tried
it out a few minutes ago...

   BTW: If you have a SoundBlaster in your computer, and the routines I use for detecting it
_can_ find it, you can use '+' and '-' to adjust the volume... Pretty nifty...

   I used it a lot from inside Turbo Pascal.. I made it a tool, and just pressed Shift-F5,
and there it was... pretty handy... and a lot faster... Ever used QCD (comes with SndB)??
Goddamn slow!

(If you can't figure out how to make a new tool in TP, don't bother... put the keyboard down!)


Well, so much about the past, a bit about the future..:
--------------------------------------------------------
  As I have written, this code is from my novice years. If you for some reason want to contact me,
don't do so if you just want to complain about the lousy code, the many unused variables and the many
work-arounds I did for making the whole thing work. I provide this code to
help novices people out, as I was helped myself some years ago...

If you DO decide to contact me, you can e-mail me... (Sorry, left FIDO years ago):

lkoudal@usa.net


Have fun!

Yours truly, 


Lars Koudal.



{Installation notes... Cut and paste the files to their original names, and the compile MINI.PAS... THATS IT!
Play around as much as you like...}

{CUT ... Save this as MINI.PAS }
{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}


                                 PROGRAM mini;


{▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀}

{This program is determined that you start it with a color-screen
 If you don't have that, or you do not know how to change it to a monochrome
 screen, don't bother... put the keyboard down...


 Lars Koudal....

 hint: look about 15 lines down, and read the comment...
}



USES
{  effects,
}  CD_Unit,
  CD_Vars,
  DOS,
  CRT,
  TPTimer,
  TCTimer,
  TPBuffer,
  ScanCode;

TYPE
  TotPlayRec   = RECORD
                   Frames,
                   Seconds,
                   Minutes,
                   Nada     : Byte;
                 END;
CONST
  TextVidSeg   : Word = $b800;
  vga_segment  = $0A000;
  fade_Delay   = 20;
  vSeg         : Word = $B800;  {change for mono}



VAR
 CurrIndex  : Word;
 ScreenLoc  : Pointer;
 ScrollSize : Word;

  vol_time     : longint;
  toslet       : boolean;
  sbfound,
  portok       : Boolean;
  ScrBuf,
  Pdwns        : Word;
  origmode     : word;
  lcv          : Integer;
  temp         : Char;
  a1,
  a2,
  a3           : Byte;
  b1,
  b2,
  b3           : Byte;
  crc          : LongInt;
  cdidstr      : String;

  number       : Byte;
  SaveExit     : Pointer;
  TrackInfo    : ARRAY [1..99] OF PAudioTrackInfo;
  I            : Integer;
  CH           : Char;
  SP,
  EP           : LongInt;
  LeadOut,
  StartP,
  TotalPlayTime: LongInt;
  TotPlay      : TotPlayRec;
  place        : LongInt;
  secs,
  pps,
  s            : LongInt;
  Track        : Byte;
  StartTrack,
  EndTrack,
  NumTracks    : Integer;
  Player       : ARRAY [1..100] OF Byte;
  PlayTime     : TotPlayRec;
  result       : Word;
  resultchar   : Char;
  Hi,
  Hi2          : Byte;
  crstyp       : Word;
  arbejder     : Byte;

  lvolume,
  rvolume      : Byte; {Volume-control}


  Scroll_Lock,
  Caps_Lock,
  Num_Lock,
  Ins,
  Alt,
  Ctrl,
  Left_Shift,
  Right_Shift  : Boolean;
  Bios_Keys    : Byte ABSOLUTE $40:$17;

Procedure WaitForRetrace; Assembler;
Asm
  Mov  DX, 3DAh
  @Rep1:
  In   AL, DX
  Test AL, 08h
  JZ   @Rep1
  @Rep2:
  In   AL, DX
  Test AL, 08h
  JNZ  @Rep2
End;

Function LeadingZero (w : Word) : String;
Var
  s : String;
Begin
  Str (w: 0, s);
  If Length (s) = 1 Then
    s := '0' + s;
  LeadingZero := s;
End;



Function ITOS ( nNum: LongInt; nSpaces: Integer ): String;
Var
   s: ^String;
Begin
  Asm
    mov     sp, BP
    push    ss
    push    Word Ptr @RESULT
  End;
  
  If nSpaces > 0 Then
    Str ( nNum: nSpaces, s^ )
  Else
    Str ( nNum: 0, s^ );
End;

Function returnspace (s: String; wantedspace: Byte): String;
Var
i   : Byte;
temp : String;
Begin
  temp := '';
  For i := Length (s) To wantedspace Do
  Begin
    temp := temp + ' ';
  End;
  returnspace := temp;
End;

{home-made-calculations of which track is currently being played}
Procedure calctrack;
Var
  Min, Sec: Byte;
  i: Byte;
  svar: Boolean;
  {**************}
  Procedure addtime (m, s: Byte);
Begin
  Min := Min + m;
  Sec := Sec + s;
  If Sec = 60 Then
  Begin
    Min := Min + 1;
    Sec := 0;
  End;
  If Sec > 60 Then
  Begin
    Min := Min + 1;
    Sec := Sec - 60;
  End;
End;
{**************}
{**************}
Procedure bigger (m1, s1, m2, s2: Byte; svar: Boolean);
{calculates whether m1:s1 is bigger than m2:s2:}
Begin
  If (m1 * 60 + s1) > (m2 * 60 + s2) Then svar := True
  Else svar := False;
End;
{**************}

Begin
  track := 0;
  Min := 0;
  Sec := 0;
  secs := 0;
  place := Head_Location (1);

  For i := starttrack To endtrack Do
  Begin
    If trackinfo [i]^. startpoint < place Then
    Begin
      track := i;
    End;
    If track = 0 Then track := 1;
  End;
End;


Procedure NoTracks;
Begin
  WriteLn;
  WriteLn ('No tracks on disk');
  WriteLn;
  ExitProc := SaveExit;
End;

Procedure Setup;
Begin
  TotalPlayTime := 0;
  LeadOut := AudioDiskInfo. LeadOutTrack;
  
  StartTrack := AudioDiskInfo. LowestTrack;
  EndTrack := AudioDiskInfo. HighestTrack;
  NumTracks := EndTrack - StartTrack + 1;
  
  
  For I := StartTrack To EndTrack Do
  Begin
    Track := I;
    Audio_Track_Info (StartP, Track);
    New (TrackInfo [I] );
    FillChar (TrackInfo [I]^, SizeOf (TrackInfo [I]^), #0);
    TrackInfo [I]^. StartPoint := StartP;
    TrackInfo [I]^. TrackControl := Track;
  End;

  For I := StartTrack To EndTrack - 1 Do
    TrackInfo [I]^. EndPoint := TrackInfo [I + 1]^. StartPoint - 1;

  TrackInfo [EndTrack]^. EndPoint := AudioDiskInfo. LeadOutTrack - 1;

  For I := StartTrack To EndTrack Do
    Move (TrackInfo [I]^. EndPoint, TrackInfo [I]^. Frames, 4);

  TrackInfo [StartTrack]^. PlayMin := TrackInfo [StartTrack]^. Minutes;
  TrackInfo [StartTrack]^. PlaySec := TrackInfo [StartTrack]^. Seconds - 2;

  For I := StartTrack + 1 To EndTrack Do
  Begin
    EP := (TrackInfo [I]^. Minutes * 60) + TrackInfo [I]^. Seconds;
    SP := (TrackInfo [I - 1]^. Minutes * 60) + TrackInfo [I - 1]^. Seconds;
    EP := EP - SP;
    TrackInfo [I]^. PlayMin := EP Div 60;
    TrackInfo [I]^. PlaySec := EP Mod 60;
  End;

  TotalPlayTime := AudioDiskInfo. LeadOutTrack - TrackInfo [StartTrack]^. StartPoint;
  Move (TotalPlayTime, TotPlay, 4);
End;


Function KeyEnh:  Boolean;
Var
  Enh:  Byte Absolute $0040:$0096;
  
Begin
  KeyEnh := False;
  If (Enh And $10) = $10 Then
    KeyEnh := True;
End;

Function InKey (Var SCAN, ASCII:  Byte): Boolean;
Var
  i     :  Integer;
  Shift,
  Ctrl,
  Alt   : Boolean;
  Temp,
  Flag1 : Byte;
  HEXCH,
  HEXRD,
  HEXFL : Byte;
  reg   : Registers;
  
Begin
  If KeyEnh Then
  Begin
    HEXCH := $11;
    HEXRD := $10;
    HEXFL := $12;
  End
  Else
  Begin
    HEXCH := $01;
    HEXRD := $00;
    HEXFL := $02;
  End;
  
  reg. AH := HEXCH;
  Intr ($16, reg);
  i := reg. Flags And fZero;
  
  reg. AH := HEXFL;
  Intr ($16, reg);
  Flag1 := Reg. AL;
  Temp  := Flag1 And $03;
  
  If Temp = 0 Then
    SHIFT := False
  Else
    SHIFT := True;
  
  Temp  := Flag1 And $04;
  If Temp = 0 Then
    CTRL := False
  Else
    CTRL := True;
  
  Temp  := Flag1 And $08;
  If Temp = 0 Then
    ALT  := False
  Else
    ALT  := True;
  
  If i = 0 Then
  Begin
    reg. AH := HEXRD;
    Intr ($16, reg);
    scan  := reg. AH;
    ascii := reg. AL;
    InKey := True;
  End
  Else
    InKey := False;
End;

{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
FUNCTION UpStr (CONST s: String): String; ASSEMBLER;
  ASM
    push DS
    lds  SI, s
    les  DI, @result
    lodsb            { load and store length of string }
    stosb
    XOR  CH, CH
    mov  CL, AL
    jcxz @empty      { FIX for null length string }
    @upperLoop:
    lodsb
    cmp  AL, 'a'
    jb   @cont
    cmp  AL, 'z'
    ja   @cont
    sub  AL, ' '
    @cont:
    stosb
    loop @UpperLoop
    @empty:
    pop  DS
  END;


procedure vretrace; assembler; { vertical retrace }
asm
  mov dx,3dah
 @vert1:
  in al,dx
  test al,8
  jz @vert1
 @vert2:
  in al,dx
  test al,8
  jnz @vert2
end;

Procedure Setupsc(Col, Row, ScrollSize : Word; Var ScreenLoc : Pointer);
Var Seg1, Ofs1 : Word;
Begin
   {I guess we're assuming an 80 column text mode }
   Ofs1 := (Row-1)*160 + ((Col-1)*2);

   If (Mem[$40:$49] = 7) then Seg1 := $B000
     else Seg1 := $B800;

   ScreenLoc := Ptr(Seg1,Ofs1);
End;



{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
FUNCTION Get_svar: Byte ;
VAR
  CH: Char;
  no_svar: Boolean;

BEGIN
  no_svar := TRUE;
  REPEAT
    CH := UpCase (ReadKey);
    IF CH = NullKey THEN
    BEGIN
      CASE Ord (ReadKey) OF
        dnarrow:
                BEGIN
                  get_svar := dnarrow;
                END;
        uparrow:
                BEGIN
                  get_svar := uparrow;
                END;
        lfarrow:
                BEGIN
                  get_svar := lfarrow;
                END;
        rtarrow:
                BEGIN
                  get_Svar := rtarrow;
                END;
      END;
    END
    ELSE
      CASE CH OF
        EnterKey  :
                   BEGIN
                     get_svar := 100;
                   END;

        EscapeKey :
                   BEGIN
                     get_svar := 27;
                   END;
      END;

  UNTIL no_svar <> FALSE;
END;



Procedure Update;Assembler;
ASM
   CLD
   LES  DI, ScreenLoc
   MOV  CX, ScrollSize

   MOV  SI, CurrIndex
   OR   SI, SI
   JZ   @WriteString

   DEC  CX
@ShiftLeft:
   MOV  AL, ES:[DI+2]
   STOSB
   INC  DI
   LOOP @ShiftLeft

   MOV  AL, CS:[SI]
   OR   AL, AL
   JNZ  @NotEndOfStr
   MOV  SI, Offset @Message
   MOV  AL, CS:[SI]
@NotEndOfStr:
   STOSB

   INC  SI
   JMP  @SaveIndex

@WriteString:
   MOV  SI, Offset @Message
@NextChar:
   MOV  AL, CS:[SI]
   OR   AL, AL
   JZ   @WriteString
   STOSB
   INC  DI
   INC  SI
   LOOP @NextChar

@SaveIndex:
   MOV  CurrIndex, SI
   JMP  @Exit

@Message:
   DB '                                                   '
   DB '                                                   '
   DB   '(\/)ini  HELP!                        '
   DB '           Function keys available:'
   DB   '      PgUP : One track up      ...      PgDN : One track down '
   DB  '     ...      "." : Pick a track using arrow keys      ...      '
   DB 'RightArrow : FastForward      ...      LeftArrow : Rewind      ...     '
   DB 'If you have a Sound Blaster you can use the "+" & "-" keys to control '
   DB 'the volume.....       '
   DB   0                              { terminate it with NULL       }
@Exit:
End;

procedure help;
Var Fedup : Boolean;
time:byte;
c:byte;
emptystr:string;
i:integer;
Begin
   fillchar(emptystr,80,' ');
   emptystr[0]:=#80;
   ScrollSize := 80;
   Setupsc(01,wherey,SCrollSize,ScreenLoc);
   CurrIndex := 0;
   time:=0;
   fedup:=false;
   textcolor(lightgray);
   gotoxy(1,wherey);
   write(emptystr);
   while keypressed do readkey;
   Repeat
     waitforretrace;
     Update;
     if keypressed then
     begin
       c:=get_svar;
       if c=uparrow then inc(time);
       if c=dnarrow then dec(time);
       Fedup := (c = 27);
     end;
   Until (Fedup);
End;


{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
FUNCTION IntToStr (I: LongInt): String;
{Converts any integer type to a string}
VAR
  S: String [11];
BEGIN
  Str (I, S);
  IntToStr := S;
END;


{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
PROCEDURE ShowVolume;
var
i:byte;
BEGIN
    gotoxy(33,wherey);
    TEXTCOLOR (DarkGray);
    FOR i := 1 TO 32 DO
    BEGIN
      WRITE ('■');
    END;

    TEXTCOLOR (Yellow);
    GOTOXY (33, wherey);
    FOR i := 1 TO lvolume DIV 8 DO
    BEGIN
      WRITE ('▐');
    END;
vol_time:=readtimer;
toslet:=true;
END;

{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
PROCEDURE Cursoff;
{ Turns the cursor off.  Stores its format for later redisplaying}
BEGIN
  ASM
    Mov AH, 03H
    Mov BH, 00H
    Int 10H
    Mov Crstyp, CX
    Mov AH, 01H
    Mov CX, 65535
    Int 10H
  END;
END;


{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
PROCEDURE Curson;
{Turns the cursor back on, using the cursor display previously stored}
BEGIN
  ASM
    Mov AH, 01H
    Mov CX, Crstyp
    Int 10H
  END;
END;



{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
PROCEDURE SetColor (Color, Red, Green, Blue : Byte);
{Sets the RGB-values for a given color}
BEGIN
  port [$3C8] := Color;
  port [$3C9] := Red;
  port [$3C9] := Green;
  port [$3C9] := Blue;
END;


{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
PROCEDURE GetColor (Nr: Byte; VAR R, G, B: Byte);
{Retrieves the RGB-values for a given color}
BEGIN
  Port [$3C7] := Nr;
  R := Port [$3C9];
  G := Port [$3C9];
  B := Port [$3C9];
END;



{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
PROCEDURE wait_4_refresh; ASSEMBLER;
{Waits for the monitors vertical retrace}
LABEL
  wait, retr;
ASM
  mov  DX, 3DAh
  wait:  IN   AL, DX
  Test AL, 08h
  jz   wait
  retr:  IN   AL, DX
  Test AL, 08h
  jnz  retr
END;





{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
FUNCTION ISCOLOR : Boolean;
{Returns FALSE for MONO or TRUE for COLOR}
VAR
  regs  : Registers;
  video_mode : Integer;
  equ_lo : Byte;
BEGIN
  Intr ($11, regs);
  video_mode := regs. AL AND $30;
  video_mode := video_mode SHR 4;
  CASE video_mode OF
    1 : ISCOLOR := FALSE; { Monochrome }
    2 : ISCOLOR := TRUE{ Color }
  END
END;



{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
PROCEDURE SAVESCR ( VAR screen );
{Saves the screen in an array of bytes}
VAR
  vidc : Byte ABSOLUTE $B800: 0000;
  vidm : Byte ABSOLUTE $B000: 0000;
BEGIN
  IF NOT ISCOLOR THEN { if MONO }
    Move (vidm, screen, 6000)
  ELSE { else COLOR }
    Move (vidc, screen, 6000)
END;



{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
PROCEDURE RESTORESCR ( VAR screen );
{Restores the screen previous stored in an array of bytes}
VAR
  vidc : Byte ABSOLUTE $B800: 0000;
  vidm : Byte ABSOLUTE $B000: 0000;
BEGIN
  IF NOT ISCOLOR THEN { if MONO }
    Move (screen, vidm, 6000)
  ELSE { else COLOR }
    Move (screen, vidc, 6000)
END;



{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
PROCEDURE working;
{Displays an 'working'-status on the screen}
VAR
  X, Y: Byte;
  c: Byte;
BEGIN
  IF playing THEN
  BEGIN
    X := WhereX;
    Y := WhereY;
    c := TextAttr;

    TextBackground (Blue);
    TextColor (Black);
    GotoXY (70, 3);
    IF arbejder = 1 THEN Write ('');
    IF arbejder = 2 THEN Write ('');
    IF arbejder = 3 THEN Write ('');
    IF arbejder = 4 THEN Write ('');

    IF arbejder < 4 THEN Inc (arbejder)
    ELSE
      arbejder := 1;
    GotoXY (X, Y);
    TextAttr := c;
  END;
END;


{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
PROCEDURE center (s: String; Y: Byte);
{Centers a given string on a given line on the screen}
BEGIN
  GotoXY (40 - (Length (s) DIV 2), Y);
  Write (s);
END;
{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
Function hex(a : Word; b : Byte) : String;
Const digit : Array[$0..$F] Of Char = '0123456789ABCDEF';
Var i : Byte;
  xstring : String;
Begin
  xstring:='';
  For i:=1 To b Do
  Begin
    Insert(digit[a And $000F], xstring, 1);
    a:=a ShR 4
  End;
  hex:=xstring
End; {hex}

{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
Procedure SoundPort;
Var xbyte1, xbyte2, xbyte3, xbyte4: Byte;
  xword, xword1, xword2, temp, sbport: Word;

Begin
  sbfound:=False;
  xbyte1:=1;
  While (xbyte1 < 7) And (Not sbfound) Do
  Begin
    sbport:=$200 + ($10 * xbyte1);
    xword1:=0;
    portok:=False;
    While (xword1 < $201) And (Not portok) Do
    Begin
      If (Port[sbport + $0C] And $80) = 0 Then
        portok:=True;
      Inc(xword1)
    End;
    If portok Then
    Begin
      xbyte3:=Port[sbport + $0C];
      Port[sbport + $0C]:=$D3;
      For xword2:=1 To $1000 Do {nothing};
      xbyte4:=Port[sbport + 6];
      Port[sbport + 6]:=1;
      xbyte2:=Port[sbport + 6];
      xbyte2:=Port[sbport + 6];
      xbyte2:=Port[sbport + 6];
      xbyte2:=Port[sbport + 6];
      Port[sbport + 6]:=0;
      xbyte2:=0;
      Repeat
        xword1:=0;
        portok:=False;
        While (xword1 < $201) And (Not portok) Do
        Begin
          If (Port[sbport + $0E] And $80) = $80 Then
            portok:=True;
          Inc(xword1)
        End;
        If portok Then
          If Port[sbport + $0A] = $AA Then
            sbfound:=True;
        Inc(xbyte2);
      Until (xbyte2 = $10) Or (portok);
      If Not portok Then
      Begin
        Port[sbport + $0C]:=xbyte3;
        Port[sbport + 6]:=xbyte4;
      End;
    End;
    If sbfound Then
    Begin
    End
    Else
      Inc(xbyte1);
  End;
End;


{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
FUNCTION pickatrack: Byte;
{Displays the user with a list of tracks to pick}
VAR
  Top, Bottom  : Byte;
  change      : Boolean; {scroller vi op/ned?}
  slut        : Boolean;
  i           : Byte;
  c           : Byte;
  curr        : Byte;
  index       : Byte;
  s: String;
  topl: Byte;
BEGIN
  topl := wherey-1; {topline}

  pickatrack := 0;
  s := '                         ';
  change := FALSE;
  curr  := 1;
  slut  := FALSE;
  Top   := 1;
  index := endtrack;


  TextColor (lightgray);
  gotoxy(32,topl+1);
  write('Select                           ');

  gotoxy(42,topl+1);
  write( '   │      ');

  curr:=track;
  REPEAT
  BEGIN
    TextBackground (Black);
    TextColor (lightgray);
    FOR i := Top TO Bottom DO
    BEGIN
      GotoXY (43, topl + 1);
      Write (' ');
      IF i = track THEN
      BEGIN
        TextColor (lightgray+ Blink);
        Write (leadingzero (i) );
        TextColor (lightgray);
        Write ('│');
        TextColor (lightgray+ Blink);
        Write (leadingzero (trackinfo [i]^. playmin) );
        TextColor (lightgray);
        Write (':');
        TextColor (lightgray+ Blink);
        Write (leadingzero (trackinfo [i]^. playsec) );
      END
      ELSE
      BEGIN
        Write (leadingzero (i) );
        Write ('│');
        Write (leadingzero (trackinfo [i]^. playmin) );
        Write (':');
        Write (leadingzero (trackinfo [i]^. playsec) );
      END;
    END;
    IF curr = track THEN
    BEGIN
      TextColor (lightgray);
      GotoXY (44, topl +  1);
      Write (leadingzero (curr) );
      TextColor (lightgray);
      Write ('│');
      TextColor (lightgray);
      Write (leadingzero (trackinfo [curr]^. playmin) );
      TextColor (lightgray);
      Write (':');
      TextColor (lightgray);
      Write (leadingzero (trackinfo [curr]^. playsec) );
    END
    ELSE
    BEGIN
      TextColor (lightgray);
      GotoXY (44, topl +  1);
      Write (leadingzero (curr) );
      Write ('│');
      Write (leadingzero (trackinfo [curr]^. playmin) );
      Write (':');
      Write (leadingzero (trackinfo [curr]^. playsec) );
    END;
    textbackground(black);
    textcolor(lightgray);
    gotoxy(39,topl+1);

    if curr=1 then write('( )');
    if curr=index then write('( )');
    if ((curr<index) and (Curr>1)) then write('()');

    repeat
      calctrack;
      q_channel_info;
      textcolor(yellow);
      gotoxy(18,wherey);
      write(leadingzero(track));
      gotoxy(21,wherey);
      textcolor(white);
      write(leadingzero(endtrack));
      textcolor(yellow);
      gotoxy(24,wherey);
      write(leadingzero(qchannelinfo.minutes));
      gotoxy(27,wherey);
      write(leadingzero(qchannelinfo.seconds));
    until keypressed;


    c := get_Svar;


    IF (c = uparrow) THEN
    BEGIN
      IF (curr = Top) AND (Top > 1) THEN
      BEGIN
        Dec (Top);
        Dec (curr);
        change := TRUE;
      END;
      IF (curr > Top) THEN Dec (curr);
    END;
    IF (c = dnarrow) THEN
    BEGIN
      IF (curr < index)THEN
      begin
        Inc (curr);
        inc(top);
      end;
    END;
    IF c = 100 THEN
    BEGIN
      pickatrack := curr;
      slut := TRUE;
    END;
    IF c = 27 THEN
    BEGIN
      TextBackground (Black);
      gotoxy(32,topl+1);write('                     ');
      Exit;
    END;
  END; {while}
  UNTIL slut;
  TextBackground (Black);
  gotoxy(32,topl+1);write('                       ');
END;



{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
PROCEDURE colwrite (col, startline: Byte; s: String);
{Writes a given line downwards from the given column and the given startline}
VAR
i, j: Byte;
BEGIN
  j := 1;
  FOR i := startline TO startline+ Length (s) - 1 DO
  BEGIN
    GotoXY (col, i);
    Write (s [j] );
    Inc (j);
  END;
END;




{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
PROCEDURE stuffthebuff;
{Empties the buffer}
VAR
  chartoskip: Char;

BEGIN
  WHILE KeyPressed DO
    chartoskip := ReadKey;
END;


{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
FUNCTION Get_Scan_Code : Word;
VAR
  HTregs : Registers;
BEGIN
  HTregs. AH := $01;
  Intr ($16, HTregs);
  Get_Scan_Code := HTregs. AX;
END;




{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
PROCEDURE fuckthebuff;
{Flushes the keyboard-buffer}
BEGIN
  ASM
    Mov AX, $0C00;
    Int 21h;
  END;

END;


{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
{▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄}
VAR
  currtrack    : Byte;
  ieren        : LongInt;
  slut         : Boolean;
  newtrack     : Byte;
  xkor,
  ykor         : Byte;
  timepassed:longint;
BEGIN
  origmode     := LastMode;
  cursoff;
  soundport;
  port [$224] := 48;
  lvolume := port [$225];
  port [$224] := 49;
  rvolume := port [$225];
  port [$224] := 65;


  xkor         := WhereX;
  ykor         := WhereY;
  TextColor (LightGray);
  TextBackground (Black);

  gotoxy(1,wherey-1);
  textcolor(white);
  write('(\/)ini');
  textcolor(lightgray);
  writeln('  v.1   Checking CD-ROM ... ');

  gotoxy(1,wherey);
  Audio_Disk_Info;
  Setup;

  IF AudioDiskInfo. HighestTrack < 1 THEN
  BEGIN
    delay(200);
    Audio_Disk_Info;
    Setup;
    WriteLn ('Not an audio-CD!');
    curson;
    Exit;
  END;

  gotoxy(1,wherey-1);

  gotoxy(01,wherey);
  write('(\/)ini  v.1     xx/xx xx:XX                                           L/th 1996');
  gotoxy(1,wherey-1);


  gotoxy(18,wherey);
  slut := FALSE;

  textcolor(white);

  audio_status_info;
  q_channel_info;
  audio_status_info;
  audio_disk_info;
  Play_Audio (trackinfo [starttrack]^. startpoint, trackinfo [endtrack]^. endpoint);


  REPEAT
    REPEAT
      if toslet then
      begin
        if elapsedtime(vol_time,readtimer)>700 then
        begin
          gotoxy(33,wherey);
          write('                                ');
          toslet:=false;
        end;
      end;

      fuckthebuff;
      calctrack;
      q_channel_info;
      gotoxy(18,wherey);
      write(leadingzero(track));
      gotoxy(21,wherey);
      textcolor(white);
      write(leadingzero(endtrack));
      textcolor(yellow);
      gotoxy(24,wherey);
      write(leadingzero(qchannelinfo.minutes));
      gotoxy(27,wherey);
      write(leadingzero(qchannelinfo.seconds));
    UNTIL InKey (Hi, Hi2);

    {ESC (EXIT AUDIO)}
    IF ( (Hi = 1) AND (Hi2 = 27) )  THEN slut := TRUE;

    {Page Up (UP ONE TRACK)}
    IF ( (Hi = 73) AND ( (Hi2 = 0) OR (Hi2 = 224) ) AND (playing) AND (track < endtrack) ) THEN
    BEGIN
      pause_audio;
      play_audio (trackinfo [track + 1]^. startpoint, trackinfo [endtrack]^. endpoint);
    END;

    {Page Down (DOWN ONE TRACK)}
    IF ( (Hi = 81) AND ( (Hi2 = 0) OR (Hi2 = 224) ) AND (playing) AND (track > starttrack) ) THEN
    BEGIN
      IF ( (place < (trackinfo [track]^. startpoint + 3000) ) ) THEN
      BEGIN
        pause_audio;
        play_audio (trackinfo [track - 1]^. startpoint, trackinfo [endtrack]^. endpoint);
      END;
      IF ( (place > (trackinfo [track]^. startpoint + 3000) ) ) THEN
      BEGIN
        pause_audio;
        play_audio (trackinfo [track]^. startpoint, trackinfo [endtrack]^. endpoint);
      END;
    END;

    {Right Arrow (SKIP 3-4 SECS)}
    IF ( (Hi = 77) AND ( (Hi2 = 0) OR (Hi2 = 224) ) AND (playing) AND ( (place+ (3000) ) <
       trackinfo [endtrack]^. endpoint) )
    THEN
    BEGIN
      pause_audio;
      play_audio (place+1000, trackinfo [endtrack]^. endpoint);
    END;

    {Left Arrow (SKIP 3-4 SECS)}
    IF ( (Hi = 75) AND ( (Hi2 = 0) OR (Hi2 = 224) ) AND (playing) AND ( (place- (3000 * 4) ) >
       trackinfo [starttrack]^. startpoint) )
    THEN
    BEGIN
      pause_audio;
      play_audio ((place- 1000), trackinfo [endtrack]^. endpoint);
      delay(20);
    END;

    {Middle key (PAUSE/RESUME)}
    IF ( (Hi = 76) AND (Hi2 = 0) ) THEN
    BEGIN
      IF playing THEN
      BEGIN
        io_control (stopplay);
        audio_status_info;
      END
      ELSE
      BEGIN
        resume_play;
      END;
    END;

    IF ( (Hi = 52) AND (Hi2 = 46) ) THEN
    BEGIN
      newtrack := pickatrack;
      IF newtrack > 0 THEN
      BEGIN
        pause_audio;
        play_audio (trackinfo [newtrack]^. startpoint, trackinfo [endtrack]^. endpoint);
      END;
    END;

    {HELP MENU!}
    IF ( (Hi = 59) AND (Hi2 = 0) ) THEN
    BEGIN
      fuckthebuff;
      help;
      gotoxy(01,wherey-1);
      write('(\/)ini  v.1     xx/xx xx:XX                                           L/th 1996');
      gotoxy(1,wherey-1);
    END;



{ VOLUME-CONTROL!}

{'-' (Reduce BOTH volumes)}
    IF ( (Hi = 74) AND (Hi2 = 45) AND NOT ( (left_shift) OR (right_shift) ) ) THEN
    BEGIN
      if sbfound then
      begin
        IF rvolume > 04 THEN
        BEGIN
          DEC (rvolume, 4);
          port [$224] := 49;
          port [$225] := rvolume;
        END;
        IF lvolume > 04 THEN
        BEGIN
          DEC (lvolume, 4);
          port [$224] := 48;
          port [$225] := lvolume;
        END;
        showvolume;
      end;
    END;


{'+' (Increase BOTH volumes)}
    IF ( (Hi = 78) AND (Hi2 = 43) AND NOT ( (left_shift) OR (right_shift) ) ) THEN
    BEGIN
      if sbfound then
      begin
        IF rvolume < 252 THEN
        BEGIN
          INC (rvolume, 4);
          port [$224] := 49;
          port [$225] := rvolume;
        END;
        IF lvolume < 252 THEN
        BEGIN
          INC (lvolume, 4);
          port [$224] := 48;
          port [$225] := lvolume;
        END;
        showvolume;
      end;
    END;

{ VOLUME-CONTROL!}
   stuffthebuff;
  UNTIL slut;
gotoxy(1,wherey);
textcolor(lightgray);
writeln('(\/)ini  v.1     Mini-CD-ROM-player                                    L/th 1996');
curson;
END.


{CUT OFF ...}

{CUT ... Save this as CD_UNIT.PAS}
UNIT CD_Unit;

INTERFACE

USES DOS, CD_Vars;

VAR
  Drive   : Integer;  { Must set drive before all operations }
  SubUnit : Integer;
  
PROCEDURE IO_Control (Command : Byte);
FUNCTION File_Name (VAR Code : Integer) : String;

FUNCTION Read_VTOC (VAR VTOC : VTOCArray;
                   VAR Index : Integer) : Boolean;

PROCEDURE CD_Check (VAR Code : Integer);

PROCEDURE Vol_Desc (VAR Code : Integer;
                   VAR ErrCode : Integer);

PROCEDURE CD_Dev_Req (DevPointer : Pointer);

PROCEDURE Get_Dir_Entry (PathName : String;
                        VAR Format, ErrCode : Integer);

PROCEDURE DeviceStatus;

PROCEDURE Audio_Channel_Info;

PROCEDURE Audio_Disk_Info;

PROCEDURE Audio_Track_Info (VAR StartPoint : LongInt;
                           VAR TrackControl : Byte);

PROCEDURE Audio_Status_Info;

PROCEDURE Q_Channel_Info;

PROCEDURE Lock (LockDrive : Boolean);

PROCEDURE Resetcd;

PROCEDURE Eject;

PROCEDURE CloseTray;

PROCEDURE Resume_Play;

PROCEDURE Pause_Audio;

PROCEDURE Play_Audio (StartSec, EndSec : LongInt);

FUNCTION Sector_Size (ReadMode : Integer) : Word;

FUNCTION Volume_Size : LongInt;

FUNCTION Media_Changed : Boolean;

FUNCTION Head_Location (AddrMode : Byte) : LongInt;

PROCEDURE Read_Drive_Bytes (VAR ReadBytes : DriveByteArray);

PROCEDURE Read_Long (TransAddr : Pointer; StartSec : LongInt);

PROCEDURE SeekSec (StartSec : LongInt);

PROCEDURE DevClose;

PROCEDURE DevOpen;

PROCEDURE OutputFlush;

PROCEDURE InputFlush;

FUNCTION UPC_Code : String;

IMPLEMENTATION

CONST
  CarryFlag  = $0001;

TYPE
  PointerHalf = RECORD
                  LoHalf, HiHalf : Word;
                END;
  
VAR
  Regs       : Registers;
  IOBlock    : IOControl;
  DriveBytes : ARRAY [1..130] OF Byte;
  
PROCEDURE Clear_Regs;
BEGIN
  FillChar (Regs, SizeOf (Regs), #0);
END;

PROCEDURE CD_Intr;
BEGIN
  Regs. AH := $15;
  Intr ($2F, Regs);
END;

PROCEDURE MSCDEX_Ver;
BEGIN
  Clear_Regs;
  Regs. AL := $0C;
  Regs. BX := $0000;
  CD_Intr;
  MSCDEX_Version. Minor := 0;
  IF Regs. BX = 0 THEN
    MSCDEX_Version. Major := 1
  ELSE
  BEGIN
    MSCDEX_Version. Major := Regs. BH;
    MSCDEX_Version. Minor := Regs. BL;
  END;
END;

PROCEDURE Initialize;
BEGIN
  NumberOfCD := 0;
  Clear_Regs;
  Regs. AL := $00;
  Regs. BX := $0000;
  CD_Intr;
  IF Regs. BX <> 0 THEN
  BEGIN
    NumberOfCD := Regs. BX;
    FirstCD := Regs. CX;
    Clear_Regs;
    FillChar (DriverList, SizeOf (DriverList), #0);
    FillChar (UnitList, SizeOf (UnitList), #0);
    Regs. AL := $01;               { Get List of Driver Header Addresses }
    Regs. ES := Seg (DriverList);
    Regs. BX := Ofs (DriverList);
    CD_Intr;
    Clear_Regs;
    Regs. AL := $0D;               { Get List of CD-ROM Units }
    Regs. ES := Seg (UnitList);
    Regs. BX := Ofs (UnitList);
    CD_Intr;
    MSCDEX_Ver;
  END;
END;


FUNCTION File_Name (VAR Code : Integer) : String;
VAR
  FN : String [38];
BEGIN
  Clear_Regs;
  Regs. AL := Code + 1;
  {
  Copyright Filename     =  1
  Abstract Filename      =  2
  Bibliographic Filename =  3
  }
  Regs. CX := Drive;
  Regs. ES := Seg (FN);
  Regs. BX := Ofs (FN);
  CD_Intr;
  Code := Regs. AX;
  IF (Regs. Flags AND CarryFlag) = 0 THEN
    File_Name := FN
  ELSE
    File_Name := '';
END;


FUNCTION Read_VTOC (VAR VTOC : VTOCArray;
                   VAR Index : Integer) : Boolean;
{ On entry -
     Index = Vol Desc Number to read from 0 to ?
  On return
     Case Index of
            1    : Standard Volume Descriptor
            $FF  : Volume Descriptor Terminator
            0    : All others
}
BEGIN
  Clear_Regs;
  Regs. AL := $05;
  Regs. CX := Drive;
  Regs. DX := Index;
  Regs. ES := Seg (VTOC);
  Regs. BX := Ofs (VTOC);
  CD_Intr;
  Index := Regs. AX;
  IF (Regs. Flags AND CarryFlag) = 0 THEN
    Read_VTOC := TRUE
  ELSE
    Read_VTOC := FALSE;
END;

PROCEDURE CD_Check (VAR Code : Integer);
BEGIN
  Clear_Regs;
  Regs. AL := $0B;
  Regs. BX := $0000;
  Regs. CX := Drive;
  CD_Intr;
  IF Regs. BX <> $ADAD THEN
    Code := 2
  ELSE
  BEGIN
    IF Regs. AX <> 0 THEN
      Code := 0
    ELSE
      Code := 1;
  END;
END;


PROCEDURE Vol_Desc (VAR Code : Integer;
                   VAR ErrCode : Integer);

  FUNCTION Get_Vol_Desc : Byte;
    BEGIN
      Clear_Regs;
      Regs. CX := Drive;
      Regs. AL := $0E;
      Regs. BX := $0000;
      CD_Intr;
      Code := Regs. AX;
      IF (Regs. Flags AND CarryFlag) <> 0 THEN
        ErrCode := $FF;
      Get_Vol_Desc := Regs. DH;
    END;

BEGIN
  Clear_Regs;
  ErrCode := 0;
  IF Code <> 0 THEN
  BEGIN
    Regs. DH := Code;
    Regs. DL := 0;
    Regs. BX := $0001;
    Regs. AL := $0E;
    Regs. CX := Drive;
    CD_Intr;
    Code := Regs. AX;
    IF (Regs. Flags AND CarryFlag) <> 0 THEN
      ErrCode := $FF;
  END;
  IF ErrCode = 0 THEN
    Code := Get_Vol_Desc;
END;

PROCEDURE Get_Dir_Entry (PathName : String;
                        VAR Format, ErrCode : Integer);
BEGIN
  FillChar (DirBuf, SizeOf (DirBuf), #0);
  PathName := PathName + #0;
  Clear_Regs;
  Regs. AL := $0F;
  Regs. CL := Drive;
  Regs. CH := 1;
  Regs. ES := Seg (PathName);
  Regs. BX := Ofs (PathName);
  Regs. SI := Seg (DirBuf);
  Regs. DI := Ofs (DirBuf);
  CD_Intr;
  ErrCode := Regs. AX;
  IF (Regs. Flags AND CarryFlag) = 0 THEN
  BEGIN
    Move (DirBuf. NameArray [1], DirBuf. FileName [1], 38);
    DirBuf. FileName [0] := #12; { File names are only 8.3 }
    Format := Regs. AX
  END
  ELSE
    Format := $FF;
END;

PROCEDURE CD_Dev_Req (DevPointer : Pointer);
BEGIN
  Clear_Regs;
  Regs. AL := $10;
  Regs. CX := Drive;
  Regs. ES := PointerHalf (DevPointer).HiHalf;
  Regs. BX := PointerHalf (DevPointer).LoHalf;
  CD_Intr;
END;

PROCEDURE IO_Control (Command : Byte);
BEGIN
  IOBlock. IOReq_Hdr. Len := 26;
  IOBlock. IOReq_Hdr. SubUnit := SubUnit;
  IOBlock. IOReq_Hdr. Status := 0;
  IOBlock. TransAddr := @DriveBytes;
  IOBlock. IOReq_Hdr. Command := Command;
  
  FillChar (IOBlock. IOReq_Hdr. Reserved, 8, #0);
  
  CD_Dev_Req (@IOBlock);
  
  Busy :=   (IOBlock. IOReq_Hdr. Status AND 512) <> 0;
  
  
END;

PROCEDURE Audio_Channel_Info;
BEGIN
  FillChar (DriveBytes, SizeOf (DriveBytes), #0);
  DriveBytes [1] := 4;
  IOBlock. NumBytes := 9;
  
  IO_Control (IOCtlInput);
  
  Move (DriveBytes, AudioChannel, 9);
END;

PROCEDURE DeviceStatus;
BEGIN
  FillChar (DriveBytes, SizeOf (DriveBytes), #0);
  
  DriveBytes [1] := 6;
  IOBlock. NumBytes := 5;
  
  IO_Control (IOCtlInput);
  
  DoorOpen     := DriveBytes [2] AND 1 <> 0;
  DoorLocked   := DriveBytes [2] AND 2 <> 0;
  AudioManip   := DriveBytes [3] AND 1 <> 0;
  DiscInDrive  := DriveBytes [3] AND 8 <> 0;
  
END;

PROCEDURE Audio_Disk_Info;
BEGIN
  FillChar (DriveBytes, SizeOf (DriveBytes), #0);
  
  DriveBytes [1] := 10;
  IOBlock. NumBytes := 7;
  
  IO_Control (IOCtlInput);
  
  Move (DriveBytes [2], AudioDiskInfo, 6);
  
  Playing := Busy;
  
END;

PROCEDURE Audio_Track_Info (VAR StartPoint : LongInt;
                           VAR TrackControl : Byte);
BEGIN
  FillChar (DriveBytes, SizeOf (DriveBytes), #0);

  DriveBytes [1] := 11;
  DriveBytes [2] := TrackControl;   { Track number }
  IOBlock. NumBytes := 7;
  
  IO_Control (IOCtlInput);
  
  Move (DriveBytes [3], StartPoint, 4);
  
  TrackControl := DriveBytes [7];
  
  Playing := Busy;
END;

PROCEDURE Q_Channel_Info;
BEGIN
  FillChar (DriveBytes, SizeOf (DriveBytes), #0);
  
  DriveBytes [1] := 12;
  IOBlock. NumBytes := 11;
  
  IO_Control (IOCtlInput);
  
  Move (DriveBytes [2], QChannelInfo, 11);
  
END;

PROCEDURE Audio_Status_Info;
BEGIN
  FillChar (DriveBytes, SizeOf (DriveBytes), #0);
  
  DriveBytes [1] := 15;
  IOBlock. NumBytes := 11;
  
  IO_Control (IOCtlInput);
  
  Paused := (Word (DriveBytes [2] ) AND 1) <> 0;
  
  Move (DriveBytes [4], Last_Start, 4);
  Move (DriveBytes [8], Last_End, 4);
  
  Playing := Busy;
END;

PROCEDURE Eject;
BEGIN
  FillChar (DriveBytes, SizeOf (DriveBytes), #0);
  
  DriveBytes [1] := 0;
  IOBlock. NumBytes := 1;
  
  IO_Control (IOCtlOutput);
END;

PROCEDURE Resetcd;
BEGIN
  FillChar (DriveBytes, SizeOf (DriveBytes), #0);

  DriveBytes [1] := 2;
  IOBlock. NumBytes := 1;
  
  IO_Control (IOCtlOutput);
  Busy := TRUE;
END;

PROCEDURE Lock (LockDrive : Boolean);
BEGIN
  FillChar (DriveBytes, SizeOf (DriveBytes), #0);
  
  DriveBytes [1] := 1;
  IF LockDrive THEN
    DriveBytes [2] := 1
  ELSE
    DriveBytes [2] := 0;
  IOBlock. NumBytes := 2;
  
  IO_Control (IOCtlOutput);
END;

PROCEDURE CloseTray;
BEGIN
  FillChar (DriveBytes, SizeOf (DriveBytes), #0);
  
  DriveBytes [1] := 5;
  IOBlock. NumBytes := 1;
  
  IO_Control (IOCtlOutput);
END;

VAR
  AudioPlay : Audio_Play;
  
FUNCTION Play (StartLoc, NumSec : LongInt) : Boolean;
BEGIN
  FillChar (AudioPlay, SizeOf (AudioPlay), #0);
  AudioPlay. APReq. Command := PlayCD;
  AudioPlay. APReq. Len := 22;
  AudioPlay. APReq. SubUnit := SubUnit;
  AudioPlay. Start := StartLoc;
  AudioPlay. NumSecs := NumSec;
  AudioPlay. AddrMode := 1;
  
  CD_Dev_Req (@AudioPlay);
  Play := ( (AudioPlay. APReq. Status AND 32768) = 0);
  
END;

PROCEDURE Play_Audio (StartSec, EndSec : LongInt);
VAR
  SP,
  EP     : LongInt;
  SArray : ARRAY [1..4] OF Byte;
  EArray : ARRAY [1..4] OF Byte;
BEGIN
  Move (StartSec, SArray [1], 4);
  Move (EndSec, EArray [1], 4);
  SP := SArray [3];           { Must use longint or get negative result }
  SP := (SP * 75 * 60) + (SArray [2] * 75) + SArray [1];
  EP := EArray [3];
  EP := (EP * 75 * 60) + (EArray [2] * 75) + EArray [1];
  EP := EP - SP;
  
  Playing := Play (StartSec, EP);
  Audio_Status_Info;
END;

PROCEDURE Pause_Audio;
BEGIN
  IF Playing THEN
  BEGIN
    FillChar (AudioPlay, SizeOf (AudioPlay), #0);
    AudioPlay. APReq. Command := stopplay; {stopplay}
    AudioPlay. APReq. Len := 13;
    AudioPlay. APReq. SubUnit := SubUnit;
    CD_Dev_Req (@AudioPlay);
  END;
  Audio_Status_Info;
  Playing := FALSE;
END;

PROCEDURE Resume_Play;
BEGIN
  FillChar (AudioPlay, SizeOf (AudioPlay), #0);
  AudioPlay. APReq. Command := ResumePlay;
  AudioPlay. APReq. Len := 13;
  AudioPlay. APReq. SubUnit := SubUnit;
  CD_Dev_Req (@AudioPlay);
  Audio_Status_Info;
END;

FUNCTION Sector_Size (ReadMode : Integer) : Word;
VAR SecSize : Word;
BEGIN
  FillChar (DriveBytes, SizeOf (DriveBytes), #0);
  
  DriveBytes [1] := 7;
  DriveBytes [2] := ReadMode;
  
  IOBlock. NumBytes := 4;
  
  IO_Control (IOCtlInput);
  
  Move (DriveBytes [3], SecSize, 2);
  Sector_Size := SecSize;
END;

(*Function CD_GetVol:Boolean;
begin
  CtlBlk[0] := 4;                           { die Lautstaerke lesen }
  CD_GetVol := CD_IOCtl(IoCtlRead, 8);
  if ((R.Flags and FCARRY) = 0)
   then Move(CtlBlk[1], CD.VolInfo, 8)
   else FillChar( CD.VolInfo, 8, 0)
end;

Function CD_SetVol:Boolean;
begin
  CtlBlk[0] := 3;                          { die Lautstaerke setzen }
  CD_SetVol := CD_IOCtl( IoCtlWrite, 8);
end;
*)

FUNCTION Volume_Size : LongInt;
VAR VolSize : LongInt;
BEGIN
  FillChar (DriveBytes, SizeOf (DriveBytes), #0);
  
  DriveBytes [1] := 8;
  
  IOBlock. NumBytes := 5;

  IO_Control (IOCtlInput);
  
  Move (DriveBytes [2], VolSize, 4);
  Volume_Size := VolSize;
END;

FUNCTION Media_Changed : Boolean;
VAR MedChng : Byte;
  
  {  1  :  Media not changed
  0  :  Don't Know
  -1  :  Media changed
  }
BEGIN
  FillChar (DriveBytes, SizeOf (DriveBytes), #0);
  
  DriveBytes [1] := 9;
  
  IOBlock. NumBytes := 2;
  
  IO_Control (IOCtlInput);
  
  Move (DriveBytes [2], MedChng, 4);
  Inc (MedChng);
  CASE MedChng OF
    2    : Media_Changed := FALSE;
    1, 0  : Media_Changed := TRUE;
  END;
END;

FUNCTION Head_Location (AddrMode : Byte) : LongInt;
VAR
  HeadLoc : LongInt;
BEGIN
  FillChar (DriveBytes, SizeOf (DriveBytes), #0);
  
  DriveBytes [1] := 1;
  DriveBytes [2] := AddrMode;
  
  IOBlock. NumBytes := 6;
  
  IO_Control (IOCtlInput);
  
  Move (DriveBytes [3], HeadLoc, 4);
  Head_Location := HeadLoc;
END;

PROCEDURE Read_Drive_Bytes (VAR ReadBytes : DriveByteArray);
BEGIN
  FillChar (DriveBytes, SizeOf (DriveBytes), #0);
  
  DriveBytes [1] := 5;
  
  IOBlock. NumBytes := 130;
  
  IO_Control (IOCtlInput);

  Move (DriveBytes [3], ReadBytes, 128);
END;


FUNCTION UPC_Code : String;
VAR
  I, J, K : Integer;
  TempStr : String;
BEGIN
  FillChar (DriveBytes, SizeOf (DriveBytes), #0);
  TempStr := '';
  DriveBytes [1] := 14;
  
  IOBlock. NumBytes := 11;
  
  IO_Control (IOCtlInput);
  
  IF ( (IOBlock. IOReq_Hdr. Status AND 32768) = 0) THEN;
  FOR I := 3 TO 9 DO
  BEGIN
    J := DriveBytes [I] AND $0F;
    K := DriveBytes [I] AND $F0;
    TempStr := TempStr + Chr (J + 48);
    TempStr := TempStr + Chr (K + 48);
  END;
  IF Length (TempStr) > 13 THEN
    TempStr [0] := Chr (Ord (TempStr [0] ) - 1);
  UPC_Code := TempStr;
END;


PROCEDURE Read_Long (TransAddr : Pointer; StartSec : LongInt);
VAR
  RL : ReadControl;
  {
  ReadControl = Record
  IOReq_Hdr : Req_Hdr;
  AddrMode  : Byte;
  TransAddr : Pointer;
  NumSecs   : Word;
  StartSec  : LongInt;
  ReadMode  : Byte;
  IL_Size,
  IL_Skip   : Byte;
  End;
  }
BEGIN
  FillChar (RL, SizeOf (RL), #0);
  RL. IOReq_Hdr. Len := 27;
  RL. IOReq_Hdr. SubUnit := SubUnit;
  RL. IOReq_Hdr. Command := ReadLong;
  RL. AddrMode := 1;
  RL. TransAddr := TransAddr;
  RL. NumSecs := 1;
  RL. StartSec := StartSec;
  RL. ReadMode := 0;
  CD_Dev_Req (@RL);
END;

PROCEDURE SeekSec (StartSec : LongInt);
VAR
  RL : ReadControl;
  
BEGIN
  FillChar (RL, SizeOf (RL), #0);
  RL. IOReq_Hdr. Len := 24;
  RL. IOReq_Hdr. SubUnit := SubUnit;
  RL. IOReq_Hdr. Command := SeekCmd;
  RL. AddrMode := 1;
  RL. StartSec := StartSec;
  RL. ReadMode := 0;
  CD_Dev_Req (@RL);
END;

PROCEDURE InputFlush;
VAR
  IOReq : Req_Hdr;
BEGIN
  FillChar (IOReq, SizeOf (IOReq), #0);
  WITH IOReq DO
  BEGIN
    Len     := 13;
    SubUnit := SubUnit;
    Command := 7;
    Status  := 0;
  END;
  CD_Dev_Req (@IOReq);
END;

PROCEDURE OutputFlush;
VAR
  IOReq : Req_Hdr;
BEGIN
  FillChar (IOReq, SizeOf (IOReq), #0);
  WITH IOReq DO
  BEGIN
    Len     := 13;
    SubUnit := SubUnit;
    Command := 11;
    Status  := 0;
  END;
  CD_Dev_Req (@IOReq);
END;

PROCEDURE DevOpen;
VAR
  IOReq : Req_Hdr;
BEGIN
  FillChar (IOReq, SizeOf (IOReq), #0);
  WITH IOReq DO
  BEGIN
    Len     := 13;
    SubUnit := SubUnit;
    Command := 13;
    Status  := 0;
  END;
  CD_Dev_Req (@IOReq);
END;

PROCEDURE DevClose;
VAR
  IOReq : Req_Hdr;
BEGIN
  FillChar (IOReq, SizeOf (IOReq), #0);
  WITH IOReq DO
  BEGIN
    Len     := 13;
    SubUnit := SubUnit;
    Command := 14;
    Status  := 0;
  END;
  CD_Dev_Req (@IOReq);
END;

{************************************************************}

BEGIN
  NumberOfCD := 0;
  FirstCD := 0;
  FillChar (MSCDEX_Version, SizeOf (MSCDEX_Version), #0);
  Initialize;
  Drive := FirstCD;
  SubUnit := 0;
END.

{CUT OFF ...}

{CUT ... Save this as CD_VARS.PAS}

UNIT CD_Vars;

INTERFACE

TYPE
  ListBuf    = RECORD
                 UnitCode : Byte;
                 UnitSeg,
                 UnitOfs  : Word;
               END;
  VTOCArray  = ARRAY [1..2048] OF Byte;
  DriveByteArray = ARRAY [1..128] OF Byte;
  
  Req_Hdr    = RECORD
                 Len     : Byte;
                 SubUnit : Byte;
                 Command : Byte;
                 Status  : Word;
                 Reserved: ARRAY [1..8] OF Byte;
               END;
  
CONST
  Init       = 0;
  IoCtlInput = 3;
  InputFlush = 7;
  IOCtlOutput = 12;
  DevOpen    = 13;
  DevClose   = 14;
  ReadLong   = 128;
  ReadLongP  = 130;
  SeekCmd    = 131;
  PlayCD     = 132;
  StopPlay   = 133;
  ResumePlay = 136;
  
TYPE
  
  Audio_Play = RECORD
                 APReq    : Req_Hdr;
                 AddrMode : Byte;
                 Start    : LongInt;
                 NumSecs  : LongInt;
               END;
  
  IOControl = RECORD
                IOReq_Hdr : Req_Hdr;
                MediaDesc : Byte;
                TransAddr : Pointer;
                NumBytes  : Word;
                StartSec  : Word;
                ReqVol    : Pointer;
              END;
  
  ReadControl = RECORD
                  IOReq_Hdr : Req_Hdr;
                  AddrMode  : Byte;
                  TransAddr : Pointer;
                  NumSecs   : Word;
                  StartSec  : LongInt;
                  ReadMode  : Byte;
                  IL_Size,
                  IL_Skip   : Byte;
                END;
  
  AudioDiskInfoRec = RECORD
                       LowestTrack    : Byte;
                       HighestTrack   : Byte;
                       LeadOutTrack   : LongInt;
                       {new!}
                       VolInfo: ARRAY [1..8] OF Byte; { Lautst.-Einstellungen }
                     END;
  
  PAudioTrackInfo   = ^AudioTrackInfoRec;
  AudioTrackInfoRec = RECORD
                        Track           : Integer;
                        StartPoint      : LongInt;
                        EndPoint        : LongInt;
                        Frames,
                        Seconds,
                        Minutes,
                        PlayMin,
                        PlaySec,
                        TrackControl    : Byte;
                      END;
  
  MSCDEX_Ver_Rec = RECORD
                     Major,
                     Minor       : Integer;
                   END;
  
  DirBufRec    = RECORD
                   XAR_Len   : Byte;
                   FileStart : LongInt;
                   BlockSize : Integer;
                   FileLen   : LongInt;
                   DT        : Byte;
                   Flags     : Byte;
                   InterSize : Byte;
                   InterSkip : Byte;
                   VSSN      : Integer;
                   NameLen   : Byte;
                   NameArray : ARRAY [1..38] OF Char;
                   FileVer   : Integer;
                   SysUseLen : Byte;
                   SysUseData: ARRAY [1..220] OF Byte;
                   FileName  : String [38];
                 END;
  
  Q_Channel_Rec = RECORD
                    Control     : Byte;
                    Track       : Byte;
                    Index       : Byte;
                    Minutes     : Byte;
                    Seconds     : Byte;
                    Frame       : Byte;
                    Zero        : Byte;
                    AMinutes    : Byte;
                    ASeconds    : Byte;
                    AFrame      : Byte;
                  END;
  
VAR
  AudioChannel   : ARRAY [1..9] OF Byte;
  DoorOpen,
  DoorLocked,
  AudioManip,
  DiscInDrive    : Boolean;
  AudioDiskInfo  : AudioDiskInfoRec;
  DriverList     : ARRAY [1..26] OF ListBuf;
  NumberOfCD     : Integer;
  FirstCD        : Integer;
  UnitList       : ARRAY [1..26] OF Byte;
  MSCDEX_Version : MSCDEX_Ver_Rec;
  QChannelInfo   : Q_Channel_Rec;
  Busy,
  Playing,
  Paused         : Boolean;
  Last_Start,
  Last_End       : LongInt;
  DirBuf         : DirBufRec;
  
IMPLEMENTATION

BEGIN
  FillChar (DriverList, SizeOf (DriverList), #0);
  FillChar (UnitList, SizeOf (UnitList), #0);
  NumberOfCD  := 0;
  FirstCD  := 0;
  MSCDEX_Version. Major := 0;
  MSCDEX_Version. Minor := 0;
END.

{CUT OFF ...}


{CUT ... Save this as TPTIMER.PAS}

{$S-,R-,I-,V-,B-}

{*********************************************************}
{*                   TPTIMER.PAS 2.00                    *}
{*                by TurboPower Software                 *}
{*********************************************************}

UNIT TpTimer;
  {-Allows events to be timed with 1 microsecond resolution}

INTERFACE

PROCEDURE InitializeTimer;
  {-Reprogram the timer chip to allow 1 microsecond resolution}

PROCEDURE RestoreTimer;
  {-Restore the timer chip to its normal state}

FUNCTION ReadTimer : LongInt;
  {-Read the timer with 1 microsecond resolution}

FUNCTION ElapsedTime (Start, Stop : LongInt) : Real;
  {-Calculate time elapsed (in milliseconds) between Start and Stop}

FUNCTION ElapsedTimeString (Start, Stop : LongInt) : String;
  {-Return time elapsed (in milliseconds) between Start and Stop as a string}

  {==========================================================================}

IMPLEMENTATION

CONST
  TimerResolution = 1193181.667;
VAR
  SaveExitProc : Pointer;
  Delta : LongInt;
  
FUNCTION Cardinal (L : LongInt) : Real;
    {-Return the unsigned equivalent of L as a real}
  BEGIN                      {Cardinal}
    IF L < 0 THEN
      Cardinal := 4294967296.0 + L
    ELSE
      Cardinal := L;
  END;                       {Cardinal}

  FUNCTION ElapsedTime (Start, Stop : LongInt) : Real;
    {-Calculate time elapsed (in milliseconds) between Start and Stop}
  BEGIN                      {ElapsedTime}
    ElapsedTime := 1000.0 * Cardinal (Stop - (Start + Delta) ) / TimerResolution;
  END;                       {ElapsedTime}

  FUNCTION ElapsedTimeString (Start, Stop : LongInt) : String;
    {-Return time elapsed (in milliseconds) between Start and Stop as a string}
  VAR
    R : Real;
    S : String;
  BEGIN                      {ElapsedTimeString}
    R := ElapsedTime (Start, Stop);
    Str (R: 0: 3, S);
    ElapsedTimeString := S;
  END;                       {ElapsedTimeString}

  PROCEDURE InitializeTimer;
    {-Reprogram the timer chip to allow 1 microsecond resolution}
  BEGIN                      {InitializeTimer}
    {select timer mode 2, read/write channel 0}
    Port [$43] := $34;        {00110100b}
    INLINE ($EB / $00);         {jmp short $+2 ;delay}
    Port [$40] := $00;        {LSB = 0}
    INLINE ($EB / $00);         {jmp short $+2 ;delay}
    Port [$40] := $00;        {MSB = 0}
  END;                       {InitializeTimer}

  PROCEDURE RestoreTimer;
    {-Restore the timer chip to its normal state}
  BEGIN                      {RestoreTimer}
    {select timer mode 3, read/write channel 0}
    Port [$43] := $36;        {00110110b}
    INLINE ($EB / $00);         {jmp short $+2 ;delay}
    Port [$40] := $00;        {LSB = 0}
    INLINE ($EB / $00);         {jmp short $+2 ;delay}
    Port [$40] := $00;        {MSB = 0}
  END;                       {RestoreTimer}

  FUNCTION ReadTimer : LongInt;
    {-Read the timer with 1 microsecond resolution}
  BEGIN                      {ReadTimer}
    INLINE (
    $FA /                   {cli             ;Disable interrupts}
    $BA / $20 / $00 /           {mov  dx,$20     ;Address PIC ocw3}
    $B0 / $0A /               {mov  al,$0A     ;Ask to read irr}
    $EE /                   {out  dx,al}
    $B0 / $00 /               {mov  al,$00     ;Latch timer 0}
    $E6 / $43 /               {out  $43,al}
    $EC /                   {in   al,dx      ;Read irr}
    $89 / $C7 /               {mov  di,ax      ;Save it in DI}
    $E4 / $40 /               {in   al,$40     ;Counter --> bx}
    $88 / $C3 /               {mov  bl,al      ;LSB in BL}
    $E4 / $40 /               {in   al,$40}
    $88 / $C7 /               {mov  bh,al      ;MSB in BH}
    $F7 / $D3 /               {not  bx         ;Need ascending counter}
    $E4 / $21 /               {in   al,$21     ;Read PIC imr}
    $89 / $C6 /               {mov  si,ax      ;Save it in SI}
    $B0 / $FF /               {mov  al,$0FF    ;Mask all interrupts}
    $E6 / $21 /               {out  $21,al}
    $B8 / $40 / $00 /           {mov  ax,$40     ;read low word of time}
    $8E / $C0 /               {mov  es,ax      ;from BIOS data area}
    $26 / $8B / $16 / $6C / $00 /   {mov  dx,es:[$6C]}
    $89 / $F0 /               {mov  ax,si      ;Restore imr from SI}
    $E6 / $21 /               {out  $21,al}
    $FB /                   {sti             ;Enable interrupts}
    $89 / $F8 /               {mov  ax,di      ;Retrieve old irr}
    $A8 / $01 /               {test al,$01     ;Counter hit 0?}
    $74 / $07 /               {jz   done       ;Jump if not}
    $81 / $FB / $FF / $00 /       {cmp  bx,$FF     ;Counter > $FF?}
    $77 / $01 /               {ja   done       ;Done if so}
    $42 /                   {inc  dx         ;Else count int req.}
    {done:}
    $89 / $5E / $FC /           {mov [bp-4],bx   ;set function result}
    $89 / $56 / $FE);          {mov [bp-2],dx}
  END;                       {ReadTimer}

  PROCEDURE Calibrate;
    {-Calibrate the timer}
  CONST
    Reps = 1000;
  VAR
    I : Word;
    L1, L2, Diff : LongInt;
  BEGIN                      {Calibrate}
    Delta := MaxInt;
    FOR I := 1 TO Reps DO BEGIN
      L1 := ReadTimer;
      L2 := ReadTimer;
      {use the minimum difference}
      Diff := L2 - L1;
      IF Diff < Delta THEN
        Delta := Diff;
    END;
  END;                       {Calibrate}

  {$F+}
  PROCEDURE OurExitProc;
    {-Restore timer chip to its original state}
  BEGIN                      {OurExitProc}
    ExitProc := SaveExitProc;
    RestoreTimer;
  END;                       {OurExitProc}
  {$F-}

BEGIN
  {set up our exit handler}
  SaveExitProc := ExitProc;
  ExitProc := @OurExitProc;
  
  {reprogram the timer chip}
  InitializeTimer;
  
  {adjust for speed of machine}
  Calibrate;
END.


{CUT OFF...}


{CUT ... Save this as TCTIMER.PAS}

UNIT tctimer;

INTERFACE
USES tptimer;

  VAR
    start : LongInt;
    
  PROCEDURE StartTimer;

PROCEDURE WriteElapsedTime;



IMPLEMENTATION

PROCEDURE StartTimer;
  BEGIN
    start := ReadTimer;
  END;

PROCEDURE  WriteElapsedTime;
  VAR stop : LongInt;
  BEGIN
    stop := ReadTimer;
    WriteLn ('calc = ', (ElapsedTime (start, stop) / 1000): 10: 6, ' sec');
  END;


END.

{CUT OFF...}

{CUT ... Save this as TPBUFFER.PAS}

UNIT TPbuffer;

(* TP-Buffer unit version 1.1 /Update              *)
(* Using the keyboard's buffer in Turbo Pascal     *)
(* This unit is released to the public domain      *)
(* by Lavi Tidhar on 5-10-1992                     *)

(* This unit adds three special functions not      *)
(* incuded in the Turbo Pascal regular package     *)

(* You may alter this source code, move the        *)
(* procedures to your own programs. Please do      *)
(* NOT change these lines of documentation         *)

(* This source might teach you about how to        *)
(* use interrupts in pascal, and the keyboard's    *)
(* buffer. from the other hand, it might not :-)   *)

(* Used: INT 16, functions 0 and 1                 *)
(*       INT 21, function 0Ch                      *)

(* INT 16 - KEYBOARD - READ CHAR FROM BUFFER, WAIT IF EMPTY
           AH = 00h
           Return: AH = scan code
                   AL = character         *)

(* INT 16 - KEYBOARD - CHECK BUFFER, DO NOT CLEAR
           AH = 01h
           Return: ZF = 0 character in buffer
                       AH = scan code
                       AL = character
                       ZF = 1 no character in buffer *)

(* INT 21 - DOS - CLEAR KEYBOARD BUFFER
        AH = 0Ch
        AL must be 1, 6, 7, 8, or 0Ah.
        Notes: Flushes all typeahead input, then executes function specified by AL
        (effectively moving it to AH and repeating the INT 21 call).
        If AL contains a value not in the list above, the keyboard buffer is
        flushed and no other action is taken. *)

(* For more details/help etc, you can contact me on: *)

(* Mail: Lavi Tidhar
         46 Bantam Dr.
         Blairgowrie
         2194
         South Africa
*)

(* Phone:
          International: +27-11-787-8093
          South Africa:  (011)-787-8093
*)

(* Netmail: The Catacomb BBS 5:7101/45 (fidonet)
            The Catacomb BBS 80:80/100 (pipemail)
*)

INTERFACE

USES DOS;

FUNCTION GetScanCode: Byte; (* Get SCAN CODE from buffer, wait if empty *)
FUNCTION GetKey: Char;      (* Get Char from buffer, do NOT wait *)
PROCEDURE FlushKB;

IMPLEMENTATION

FUNCTION GetKey: Char;
 VAR Regs: Registers;
 BEGIN
   Regs. AH := 1;                (* Int 16 function 1 *)
   Intr ($16, Regs);           (* Read a charecter from the keyboard buffer *)
   GetKey := Chr (Regs. AL);     (* do not wait. If no char was found, CHR(0) *)
 END;                        (* (nul) is returned *)

FUNCTION GetScanCode: Byte;   (* Int 16 function 0 *)
 VAR Regs: Registers;         (* The same as CRT's Readkey, but gives you *)
 BEGIN                      (* the scan code. Esp usefull when you want to *)
   Regs. AH := 1;               (* use special keys as the arrows, there will *)
   Intr ($16, Regs);          (* be a conflict when using ReadKey *)
   GetScanCode := Regs. AH;
 END;

PROCEDURE FlushKB;           (* INT 21 function 0C *)
 VAR Regs: Registers;         (* Flushes (erase) the keyboard buffer *)
 BEGIN                      (* ONLY. No other function is executed *)
   Regs. AH := $0C;
   Regs. AL := 2;
   Intr ($21, Regs);
 END;

END.

{CUT OFF...}


{CUT... Save this as SCANCODE.PAS}

UNIT ScanCode;

{ This UNIT is created by Wayne Boyd, aka Vipramukhya Swami, BBS phone
   (604)431-6260, Fidonet node 1:153/763. It's function is to facilitate
   the use of Function keys and Alt keys in a program. It includes F1
   through F10, Shift-F1 through Shift-F10, Ctrl-F1 through Ctrl-F10,
   and Alt-F1 through Alt-F10. It also includes all of the alt keys, all
   of the Ctrl keys and many other keys as well. This UNIT and source code
   are copyrighted material and may not be used for commercial use
   without express written permission from the author. Use at your own
   risk. I take absolutely no responsibility for it, and there are no
   guarantees that it will do anything more than take up space on your
   disk. }


INTERFACE

CONST
  
  F1  = 59;   CtrlF1  =  94;   AltF1  = 104;   Homekey   = 71;
  F2  = 60;   CtrlF2  =  95;   AltF2  = 105;   Endkey    = 79;
  F3  = 61;   CtrlF3  =  96;   AltF3  = 106;   PgUp      = 73;
  F4  = 62;   CtrlF4  =  97;   AltF4  = 107;   PgDn      = 81;
  F5  = 63;   CtrlF5  =  98;   AltF5  = 108;   UpArrow   = 72;
  F6  = 64;   CtrlF6  =  99;   AltF6  = 109;   RtArrow   = 77;
  F7  = 65;   CtrlF7  = 100;   AltF7  = 110;   DnArrow   = 80;
  F8  = 66;   CtrlF8  = 101;   AltF8  = 111;   LfArrow   = 75;
  F9  = 67;   CtrlF9  = 102;   AltF9  = 112;   InsertKey = 82;
  F10 = 68;   CtrlF10 = 103;   AltF10 = 113;   DeleteKey = 83;
  
  AltQ = 16;   AltA = 30;   AltZ = 44;   Alt1 = 120;  ShftF1 = 84;
  AltW = 17;   AltS = 31;   AltX = 45;   Alt2 = 121;  ShftF2 = 85;
  AltE = 18;   AltD = 32;   AltC = 46;   Alt3 = 122;  ShftF3 = 86;
  AltR = 19;   AltF = 33;   AltV = 47;   Alt4 = 123;  ShftF4 = 87;
  AltT = 20;   AltG = 34;   AltB = 48;   Alt5 = 124;  ShftF5 = 88;
  AltY = 21;   AltH = 35;   AltN = 49;   Alt6 = 125;  ShftF6 = 89;
  AltU = 22;   AltJ = 36;   AltM = 50;   Alt7 = 126;  ShftF7 = 90;
  AltI = 23;   AltK = 37;                Alt8 = 127;  ShftF8 = 91;
  AltO = 24;   AltL = 38;                Alt9 = 128;  ShftF9 = 92;
  AltP = 25;   CtrlLf = 115;             Alt0 = 129;  ShftF10 = 93;
  CtrlRt = 116;
  
  CtrlA  = #1;  CtrlK = #11; CtrlU = #21; CtrlB = #2;  CtrlL = #12;
  CtrlV  = #22; CtrlC = #3;  CtrlM = #13; CtrlW = #23; CtrlD = #4;
  CtrlN  = #14; CtrlX = #24; CtrlE = #5;  CtrlO = #15; CtrlY = #25;
  CtrlF  = #6;  CtrlP = #16; CtrlZ = #26; CtrlG = #7;  CtrlQ = #17;
  CtrlS  = #19; CtrlH = #8;  CtrlR = #18; CtrlI = #9;  CtrlJ = #10;
  CtrlT = #20;  BSpace = #8; EscapeKey = #27; EnterKey = #13; NullKey = #0;
  
IMPLEMENTATION

END.

{CUT OFF...}

