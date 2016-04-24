(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0053.PAS
  Description: File and Record Locks
  Author: RONEN MAGID
  Date: 05-25-94  08:19
*)

{
This is a demonstration of a network unit capable of locking
pascal records or any set of bytes on a file.

Programmer: Ronen Magid, Qiyat-Ono Israel.
Contributed to the SWAG.
}

Unit Network;
Interface
Uses Dos;

Var
  Regs       : Registers;
  RegSize    : Byte;
  RecSize    : Longint;
  OffSet     : LongInt;
  FileHandle : word;

Const
 SH_COMPAT   =  $0000;
 SH_DENYRW   =  $0010;
 SH_DENYWR   =  $0020;
 SH_DENYRD   =  $0030;
 SH_DENYNONE =        $0040;
 SH_DENYNO   =  SH_DENYNONE;
 O_RDONLY    =  $0;
 O_WRITE     =  $1;
 O_RDWR      =  $2;

function  Lock(Var Handle: Word; Var  Offset, BufLen: Longint): Word;
function  Unlock(Var Handle: Word; Var OffSet, BufLen: Longint): Word;

Implementation

function Lock(var  handle: word; var  offset, buflen: longint): word;
var
  TempOffset:longint;
begin
  Lock := 0;
  TempOffset:=1000000000+Offset;
  fillchar(regs, sizeof(regs), 0);
  regs.ah := $5C; { Lock file access }
  regs.al := 0;
  regs.bx := handle;
  regs.cx := TempOffset shr RegSize; {and $ffff;}
  regs.dx := TempOffset and $ffff;
  regs.si := buflen shr RegSize; {and $ffff;}
  regs.di := buflen and $ffff;
  MsDos(regs);
  if (regs.Flags and 1) <> 0 then
  Lock := regs.ax;
end;

function Unlock(var handle: word; var offset, buflen: longint): word;
var
  TempOffset:longint;
begin
  Unlock := 0;
  TempOffset:=1000000000+Offset;
  regs.ah := $5C; { Unlock file access }
  regs.al := 1;
  regs.bx := handle;
  regs.cx := TempOffset shr RegSize; {and $ffff;}
  regs.dx := TempOffset and $ffff;
  regs.si := buflen shr RegSize; {and $ffff;}
  regs.di := buflen and $ffff;
  MsDos(regs);
  if (regs.Flags and 1) <> 0 then
  Unlock := regs.ax;
end;

End.

{ ---------------------     TEST CODE ...   CUT HERE -------------------}

{
This demonstartion will show how to use the NETWORK file-lock
unit to allow lock and lock-check of records in a regular
pascal database file.

Programmer: Ronen Magid, Qiyat-Ono Israel.
Contributed to the SWAG.
}

Program NetTest;
uses Dos,Network;

Type
  PhoneRecord = Record
    Name    :  String[30];
    Address :  String[35];
    Phone   :  String[15];
  End;

Var
  PhoneRec   : PhoneRecord;
  PhoneFile  : File of PhoneRecord;
  FileHandle : word;
  LockStatus : Word;
  I          : Byte;
  Ok         : Boolean;

Function LockPhoneRec(which: LongInt): Boolean;
Begin
  recsize := SizeOf(PhoneRec);
  OffSet :=  RecSize * Which - Recsize;
  FileHandle := FileRec(PhoneFile).handle;
  LockStatus := Lock(FileHandle, offset, recsize);
  if LockStatus = 0 then
  begin
    LockPhoneRec:=True;
  end else
  begin
    LockPhoneRec:=False;
  end;
end;

function UnLockPhoneRec(Which: Byte): boolean;
var
  ok:   boolean;
begin
  recsize := SizeOf(PhoneRec);
  OffSet := Which * RecSize - RecSize;
  FileHandle := FileRec(PhoneFile).handle;
  LockStatus := Unlock(FileHandle, offset, recsize);
  if LockStatus <> 0 then
  begin
    UnlockPhoneRec := false;
  end else
  begin
    UnlockPhoneRec := true;
  end;
end;

begin
  Assign(Phonefile,'PHONE.SMP');
  Rewrite(Phonefile);
  For I:=1 to 5 do Write(Phonefile,phoneRec);
  Close(Phonefile);

  FileMode := SH_DENYNO + O_RDWR;    {Important, Before RESET!}
  Reset(Phonefile);

  { And now lets begin to lock... }

  Ok:=LockPhoneRec(2);
  {Locking phone rec 2}

  {Now lets see if its locked... }

  Ok:=LockPhoneRec(2);
  {a record is already locked if we
   cant lock it. This locking procedure
   can be performed by other PCs & other
   tasks.}

  If Not Ok then writeln('#2 locked');

  Ok:=UnlockPhoneRec(2);
  { lets release it. This will enable
    other tasks or LAN PCs to lock
    (& obtain) this record again...}

  If Ok then Writeln('Rec #2 unlocked');

  {thats it...}
  Ok:=LockPhoneRec(2);
  If Ok then Writeln('And since its free we can relock it !');
  Close(phoneFile);
End.

