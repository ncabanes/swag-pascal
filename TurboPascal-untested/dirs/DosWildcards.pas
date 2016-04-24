(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0055.PAS
  Description: DOS Wildcards
  Author: BERNHARD TSCHIRREN
  Date: 02-21-96  21:04
*)

{
JH>Is anybody familiar with a way to do Wildcards?
JH>I want to be able to select
JH>something ie: *.ZIP and it makes a que list from all of them?

If you ever need a procedure to check whether a file conforms to a wildcard
Ive got just the right procedure for you.

_______________0/__________________________________________
               0\                                           }

Function DirOnly(FileName:PathStr) : DirStr;
        Var
                Dir  : DirStr;
                Name : NameStr;
                Ext  : ExtStr;
        Begin
                FSplit(FileName,Dir,Name,Ext);
                DirOnly := Dir;
        End;

Function NameOnly(FileName:PathStr) : TStr12;
        Var
                Dir  : DirStr;
                Name : NameStr;
                Ext  : ExtStr;
        Begin
                FSplit(FileName,Dir,Name,Ext);
                NameOnly := Name+Ext;
        End;

Function BaseNameOnly(FileName:PathStr) : NameStr;
        Var
                Dir  : DirStr;
                Name : NameStr;
                Ext  : ExtStr;
        Begin
                FSplit(FileName,Dir,Name,Ext);
                BaseNameOnly := Name;
        End;

Function ExtOnly(FileName:PathStr) : ExtStr;
        Var
                Dir  : DirStr;
                Name : NameStr;
                Ext  : ExtStr;
        Begin
                FSplit(FileName, Dir, Name, Ext);
                If Pos('.',Ext) <> 0 Then Delete(Ext,1,1);
                ExtOnly := Ext;
        End;

Function SameName(N1,N2:NameStr) : Boolean;
        Var
                P1,P2 : Byte;
                Match : Boolean;
        Begin
                P1    := 1;
                P2    := 1;
                Match := True;

                If (Length(N1) = 0) And (Length(N2) = 0) Then
                        Match := True
                Else
                        If Length(N1) = 0 Then
                                If N2[1] = '*' Then
                                        Match := True
                                Else
                                        Match := False
                        Else
                                If Length(N2) = 0 Then
                                        If N1[1] = '*' Then
                                                Match := True
                                        Else
                                                Match := False;

                While (Match = True) And (P1 <= Length(N1)) And (P2 <= 
Length(N2)) Do
                        If (N1[P1] = '?') Or (N2[P2] = '?') Then
                                Begin
                                        Inc(P1);
                                        Inc(P2);
                                End
                        Else
                                If N1[P1] = '*' Then
                                        Begin
                                                Inc(P1);
                                                If P1 <= Length(N1) Then
                                                Begin
                                                While (P2 <= Length(N2)) And
                                                Not SameName(Copy(N1,P1,Length(N1)-P1+1),Copy(N2,P2,Length(N2)-P2+1)) Do
                                                Inc(P2);
                                                If P2 > Length(N2) Then Match := False
                                                Else

Begin

        P1 := Succ(Length(N1));

        P2 := Succ(Length(N2));

End;
                   End
                     Else
                     P2 := Succ(Length(N2));
                     End
                      Else
                      If N2[P2] = '*' Then
                              Begin
                                      Inc(P2);
                                      If P2 <= Length(N2) Then
                                              Begin

While (P1 <= Length(N1)) And

           Not SameName(Copy(N1,P1,Length(N1)-P1+1),Copy(N2,P2,Length(N2)-P2+1)) Do

        Inc(P1);
        If P1 > Length(N1) Then

        Match := False

Else

        Begin

                P1 := Succ(Length(N1));

                P2 := Succ(Length(N2));

        End;
                          End
                          Else
                          P1 := Succ(Length(N1));
                    End
            Else
            If UpCase(N1[P1]) = UpCase(N2[P2]) Then
                            Begin
                                    Inc(P1);
                                    Inc(P2);
                            End
                    Else
                            Match := False;

                If P1 > Length(N1) Then
                        Begin
                                While (P2 <= Length(N2)) And (N2[P2] = '*') 
Do
                                        Inc(P2);
                                If P2 <= Length(N2) Then
                                        Match := FALSE;
                        End;

                If P2 > Length(N2) Then
                        Begin
                                While (P1 <= Length(N1)) And (N1[P1] = '*')
Do
                                        Inc(P1);
                                If P1 <= Length(N1) Then
                                        Match := False;
                        End;

                SameName := Match;
        End;

Function SameFile(File1,File2:PathStr) : Boolean;
        Var
                Dir1,Dir2 : DirStr;
        Begin
                File1 := FExpand(File1);
                File2 := FExpand(File2);
                Dir1  := DirOnly(File1);
                Dir2  := DirOnly(File2);

                SameFile :=  SameName(BaseNameOnly(File1),BaseNameOnly(File2)) And
                SameName(ExtOnly(File1),ExtOnly(File2)) And
                                        (Dir1 = Dir2);
        End;

_______________0/__________________________________________
               0\ 

Sorry about the bad formatting but I use LONG lines with tabs for all my 
indents with my tab size set to 4. This procedure handles all cases of 
wildcards including some that dos doeen't:

    SameFile('*.PAS','HELLO.PAS) = TRUE
    SameFile('*.P?L','HELLO.PAL) = TRUE    
    SameFile('TE*.PAS','TOTO.PAS') = False
    SameFile('*PA.EXE','SUPA.EXE') = True (Not handled by dos!)
    SameFile('ST?P.*','STOP.COM') = True


