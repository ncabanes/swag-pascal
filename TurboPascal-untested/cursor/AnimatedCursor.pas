(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0026.PAS
  Description: Animated Cursor
  Author: JONATHAN ANDERSON & KELLY SMALL
  Date: 05-26-95  22:57
*)


{ Updated CURSOR.SWG on May 26, 1995 }

{
Hi everyone.  Recently, I made a program to animate the cursor, and
when I added support for hiding and showing the cursor, my program
ceased to work like it should (all int 10h functions (video) didn't
work right.)  If anyone has any suggestions, optimizations, or ways
to get this to take up less memory, please reply.

----8<-cut-here-
Program AnimateCursor;
{ AnimateCursor Copyright (C) 1995 by Jonathan Anderson }
{ This program does what it says -- it makes the cursor move up and down }
{ thanks to John Baldwin for nice description of cursor handling }

{-$DEFINE Debug}        { Define this if changing the code }
{$DEFINE Use286}       { Define this to use 286 code }

{$IFDEF Debug}

{$M $1000,0,0}   { 4K stack, no heap }
{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,R-,S+,V+,X-}     { TP6 compile options }

{$ELSE}

{$M $400,0,0}    { 1K stack, no heap }
{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S-,V-,X-}

{$ENDIF}

{$IFDEF Use286}
{$G+}
{$ENDIF}

Uses Dos;

Var OldInt1C, OldInt09 : Procedure;
    OldInt10           : Pointer;     { status = cursor blink pattern }
    x, z, status       : Byte;        { x = top scan line for cursor }
    y                  : Boolean;     { z = width (in scan lines) of cursor }
                                      { y = cursor going up (F) or down (T) }

Procedure RemoveAnimate; Assembler;
Asm                  { thanks to Luis Mezquita Raya for this... }
  cli
  mov   ah,1
  mov   ch,6                { this procedure (c) Jul 94 Luis Mezquita Raya }
  mov   cl,7
  int   10h
  mov   ah,49h
  mov   es,PrefixSeg
  push  es
  mov   es,es:[2ch]
  int   21h
  pop   es
  mov   ah,49h
  int   21h
  sti
End;

{$F+}
Procedure NewInt09; Interrupt;      { KBD handler for unloading hotkey }
Var KB : Byte;
Begin
  KB := Port[$60];
  Inline($9C);                      { pushf }
  OldInt09;                         { call old interrupt }
  If KB = 88 Then                   { Use F12 to unload from memory }
    Begin
      SetIntVec($1C, @OldInt1C);
      SetIntVec($10, OldInt10);
      SetIntVec($09, @OldInt09);
      RemoveAnimate;
    End;
End;

Procedure NewInt10; Interrupt; Assembler;  { handler to allow programs  }
Asm                                        { to hide & show cursor...   }
{$IFDEF Use286}                            { right now, it doesn't work }
  pusha
{$ELSE}
  push  ax
  push  bx
  push  cx
  push  dx
  push  si
  push  di
{$ENDIF}
  cmp   ah,1                               { check for cursor change }
  jnz   @Skip                              { request & jump if not   }
  mov   status,ch
  and   status,60h                         { isolate bits 5 and 6 }
@Skip:
{$IFDEF Use286}
  popa
{$ELSE}
  pop   ax
  pop   bx
  pop   cx
  pop   dx
  pop   si
  pop   di
{$ENDIF}
  call  oldint10                           { call olt interrupt }
End;

Procedure NewInt1C; Interrupt;             { timer handler; changes cursor }
Var ctype : Byte;
Begin
  If (x=129) or (x=143-z) Then y := Not(y);  { reverse direction of cursor }
  If y Then Asm dec x End                  { why use Inc() and Dec() ? }
  Else Asm inc x End;
  ctype := status OR x;            { combine status bits with position bits }
  Asm
    mov  ah,1                      { request cursor change }
    mov  ch,ctype                  { set top scan line }
    mov  cl,ctype                  { set bottom scan line }
    add  cl,z
    call OldInt10      { call oldint instead of wasting time calling new one }
  End;
  Inline($9C);         { pushf }
  OldInt1C;            { call old interrupt }
End;
{$F-}

Begin
  x := 129;  { had to mess with this value for use of all scan lines in char }
  z := 1;                    { cusor width = 1 }
  status := 0;               { normal cursor }
  y := True;                 { MUST be true...}
  GetIntVec($09, @OldInt09);
  SetIntVec($09, @NewInt09);
  GetIntVec($10, OldInt10);
  SetIntVec($10, @NewInt10); { comment this line for prog. to work w/o int10 }
  GetIntVec($1C, @OldInt1C);
  SetIntVec($1C, @NewInt1C);
  Keep(0);                   { terminate, stay resident }
End.

(*
  From: Kelly Small

You don't restore the registers properly during the Int $10 ISR.
You need to pop them in the reverse order that they were pushed:

>Procedure NewInt10; Interrupt; Assembler;  { handler to allow programs  }
>Asm                                        { to hide & show cursor...   }
>  push  ax
>  push  bx
>  push  cx
>  push  dx
>  push  si
>  push  di


>  pop   ax
>  pop   bx
>  pop   cx
>  pop   dx
>  pop   si
>  pop   di

After this you would have ax = di
                          bx = si etc.

Reverse the order of your pop's and it should work.
*)

