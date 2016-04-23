 (* Start of PART 1 of 7 *)

(***********************************************************************
          Contest 3 Entry : Anagram Sort by Guy McLoughlin
          Compiler        : Borland Pascal 7.0
***********************************************************************)

 {.$DEFINE DebugMode}

 {$IFDEF DebugMode}
   {$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T+,V+,X-}
 {$ELSE}
   {$A+,B-,D-,E-,F-,G+,I-,L-,N-,O-,P-,Q-,R-,S+,T-,V-,X-}
 {$endIF}

 {$M 16384,374784,655360}

Program Anagram_Sort;

Const
  co_MaxWord  =  2500;
  co_MaxSize  = 65519;
  co_SafeSize = 64500;

Type
  Char_12 = Array[1..12] of Char;

  st_4    = String[4];
  st_10   = String[10];
  st_80   = String[80];

  byar_26 = Array[97..122] of Byte;

  po_Buff     = ^byar_Buffer;
  byar_Buffer = Array[1..co_MaxSize] of Byte;

  porc_Word = ^rc_Word;
  rc_Word   = Record
                wo_Pos    : Word;
                ar_LtrChk : Char_12;
                st_Word   : st_10
              end;

  poar_Word     = Array[0..co_MaxWord] of porc_Word;

  porc_AnaGroup = ^rc_AnaGroup;
  rc_AnaGroup   = Record
                    wo_Pos   : Word;
                    st_Group : st_80
                  end;

  poar_AnaGroup = Array[0..co_MaxWord] of porc_AnaGroup;
  poar_Generic  = Array[0..co_MaxWord] of Pointer;

  (***** Check For I/O errors.                                        *)
  (*                                                                  *)
  Procedure CheckIOerror;
  Var
    by_Error : Byte;
  begin
    by_Error := ioresult;
    if (by_Error <> 0) then
      begin
        Writeln('Input/Output error = ', by_Error);
        halt
      end
  end;        (* CheckIOerror.                                        *)

  (***** Display HEAP error message.                                  *)
  (*                                                                  *)
  Procedure HeapError;
  begin
    Writeln('Insuficient free HEAP memory');
    halt
  end;        (* HeapError.                                        *)

