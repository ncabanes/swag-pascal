
Unit MPEditor;  { VERSION 1.0  May 14, 1994 }
{  A general full-screen text editor that should compile under varying
   versions of Borland's Turbo Pascal, relying solely on the CRT
   (and System) units.

 (c) 1994, Michael Perry / Progressive Computer Services, Inc.
            All rights reserved worldwide.

  LICENSE:  This code is NOT Public Domain; It can be freely
            distributed as long as it is not modified in any
            form.  If you incorporate any part of the code into
            a program, please credit Mike Perry in the program;
            No other remuneration or consideration necessary,
            although it would be nice to get a "thank you" postcard.
            If you have suggestions or enhancements (please do)
            send them to me and I'll make sure that you get
            credit and that this unit will be continually updated.

    Author: Mike Perry / Progressive Computer Services, Inc.
            PO Box 7638, Metairie, LA 70010 USA
            BBS: (504) 835-0085  FAX: (504) 834-2160
            Fidonet: 1:396/21  Cserve: 71127,2105  AOL: Arpegi0
            Internet: 71127.2105@compuserve.com    PAN: MIKEPERRY
            Unison: MIKEP

  USAGE:    MPEDITOR manipulates text in an allocated area of memory
            specified by the TXT^ pointer.  To incorporate this unit
            into your program, simply copy your text into the array of
            byte specified by TXT^ and call the appropriate procedures.
            Supported commands:
              Arrow keys for cursor movement, INS, DEL, PgUp, PgDn
              CTRL-(left/right) moves cursor to next word;
              ^Y = delete line,
              ^B = reformat text from cursor to end of paragraph
              Ctrl-PgUp = go to top of file
              Ctrl-PgDn = go to end of file
  NOTES:
  % Statements in the unit which are commented out pertain to features
    and options which are either for demonstration purposes or have
    yet to be implemented; look for updates soon.
  % This editor unit assumes that linefeed characters (#10) are
    stripped from the input prior to editing.  If you import
    data to be edited, make sure you convert CR+LF to CR!!
  % The following routines are critical to performance and if
    implemented in ASM would improve efficiency of the unit:
    GET_LINE_DATA, SET_POSITION, SET_CURSOR
    If you can help, contact me at the addresses at the top.
}
{$R-}   { range checking off - causes error when referencing buffer array }

{ If you want to implement your own screen i/o routines, look for the
  USEQWIK directive which identifies areas in the program where you can
  make modifications to suit your objective }
{-$DEFINE USEQWIK} { implements FAST direct screen writing / requires }
                   { Eagle Performance Software's QWIK screen units }
                   { available as Shareware }
INTERFACE

{$IFDEF USEQWIK}
  USES     CRT,Qwik;
{$ELSE}
  USES     CRT;
{$ENDIF}

CONST
  TEXTMAX:WORD= 40000; { Maximum size of text editing buffer in bytes }
  CR       = 13;       { ordinal value used to indicate a new line }
  SPACE    = 32;       { ordinal value used to indicate a space }
  REFORMAT = 2;        { ordinal value to initiate reformat command / CTRL-B }
  TABSIZE  = 5;        { tab stop every five characters }

TYPE
  TXT_TYPE  = ARRAY [1..1] OF BYTE;

VAR
  TXT       : ^TXT_TYPE;    { TEXT BUFFER, pointer to memory block }

  { operational status variables ------(set during operation)------------- }
  TEXTSIZE  : LONGINT;      { size of txt array in use / max current index }
  POSITION  : LONGINT;      { index of current (cursor) position in TXT array }
  WINTOP    : LONGINT;      { index position in buffer of top of text window }
  XLINE     : BOOLEAN;      { TRUE if cursor position outside of data area }
  INSERTON  : BOOLEAN;      { TRUE indicates insert mode on }
  VROW,
  VCOLUMN   : BYTE;         { VIRTUAL ROW/COLUMN position within editing area }
  WIDTH,
  HEIGHT    : BYTE;         { width and height of current editing window }
  SCRBUMP   : BYTE;         { chars to bump over display / not to exceed
WIDTH! }
  OFFSET    : LONGINT;      { screen display offset, column position to begin
displaying }
{  MARKSTART,
   MARKEND  : LONGINT;      { start/end index of marked text / NOT IMPLEMENTED
}
  { operational configuration vars ----(set by user)----------------------- }
  MARKATTR,                 { marked text attribute }
  BACKATTR,                 { background text window attribute }
  NORMATTR,                 { attribute values for normal & hilighted text }
  BORDATTR  : WORD;         { attribute value for border }
  R1,C1,                    { row,column of upper left coord of edit window }
  R2,C2     : BYTE;         { row,column of lower right coord on edit win }
  MAXCOLUMN : LONGINT;      { maximum line length/column size, 0=No Limit }
{  MAXROW    : LONGINT;      { maximum number of lines allowed, 0=No Limit }

  { prototypes ------------------------------------------------------------ }

   {FUNCTION GETINPUT(VAR FUNCTIONKEY:BOOLEAN):BYTE; NEAR }
   {FUNCTION SPACES(COUNT:BYTE):STRING;              NEAR }
   {PROCEDURE CLEAR_TXT;                             NEAR }
  FUNCTION GETTEXTEND:LONGINT;
  FUNCTION INITIALIZE_TXT(VAR PTXT:POINTER;SIZE:LONGINT):BOOLEAN;
  PROCEDURE DISPOSE_TXT(VAR PTXT:POINTER;SIZE:LONGINT);
   {PROCEDURE DRAW_BOX(R1,C1,R2,C2:BYTE);            NEAR }
   {PROCEDURE INITIALIZE_WINDOW(R1,C1,R2,C2:BYTE);   NEAR }
   {PROCEDURE CLEAR_WINDOW;                          NEAR }
   {PROCEDURE CLEAR_LINE;                            NEAR }
   {PROCEDURE BUMP_TXT(COUNT:LONGINT);               NEAR }
   {PROCEDURE DEL_CHARS(COUNT:LONGINT);              NEAR }
   {PROCEDURE GET_LINE_DATA(POS:LONGINT; VAR STARTINDEX,ENDINDEX,COL:LONGINT);}
   {PROCEDURE STUFF_TXT(s:string);                   NEAR }
  FUNCTION WINBOTTOM:LONGINT;
   {PROCEDURE SHOW_LINE;                             NEAR }
  PROCEDURE SHOW_TXT;
  PROCEDURE DISPLAY_TXT(VAR PT:POINTER);
  PROCEDURE SCROLLUP(LINES:BYTE);
  PROCEDURE SCROLLDOWN(LINES:BYTE);
   {PROCEDURE SET_POSITION;                          NEAR }
   {PROCEDURE SET_CURSOR;                            NEAR }
   {PROCEDURE WORD_WRAP(startpoint,endpoint,length:LONGINT);}
   {FUNCTION LINEUP:LONGINT;                         NEAR }
   {FUNCTION LINEDOWN:LONGINT;                       NEAR }
  PROCEDURE READ_TXT(VAR PT:POINTER;FILENAME:STRING;VAR TEXTSIZE:LONGINT);
   {PROCEDURE DIRECTION(C:BYTE);                     NEAR }
   {FUNCTION PARSE_INPUT:BYTE;                       NEAR }
  PROCEDURE SETUP_TEXT_SETTINGS(Row1,Column1,Row2,Column2:BYTE;DRAWBOX:BOOLEAN) ;
  PROCEDURE EDIT(PT:POINTER;VAR RETURNCODE:BYTE);

IMPLEMENTATION

(***************************************************************************)
FUNCTION GETINPUT(VAR FUNCTIONKEY:BOOLEAN):BYTE;
{ read keyboard and return character/function key }
VAR CH: CHAR;
BEGIN
  CH:=ReadKey;
  IF (CH=#0) THEN
    BEGIN
      CH:=ReadKey;
      FUNCTIONKEY:=TRUE;
    END
  ELSE FUNCTIONKEY:=FALSE;
  GETINPUT:=ORD(CH);
END;
(***************************************************************************)
FUNCTION SPACES(COUNT:BYTE):STRING;
{ returns COUNT number of spaces }
{ NOTE: Unpredictable results if count exceeds 255!! }
var temp:string;
BEGIN
  TEMP:='';
  WHILE COUNT>0 DO BEGIN
    TEMP:=TEMP+#32;
    DEC(COUNT);
  END;
  SPACES:=TEMP;
END;
(***************************************************************************)
PROCEDURE CLEAR_TXT;
{ zeros the text array & associated values }
BEGIN
  fillchar(txt^,TEXTMAX,0);
  textsize:=0;
  position:=1;
END;
(***************************************************************************)
FUNCTION GETTEXTEND:LONGINT;
{ find the end of text by looking for null character
  %% This is a technique that I use to identify the actual size of
     a text buffer; if you're reading data from a disk structure,
     unless you save the actual size, you'll need to determine it.
     I make sure any unused area in my text buffer is padded with
     nuls }
var I:longint;
BEGIN
  FOR I:=1 TO TEXTMAX DO
    IF TXT^[I]=0 THEN BEGIN
      GETTEXTEND:=I-1;
      EXIT;
    END;
  GETTEXTEND:=TEXTSIZE;
END;
(***************************************************************************)
FUNCTION INITIALIZE_TXT(VAR PTXT:POINTER;SIZE:LONGINT):BOOLEAN;
{ create/allocate memory for text buffer }
BEGIN
  if MaxAvail < SIZE then
    INITIALIZE_TXT:=FALSE     { not enough available memory }
  else BEGIN
    GETMEM(PTXT,SIZE);
    INITIALIZE_TXT:=TRUE;
    TEXTMAX:=SIZE;            { set max size of text }
    TXT:=PTXT;                { establish pointer for routines }
    CLEAR_TXT;                { zero text }
  END;
END;

(***************************************************************************)
PROCEDURE DISPOSE_TXT(VAR PTXT:POINTER;SIZE:LONGINT);
{ disposes text buffer }
BEGIN
  FREEMEM(PTXT,SIZE);
END;
(***************************************************************************)
PROCEDURE DRAW_BOX(R1,C1,R2,C2:BYTE);
{ surrounds the specified area with a box }
{ NOTE! There are no checks to make sure the box area isn't off the screen!
        and this (and other) routines must be slightly modified if you want
        the text area to fill up the entire screen due to anomolies with
        TP's WINDOW function }
var I:byte;
BEGIN
{$IFDEF USEQWIK}
  { draw horizontal line }
  FOR I:=(C1-1) TO (C2+1) DO BEGIN
    qwrite(R1-1,I,BORDATTR,'─');
    qwrite(R2+1,I,BORDATTR,'─');
  END;
  { draw vertical line }
  FOR I:=(R1-1) TO (R2+1) DO BEGIN
    QWRITE(I,C1-1,BORDATTR,'│');
    QWRITE(I,C2+1,BORDATTR,'│');
  END;
  QWRITE(R1-1,C1-1,BORDATTR,'┌');
  QWRITE(R2+1,C1-1,BORDATTR,'└');
  QWRITE(R1-1,C2+1,BORDATTR,'┐');
  QWRITE(R2+1,C2+1,BORDATTR,'┘');
{$ELSE}
  TEXTATTR:=BORDATTR;
  { draw horizontal line }
  FOR I:=(C1-1) TO (C2+1) DO BEGIN
    GOTOXY(I,R1-1); WRITE('─');
    GOTOXY(I,R2+1); WRITE('─');
  END;
  { draw vertical line }
  FOR I:=(R1-1) TO (R2+1) DO BEGIN
    GOTOXY(C1-1,I); WRITE('│');
    GOTOXY(C2+1,I); WRITE('│');
  END;
  GOTOXY(c1-1,r1-1); WRITE('┌');
  GOTOXY(c1-1,r2+1); WRITE('└');
  GOTOXY(c2+1,r1-1); WRITE('┐');
  GOTOXY(c2+1,r2+1); WRITE('┘');
  TEXTATTR:=NORMATTR;
{$ENDIF}
END;
(***************************************************************************)
PROCEDURE INITIALIZE_WINDOW(R1,C1,R2,C2:BYTE);
{ defines text window and clears screen }
BEGIN
{$IFNDEF USEQWIK}
  WINDOW(C1,R1,C2+1,R2);
{$ENDIF}
END;
(***************************************************************************)
PROCEDURE CLEAR_WINDOW;
{ clears the current text window }
BEGIN
{$IFDEF USEQWIK}
  QFILL(r1,c1,HEIGHT,WIDTH,BACKATTR,#32);
{$ELSE}
  textattr:=backattr;
{ since TP forces an unwanted scroll when writing to the lower right corner
  of a window, we create a window 1-column larger and init a smaller one when
  we want to clear the screen, there is an extra column defined in the
  working window so that unwanted scrolls are not accomplished }
  WINDOW(C1,R1,C2,R2);
  CLRSCR;
  WINDOW(C1,R1,C2+1,R2);
{$ENDIF}
END;
(***************************************************************************)
PROCEDURE CLEAR_LINE;
{ clears the current line }
BEGIN
{$IFDEF USEQWIK}
  QFILL(R1+VROW-1,C1,1,WIDTH,BACKATTR,#32);
  { FYI, the arguments for QFILL are:
     QFILL(row,column,rows,columns,attribute,char);  }
{$ELSE}
  TEXTATTR:=BACKATTR;
  WINDOW(C1,R1,C2,R2);
  gotoxy(1,vrow); clreol;
  WINDOW(C1,R1,C2+1,R2);
{$ENDIF}
END;
(***************************************************************************)
PROCEDURE BUMP_TXT(COUNT:LONGINT);
{ moves text at POSITION index over COUNT bytes, for inserting data }
{ this procedure does NOT change, position or cursor indexes }
VAR I:LONGINT;
BEGIN
  inc(textsize,COUNT);
  for i:=textsize downto position do { move everything forward 1 }
    txt^[i]:=txt^[i-COUNT];
END;
(***************************************************************************)
PROCEDURE DEL_CHARS(COUNT:LONGINT);
{ erase COUNT chars at position, shorten text array }
var I:longint;
BEGIN
  FOR I:=POSITION TO (TEXTSIZE-1) DO
    TXT^[I]:=TXT^[I+COUNT];
  DEC(TEXTSIZE,COUNT);
END;

(***************************************************************************)
PROCEDURE GET_LINE_DATA(POS:LONGINT; VAR STARTINDEX,ENDINDEX,COL:LONGINT);
{ given the array index (position), calculate the start & ending index of the
  current line, also returning VIRTUAL column position on the current line

  procedure returns:  1,1,1 if at the top of the file;
  procedure returns:  textsize,textsize,1 at bottom of file

  This is one procedure, that if implemented in ASM would improve the
  overall performance of this unit (I'm open to suggestions).
}
VAR i:longint;
BEGIN
  startindex:=0; endindex:=0; col:=0;
  if pos<1 then exit;               { invalid position }
  if pos>textsize then begin        { at end of text }
    endindex:=textsize+1;
  end else begin
    for i:=pos to textsize do       { find end of line index }
      if txt^[i]=CR then begin      { found CR at end of line }
        endindex:=i;
        i:=textsize;                { force end of loop }
      end;
    if endindex=0 then endindex:=textsize+1;  { last line obviously }
  end;
                                    { find beginning of line index }
  for i:=(endindex-1) downto 1 do   { FOR checks=endvalue, if not increments! }
    if txt^[i]=CR then begin        { found CR at beginning of line }
      startindex:=i+1;              { index of previous CR+1 }
      i:=1;                         { force end of loop }
    end;
  if startindex=0 then startindex:=1;  { begin of line is top of text }

  col:=pos-startindex+1;            { calculate VIRTUAL column position }
END;
(***************************************************************************)
PROCEDURE STUFF_TXT(s:string);
{ add string/char to txt array, bump POSITION up one }
VAR j,b1,e1,col1:longint; t:byte;
BEGIN
  t:=length(s);
  if ((inserton) or (txt^[position]=CR)) and ((textsize+t)>textmax) then
begin  { no more room }
    write(#7); exit;
  end;

{ if xline, and text added, make sure to bump position to the end of line }
  IF (XLINE) THEN BEGIN { pad the short line with spaces to the position }
    GET_LINE_DATA(POSITION, b1,e1,col1);
    j:=(offset+vcolumn)-(e1-b1+1);  { number of spaces to pad }
    IF ((textsize+t+j)>textmax) then BEGIN { check for avail space }
      write(#7); exit;
    END;
    bump_txt(j);
    for b1:=position to (position+j-1) do
      txt^[b1]:=SPACE;
    XLINE:=FALSE;
    POSITION:=POSITION+J;
  END;

  if (inserton) OR (txt^[position]=CR) then
    if (position<=textsize) then begin { insert }
      bump_txt(t);
      FOR J:=1 TO T DO BEGIN
        txt^[position]:=ORD(S[J]);  { add/replace character }
        INC(POSITION);              { move pointer up one }
        INC(VCOLUMN);
      END;
      exit;
    end else begin                  { append / position > textsize }
      FOR J:=1 TO T DO BEGIN
        inc(textsize);
        txt^[textsize]:=ORD(S[J]);
        INC(VCOLUMN);
      END;
      position:=textsize+1;         { position pointer at end of text }
    end
  else if position<=textsize then begin { overwrite }
    FOR J:=1 TO T DO BEGIN
      txt^[position]:=ORD(S[J]);        { overwrite current position }
      inc(position);                    { move pointer one over }
    END;
    INC(VCOLUMN,T);
  end else begin { append }
    if ((textsize+T)>=textmax) then begin  { can't append if buffer full }
      write(#7);
      exit;
    end;
    FOR J:=1 TO T DO BEGIN
      inc(textsize);
      txt^[textsize]:=ORD(S[J]);
    END;
    position:=textsize+1;
    INC(VCOLUMN,T);
  end;
END;
(***************************************************************************)
FUNCTION WINBOTTOM:LONGINT;
{ returns the text array index value of the last character in the text window }
var i:longint; linecount:byte;
BEGIN
  LINECOUNT:=0;
  FOR I:=WINTOP TO TEXTSIZE DO BEGIN
    IF TXT^[I]=CR THEN INC(LINECOUNT);
    IF LINECOUNT=HEIGHT THEN BEGIN { found last line in text window }
      WINBOTTOM:=I;
      EXIT;
    END;
  END; { for loop thru text }
  WINBOTTOM:=TEXTSIZE; { end before last text line found, so text ends in
window }
END;

(***************************************************************************)
PROCEDURE SHOW_LINE;
{ rewrites the current line to the window }
VAR I,b1,e1,col1:longint; S:STRING;
BEGIN
  GET_LINE_DATA(position, b1,e1,col1);
  IF (B1>TEXTSIZE) THEN BEGIN CLEAR_LINE; EXIT; END; { nothing there }
  col1:=(offset+b1+width-1); if col1>textsize then col1:=textsize; {eol pos}
  S:='';
  for i:=(offset+b1) to col1 {(offset+b1+width-1)} do begin
    if txt^[i]=CR then i:=col1 {(offset+b1+width-1)} { force end }
    else begin
      s:=s+chr(txt^[i]);
    end;
  end;
  CLEAR_LINE;
{$ifdef USEQWIK}
  QWRITE(R1+VROW-1,C1,NORMATTR,S);
  GOTORC(R1+VROW-1,C1+VCOLUMN-1);
{$ELSE}
  TEXTATTR:=NORMATTR;
  GOTOXY(1,VROW);  WRITE(S);
  GOTOXY(VCOLUMN,VROW);
{$ENDIF}
END;
(***************************************************************************)
PROCEDURE SHOW_TXT;
{ display text to screen area
  sets VROW and VCOLUMN to match displayed area where position
  is and moves cursor to that location }
var I,R,C,CWIDTH:LONGINT;
BEGIN
  R:=1; C:=1;  { set start row/column }
  CWIDTH:=0;
  CLEAR_WINDOW;

  { % hide cursor }
  FOR I:=WINTOP TO TEXTSIZE DO BEGIN
    IF (R>HEIGHT) OR (I>TEXTSIZE) THEN begin { check for outside vertical
boundaries OR end }
      {$IFDEF USEQWIK}
        GOTORC(R1+VROW-1,C1+VCOLUMN-1);
      {$ELSE}
        GOTOXY(VCOLUMN,VROW);
      {$ENDIF}
      EXIT;  { done, filled window }
    END;
    IF (TXT^[I]=CR) THEN BEGIN   { -------------- check for carriage return }
      INC(R);   { bump row down }
      CWIDTH:=0;
      C:=1;
{ % IF TXT^[I+1]=10 THEN INC(I);  { check for additional LF / skip over }

    END ELSE BEGIN   { ----------------------------------- printable char }
      INC(CWIDTH);
      IF CWIDTH>OFFSET THEN       { if screen offset in effect }
        IF C<= WIDTH THEN BEGIN    { if line not off the screen }
{$IFDEF USEQWIK}
          QWRITE(R1+R-1,C1+C-1,NORMATTR,CHR(TXT^[I]));
{$ELSE}
          GOTOXY(C,R); textattr:=normattr;
          WRITE(CHR(TXT^[I]));
{$ENDIF}
          INC(C);
        END else INC(C);  { increment column counter anyway even though not
printed }
     END;
     IF I>TEXTSIZE THEN I:=TEXTSIZE;  { if bumped past, set to end loop }
  END;  { FOR loop }
{$IFDEF USEQWIK}
  GOTORC(R1+VROW-1,C1+VCOLUMN-1);
{$ELSE}
  GOTOXY(VCOLUMN,VROW);
{$ENDIF}
  EXIT;
END;
(***************************************************************************)
PROCEDURE DISPLAY_TXT(VAR PT:POINTER);
{ display text, specified by pointer
  can be used by an external viewing routine }
VAR TEMP:POINTER;
BEGIN
  TEMP:=addr(TXT);
  TXT:=PT;
  SHOW_TXT;
  TXT:=TEMP;
END;
(***************************************************************************)
PROCEDURE SCROLLUP(LINES:BYTE);
{ scroll screen up x lines; does not change cursor or text pointer }
var i,b1,e1,col1,LINECOUNT:longint;
BEGIN
  LINECOUNT:=0;
  FOR I:=WINTOP DOWNTO 1 DO BEGIN
    if txt^[i]=CR then begin  { found end of prev line }
       INC(LINECOUNT);
       IF (LINECOUNT=LINES) THEN BEGIN
         GET_LINE_DATA(I, b1,e1,col1);
         WINTOP:=B1;
         EXIT;
       END;
    END; { cr found }
  END; { for loop }
  WINTOP:=1;
END;
(***************************************************************************)
PROCEDURE SCROLLDOWN(LINES:BYTE);
{ scroll screen down x lines, does not change cursor or text pointer }
var i,b1,e1,col1,LINECOUNT:longint;
BEGIN
  linecount:=0;
  for i:=WINTOP to textsize do begin
    if txt^[i]=CR then begin
      { i=index pos of CR of next line }
      inc(linecount);
      if (linecount=lines) {or (i=textsize)} then begin
        WINTOP:=i+1;
        SHOW_TXT;
        EXIT;
      end;  { found specified number of lines }
    end; { if CR found }
  end; { loop thru text }
END;

(***************************************************************************)
PROCEDURE SET_POSITION;
{ sets POSITION index based on cursor location and WINTOP index }
var I,b1,e1,col1,R,LINECOUNT:longint;
BEGIN
  R:=1; LINECOUNT:=1;
  FOR I:=WINTOP TO TEXTSIZE DO BEGIN
    if (VROW=R) then begin  { line cursor on found }
      GET_LINE_DATA(I, b1,e1,col1);
      IF ((E1-B1+1) < (VCOLUMN+OFFSET)) THEN BEGIN
        POSITION:=E1;
        XLINE:=TRUE;
      END ELSE BEGIN
        POSITION:=B1+VCOLUMN-1;
        XLINE:=FALSE;
      END;
      EXIT;
    end; { cursor line found }
    if txt^[i]=CR then begin
      INC(R);
      INC(LINECOUNT);
    end;
  END; { for loop thru text }
  POSITION:=TEXTSIZE+1;  { assuming cursor at end of text then }
  VROW:=LINECOUNT;  { not sure if this should be here, but takes care
                      of case where scrolling causes most of screen to
                      be past the end of file (where the cursor pos is)
                    }
  GET_LINE_DATA(POSITION, b1,e1,col1);
  IF (VCOLUMN>COL1) THEN XLINE:=TRUE ELSE BEGIN
    POSITION:=B1+VCOLUMN+OFFSET-1;
    XLINE:=FALSE;
  END;
END;
(***************************************************************************)
PROCEDURE SET_CURSOR;
{ finds position and sets VCOLUMN & VROW and OFFSET appropriately in window }
{ ALWAYS sets XLINE to FALSE }
var i,b1,e1,col1,R,C:longint; screenchanged:BOOLEAN;
BEGIN
  R:=1; C:=1; SCREENCHANGED:=FALSE; XLINE:=FALSE;
  FOR I:=WINTOP TO TEXTSIZE+1 DO BEGIN
    IF I=POSITION THEN BEGIN   { found it ------------------------ }
      if (c>offset) and (c<=(offset+width)) then begin  { in window }
        dec(c,offset);
      end else BEGIN
        SCREENCHANGED:=TRUE;
        IF (C<=WIDTH) THEN BEGIN
          OFFSET:=0;
        END ELSE BEGIN
          OFFSET:=(C-WIDTH)+SCRBUMP;
          C:=WIDTH-SCRBUMP;
        END;
      END;
      VCOLUMN:=C;
      VROW:=R;
      IF (SCREENCHANGED) THEN SHOW_TXT else
{$IFDEF USEQWIK}
        GOTORC(R1+VROW-1,C1+VCOLUMN-1);
{$ELSE}
        GOTOXY(VCOLUMN,VROW);
{$ENDIF}
      EXIT;
    END; { position found }
  IF TXT^[I]=CR THEN BEGIN
    INC(R); C:=1;
  END ELSE INC(C);
  IF (R>HEIGHT) {OR (R<1)} THEN BEGIN
    GET_LINE_DATA(WINTOP, b1,e1,col1);
    WINTOP:=E1+1;
    R:=HEIGHT;
    SCREENCHANGED:=TRUE;
  END;
 END; { for }
END;
(***************************************************************************)
PROCEDURE WORD_WRAP(startpoint,endpoint,length:LONGINT);
{ word wrap a section of text }
var ccount,i,spacepos,lastcr:longint; showit:boolean;
BEGIN
  IF LENGTH=0 THEN EXIT;  { no length specified so get outta here }
  SPACEPOS:=0; SHOWIT:=FALSE; CCOUNT:=0; LASTCR:=-1;
  FOR I:=STARTPOINT TO (ENDPOINT-1) DO BEGIN
    INC(CCOUNT);
    IF TXT^[I]=SPACE THEN SPACEPOS:=I;
    IF TXT^[I]=CR THEN    { end wrap when to CRs follow, otherwise -> space }
      IF LASTCR=(I-1) THEN BEGIN
        TXT^[I-1]:=CR; { restore prev CR }
        SET_CURSOR;
        SHOW_TXT;
        EXIT;
      END ELSE BEGIN
        TXT^[I]:=SPACE;
        SPACEPOS:=I;
        LASTCR:=I;
      END;
    IF (CCOUNT)>LENGTH THEN BEGIN  { past point }
      IF SPACEPOS=0 THEN BEGIN     { force a CR }
        SPACEPOS:=POSITION; { save pos }
        POSITION:=I;
        BUMP_TXT(1);  { insert 1 byte at position }
        INC(ENDPOINT);
        POSITION:=SPACEPOS; { restore pos }
        TXT^[I]:=CR;
        CCOUNT:=0;
      END ELSE BEGIN
        TXT^[SPACEPOS]:=CR; { turn last space into a CR }
        CCOUNT:=I-SPACEPOS; { calc next line len w/wrap }
      END;
      SHOWIT:=TRUE;
    END; { line past length }
  END; { for }
  IF SHOWIT THEN BEGIN
    SET_CURSOR;
    SHOW_TXT;
  END;
END;

(***************************************************************************)
FUNCTION LINEUP:LONGINT;
{ returns new index in file, one line up }
{ MOVES cursor on screen as well }
var b1,b2,e1,e2, col1,col2,len1,len2:longint;
BEGIN
  GET_LINE_DATA(position, b1,e1,col1); { get data on current line }
  len1:=e1-b1+1;                       { length of line + CR }
  if b1=1 then BEGIN                   { check for top of text }
    LINEUP:=POSITION; EXIT;
  END;
  GET_LINE_DATA(B1-1,     b2,e2,col2); { get data on previous line }
  len2:=e2-b2+1;
  IF (XLINE) THEN BEGIN
    col2:=b2+vcolumn+offset-1; { in case of move to non-xline, set position }
  END ELSE
    col2:=b2+col1-1;  { index position of one line up, tentative }

  if col2<1 then col2:=1 else { top of file }
    if (col2>e2) then begin   { previous line shorter than current line }
      col2:=e2;               { make one line up, end of previous line }
      XLINE:=TRUE;
    end else begin
      XLINE:=FALSE;
    end;
  LINEUP:=COL2;

  IF (WINTOP>col2) THEN BEGIN  { scroll the screen up }
    WINTOP:=B2;
    SHOW_TXT;
  END ELSE DEC(VROW);  { bump cursor up }
{$IFDEF USEQWIK}
  GOTORC(R1+VROW-1,C1+VCOLUMN-1);
{$ELSE}
  GOTOXY(VCOLUMN,VROW);
{$ENDIF}
END;
(***************************************************************************)
FUNCTION LINEDOWN:LONGINT;
{ returns new index in file, one line down }
{ MOVES cursor on screen as well }
var b1,b2,e1,e2, col1,col2,len1,len2:longint;
BEGIN
  GET_LINE_DATA(position, b1,e1,col1); { get data on current line }
  len1:=e1-b1+1;                       { calc length of line incl. CR }
  if e1>=textsize then begin           { can't go down on last line }
    LINEDOWN:=POSITION; EXIT;
  end;
  GET_LINE_DATA(e1+1,     b2,e2,col2); { get data on next line }
  len2:=e2-b2+1;

  IF (XLINE) THEN BEGIN
    col2:=b2+vcolumn+offset-1;   { in case of move to non-xline, set position }
  END ELSE
    col2:=b2+col1-1;   { index position of one line down, tentative }

  if (col2>e2) then begin  { next line position is past end of next line }
      col2:=e2;            { make one line down, end of next line }
      xline:=TRUE;
    end else begin
      xline:=FALSE;
  end;
  LINEDOWN:=COL2;

  IF (VROW=HEIGHT) THEN BEGIN   { down off screen, scroll text up }
    SCROLLDOWN(1);  {WINTOP:=B2;}
  END ELSE INC(VROW);  { bump screen down }
{$IFDEF USEQWIK}
  GOTORC(R1+VROW-1,C1+VCOLUMN-1);
{$ELSE}
  GOTOXY(VCOLUMN,VROW);
{$ENDIF}
END;
(***************************************************************************)
PROCEDURE READ_TXT(VAR PT:POINTER;FILENAME:STRING;VAR TEXTSIZE:LONGINT);
{ reads text from file into buffer, strips LFs }
{ HORRIBLY SLOW, but not intended to be a real part of this unit }
VAR
    F    :FILE OF BYTE;
    PTXT :^TXT_TYPE;
BEGIN
  PTXT:=PT;
  ASSIGN(F,FILENAME);
  RESET(F);
  TEXTSIZE:=0;
  IF IORESULT<>0 THEN EXIT;
  IF EOF(F) THEN BEGIN CLOSE(F); EXIT; END;
  WHILE NOT(EOF(F)) DO BEGIN
    INC(TEXTSIZE);
    READ(F,PTXT^[TEXTSIZE]);
    if (Ptxt^[textsize]=10) then begin
      dec(textsize);  { remove LFs }
    end;
    IF TEXTSIZE>=TEXTMAX THEN BEGIN
      CLOSE(F);
      EXIT;
    END;
  END;
  CLOSE(F);
END;

(***************************************************************************)
PROCEDURE DIRECTION(C:BYTE);
{ act on direction keys }
var b1,e1,col1:longint; T:BYTE;
BEGIN
      case C of
       72:begin  { up }
           POSITION:=LINEUP;
         end;
       80:begin  { down }
            POSITION:=LINEDOWN;
          end;
       75:begin  { left }
            if position=1 then begin
              write(#7);
              exit;
            end;
            if (xline) then begin
              dec(vcolumn);
              { check to see if moved onto text }
              get_line_data(position,b1,e1,col1);
              if (offset+vcolumn)=(e1-b1+1) then begin
                xline:=FALSE;
              end;
            end else begin  { not xline }
              if txt^[position-1]=CR then begin      { back up one line? }
                get_line_data(position-1,b1,e1,col1);
                vcolumn:=col1;
                if col1>width then begin { left to prev line off screen }
                  offset:=col1-width+2;
                  vcolumn:=col1-offset;
                  SHOW_TXT;
                end else offset:=0;
                dec(vrow)
              end else begin
                dec(vcolumn);
              end;
              dec(position);
            end; { xline }
            if (vcolumn<1) and (offset>0) then begin
              vcolumn:=1;
              dec(offset);
              SHOW_TXT;
            end;
{$IFDEF USEQWIK}
            GOTORC(R1+VROW-1,C1+VCOLUMN-1);
{$ELSE}
            GOTOXY(VCOLUMN,VROW);
{$ENDIF}
          end;
       77:begin  { right }
            if (xline) then begin
              inc(vcolumn);
            end else begin
              inc(position);
              inc(vcolumn);
              if (txt^[position-1]=CR) OR ((position-1)>=TEXTSIZE) then begin
{ at eol }
                dec(position);
                xline:=true;
              end;
            end;

            IF (MAXCOLUMN>0) AND ((VCOLUMN+OFFSET)>MAXCOLUMN) THEN BEGIN
              GET_LINE_DATA(POSITION,b1,e1,col1);
              IF E1>=TEXTSIZE THEN BEGIN
                DEC(VCOLUMN);
              END ELSE BEGIN
                POSITION:=E1+1;
                SET_CURSOR;
                EXIT;
              END;
            END;

            if vcolumn>width then begin { moved outside window }
              inc(offset);
              dec(vcolumn);
              SHOW_TXT;
            end;
{$IFDEF USEQWIK}
            GOTORC(R1+VROW-1,C1+VCOLUMN-1);
{$ELSE}
            GOTOXY(VCOLUMN,VROW);
{$ENDIF}
          end;
       71:begin  { HOME, to beginning of current line }
            GET_LINE_DATA(POSITION,B1,E1,COL1);
            POSITION:=B1; VCOLUMN:=1;
            IF OFFSET>0 THEN BEGIN
              OFFSET:=0;
              SHOW_TXT;
            END;
{$IFDEF USEQWIK}
            GOTORC(R1+VROW-1,C1+VCOLUMN-1);
{$ELSE}
            GOTOXY(VCOLUMN,VROW);
{$ENDIF}
            XLINE:=FALSE;
          end;
       79:begin  { END, to end of current line }
            GET_LINE_DATA(POSITION,B1,E1,COL1);
            POSITION:=E1;
            { calculate offset & cursor position }
            IF (E1-(B1+OFFSET)+1)>WIDTH THEN BEGIN  { off screen }
              offset:=(e1-b1+1)-width+2; {SCRBUMP}
              vcolumn:=width-2; {SCRBUMP}
              SHOW_TXT;
            END ELSE VCOLUMN:=((E1-B1+1)-offset);
{$IFDEF USEQWIK}
            GOTORC(R1+VROW-1,C1+VCOLUMN-1);
{$ELSE}
            GOTOXY(VCOLUMN,VROW);
{$ENDIF}
          end;
       73:begin  { PGUP, up one screen }
            IF (WINTOP=1) THEN BEGIN
              POSITION:=1;
              VCOLUMN:=1; VROW:=1;
{$IFDEF USEQWIK}
              GOTORC(R1+VROW-1,C1+VCOLUMN-1);
{$ELSE}
              GOTOXY(VCOLUMN,VROW);
{$ENDIF}
            END ELSE BEGIN
              SCROLLUP(HEIGHT);
              SET_POSITION;
              SHOW_TXT;
            END;
          end;
       81:begin  { PGDN, down one screen }
            IF (WINBOTTOM=TEXTSIZE) THEN BEGIN
              POSITION:=TEXTSIZE+1;
              SET_CURSOR;
            END ELSE BEGIN
              SCROLLDOWN(HEIGHT);
              SET_POSITION;
              SHOW_TXT;
            END;
          end;
        82:BEGIN
             INSERTON:=NOT(INSERTON);     { INS toggle insert status }
{ %      IF (INSERTON) THEN GETBLOCKCURSOR ELSE GETUNDERLINECURSOR;}
           END;
        83:BEGIN                        { DEL }
             T:=ORD(TXT^[POSITION]);
             IF POSITION=TEXTSIZE+1 THEN EXIT;
             IF (XLINE) THEN BEGIN   { hitting DEL past eol, special case }
               STUFF_TXT(#0);
               DEC(POSITION);
               DEC(VCOLUMN);
               DEL_CHARS(1);
             END;
             DEL_CHARS(1);
             IF (T=CR) OR (POSITION>=TEXTSIZE) THEN SHOW_TXT ELSE SHOW_LINE;
           END;
       132:begin  { CTRL-PgUP - top of text }
             POSITION:=1; VROW:=1; VCOLUMN:=1; XLINE:=FALSE;
             IF (WINTOP=1) AND (OFFSET=0) THEN
{$IFDEF USEQWIK}
               GOTORC(R1+VROW-1,C1+VCOLUMN-1)
{$ELSE}
               GOTOXY(VCOLUMN,VROW)
{$ENDIF}
             ELSE BEGIN
               WINTOP:=1; OFFSET:=0;
               SHOW_TXT;
             END;
          end;
       115:begin  { CTRL <- }
             if position<3 then exit;
             for col1:=(position-2) downto 1 do
               if (txt^[col1]=SPACE) then begin
                 position:=col1+1;
                 if position<wintop then begin
                   wintop:=1;
 { this could be avoided if set-cursor started at 1 instead of wintop,
   but it would reduce overal performance }
                   set_cursor;
                   show_txt
                 end else
                   set_cursor;
                 exit;
               end;
           end;
       116:begin  { CTRL -> }
             if position>=textsize then exit;
             for col1:=position+1 to textsize do
               if (txt^[col1]=SPACE) then begin
                 position:=col1+1;
                 set_cursor;
                 exit;
               end;
           end;
       118:begin  { CTRL-PgDN - end of text }
             position:=textsize+1;
             SET_CURSOR;
         end;
       67:BEGIN    { F9 }
          END;
      end; { case }
end;

(***************************************************************************)
FUNCTION PARSE_INPUT:BYTE;
{ main encapsulation of editing routine, read keys and act }
var c         :byte;
    fkey      :boolean;
    leaving   :boolean;
    b1,e1,col1:longint;
{ RETURNS:
      1=ESC
      2=ALT-X
      3=F1
      4=F10
      5=F2
}
BEGIN
  LEAVING:=FALSE;
  REPEAT
    c:=getinput(fkey);

    IF (C=27) OR ((FKEY) AND (C IN [59,45,60,68])) THEN BEGIN  { exit
conditions }
      IF C=27 THEN PARSE_INPUT:=1 ELSE  { esc }
      IF C=45 THEN PARSE_INPUT:=2 ELSE  { Alt-X }
      IF C=59 THEN PARSE_INPUT:=3 ELSE  { F1 }
      IF C=68 THEN PARSE_INPUT:=4 ELSE  { F10 }
      IF C=60 THEN PARSE_INPUT:=5;      { F2 }
      EXIT;
    END ELSE
    IF (FKEY) THEN BEGIN  { ------------------ eval FNC & CURSOR keys ----- }
      DIRECTION(C);
    END { if function key pressed }
    ELSE BEGIN                      { alphanumeric key - process data }
      CASE C OF                     { check alpha keys }
       REFORMAT:BEGIN               { CTRL-B, 02, REFORMAT }
            GET_LINE_DATA(POSITION,b1,e1,col1);
            WORD_WRAP(B1,TEXTSIZE,MAXCOLUMN);
          END;
       CR:begin                     { carriage return }
            IF (INSERTON) OR (POSITION>TEXTSIZE) THEN BEGIN
              OFFSET:=0;
              INC(VROW);
              IF VROW>HEIGHT THEN BEGIN
                 SCROLLDOWN(1);
                 DEC(VROW);
               END;
               STUFF_TXT(CHR(C));
               VCOLUMN:=1;
               SHOW_TXT;
             end ELSE BEGIN  { enter pressed with overwrite on }
               GET_LINE_DATA(POSITION,B1,E1,COL1);
               POSITION:=E1+1;
               OFFSET:=0;
               SET_CURSOR;
               show_txt;
             END;
           END;
        08:IF POSITION<>1 THEN BEGIN    { backspace }
             IF (XLINE) THEN BEGIN   { can't erase dead zone }
                DEC(VCOLUMN);        { just move cursor left }
                SET_POSITION;
             END ELSE BEGIN
               DEC(POSITION);
               IF TXT^[POSITION]=CR THEN BEGIN { backspace/erase line }
                 DEL_CHARS(1);
                 SET_CURSOR;
                 SHOW_TXT;
               END ELSE BEGIN
                 DEL_CHARS(1);
                 DEC(VCOLUMN);
                 IF (VCOLUMN=0) THEN
                   IF (OFFSET>=SCRBUMP) THEN BEGIN
                     DEC(OFFSET,SCRBUMP); VCOLUMN:=SCRBUMP;
                     SHOW_TXT;
                   END ELSE BEGIN
                     OFFSET:=0; SET_CURSOR;
                     SHOW_TXT;
                   END
                 ELSE SHOW_LINE;
               END;
             END; { xline / else }
{$IFDEF USEQWIK}
             GOTORC(R1+VROW-1,C1+VCOLUMN-1);
{$ELSE}
             GOTOXY(VCOLUMN,VROW);
{$ENDIF}
           END;
         09:BEGIN                      { TAB }
              GET_LINE_DATA(POSITION, b1,e1,col1);
              col1:=tabsize-((position-b1) mod tabsize); { spaces to next tab
stop }
              IF (INSERTON) THEN BEGIN
                stuff_txt(SPACES(COL1));
                SHOW_LINE;
              END ELSE BEGIN
                INC(VCOLUMN,COL1);
                IF VCOLUMN>WIDTH THEN BEGIN
                  INC(OFFSET,SCRBUMP);
                  DEC(VCOLUMN,SCRBUMP);
                  SHOW_TXT;
                END;
                IF (POSITION+COL1)>E1 THEN BEGIN
                  POSITION:=E1; XLINE:=TRUE;
                END ELSE begin POSITION:=POSITION+COL1; XLINE:=FALSE; END;
{$IFDEF USEQWIK}
                GOTORC(R1+VROW-1,C1+VCOLUMN-1);
{$ELSE}
                GOTOXY(VCOLUMN,VROW);
{$ENDIF}
              END;
            END;
         25:BEGIN                      { CTRL-Y / ERASE LINE }
              GET_LINE_DATA(POSITION, b1,e1,col1);
              IF E1>TEXTSIZE THEN E1:=E1-B1 ELSE E1:=E1-B1+1;
              POSITION:=B1; { E1:=E1-B1+1; }
              OFFSET:=0; VCOLUMN:=1;
              DEL_CHARS(E1);
              SHOW_TXT;
              IF POSITION>TEXTSIZE THEN POSITION:=TEXTSIZE+1;
            END;
        ELSE BEGIN   {------------------ unspecific alphanumeric char }
          STUFF_TXT(CHR(C));           { store it }
          IF MAXCOLUMN=0 THEN BEGIN    { check for column boundaries }
            IF VCOLUMN>WIDTH THEN BEGIN
              INC(OFFSET,SCRBUMP);
              DEC(VCOLUMN,SCRBUMP);
              SHOW_TXT;
            END;
          END ELSE BEGIN  { limited screen/line size }
            SHOW_LINE;
            IF ((VCOLUMN+OFFSET)>MAXCOLUMN+1) THEN BEGIN  { hit edge limit }
              get_line_data(position,b1,e1,col1);
              word_wrap(b1,textsize,MAXCOLUMN);
            END ELSE BEGIN
              IF VCOLUMN>WIDTH THEN BEGIN { maxcolumn>width but set }
                INC(OFFSET,SCRBUMP);
                DEC(VCOLUMN,SCRBUMP);
                SHOW_TXT;
              END;
            END;
          END;
          SHOW_LINE;
        END;
      END; { case }
    END { alpha key }
  UNTIL LEAVING;
END;

(***************************************************************************)
PROCEDURE SETUP_TEXT_SETTINGS(Row1,Column1,Row2,Column2:BYTE;DRAWBOX:BOOLEAN);
{ sets appropriate system values for text window }
BEGIN
  R1:=ROW1; C1:=COLUMN1; R2:=ROW2; C2:=COLUMN2;  { set global position of win }
{ % these are arbitrary attribute values - tweak them to suit your tastes }
  NORMATTR:=37; { % }
  BACKATTR:=37; { % }
  BORDATTR:=36; { % }
  OFFSET:=0;
  INSERTON:=TRUE;
  XLINE:=FALSE;
  HEIGHT:=R2-R1+1;  { current height of text window }
  WIDTH:=C2-C1+1;   { current width (in columns) of text window }
  SCRBUMP:=WIDTH DIV 2;
  VROW:=1;          { virtual row and column of cursor inside text window }
  VCOLUMN:=1;

{ % maxcolumn sets automatic formatting and word wrapping !! }
{  MAXCOLUMN:=WIDTH; { set to 0 to disable word wrap and line length limits }
  MAXCOLUMN:=0;   { no word wrapping }

  position:=1;
  wintop:=1;
  IF DRAWBOX THEN BEGIN
    DRAW_BOX(R1,C1,R2,C2);
    { DRAW_BOX must be prior to initialize window if not using qwik }
    INITIALIZE_WINDOW(R1,C1,R2,C2);
  END;
END;
(***************************************************************************)
PROCEDURE EDIT(PT:POINTER;VAR RETURNCODE:BYTE);
{ Edit text; assumes text has already been initialized }
BEGIN
  TXT:=PT;    { assign specified text pointer to working name }
  SHOW_TXT;

  RETURNCODE:=PARSE_INPUT;
{ RETURNCODE the following values based on keys pressed:
      1=ESC
      2=ALT-X
      3=F1
      4=F10
      5=F2
}
END;
(***************************************************************************)
END. { Unit MPEDITOR.PAS }
