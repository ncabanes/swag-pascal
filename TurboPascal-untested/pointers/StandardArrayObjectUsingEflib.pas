(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0042.PAS
  Description: Standard Array Object using EFLIB
  Author: JOHAN LARSSON
  Date: 11-29-96  08:17
*)


{ Borland Pascal Extended Function Library - EFLIB (C) Johan Larsson, 1996
  Demonstration; sample unit with ADT implementation of the standard array

  This is an abstract data type engine for the Borland Pascal array list.
  The program requires EFLIB to compile. EFLIB is a FREE and POWERFUL
  object-oriented toolkit for Borland Pascal, to compile. It's available
  via Internet at http://www.ts.umu.se/~jola/EFLIB/. EFLIB features not
  only data structures, but also streams, user interface, and much more.

  If you have any question, write an e-mail to Johan Larsson at
  jola@ts.umu.se.

  THIS SOURCE CODE IS DONATED TO PUBLIC DOMAIN FOR DISTRIBUTION WITH THE
  SWAG PACKAGE. FEEL FREE TOO USE THE SOURCE CODE TO MAKE YOUR OWN,
  ADVANCED EFLIB COMPATIBLE DATA STRUCTURE. }


unit STDARRAY;


INTERFACE

uses EFLIBDEF, EFLIBDAT;

const NumberOfElements = 1000;

type { Type of elements inside standard array object }
     ElementType                       = real;

     { Implementation of a standard Pascal array with a compile-time fixed
       size. Because this object is inherited from EFLIBs parent object for
       data types, it has features such as sorting, searching and stream
       storage (inherited methods). }
     StandardArrayObjectPointerTyp     = ^StandardArrayObjectType;
     StandardArrayObjectType           = object (DataObjectType)
                                             public
                                               { Fields }
                                               BaseArray        : array [1 .. NumberOfElements] of ElementType;
                                               LastUsed         : word;
                                               { Miscellaneous methods }
                                               procedure Clear; virtual;                           { Clears all elements }
                                               { Methods for handling of elements }
                                               procedure Add (var Data); virtual;                  { Adds an element }
                                               procedure Insert (var Data; Index : word); virtual; { Inserts an element }
                                               procedure Update (Index : word; var Data); virtual; { Updates an element }
                                               procedure Element (Index : word; var Data);
                                                         virtual;                                  { Retrieves an element }
                                               procedure Erase (Index : word); virtual;            { Erases an element }
                                               function Compare (Index1, Index2 : word) :
                                                        shortint; virtual;                         { Compares two elements }
                                               function CompareContent (Index : word; var Data) :
                                                        shortint; virtual;                         { Compares element content }
                                               { Methods for stream storage }
                                               constructor StreamLoad (Stream : pointer);          { Loads from a stream }
                                               { Methods for direct element access }
                                               function ElementSize (Index : word) :
                                                        word; virtual;                             { Size of element data }
                                               function ElementPointer (Index : word) :
                                                        pointer; virtual;                          { Returns element pointer }
                                               { Status methods }
                                               function Elements : word; virtual;                  { Number of elements }
                                               function Capacity : word; virtual;                  { Capacity of elements }
                                               function NameOfType : string; virtual;              { Name of object type }
                                         end;


IMPLEMENTATION

{$B-} {$IFNDEF DEBUG} {$I-} {$S-} {$R-} {$Q-} {$ENDIF}


uses EFLIBIO;

{ *** StandardArrayObjectType *** }

{ Clears data type (ie. erases all elements). }
procedure StandardArrayObjectType.Clear;
begin
     FillChar (BaseArray, SizeOf(BaseArray), 0);
     LastUsed := 0;
end;

{ Adds data into data type in a new element. }
procedure StandardArrayObjectType.Add (var Data);
begin
     if LastUsed < Capacity then begin
        Inc (LastUsed); BaseArray[LastUsed] := ElementType(Data);
     end else { Error; array is full } ;
end;

{ Inserts data to data type in a new element that follows specified indexed
  element in order. If index is zero, element is inserted first in the
  data type. }
procedure StandardArrayObjectType.Insert (var Data; Index : word);
var Count : word;
begin
     if Capacity > Elements then begin
        { Pull elements inside array to make space for a new element }
        for Count := Elements downto Succ(Index) do
            BaseArray[Succ(Count)] := BaseArray[Count];
        Inc (LastUsed); BaseArray[Index] := ElementType (Data);
     end else { Error; array is full } ;
