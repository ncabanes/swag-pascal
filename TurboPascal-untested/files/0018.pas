===========================================================================
 BBS: Canada Remote Systems
Date: 06-24-93 (15:37)             Number: 27580
From: ROB PERELMAN                 Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: End of EXE                     Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
This is a unit I wrote but it crashed a few times on me, so here is an
updated unit for anyone's use.  Remember not to use it from the TP
editor because if you compile to memory, PARAMSTR(0) is the editor, and
if you compile to disk, you will not have any data.

Unit ExeEnd;

Interface

Var EndOfExe: LongInt; {Shows the end of the EXE file}
    ExeFile: File; {The EXE file positioned at the end}
    Data: Boolean; {If there is data after the EXE}

Implementation

Type EXEHeader=Record
      ID: Word;                  { EXE file id }
      ByteMod: Word;             { Load module image size mod 512 }
      Pages: Word;               { File size (including header) div 512 }
      RelocItems: Word;          { Number of relocation table items }
      Size: word;                { Header size in 16-byte paragraphs }
      MinParagraphs: Word;       { Minimum number of paragraphs above program }
      MaxParagraphs: Word;       { Maximum number of paragraphs above program }
      StackSeg: Word;            { Displacement of stack segment }
      SPReg: Word;               { Initial SP register value }
      CheckSum: Integer;         { Word checksum - negative sum (not used) }
      IPReg: Word;               { Initial IP register value }
      CodeSeg: Word;             { Displacement of code segment }
      FirstReloc: Word;          { First relocation item }
      OvlN: Word                 { Overlay number }
    End;

Const CorrectExe=$5A4D;

Var Exe: EXEHeader;
    ReadIn: Integer;
    OldExitProc: Pointer;

Procedure CloseExe; Far;
Begin
  ExitProc:=OldExitProc;
  Close(ExeFile);
End;

Begin
  OldExitProc:=ExitProc;
  ExitProc:=@CloseExe;
  Assign(ExeFile, ParamStr(0));
  Reset(ExeFile, 1);
  BlockRead(ExeFile, Exe, SizeOf(Exe), ReadIn);
  With Exe do If (ReadIn<>SizeOf(Exe)) or (ID<>CorrectExe) then EndOfExe:=0
    Else EndOfExe:=Pages*512+ByteMod-512;
  Seek(ExeFile, EndOfExe);
  Data:=Not EOF(ExeFile);
End.

 * QMPro 1.50 4 * "Call waiting", great if you have two friends


--- WM v3.00/92-0215
 * Origin: High Country East, Ramona, CA (619)-789-4391  (1:202/1308.0)
