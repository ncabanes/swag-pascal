(*
  Category: SWAG Title: SEARCH/FIND/REPLACE ROUTINES
  Original name: 0004.PAS
  Description: BOYER.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:46
*)


              (* Public-domain demo of Boyer-Moore search algorithm.  *)
              (* Guy McLoughlin - May 2, 1993.                        *)
program DemoBMSearch;


              (* Boyer-Moore index-table data definition.             *)
type
  BMTable  = array[0..255] of byte;


  (***** Create a Boyer-Moore index-table to search with.             *)
  (*                                                                  *)
  procedure Create_BMTable({output} var       BMT : BMTable;
                           {input }       Pattern : string;
                                        ExactCase : boolean);
  var
    Index : byte;
  begin
    fillchar(BMT, sizeof(BMT), length(Pattern));
    if NOT ExactCase then
      for Index := 1 to length(Pattern) do
        Pattern[Index] := upcase(Pattern[Index]);
    for Index := 1 to length(Pattern) do
      BMT[ord(Pattern[Index])] := (length(Pattern) - Index)
  end;        (* Create_BMTable.                                      *)


  (***** Boyer-Moore Search function. Returns 0 if string is not      *)
  (*     found. Returns 65,535 if BufferSize is too large.            *)
  (*     ie: Greater than 65,520 bytes.                               *)
  (*                                                                  *)
  function BMsearch({input } var BMT       : BMTable;
                             var Buffer;
                                 BuffSize  : word;
                                 Pattern   : string;
                                 ExactCase : boolean) : {output} word;
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
    if NOT ExactCase then
      begin
        for Index1 := 1 to BuffSize do
          if  (Buffer2[Index1] > #96)
          and (Buffer2[Index1] < #123) then
            dec(Buffer2[Index1], 32);
        for Index1 := 1 to length(Pattern) do
          Pattern[Index1] := upcase(Pattern[Index1])
      end;
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
  st_Temp : string[20];
  Buffer  : ^arby_64K;
  BMT     : BMTable;

BEGIN
  new(Buffer);
  fillchar(Buffer^, sizeof(Buffer^), 0);
  st_Temp := 'aBcDeFgHiJkLmNoPqRsT';
  move(st_Temp[1], Buffer^[65501], length(st_Temp));
  st_Temp := 'AbCdEfGhIjKlMnOpQrSt';
  Create_BMTable(BMT, st_Temp, false);
  Index := BMSearch(BMT, Buffer^, sizeof(Buffer^), st_Temp, false);
  writeln(st_Temp, ' found at offset ', Index)
END.
                               - Guy
---
 ■ DeLuxe²/386 1.25 #5060 ■
 * Rose Media, Toronto, Canada : 416-733-2285
 * PostLink(tm) v1.04  ROSE (#1047) : RelayNet(tm)

                                                                               
