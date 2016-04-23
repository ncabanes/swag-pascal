{    Hey David, try this one out. It Uses a little known fact that TP
will parse the command line each time you call Paramstr(). So by
stuffing a String into the command-line buffer, we can have TP parse it
For us.
}
Program Parse;
Type
    String127 = String[127];
    Cmd = ^String127;

Var
    My_String : Cmd;
    Index : Integer;

begin
    My_String := Ptr(PrefixSeg, $80); {Point it to command line buffer}
    Write('Enter a line of Text (127 caracters Max) ');
    Readln(My_String^);
    For Index := 1 to Paramcount do
        Writeln(Paramstr(Index));
end.

{    You can solve the problem of the 127 caracter limit by reading into
a standard String and splitting it into <127 caracter substrings.
}