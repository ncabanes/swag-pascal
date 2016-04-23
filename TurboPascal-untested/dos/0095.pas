{$A-,B-,D-,E-,F+,G-,I-,L-,N-,O+,P-,R-,S-,V-,X+}
Unit AltDos;
Interface
{$IFDEF VIRTUALPASCAL}
Uses Use32,Dos;
{$DEFINE OS2}
{$ELSE}
Uses Dos;
{$ENDIF}

{$IFNDEF OS2}
function Execute(ExeFile,ComLine: string): boolean;
{$ENDIF}
Function DosShell(command:String): Integer;

function FileExists(FileName: string): boolean;
function DirExists(FileName: string): boolean;

{$IFNDEF VIRTUALPASCAL}
Procedure GetFileMode;
Function TextFilePos(Var f : Text) : LongInt;
Function TextFileSize(Var f : Text) : LongInt;
Procedure TextSeek(Var f : Text; n : LongInt);
{$ENDIF}

procedure CopyFile(FromN,ToN: string);

{$IFNDEF OS2}
Function GetMemSize: Word;
{$ENDIF}

Implementation
{$IFNDEF OS2}
{$IFNDEF DPMI}
Function DosShell;
Var
  OldHeapEnd,
  NewHeapEnd: Word;
  Error:Integer;
Begin
  Error:=0;
  If MemAvail<$1000
    then Error:=8;
  If Error=0
    then
      begin
        NewHeapEnd:=Seg(HeapPtr^)-PrefixSeg;
        OldHeapEnd:=Seg(HeapEnd^)-PrefixSeg;
        asm
          mov ah,4Ah
          mov bx,NewHeapEnd
          mov es,PrefixSeg
          Int 21h
          jnc @EXIT
          mov Error,ax
          @EXIT:
        end;
        If Error=0
          then
            begin
              SwapVectors;
              Exec(GetEnv('COMSPEC'),command);
              SwapVectors;
              asm
                mov ah,4Ah
                mov bx,OldHeapEnd
                mov es,PrefixSeg
                Int 21h
                jnc @EXIT
                mov Error,ax
                @EXIT:
              end;
            end;
      end;
  DosShell:=Error;
end;     {Function}
{$ENDIF}
{$ENDIF}

{$IFDEF DPMI}
Function DosShell;
Begin
  SwapVectors;
  Exec(GetEnv('COMSPEC'),command);
  SwapVectors;
  DosShell:=0;
end;     {Function}
{$ENDIF}

{$IFDEF OS2}
Function DosShell;
Begin
  Exec(GetEnv('COMSPEC'),command);
  DosShell:=0;
end;     {Function}
{$ENDIF}

{$IFNDEF OS2}
function Execute;
var
  EF  : string ;
  Dir : DirStr ;
  Name: NameStr;
  Ext : ExtStr ;
{$IFNDEF DPMI}
  OldHeapEnd,
  NewHeapEnd: Word;
{$ENDIF}
  Error:Integer;
