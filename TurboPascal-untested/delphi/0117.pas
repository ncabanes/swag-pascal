
{
Dynamic Arrays

Is it possible to create a dynamically-sized array in Delphi?

Yes.  First, you need to create an array type using the largest
size you might possibly need.  When creating a type, no memory
is actually allocated.  If you created a variable of that type,
then the compiler will attempt to allocate the necessary memory
for you.  Instead, create a variable which is a pointer to that
type.  This causes the compiler to only allocate the four bytes
needed for the pointer.

Before you can use the array, you need to allocate memory for
it.  By using AllocMem, you will be able to control exactly how
many bytes are allocated.  To determine the number of bytes
you'll need to allocate, simply multiply the array size you
want by the size of the individual array element.  Keep in mind
that the largest block that can be allocated at one time in a
16-bit environment is 64KB.  The largest block that can be
allocated at one time in a 32-bit environment is 4GB.  To
determine the maximum number of elements you can have in your
particular array (in a 16-bit environment), divide 65,520 by
the size of the individual element.
Example:  65520 div SizeOf(LongInt)

Example of declaring an array type and pointer:
}
type
  ElementType = LongInt;

const
  MaxArraySize = (65520 div SizeOf(ElementType));
    (* under a 16-bit environment *)

type
  MyArrayType = array[1..MaxArraySize] of ElementType;
var
  P: ^MyArrayType;

const
  ArraySizeIWant: Integer = 1500;

Then when you wish to allocate memory for the array, you could
use the following procedure:

procedure AllocateArray;
begin
  if ArraySizeIWant <= MaxArraySize then
    P := AllocMem(ArraySizeIWant * SizeOf(LongInt));
end;

Remember to make sure that the value of ArraySizeIWant is less
than or equal to MaxArraySize.

Here is a procedure that will loop through the array and set a
value for each member:

procedure AssignValues;
var
  I: Integer;
begin
  for I := 1 to ArraySizeIWant do
    P^[I] := I;
end;

Keep in mind that you must do your own range checking.  If you
have allocated an array with five members and you try to assign
a value to the sixth member of the array, you will not receive
an error message.  However, you will get memory corruption.

Remember that you must always free up any memory that you
allocate.  Here is an example of how to dispose of this array:

procedure DeallocateArray;
begin
  P := AllocMem(ArraySizeIWant * SizeOf(LongInt));
end;

Below is an example of a dynamic array:

}

unit Unit1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls;

type
  ElementType = Integer;

const
  MaxArraySize = (65520 div SizeOf(ElementType));
    { in a 16-bit environment }

type
  { Create the array type.  Make sure that you set the range to
    be the largest number you would possibly need. }
  TDynamicArray = array[1..MaxArraySize] of ElementType;
  TForm1 = class(TForm)
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  { Create a variable of type pointer to your array type. }
  P: ^TDynamicArray;

const
  { This is a typed constant.  They are actually static
    variables hat are initialized at runtime to the value taken
    from the source code.  This means that you can use a typed
    constant just like you would use any other variable.  Plus
    you get the added bonus of being able to automatically
    initialize it's value. }
  DynamicArraySizeNeeded: Integer = 10;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  { Allocate memory for your array.  Be very careful that you
    allocate the amount that you need.  If you try to write
    beyond the amount that you've allocated, the compiler will
    let you do it.  You'll just get data corruption. }
  DynamicArraySizeNeeded := 500;
  P := AllocMem(DynamicArraySizeNeeded * SizeOf(Integer));
  { How to assign a value to the fifth member of the array. }
  P^[5] := 68;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  { Displaying the data. }
  Button1.Caption := IntToStr(P^[5]);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  { Free the memory you allocated for the array. }
  FreeMem(P, DynamicArraySizeNeeded * SizeOf(Integer));
end;

end.
