{
{TEXT EFFECTS, otherwise known as TextFX, is a pascal unit, created in
{TURBO Pascal 4.0".  It's sole purpose is to add a little flair to text
{based pascal programs.  This is done via binary files, that can be made
{in pascal and saved to disk using the included SaveScreen procedure, or
{made in any text image design program that will save its data as a binary
{file, such as "TheDraw", by TheSoft Programming Services.
{
{
{
{This is a first release, and as such, is not certified to be error free
{and I shall take no responsibility for ANY damages caused by using this
{Unit.
{
{To all programmers:  This unit isn't all that fancy (YET) but, if it
{helps you to make a living, I'd appreciate it if you'd help me make my
{own.  Ideally this would be entail recognition in your final product, as
{well as a financial contribution that reflects how useful/profitable you
{found the unit to be.  Also acceptible would be one or the other as both
{are of great help.  ThanX.
{
{I am always looking for more text effects for upcoming versions, so if
{you think of something, drop me a line.  Don't forget to include your
{name or I won't be able to give you any credit for it.  Please note that
{credit will be given only once for each effect.  If two messages com in
{detailing the same effect, credit will go to the first I come across.
{
{Here's my address:
{
{   Tony Peardon
{   Comp 1, RR 2, Erb Site,
{   Quesnel BC, Canada.
{   V2J-3H6
{
{Or I can be reached in the Pascal Programmers Echo....
{
{
{ ...And so, without further adu... I present TextFX!!
}
UNIT TextFX;  {Version 1.00 - By Tony Peardon         (Mar.14`95) }

INTERFACE

USES Dos, Crt;

TYPE
  PageType = ARRAY[1..25,1..80] OF RECORD
                                    Char: char;
                                    Attr: byte;
                                  END;

  FlipMethod = (DragLeft,DragRight,DragUp,DragDown,
                PushLeft,PushRight,PushUp,PushDown,
                PullLeft,PullRight,PullUp,PullDown,
                ScanLeft,ScanRight,ScanUp,ScanDown,

                DragHSides,DragHCenter,DragVSides,DragVCenter,
                PushHSides,PushHCenter,PushVSides,PushVCenter,
                PullHSides,PullHCenter,PullVSides,PullVCenter,
                ScanHSides,ScanHCenter,ScanVSides,ScanVCenter,

                PushRand,PullRand,ScanRand,DragRand,AllRand);

VAR
  Monitor: PageType absolute $B800:$0000; {Change to $B000:$0000 FOR MONO}


PROCEDURE SaveScreen(VAR Screen: PageType; FileName: String);
PROCEDURE LoadScreen(VAR Screen: PageType; FileName: String);
PROCEDURE MoveBlock(VAR Source, Destin: PageType;
                     X1,Y1,X2,Y2,DX,DY: integer);
PROCEDURE PageFlip(ToPage: PageType; Method: FlipMethod);




IMPLEMENTATION

PROCEDURE ErrorCheck;
{
{ Echos an error message if any errors are encountered
{ during I/O operations.
}
VAR
  Key: Char;
BEGIN
  IF DosError = 0 THEN exit;
  gotoxy(1,25);
  write('ERROR #',DosError,': ');
  CASE DosError OF
    2:write('File Not Found.');
    3:write('Path Not Found.');
    5:write('Access Denied.');
    6:write('Invalid Handle.');
    8:write('Not Enough Memory.');
    10:write('Invalid Environment.');
    11:write('Invalid Format.');
    18:write('File Not Found.');
  END;
  IF NOT DosError IN [2,3,5,6,8,10,11,18] THEN write('Unknown Error.');
  write(#7,#7,#7);
  delay(500);
  write(' --- Press Any Key ---');
  WHILE KeyPressed DO Key := ReadKey;
  REPEAT UNTIL KeyPressed;
  halt;
END;

PROCEDURE SaveScreen(VAR Screen: PageType; FileName: String);
{
{ Saves an 80/25 screen to a binary file
}

VAR
  Saving: File;
  Search:SearchRec;
BEGIN
  assign(Saving,FileName);
{$I-}
  rewrite(Saving,4000); ErrorCheck;
  blockwrite(Saving,Screen,1);  ErrorCheck;
  close(Saving);  ErrorCheck;
{$I+}
END;


PROCEDURE LoadScreen(VAR Screen: PageType; FileName: String);
{
{ Loads an 80/25 screen from a file
}
VAR
  Loading: File;
  Search: SearchRec;
BEGIN
  assign(Loading,FileName);
{$I-}
  findfirst(FileName,AnyFile,Search);  ErrorCheck;
  reset(Loading,4000); ErrorCheck;
  blockread(Loading,Screen,1);  ErrorCheck;
  close(Loading);  ErrorCheck;
{$I+}
END;

PROCEDURE MoveBlock(VAR Source, Destin: PageType;
                    X1,Y1,X2,Y2,DX,DY: integer);
{
{  Moves a block of binary information from one page to another.
{  Note that DX and DY refer to the top left point on the desti-
{  nation page where the defined block will begin to be displayed.
}
VAR
  YRange, YCount, XSize: integer;
  Temp: PageType;
BEGIN
  YRange := Y2 - Y1;
  XSize := (X2 - X1+1)*2;
  FOR YCount := 0 TO YRange DO BEGIN
    move(Source[Y1+YCount,X1],Temp[DY+YCount,DX],XSize);
  END;
  Destin := Temp;
END;


PROCEDURE PageFlip(ToPage: PageType; Method: FlipMethod);
{
{  A collection of fancy page flipping routines following one of
{  four basic styles.
{
{   PUSH: Pushes 'ToPage' over the current page.
{   PULL: Pulls the current page revealing 'ToPage' beneith.
{   SCAN: Replaces Each Position.
{   DRAG: Pulls the current page and drags 'To Page' behind it.
}
VAR
  C1,C2: integer;  {Counters}
BEGIN
  IF Method = AllRand THEN CASE random(4) OF
    0: Method := ScanRand;
    1: Method := PushRand;
    2: Method := PullRand;
    3: Method := DragRand;
  END;
  IF Method IN[ScanRand,PushRand,PullRand,DragRand] THEN BEGIN
    IF Method = ScanRand THEN BEGIN
      CASE random(8) OF
        0: Method := ScanUp;
        1: Method := ScanDown;
        2: Method := ScanLeft;
        3: Method := ScanRight;
        4: Method := ScanHCenter;
        5: Method := ScanHSides;
        6: Method := ScanVCenter;
        7: Method := ScanVSides;
      END;
    END;
    IF Method = PullRand THEN BEGIN
      CASE random(8) OF
        0: Method := PullUp;
        1: Method := PullDown;
        2: Method := PullLeft;
        3: Method := PullRight;
        4: Method := PullHCenter;
        5: Method := PullHSides;
        6: Method := PullVCenter;
        7: Method := PullVSides;
      END;
    END;
    IF Method = PushRand THEN BEGIN
      CASE random(8) OF
        0: Method := PushUp;
        1: Method := PushDown;
        2: Method := PushLeft;
        3: Method := PushRight;
        4: Method := PushHCenter;
        5: Method := PushHSides;
        6: Method := PushVCenter;
        7: Method := PushVSides;
      END;
    END;
    IF Method = DragRand THEN BEGIN
      CASE random(8) OF
        0: Method := DragUp;
        1: Method := DragDown;
        2: Method := DragLeft;
        3: Method := DragRight;
        4: Method := DragHCenter;
        5: Method := DragHSides;
        6: Method := DragVCenter;
        7: Method := DragVSides;
      END;
    END;
  END;
  CASE Method OF

    DragLeft:     BEGIN
                    FOR C1 := 1 TO 80 DO BEGIN
                      moveblock(Monitor,Monitor,2,1,80,25,1,1);
                      moveblock(ToPage,Monitor,C1,1,C1,25,80,1);
                    END;
                  END;
    DragRight:    BEGIN
                    FOR C1 := 80 DOWNTO 1 DO BEGIN
                      moveblock(Monitor,Monitor,1,1,79,25,2,1);
                      moveblock(ToPage,Monitor,C1,1,C1,25,1,1);
                    END;
                  END;
    DragUp:       BEGIN
                    FOR C1 := 1 TO 25 DO BEGIN
                      moveblock(Monitor,Monitor,1,2,80,25,1,1);
                      moveblock(ToPage,Monitor,1,C1,80,C1,1,25);
                    END;
                  END;
    DragDown:     BEGIN
                    FOR C1 := 25 DOWNTO 1 DO BEGIN
                      moveblock(Monitor,Monitor,1,1,80,24,1,2);
                      moveblock(ToPage,Monitor,1,C1,80,C1,1,1);
                    END;
                  END;
    DragHSides:   BEGIN
                    C1 := 0;
                    C2 := 81;
                    REPEAT
                      C1 := C1 + 1;
                      C2 := C2 - 1;
                      moveblock(Monitor,Monitor,2,1,40,25,1,1);
                      moveblock(Monitor,Monitor,41,1,79,25,42,1);
                      moveblock(ToPage,Monitor,C1,1,C1,25,40,1);
                      moveblock(ToPage,Monitor,C2,1,C2,25,41,1);
                    UNTIL C1 = 40;
                  END;
    DragHCenter:  BEGIN
                    C1 := 41;
                    C2 := 40;
                    REPEAT
                      C1 := C1 - 1;
                      C2 := C2 + 1;
                      moveblock(Monitor,Monitor,1,1,40,25,2,1);
                      moveblock(Monitor,Monitor,42,1,80,25,41,1);
                      moveblock(ToPage,Monitor,C1,1,C1,25,1,1);
                      moveblock(ToPage,Monitor,C2,1,C2,25,80,1);
                    UNTIL C2 = 80;
                  END;
    DragVSides:   BEGIN
                  {Not advailable till the next release}
                  END;
    DragVCenter:  BEGIN
                  {Not advailable till the next release}
                  END;


    PushLeft:     BEGIN
                    FOR C1 := 1 TO 80 DO BEGIN
                      moveblock(ToPage,Monitor,1,1,C1,25,81-C1,1);
                    END;
                  END;
    PushRight:    BEGIN
                    FOR C1 := 80 DOWNTO 1 DO BEGIN
                      moveblock(ToPage,Monitor,C1,1,80,25,1,1);
                    END;
                  END;
    PushUp:       BEGIN
                    FOR C1 := 1 TO 25 DO BEGIN
                      moveblock(ToPage,Monitor,1,1,80,C1,1,26-C1);
                    END;
                  END;
    PushDown:     BEGIN
                    FOR C1 := 25 DOWNTO 1 DO BEGIN
                      moveblock(ToPage,Monitor,1,C1,80,25,1,1);
                    END;
                  END;
    PushHSides:   BEGIN
                    C1 := 0;
                    C2 := 81;
                    REPEAT
                      C1 := C1 + 1;
                      C2 := C2 - 1;
                      moveblock(ToPage,Monitor,1,1,C1,25,41-C1,1);
                      moveblock(ToPage,Monitor,C2,1,80,25,41,1);
                    UNTIL C1 = 40;
                  END;
    PushHCenter:  BEGIN
                    C1 := 41;
                    C2 := 40;
                    REPEAT
                      C1 := C1 - 1;
                      C2 := C2 + 1;
                      moveblock(ToPage,Monitor,C1,1,40,25,1,1);
                      moveblock(ToPage,Monitor,41,1,C2,25,80-(C2-41),1);
                    UNTIL C1 = 1;
                  END;
    PushVSides:   BEGIN
                  {Not advailable till the next release}
                  END;
    PushVCenter:  BEGIN
                  {Not advailable till the next release}
                  END;
    ScanLeft:     BEGIN
                    FOR C1 := 80 DOWNTO 1 DO BEGIN
                      moveblock(ToPage,Monitor,C1,1,C1,25,C1,1);
                    END;
                  END;
    ScanRight:    BEGIN
                    FOR C1 := 1 TO 80 DO BEGIN
                      moveblock(ToPage,Monitor,C1,1,C1,25,C1,1);
                    END;
                  END;
    ScanUp:       BEGIN
                    FOR C1 := 25 DOWNTO 1 DO BEGIN
                      moveblock(ToPage,Monitor,1,C1,80,C1,1,C1);
                    END;
                  END;
    ScanDown:     BEGIN
                    FOR C1 := 1 TO 25 DO BEGIN
                      moveblock(ToPage,Monitor,1,C1,80,C1,1,C1);
                    END;
                  END;
    ScanHSides:   BEGIN
                    C1 := 0;
                    C2 := 81;
                    REPEAT
                      C1 := C1 + 1;
                      C2 := C2 - 1;
                      moveblock(ToPage,Monitor,C1,1,C1,25,C1,1);
                      moveblock(ToPage,Monitor,C2,1,C2,25,C2,1);
                    UNTIL C1 = 40;
                  END;
    ScanHCenter:  BEGIN
                    C1 := 41;
                    C2 := 40;
                    REPEAT
                      C1 := C1 - 1;
                      C2 := C2 + 1;
                      moveblock(ToPage,Monitor,C1,1,C1,25,C1,1);
                      moveblock(ToPage,Monitor,C2,1,C2,25,C2,1);
                    UNTIL C2 = 80;
                  END;
    ScanVSides:   BEGIN
                  {Not advailable till the next release}
                  END;
    ScanVCenter:  BEGIN
                  {Not advailable till the next release}
                  END;


    PullLeft:     BEGIN
                    FOR C1 := 80 DOWNTO 1 DO BEGIN
                      moveblock(Monitor,Monitor,2,1,C1,25,1,1);
                      moveblock(ToPage,Monitor,C1,1,C1,25,C1,1);
                    END;
                  END;
    PullRight:    BEGIN
                    FOR C1 := 1 TO 80 DO BEGIN
                      moveblock(Monitor,Monitor,C1,1,79,25,C1+1,1);
                      moveblock(ToPage,Monitor,C1,1,C1,25,C1,1);
                    END;
                  END;
    PullUp:       BEGIN
                    FOR C1 := 25 DOWNTO 1 DO BEGIN
                      moveblock(Monitor,Monitor,1,2,80,C1,1,1);
                      moveblock(ToPage,Monitor,1,C1,80,C1,1,C1);
                    END;
                  END;
    PullDown:     BEGIN
                    FOR C1 := 1 TO 25 DO BEGIN
                      moveblock(Monitor,Monitor,1,C1,80,24,1,C1+1);
                      moveblock(ToPage,Monitor,1,C1,80,C1,1,C1);
                    END;
                  END;
    PullHSides:   BEGIN
                    C1 := 41;
                    C2 := 40;
                    REPEAT
                      C1 := C1 - 1;
                      C2 := C2 + 1;
                      moveblock(Monitor,Monitor,2,1,C1,25,1,1);
                      moveblock(Monitor,Monitor,C2,1,79,25,C2+1,1);
                      moveblock(ToPage,Monitor,C1,1,C2,25,C1,1);
                    UNTIL C1 = 1;
                  END;
    PullHCenter:  BEGIN
                    C1 := 0;
                    C2 := 81;
                    REPEAT
                      C1 := C1 + 1;
                      C2 := C2 - 1;
                      moveblock(Monitor,Monitor,C1,1,39,25,C1+1,1);
                      moveblock(Monitor,Monitor,42,1,C2,25,41,1);
                      moveblock(ToPage,Monitor,C1,1,C1,25,C1,1);
                      moveblock(ToPage,Monitor,C2,1,C2,25,C2,1);
                    UNTIL C1 = 40;
                  END;
    PullVSides:   BEGIN
                  {Not advailable till the next release}
                  END;
    PullVCenter:  BEGIN
                  {Not advailable till the next release}
                  END;

  END;
END;

BEGIN
END.

PROGRAM TestFx;
USES TextFX, Crt;
{ Compile this little program into an EXE and run it with two
{ command line parameters.  Both parameters should be the path
{ and name of two binary text screen files.  Such as those created
{ by the draw.
{
{ NOTE: Esc will end the Demonstration
}

VAR
  Page: ARRAY[0..2] OF PageType;
  Counter: integer;
  Key: char;

BEGIN
  Page[0] := Monitor;
  LoadScreen(Page[1],paramstr(1));
  LoadScreen(Page[2],paramstr(2));
  REPEAT
    WHILE KeyPressed DO Key := ReadKey;
    IF Counter = 1 THEN Counter := 2 ELSE Counter := 1;
    PageFlip(Page[Counter],AllRand);
  UNTIL Key = #27;
  PageFlip(Page[0],AllRand);
END.