Type
  Item     = Pointer;
  ar_Item  = poar_Generic;
  CompFunc = Function(Var Item1, Item2 : Item) : Boolean;

 (* end of PART 1 of 7 *)
 (* Start of PART 2 of 7 *)

  (***** QuickSort routine.                                           *)
  (*                                                                  *)
  Procedure QuickSort({update} Var ar_Data  : ar_Item;
                      {input }     wo_Left,
                                   wo_Right : Word;
                                   LessThan : CompFunc);
  Var
    Pivot,
    TempItem : Item;
    wo_Index1,
    wo_Index2 : Word;
  begin
    wo_Index1 := wo_Left;
    wo_Index2 := wo_Right;
    Pivot := ar_Data[(wo_Left + wo_Right) div 2];
    Repeat
      While LessThan(ar_Data[wo_Index1], Pivot) do
        inc(wo_Index1);
      While LessThan(Pivot, ar_Data[wo_Index2]) do
        dec(wo_Index2);
      if (wo_Index1 <= wo_Index2) then
        begin
          TempItem := ar_Data[wo_Index1];
          ar_Data[wo_Index1] := ar_Data[wo_Index2];
          ar_Data[wo_Index2] := TempItem;
          inc(wo_Index1);
          dec(wo_Index2)
        end
      Until (wo_Index1 > wo_Index2);
      if (wo_Left < wo_Index2) then
        QuickSort(ar_Data, wo_Left, wo_Index2, LessThan);
      if (wo_Index1 < wo_Right) then
        QuickSort(ar_Data, wo_Index1, wo_Right, LessThan)
  end;        (* QuickSort.                                           *)

  (***** Sort Function to check if anagram-Word's are in sorted order *)
  (*                                                                  *)
  Function AlphaSort(Var Item1, Item2 : Item) : Boolean; Far;
  begin
    AlphaSort := (porc_Word(Item1)^.st_Word < porc_Word(Item2)^.st_Word)
  end;        (* AlphaSort.                                           *)

  (***** Sort Function to check:                                      *)
  (*                                                                  *)
  (*        1 - If anagram-Words are sorted by length.                *)
  (*        2 - If anagram-Words are sorted by anagram-group.         *)
  (*        3-  If anagram-Words are sorted alphabeticly.             *)
  (*                                                                  *)
  Function Sort1(Var Item1, Item2 : Item) : Boolean; Far;
  begin
    if (porc_Word(Item1)^.st_Word[0] <>
                                      porc_Word(Item2)^.st_Word[0]) then
      Sort1 := (porc_Word(Item1)^.st_Word[0] <
                                           porc_Word(Item2)^.st_Word[0])
    else
      if (porc_Word(Item1)^.ar_LtrChk <>
                                       porc_Word(Item2)^.ar_LtrChk) then
        Sort1 := (porc_Word(Item1)^.ar_LtrChk <
                                            porc_Word(Item2)^.ar_LtrChk)
      else
        Sort1 := (porc_Word(Item1)^.wo_Pos < porc_Word(Item2)^.wo_Pos)
  end;        (* Sort1.                                               *)

  (***** Sort Function to check:                                      *)
  (*                                                                  *)
  (*     If anagram-group Strings are sorted alphabeticly.            *)
  (*                                                                  *)
  Function Sort2(Var Item1, Item2 : Item) : Boolean; Far;
  begin
    Sort2 := (porc_AnaGroup(Item1)^.wo_Pos <
                                           porc_AnaGroup(Item2)^.wo_Pos)
  end;        (* Sort2.                                               *)

 (* end of PART 2 of 7 *)
 (* Start of PART 3 of 7 *)

  (***** Check if the anagram-Word table is in sorted order.          *)
  (*                                                                  *)
  Function TableSorted({input } Var ar_Data  : poar_Word;
                                    wo_Left,
                                    wo_Right : Word) : {output} Boolean;
  Var
    wo_Index : Word;
  begin
              (* Set Function result to True.                         *)
    TableSorted := True;

              (* Loop through all but the last Word in the anagram-   *)
              (* Word "table".                                        *)
    For wo_Index := wo_Left to pred(wo_Right) do
              (* Check if the current and next anagram-Words are not  *)
              (* sorted.                                              *)
      if (ar_Data[wo_Index]^.st_Word >
                                ar_Data[succ(wo_Index)]^.st_Word) then
      begin
              (* Set Function result to False, and break the "for"    *)
              (* loop.                                                *)
        TableSorted := False;
        break
      end
  end;        (* TableSorted.                                         *)

  (***** Pack bits 0,1,2 of each Byte in 26 Byte Array into 10 Chars. *)
  (*                                                                  *)
  Procedure PackBits({input } Var byar_Temp : byar_26;
                     {output} Var Char_Temp : Char_12);
  begin
    Char_Temp[ 1] := chr((byar_Temp[ 97] and $7) shl 5 +
                         (byar_Temp[ 98] and $7) shl 2 +
                         (byar_Temp[ 99] and $6) shr 1);
    Char_Temp[ 2] := chr((byar_Temp[ 99] and $1) shl 7 +
                         (byar_Temp[100] and $7) shl 4 +
                         (byar_Temp[101] and $7) shl 1 +
                         (byar_Temp[102] and $4) shr 2);
    Char_Temp[ 3] := chr((byar_Temp[102] and $3) shl 6 +
                         (byar_Temp[103] and $7) shl 3 +
                         (byar_Temp[104] and $7));
    Char_Temp[ 4] := chr((byar_Temp[105] and $7) shl 5 +
                         (byar_Temp[106] and $7) shl 2 +
                         (byar_Temp[107] and $6) shr 1);
    Char_Temp[ 5] := chr((byar_Temp[107] and $1) shl 7 +
                         (byar_Temp[108] and $7) shl 4 +
                         (byar_Temp[109] and $7) shl 1 +
                         (byar_Temp[110] and $4) shr 2);
    Char_Temp[ 6] := chr((byar_Temp[110] and $3) shl 6 +
                         (byar_Temp[111] and $7) shl 3 +
                         (byar_Temp[112] and $7));
    Char_Temp[ 7] := chr((byar_Temp[113] and $7) shl 5 +
                         (byar_Temp[114] and $7) shl 2 +
                         (byar_Temp[115] and $6) shr 1);
    Char_Temp[ 8] := chr((byar_Temp[115] and $1) shl 7 +
                         (byar_Temp[116] and $7) shl 4 +
                         (byar_Temp[117] and $7) shl 1 +
                         (byar_Temp[118] and $4) shr 2);
    Char_Temp[ 9] := chr((byar_Temp[118] and $3) shl 6 +
                         (byar_Temp[119] and $7) shl 3 +
                         (byar_Temp[120] and $7));
    Char_Temp[10] := chr((byar_Temp[121] and $7) shl 5 +
                         (byar_Temp[122] and $7) shl 2)
  end;        (* PackBits.                                            *)

Var
  po_Buffer       : po_Buff;

  by_Index,
  by_LastAnagram,
  by_CurrentWord  : Byte;

  wo_Index,
  wo_ReadIndex,
  wo_TableIndex,
  wo_BufferIndex,
  wo_CurrentIndex : Word;

 (* end of PART 3 of 7 *)
 (* Start of PART 4 of 7 *)

  st_Temp         : st_4;

  byar_LtrChk     : byar_26;

  fi_Temp         : File;

  rcar_Table      : poar_Word;

  rcar_Groups     : poar_AnaGroup;


              (* Main Program execution block.                        *)
begin
              (* If there is sufficient room, allocate the main data- *)
              (* buffer on the HEAP.                                  *)
  if (maxavail > co_MaxSize) then
    new(po_Buffer)
  else
              (* Else, inform user of insufficient HEAP memory, and   *)
              (* halt the Program.                                    *)
    HeapError;

              (* Clear the data-buffer.                               *)
  fillChar(po_Buffer^, co_MaxSize, 0);

              (* Initialize counter Variable.                         *)
  wo_Index := 0;

              (* While the counter is less than co_MaxWord do...      *)
  While (co_MaxWord > wo_Index) do

              (* If there is sufficient memory, allocate another      *)
              (* anagram-Word Record on the HEAP.                     *)
    if (maxavail > sizeof(rc_Word)) then
      begin
        inc(wo_Index);
        new(rcar_Table[wo_Index]);
        fillChar(rcar_Table[wo_Index]^, sizeof(rc_Word), 0);
      end
    else
              (* Else, inform user of insufficient HEAP memory, and   *)
              (* halt the Program.                                    *)
      HeapError;

              (* Initialize counter Variable.                         *)
  wo_Index := 0;

              (* While the counter is less than co_MaxWord do...      *)
  While (co_MaxWord > wo_Index) do

              (* If there is sufficient memory, allocate another      *)
              (* anagram-group String on the HEAP.                    *)
    if (maxavail > sizeof(rc_AnaGroup)) then
      begin
        inc(wo_Index);
        new(rcar_Groups[wo_Index]);
        fillChar(rcar_Groups[wo_Index]^, sizeof(rc_AnaGroup), 32);
      end
    else
              (* Else, inform user of insufficient HEAP memory, and   *)
              (* halt the Program.                                    *)
      HeapError;

              (* Attempt to open File containing the anagram-Words.   *)
  assign(fi_Temp, 'WordLIST.DAT');

              (* Set Filemode to "read-only".                         *)
  Filemode := 0;
  {$I-}
  reset(fi_Temp, 1);
  {$I+}
              (* Check For I/O errors.                                *)
  if (ioresult <> 0) then
    begin
      Writeln('Error opening anagram data File ---> WordLIST.DAT');
      halt
    end;
              (* Read-in the entire anagram list into the data-buffer *)
  blockread(fi_Temp, po_Buffer^, co_MaxSize, wo_ReadIndex);

 (* end of PART 4 of 7 *)
 (* Start of PART 5 of 7 *)

              (* Check For I/O errors.                                *)
  CheckIOerror;

  close(fi_Temp);

              (* Check For I/O errors.                                *)
  CheckIOerror;

              (* Initialize index Variables.                          *)
  wo_TableIndex  := 0;
  wo_BufferIndex := 0;

              (* Repeat...Until all data in the data-buffer has been  *)
              (* processed.                                           *)
  Repeat

              (* Repeat...Until a valid anagram-Word Character has    *)
              (* been found, or the complete data-buffer has been     *)
              (* processed.                                           *)
    Repeat
      inc(wo_BufferIndex)
    Until ((po_Buffer^[wo_BufferIndex] > 96)
      and (po_Buffer^[wo_BufferIndex] < 123))
       or (wo_BufferIndex > wo_ReadIndex);

              (* If the complete data-buffer has been processed then  *)
              (* break the Repeat...Until loop.                       *)
    if (wo_BufferIndex > wo_ReadIndex) then
      break;

              (* Advance the anagram-Word "table" index.              *)
    inc(wo_TableIndex);

              (* Clear the "letter check" Byte-Array Variable.        *)
    fillChar(byar_LtrChk, sizeof(byar_26), 0);

              (* Repeat...Until not an anagram-Word Character,  or    *)
              (* complete data-buffer has been processed.             *)
    Repeat

              (* With the current anagram-Word Record do...           *)
      With rcar_Table[wo_TableIndex]^ do
        begin
              (* Record the number of each alphabetical Character in  *)
              (* the anagram-Word.                                    *)
          inc(byar_LtrChk[po_Buffer^[wo_BufferIndex]]);

              (* Advance the String length-Character.                 *)
          inc(st_Word[0]);

              (* Add the current anagram-Word Character to anagram-   *)
              (* Word String.                                         *)
          st_Word[ord(st_Word[0])] :=
                                    chr(po_Buffer^[wo_BufferIndex]);

              (* Advance the data-buffer index.                       *)
          inc(wo_BufferIndex)

        end
    Until (po_Buffer^[wo_BufferIndex] < 97)
       or (po_Buffer^[wo_BufferIndex] > 122)
       or (wo_BufferIndex > wo_ReadIndex);

              (* Pack bits 0,1,2 of each Character in "letter-check"  *)
              (* Variable, to store Variable as 10 Char data. This    *)
              (* reduces memory storage requirements by 16 Bytes For  *)
              (* each anagram-Word, and makes data faster to sort.    *)
    PackBits(byar_LtrChk, rcar_Table[wo_TableIndex]^.ar_LtrChk);

  Until (wo_BufferIndex > wo_ReadIndex);

              (* Check if the Array of anagram-Words in the "table"   *)
              (* Array are sorted. If not then sort them.             *)
  if not TableSorted(rcar_Table, 1, wo_TableIndex) then
    QuickSort(poar_Generic(rcar_Table), 1, wo_TableIndex, AlphaSort);

              (* Record the position of all the anagram-Words on the  *)
              (* "table" Array. This will be used as a faster sorting *)
              (* index.                                               *)
  For wo_Index := 1 to wo_TableIndex do
    rcar_Table[wo_Index]^.wo_Pos := wo_Index;

 (* end of PART 5 of 7 *)
  (* Start of PART 6 of 7 *)

              (* QuickSort the "table" of anagram Words, using Sort1  *)
              (* routine.                                             *)
  QuickSort(poar_Generic(rcar_Table), 1, wo_TableIndex, Sort1);

              (* Attempt to open a File to Write sorted data to.      *)
  assign(fi_Temp, 'SORTED.DAT');
  {$I-}
  reWrite(fi_Temp, 1);

              (* Check For I/O errors.                                *)
  CheckIOerror;

              (* Set the temporary String to ', ' + Cr + Lf.          *)
  st_Temp := ', ' + #13#10;

              (* Reset the loop index.                                *)
  wo_Index      := 1;

              (* Repeat...Until all anagram-Word on "table" Array are *)
              (* processed.                                           *)
  Repeat

              (* Reset the counter Variables.                         *)
    by_LastAnagram := 0;
    by_CurrentWord := 0;

              (* While the next anagram-Word belongs to the same      *)
              (* anagram-group, advance the by_LastAnagram Variable.  *)
    While (rcar_Table[(wo_Index + by_LastAnagram)]^.ar_LtrChk =
              rcar_Table[succ(wo_Index + by_LastAnagram)]^.ar_LtrChk) do
      inc(by_LastAnagram);

              (* Repeat...Until next anagram-Word is not in the same  *)
              (* anagram group.                                       *)
    Repeat

              (* With current anagram group do...                     *)
      With rcar_Groups[(wo_Index + by_CurrentWord)]^ do
        begin

              (* Move the first anagram-Word in "table" Array to the  *)
              (* current anagram group-String.                        *)
          move(rcar_Table[(wo_Index + by_CurrentWord)]^.st_Word[1],
               st_Group[1], ord(rcar_Table[(wo_Index +
                                         by_CurrentWord)]^.st_Word[0]));

              (* Set the length-Char of current anagram-String to 12. *)
          st_Group[0] := #12;

              (* Record the first anagram-Word position.              *)
          wo_Pos := rcar_Table[(wo_Index + by_CurrentWord)]^.wo_Pos;

              (* Loop from 0 to total number of anagrams in the group *)
          For by_Index := 0 to by_LastAnagram do

              (* If the loop index is not equal the the current       *)
              (* anagram-Word, then...                                *)
            if (by_Index <> by_CurrentWord) then
              begin

              (* Add the next anagram-Word to the anagram-String.     *)
                move(rcar_Table[(wo_Index + by_Index)]^.st_Word[1],
                     st_Group[succ(length(st_Group))],
                     ord(rcar_Table[(wo_Index +
                                               by_Index)]^.st_Word[0]));

              (* Record the length of the anagram-Word added to the   *)
              (* anagram-String.                                      *)
                inc(st_Group[0],
                    ord(rcar_Table[(wo_Index +
                                               by_Index)]^.st_Word[0]));

              (* If the current anagram-Word is not the last anagram- *)
              (* Word of the anagram-group, and the loop-index is     *)
              (* less than the last anagram-Word, or the loop-index   *)
              (* is less than the 2nd to last anagram-Word in group   *)
                if ((by_CurrentWord <> by_LastAnagram) and
                    (by_Index < by_LastAnagram))
                or (by_Index < pred(by_LastAnagram)) then
                  begin

 (* end of PART 6 of 7 *)
 (* Start of PART 7 of 7 *)

              (* Add the comma and space Character to anagram-String. *)
                    move(st_Temp[1],
                                   st_Group[succ(length(st_Group))], 2);
                    inc(st_Group[0], 2)
                  end
              end;

              (* Add the CR + Lf to anagram String.                   *)
          move(st_Temp[3], st_Group[succ(length(st_Group))], 2);
          inc(st_Group[0], 2);

              (* Advance the currrent anagram-Word index.             *)
          inc(by_CurrentWord)

        end
    Until (by_CurrentWord > by_LastAnagram);

              (* Advance the anagram-group index by the current       *)
              (* anagram-Word index.                                  *)
    inc(wo_Index, by_CurrentWord);

  Until (wo_Index > wo_TableIndex);

              (* QuickSort the anagram-Strings, using Sort2.          *)
  QuickSort(poar_Generic(rcar_Groups), 1, wo_TableIndex, Sort2);

              (* Initialize loop control Variable.                    *)
  wo_CurrentIndex := 1;

              (* Repeat Until all the anagram Words in the "table"    *)
              (* Array have been processed.                           *)
  Repeat

              (* Initialize loop control Variable.                    *)
    wo_BufferIndex := 1;

              (* Place all the anagram-Strings in the data-buffer.    *)
    While (wo_CurrentIndex <= wo_TableIndex)
    and   (wo_BufferIndex  < co_SafeSize) do
      With rcar_Groups[wo_CurrentIndex]^ do
        begin
              (* Place current anagram-String in the data-buffer.     *)
          move(st_Group[1], po_Buffer^[wo_BufferIndex],
                                                      length(st_Group));

              (* Advance the data-buffer index by length of anagram-  *)
              (* String.                                              *)
          inc(wo_BufferIndex, length(st_Group));

              (* Advance current anagram-String index.                *)
          inc(wo_CurrentIndex)

        end;

              (* Write the anagram Text data in the buffer to disk.   *)
    blockWrite(fi_Temp, po_Buffer^[1], pred(wo_BufferIndex));

              (* Check For I/O errors.                                *)
    CheckIOerror;

  Until (wo_CurrentIndex >= wo_TableIndex);

              (* Close the sorted anagram-Text File.                  *)
  close(fi_Temp);

              (* Check For I/O errors.                                *)
  CheckIOerror

end.

 (* end of PART 7 of 7 *)
{  Hi, to All:

  ...I gather that the 3rd Programming contest (Anagram Word sort)
  is officially over, and am now posting my entry's source-code.

  This Program should execute in well under 1 second on a 486-33
  ram-disk. (It's about 3.21 sec on my 386sx-25) The final compiled
  size of the .EXE is 7360 Bytes.

  ...I've commented the h*ll out of my source-code, so it's a bit
  on the big side.

  ...Here is a "quick" run-down of how it works:

      1- Creates a 60K buffer on the HEAP.

      2- Creates an Array table to store all the anagram Words
         and data about each Word, on the HEAP.

      3- Creates an Array of anagram-group Strings on the HEAP.

      4- Read the entire anagram-Word input File WordLIST.DAT
         into the 60K buffer in 1 big chunk.

      5- Finds all the anagram-Words in the buffer, and assigns
         their data to the anagram-Word table on the HEAP.

      6- Each letter of every anagram-Word is Recorded in an
         Array of 26 Bytes. Then the first 3 bits of each of
         the 26 Bytes is packed, so that this data can be
         stored in a 10 Character Array in each anagram-Word
         table Record. (The bits are packed to save space and
         to make the sorting faster.) This method allows for
         a maximum of 7 of the same letter in each Word, which
         should be sufficient For this contest.

      7- The table of anagram Records is then checked to see if
         the anagram-Words are in sorted order. (In this contest
         the original input File is in sorted order.) If they are
         not in sorted order, QuickSort is called to put the
         Words (actually Pointers to the Words) in order.

      8- Now that the anagram-Words are in sorted order, their
         position in the anagram-Word table is Recorded in a
         position field within each anagram-Word Record.

      9- The table of anagram-Word Records is now sorted using
         a multi-key QuickSort. This will sort the anagram-Word
         Records by:
                     1- Length of anagram-Word.
                     2- Letters that each anagram-Word contains.
                     3- Alphabeticly.

         ...This multi-key sort will establish the anagram groups,
         and sort the members of each group alphabeticly.

     10- Open the sorted output File.

     11- Create N number of anagram-Strings from N mumber of anagram-
         Words in each anagram-group. Keeping the anagram Words in
         the String in sorted order.

     12- QuickSort the anagram-group Strings into alphabetical order.

     13- Place all the sorted anagram-group Strings back into the
         60K buffer.

     14- Write the entire buffer to the SORTED.DAT File, and close
         this File.

   NOTES: Well this is the first time I've figured out how to do
          multi-key QuickSorts, which I wasn't sure was possible
          at first.

          I also tried using a 32-bit CRC value to identify the
          anagram-groups which ran even faster, but should not
          be considered a "safe" method, as it's accuracy is only
          guaranteed For 2-7 Character Words.

          File I/O and repetitive loops are usually the big speed
          killers in these Types of contests, so I always try to
          keep them to a minimum.

          ...My entry could possibly be tweaked further still,
          but I've got a life. <g>

}