{
 TF> Hello . How Are YOU doing.

 TF> I have some trouble and i'm wondering if you can help me.
 TF> Can you write a little program that showes ansi-pics under
 TF> Turbo Pascal 7.

Here's a UNIT of mine that interprets and displays ANSI files:

----------------------------------------------- }
{Written by Mike Phillips 12-01-93}

UNIT ANSI;
INTERFACE

USES crt,dos;


VAR
  speed : integer;

FUNCTION Min(X,Y : integer):integer;
FUNCTION Max(X,Y : INTEGER) : INTEGER;


TYPE
  charset = set of char;
  TANSiView = object
    ANSiParams : array [byte] of byte;
    ANSiNum : byte;
    errornum : integer;
    ANSiType : char;
    ANS : text;
    ANSiStr : string;
    ESCChars : charset;
    blinkin,high : boolean;
    fore,back,temp : word;
    constructor init;
    procedure attrib; virtual;
    procedure parse; virtual;
    procedure read_file (fn:string); virtual;
    procedure err; virtual;
    destructor done; virtual;
  end; (* of object *)



IMPLEMENTATION

FUNCTION Min(X,Y : INTEGER) : INTEGER; ASSEMBLER;
ASM
   MOV   AX,X
   CMP   AX,Y
   JLE   @@1
   MOV   AX,Y
@@1:
END;

FUNCTION Max(X,Y : INTEGER) : INTEGER; ASSEMBLER;
ASM
   MOV   AX,X
   CMP   AX,Y
   JGE   @@1
   MOV   AX,Y
@@1:
END;


constructor TANSiView.Init;
begin
  clrscr;
  blinkin := false;
  high := false;
  fore := 7;
  back := 0;
  ESCChars :=
['H','f','A','B','C','D','s','u','J','K','m','h','l','p','@',#14];end; (* of
constructor TANSiVeiw.Init *)
procedure TANSiView.attrib;
var
  count : byte;
begin
  FOR count := 1 TO ANSiParams [0] DO begin
    case ANSiParams [count] of
      0 : begin
            blinkin := false;
            high := false;
            fore := 7;
            back := 0;
            end;
      1 : high := true;
      4,7 : begin
              temp := fore;
              fore := back;
              back := temp;
            end;
      5 : blinkin := true;
      8 : fore := back;
      30 : fore := black;
      31 : fore := red;
      32 : fore := green;
      33 : fore := brown;
      34 : fore := blue;
      35 : fore := magenta;
      36 : fore := cyan;
      37 : fore := lightgray;
      40 : back := black;
      41 : back := red;
      42 : back := green;
      43 : back := brown;
      44 : back := blue;
      45 : back := magenta;
      46 : back := cyan;
      47 : back := lightgray;
    end; (* of CASE *)
  END; (* of FOR *)
  if high then fore := fore OR 8;
  if blinkin then textattr := fore + back*16 + 128
  else textattr := fore + back*16;
end; (* of method attrib *)

procedure TANSiView.parse;
type
  tcurpos = record
    x,y : byte
  end; (* of record *)
var
  count : byte;
  tempst : string;
  inpu : char;
  curpos : tcurpos;
begin
  ANSiParams [0] := 0;
  read (ans,inpu);
  if inpu <> '[' then exit;
  WHILE NOT (inpu in ESCChars) DO begin
  read (ans,inpu);
  WHILE NOT (inpu in [';'] + ESCChars) DO begin
    if inpu in ['0'..'9'] then tempst := tempst + inpu;
    read (ans,inpu);
  end; (* of WHILE *)
  val (tempst,ANSiParams[ANSiParams[0]+1],errornum);
  if errornum = 0 then inc (ANSiParams [0]);
  tempst := '';
  if inpu in ESCChars then begin
    case inpu of
      'H','f' : IF ANSiParams[0] = 2 then gotoxy (ANSiParams[2],ANSiParams[1])
                else IF ANSiParams[0] = 0 then gotoxy (1,1)
                else gotoxy (1,ansiparams[1]);
      'A' : IF ANSIParams [0] = 0 then if wherey > 1 then gotoxy (wherex,wherey-1)
      else if wherey > ANSiParams [1] then gotoxy (wherex,wherey-ANSiParams[1])
      else gotoxy (wherex,1);

      'B' : IF ANSiParams [0] = 0 then gotoxy (wherex,wherey+1)
            else gotoxy (wherex,wherey+ANSiParams[1]);

      'C' : IF ANSiParams [0] = 0 then gotoxy (wherex+1,wherey)
            else gotoxy (wherex+ANSiParams[1],wherey);
      'D' : IF ANSIParams [0] = 0 then gotoxy (wherex-1,wherey)
            else if wherex > ANSiParams [1] then gotoxy (wherex -
ANSiParams[1],wherey)            else gotoxy (1,wherey);
      's' : begin
               curpos.x := wherex;
               curpos.y := wherey;
               end;
      'u' : gotoxy (curpos.x,curpos.y);
      'J' : clrscr;
      'K' : clreol;
      'm' : attrib;
    end; (* of case *)
  end; (* of IF *)
  end; (* of WHILE *)
end; (* of method parse *)

procedure TANSiView.read_file (Fn:string);
var
  ch:char;
begin
{$I-}
  ANSiStr := Fn;
  assign (ANS,Fn);
  reset (ANS);
{$I+}
  if ioresult <> 0 then begin
    err;
    exit;
  end;
  read (ANS,ch);
  while not eof (ans) do begin
    delay (speed);
    if ch = #27 then parse
    else write (ch);
    read (ans,ch);
  end; (* of while *)
  close (ans);
end; (* of method read_file *)

procedure TANSiView.err;
begin
  writeln ('File not found');
end;

destructor TANSiView.done;
begin
end;

begin
  speed := 0;
end.

{ TEST PROGRAM ----------------------------------------------}

Use it like :
var
  MyANSI : TANSIView;
  ANSIFile : string;
begin
  write ('Enter the filename to view:  ');
  readln (ANSIFile);
  MyANSI.Read_File (ANSIFile);
end.

You may set the speed variable to slow down the display in order to
emulate various baud rates.  Higher value = slower.

Mike Phillips
INTERNET:  phil4086@utdallas.edu
