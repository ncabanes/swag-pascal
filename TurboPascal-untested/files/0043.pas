{
Also, please note, this unit has not been completely tested.  It may
(and most probably does) have bugs in it.  If (and when) any are
discovered, please contact me, so I can update my routines also.

**************************
*     SHARE.PAS v1.0     *
*                        *
*  General purpose file  *
*    sharing routines    *
**************************

1992-93 HyperDrive Software
Released into the public domain.
}

{$S-,R-,D-}
{$IFOPT O+}
  {$F+}
{$ENDIF}

unit Share;

interface

const
  MaxLockRetries : Byte = 10;

  NormalMode = $02; { ---- 0010 }
  ReadOnly   = $00; { ---- 0000 }
  WriteOnly  = $01; { ---- 0001 }
  ReadWrite  = $02; { ---- 0010 }
  DenyAll    = $10; { 0001 ---- }
  DenyWrite  = $20; { 0010 ---- }
  DenyRead   = $30; { 0011 ---- }
  DenyNone   = $40; { 0100 ---- }
  NoInherit  = $70; { 1000 ---- }

type
  Taskers = (NoTasker, DesqView, DoubleDOS, Windows, OS2, NetWare);

var
  MultiTasking : Boolean;
  MultiTasker  : Taskers;
  VideoSeg     : Word;
  VideoOfs     : Word;

procedure SetFileMode(Mode : Word);
{- Set filemode for typed/untyped files }
procedure ResetFileMode;
{- Reset filemode to ReadWrite (02h) }
procedure LockFile(var F);
{- Lock file F }
procedure UnLockFile(var F);
{- Unlock file F }
procedure LockBytes(var F;  Start, Bytes : LongInt);
{- Lock Bytes bytes of file F, starting with Start }
procedure UnLockBytes(var F;  Start, Bytes : LongInt);
{- Unlock Bytes bytes of file F, starting with Start }
procedure LockRecords(var F;  Start, Records : LongInt);
{- Lock Records records of file F, starting with Start }
procedure UnLockRecords(var F;  Start, Records : LongInt);
{- Unlock Records records of file F, starting with Start }
function  TimeOut : Boolean;
{- Check for LockRetry timeout }
procedure TimeOutReset;
{- Reset internal LockRetry counter }
function  InDos: Boolean;
{- Is DOS busy? }
procedure GiveTimeSlice;
{- Give up remaining CPU time slice }
procedure BeginCrit;
{- Enter critical region }
procedure EndCrit;
{- End critical region }

implementation

uses
  Dos;

var
  InDosFlag : ^Word;
  LockRetry : Byte;

procedure FLock(Handle : Word; Pos, Len : LongInt);
Inline(
  $B8/$00/$5C/    {  mov   AX,$5C00        ;DOS FLOCK, Lock subfunction}
  $8B/$5E/$04/    {  mov   BX,[BP + 04]    ;Place file handle in Bx register}
  $C4/$56/$06/    {  les   DX,[BP + 06]    ;Load position in ES:DX}
  $8C/$C1/        {  mov   CX,ES           ;Move ES pointer to CX register}
  $C4/$7E/$08/    {  les   DI,[BP + 08]    ;Load length in ES:DI}
  $8C/$C6/        {  mov   SI,ES           ;Move ES pointer to SI register}
  $CD/$21);       {  int   $21             ;Call DOS}

procedure FUnlock(Handle : Word; Pos, Len : LongInt);
Inline(
  $B8/$01/$5C/    {  mov   AX,$5C01        ;DOS FLOCK, Unlock subfunction}
  $8B/$5E/$04/    {  mov   BX,[BP + 04]    ;Place file handle in Bx register}
  $C4/$56/$06/    {  les   DX,[BP + 06]    ;Load position in ES:DX}
  $8C/$C1/        {  mov   CX,ES           ;Move ES pointer to CX register}
  $C4/$7E/$08/    {  les   DI,[BP + 08]    ;Load length in ES:DI}
  $8C/$C6/        {  mov   SI,ES           ;Move ES pointer to SI register}
  $CD/$21);       {  int   $21             ;Call DOS}

procedure SetFileMode(Mode : Word);
begin
  FileMode := Mode;
end;

procedure ResetFileMode;
begin
  FileMode := NormalMode;
end;

procedure LockFile(var F);
begin
  If not MultiTasking then
    Exit;

  While InDos do
    GiveTimeSlice;

  FLock(FileRec(F).Handle, 0, FileSize(File(F)));
end;

procedure UnLockFile(var F);
begin
  If not MultiTasking then
    Exit;

  While InDos do
    GiveTimeSlice;

  FLock(FileRec(F).Handle, 0, FileSize(File(F)));
end;

procedure LockBytes(var F;  Start, Bytes : LongInt);
begin
  If not MultiTasking then
    Exit;

  While InDos do
    GiveTimeSlice;

  FLock(FileRec(F).Handle, Start, Bytes);
end;

procedure UnLockBytes(var F;  Start, Bytes : LongInt);
begin
  If not MultiTasking then
    Exit;

  While InDos do
    GiveTimeSlice;

  FLock(FileRec(F).Handle, Start, Bytes);
end;

