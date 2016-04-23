(*
>Does anyone know of a utility Program that will apply some sort of
>reasonable structuring to a pascal source File?

I'm not sure if it's what you want, but the source For a Pascal
reFormatter, etc, was entered in the Fidonet PASCAL Programming
Competition, and came third (I came second!!).

As you can see by the File dates, this is a very recent thing and
since it is Nearly too late I toyed With the idea of just keeping it
to myself.  It certainly is not an example of inspired Programming.
But then, I thought, if everyone felt that way you'd have nothing to
chose from and even if this is not a prize winner, mayby someone
else will find it useful.

So here it is...  not extensively tested, but I couldn't find any
bugs.  Used Pretty to reFormat itself and it still Compiled and
worked.  Anyway, the only possible use is to another Turbo Pascal
Programmer who shouldn't have any difficult modifying to suit
himself.  They'd probably do that anyway since the output represents
my own peculiar notion as to what a readable Format should be.

'Pretty Printers' date back to the earliest Computer days and
Variations existed For just about any language.  However, I've been
unable to find a current one For Turbo Pascal.

Here's what this one does:

Pretty With no parameters generates a syntax message.

Input is scanned line-by-line, Word-by-Word and Byte-by-Byte.  Any
identifiers recognized as part of TP's language are replaced by
mixed Case (in a style which _I_ like).  Someone else can edit
Constants Borland1 through Borland5 and TP3.  (Why TP3 later.)  The
first one on a line is capitalized anyway.

A fallout of this is to use selected ones to determine indentation
in increments of 'IndentSpcs' which I arbitrarily set to 3.  Change
if you like. Indentation is incremented whenever one of the
'IndentIDs' appears and decremented With 'UnindentIDs' (surprise!).

Single indents are also provided For 'SectionIDs' (Const, Type,
Uses, Var) and For 'NestIDs' (Procedure Function) to make these more
visible.  White space is what does it, right?

On the other hand, no attempt is made to affect white space in the
vertical direction.  Since that generally stays the way you
originate it.

Any '{', '(' or '''' (Single quote) detected during the line scan
trigger a 'skipit' mode which moves the enclosed stuff directly to
output, unmodified. With one exception.  {Comments} which begin a
line are aligned to the left margin (where I like to see Compiler
directives and one line Procedure/Function explanations).  Other
{Comments} which begin/end on the same line are shifted so the '}'
aligns at the (80th column) right margin.  I think this makes them
more visible than when snuggled up to a semi-colon and getting them
away from the code makes it more legible, too.

and it did look better originally when it used some of my personal
Units. Hastily modified to stand alone.  There are, no doubt, some
obvious ways the Programming can be improved (you would probably
have used some nice hash tables to look up key Words) but, as I say,
I thought I would be the only one using this and speed in this Case
is not all that important.

With one exception.  Something I worked up For an earlier
application and may be worth looking at -- 'LowCase'.

It will Compile With TP4-TP5.5 and probably TP6 (if it still
supports Inline). I included TP3 stuff because some of the old
software I was looking at was written in it.  and it recognizes
Units in a clumsy sort of way.

Switching to chat mode here.  if you're Really busy, you can skip the
following.

This thing actually began as a 'Case-converter'.  I was trying to
avoid re-inventing some wheels by re-working some old Pascal source
dating back to the late 70's and 80's.  Upper Case Programs became a
'standard' back in the days when you talked to main frames through a
teleType machine, which has no lower Case.  Sadly, this persisted
long after it was no longer necessary and I find those
all-upper-Case Programs almost unreadable.  That is I can't find
what I'm looking For.  They were making me crazy.  (BTW I suspect
some of this has to do With why Pascal has UpCase but no LoCase.)

I stole the orginal LowCase included here from someone who had done
the intuitive thing -- first test For 'A', then For 'Z'.  Changing
to an initial test For 'Z' does two things.  A whopping 164 of the
255 possible Characters can be eliminated With just one test and,
since ordinary Text consists of mostly lower Case, these will be
passed over rapidly.

When you received this you thought, "Who the heck is Art Weller?  I
don't remember him on the Pascal Echo."  Right.  I'm a 'lurker'!
Been reading the echo since beFore it had a moderator.  (Now we have
an excellent one.  Thank you.) I have a machine on a timer which
calls the BBS each morning to read and store several echos which I
read later.  Rarely get inspired enough to call back and enter a
discussion.  Things usually get resolved nicely without me.  I
especially don't want to get involved in such as the 'Goto' wars.
But I monitor the better discussions to enhance my TP skills.

I'm not Really a Programmer (no Formal training, that is --
Computers hadn't been invented when I was in school!), but an
engineer.  I'm retired from White Sands Missile Range where I was
Chief of Plans and Programs For (mumble, mumble) years.  I
self-taught myself Computers when folks from our Analysis and
Computation Directorate started using jargon on me.  I did that well
enough to later help Write a book For people who wanted to convert
from BASIC to Pascal then after "retiring" was an editor For a small
Computer magazine (68 Micro-Journal).

In summary, if you think this worth sharing With others I'll be
pleased enough even without a prize.  not even sure it will get
there in time.  Snail-Mail, you know.
*)

Program Pretty;
{A 'Pretty Printer' For Turbo Pascal Programs}
{  This Program converts Turbo Pascal identifiers in a source code File to
   mixed Case and indents the code.
   Released into Public Domain June, 1992 on an 'AS IS' basis.  Enjoy at your
   own risk.
                                                    Art Weller
                                                    3217 Pagosa Court
                                                    El Paso, Texas  79904
                                                    U. S. A.
                                                    Ph. (915) 755-2516}

{Uses
   Strings;}

Const
   IndentSpcs = 3;

   Borland1 =
   ' Absolute Addr and ArcTan Array Assign AuxInptr AuxOutptr BDos begin Bios '+
   ' BlockRead BlockWrite Boolean Buflen Byte Case Chain Char Chr Close ClrEol '+
   ' ClrScr Color Concat Const Copy Cos Delay Delete DelLine Dispose div do ';
   Borland2 =
   ' Downto Draw else end Eof Eoln Erase Execute Exp External False File '+
   ' FilePos FileSize FillChar Flush For Forward Frac Freemem Function Getmem '+
   ' Goto GotoXY Halt HeapPtr Hi HighVideo HiRes if Implementation in Inline ';
   Borland3 =
   ' Input Insert InsLine Int Integer Interface Intr IOResult KeyPressed '+
   ' Label Length Ln Lo LowVideo Lst Mark MaxAvail Maxint Mem MemAvail Memw Mod '+
   ' Move New Nil NormVideo not Odd of Ofs or Ord Output Overlay Packed ';
   Borland4 =
   ' Pallette Pi Plot Port Pos Pred Procedure Program Ptr Random Randomize Read '+
   ' ReadLn Real Record Release Rename Repeat Reset ReWrite Round Seek Seg Set '+
   ' Shl Shr Sin SizeOf Sound Sqr Sqrt Str String Succ Swap Text then to ';
   Borland5 =
   ' True Trunc Type Unit Until UpCase Uses UsrOutPtr Val Var While Window With '+
   ' Write WriteLn xor ';
   TP3 =
   ' AUX CONinPTR CON CONOUTPTR ConstPTR CrtEXIT CrtinIT ERRorPTR Kbd '+
   ' LStoUTPTR TRM USR USRinPTR ';

   IndentIDs   = ' begin Case Const Record Repeat Type Uses Var ';
   UnIndentIDs = ' end Until ';
   SectionIDs  = ' Const Type Uses Var ';
   endSection  = ' begin Const Uses Var Function Implementation Interface '+
                 ' Procedure Type Unit ';
   NestIDs     = ' Function Procedure Unit ';

   IDAlphas    = ['a'..'z', '1'..'0', '_'];

Var
   Indent,
   endPend,
   Pending,
   UnitFlag       : Boolean;
   NestLevel,
   NestIndent,
   IndentNext,
   IndentNow,
   Pntr, LineNum  : Integer;
   IDs,
   InFile,
   OutFile,
   ProgWrd,
   ProgLine       : String;
   Idents,
   OutID          : Array [1..5] of String;
   f1, f2         : Text;

Function  LowCase(Ch: Char): Char;
begin
  Inline(
   $8A/$86/>Ch/                          {      mov al,>Ch[bp]   ;Char to check}
   $3C/$5A/                              {      cmp al,'Z'                     }
   $7F/$06/                              {      jg  Done                       }
   $3C/$41/                              {      cmp al,'A'                     }
   $7C/$02/                              {      jl  Done                       }
   $0C/$20/                              {      or al,$20                      }
   $88/$86/>LowCase);                    {Done :mov >LowCase[bp],al            }
end;

Function LowCaseStr(InStr : String): String;
Var
  i  : Integer;
  len: Byte Absolute InStr;
begin
  LowCaseStr[0] := Chr(len);
  For i := 1 to len do
  LowCaseStr[i] := LowCase(InStr[i]);
end;

Function  Blanks(Count: Byte): String; {return String of 'Count' spaces}
Var
  Result: String;
begin
  FillChar(Result[1], Count+1, ' ');
  Result[0] := Chr(Count);
  Blanks := Result;
end;

Procedure StripLeading(Var Str: String);  {remove all leading spaces}
begin
  While (Str[1] = #32) and (length(Str) > 0) do
    Delete(Str,1,1);
end;

Procedure Initialize;
begin
  IDs := IndentIDs + UnIndentIDs + endSection;
  OutID[1] := Borland1;
  Idents[1] := LowCaseStr(OutID[1]);
  OutID[2] := Borland2;
  Idents[2] := LowCaseStr(OutID[2]);
  OutID[3] := Borland3;
  Idents[3] := LowCaseStr(OutID[3]);
  OutID[4] := Borland4;
  Idents[4] := LowCaseStr(OutID[4]);
  OutID[5] := Borland5 + TP3;
  Idents[5] := LowCaseStr(OutID[5]);
  Pending := False;
  UnitFlag := False;
  IndentNext := 0;
  IndentNow := 0;
  LineNum := 0;
  NestIndent := 0;
  NestLevel := 0;
end;

Procedure Greeting;
begin
  Writeln;
  Writeln('Pascal Program Indenter');
  Writeln; Writeln;
  Writeln('SYNTAX:  INDENT InputFile OutPutFile');
  Writeln('         INDENT InputFile > OutPut');
  Writeln; Writeln;
  Halt(0);
end;

Procedure OpenFiles;
begin
  if paramcount <> 0 then
  begin
    InFile := ParamStr(1);
    if (pos('.', InFile) = 0) then
      InFile := InFile + '.pas';
    OutFile := Paramstr(2);
  end
  else
    Greeting;
  Assign(f1, InFile);
  Reset(f1);
  Assign(f2, OutFile);
  ReWrite(f2);
end;

Procedure GetWord;
Var
  i,
  index,
  TmpPtr,
  WrdPos   : Integer;

  Procedure DecIndent;
  begin
    if (IndentNext > IndentNow) then   {begin/end on same line}
      Dec(IndentNext)
    else
    if IndentNow > 0 then
      dec(IndentNow);
    IndentNext := IndentNow;    {next line, too}
  end;

begin
  ProgWrd := ' ';
  TmpPtr := Pntr;

  While (LowCase(ProgLine[Pntr]) in IDAlphas) {Convert checked For LCase alpha}
        and (Pntr <= length(ProgLine)) do
  begin
    ProgWrd := ProgWrd + LowCase(ProgLine[Pntr]);
    Inc(Pntr);
  end;

  ProgWrd := ProgWrd+' ';   {surrounded With blanks to make it unique!}
  index := 0;

  Repeat;     {is it a Turbo Pascal Word?}
    inc(index);
    WrdPos := Pos(ProgWrd, Idents[index]);
  Until (WrdPos <> 0) or (index = 5);

  if WrdPos <> 0 then   {found a Pascal Word}
  begin
    Move(OutID[index][WrdPos+1], ProgLine[TmpPtr], Length(ProgWrd)-2);
    if TmpPtr = 1 then
      ProgLine[1] := UpCase(ProgLine[1]);

    if Pos(ProgWrd, IDs) <> 0 then  {only checked if a Pascal Word ^}
    begin
      if Pos(ProgWrd, endSection) <> 0 then  {this includes "SectionIDs"}
      begin                                      {and "NestIDs"}
        if (pos(ProgWrd, NestIDs) <> 0) then
        begin
          if ProgWrd = ' Unit ' then
            UnitFlag := True;
          if not UnitFlag then
            inc(NestLevel);
        end;
        if Pending then
          DecIndent;
        Pending := Pos(ProgWrd, SectionIDs) <> 0;
        if ProgWrd = ' Implementation ' then
          UnitFlag := False;
      end;
      if Pos(ProgWrd, IndentIDs) <> 0 then
        inc(IndentNext); {Indent 1 level}
      if Pos(ProgWrd, UnIndentIDs) <> 0 then
      begin
         DecIndent;   {Unindent 1 level}
         if (IndentNow = 0) and (NestLevel > 0) then
           dec(NestLevel);
      end;
      if NestLevel > 1 then
        NestIndent := 1;
    end;
  end;
end;

Procedure Convert;

  Procedure OutLine;
  Var
    Tabs : String[40];
  begin
    Tabs := Blanks((IndentNow+NestIndent) * IndentSpcs);
    if ProgLine[1] = '{' then
      Writeln(f2, ProgLine)
    else
      Writeln(f2, Tabs, ProgLine);
    IndentNow := IndentNext;   { get ready For next line }
    if NestLevel < 2 then
      NestIndent := 0;
  end;

  Procedure Skipto(SearchChar: Char);
  begin
    Repeat
      if pntr > Length(ProgLine) then
      begin
        OutLine;
        Readln(f1, ProgLine);   {get another line}
        Pntr := 0;
      end;
      Inc(pntr);
    Until (ProgLine[pntr] = SearchChar) or Eof(f1);
  end;

  Procedure MoveComments;
  Var
    TmpIndent : Integer;
  begin
    if (ProgLine[1] = '{') or (ProgLine[Pntr+1] = '$') then
    begin
      Skipto('}');
      Exit;
    end;
    TmpIndent := (IndentNow+NestIndent) * IndentSpcs;
    While Length(ProgLine) < 80-TmpIndent do
      Insert(' ', ProgLine, Pntr);
    While (pos('}', ProgLine) > 80-TmpIndent) and (pos(' {', ProgLine) > 1) do
    begin
      Delete(ProgLine, Pos(' {', ProgLine), 1);
      Dec(Pntr);
    end;
    Skipto('}');
  end;

begin
  While not Eof(f1) do
  begin
    Readln(f1, ProgLine);
    StripLeading(ProgLine);
    if Length(ProgLine) = 0 then
      Writeln(f2)
    else
    begin
      Pntr := 1;
      Repeat
        Case LowCase(ProgLine[pntr]) of
          'a'..'z','_'  :  GetWord;
          '{'           :  MoveComments;
          '('           :  Skipto(')');
          #39           :  Skipto(#39)        {Single quote}
        end;
        Inc(pntr)
      Until (pntr >= length(ProgLine));
      OutLine;
    end;
  end;  { While }
  Close(f1); Close(f2);
end;

begin
  Initialize;
  OpenFiles;
  Convert;
end.