end;

{ Updates an element in the data type. }
procedure StandardArrayObjectType.Update (Index : word; var Data);
begin
     if (Index >= 1) and (Index <= Elements) then
        BaseArray[Index] := ElementType(Data)
     else { Error; range check error; not a valid element index } ;
end;

{ Returns the data in an indexed element in the data type. }
procedure StandardArrayObjectType.Element (Index : word; var Data);
begin
     if IsValid (Index) then
        Move (BaseArray[Index], Data, ElementSize(Index))
     else { Error; range check error; not a valid element index } ;
end;

{ Erases an element from the data type. This is a method that must be
  overridden by all descendants. }
procedure StandardArrayObjectType.Erase (Index : word);
var Count : word;
begin
     if IsValid(Index) then begin
        { Pull elements inside array to make space for a new element }
        for Count := Index to Pred(Elements) do
            BaseArray[Count] := BaseArray[Succ(Count)];
        Dec (LastUsed);
     end else { Error; range check error; not a valid element index } ;
end;

{ Compares two indexed elements inside the data type and returns
  1, 0 or -1, depending on if the first element is bigger, equal
  or smaller than the second element. }
function StandardArrayObjectType.Compare (Index1, Index2 : word) : shortint;
begin
     if BaseArray[Index1] > BaseArray[Index2] then Compare := 1
        else if BaseArray[Index1] < BaseArray[Index2] then Compare := -1
             else Compare := 0;
end;

{ Compares the content of an elements with some data and returns
  1, 0 or -1, depending on if the element is bigger, equal or smaller
  than the data. }
function StandardArrayObjectType.CompareContent (Index : word; var Data) : shortint;
begin
     if BaseArray[Index] > ElementType(Data) then CompareContent := 1
        else if BaseArray[Index] < ElementType(Data) then CompareContent := -1
             else CompareContent := 0;
end;


{ Constructs and loads the object from a stream. This is an abstract
  constructor that must be overridden by all descendants that support
  stream storage. }
constructor StandardArrayObjectType.StreamLoad (Stream : pointer);
var Storage : StreamObjectPointerType absolute Stream;
begin
     if Storage^.IsInitialized and Storage^.IsAllocated and
        not Storage^.IsWriteOnly then with Storage^ do begin

        { Load object data }
        if Initialize then Inherited StreamLoad (Storage);

     end else { Error; failed to load object } ;
end;


{ Returns the size of elements inside the data type. }
function StandardArrayObjectType.ElementSize (Index : word) : word;
begin ElementSize := SizeOf(ElementType); end;

{ Returns a pointer to a specified elements data region. }
function StandardArrayObjectType.ElementPointer (Index : word) : pointer;
begin ElementPointer := @BaseArray[Index]; end;


{ Returns the number of elements inside the data type. }
function StandardArrayObjectType.Elements : word;
begin Elements := LastUsed; end;

{ Returns the number of elements that can be stored inside the data
  type. }
function StandardArrayObjectType.Capacity : word;
begin Capacity := SizeOf(BaseArray) div ElementSize (0); end;


{ Returns the full Borland Pascal name of the object type }
function StandardArrayObjectType.NameOfType : string;
begin NameOfType := 'StandardArrayObjectType'; end;


end. { unit }



{ - - - - - - - - - - - Cut here - - - - - - - - - }


{ Borland Pascal Extended Function Library - EFLIB (C) Johan Larsson, 1996
  Demonstration; example on ARRAYLST.PAS implementation

  EFLIB IS PROTECTED BY THE COPYRIGHT LAW AND MAY NOT BE COPIED, SOLD OR
  MANIPULATED. FOR MORE INFORMATION, SEE PROGRAM MANUAL! THIS DEMONSTRAT-
  ION PROGRAM MAY FREELY BE USED AND DISTRIBUTED.                          }


uses EFLIBDEF, STDARRAY;

var MyArray : StandardArrayObjectType; Number : real;

begin
     WriteLn ('* Standard Pascal array implemented as a polymorphic EFLIB data type *');

     with MyArray do begin
          Initialize;

          { Add some elements }
          Number := 1.1; Add (Number);
          Number := 2.2; Add (Number);
          Number := 4.4; Add (Number);

          with CreateIterator^ do begin
               repeat
                     WriteLn (Real(Content^):0:2);
                     WalkForward;
               until IsEnd;
               Free;
          end;

          Intercept;
     end;
end.



