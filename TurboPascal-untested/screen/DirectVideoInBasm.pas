(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0026.PAS
  Description: Direct Video in BASM
  Author: JOHN GIESBRECT
  Date: 08-23-93  09:16
*)

{
===========================================================================
 BBS: Canada Remote Systems
Date: 08-17-93 (19:47)             Number: 34561
From: JOHN GIESBRECHT              Refer#: NONE
  To: CHRIS PORTMAN                 Recvd: NO
Subj: DIRECT VIDEO WRITES            Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
Chris Portman (1:229/15) wrote to All on <15 Aug 10:38> :

 CP> Can anyone write me a procedure that will write a character on
 CP> the screen without moving the cursor (ie - DirWrite (80, 25,
 CP> '!');). I just need this to write to the space at 80x25
 CP> without scrolling the screen.
}
USES
  crt;

PROCEDURE writechar (c : CHAR; attr, x, y : BYTE); assembler;

(*  assumes video page 0
 *  upper left-hand corner is (1, 1)
 *)
asm
  mov ax, $0300   (* get cursor position *)
  XOR bh, bh
  INT $10
  push dx         (* and save it *)
  mov ax, $0200   (* set cursor position *)
  XOR bh, bh
  mov dh, BYTE PTR y
  DEC dh
  mov dl, BYTE PTR x
  DEC dl
  INT $10
  mov ah, $09     (* write char and attribute *)
  mov al, BYTE PTR c
  XOR bh, bh
  mov bl, BYTE PTR attr
  mov cx, $0001
  INT $10         (* restore original cursor position *)
  mov ax, $0200
  XOR bh, bh
  pop dx
  INT $10
END;

PROCEDURE WriteString (Row, Col, Attr : BYTE; STR : STRING);
VAR Len : Byte ABSOLUTE Str;
    I   : Byte;
BEGIN
  FOR I := 1 To Len DO  writechar (STR[i], Attr, Col + i, Row);
END;

BEGIN
  CLRSCR;
  GOTOXY (40, 13);
  writechar ('*', $0F, 1, 1);
  writechar ('*', $0e, 80, 1);
  writechar ('*', $0d, 1, 25);
  writechar ('*', $0c, 80, 25);
  WriteString(15,25,31,'Gayle Davis was here');
  READKEY;
END.

- - - MSQ - EE 2.1a / e2
 * Origin : * idiot savant * St. Catharines, ON, Canada * (1 : 247 / 128)