begin
  FSplit(ExeFile,Dir,Name,Ext);
  if Name+Ext='COMMAND.COM'
    then Error:=DosShell(ComLine)
    else
      begin
        if (Dir[byte(Dir[0])]='\') and (byte(Dir[0])>0)
          then Dir[byte(Dir[0])]:=';'
          else
            if (byte(Dir[0])>0)
              then Dir:=Dir+';';
        EF:=FSearch(ExeFile,Dir+GetEnv('PATH'));
        if EF=''
          then Execute:=false
          else
            begin
{$IFNDEF DPMI}
            Error:=0;
            If MemAvail<$1000
              then Error:=8;
            If Error=0
              then
                begin
                  NewHeapEnd:=Seg(HeapPtr^)-PrefixSeg;
                  OldHeapEnd:=Seg(HeapEnd^)-PrefixSeg;
                  asm
                    mov ah,4Ah
                    mov bx,NewHeapEnd
                    mov es,PrefixSeg
                    Int 21h
                    jnc @EXIT
                    mov Error,ax
                  @EXIT:
                  end;
                 If Error=0
                   then
                     begin
{$ENDIF}
                       SwapVectors;
                       Exec(EF,ComLine);
                       SwapVectors;
{$IFNDEF DPMI}
                       asm
                         mov ah,4Ah
                         mov bx,OldHeapEnd
                         mov es,PrefixSeg
                         Int 21h
                         jnc @EXIT
                         mov Error,ax
                       @EXIT:
                     end;
                end;
            end;
{$ENDIF}
              Execute:=true;
            end;
      end;
end;
{$ENDIF}

{$IFDEF VIRTUALPASCAL}
{$UNDEF OS2}
{$ENDIF}

{$IFNDEF VIRTUALPASCAL}
Procedure GetFileMode; Assembler;
Asm
  CLC
  CMP    ES:[DI].TextRec.Mode, fmInput
  JE     @1
  MOV    [InOutRes], 104         { 'File not opened For reading' }
  xor    AX, AX                  { Zero out Function result }
  xor    DX, DX
  STC
@1:
end;  { GetFileMode }

Function TextFilePos(Var f : Text) : LongInt; Assembler;
Asm
  LES    DI, f
  CALL   GetFileMode
  JC     @1
  xor    CX, CX                  { Get position of File Pointer }
  xor    DX, DX
  MOV    BX, ES:[DI].TextRec.handle
  MOV    AX, 4201h
  inT    21h                     { offset := offset-Bufend+BufPos }
  xor    BX, BX
  SUB    AX, ES:[DI].TextRec.Bufend
  SBB    DX, BX
  ADD    AX, ES:[DI].TextRec.BufPos
  ADC    DX, BX
@1:
end;  { TextFilePos }

Function TextFileSize(Var f : Text) : LongInt; Assembler;
Asm
  LES    DI, f
  CALL   GetFileMode
  JC     @1
  xor    CX, CX                  { Get position of File Pointer }
  xor    DX, DX
  MOV    BX, ES:[DI].TextRec.handle
  MOV    AX, 4201h
  inT    21h
  PUSH   DX                      { Save current offset on the stack }
  PUSH   AX
  xor    DX, DX                  { Move File Pointer to Eof }
  MOV    AX, 4202h
  inT    21h
  POP    SI
  POP    CX
  PUSH   DX                      { Save Eof position }
  PUSH   AX
  MOV    DX, SI                  { Restore old offset }
  MOV    AX, 4200h
  inT    21h
  POP    AX                      { Return result}
  POP    DX
@1:
end;  { TextFileSize }

Procedure TextSeek(Var f : Text; n : LongInt); Assembler;
Asm
  LES    DI, f
  CALL   GetFileMode
  JC     @2
  MOV    CX, Word Ptr n+2        { Move File Pointer }
  MOV    DX, Word Ptr n
  MOV    BX, ES:[DI].TextRec.Handle
  MOV    AX, 4200h
  inT    21h
  JNC    @1                      { Carry flag = reading past Eof }
  MOV    [InOutRes], AX
  JMP    @2
  { Force read next time }
@1:
  MOV    AX, ES:[DI].TextRec.Bufend
  MOV    ES:[DI].TextRec.BufPos, AX
@2:
end;  { TextSeek }
{$ENDIF}

function FileExists;
var
  SR: SearchRec;
begin
{$IFDEF OS2}
  FindFirst(FileName,AnyFile-Directory,SR);
{$ELSE}
  FindFirst(FileName,AnyFile-VolumeID-Directory,SR);
{$ENDIF}
  FileExists:=DosError=0;
end;

function DirExists;
var
  SR: SearchRec;
begin
  FindFirst(FileName,Directory,SR);
  DirExists:=DosError=0;
end;

procedure CopyFile;
var
  FromF,ToF: file   ;
  NrRead,
  NrWriteln: word   ;
  Buf      : pointer;
  Block    : word   ;
begin
  Assign(FromF,FromN);
  Assign(ToF,ToN);
  Reset(FromF,1);
  Rewrite(ToF,1);
  Block:=MaxAvail;
  GetMem(Buf,Block);
  repeat
    BlockRead(FromF,Buf^,Block,NrRead);
    BlockWrite(ToF,Buf^,NrRead,NrWriteLn);
  until (NrRead=0) or (NrWriteLn<>NrRead);
  FreeMem(Buf,Block);
  Close(FromF);
  Close(ToF);
end;

{$IFDEF VIRTUALPASCAL}
{$DEFINE OS2}
{$ENDIF}

{$IFNDEF OS2}
Function GetMemSize;
Assembler;
Asm
  Int 12h
End;
{$ENDIF}

end.