procedure LockRecords(var F;  Start, Records : LongInt);
begin
  If not MultiTasking then
    Exit;

  While InDos do
    GiveTimeSlice;

  FLock(FileRec(F).Handle, Start * FileRec(F).RecSize, Records * FileRec(F).RecSize);
end;

procedure UnLockRecords(var F;  Start, Records : LongInt);
begin
  If not MultiTasking then
    Exit;

  While InDos do
    GiveTimeSlice;

  FLock(FileRec(F).Handle, Start * FileRec(F).RecSize, Records * FileRec(F).RecSize);
end;

function TimeOut : Boolean;
begin
  GiveTimeSlice;
  TimeOut := True;

  If MultiTasking and (LockRetry < MaxLockRetries) then
  begin
    TimeOut := False;
    Inc(LockRetry);
  end;
end;

procedure TimeOutReset;
begin
  LockRetry := 0;
end;

function InDos : Boolean;
begin
  InDos := InDosFlag^ > 0;
end;

procedure GiveTimeSlice;  ASSEMBLER;
asm
  cmp   MultiTasker, DesqView
  je    @DVwait
  cmp   MultiTasker, DoubleDOS
  je    @DoubleDOSwait
  cmp   MultiTasker, Windows
  je    @WinOS2wait
  cmp   MultiTasker, OS2
  je    @WinOS2wait
  cmp   MultiTasker, NetWare
  je    @Netwarewait
 @Doswait:
  int   $28
  jmp   @WaitDone
 @DVwait:
  mov   AX,$1000
  int   $15
  jmp   @WaitDone
 @DoubleDOSwait:
  mov   AX,$EE01
  int   $21
  jmp   @WaitDone
 @WinOS2wait:
  mov   AX,$1680
  int   $2F
  jmp   @WaitDone
 @Netwarewait:
  mov   BX,$000A
  int   $7A
  jmp   @WaitDone
 @WaitDone:
end;

procedure BeginCrit;  ASSEMBLER;
asm
  cmp   MultiTasker, DesqView
  je    @DVCrit
  cmp   MultiTasker, DoubleDOS
  je    @DoubleDOSCrit
  cmp   MultiTasker, Windows
  je    @WinCrit
  jmp   @EndCrit
 @DVCrit:
  mov   AX,$101B
  int   $15
  jmp   @EndCrit
 @DoubleDOSCrit:
  mov   AX,$EA00
  int   $21
  jmp   @EndCrit
 @WinCrit:
  mov   AX,$1681
  int   $2F
  jmp   @EndCrit
 @EndCrit:
end;

procedure EndCrit;  ASSEMBLER;
asm
  cmp   MultiTasker, DesqView
  je    @DVCrit
  cmp   MultiTasker, DoubleDOS
  je    @DoubleDOSCrit
  cmp   MultiTasker, Windows
  je    @WinCrit
  jmp   @EndCrit
 @DVCrit:
  mov   AX,$101C
  int   $15
  jmp   @EndCrit
 @DoubleDOSCrit:
  mov   AX,$EB00
  int   $21
  jmp   @EndCrit
 @WinCrit:
  mov   AX,$1682
  int   $2F
  jmp   @EndCrit
 @EndCrit:
end;

begin
  {- Init }
  LockRetry:= 0;

  asm
   @CheckDV:
    mov   AX, $2B01
    mov   CX, $4445
    mov   DX, $5351
    int   $21
    cmp   AL, $FF
    je    @CheckDoubleDOS
    mov   MultiTasker, DesqView
    jmp   @CheckDone
   @CheckDoubleDOS:
    mov   AX, $E400
    int   $21
    cmp   AL, $00
    je    @CheckWindows
    mov   MultiTasker, DoubleDOS
    jmp   @CheckDone
   @CheckWindows:
    mov   AX, $1600
    int   $2F
    cmp   AL, $00
    je    @CheckOS2
    cmp   AL, $80
    je    @CheckOS2
    mov   MultiTasker, Windows
    jmp   @CheckDone
   @CheckOS2:
    mov   AX, $3001
    int   $21
    cmp   AL, $0A
    je    @InOS2
    cmp   AL, $14
    jne   @CheckNetware
   @InOS2:
    mov   MultiTasker, OS2
    jmp   @CheckDone
   @CheckNetware:
    mov   AX,$7A00
    int   $2F
    cmp   AL,$FF
    jne   @NoTasker
    mov   MultiTasker, NetWare
    jmp   @CheckDone
   @NoTasker:
    mov   MultiTasker, NoTasker
   @CheckDone:
    {-Set MultiTasking }
    cmp   MultiTasker, NoTasker
    mov   VideoSeg, $B800
    mov   VideoOfs, $0000
    je    @NoMultiTasker
    mov   MultiTasking, $01
    {-Get video address }
    mov   AH, $FE
    les   DI, [$B8000000]
    int   $10
    mov   VideoSeg, ES
    mov   VideoOfs, DI
    jmp   @Done
   @NoMultiTasker:
    mov   MultiTasking, $00
   @Done:
    {-Get InDos flag }
    mov   AH, $34
    int   $21
    mov   WORD PTR InDosFlag, BX
    mov   WORD PTR InDosFlag + 2, ES
  end;
end.

