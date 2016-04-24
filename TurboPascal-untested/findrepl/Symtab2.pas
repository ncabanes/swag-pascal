(*
  Category: SWAG Title: SEARCH/FIND/REPLACE ROUTINES
  Original name: 0015.PAS
  Description: SYMTAB2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:46
*)

LARRY HADLEY

   Errata: include an "info" Pointer field in the SYMTAB_NODE
   structure in the previous post.

   USING THE SYMBOL TABLE - A CROSS REFERENCER

   A cross-reference is a listing of a Programs identifiers in
   alphabetical order:

Page 1   hello.pas  April 08 1993  19:03
   1 0: Program hello (output);
   2 0: Var i:Integer;
   3 0: begin
   4 0:    For i := 1 to 10 do
   5 0:    begin
   6 0:       WriteLn('Hello world.');
   7 0:    end;
   8 0: end.

Cross Reference
---------------

hello               1

i                   2    4

Integer             2

ouput               1

Writeln             6

  As shown above, alongside each identifier's name are the source
  line numbers that contain the identifier. (This is useful for
  tracking where they're used)

  A cross-referencer reads the source File and looks for
  identifiers, using the scanner you've built previously. The first
  time a particular identifier is found, it is inserted in the
  symbol tree along With it's line number. Subsequent appearances of
  the same identifier update the symbol tree With an additional line
  number appended to the list of line numbers.

  As soon as the Program is completely scanned, all the identifier
  names and their line numbers are printed.

  Use the INFO field of SYMTAB_NODE to point to a LINKED LIST of
  line numbers.

  The main loop should scan For tokens Until it finds a period, or
  Exits With an "Unexpected end of File" error. For each identifier,
  search the symbol table to see if their were any previous
  instances of the identifier. If it is not found, then this must be
  the first time it is used so we can call the "enter" Function to
  create a new node.

  Then, whether a new node was actually created or not, we call a
  Function to add the line number to the queue of line numbers
  attached to the node's "info" field. Finally, when the scanner
  loop terminates, we call a printing Function which traverses the
  tree from left to right to print the sorted tree - and all the
  line numbers in the linked list attached to each node.

  Note that a recursive call to itself is probably the easiest way
  to do this, since _all_ the nodes of the tree are being accessed,
  not just one.

  Types you will need:

Type
  pLINENUMS = ^LINENUM_NODE;
  LINENUM_NODE = Record
     next     :pLINENUMS;
     line     :Integer;
  end;

  pLINE_HEADER = ^LINENUM_HDR;
  LINENUM_HDR = Record
     first, last :pLINENUMS;
  end;

  EXCERCISE #1

  Write a cross referencer, as above. Text it With an assortment of
  pascal sourceFiles.

  ADVANCED EXCERCISE

  Note that the symbol table above converts all identifier names to
  lower case. What would be needed to reWrite the scanner/xref
  Program to preserve case? ReWrite the xref Program to do so. (note
  that Pascal compilers are Case insensitive, so the symbol table -

  For compatibility - must compare lower case)

  "BRAIN TEASERS"

  1. What would be necessary to reWrite the symbol table as a hash
     table?

  2. If an identifier appears more than once in a line, line
     numbers will appear more than once in the listing. Fix xref to
     recognize duplicate occurences of line numbers in node-lists.

  -----------------------------------------------------------------

  Next: Pascal source cruncher.

