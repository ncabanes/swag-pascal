(*
  From: Mike Copeland                                Read: Yes    Replied: No
>>    This is definitely possible in Turbo/Borland Pascals, and
>> you don't need any ASM, either.  The basic process is to (1)
>> read the entire file into memory (probably to the Heap, via
>> pointers) and (2) display "pages" of the data, using ReadKey
>> interpretation to "move" through the data (starting with
>> record 1-20, and adjusting what you display by whatever key
>> "command" is invoked.

   Here it is {tested}.  Note that I use some TechnoJocks screen
i/o routines here, but you should be able to substitute normal TP/BP
procedures.  Also, I wrote this program to process Tagline files, so the
"record" is limited to 80 character strings - you can change that, too,
as needed...
*)

program Text_File_Viewer;                    { MRCopeland 941231 }
{$M 8192,0,655000}
Uses CRT,DOS,FastTTT5,WinTTT5,RPU1;

const VERSION = '1.0';
      TLIM    = 10000;                           { Records Limit }
type  S80     = string[80];
      LLPTR   = ^S80;
var   I,J,K   : integer;
      PAX,B,E : integer;                   { Pointer Array indeX }
      OFFSET  : integer;
      DONE    : boolean;
      T       : S80;
      PA      : array[1..TLIM] of LLPTR;  {  P/A for stored recs }

procedure HEADER;
begin
  ClrScr;
  WriteCenter (2,LightGray,Black,'**** Scrolling Viewer - Ver '+
              VERSION+'****');
end;  { HEADER }

procedure INITIALIZE;            { initialize system & variables }
begin
  HEADER;
  if ParamCount > 0 then F3 := ParamStr(1)
  else
    begin
      WPROM (LONORM,'Enter filename: '); readln (F3);
    end;
  if not EXISTS (F3) then FATAL ('Cannot Open '+F3+' as input file');
  FastWrite (1,25,LONORM,FSI(MemAvail,1)+' Bytes @ start ');
  for I := 1 to TLIM do PA[I] := Nil;
  BBOPEN (FV3,F3,'r',BUFFIN); OFFSET := 1  { default record offset }
end;  { INITIALIZE }

procedure SORT_RECS (LEFT,RIGHT : word);         { Lo-Hi QuickSort }
var LOWER,UPPER,MIDDLE : Word;
    PIVOT              : S80;
begin
  LOWER := LEFT; UPPER := RIGHT; MIDDLE := (LEFT+RIGHT) Shr 1;
  PIVOT := PA[MIDDLE]^;
  repeat
    while PA[LOWER]^ < PIVOT do Inc(LOWER);
    while PIVOT < PA[UPPER]^ do Dec(UPPER);
    if LOWER <= UPPER then
      begin
        T := PA[LOWER]^; PA[LOWER]^ := PA[UPPER]^; PA[UPPER]^ := T;
        Inc (LOWER); Dec (UPPER);
      end;
  until LOWER > UPPER;
  if LEFT < UPPER then SORT_RECS (LEFT, UPPER);
  if LOWER < RIGHT then SORT_RECS (LOWER, RIGHT)
end;  { SORT_RECS }

procedure DISPLAY_PAGE (F,L : integer);
Var N,M : integer;
begin
  ClrScr; M := 0;
  for N := F to L do
    begin
      Inc (M); FastWrite (1,M,HINORM,Copy(PA[N]^,OFFSET,80))
    end
end;  { DISPLAY_PAGE }

procedure DO_HOME;
begin
  B := 1; E := 20;
  if E > PAX then E := PAX
end;  { DO_HOME }

procedure CHECK_END;
begin
  if E <= 0 then E := 1;
  if E > PAX then E := PAX;
  B := E-19;
  if B <= 0 then B := 1
end;  { CHECK_END }

function GET_CMD : char;                         { Get User Command }
Var WCH : char;
begin
  WriteCenter (DSLINE,LightGray,Black,'Cursor keys to move; Q or Esc to Quit');
  WPROM (LONORM,'Command: '); WCH := ReadKey;{ fetch user keystroke }
  case WCH of
    #00 : begin                        { special/extended keystroke }
            WCH := ReadKey;
            case WCH of
              #71 : DO_HOME;                                 { Home }
              #79 : E := PAX;                                 { End }
              #72 : Dec (E);                              { UpArrow }
              #73 : Dec (E,20);                              { PgUp }
              #80 : Inc (E);                            { DownArrow }
              #13,                                            { c/r }
              #81 : begin                                    { PgDn }
                      Inc (E,20); WCH := ' ';
                    end;
              #77 : begin                                 { RtArrow }
                      Inc (OFFSET,10);
                      if OFFSET > 71 then OFFSET := 70
                    end;
              #75 : begin                               { LeftArrow }
                      Dec (OFFSET,10);
                      if OFFSET < 1 then OFFSET := 1
                    end;
            end  { case }
          end;
    else
  end;  { case }
  CHECK_END; GET_CMD := UpCase(WCH)
end;  { GET_CMD }

procedure READ_RECS;
begin
  PAX := 0;
  while not EOF (FV3) do
    begin
      readln (FV3,S1); Inc (CT); FastWrite (1,DSLINE,LONORM,FSI(CT,5));
      CH := S1[1]; S2 := TTB(S1); Inc (PAX);
      if PAX <= TLIM then
        begin
          New (PA[PAX]); PA[PAX]^ := S2;
          FastWrite (7,DSLINE,LONORM,FSI(PAX,4));
        end
    end;
  FastWrite (50,25,LONORM,FSI(MemAvail,1)+' Bytes with data loaded');
  Close (FV3); Dispose (BUFFIN);
  SORT_RECS (1,PAX);
  DONE := false; DO_HOME;              { set up 1st page of display }
  repeat               { display "pages" of data, using cursor keys }
    DISPLAY_PAGE(B,E);
    CH := GET_CMD; DONE := CH in [#27,'Q']
  until DONE
end;  { READ_RECS }

begin  { MAIN LINE }
  INITIALIZE;                       { initialize system & variables }
  READ_RECS;                           { read & store records, list }
  WriteCenter (ERLINE,LightGray,Black,'Finis...'); PAUSE
end.
