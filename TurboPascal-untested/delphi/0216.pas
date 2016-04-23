{
> I have been meaning to find out how one could get the lowest and highest
> index values of a multidimensional array.
>
> I mean, say you have an array like this
>
>         MyArray : Arra[1..25, 5..9, 3..7] Of Something;
>
> Now, If I had to deal with it in a different unit, how would I find out how
> big each dimension is?

Contrary to popular opinion, Basri, it's easy enough to determine the
low and high indexes of a Pascal array: You use the Low and High
functions! Here's a wee console app to show how it works.

program Project1;

uses
  SysUtils;

{$APPTYPE CONSOLE}

var
  MyArray: array[1..25, 5..9, 3..7] of Integer;
  I1L, I1H, I2L, I2H, I3L, I3H: Integer;
begin
  I1L := low(MyArray);
  I1H := high(MyArray);
  I2L := low(MyArray[I1L]);
  I2H := high(MyArray[I1L]);
  I3L := low(MyArray[I1L][I2L]);
  I3H := high(MyArray[I1L][I2L]);
  Writeln(Format('[%d..%d, %d..%d, %d..%d]',
    [I1L, I1H, I2L, I2H, I3L, I3H]));
  Readln;
end.
