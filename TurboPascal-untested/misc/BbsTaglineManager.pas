(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0181.PAS
  Description: BBS Tagline Manager
  Author: MIKE COPELAND
  Date: 05-31-96  09:17
*)

{
 GC> Does anyone know how to make a Pascal program to sort a file and
 GC> then remove the duplicates and choose a random line ??  I need this for
 GC> my tagline file and need some type of program to do this.  Thanks!

   Here's a start for you:
}
program TagLines_Manager;               { TagLines Manager  MRCopeland 950906}
{$M 32768,0,655000}
Uses CRT,DOS,FastTTT5,WinTTT5,RPU1;
const
     VERSION = '1.2.4';
     TLIM    = 10000;                                        { TagLines Limit
}     CLIM    = 100;                                   { Comment records Limit
}type
     S80     = string[80];
     LLPTR   = ^S80;
var
    I, J, K  : integer;
    TX,CT,XT : integer;                            { Areas, i/p record counts
}    PAX,CRX  : integer;                                 { Pointer Array indeX
}    STATUS   : integer;
    HRF      : boolean;                                  { Header Record Flag
}    DTIME    : LongInt;                             { Original File Date/Time
}    DT       : DateTime;
    DS       : DirStr;
    NS       : NameStr;
    ES       : ExtStr;
    PRIOR,T  : S80;
    PA       : array[1..TLIM] of LLPTR;   { Pointer Array for stored TagLines
}    CRECS    : array[1..CLIM] of LLPTR;                     { Comment Records
}
procedure HEADER;
begin
  ClrScr;
  WriteCenter (2,LightGray,Black,'**** TagLines Manager - Ver '+VERSION+'
****')end;  { HEADER }

procedure INITIALIZE;                         { initialize system & variables
}begin
  HEADER;
  if ParamCount > 0 then F3 := ParamStr(1)
  else
    begin
      WPROM (LONORM,'Enter TagLines filename: '); readln (F3);
    end;
  if not EXISTS (F3) then FATAL ('Cannot Open '+F3+' as input file');
  FastWrite (1,25,LONORM,FSI(MemAvail,1)+' Bytes @ start ');
  for I := 1 to TLIM do PA[I] := Nil;
  for I := 1 to CLIM do CRECS[I] := Nil;
  BBOPEN (FV3,F3,'r',BUFFIN);
  GetFTime (FV3,DTIME); UnPackTime (DTIME,DT)
end;  { INITIALIZE }

procedure SORT_TAGS (LEFT,RIGHT : word);                   { Lo-Hi QuickSort }
var LOWER,UPPER,MIDDLE : word;
    PIVOT              : S80;
begin
  LOWER := LEFT; UPPER := RIGHT; MIDDLE := (LEFT+RIGHT) Shr 1;
  PIVOT := PA[MIDDLE]^;
  repeat
    while PA[LOWER]^ < PIVOT do Inc(LOWER);
    while PIVOT < PA[UPPER]^ do Dec(UPPER);
    if LOWER <= UPPER then
      begin
        T := PA[LOWER]^; PA[LOWER]^ := PA[UPPER]^;
        PA[UPPER]^ := T; Inc (LOWER); Dec (UPPER)
      end;
  until LOWER > UPPER;
  if LEFT < UPPER then SORT_TAGS (LEFT, UPPER);
  if LOWER < RIGHT then SORT_TAGS (LOWER, RIGHT)
end;                                                              { SORT_TAGS
}
procedure READ_TAGS;
var P : Word;
begin
  CT := 0; TX := 0; XT := 0; PAX := 0; CRX := 0;
  while not EOF (FV3) do
    begin
      readln (FV3,S1); Inc (CT); FastWrite (1,DSLINE,LONORM,FSI(CT,5));
      CH := S1[1]; S2 := TTB(S1);
      if CH in [';','%','@'] then                           { Comment Records }
        begin
          Inc (CRX);
          if CRX <= CLIM then
            begin
              New (CRECS[CRX]); CRECS[CRX]^ := S2; Inc (XT);
              FastWrite (13,DSLINE,HINORM,FSI(CRX,4))
            end
        end
      else
        begin                                                      { TagLines }
          if Copy(S2,1,4) = '... ' then Delete (S2,1,4);       { flush header}
          while (Pos(' -- ',S2) > 0) do              { change " -- ' to " - " }
            begin
              P := Pos(' -- ',S2); Delete (S2,P+1,1)
            end;
          while (Length(S2) > 0) and (S2[1] = ' ') do Delete (S2,1,1);
          if Length(S2) > 0 then
            begin
              Inc (PAX);
              if PAX <= TLIM then
                begin
                  New (PA[PAX]); PA[PAX]^ := S2; Inc (TX);
                  FastWrite (7,DSLINE,LONORM,FSI(PAX,4))
                end
            end  { if }
        end;
    end;
  FastWrite (50,25,LONORM,FSI(MemAvail,1)+' Bytes with data loaded');
  Close (FV3); Dispose (BUFFIN);
  SORT_TAGS (1,PAX);
  FSplit(F3,DS,NS,ES); F1 := DS+NS+'.BAK';
  if EXISTS (F1) then
    begin
      Assign (FV1,F1); Erase(FV1)
    end;
  ReName (FV3,F1); BBOPEN (FV3,F3,'w',BUFFOUT); PRIOR := '';
  CT := 0;
  for I := 1 to CRX do                              { write out comment lines
}    writeln (FV3,CRECS[I]^);
  XT := 0;
  for I := 1 to PAX do                            { write out sorted TagLines
}    begin
      Inc (CT);
      if PA[I]^ <> PRIOR then
        begin
          PRIOR := PA[I]^; writeln (FV3,PRIOR); Inc (XT)
        end;
      FastWrite (20,DSLINE,LONORM,FSI(CT,5)+FSI(XT,5))
    end;
  Close (FV3); Dispose (BUFFOUT)
end;  { READ_TAGS }

begin  { MAIN LINE }
  STATUS := 0;
  INITIALIZE;                                 { initialize system & variables}
  READ_TAGS;                        { read & store selected records, reformat}
  WriteCenter (ERLINE,LightGray,Black,'Finis...'); PAUSE
end.

