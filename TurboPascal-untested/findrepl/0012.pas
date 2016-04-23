
  Hi, Andy:

  ...Just for fun I also threw together a "PosSearch" routine
  that uses the built-in TP "POS" function. It actually performs
  better than I thought it would, as it takes a string longer than
  15 characters before it starts to become slower than the Boyer-
  Moore function I just posted. (ie: PosSearch is faster than the
  Boyer-Moore routine for strings that are smaller than 16 chars)
  Here's a demo program of the "PosSearch" search routine I put
  together. *Remember* to turn-off "range-checking" {$R-} in your
  finished program, otherwise the PosSearch will take longer than
  it should to execute.

              (* Public-domain Search routine, using the standard TP  *)
              (* POS function. Guy McLoughlin - May 1, 1993.          *)
program DemoPosSearch;


  (***** PosSearch function. Returns 0 if string is not found.        *)
  (*     Returns 65,535 if BufferSize is too large.                   *)
  (*     ie: Greater than 65,520 bytes.                               *)
  (*                                                                  *)
  function PosSearch({input } var Buffer;
                                  BuffSize : word;
                                  Pattern  : string) : {output} word;
  type
    arwo_2    = array[1..2] of word;
    arch_255  = array[1..255] of char;
  var
    po_Buffer  : ^arch_255;
    by_Temp,
    by_IncSize : byte;
    wo_Index   : word;
  begin
    if (BuffSize > 65520) then
      begin
        PosSearch := $FFFF;
        exit
      end;
    wo_Index := 0;
    by_IncSize := (255 - pred(length(Pattern)));
    po_Buffer := addr(Buffer);
    repeat
      by_Temp := pos(Pattern, po_Buffer^);
      if (by_Temp = 0) then
        begin
          inc(wo_Index, by_IncSize);
          inc(arwo_2(po_Buffer)[1], by_IncSize)
        end
      else
        inc(wo_Index, by_Temp)
    until (by_Temp <> 0) or (wo_Index > BuffSize);
    if (by_Temp = 0) then
      PosSearch := 0
    else
      PosSearch := wo_Index
  end;        (* PosSearch.                                           *)


type
  arby_64K = array[1..65520] of byte;

var
  Index   : word;
  st_Temp : string[20];
  Buffer  : ^arby_64K;

BEGIN
  new(Buffer);
  fillchar(Buffer^, sizeof(Buffer^), 0);
  st_Temp := '12345678901234567890';
  move(st_Temp[1], Buffer^[65501], length(st_Temp));
  Index := PosSearch(Buffer^, sizeof(Buffer^), st_Temp);
  writeln(st_Temp, ' found at offset ', Index)
END.

                               - Guy
---
 ■ DeLuxe²/386 1.25 #5060 ■
 * Rose Media, Toronto, Canada : 416-733-2285
 * PostLink(tm) v1.04  ROSE (#1047) : RelayNet(tm)

                                                                     