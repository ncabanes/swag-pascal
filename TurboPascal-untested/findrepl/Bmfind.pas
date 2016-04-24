(*
  Category: SWAG Title: SEARCH/FIND/REPLACE ROUTINES
  Original name: 0001.PAS
  Description: BMFIND.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:46
*)


  Hi, Andy:

  ...Here's a demo program of the Boyer-Moore search algorithm.

  The basic idea is to first create a Boyer-Moore index-table
  for the string you want to search for, and then call the
  BMsearch routine. *Remember* to turn-off "range-checking"
  {$R-} in your finished program, otherwise the BMSearch will
  take 3-4 times longer than it should.

              (* Public-domain demo of Boyer-Moore search algorithm.  *)
              (* Guy McLoughlin - May 1, 1993.                        *)
program DemoBMSearch;

              (* Boyer-Moore index-table data definition.             *)
type
  BMTable  = array[0..127] of byte;

  (***** Create a Boyer-Moore index-table to search with.             *)
  (*                                                                  *)
  procedure Create_BMTable({input }     Pattern : string;
                           {update} var     BMT : BMTable);
  var
    Index : byte;
  begin
    fillchar(BMT, sizeof(BMT), length(Pattern));
    for Index := 1 to length(Pattern) do
      BMT[ord(Pattern[Index])] := (length(Pattern) - Index)
  end;        (* Create_BMTable.                                      *)

  (***** Boyer-Moore Search function. Returns 0 if string is not      *)
  (*     found. Returns 65,535 if BufferSize is too large.            *)
  (*     ie: Greater than 65,520 bytes.                               *)
  (*                                                                  *)
  function BMsearch({input } var Buffer;
                                 BuffSize : word;
                             var BMT      : BMTable;
                                 Pattern  : string) : {output} word;
  var
    Buffer2 : array[1..65520] of char absolute Buffer;
    Index1,
    Index2,
    PatSize : word;
  begin
    if (BuffSize > 65520)  then
      begin
        BMsearch := $FFFF;
        exit
      end;
    PatSize := length(Pattern);
    Index1 := PatSize;
    Index2 := PatSize;
    repeat
      if (Buffer2[Index1] = Pattern[Index2]) then
        begin
          dec(Index1);
          dec(Index2)
        end
      else
        begin
          if (succ(PatSize - Index2) > (BMT[ord(Buffer2[Index1])])) then
            inc(Index1, succ(PatSize - Index2))
          else
            inc(Index1, BMT[ord(Buffer2[Index1])]);
          Index2 := PatSize
        end;
    until (Index2 < 1) or (Index1 > BuffSize);
    if (Index1 > BuffSize) then
      BMsearch := 0
    else
      BMsearch := succ(Index1)
  end;        (* BMsearch.                                            *)

type
  arby_64K = array[1..65520] of byte;

var
  Index   : word;
  st_Temp : string[10];
  Buffer  : ^arby_64K;
  BMT     : BMTable;

BEGIN
  new(Buffer);
  fillchar(Buffer^, sizeof(Buffer^), 0);
  st_Temp := 'Gumby';
  move(st_Temp[1], Buffer^[65516], length(st_Temp));
  Create_BMTable(st_Temp, BMT);
  Index := BMSearch(Buffer^, sizeof(Buffer^), BMT, st_Temp);
  writeln(st_Temp, ' found at offset ', Index)
END.
                               - Guy
---
 ■ DeLuxe²/386 1.25 #5060 ■
 * Rose Media, Toronto, Canada : 416-733-2285
 * PostLink(tm) v1.04  ROSE (#1047) : RelayNet(tm)

                                                           
