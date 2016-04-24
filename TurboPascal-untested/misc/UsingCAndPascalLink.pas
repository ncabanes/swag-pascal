(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0109.PAS
  Description: Using C And Pascal - Link
  Author: DAVE BELL
  Date: 08-25-94  09:05
*)

(*
YK>1) I'm going to write a program in pascal that calls a function.
YK>2) That function is going to be written in C.
YK>3) Link them together to make one EXE file.

YK>Is there anyway to do this or am I just dreaming? <g>  Thanks for
YK>any insight in this.

Yes, it is possible.  You will need to compile object code modules with
your Pascal and C compilers, and then link them with a linker program.
Unusually, for a programming tool, the program you use for linking usually
has the obvious name of LINK.EXE (as compared to such things as "grep",
"awk", "yacc" or "bison").

The second edition of Turbo C++ includes a set of example files for just
this situation.

First, a fragment of the C code called by the Pascal program.


typedef unsigned int word;
typedef unsigned char byte;
typedef unsigned long longword;

extern void setcolor(byte newcolor);  /* procedure defined in
                                         Turbo Pascal program */
extern word factor;    /* variable declared in Turbo Pascal program */

word sqr(int i)
{
  setcolor(1);
  return(i * i);
} /* sqr */

word multbyfactor(word w)
{
  setcolor(9);        /* note that this function accesses the Turbo Pascal */
  return(w * factor); /* declared variable factor */
} /* multbyfactor */

----8<---------

The command line compiler uses the following .CFG file

---8<---------

-wrvl
-p
-k-
-r-
-u-
-zCCODE
-zP
-zA
-zRCONST
-zS
-zT
-zDDATA
-zG
-zB

---8<------------

Finally, the Pascal code

*)
program CPASDEMO;
(*
  This program demonstrates how to interface Turbo Pascal and Turbo C++.
  Turbo C++ is used to generate an .OBJ file (CPASDEMO.OBJ). Then
  this .OBJ is linked into this Turbo Pascal program using the {$L}
  compiler directive.

  NOTES:
    1. Data declared in the Turbo C++ module cannot be accessed from
       the Turbo Pascal program. Shared data must be declared in
       Pascal.

    2. If the C functions are only used in the implementation section
       of a unit, declare them NEAR.  If they are declared in the
       interface section of a unit, declare them FAR.  Always compile
       the Turbo C++ modules using the small memory model.

    3. Turbo C++ runtime library routines cannot be used because their
       modules do not have the correct segment names.  However, if you
       have the Turbo C++ runtime library source (available from
       Borland), you can use individual library modules by recompiling
       them using Pascal conventions.  If you do recompile them, make
       sure that you include prototypes in your C module for all C
       library functions that you use.

    4. Some of the code that Turbo C++ generates are calls to internal
       routines. These cannot be used without recompiling the relevant
       parts of the Turbo C++ runtime library source code.

  In order to run this demonstration program you will need the following
  files:

    TCC.EXE and CTOPAS.CFG or
    TC.EXE and CTOPAS.TC

  To run the demonstration program CPASDEMO.EXE do the following:

  1. First create a CPASDEMO.OBJ file compatible with Turbo Pascal 4.0
     or later using Turbo C++.

    a) If you are using the Turbo C++ integrated environment (TC.EXE)
       then at the DOS prompt execute:

       TC CTOPAS.PRJ

       then create the .OBJ file by pressing ALT-F9.

    b) If you are using the Turbo C++ command line version (TCC.EXE)
       then at the DOS prompt execute:

       TCC +CTOPAS.CFG CPASDEMO.C

       Note: Use the same configuration file (CTOPAS.CFG or CTOPAS.PRJ)
             when you create your own Turbo C++ modules for use with
             Turbo Pascal

  2. Compile and execute the Turbo Pascal program CPASDEMO.PAS

  This simple program calls each of the functions defined in the Turbo C++
  module. Each of the Turbo C++ functions changes the current display color
  by calling the Turbo Pascal procedure SetColor. }
*)

uses Crt;

var
  Factor : Word;

{$F+}  { Force Far Calls for calling to and from Turbo C }

{$L CPASDEMO.OBJ}  { link in the Turbo C++-generated .OBJ module }

function Sqr(I : Integer) : Word; external;
{ Change the text color and return the square of I }

function MultByFactor(W : Word) : Word; external;
{ Change the text color and return W * Factor - note Turbo C++'s access of }
{ Turbo Pascal's global variable.                                        }

procedure SetColor(NewColor : Byte); { A procedure that changes the current }
begin                                { display color by changing the CRT    }
  TextAttr := NewColor;              { variable TextAttr                    }
end; { SetColor }

begin
  Writeln(Sqr(10));                  { Call each of the functions defined   }
                                     { passing it the appropriate info.}

  Factor :=100;
  Writeln(MultbyFactor(10));
  SetColor(LightGray);

end.
{
------8<----------

To save space, I've edited a lot of the functions out of both source
files.  I hope this works.  I don't have a DOS Pascal compiler :(
}

