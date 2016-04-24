(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0070.PAS
  Description: ASM Drive Valid Function
  Author: SWAG SUPPORT TEAM
  Date: 02-15-94  07:56
*)

function DriveValid(Drive: Char): Boolean; assembler;
asm
    mov   ah, 19h     { Select DOS function 19h }
    int   21h         { Call DOS for current disk drive }
    mov   bl, al      { Save drive code in bl }
    mov   al, Drive   { Assign requested drive to al }
    sub   al, 'A'     { Adjust so A:=0, B:=1, etc. }
    mov   dl, al      { Save adjusted result in dl }
    mov   ah, 0eh     { Select DOS function 0eh }
    int   21h         { Call DOS to set default drive }
    mov   ah, 19h     { Select DOS function 19h }
    int   21h         { Get current drive again }
    mov   cx, 0       { Preset result to False }
    cmp   al, dl      { Check if drives match }
    jne   @@1         { Jump if not--drive not valid }
    mov   cx, 1       { Preset result to True }
@@1:
    mov   dl, bl      { Restore original default drive }
    mov   ah, 0eh     { Select DOS function 0eh }
    int   21h         { Call DOS to set default drive }
    xchg  ax, cx      { Return function result in ax }
end;

