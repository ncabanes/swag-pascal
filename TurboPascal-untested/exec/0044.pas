{
Most suggestions for modifying EXE files involve storing and searching
for a marker value.  This seems clumsy.  An alternative is given in
"PC Techniques C/C++ Power Tools" by Duntemann & Weiskamp.  This
involves deducing the position in the disk file at which initialised
constants are stored, based on their address in RAM at run time.

I have produced a demo Pascal program based on these ideas.  The code
is given below.  It works fine, but only in real mode.  Can anyone see
any way to use the same approach in protected mode or, ideally, in
Windows ?
}
program TestMod;

type  TEXEHeader = record
                     EXEID    : Word;  {EXE File identifier          }
                     ByteMod  : Word;  {Load module image size mod512}
                     Pages    : Word;  {File size (inc hdr) div 512  }
                     RelocCnt : Word;  {No. of relocation table items}
                     Size     : Word;  {Header size in 16-byte paras }
                     MinParas : Word;  {Min. No. of paras above prog }
                     MaxParas : Word;  {Max. No. of paras above prog }
                     StackSeg : Word;  {Displacement of stack segment}
                     spreg    : Word;  {Initial SP register value    }
                     CheckSum : Integer;{Negative checksum (unused)  }
                     ipreg    : Word;  {Initial IP register value    }
                     CodeSeg  : Word;  {Displacement of code segment }
                     Reloc1   : Word;  {First relocation item        }
                     ovln     : Word;  {Overlay number               }
                   end;

const MyStr : String = 'Original string in EXE file'; 
      PSPSize = 16; { Size of Program Segment Prefix = 16 paragraphs }
      ParaSize = 16; { 1 paragraph = 16 bytes }
      fmShareDenyWrite = $0020; { EXE File open mode }

var   EXEHdrSize  : Integer;
      EXEName     : String;
      DiskPos     : LongInt;
      F           : File;

procedure GetEXENameAndHdrSize;
var   EXEHdr  : TEXEHeader;
begin EXEName := ParamStr(0);
      Assign(F,EXEName);
      FileMode := fmShareDenyWrite;
      Reset(F,1);
      BlockRead(F,EXEHdr,SizeOf(TEXEHeader));
      close(F);
      EXEHdrSize := EXEHdr.Size;
      end;

procedure RestoreDefaultStr( var S : String );
var   DiskPos : LongInt;
begin assign(F,EXEName);
      FileMode := fmShareDenyWrite;
      reset(F,1);
      DiskPos :=
(Seg(S)-(PrefixSeg+PSPSize)+EXEHdrSize)*ParaSize+Ofs(S);
      seek(F,DiskPos);
      blockread(F,S[0],1); { Find size of default value for string }
      blockread(F,S[1],Integer(S[0])); { Read the string itself }
      close(F);
      end;

procedure SetNewDefaultStr( var S : String );
var   DiskPos : LongInt;
begin assign(F,EXEName);
      FileMode := fmShareDenyWrite;
      rewrite(F,1);
      DiskPos :=
(Seg(S)-(PrefixSeg+PSPSize)+EXEHdrSize)*ParaSize+Ofs(S);
      seek(F,DiskPos);
      blockwrite(F,S[0],Length(S)+1);
      close(f);
      end;


begin

  GetEXENameAndHdrSize;

  writeln(MyStr);            { Show original string value  }

  MyStr := 'Changed in RAM'; { Change string so we can tell}
  Writeln(MyStr);            { if we read EXE file OK.     }

  RestoreDefaultStr( MyStr );{ Read original from EXE file }
  Writeln(MyStr);

  MyStr := 'Written to EXE'; { Change the string and       }
  SetNewDefaultStr( MyStr ); { write new value to EXE file }

  MyStr := 'Temp RAM value'; { Change again so we can test }
  writeln(MyStr);            { if new value read from EXE  }


  RestoreDefaultStr( MyStr );{ Read the value we earlier   }
  Writeln(MyStr);            { wrote to the EXE file.      }

  end.
