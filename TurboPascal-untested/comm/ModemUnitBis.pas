(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0109.PAS
  Description: Modem unit
  Author: UDI SHPIRER
  Date: 01-02-98  07:39
*)


{
 Hi MR. Davis!
 This is just a little modem unit i have built , i hope its good enough
 so you can include it in SWAG.

 MODIFYING PROHIBITED!
}
unit modem;

INTERFACE

VAR
 MDM:ShortInt;
{
 INITIALIZES THE MODEM. MUST BE IN THE BEGINNING OF THE CODE.
}
PROCEDURE InitModem(port:word);
{
 SEND A CHAR TO A MODEM ON A SPECIFIED PORT.
}
PROCEDURE SendChar(port:word;ch:char);
{
 SEND ASCI CODE TO A MODEM ON A SPECIFIED PORT.
}
PROCEDURE SendAsci(port:word;asc:ShortInt);
{
 READ AN ASCI CHARACTER FROM A SPECIFIED PORT , AND PUTS IT IN <MDM>.
}
PROCEDURE ReadAsci(port:word);
{
 FLUSH A SPECIFIED PORT'S BUFFER.
}
PROCEDURE FlushPort(port:byte);

{
 IMPORTANT NOTICE : WHEN SPECIFYING A PORT ADRESS , IT GOES LIKE THIS :
                    '0' : COM PORT 1.
                    '1' : COM PORT 2.
                    '2' : COM PORT 3.
                    '3' : COM PORT 4.
}

IMPLEMENTATION

PROCEDURE InitModem(port:word); ASSEMBLER;
 ASM
  mov ah,00                      { INIT THE MODEM }
  mov al,11100011b               { MAXIMUM OPTIMIZATION }
  mov dx,port                    { SET COM PORT }
  int 14h                        { DIRECT PORT ACCESS INTERRUPT }
 end;

PROCEDURE SendChar(port:word;ch:char);
 var
  asc:shortint;
 begin
  asc:=ord(ch);
  ASM
   mov ah,01h                    { WRITE TO THE PORT }
   mov dx,port                   { SET COM PORT }
   mov al,asc                    { THE CHAR TO SEND }
   int 14h                       { DIRECT PORT ACCESS INTERRUPT }
  end;
 end;

PROCEDURE SendAsci(port:word;asc:ShortInt); ASSEMBLER;
 ASM
  mov ah,01h                     { WRITE TO THE PORT }
  mov dx,port                    { SET COM PORT }
  mov al,asc                     { THE ASCI TO SEND }
  int 14h                        { DIRECT PORT ACCESS INTERRUPT }
 end;

PROCEDURE ReadAsci(port:word);
 begin
  asm
   mov ah,02h                    { READ FROM THE PORT }
   mov dx,port                   { SET COM PORT }
   mov al,00h                    { READ FROM THE PORT }
   int 14h                       { DIRECT PORT ACCESS INTERRUPT }
   mov MDM,al
  end;
 end;

PROCEDURE FlushPort(port:byte); ASSEMBLER;
 ASM
  mov ah,04h                     { FLUSH THE PORT BUFFER }
  mov dl,port                    { SET COM PORT }
  mov dh,00000011b               { MAXIMUM PROTOCOL OPTIMIZATION }
  int 14h                        { DIRECT PORT ACCESS INTERRUPT }
 end;

BEGIN

END.

