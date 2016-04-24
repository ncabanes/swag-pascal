(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0043.PAS
  Description: Convert Long to HEX Str
  Author: HELGE HELGESEN
  Date: 09-26-93  09:14
*)

(*
===========================================================================
 BBS: Canada Remote Systems
Date: 09-16-93 (08:30)             Number: 27395
From: HELGE HELGESEN               Refer#: NONE
  To: KURTIS LINDQVIST              Recvd: NO
Subj: Longint to HEX                 Conf: (552) R-TP
---------------------------------------------------------------------------
Here's a simple - unoptimized - function to convert a
longint to hex.
*)
function LongInt2Str(no: longint): string; assembler;
const
  Digits: array[0..$f] of char =
    ( '0', '1', '2', '3', '4' ,'5', '6', '7', '8', '9', 'A', 'B', 'C',
      'D', 'E', 'F'
    );
asm
  les  di, @Result { get address to result }
  mov  al, 8 { size of result }
  stosb
  lea  bx, Digits { get adress to digit table }
  mov  dx, word ptr no+2
  mov  cx, 2
@1:
  mov  al, dh
  shr  al, 4
  xlat
  stosb
  mov  al, dh
  and  al, 15
  xlat
  stosb
  mov  al, dl
  shr  al, 4
  xlat
  stosb
  mov  al, dl
  and  al, 15
  xlat
  stosb
  mov  dx, word ptr no
  loop @1
end;
---
 ■ RM 1.2 00308 ■ C program run.  C program crash.  C programmer quit
 * Midnight Sun BBS, Norway +47 81 84545 HST/DS, 9 Gb
 * PostLink(tm) v1.07  MIDNIGHT (#602) : RelayNet(tm)
===========================================================================
 BBS: Canada Remote Systems
Date: 09-16-93 (20:19)             Number: 27393
From: PHIL NICKELL                 Refer#: NONE
  To: KURTIS LINDQVIST              Recvd: NO
Subj: Longint to HEX                 Conf: (552) R-TP
---------------------------------------------------------------------------
KL│Allright, I have been struggling with this problem for awhile but I give up.
  │A friend of mine wrote a unit that would convert a longint to a HEX number in
  │string. This is for a program that stores one file for each user (it's an ord
  │door), the name of the file is equal to the HEX number representing the

 I'll include two functions named HEXLONG that produce identical
 results.  The first is pure classic Turbo Pascal, the second is a Turbo
 Pascal Assembler function that is blinding-speed vs size optimized.
 You pass them a longint value, they return an 8 byte string.  Voila.
 Take your pick.


(* Return a 8 byte ascii string of the hex value of the longint
   argument *)
FUNCTION  Hexlong (argument : longint): namestr;
   var i      :longint;
       res    :namestr;
   Const
       HexTable  :array[0..15] of char = '0123456789ABCDEF';
  begin
    res[0] := #8;
    for i := 0 to 7 do
      res[8-i] := HexTable[ argument shr (i shl 2) and $f];
    hexlong := res;
  end;

FUNCTION  Hexlong (argument : longint): namestr; Assembler;
  asm
     cld
     les    di,@result
     mov    al,8                   { store string length }
     stosb
     mov    cl, 4                  { shift count }

     mov    dx,Word Ptr Argument+2 { hi word }
     call   @1                     { convert dh to ascii }
     mov    dh, dl                 { lo byte of hi word }
     call   @1                     { convert dh to ascii }
     mov    dx,Word Ptr Argument   { lo word }
     call   @1                     { convert dh to ascii }
     mov    dh, dl                 { lo byte of lo word }
     call   @1                     { convert dh to ascii }
     jmp    @2

   @1:
     mov    al, dh                 { 1 byte }
     and    al, 0fh                { low nybble }
     add    al, 90h
     daa
     adc    al, 40h
     daa
     mov    ah, al                 { store }
     mov    al, dh                 { 1 byte }
     shr    al, cl                 { get high nybble }
     add    al, 90h
     daa
     adc    al, 40h
     daa
     stosw                         { move characters to result }
     retn                          { return near }
   @2:
  end;

begin
  Writeln( Hexlong($1234ABCD) );
end.
---
 ■ SLMR 2.1a ■ doesn't take a rocket scientist to be a rocket scientist
 ■ KMail 3.00d Twin Peaks (303)-651-0225 ■ Home of KMail ■
 ■ RNET 2.00b: ■ Twin Peaks BBS ■ (303)-651-0225, Longmont, Co.
 * The DC Information Exchange (703)836-0748
 * PostLink(tm) v1.07  DCINFO (#16) : MetroLink(tm)

