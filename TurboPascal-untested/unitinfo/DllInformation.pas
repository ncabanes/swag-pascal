(*
  Category: SWAG Title: UNIT INFORMATION ROUTINES
  Original name: 0004.PAS
  Description: DLL Information
  Author: ANDREW EIGUS
  Date: 11-26-94  05:05
*)

{
> I'm having some problems with putting DLL'd routines into my program.
}

{---HELLO.PAS---}  { a sample DLL }

Library Hello;

Function HelloWorld : PChar; export;
Begin
  HelloWorld := 'Hello, world! Greetings from HELLO.DLL!'
End; { HelloWorld }

exports
  HelloWorld index 1;

Begin
End.

{---END---}

{---DLLDEMO.PAS---} { a sample program that uses routine from HELLO.DLL }

Program DLLDemo;

uses WinCrt;

const
  DLLName = 'HELLO';

Function HelloWorld : PChar; far; external DLLName;

Begin
  WriteLn(HelloWorld)
End.

{---END---}
(*
And RTM:

In the Windows and protected mode environments, dynamic-link libraries
(DLLs) permit several applications to share code and resources.

A DLL is an executable module (extension .DLL) that contains code or
resources that are used by other DLLs or applications.

DLLs provide the ability for multiple programs ("clients") to share a single
copy of a routine they have in common. The .DLL file must be present when
the client program runs.

The Borland Pascal concept most comparable to a DLL is a unit. However,
routines in units are linked into your executable at link time ("statically
linked"), whereas DLL routines reside in a seperate file and are made
available at run time ("dynamically linked").

When the program is loaded into memory, the Windows or DOS protected mode
program loader dynamically links the procedure and function calls in the
program to their entry points in the DLLs used by the program.

A Borland Pascal application can use DLLs that were not written in Borland
Pascal. Also, programs written in other languages can use DLLs written in
Borland Pascal.

DLLs that are compiled for Windows can also be used in DOS protected mode if
the DLLs use only the Windows functions defined in WinAPI.unit. This subset
of the Windows API is emulated by the DOS protected mode Run-Time Manager,
allowing one DLL file to run in Windows or in DOS without recompiling.

 Using DLLs
 ▀▀▀▀▀▀▀▀▀▀▀▀
There are two ways to access and call a DLL function:

  1. Using an external declaration in your program.
  2. Using GetProcAddress to initialize procedure pointers in your program.

In order for a module to use a procedure or function that is in a DLL, it
imports the procedure or function using an external declaration.

In imported procedures and functions, the external directive takes the place
of the declaration and statement parts that would otherwise be present.

Imported procedures and functions behave just like normal ones, except they
must use the far call model (use a far procedure directive or a
{$F+} compiler directive.)

Borland Pascal provides three ways to import procedures and functions:

  - by name
  - by new name
  - by ordinal

Although a DLL can have variables, it is not possible to import them in to
other modules. Any access to a DLL's variables must take place through a
procedural interface.

 Example:
This external declaration imports the function GlobalAlloc from the DLL
called KERNEL (the Windows kernel):

   function GlobalAlloc(Flags: Word; Bytes: Longint): THandle; far; external
    'KERNEL' index 15;

Note: The DLL name specified after the external keyword and the new name
specified in a name clause do not have to be string literals. Any constant
string expression is allowed.

Likewise, the ordinal number specified in an index clause can be any
constant-integer expression. For example:

   const
     TestLib = 'TESTLIB';
     Ordinal = 5;

   procedure ImportByName;    external TestLib;
   procedure ImportByNewName; external TestLib name 'REALNAME';
   procedure ImportByOrdinal; external TestLib index Ordinal;

 Writing DLLs
 ▀▀▀▀▀▀▀▀▀▀▀▀▀▀
The structure of a Borland Pascal DLL is identical to that of a program,
except that a DLL starts with a library header instead of a program header.

The library header tells Borland Pascal to produce an executable file with
the extension .DLL instead of .EXE. It also ensures that the executable file
is marked as being a DLL.

If procedures and functions are to be exported by a DLL, they must be
compiled with the export procedure directive.

 Example:
This implements a very simple DLL with two exported functions:
*)
   library MinMax;

   {The export procedure directive prepares Min and Max for exporting}

   function Min(X, Y: Integer): Integer; export;
   begin
     if X < Y then Min := X else Min := Y;
   end;

   function Max(X, Y: Integer): Integer; export;
   begin
     if X > Y then Max := X else Max := Y;
   end;

   {The exports clause actually exports the two routines, supplying an
    optional ordinal number for each of them}

   exports
     Min index 1,
     Max index 2;

   begin
   end.
(*
Libraries often consist of several units. In such cases, the library source
file itself is frequently reduced to a uses clause, an exports clause, and
the library's initialization code.

For example:
*)
   library Editors;

   uses EdInit, EdInOut, EdFormat, EdPrint;

   exports
     InitEditors index 1,
     DoneEditors index 2,
     InsertText index 3,
     DeleteSelection index 4,
     FormatSelection index 5,
     PrintSelection index 6,
      .
      .
     SetErrorHandler index 53;

   begin
     InitLibrary;
   end.


(*
Sooo, i hope that i helped u a little byte. BTW, the information above was
taken from Borland Pascal help file.
*)

