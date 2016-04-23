{
Here's the source of a seven segment display useful to place at the end
of your autoexec if you also have the habit of turning your computer on
long before using it or want an expensive clock (works then best on a
66Mhz DX2 or Pentium).


The BGI_01 unit just links in the BGI driver. If removed you'll have to
supply EGAVGA.BGI in the current directory (Or get the source of the
unit from a previous message).


Start it with SEGMENT 15 and a bright yellow clock will appear.


-------------------------<cut here

{---------------------------------------------------------}
{  Project : Seven Segment Display                        }
{  Auteur  : Ir. G.W. van der Vegt                        }
{---------------------------------------------------------}
{  Datum .tijd  Revisie                                   }
{  901025.2000  Creatie.                                  }
{---------------------------------------------------------}

PROGRAM Segment(INPUT,OUTPUT);

USES
  CRT,
  DOS,
  GRAPH,
  BGI_01;

VAR
  cl : INTEGER;

{---------------------------------------------------------}
{----Routine to display ASCII as seven segment LED display}
{---------------------------------------------------------}

PROCEDURE Segments(nch,och : CHAR;xc,yc : INTEGER;scale : REAL);

{---------------------------------------------------------}
{----Types & const for graphical LED segment definition   }
{---------------------------------------------------------}

TYPE
  seg = ARRAY[1..7] OF Pointtype;

CONST
  Ver   : seg = ((x :   1; y :   0),(x :   0; y :   1),
                 (x :   0; y :   9),(x :   1; y :  10),
                 (x :   2; y :   9),(x :   2; y :   1),
                 (x :   1; y :   0)                  );

  Hor   : seg = ((x :   0; y :   1),(x :   1; y :   0),
                 (x :   9; y :   0),(x :  10; y :   1),
                 (x :   9; y :   2),(x :   1; y :   2),
                 (x :   0; y :   1)                  );

  DPdot : seg = ((x :   1; y :   1),(x :   2; y :   0),
                 (x :   2; y :   1),(x :   2; y :   2),
                 (x :   1; y :   2),(x :   0; y :   2),
                 (x :   1; y :   1)                   );

  SCDot : seg = ((x :   4; y :   4),(x :   4; y :   6),
                 (x :   6; y :   6),(x :   6; y :   4),
                 (x :   4; y :   4),(x :   4; y :   4),
                 (x :   4; y :   4)                   );

Type
  dir  = (vertical,horizontal,decimal,dot);

{---------------------------------------------------------}
{----Routine to hide/display a segment                    }
{---------------------------------------------------------}

PROCEDURE Dispsegm(dir : dir;show : BOOLEAN; m,dx,dy : REAL);

VAR
  segm : seg;
  i    : INTEGER;

BEGIN
  CASE dir OF
    vertical   : segm:=ver;
    horizontal : segm:=hor;
    decimal    : segm:=DPdot;
    dot        : segm:=SCdot;
  END;

  FOR i:=1 TO 7 DO
    BEGIN
      segm[i].x:=TRUNC((segm[i].x+dx)*m)+xc;
      segm[i].y:=TRUNC((segm[i].y+dy)*m)+yc;
    END;

  IF show
    THEN setfillstyle(solidfill,cl)
    ELSE setfillstyle(solidfill,black);

  Fillpoly(7,segm);
END;

{---------------------------------------------------------}
{----Types & Const for 7 segment display codes definitions}
{---------------------------------------------------------}

TYPE
  leds  = (a,b,c,d,e,f,g,dp,dl,dh);
  offst = RECORD
            dx,dy : REAL;
            d     : dir;
          END;
  disp  = SET OF leds;

CONST
  rel : ARRAY[leds] OF offst =
        ((dx : 1.0;dy : 0.0; d : horizontal),
         (dx : 0.0;dy : 1.0; d : vertical  ),
         (dx : 0.0;dy :11.0; d : vertical  ),
         (dx : 1.0;dy :20.0; d : horizontal),
         (dx :10.0;dy :11.0; d : vertical  ),
         (dx :10.0;dy : 1.0; d : vertical  ),
         (dx : 1.0;dy :10.0; d : horizontal),
         (dx :11.0;dy :21.0; d : decimal   ),
         (dx : 1.0;dy : 1.0; d : dot       ),
         (dx : 1.0;dy :11.0; d : dot       ));

{---------------------------------------------------------}
{----Routine to convert ASCII to 7 segments               }
{---------------------------------------------------------}

PROCEDURE Calcleds(ch : CHAR;VAR sseg : disp);

BEGIN
  CASE ch OF
    '0' : sseg:=[a,b,c,d,e,f];
    '1' : sseg:=[e,f];
    '2' : sseg:=[a,c,d,f,g];
    '3' : sseg:=[a,d,e,f,g];
    '4' : sseg:=[b,e,f,g];
    '5' : sseg:=[a,b,d,e,g];
    '6' : sseg:=[a,b,c,d,e,g];
    '7' : sseg:=[a,e,f];
    '8' : sseg:=[a,b,c,d,e,f,g];
    '9' : sseg:=[a,b,d,e,f,g];
    '-' : sseg:=[g];
    '-' : sseg:=[d];
    '^' : sseg:=[a];
    ':' : sseg:=[dl,dh];
    '≡' : sseg:=[a,d,g];
    '.' : sseg:=[dp];
  ELSE sseg:=[];
  END;
END;

VAR
  led     : leds;
  oseg,
  nseg,
  offseg,
  onseg   : disp;

BEGIN
  Setcolor(DarkGray);

  IF (nch=#0) AND (och=#0)
    THEN
      BEGIN
        offseg:=[a,b,c,d,e,f,g,dp,dl,dh];
        onseg :=[];
      END
    ELSE
      BEGIN
        Calcleds(och,oseg);
        Calcleds(nch,nseg);

        onseg :=nseg-oseg-oseg*nseg;    {----Leds to turn on }
        offseg:=oseg-nseg-oseg*nseg;    {----Leds to turn off}
      END;

  FOR led:=a TO dh DO
    WITH rel[led] DO
      BEGIN
        IF led IN  onseg THEN Dispsegm(d, true,scale,dx,dy);
        IF led IN offseg THEN Dispsegm(d,false,scale,dx,dy);
      END;
END;

{---------------------------------------------------------}
{----Prints error msg & halts program                     }
{---------------------------------------------------------}

PROCEDURE Error(s : STRING);

BEGIN
  CLRSCR;
  WRITELN;
  WRITELN('SYNTAX : Segment <color>');
  WRITELN;
  WRITELN('ERROR    ',s);
  WRITELN;
  HALT;
END;

{---------------------------------------------------------}
{----Main Program                                         }
{---------------------------------------------------------}

VAR
  tmp,
  h,m,s,ms : WORD;
  i,e      : INTEGER;

  c1,c2,c3 : STRING[2];

  olds,
  news     : STRING;

  grdriver,
  grmode,
  errcode : INTEGER;

  r       : REGISTERS;
  oldstate: BYTE;

{---------------------------------------------------------}

BEGIN

  Grdriver:=detect;
  DetectGraph(grdriver,grmode);

{----Allow segment color to be chosen by user}
  IF (PARAMCOUNT=1)
    THEN
      BEGIN
        VAL(PARAMSTR(1),cl,e);
        IF (e<>0) THEN Error('Incorrcet Parameter');
      END
    ELSE
      CASE grdriver OF
        mcga,
        egamono : cl:=1;
        ega64   : cl:=3;
        ega,
        vga     : cl:=15;
      END;

  CASE grdriver OF
    mcga    : IF NOT (cl IN [1])
                THEN Error('With MCGA only color 1 is allowed');
    ega64   : IF NOT (cl IN [1..3])
                THEN Error('With 64 K EGA only colors 1..4 are allowed');
    egamono : IF NOT (cl IN [1])
                THEN Error('With EGA mono only color 1 is allowed');
    ega     : IF NOT (cl IN [1..15])
                THEN Error('With 256 K EGA only colors 1..15 are allowed');
    vga     : IF NOT (cl IN [1..15])
                THEN Error('With VGA only colors 1..15 are allowed');
  ELSE Error('Graphics Adapter NOT Supported');
  END;

  Initgraph(grdriver,grmode,'');
  errcode:=Graphresult;

  news:='        ';
  olds:='        ';

  FOR i:=1 TO LENGTH(news) DO Segments(#0,#0,80*(i-1),80,6.0);

  r.ah:=$02;
  INTR($16,r);

  REPEAT
    oldstate:=r.al;

    GETTIME(h,m,s,ms);

    STR(h:2,c1);
    STR(m:2,c2);
    STR(s:2,c3);

    IF Odd(s)
      THEN news:=c1+':'+c2+':'+c3
      ELSE news:=c1+' '+c2+' '+c3;

    IF (news[1]=' ') THEN news[1]:='0';
    IF (news[4]=' ') THEN news[4]:='0';
    IF (news[7]=' ') THEN news[7]:='0';

  {----Write only the changed segments in all displays}
    FOR i:=1 TO LENGTH(news) DO Segments(news[i],olds[i],80*(i-1),80,6.0);

    olds:=news;

    Delay(100);

{----Not only wait for normal keypressed but also for
     shift/alt/ctrl or insert/numlock/scrollock keys pressed}
    r.ah:=$02;
    INTR($16,r);

  UNTIL (r.al<>oldstate) OR (KEYPRESSED AND (READKEY<>#255));

  Closegraph;

END. {of segment}


> I would like to include a clock in my current project which will be
> updated once a minute.  Instead of constantly checking the computer's clock
> and waiting for it to change, I would like to use an interrupt.

This one has even a hot key handler.  If you want to update it once per
minute, bump a counter within the interrupt 1Ch handler till it reaches the
value 60*18.2.  Then refresh the screen.
}

Program Clock;

{$G+,R-,S-,M 1024, 0, 0 }

uses
  Dos;

Const
  x           = 71;                   { x location on screen }
  y           = 1;                    { y location on screen }
  Keyboard    = 9;                    { Hardware keyboard interrupt }
  TimerTick   = $1C;                  { Gets called 18.2 / second }
  VideoOffset = 160 * (y - 1) + 2 * x;{ Offset in display memory }
  yellow      = 14;
  blue        = 1;
  attribute   = blue * 16 + yellow;   { Clock colours }
  VideoBase   : Word = $B800;         { Segment of display memory }
  ActiveFlag  : ShortInt = -1;        { 0: on, -1: off }

Var
  OrgInt9,                             { Saved interrupt 9 vector }
  OrgInt1Ch : Pointer;              { Saved interrupt 1Ch vector }
  VideoMode : Byte absolute $0000:$0449;

{ Display a string using Dos services (avoid WriteLn, save memory) }

Procedure DisplayString(s : String); Assembler;

ASM
  PUSH   DS
  XOR    CX, CX
  LDS    SI, s
  LODSB
  MOV    CL, AL
  JCXZ   @EmptyString
  CLD
 @NextChar:
  LODSB
  XCHG   AX, DX
  MOV    AH, 2
  INT    21h
  LOOP   @NextChar
 @EmptyString:
  POP    DS
end;

{ Returns True if a real time clock could be found }
Function HasRTClock : Boolean; Assembler;

ASM
  XOR    AL, AL
  MOV    AH, 2
  INT    1Ah
  JC     @NoRTClock
  INC    AX
 @NoRTCLock:
end;

{ Release Dos environment }
Procedure ReleaseEnvironment; Assembler;
ASM
  MOV    ES, [PrefixSeg]
  MOV    ES, ES:[002Ch]
  MOV    AH, 49h
  INT    21h
end;

{ INT 9 handler intercepting Alt-F11 }
Procedure ToggleClock; Interrupt; Assembler;
Const
  F11      = $57;                  { 'F11' make code }
  BiosSeg  = $40;                  { Segment of BIOS data area }
  AltMask  = $08;                  { Bitmask of Alt key }
  KbdFlags = $17;                  { Byte showing keyboard status }

ASM
  STI
  IN     AL, 60h

 { F11 pressed? }
  CMP    AL, F11
  JNE    @PassThru

 { Alt-key pressed? }
  PUSH   BiosSeg
  POP    ES
  MOV    AL, ES:[KbdFlags]
  AND    AL, AltMask
  CMP    AL, AltMask
  JNE    @PassThru

 { Flip status flag, force EOI and leave routine }
  NOT    [ActiveFlag]
  IN     AL, 61h
  MOV    AH, AL
  OR     AL, 80h
  OUT    61h, AL
  MOV    AL, AH
  OUT    61h, AL
  CLI
  MOV    AL, 20h
  OUT    20h, AL
  STI
  JMP    @Exit

 @PassThru:
  CLI
  PUSHF
  CALL   DWord Ptr [OrgInt9]
 @Exit:
end;  { ToggleClock }

{ Convert a packed BCD byte to ASCII character }
Procedure Digit; Assembler;
ASM
  PUSH   AX
  CALL   @HiNibble
  POP    AX
  CALL   @LoNibble
  RETN

 @HiNibble:
  SHR    AL, 4
  JMP    @MakeAscii
 @LoNibble:
  AND    AL, 0Fh
 @MakeAscii:
  OR     AL, '0'
  STOSW
end;

{ INT 1Ch handler that displays a clock on the right hand side of the screen }
Procedure DisplayClock; Interrupt; Assembler;
ASM
  CMP    [ActiveFlag], 0
  JNE    @Exit
  CLD
  MOV    AH, 2
  INT    1Ah
  MOV    ES, [VideoBase]
  MOV    DI, VideoOffset
  MOV    AH, attribute
  MOV    AL, CH
  CALL   Digit
  MOV    AL, ':'
  STOSW
  MOV    AL, CL
  CALL   Digit
  MOV    AL, ':'
  STOSW
  MOV    AL, DH
  CALL   Digit
  PUSHF
  CALL   DWord Ptr [OrgInt1Ch]
 @Exit:
end;

Begin
  If VideoMode = 7 Then
    VideoBase := $B000;
  GetIntVec(TimerTick, OrgInt1Ch);
  SetIntVec(TimerTick, @DisplayClock);
  GetIntVec(Keyboard, OrgInt9);
  SetIntVec(Keyboard, @ToggleClock);
  SwapVectors;
  ReleaseEnvironment;
  DisplayString('CLOCK installed.  <Alt-F11> toggles on/off');
  Keep(0);
end.
