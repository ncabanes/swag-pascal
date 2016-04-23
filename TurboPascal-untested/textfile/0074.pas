{$A+,B-,D+,E-,F-,I-,L+,N-,O-,R-,S-,V-}
{$M 16384,0,655360}

Unit RLINE;

(*********************************************************************
                   Fast disk file text reading operations.

        Address comments, complaints, suggestions on CompuServe to
                       Don Strenczewilk [72617,132]


    This unit contains a fast reading object designed for high speed
    reading standard ASCII disk files.

    The RLINE unit uses about 600 bytes of your programs code space,
    and 0 data.

    All of RLobject's methods return the result of their operation in
    the RFerror field, except for methods: FFilePos and FClose, which
    have no error codes.  RFerror should be checked after each call to
    one of the methods that set it, because it is re-set with each
    method call.

**********************************************************************)
  Interface
(*********************************************************************)

USES
  DOS;

TYPE
  RFobject = OBJECT
      _Handle  : Word;        { File handle }
      _BufPtr  : Pointer;     { BufOfs, BufSeg}
      _Bpo,                   { Current buffer position }
      _BSize,                 { Buffer size in bytes }
      _BLeft,                 { Bytes left in buffer to scan }
      _NBufs   : Word;        { Number of buffers read. = 0 if none. }
      _TotBytesInBuf : Word;  { Total bytes that were read into current buffer.}
      RFerror : Word;	      { RFobject's IOResult }

      PROCEDURE FOpen(Fn      : STRING;  { Name of file to open. }
		      DBSize  : Word;     { Size of buffer. 512 bytes minimum. }
		      VAR BufP);          { Disk buffer to use. }
      PROCEDURE FClose;
      PROCEDURE FReadLn(VAR S : STRING); { String variable to read next line to. }
      PROCEDURE FRead(VAR Ch  : Char);  { Char variable to read next line to. }
      FUNCTION  FFilePos : LongInt;
      PROCEDURE FSeek(FPo : LongInt);
  END;


  RFextendedP = ^RFextended;
  RFextended = Object(RFobject)
    FileName : string[80];

    CONSTRUCTOR Init(Fn : STRING;	  { Name of file to open. }
		     DBSize : Word;       { Size of buffer. }
		     VAR BufP);           { Address of disk buffer }
    Destructor Done;
    FUNCTION FileSize : LongInt;
    Function RFerrorString : string;
    PROCEDURE Reset;
  END;

TYPE
  BufRec = Record
    Lno : LongInt;  { The first line number in the buffer }
    FP  : LongInt;  { file position of first line in buffer. }
  END;

CONST
  MaxBufs = 8191;

TYPE
  BufferArray = Array[1..MaxBufs] OF BufRec;

{ When FileOfLines is initialized with SizeForBuffer = 256, it can index
  files up to 2,096,896 bytes long.
{ With SizeForBuffer = 4096, it will handle files up to 33,550,336 bytes. }

  FileOfLinesPtr = ^FileOfLines;
  FileOfLines = Object(RFextended)
    TBuf : Pointer;		{ Disk buffer pointer. }
    BufSize : Integer;		{ Disk buffer size. }
    LastLineNum : LongInt;      { Last line number accessed. }
    LastLine : String;          { Last line read. }
    TotalLines : LongInt;       { Total lines in file. }
    BufRay : ^BufferArray;      { Index of buffers for paging. }
    NBuffers : Integer;

    Constructor Init(FN : String;
		     SizeForBuffer : Word);
    Destructor Done;
    PROCEDURE SeekLine(Row : LongInt);
  END;

(*---------------------------------------------------------------------
PROCEDURE RFobject.FOpen

A file must first be successfully opened with a call to FOpen, before any of
the other routines are used.

A buffer must be declared to be passed the FOpen.  There are no restrictions
on the location of the buffer, so it can be a global or local variable, or
allocated with New() or GetMem().


PROCEDURE FOpen(Fn  : STRING;  { Name of file to open. }
		DBSize : Word; { Size of buffer. 512 bytes minimum. }
		VAR BufP);     { Disk buffer to use. }

  If successful:
    Sets RFerror to 0.

  If not successful:
    Sets RFerror to DOS error code if a DOS error occured,
    or error 12 (Invalid File Access Code) if the buffer size is 0.

NOTES:
  The SYSTEM unit FileMode variable is used as the DOS File Access Mode
  passed to DOS function $3D, to open the file.  Actually, the low 3 bits
  are set to zero, specifying Read-Only access, but the high 5 file
  sharing bits are passed.

TRAPS:
  If using a buffer allocated with New() or GetMem(), be sure to use the
  caret after it for the BufP parameter. Ie. RF.FOpen(Fn, BSize, BufP^);

Never call FOpen twice with the same RFobject variable without calling
FCLOSE first.

EXAMPLE:
VAR
  RF : RFobject;
  Buffer : Array[1..2048] of Char;
BEGIN
  System.FileMode := 0;
  RF.FOpen('HELLO.PAS', Sizeof(Buffer), Buffer);
  If RFerror = 0
  THEN Writeln('Success')
  ELSE Writeln('Error: ', i);
...

--------------------------------------------------------------------------
PROCEDURE RFobject.FClose  - When done with the file, it must be closed
			     with a call to FClose:

PROCEDURE FClose;

Closes previously opened RFrec.
Returns nothing.

This procedure attempts to identify whether the file has been previously
opened before it attempts to ask DOS to close it.  It does not attempt to
close the file if:

 a) RF.BSize = 0. PROCEDURE FOpen sets RF.BSize to 0 if DOS open failed.
or
 b) RF.Handle < 5, in which case it would be a standard DOS handle, which
    shouln't be closed.

TRAP: A problem that could occur with this scheme would be if (the file was
never even attempted to be opened by FOpen) AND (the handle = the handle of
a file that is currently opened somewhere else in the program).

----------------------------------------------------------------------
PROCEDURE RFobject.FReadLn

FReadLn - Reads a string of characters up to the next ^M, or
	  the physical end of file, whichever comes first.
	  ^Z is ignored if it occurs at the end of the file.
	  If a ^Z appears before the end of the file, it is passed
	  on to "S".

	  VAR "S", which receives the string, MUST be of TYPE STRING
	  or STRING[255].

	  The maximum length of the string returned to caller is 255
	  characters.  If more than 255 characters are passed in the
	  file before ^M or <EOF>, the remaining characters are
	  discarded.


PROCEDURE FReadLn(VAR S   : STRING); { String variable to read next line to. }

On success:
  Sets RFerror to 0.
  S = next string read from file RF.Handle.
On failure:
  Sets RFerror to DOS error code,
  or $FFFF if End of File

Works like a Turbo Pascal Readln(F, S); except:
    (1) It works only with disk files.
    (2) Only reads type STRING. ie. not integers, words, or any other type.
    (3) It is much faster.
    (4) Doesn't stop when a ^Z is encountered before end of file.  If a ^Z
	is encountered AT the end of file, it is stripped.  Any ^Z's
	encountered before the physical end of the file are passed on
	to the string.
    (5) RFerror is set to $FFFF after calling this if the physical
	end of file is reached.  The value of "S" is invalid when the
	$FFFF end of file result is set.

----------------------------------------------------------------------
PROCEDURE RFobject.FRead - Reads the next character from the file:

PROCEDURE FRead(VAR Ch  : Char);  { Char variable to read next line to. }

Works the same as FReadLn but returns one character instead of a string.
All characters are passed on to Ch except ^Z if it occurs at end of file.
Any ^Z found before the physical end of file is passed on to Ch.

If successful:
  Sets RFerror to 0.
  Ch = next character in the file.

If failed:
  Sets RFerror to either DOS error code,
  or $FFFF if physical End of File

----------------------------------------------------------------------
Function RFobject.FFilePos - Returns current file position for use with FSeek.

FUNCTION FFilePos : LongInt;

Returns current file position. RF must have been previously opened.
If FFilePos is called before FOpen is called successfully, the results
will be meaningless.

----------------------------------------------------------------------
PROCEDURE RFobject.FSeek - Seeks to position FPo in previously opened RF.

PROCEDURE FSeek(FPo : LongInt) : Word;

If successful,
  RFerror is set to 0.

If failed,
  RFerror is set to DOS error code.

To Reset the file, call RFSeek with FPo := 0.  Ie. FSeek(0);

On a normal ^M^J ascii file, FFilePos will most often return the position of
the ^J after a call to FReadLn.  Because FReadLn strips leading ^J's, this
shouldn't be a problem.  But, bear that in mind if using the FFilePos
results for your own untyped file routines.

(****************************************************************************)
Implementation
(****************************************************************************)

{ RFOBJECT ----------------------------------------------------------------}

  {$L RLINE.OBJ}
  PROCEDURE RFobject.FOpen(Fn    : STRING;
			   DBSize : Word;
			   VAR BufP); EXTERNAL;
  PROCEDURE RFobject.FClose; EXTERNAL;
  PROCEDURE RFobject.FReadLn(VAR S : STRING); EXTERNAL;
  PROCEDURE RFobject.FRead(VAR Ch : Char); EXTERNAL;
  PROCEDURE RFobject.FSeek(FPo : LongInt); EXTERNAL;
  FUNCTION  RFobject.FFilePos : LongInt; EXTERNAL;

{ RFEXTENDED --------------------------------------------------------------}

  CONSTRUCTOR RFextended.Init(Fn : STRING;   { Name of file to open. }
			      DBSize : Word; { Size of buffer. }
			      VAR BufP);     { Address of disk buffer }
  BEGIN
    FileName := FExpand(Fn);
    FOpen(Fn, DBSize, BufP);
  END;

  FUNCTION RFextended.FileSize : LongInt;
  VAR
    r : registers;
    Fpos : LongInt;
  BEGIN
    FPos := FFilePos; { save current file position }
    with r do begin
      ax := $4202;
      bx := _handle;
      cx := 0;
      dx := 0;
      msdos(r);
      if flags and fcarry <> 0
      then RFerror := ax
      else FileSize := (longint(dx) shl 16) or ax;
    end;
    _TotBytesInBuf := 0;  { Force FSeek to move file pointer. }
    FSeek(FPos);          { restore current file position }
  END;

  Function RFextended.RFerrorString : string;
    { Converts RFerror to a string. }
  VAR
    S : STRING[80];
  BEGIN
    CASE RFerror OF
      0 : S := 'Success';           { it's not an error. }
      100 : S := 'Attempted to read past End Of File.';
      101 : S := 'Disk write error.';
      102 : S := 'File not assigned.';
      103 : S := 'File not opened.';
      104 : S := 'File not open for input.';

      2 : S := 'File not found.';
      3 : S := 'Path not found.';
      4 : S := 'Too many files opened.';
      5 : S := 'File access denied.';
      6 : S := 'Invalid file handle.';
      $FFFF : S := 'End Of File.'; { special EOF number, unique to FRead and FReadln }
      200 : s := 'Divide by zero.  Buffersize = 0?';
    ELSE BEGIN
	   Str(RFerror, S);
           S := 'IOerror '+S;
         END;
    END;
    RFerrorString := S;
  END;

  PROCEDURE RFextended.Reset;
  BEGIN
    FSeek(0);
  END;

  DESTRUCTOR RFextended.Done;
  BEGIN
    Fclose;
  END;

{ FILEOFLINES -------------------------------------------------------}

  Constructor FileOfLines.Init(FN : string; SizeForBuffer : Word);
  VAR
    F : File;
    L, RamNeeded, FSize : LongInt;
    BufNum : Word;
  BEGIN
    TBuf := nil;
    BufRay := nil;
    LastLineNum := 0;
    LastLine := '';
    TotalLines := 0;

    If MaxAvail > SizeForBuffer			{ create the disk buffer }
    THEN BufSize := SizeForBuffer
    ELSE BufSize := MaxAvail;
    If BufSize >= 256
    Then GetMem(TBuf,BufSize)
    Else Fail;

    FileName := FExpand(Fn);			{ open the file. }
    FOpen(FileName, BufSize, TBuf^);
    IF RFError = 0
    THEN FSize := FileSize;

    IF RFerror <> 0 THEN
      Exit;  { Don't fail so RFerror can be polled in calling routine. }

    NBuffers := ((FSize DIV BufSize) + 1); { allocate ram for bufferarray }
    RamNeeded := NBuffers * SizeOf(BufRec);
    If (MaxAvail < RamNeeded) OR (NBuffers > MaxBufs) THEN BEGIN
      Done;
      Fail;
    END;
    GetMem(BufRay, RamNeeded);

    { Index the file. }
    BufNum := 1;
    With BufRay^[1] Do BEGIN
      Lno := 1;
      FP := 0;
    END;

    FReadLn(LastLine);
    While RFerror = 0 DO BEGIN
      Inc(TotalLines);
      IF (_NBufs > BufNum) AND (BufNum < NBuffers) Then BEGIN
	Inc(BufNum);
	With BufRay^[BufNum] DO BEGIN
	  Lno := Succ(TotalLines);
	  FP := FFilePos;
	END;
      END;
      FReadLn(LastLine);
    END;

    IF RFError = $FFFF { make it to EOF with no problems? }
    THEN Reset;
  END;

  Destructor FileOfLines.Done;
  BEGIN
    If BufRay <> nil Then Freemem(BufRay,NBuffers * SizeOf(BufRec));
    If TBuf <> nil Then FreeMem(TBuf,BufSize);
    BufRay := nil;
    TBuf := nil;
    FClose;
  END;

  PROCEDURE FileOfLines.SeekLine(Row : LongInt);
  { Seeks and reads row and puts in string LastLine }
  VAR
    i : Integer;
  BEGIN
    If Row > TotalLines THEN BEGIN
      RFerror := 100; { Attempt to read past end of file. }
      Exit;
    END;
    IF (Row <> LastLineNum+1) THEN BEGIN
      i := 2;
      While (i <= NBuffers) AND (BufRay^[i].Lno < Row) Do Inc(i);
      Dec(i);
      With BufRay^[i] DO BEGIN
	FSeek(FP);
	IF RFerror = 0 THEN BEGIN
	  FReadLn(LastLine);
	  LastLineNum := Lno;
	END;
      END;
    END;
    While (RFerror = 0) AND (LastLineNum < Row) DO
    BEGIN
      FReadLn(LastLine);
      Inc(LastLineNum);
    END;
  END;

END.

{ ---------------------   RLINE.OBJ needed for this unit ------------ }
{ cut this block out.  Save as RLINE.XX.  decode with  XX3402 :

{                      XX3402 d RLINE.XX                               }
{  the file RLINE.OBJ will be created                                  }

*XX3402-000883-310792--72--85-14039-------RLINE.OBJ--1-OF--1
U+g+0J7AGIt39Y3HHSC66++++3FpQa7j623nQqJhMalZQW+UJaJmQqZjPW+l9X+lW6UF+21d
xId42kZGH2ZCFGt-IooIW+A+ECZAZU6++4WK-U+2F23IEIOM-k-6+++0+E2JZUM+-2BDF2J3
a+Q+81o0+k2-xMk9++V4GIl3HIx2FE+QY-I+++6CIYNDEYd3EpF+FYxEFIs8+++uY-M+++6D
IYNDEYd3EpF+FYBAHpB3Pk++Xt+L+++02374Ho78FIBIE2NGFI32H2s++E0vY-I+++6CIYND
EYd3EpF+FZ73EIFU+E1tY-I+++6CIYNDEYd3EpF+FZB3FIiX+E0eY-U+++6FIYNDEYd3EpF+
FYN7H2JEHpAH+U-7W+E+E86-YO--+U6++3Qnk9Y7+DCfLwBJWym1v349p-u85U++UCDslLME
z8mtI++ukLA0WgW9yVM5wuEaW+oK5wFy-iX5znZ41bI3i+k+um48kvExnG3m4GO7-Mh41WO7
FEX3RUcaWLI0XBUaWII2Aw+aWIIE5sjZLQcC+3K9vAFy-WO1TEU+R+waWlrcTjy1ykFq-9Ey
nG49tJr8-+09wchD06hL+cjuWlyAk6vMh1zB6MjKlJs4QVu9mCAKzoQAVxYaU5bz4cTNRE37
WIwCsk9skvXzzzb15iAO7c+w0bI2GLEFFctT-9Xz+0j0R-kvm5M0WwX2TUe8kU9-eiAA+ze8
oB5dwuLFoTCY5wBJWykSz1DGWwf3LUO9TkOCFkE9Hkdo2cjrIP+BwetMR0K9mCWZzst5-CVZ
zrDdDTzzRGA8obETE6Z50chD+UBD1cZD-igEWLw4WIw88w36WwXcRzwnk6Z52-y9tJr80+-J
WymAqjn3LUMnmEhD0bERWrQ4zow8zoQ4XZw2l5s8d1D+WIQEXhe9tJr80+1c+Txmw2a7Hkca
WUJ5WLw4l5s8eijRJMjg5gJq-XD70ok6REKsm+1fIsh40chK1DTlE1Z215I4UrkC+5IYIYW7
F+knojRY06gQWwW5mfU+EgoVKb6bXYE2Wxvcdzu9wr6PWoECCw7r-PVY+CgD8w87F+e9F+61
kcZ2-XD+WIEE5sjZLQc6+3K9vAFy-XDG7ch31+j+R-F67chB0DTV7chB-WMfHE61kMDG+6jZ
LQc2+CeQ-U123EM-+Lq8+U++R+++
***** END OF BLOCK 1 *****

