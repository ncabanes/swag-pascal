(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0061.PAS
  Description: Keyboard Characters
  Author: GREG VIGNEAULT
  Date: 01-27-94  12:11
*)

{
> Can you help me with an explaination as the the function of the
> various control codes.  Please help me fill in this list:

 ASCII TABLE...

 Dec  Hex   Binary    Ctrl Name of character
 ---  ---  ---------   --  --------------------------------------
   0  00h  0000 0000   ^@  NUL  null
   1  01h  0000 0001   ^A  SOH  start of header
   2  02h  0000 0010   ^B  STX  start of text
   3  03h  0000 0011   ^C  ETX  end of text
   4  04h  0000 0100   ^D  EOT  end of transmission
   5  05h  0000 0101   ^E  ENQ  inquiry
   6  06h  0000 0110   ^F  ACK  acknowledgement
   7  07h  0000 0111   ^G  BEL  bell
   8  08h  0000 1000   ^H  BS   backspace
   9  09h  0000 1001   ^I  HT   horizontal tab    (Can't display)
  10  0Ah  0000 1010   ^J  LF   line feed         (Can't display)
  11  0Bh  0000 1011   ^K  VT   vertical tab
  12  0Ch  0000 1100   ^L  FF   form feed
  13  0Dh  0000 1101   ^M  CR   carriage return   (Can't display)
  14  0Eh  0000 1110   ^N  SO   shift out
  15  0Fh  0000 1111   ^O  SI   shift in
  16  10h  0001 0000   ^P  DLE  data link escape
  17  11h  0001 0001   ^Q  DC1  device control 1  (XON)
  18  12h  0001 0010   ^R  DC2  device control 2
  19  13h  0001 0011   ^S  DC3  device control 3  (XOFF)
  20  14h  0001 0100   ^T  DC4  device control 4
  21  15h  0001 0101   ^U  NAK  negative acknowledgement
  22  16h  0001 0110   ^V  SYN  synchronous idle
  23  17h  0001 0111   ^W  ETB  end of transmission block
  24  18h  0001 1000   ^X  CAN  cancel
  25  19h  0001 1001   ^Y  EM   end of medium
  26  1Ah  0001 1010   ^Z  SUB  substitute
  27  1Bh  0001 1011   ^[  ESC  escape
  28  1Ch  0001 1100   ^\  FS   file separator
  29  1Dh  0001 1101   ^]  GS   group separator
  30  1Eh  0001 1110   ^^  RS   record separator
  31  1Fh  0001 1111   ^_  US   unit separator
  32  20h  0010 0000       SP   space


