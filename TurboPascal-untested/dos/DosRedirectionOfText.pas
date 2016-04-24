(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0083.PAS
  Description: DOS Redirection of text
  Author: ANDREW EIGUS
  Date: 11-26-94  05:08
*)

{
 MH> Could anyone know how to redirect a standard output (CRT) to a file using
 MH> standard Write/WriteLn(Output,...) Pascal procedures ?

I was playing around with this about two hours and i still didn't figure out
how to construct my program so Crt standard write and writeln procedures would
write depending on which device you specified in the command line.

So i left idea to trouble myself more and wrote my own dependent write
procedures that will print only string-typed variables, but at least can be
redirected to any other device than CONsole device. :)

Now my code goes:

{---cut here---}

Program SupportingRedirectionWithCrt;
{ Public Domain, by Andrew Eigus }

uses Crt;

Procedure DevWrite(Str : string); assembler;
{ Device-dependent write procedure }
Asm
  push ds
  lds si,Str
  cld
  xor ax,ax
  lodsb
  mov cx,ax
  mov dx,si
  mov bx,1 { standard output device }
  mov ah,40h
  int 21h
  pop ds
End; { DevWrite }

Procedure DevWriteLn(Str : string); assembler;
{ Device-dependent writeln procedure }
Asm
  les si,Str
  push es
  push si
  call DevWrite
  mov ah,02h
  mov dl,0Dh
  int 21h
  mov dl,0Ah
  int 21h
End; { DevWriteLn }

Begin
  DevWriteLn('Hello, world!'#13#10);
  DevWriteLn('This text might be freely redirected to any device from the');
  DevWriteLn('command line.');
  WriteLn(#13#10'And this text may appear on screen only.')
End.


