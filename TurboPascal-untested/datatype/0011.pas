{
> It would be Really nifty if it were possible to have InVar be
> unTyped in the Function, so that the call would pass the Type,
> but I can't figure this one out.

Here is a small sample of code that demonstrates how to do what (I
think) you're wanting to do:
}

Type
  TypeID = (tByte, tInt, tLong, tReal, tStr);

Procedure MultiType(Var InVar; InType : TypeID);

Var
  b : Byte Absolute InVar;
  w : Integer Absolute InVar;
  i : LongInt Absolute InVar;
  r : Real Absolute InVar;
  s : String Absolute InVar;

begin
  Case InType of
    tByte : WriteLn('Byte = ',b);
    tInt  : WriteLn('Integer = ',w);
    tLong : WriteLn('LongInt = ',i);
    tReal : WriteLn('Real = ',r);
    tStr  : WriteLn('String = ',s);
    else    WriteLn('Unknown Type!');
  end;
end;

{
of course, the above is just an example and it doesn't actually
do anything useful, but you should be able to adapt it to suit
your purposes.
}

