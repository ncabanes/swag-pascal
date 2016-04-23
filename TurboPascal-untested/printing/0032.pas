UNIT HPUnit;
{ Handles all aspects of HP LASER JET PRINTERS}

INTERFACE

USES
 Crt,
 Dos;

CONST
 Esc       = #27;
 HPReset   = #27'E';

(* Page sizes... *)
 Executive       = #27'&l1A';
 Letter          = #27'&l2A';
 Legal           = #27'&l3A';
 A4              = #27'&l26A';
 Monarch         = #27'&l80A';
 Commercial10    = #27'&l81A';
 InternationalDL = #27'&l90A';
 InternationalCS = #27'&l91A';

 (* orintation *)

 Portrait  = #27'&l0O';
 Landscape = #27'&l1O';

 (* symbol set... *)

 HpRoman8  = #27'(8U';
 PC8       = #27'(10U';

 (* spacQcing... *)

 Fixed     = #27'(s0P';
 Proportional = #27'(s1P';

 (* style... *)

 Upright   = #27'(s0S';
 Italic    = #27'(s1S';

 (* stroke... *)

 Medium    = #27'(s0B';
 Bold      = #27'(s1B';

 (* typeface... *)

 Lineprinter = #27'(s0T';
 Courier     = #27'(s3T';
 Helv        = #27'(s4T';
 TmsRoman    = #27'(s5T';
 LetterGothic = #27'(s6T';
 Prestige    = #27'(s8T';
 Presentations = #27'(s11T';
 Optima      = #27'(s17T';
 TCGaramond  = #27'(s18T';
 CooperBlack = #27'(s19T';
 CooperBold  = #27'(s20T';
 Broadway    = #27'(s21T';
 BauerBodoniBlackCondensed = #27'(s22T';
 CenturySchoolBook         = #27'(s23T';
 UniversityRoman           = #27'(s24T';

 StartUnderLine = #27'&d0D';
 StopUnderLine = #27'&d@';

(*  functions and procedures ...  *)

FUNCTION  Copies (CopyCount : INTEGER) : STRING;
FUNCTION  LinesPerPage (LineCount : INTEGER) : STRING;
FUNCTION  LinesPerInch (LineCount : INTEGER) : STRING;
FUNCTION  PrimaryPitch (Pitch : INTEGER) : STRING;
FUNCTION  PointSize (Points : REAL) : STRING;
FUNCTION  PitchSize (Pitch : REAL) : STRING;
FUNCTION  AbsHorizPos (Inches : REAL) : STRING;
FUNCTION  AbsVertPos (Inches : REAL) : STRING;
PROCEDURE PlotXY (VAR PrnFile : TEXT;X, Y : REAL);
PROCEDURE PlotX (VAR PrnFile : TEXT; X : REAL);
PROCEDURE PlotY (VAR PrnFile : TEXT;Y : REAL);
FUNCTION  FontId (Id : INTEGER) : STRING;
FUNCTION  FontStatus (ID : INTEGER; Status : CHAR) : STRING;
FUNCTION  FontPrimORSec (ID : INTEGER; Status : CHAR) : STRING;
PROCEDURE DownloadFont (FontFileName : STRING; Id : INTEGER; Status : CHAR;
                        StatusX, StatusY, StatusFore, StatusBack : INTEGER);
PROCEDURE EjectPage (VAR PrnFile : TEXT);

IMPLEMENTATION

CONST
 BlockSize = 4096;

TYPE
 BufferType = ARRAY [0..BlockSize - 1] OF BYTE;

VAR
 St : STRING;

PROCEDURE WriteAT (x, y, f, b : BYTE; s : STRING);

VAR
  cnter  : WORD;
  vidPtr : ^WORD;
  attrib : WORD;

BEGIN
  attrib := SWAP ( (b SHL 4) + f);
  vidptr := PTR ($B800, 2 * (80 * PRED (y) + PRED (x) ) );
  IF lastmode = 7 THEN
     DEC (LONGINT (vidptr), $08000000);  { MONO ?? }
  FOR cnter := 1 TO LENGTH (s) DO
  BEGIN
    vidptr^ := attrib OR BYTE (s [cnter]);
    INC (vidptr);
  END;
END;


FUNCTION Realstr (Num : REAL; D : BYTE) : STRING;
{ Return a string value (width 'w')for the input real ('n') }
  VAR
    Stg : STRING;
  BEGIN
    STR (Num : 10 : D, Stg);
    WHILE Stg [1] = #32 DO DELETE (Stg, 1, 1);
    Realstr := Stg;
  END;

FUNCTION IntStr (Num : LONGINT) : STRING;
  VAR
    Stg : STRING;
  BEGIN
    STR (Num : 10, Stg);
    WHILE Stg [1] = #32 DO DELETE (Stg, 1, 1);
    IntStr := Stg;
  END;


PROCEDURE Dta2Prn (BufferAddr : POINTER;
                   BufferSize : LONGINT); EXTERNAL;

{$L Dta2Prn.OBJ}

FUNCTION Copies;

(* Get the string for the copycount...   *)

BEGIN
 STR (CopyCount, St);
 Copies := Esc + '&l' + St + 'X';
END;

FUNCTION LinesPerPage;

BEGIN
 STR (LineCount, St);
 LinesPerPage := Esc + '&l' + St + 'F';
END;

FUNCTION LinesPerInch;

BEGIN
 STR (LineCount, St);
 LinesPerInch := Esc + '&l' + St + 'D';
END;

FUNCTION PrimaryPitch;

BEGIN
 STR (Pitch, St);
 PrimaryPitch := Esc + '(s' + St + 'H';
END;

FUNCTION PointSize;

BEGIN
 St := RealStr (Points, 2);
 PointSize := Esc + '(s' + St + 'V';
