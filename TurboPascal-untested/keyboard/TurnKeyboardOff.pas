(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0006.PAS
  Description: Turn Keyboard OFF
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:49
*)

{IDIOT PASCAL 101
----------------

Welcome to IP 101. In today's lesson we will be answering a few
often asked questions about Turbo Pascal. if you signed up For
IDIOT C/C++ 101, please get up and run beFore you get shot.

Q:  HOW do I TURN ofF/ON THE KEYBOARD FROM MY Program?
A:  Easy. Though you may search through many books, you will find
    the answer in a Excellent reference called _THE MS-Dos
    ENCYCLOPEDIA_. It tells of a mystical I/O port where you can
    turn off/on the keyboard by just flipping a bit. This port is
    the 8259 Programmible Interrupt Controller. Now, part of the
    8259 is the Interrupt Mask Register, or IMR For short. The
    port location is $21. to turn off the Keyboard...(RECKLESSLY)

}    Procedure KEYBOARD_ofF;

      begin
        PorT[$21]:=$02
      end;
{
    to turn the keyboard back on (RECKLESSLY), just set the port
    back to $0.

      (THE MSDos ENCYCLOPEDIA (C) 1988 Microsoft Press p417)

Q: HOW do I FLIP BITS ON/ofF in A Byte or Integer?
A: Simple, Really.  The following Procedures work on both
   Byte,Char,Boolean,Integer, and Word values(I hope).
}
Procedure SBIT(Var TARGET;BITNUM:Integer);   {set bit}

Var
  SUBJECT : Integer Absolute TARGET;
  MASK    : Integer;

 begin
   MASK := 1 SHL BITNUM;
   SUBJECT := SUBJECT or MASK
 end;

Procedure CBIT(Var TARGET;BITNUM:Integer);  {clear bit}

 Var
   SUBJECT : Integer Absolute TARGET;
   MASK    : Integer;

  begin
    MASK := not(1 SHL BITNUM);
    SUBJECT := SUBJECT and MASK
  end;

Procedure SETBIT(Var TARGET;BITNUM:Integer;VALUE:Byte);{control}
                                                       {Proc.  }
 begin
   if VALUE = 1 then
     SBIT(TARGET,BITNUM)
   else
     CBIT(TARGET,BITNUM)
 end;


