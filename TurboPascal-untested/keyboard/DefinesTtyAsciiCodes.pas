(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0119.PAS
  Description: Defines TTY Ascii Codes
  Author: TOBIN FRICKE
  Date: 03-04-97  13:18
*)

Unit TTY;

{ Copyright (c) 1995 by Tobin T. Fricke, All Rights Reserved            }
{ This is freeware.  Created March 3, 1995 by Tobin Fricke.             }

{ Description: Basically, this unit defines the various TTY ascii codes }
{              which come in handy sometimes.                           }

{ If you use this, I'd appreciate it if you could send me a postcard    }
{ from where you live, or at least send me an email.  My email address  }
{ is tobin@mail.edm.net.  If that doesn't work, try using               }
{ fricke@roboben.engr.ucdavis.edu.  My postal address is:               }
{ 25001 El Cortijo Ln., Mission Viejo, CA 92691-5236, USA.  Thanks!     }


Interface

Const
 NUL=#0; { Null      }
 SOH=#1;
 STX=#2;
 ETX=#3;
 EOT=#4;
 ENQ=#5;
 ACK=#6; {Acknowledge}
 BEL=#7; { Beep      }
 BS=#8;  { Backspace }
 HT=#9;  { Horiz Tab }
 LF=#10; { Line Feed }
 VT=#11; { Vert Tab        }
 FF=#12; { Form Feed       }
 CR=#13; { Carriage return }
 SO=#14;
 SI=#15;
 DLE=#16;
 DC1=#17;
 DC2=#18;
 DC3=#19;
 DC4=#20;
 NAK=#21;
 SYN=#22;
 ETB=#23;
 CAN=#24;
 EM=#25;
 SUB=#26;
 ESC=#27;
 FS=#28; {cursor right}
 GS=#29; {cursor left }
 RS=#30; {cursor up   }
 US=#31; {cursor down }

Implementation

End.

