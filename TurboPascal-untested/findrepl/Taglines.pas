(*
  Category: SWAG Title: SEARCH/FIND/REPLACE ROUTINES
  Original name: 0016.PAS
  Description: TAGLINES.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:46
*)

{ BOB SWART

Here it is, all new and much faster. I used an internal binary tree to manage
the taglines. You can store up to the available RAM in taglines:
}

{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S+,T-,V-,X-}
{$M 16384,0,655360}
Uses
  Crt;
Type
  TBuffer  = Array[0..$4000] of Char;

Const
  Title = 'TagLines 0.2 by Bob Swart For Travis Griggs'#13#10;
  Usage = 'Usage: TagLines inFile outFile'#13#10#13#10+
          '       Taglines will remove dupicate lines from inFile.'#13#10+
          '       Resulting Text is placed in outFile.'#13#10;

  NumLines: LongInt = 0; { total number of lines in InFile }
  NmLdiv80: LongInt = 0; { NumLines div 80, For 'progress' }
  CurrentL: LongInt = 0; { current lineno read from InFile }

Type
  String80 = String[80];

  PBinTree = ^TBinTree;
  TBinTree = Record
               Info: String80;
               left,right: PBinTree
             end;

Var
  InBuf,
  OutBuf   : TBuffer;
  InFile,
  OutFile  : Text;
  TagLine  : String80;
  Root,
  Current,
  Prev     : PBinTree;
  i        : Integer;
  SaveExit : Pointer;


Function CompStr(Var Name1,Name2: String): Integer; Assembler;
{ Author: drs. Robert E. Swart
}
Asm
  push  DS
  lds   SI,Name1               { ds:si pts to Name1       }
  les   DI,Name2               { es:di pts to Name2       }
  cld
  lodsb                        { get String1 length in AL }
  mov   AH,ES:[DI]             { get String2 length in AH }
  inc   DI
  mov   BX,AX                  { save both lengths in BX  }
  xor   CX,CX                  { clear cx                 }
  mov   CL,AL                  { get String1 length in CX }
  cmp   CL,AH                  { equal to String2 length? }
  jb    @Len                   { CX stores minimum length }
  mov   CL,AH                  { of String1 and String2   }
 @Len: jcxz  @Exit                  { quit if null             }

 @Loop: lodsb                        { String1[i] in AL         }
  mov   AH,ES:[DI]             { String2[i] in AH         }
  cmp   AL,AH                  { compare Str1 to Str2     }
  jne   @Not                   { loop if equal            }
  inc   DI
  loop  @Loop                  { go do next Char          }
  jmp   @Exit                  { Strings OK, Length also? }

 @Not: mov   BX,AX                  { BL = AL = String1[i],
                                 BH = AH = String2[i]     }
 @Exit: xor   AX,AX
  cmp   BL,BH                  { length or contents comp  }
  je    @Equal                 { 1 = 2: return  0         }
  jb    @Lower                 { 1 < 2: return -1         }
  inc   AX                     { 1 > 2: return  1         }
  inc   AX
 @Lower: dec   AX
 @Equal: pop   DS
end {CompStr};

Procedure Stop; Far;
begin
  ExitProc := SaveExit;
  Close(InFile);
  Close(OutFile);
end {Stop};


begin
  Writeln(Title);
  if Paramcount <> 2 then
  begin
    Writeln(Usage);
    Halt
  end;

  Assign(InFile,ParamStr(1));
  SetTextBuf(InFile,InBuf);
  Reset(InFile);
  if IOResult <> 0 then
  begin
    WriteLn('Error: could not open ', ParamStr(1));
    Halt(1)
  end;

  Assign(OutFile,ParamStr(2));
  SetTextBuf(OutFile,OutBuf);
  Reset(OutFile);
  if IOResult = 0 then
  begin
    WriteLn('Error: File ', ParamStr(2),' already exists');
    Halt(2)
  end;

  ReWrite(OutFile);
  if IOResult <> 0 then
  begin
    WriteLn('Error: could not create ', ParamStr(2));
    Halt(3)
  end;

  SaveExit := ExitProc;
  ExitProc := @Stop;

  While not eof(InFile) do
  begin
    readln(InFile);
    Inc(NumLines);
  end;
  Writeln('There are ',NumLines,' lines in this File.'#13#10);
  Writeln('Press any key to stop the search For duplicate lines');
  NmLdiv80 := NumLines div 80;

  Root := nil;
  reset(InFile);
  While CurrentL <> NumLines do
  begin
    if KeyPressed then
      Halt { calls Stop };
    Inc(CurrentL);
    if (CurrentL and NmLdiv80) = 0 then
      Write('#');
    readln(InFile,TagLine);

    if root = nil then { first TagLine }
    begin
      New(Root);
      Root^.left := nil;
      Root^.right := nil;
      Root^.Info := TagLine;
      Writeln(OutFile,tagLine)
    end
    else { binary search For TagLine }
    begin
      Current := Root;
      Repeat
        Prev := Current;
        i := CompStr(Current^.Info,TagLine);
        if i > 0 then
          Current := Current^.left
        else
        if i < 0 then
          Current := Current^.right
      Until (i = 0) or (Current = nil);

      if i <> 0 then { TagLine not found }
      begin
        New(Current);
        Current^.left := nil;
        Current^.right := nil;
        Current^.Info := TagLine;

        if i > 0 then
          Prev^.left := Current { Current before Prev }
        else
          Prev^.right := Current { Current after Prev };
        Writeln(OutFile,TagLine)
      end
    end
  end;
  Writeln(#13#10'100% Completed, result is in File ',ParamStr(2))
  { close is done by Stop }
end.

{
> I also tried DJ's idea of the buffer of 65535 but it said the structure
> was too large. So I used 64512.
Always try to use a multiple of 4K, because the hard disk 'eats' space in these
chunks. Reading/Writing in these chunks goes a lot faster that way.
}
