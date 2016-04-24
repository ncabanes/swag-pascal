(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0038.PAS
  Description: Trapping 8087 Errors
  Author: DEVEN HICKINGBOTHAM
  Date: 11-02-93  05:35
*)

{
> I know that in pascal there is some way to create the Program
> from crashing if the users does something wrong.  I need to know how to
To prevent Type errors on input always use Strings and convert them
afterwards using the VAL Procedure.

Try this to trap arithmetic errors.
}

{$N+,G+}
Unit op8087;

{ The routines below duplicate two Op8087 routines For use in TPW, +
  Exceptions8087 and Error8087.  These routines are helpful when +
  doing Real math and you don't want to explicitly check For divide +
  by zero, underflow, and overflow.  Need to use the compiler +
  directives N+ and G+.  See OPro or 8087 documentation For a complete +
  description of the 8087 status Word returned by Error8087.

  Do not embed Error8087 in a Write statement as the 8087 status Word +
  will be cleared, and the result meaningless.

  Version 1.00 09/17/92

  Deven Hickingbotham, Tamarack Associates, 72365,46

  -----------------------------------------------------------------
  Added infinity and NAN 'Constants' and created Unit December 1992
  Kevin Whitefoot, Aasgaten 45, N-3060 Svelvik, Norway.

  After this Unit has initialized 8087 exceptions will be OFF and the NAN
  and INF Variables set to NAN and INF respectively.  These Variables can be
  used in comparisons or to indicate uninitialized Variables.  The Variables
  are of Type extended but are compatible With singles and doubles too.  You
  cannot assign the value in INF or NAN to a Real because the Real cannot
  represent these values (if you do you will get error 105).
  -----------------------------------------------------------------

}


Interface

Procedure Exceptions8087(On : Boolean);
Function  Error8087 : Word; {Assumes $G+, 287 or better  }

Function isdoublenan(r : double) : Boolean;
Function issinglenan(r : single) : Boolean;

{These two Functions are used instead of direct comparisons With NANs as
all numbers are = to NAN; very strange}

Const
  nanpattern : Array [0..9] of Byte =
    ($FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF);
  { This is the bit pattern of an extended 'not a number'.  The +
    Variable NAN is overlaid on this as we cannot create a NAN in a +
    normal Constant declaration.}
Var
  nan : extended Absolute nanpattern;
  { not a number'; this is convenient For uninitialized numbers, +
    errors and so on, parsers can be designed to return this when +
    the input is not a number so that the error remains visible even +
    if the user or Program takes no corrective action}
  inf : extended;
  { The initialization of this routine deliberately executes a +
    divide by zero so as to create and infinity and stores it here +
    For general use.}

  singlenan : single;
  doublenan : double;

Implementation

Function isdoublenan(r : double) : Boolean;
Var
  l1 : Array [0..1] of LongInt Absolute singlenan;
  l2 : Array [0..1] of LongInt Absolute r;
begin
  isdoublenan := (l1[0] = l2[0]) and (l1[1] = l2[1]);
end;

Function issinglenan(r : single) : Boolean;
Var
  l1 : LongInt Absolute singlenan;
  l2 : LongInt Absolute r;
begin
  issinglenan := l1 = l2;
end;

Procedure Exceptions8087(On : Boolean); Assembler;
Var
  CtrlWord : Word;
Asm
  MOV   AL, On
  or    AL, AL
  JZ    @ExceptionsOff

  MOV   CtrlWord, 0372H    { Unmask IM, ZM, OM }
  JMP   #ExceptionsDone

 @ExceptionsOff:
  FSTCW CtrlWord           { Get current control Word }
  or    CtrlWord, 00FFh    { Mask all exceptions }

 @ExceptionsDone:
  FLDCW CtrlWord           { Change 8087 control Word }
end;


Function Error8087 : Word; Assembler;   {Assumes $G+, 287 or better  }
Asm
  FSTSW AX        { Get current status Word  }
  and   AX, 03Fh  { Just the exception indicators }
  FCLEX           { Clear exception indicators  }
end;

begin
  Exceptions8087(False);
  inf := 0; { Use a Variable not a Constant or the expression will be
              resolved at compile time and the compiler will complain }
  inf := 1 / inf;
  singlenan := nan;
  doublenan := nan;
end.