END;

FUNCTION PitchSize;

BEGIN
 St := RealStr (Pitch, 2);
 PitchSize := Esc + '(s' + St + 'H'
END;

FUNCTION AbsHorizPos;

VAR
 Dots : REAL;
 DotSt : STRING;

BEGIN
 Dots := Inches * 300;
 STR (ROUND (Dots), DotSt);
 AbsHorizPos := Esc + '*p' + DotSt + 'X';
END;

FUNCTION AbsVertPos;

VAR
 Dots : REAL;
 DotSt : STRING;

BEGIN
 Dots := Inches * 300;
 STR (ROUND (Dots), DotSt);
 AbsVertPos := Esc + '*p' + DotSt + 'Y';
END;

PROCEDURE PlotXY (VAR PrnFile : TEXT; X, Y : REAL);

BEGIN
 WRITE (PrnFile, AbsHorizPos (X) );
 WRITE (PrnFile, AbsVertPos (Y) );
END;

PROCEDURE PlotX (VAR PrnFile : TEXT; X : REAL);

BEGIN
 WRITE (PrnFile, AbsHorizPos (X) );
END;

PROCEDURE PlotY (VAR PrnFile : TEXT; Y : REAL);

BEGIN
 WRITE (PrnFile, AbsVertPos (Y) );
END;

FUNCTION FontID;

VAR
 IdSt : STRING;

BEGIN
 STR (Id, IdSt);
 FontID := Esc + '*c' + IdSt + 'D';
END;

FUNCTION FontPrimORSec;

(* Is the font you're about to send primary or secondary?  Send  *)
(*   the function 'P' or 'S'                                     *)

VAR
 IdSt : STRING;

BEGIN
 Status := UPCASE (Status);
 STR (Id, IdSt);
 CASE Status OF
  'P' : FontPrimORSec := Esc + '(' + IdSt + 'X';
  'S' : FontPrimORSec := Esc + ')' + IdSt + 'X'
  ELSE FontPrimORSec := '';
 END; (* Case *)
END;

FUNCTION FontStatus;

VAR
 IdSt : STRING;

BEGIN
 Status := UPCASE (Status);
 STR (Id, IdSt);
 CASE Status OF
  'P' : FontStatus := Esc + '*c5' + 'F';       (* Permanent *)
  'T' : FontStatus := Esc + '*c4' + 'F';       (* Temp      *)
  ELSE FontStatus := '';
 END; (* Case *)
END;

PROCEDURE DownloadFont;

VAR
 ListFile : TEXT;
 PrnFile,
 FontFile : FILE;
 Buffer : BufferType;
 RecsRead : INTEGER;

BEGIN
 ASSIGN (FontFile, FontFileName);
 RESET (FontFile, 1);
 ASSIGN (PrnFile, 'PRN');
 REWRITE (PrnFile, 1);
 ASSIGN (ListFile, 'PRN');
 REWRITE (ListFile);
 WRITE (ListFile, HPReset);
 WRITE (ListFile, FontID (Id) );
 WHILE NOT (EOF (FontFile) ) DO
  BEGIN
   BLOCKREAD (FontFile, Buffer, SIZEOF (Buffer), RecsRead);
   IF (StatusX <> 0) OR (StatusY <> 0) THEN
    WriteAt (StatusX, StatusY, StatusFore, StatusBack,
            IntStr (ROUND (FILEPOS (FontFile) / FILESIZE (FontFile) * 100) ) +
            ' % downloaded...');
   Dta2Prn (@Buffer, RecsRead);
  END;
 CLOSE (FontFile);
 WRITE (ListFile, FontStatus (Id, Status) );
 WRITE (ListFile, FontPrimORSec (Id, 'P') );
 CLOSE (PrnFile);
 CLOSE (ListFile);
END;

PROCEDURE EjectPage (VAR PrnFile : TEXT);

BEGIN
 WRITE (PrnFile, Esc + '&l0H');
END;

END. (* unit *)

{

CUT THIS OUT TO A SEPARATE FILE .. DTA2PRN.XX, and execute XX34 D filename
to create the OBJ file needed for this unit

*XX3402-000499-170789--72--85-40996-----DTA2PRN.OBJ--1-OF--1
U-Q+3IAuL3FEL2x0GZl2J22mI37C9Y3HHHe65k+++3FpQa7j623nQqJhMalZQW+UJaJmQqZj
PW+l9X0uW-o+ECYgHisG3IAuL3FEL2x0GZl2J22mI37C9Y3HHMa6+k-+uImK+U++O7M4++F1
HoF3FNU5+0UP++6-+FeE1U+++ER2J22mI37C++++LsU3+21V4E+tW+E+E86-YMU3+21e-+-3
W+U+ECAM++M+8UK60E-+slY++++Y++y60E-+slc++++Y+Eq6M+-+sY++++++++JDH2F0I+d+
+U+++++5IYJIEIF2IUd+-++++++6EZJ4FYJGIpc8E+M+++++0I7JFYN3IZB3Fkd+0++++++7
EZJ4FYJGHoNH0Y+8++++U+R3HYFBEJ7903O62E-+slg5HotHJ231Gkg+6+++t6US+21c+-J1
CZlII3lDEYdQF3F-AZ-GHWt-IoogHisGWNEr+++-4U+++-g++E+d++A+8U+3+0o+0++i++g+
A++B+16+1k+n+-2+B++H+1Q+3E+s+-Q+CE+M+2061E-+tURDHZBIEIB94kQ7W-2+ECM5F3F-
AZ-GHVY+++2++0K61U-+tUFCFJVI4E+++Eo+qe+T++2++3K9v1D7Wos2WrM6Ax6qf19YnFTW
y6jZLQ64+288+U++R+++
***** END OF BLOCK 1 *****

