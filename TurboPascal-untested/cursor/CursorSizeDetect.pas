(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0005.PAS
  Description: Cursor Size & Detect
  Author: SEAN PALMER
  Date: 05-28-93  13:36
*)

{
SEAN PALMER
}

unit cursor; {Public domain, by Sean Palmer aka Ghost}

interface

var
  maxSize : byte;

procedure setSize(scans : byte);  {set size from bottom, or 0 for off}
procedure detect;     {get max scan lines by reading current cursor}

implementation

procedure setSize(scans : byte);
var
  t : byte;
begin
  if scans = 0 then
    t := $20
  else
    t := maxSize - scans;
  asm
    mov ah, 1
    mov bh, 0
    mov ch, t
    mov cl, maxSize
    dec cl
    int $10
  end;
end;

procedure detect; assembler;
asm  {do NOT call while cursor's hidden}
  mov ah, 3
  mov bh, 0
  int $10
  inc cl
  mov maxSize, cl
end;

begin
  detect;
end.

program test;
uses
  cursor;
begin
  writeln(cursor.maxSize);
  cursor.setSize(cursor.maxSize);
  readln;        {block}
  cursor.setSize(0);
  readln;                     {hidden}
  cursor.setSize(cursor.maxSize div 2);
  readln;  {half}
  cursor.setSize(2);
  readln;                     {normal}
end.

