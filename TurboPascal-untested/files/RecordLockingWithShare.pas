(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0088.PAS
  Description: Record Locking with Share
  Author: BRAD ZAVITSKY
  Date: 05-31-96  09:17
*)

{
You may be unlocking the records incorrectly, it may be your system, or
it may be bad code (I only found one good proc in AllSwags and that
needed some tweaking to get it to work right).  Here is a program that
has been tested and works fine, I had ~7 copies running at once under
Win95 and it was still pretty fast:

{NOTE: IT generates the dat file if one is not found}

{$M 4000, 0,0}

program Test;

uses Crt;

const
  {File mode def's}
  fmReadOnly  = $00;
  fmWriteOnly = $01; {Use one of these}
  fmReadWrite = $02;

  fmDenyAll   = $10; {with one of these}
  fmDenyWrite = $20;
  fmDenyRead  = $30;
  fmDenyNone  = $40;

type
  LockAction = (Lock, Unlock);

var
  Err: Integer;
  Timer: Longint absolute $40:$6C;
  Buffer: array[0..4991] of byte;
  Data: array[0..127] of byte;
  F: file;
  I: Integer;
  FPos: Longint;

function ShareIn: Boolean; assembler;
asm
  mov ax, 1000h  {Test for share}
  int 2fh        {Call multiplex interrupt}
  cmp al, 0ffh   {ShareIn = AL=$FF}
  xor al, al     {Default is false}
  jne @@Done     {False}
  mov al, 01h    {True}
@@Done:
  mov ax, 01h
end;

function FLock(var F; Action: LockAction; FPos,Len: Longint): Word;
  assembler;
asm
  je @@End
  mov al, Action  {0=Lock,1=Unlock}
  mov ah, $5C     {Dos lock function}
  les si, F       {Load F}
  mov bx, es:[si] {Get file handle}
  les dx, Fpos
  mov cx, es      {CX:DI=Begin position}
  les di, len
  mov si, es      {SI:DI length lock area}
  int 21h         {MS-DOS}
  jc @@End        {If error, return AX}
  xor ax, ax      {Else, return 0}
@@End:
end;

begin
  if not ShareIn then
  begin
    Writeln('Either run under Win95 or install SHARE');
    Exit;
  end;
  {$I-}
  assign(F, 'Test.dat');
  filemode := fmDenyNone and fmReadWrite;
  Reset(F,128);
  if IOResult = 2 then
  begin
    FileMode := $02;
    Rewrite(F, 1);
    BlockWrite(F,Buffer,SizeOf(Buffer));
    Close(F);
    FileMode := fmDenyNone + fmReadWrite;
    Reset(F,128);
  end;
  {$I+}
  repeat
    I := 0;
  while not EOf(F) do
  begin
    inc(I);
    FPos := FilePos(F);
    repeat
      Err := Flock(F,Lock,FPos,FPos+SizeOf(Data));
    until Err <> 33;
    if Err <> 0 then
    begin
      Writeln('Error locking!');
      Halt;
    end;
    BlockRead(F, Data, 1);
    Flock(F,unLock,FPos,FPos+SizeOf(Data));
    Writeln(I);
  end;
  Seek(F,0);
  until KeyPressed;
  Close(F);
end.

