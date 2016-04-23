Unit expfht;

  { Author: Trevor J Carlsen  Released into the public domain }
  {         PO Box 568                                        }
  {         Port Hedland                                      }
  {         Western Australia 6721                            }
  {         Voice +61 91 732 026                              }

  { EXPFHT: This Unit allows an application to expand the number of File }
  { handles in use. It is limited to the number permitted by Dos and     }
  { initialised in the FileS= of the config.sys File.                    }

Interface

Const
  NumbFiles= 105;
  { Set to the number of File handles needed. 99 will be the max With }
  { Dos 2.x and 254 With Dos 3.x. (I don't know why not 255!)         }
Type
  fht      = Array[1..NumbFiles] of Byte;
Var
  NewFHT   : fht;
  OldFHT   : LongInt;
  OldSize  : Word;
                    
Function MakeNewFHT: Boolean;
Procedure RestoreOldFHT;


Implementation

Const
  Successful : Boolean = False;

Var
  OldExitProc  : Pointer;

{$R-}
Function MakeNewFHT : Boolean;
  { create a new expanded File handle table - True if successful }
  Const
    AlreadyUsed : Boolean = False;
  begin
    if not AlreadyUsed then begin
      AlreadyUsed := True;
      MakeNewFHT := True;
      Successful := True;
      OldFHT  := MemL[PrefixSeg:$34];            { Store the old FHT address }
      FillChar(NewFHT,NumbFiles,$ff);              { Fill new table With 255 }
      Oldsize := MemW[PrefixSeg:$32];               { Store the old FHT size }
      MemW[PrefixSeg:$32] := NumbFiles;            { Put new size in the psp }
      MemL[PrefixSeg:$34] := LongInt(@NewFHT);      { new FHT address in psp }
      move(Mem[PrefixSeg:$19],NewFHT,$15);      { put contents of old to new }
    end { if not AllreadyUsed }
    else MakeNewFHT := False;
  end; { MakeNewFHT }
{$R+}

{$F+}
Procedure RestoreOldFHT;
  begin
    ExitProc := OldExitProc;
    if Successful then begin
      MemW[PrefixSeg:$32] := OldSize;
      MemL[PrefixSeg:$34] := OldFHT;
    end;  
  end;
{$F-}

begin
  OldExitProc := ExitProc;
  ExitProc    := @RestoreOldFHT;
end.

