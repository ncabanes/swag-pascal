{
Here's a solution in Borland Pascal 7.0 to your sorting problem. However, it
does one things slightly different from what you might expect: It uses
ASCIIbetical order, ie. spaces come before letters.

I hope you can adapt the program to your needs (your specific compiler etc).
The program uses Strings, but you can substitute them with Array [1..255] of
Char (of course, the displaying part should be changed). If you need the new
indices, try moving the P array out of the DoSort procedure.

Hope this helps.
Andy Kurnia

-----Sample output for input: THIS IS AN EXAMPLE ARRAY OF BYTES-----

-----SORTING.PAS, 1,742 bytes, Borland Pascal 7.0-----
{$A+,B-,D-,E-,F-,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V+,X+,Y-}
{$M 4096,0,0}

Program Sorting;

Var
    S : String;

Function GetRow(X : Byte) : String;
Var
    T : String;
Begin
    If S[0] = ^@ Then Begin             { Zero-length string check }
        GetRow := '';
        Exit
    End
    Else If X = 0 Then                  { Row 0 check }
        X := Length(S);
    T := S;
    Delete(T, 1, (X - 1) Mod Length(S));
    T := T + S;
    T[0] := S[0];                       { Cut unnecessary extra characters }
    GetRow := T
End;

Var
    A1, A2, A3, A4 : String;            { Strings are Array Of Char }

Procedure DoSort;
Var
    I, J : Byte;
    P : Array[1..255] Of Byte;          { Pointers to sorted position }
Begin
    A1 := S;
    A2 := S[Length(S)] + Copy(S, 1, Length(S) - 1);
    For I := 1 To 255 Do
        P[I] := I;
    For I := 1 To Length(S) - 1 Do      { The good old bubble sort }
        For J := I + 1 To Length(S) Do
            If GetRow(P[I]) > GetRow(P[J]) Then Begin
                P[I] := P[I] Xor P[J];  { Exchange P[I] with P[J] }
                P[J] := P[I] Xor P[J];
                P[I] := P[I] Xor P[J]
            End;
    A3[0] := S[0];                      { Copy just the length bytes }
    A4[0] := S[0];
    For I := 1 To Length(S) Do Begin    { Lay the results out }
        A3[I] := A1[P[I]];
        A4[I] := A2[P[I]]
    End
End;

Var
    I : Byte;
Begin
    Write('Enter test string: ');
    ReadLn(S);
    WriteLn('The matrix of strings:');
    For I := 1 To Length(S) Do
        WriteLn(GetRow(I));
    DoSort;
    WriteLn('[A1] = ', A1);
    WriteLn('[A2] = ', A2);
    WriteLn('[A3] = ', A3);
    WriteLn('[A4] = ', A4)
End.
