
{$R-,S+,I-,D-,T-,F-,V-,B-,N-}

unit Searches;

{ A unit for rapidly searching a buffer for a string.

  Version 1.00 - 10/26/1987 - First general release

  Scott Bussinger
  Professional Practice Systems
  110 South 131st Street
  Tacoma, WA  98444
  (206)531-8944
  Compuserve 72247,2671

  BlockPos was originally written by Randy Forgaard for use with Turbo
  Pascal version 3.0.

  The Boyer-Moore routines were originally written by Van Hall for Turbo
  Pascal version 3.0 and have been extensively rearranged for optimum use
  with Turbo Pascal 4.0.  Note that the Boyer-Moore routines are MUCH, MUCH
  slower than using BlockPos (which is written with inline code). }


interface

function BlockPos(var Buffer;Size: word;S: string): integer;
  { Search in Buffer of Size bytes for the string S }

type BoyerTable = record
       Match: string;
       MatchLength: byte;
       Table: array[char] of byte
       end;

procedure MakeBoyerTable(MatchString: string;var Table: BoyerTable);
  { Generate the necessary table for doing a Boyer-Moore search }

function BoyerMoore(var BufferAddr;Size: word;Start: word;var Table: BoyerTable): word;
  { Search a Buffer of Size characters beginning at Start for the match string defined in Table }


implementation

function BlockPos(var Buffer;Size: word;S: string): integer;
  { Search in Buffer of Size bytes for the string S }
  begin
  { Load "buffer" address into ES:DI, "buffer" offset into BX, Length(s) -
    1 into DX, contents of "s[1]" into AL, offset of "s[2]" into SI, and
    "size" - Length(s) + 1 into CX.  If "size" < Length(s), or if
    Length(s) = 0, return zero. }

  Inline($1E/               {        PUSH    DS           }
         $16/               {        PUSH    SS           }
         $1F/               {        POP     DS           }
         $C4/$BE/>buffer/   {        LES     DI,buffer[BP]}
         $89/$FB/           {        MOV     BX,DI        }
         $8B/$8E/>size/     {        MOV     CX,size[bp]  }
         $8D/$B6/>s+2/      {        LEA     SI,s+2[bp]   }
         $8A/$86/>s+1/      {        MOV     AL,s+1[bp]   }
         $8A/$96/>s/        {        MOV     DL,s[bp]     }
         $84/$D2/           {        TEST    DL,DL        }
         $74/$23/           {        JZ      ERROR        }
         $FE/$CA/           {        DEC     DL           }
         $30/$F6/           {        XOR     DH,DH        }
         $29/$D1/           {        SUB     CX,DX        }
         $76/$1B/           {        JBE     ERROR        }

  { Scan the ES:DI buffer, looking for the first occurrence of "s[1]."  If
    not found prior to reaching Length(s) characters before the end of the
    buffer, return zero.  If Length(s) = 1, the entire string has been
    found, so report success. }

       $FC/               {        CLD                  }
       $F2/               {NEXT:   REPNE                }
       $AE/               {        SCASB                }
       $75/$16/           {        JNE     ERROR        }
       $85/$D2/           {        TEST    DX,DX        }
       $74/$0C/           {        JZ      FOUND        }

  { Compare "s" (which is at SS:SI) with the ES:DI buffer, in both cases
    starting with the first byte just past the length byte of the string.
    If "s" does not match what is at the DI position of the buffer, reset
    the registers to the values they had just prior to the comparison, and
    look again for the next occurrence of the length byte. }

         $51/               {        PUSH    CX           }
         $57/               {        PUSH    DI           }
         $56/               {        PUSH    SI           }
         $89/$D1/           {        MOV     CX,DX        }
         $F3/               {        REPE                 }
         $A6/               {        CMPSB                }
         $5E/               {        POP     SI           }
         $5F/               {        POP     DI           }
         $59/               {        POP     CX           }
         $75/$EC/           {        JNE     NEXT         }

  { String found in buffer.  Set AX to the offset, within buffer, of the
    first byte of the string (the length byte), assuming that the first
    byte of the buffer is at offset 1. }

         $89/$F8/           {FOUND:  MOV     AX,DI        }
         $29/$D8/           {        SUB     AX,BX        }
         $EB/$02/           {        JMP     SHORT RETURN }

  { An "error" condition.  Return zero. }

         $31/$C0/           {ERROR:  XOR     AX,AX        }
         $89/$46/$FE/       {RETURN: MOV     [BP-2],AX    }
         $1F)               {        POP     DS           }
  end;

procedure MakeBoyerTable(MatchString: string;var Table: BoyerTable);
  { Generate the necessary table for doing a Boyer-Moore search }
  var Counter: byte;
  begin
  with Table do
    begin
    Match := MatchString;
    MatchLength := length(MatchString);
    fillChar(Table,sizeof(Table),MatchLength);
    if MatchLength > 0 then
      for Counter := pred(MatchLength) downto 1 do
        if Table[Match[Counter]] = MatchLength then
            Table[Match[Counter]] := MatchLength-Counter
    end
  end;

function BoyerMoore(var BufferAddr;Size: word;Start: word;var Table: BoyerTable): word;
  { Search a Buffer of Size characters beginning at Start for the match string defined in Table }
  type Ptr = record
         case integer of
           0: (Ptr: ^char);
           1: (Offset: word;
               Segment: word)
         end;
  var Buffer: array[1..$FFF1] of char absolute BufferAddr;
      BufferPtr: Ptr;
      BufferEndOfs: word;
      MatchPtr: Ptr;
      MatchEndPtr: Ptr;
  begin
  with Table do
    if MatchLength = 0                           { Are we looking for an empty string? }
     then
      BoyerMoore := 0
     else
      begin
      MatchEndPtr.Ptr := @Match[MatchLength];
      MatchPtr := MatchEndPtr;
      BufferPtr.Ptr := @Buffer[pred(Start+MatchLength)];
      BufferEndOfs := ofs(Buffer[Size]);
      repeat
        if BufferPtr.Ptr^ = MatchPtr.Ptr^
         then
          begin
          dec(BufferPtr.Offset);
          dec(MatchPtr.Offset)
          end
         else
          begin
          MatchPtr := MatchEndPtr;
          inc(BufferPtr.Offset,Table[BufferPtr.Ptr^])
          end
      until (MatchPtr.Ptr=@Match) or (ofs(BufferPtr.Ptr^)>=BufferEndOfs);
      if MatchPtr.Ptr = @Match
       then
        BoyerMoore := ofs(BufferPtr.Ptr^) - ofs(Buffer) + 2
       else
        BoyerMoore := 0
      end
  end;

end.
