(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0029.PAS
  Description: SHARE Unit in ASM
  Author: HELGE HELGESEN
  Date: 09-26-93  10:17
*)

(*
From: HELGE HELGESEN
Subj: SHARE.EXE
---------------------------------------------------------------------------
-> Can I lock the files after the RESET and unlock before / after
-> the close?

Yes. This is one advantage of network files. All users running
your program will open the files simultaneously, and when a
process wants to write to a record, it simply locks it. No other
processes can then read or write to the record, though they can
read/write all other records.

(I assume you're NOT using text files!)

-> I'd like to add a thing that checks if the file is locked
-> before the reset.

If a record is locked, then the process still can open the file.

-> Does the "lock" occur on the open or the read of the file?

What do you mean? You can open a file in numerous ways. If you
open it for shDenyN, then locking is done on record(byte) basis.
If you open it for exclusive(FileMode=2) access or shDenyRW (no
other can access the file) then locking is done on file basis.

Here's a short unit with file locking support. It's written for
Turbo Pascal (or Borland Pascal) 7.0, but it should work with
TP60 without many modifications.
SHARE.PAS --->
*)

Unit Share;
{
  Utility to allow file sharing on a network
  (c) 1993 Helge Olav Helgesen
}

interface

uses
  dos;

function shShareInstalled: boolean; { check if SHARE is installed }
function LockByte(var thefile; FirstByte, NoBytes: longint): byte;
function UnLockByte(var thefile; FirstByte, NoBytes: longint): byte;
function Lock(var thefile; FirstRec, NoRecs: word): byte;
function UnLock(var thefile; FirstRec, NoRecs: word): byte;

const
{
  Here's a list of file file modes you can open a file with. To allow
  multiple access to one file, it should either be marked R/O, or opened
  with shDenyN-mode. To open a file with a spesified mode, do:

  FileMode:=shDenyN+shAccessRW; (Add the flags)
}
  shDenyR    = $30; { Deny Read to other Processes }
  shDenyW    = $20; { Deny Write to other Processes }
  shDenyRW   = $10; { Deny access to other Processes }
  shDenyN    = $40; { Deny none - full access to other Processes }
  shAccessR  = $0;  { open for Read access }
  shAccessW  = $1;  { open for Write Access }
  shAccessRW = $2;  { open for both read and write }
  shPrivate  = $80; { private mode - don't know what this is... }

implementation { the private part }

function shShareInstalled; assembler;
{
  Returns TRUE if Share is installed on the local machine!
}
asm
  mov ax,$1000 { check if SHARE is installed }
  int $2f { call multiplex interrupt }
end; { shShareInstalled }

function LockByte; assembler;
{
  Locks a region of bytes in the specified file.
}
asm
  mov ax, $5c00
  les bx, thefile
  mov bx, es:[bx].FileRec.Handle
  les dx, FirstByte
  mov cx, es
  les di, NoBytes
  mov si, es
  int $21
  jc @1
  xor al, al
@1:
end;

function Lock; assembler;
{
  Lock records.
}
asm
  les bx, thefile
  mov cx, es:[bx].FileRec.RecSize
  mov ax, FirstRec
  mul cx
  push ax
  push dx
  mov ax, NoRecs
  mul cx
  mov si, dx
  mov di, ax
  pop cx
  pop dx
  mov ax, $5c00
  mov bx, es:[bx].FileRec.Handle
  int $21
  jc @1
  xor al, al
@1:
end;

function UnLockByte; assembler;
asm
  mov ax, $5c01
  les bx, thefile
  mov bx, es:[bx].FileRec.Handle
  les dx, FirstByte
  mov cx, es
  les di, NoBytes
  mov si, es
  int $21
  jc @1
  xor al, al
@1:
end;

function UnLock; assembler;
asm
  les bx, thefile
  mov cx, es:[bx].FileRec.RecSize
  mov ax, FirstRec
  mul cx
  push ax
  push dx
  mov ax, NoRecs
  mul cx
  mov si, dx
  mov di, ax
  pop cx
  pop dx
  mov ax, $5c01
  mov bx, es:[bx].FileRec.Handle
  int $21
  jc @1
  xor al, al
@1:
end;

end.


They're used this way:
Lock(MyFile, FirstByteToLock, NoBytesToLock);
LockByte(MyFile, FirstRecToLock, NoRecsToLock);

Since you're working with records, you probably want to use Lock.
When you want to update a record, this might be the code:

Lock(MyFile, Rec, 1);
Write(MyFile, MyRec);
UnLock(MyFile, Rec, 1);

You will of course have to make code to check if the lock failed
(any result but 0), you can't write to the record. Always unlock
the record as soon you're done!

The last ones are UnLock and UnLockByte. They're used the same
way as Lock and LockByte.

And a last note! You can't open a file in a mode that conflicts
with the access other processes have to a file.

Eg.

if you first open a file with mode shDenyN+shAccessRW, and then
try to open the file again (without closing the first one) with
the mode shDenyRW+shAccessRW, the reset will fail.

I'll see if I can make a short program to illustrate how this
works...

Hope this helps a litte,

... Helge

