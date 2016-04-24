(*
  Category: SWAG Title: SEARCH/FIND/REPLACE ROUTINES
  Original name: 0018.PAS
  Description: Position Search
  Author: GUY MCLOUGHLIN
  Date: 10-28-93  11:36
*)

{===========================================================================
Date: 10-07-93 (13:12)
From: GUY MCLOUGHLIN
Subj: Pos-Search Demo
---------------------------------------------------------------------------}

 {.$DEFINE DebugMode}

 {$IFDEF DebugMode}

   {$A+,B-,D+,E-,F-,I+,L+,N-,O-,R+,S+,V+}
   {$M 4096,65536,65536}

 {$ELSE}

   {$A+,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V-}
   {$M 4096,65536,65536}

 {$ENDIF}

              (* Public-domain Search routine, using the standard TP  *)
              (* POS function. Guy McLoughlin - May 16, 1993.         *)
program DemoPosSearch;


  (***** Force alphabetical characters to uppercase.                  *)
  (*                                                                  *)
  procedure UpCaseData({input } var Data;
                                    wo_Size : word); far; assembler;
  asm
    push  ds
    cld
    lds   si, Data
    mov   di, si
    mov   cx, wo_Size
    xor   ah, ah

  @L1:
    jcxz  @END
    lodsb
    cmp   al, 'a'
    jb    @L2
    cmp   al, 'z'
    ja    @L2
    sub   al, 20h

  @L2:
    stosb
    loop  @L1

  @END:
    pop ds

  end;        (* UpCaseData.                                          *)


  (***** PosSearch function. Returns 0 if string is not found.        *)
  (*     Returns 65,535 if BufferSize is too large.                   *)
  (*     ie: Greater than 65,520 bytes.                               *)
  (*                                                                  *)
  function PosSearch({input } var Buffer;
                                  BuffSize  : word;
                                  Pattern   : string;
                                  ExactCase : boolean) : {output} word;
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
    by_IncSize := (255 - pred(length(Pattern)));
    po_Buffer := addr(Buffer);
    if NOT ExactCase then
      begin
        UpCaseData(po_Buffer^, BuffSize);
        for wo_Index := 1 to length(Pattern) do
          Pattern[wo_Index] := upcase(Pattern[wo_Index])
      end;

    wo_Index := 0;
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
  st_Temp := 'aBcDeFgHiJkLmNoPqRsT';
  move(st_Temp[1], Buffer^[65501], length(st_Temp));
  st_Temp := 'AbCdEfGhIjKlMnOpQrSt';
  Index := PosSearch(Buffer^, sizeof(Buffer^), st_Temp, false);
  writeln(st_Temp, ' found at offset ', Index)
END.


