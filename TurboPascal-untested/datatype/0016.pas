(*
> is there any way to write an inverse Ord function for any type?

> Type Color = (RED, BLUE, GREEN, VIOLET, PURPLE);
> Var Whatever : Color;

> Begin
>   Writeln ('Red: ',Ord(Red); { Will print Red: 0 }
>   Writeln ('Inverse of Ord of Red:,InvOrd(0,Color); { Should spit out RED }
> End.

> For the function I had this in mind:

> Function InvOrd(TypeOrd : Integer; SpecifyType : SomeType) : SomeType;
> Begin
>   { What goes here? }
> End.

In a running program, variables are not really accessed by name, but by
address,  and their names don't show up in the final EXE.  The only way
I know to do such a thing is to add:
*)

Const
  Red    = 1;
  Purple = 5;
  InvOrd : Array [Red..Purple] of String[6] =
      ('Red', 'Blue', 'Green', 'Violet', 'Purple');

{ And then access this array like: }
begin
  WriteLn('Inverse of Ord of Red:', InvOrd[Red]);
end.
