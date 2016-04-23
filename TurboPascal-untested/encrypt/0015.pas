(*-----
        Program                : CODE/DECODE

        File                : Code.Pas

        Version                : 1.2

        Author(s)        : Mark Midgley

        Date
         (Started)        : April 11, 1990
        Date
         (Finished)        : , 1990

        Comment(s)        :

-----*)
Program Code_and_DeCode;


{$IFDEF DEBUG}
        {$D+}                (* Turn Debugging Info **ON** *)
        {$L+}                (* Turn Local Symbols  **ON** *)
        {$R+}                (* Turn Range Checking **ON** *)
        {$S+}                (* Turn Stack Checking **ON** *)
{$ELSE}
        {$D-}                (* Turn Debugging Info **OFF** *)
        {$L-}                (* Turn Local Symbols  **OFF** *)
        {$R-}                (* Turn Range Checking **OFF** *)
        {$S-}                (* Turn Stack Checking **OFF** *)
{$ENDIF}

Uses
        Crt,
        Dos;

Const
        BufSize                =        512;
        Version                =        '1.3';
        MaxError    =        7;

Type
        EDMode                        =        (EnCrypt,EnCryptPass,DeCrypt);
        String79                =        String[79];
        FilePaths                =        Array [1..2] Of String79;
        Errors                        =        1..(MaxError - 1);

Procedure WriteXY( X,Y : Byte; S : String79 );
Begin        (* WriteXY *)
        GotoXY(X,Y);
        Write(S);
End;        (* WriteXY *)

Function UpStr( S : String ) : String;
Var
        X        : Byte;

Begin        (* UpStr *)
        For X := 1 To Length(S) Do
                S[x] := (UpCase(S[x]) );
        UpStr := S;
End;        (* UpStr *)

Procedure Center( Y : Byte; S : String; OverWriteMode : Errors );
Var
        X : Byte;

Begin        (* Center *)
        GotoXY(1,Y);
        Case (OverWriteMode) of
                1        : For X := 2 To 78 Do WriteXY(X,WhereY,' ');
                2        : ClrEOL;
        End;        (* Case *)
        X := ((79 - Length(S)) Div 2);
        If (X <= 0) Then X := 1;
        WriteXY(X,Y,S);
End;        (* Center *)

Procedure OutError( S : String79; X,OWM : Errors );
Var
        T : String79;

Begin        (* OutError *)
        GotoXY(1, WhereY);
        Case ( X ) Of
                1        : T := ('Incorrect Number of parameters.');
                2        : T := ('Input file "'+ S +'" not found.');
                3        : T := ('Input and Output files conflict.');
                4        : T := ('User Aborted!');
                5        : T := ('Input file "'+ S +'" is corrupted!');
                6        : If (T = '') Then T := ('DOS Input/Output Failure.')
                                Else T := S;
        End;        (* Case *)
        TextColor(LightRed);
        Center(WhereY,T,OWM);
        TextColor(LightGray);
        If (OWM = 1) Then WriteLn;
        WriteLn;
        Halt(x);
End;        (* OutError *)

Procedure HelpScreen( FullScreen : Boolean );
Begin        (* HelpScreen *)
        TextColor(LightGray);
        GotoXY(1,WhereY);
        WriteLn('               USAGE: CODE [/D|/E|/P] INPUT_FILE OUTPUT_FILE');
        WriteLn('                  Options are: /D Decode File.');
        WriteLn('                               /E Encode File.');
        WriteLn('                               /P Encode with Password.');
        If (Not FullScreen) Then Halt(MaxError);
        WriteLn;
        WriteLn('Description:');
        WriteLn;
        WriteLn('  CODE  encrypts a  DOS  file  to  garbage using  a  randomly  generated  seed');
        WriteLn('  and then back again.  For  more protection, the password  option can be used.');
        WriteLn('  Note:  With no  option, CODE defaults to encode "/E";  Input and Output files');
        WriteLn('  must be different;  the "/P" option will  prompt  for the password  and  echo');
        WriteLn('  dots;  Code does not allow wildcards;  Pressing  ESCape during operation will');
        WriteLn('  abort.  The author  does  not  guarantee  the reliability of this program and');
        WriteLn('  is not responsible for  any data lost.  If you appreciate this program in any');
        WriteLn('  way or value its use then please send $5.00 - $20.00 to:');
        WriteLn;
        TextColor(White);
        WriteLn('                                        Mark "Zing" Midgley');
        WriteLn('                                        843 East 300 South');
        WriteLn('                                        Bountiful Ut, 84010');
        TextColor(LightGray);
        Halt(MaxError);
End;         (* HelpScreen *)

Function Shrink( P : PathStr ) : String79;
Var
        D        : DirStr;
        N        : NameStr;
        E        : ExtStr;

Begin        (* Shrink *)
        FSplit(P,D,N,E);
        Shrink := N + E;
End;        (* Shrink *)

Procedure GraphIt( Var F1, F2        : File;
                                   Var OldX                : Byte;
                                   Hour,
                                   Min,
                                   Sec,
                                   Sec100                : Word;
                                   BoxSetUp                : Boolean );
Var
        F1Size,
        F2Size        : LongInt;
        Percent,
        X,
        NewX        : Byte;
        H,
        M,
        S,
        S100        : Word;
        A,
        B,
        C,
        D,
        Temp        : String79;

Begin        (* GraphIt *)
        If (BoxSetUp) Then
        Begin
                Percent := 0;
                OldX := 3;
                GotoXY(1,WhereY);
                WriteLn('╔═════════════════════════════════════════════════════════════════════════════╗');
                WriteLn('║                                                                             ║');
                WriteLn('╚═════════════════════════════════════════════════════════════════════════════╝');
                GotoXY(3,WhereY - 2);
        End Else
        Begin
                GetTime(H,M,S,S100);
                If (Sec100 <= S100) Then Dec(S100,Sec100)
                        Else
                        Begin
                                S100 := (S100 + 100 - Sec100);
                                If (S > 0) Then Dec(S);
                        End;
                If (Sec <= S) Then Dec(S,Sec)
                        Else
                        Begin
                                S := (S + 60 - Sec);
                                If (M > 0) Then Dec(M);
                        End;
                If (Min <= M) Then Dec(M,Min)
                        Else
                        Begin
                                M := (M + 60 - Min);
                                If (H > 0) Then Dec(H);
                        End;
                If (Hour <= H) Then Dec(H,Hour)
                        Else H := (H + 12 - Hour);
                Str(H,A);
                Str(M,B);
                Str(S,C);
                Str(S100,D);
                Case (S100) of
                        0..9        : D := ('0' + D);
                End;        (* Case *)
                If (M > 0) Then
                Case (S) of
                        0..9        : C := ('0' + C);
                End;        (* Case *)
                If (H > 0) Then
                Case (M) of
                        0..9        : B := ('0' + B);
                End;        (* Case *)
                If (H = 0) Then
                Begin
                        If (M = 0) Then Temp := (Concat(C,'.',D,' sec') )
                        Else Temp := (Concat(B,' min ',C,'.',D,' sec') );
                End
                Else If (H = 1) Then Temp := (Concat(A,' hr ',B,' min ',C,'.',D,' sec') )
                                Else Temp := (Concat(A,' hrs ',B,' min ',C,'.',D,' sec') );
            F1Size := FileSize(F1);
                F2Size := FileSize(F2);
                If (F2Size <= F1Size) Then
                Percent := ((F2Size * 100) Div F1Size )
                        Else Percent := 100;
                NewX := (((Percent * 76) Div 100) + 2);
                If (NewX < 3) Then NewX := 3;
                For X := OldX To NewX Do WriteXY(X,WhereY,#176);
                OldX := NewX;
                Center(WhereY + 1,(#181 + ' ' + Temp + ' ' + #198),3);
                GotoXY(NewX,WhereY - 1);
        End;
End;        (* GraphIt *)

Procedure Rm( FileName : String79 );
Var
        F : File;

Begin        (* Rm *)
        If (FileName = '') Then Exit;
        Assign(F,FileName);
        Erase(F);
End;        (* Rm *)

Procedure GetStr( Var S : String79; Prompt,FName : String79; Show : Boolean );
Var
        Max,
        Min        : Byte;
        A        : Char;
        X        : Byte;

Begin        (* GetStr *)
        If (FName = '') Then
        Begin
                Max := 54;
                Min := 0
        End Else
        Begin
                Max := 25;
                Min := 3
        End;
        TextColor(LightGray);
        WriteXY(1,WhereY,Prompt);
        Repeat
                GotoXY(Length(Prompt) + 1,WhereY);
                ClrEOL;
                If (Show) Then WriteXY(Length(Prompt) + 1,WhereY,S)
                Else For X := 1 To Length(S) Do Write(#249);
                A := (ReadKey);
                Case ( A ) of
                        #32..#126 :
                                If (Length(S) < Max) Then S := S + A
                                Else
                                Begin
                                        Sound(100);
                                        Delay(12);
                                        NoSound;
                                End;
                        #8 :
                                If (Length(S) > 0) Then
                                        Delete(S,(Length(S) ), 1);
                        #0 :
                                A := ReadKey;
                        #27:
                                Begin
                                        Rm(FName);
                                        OutError('',4,2);
                                End;
                End;        (* Case *)
        Until (A = #13) And (Length(S) >= Min);
End;        (* GetStr *)

Function RealFile( St : String79; OWM : Errors ) : Boolean;
Var
        Error : Word;
        F          : File;

Begin        (* RealFile *)
        RealFile := False;
        Assign(F,St);
        {$I-}                 (* Turn Input/Output-Checking Switch Off *)
        Reset(F);        (* Open file. *)
        Error := IOResult;
        {$I+}            (* Turn Input/Output-Checking Switch On  *)
        If (Error = 0) Then (* File exists. *)
        Begin
                RealFile := True;
                Close(F);
        End Else
{*}                Case (Error) Of
                        152        : OutError('Drive Not Ready.',6,OWM);
                        3        : OutError('Invalid Drive specification.',6,OWM);
                        (* 5  : Directory *)
                End;        (* Case *)
End;        (* RealFile *)

Procedure CheckError( FileName, Msg : String79 );
Var
        Error : Word;

Begin        (* CheckError *)
        Error := IOResult;
        If (Error <> 0) Then
        Begin
                If (Error <> 152) And
                   (Error <> 3) Then Rm(FileName)
                        Else Msg := ('Drive Not Ready.');
                OutError(Msg,6,1);
        End;
End;        (* CheckError *)

Procedure CheckAbort( FileName : String79 );
Begin        (* CheckAbort *)
        If (KeyPressed) Then
        If (ReadKey = #27) Then
        Begin
                Rm(FileName);
                OutError('',4,1);
        End;
End;        (* CheckAbort *)

(*----
        Procedure Encode();

        Author(s)        :        Mark Midgley
                                        Louis Zirkel

        Comments        :        Cool Man...

----*)

Procedure EnCode( _File : FilePaths; Protect : Boolean );
Var
        Seed,
        PI,
        Y,
        OldX                : Byte;
        I,
        Increment        : Integer;
        Buf                        : Array [1..BufSize] of Char;
        Hour,
        Min,
        Sec,
        Sec100,
        Status                : Word;
        Temp,
        Pass                : String79;
        F1,
        F2                        : File;

Begin        (* EnCode *)
        Pass := '';
    {$I-}
        Assign(F1, _File[1]);        (* input file  *)
        Assign(F2, _File[2]);        (* output file *)
        Reset(F1,1);
        CheckError('','Couldn''t open input file.');
        ReWrite(F2,1);
        CheckError(_File[2],'Couldn''t create output file.');
        Randomize;
        If (Protect) Then
        Begin
                GetStr(Pass,'(3 Char min, 25 Char max) Enter Password: ',_File[2],False);
                Buf[1] := Chr(Random(127) );
                BlockWrite(F2,Buf[1],SizeOf(Buf[1]),Status);
                CheckError(_File[2],'Couldn''t write to output file.');
        End Else
        Begin
                Buf[1] := Chr(Random(127) + 127);
                BlockWrite(F2,Buf[1],SizeOf(Buf[1]),Status);
                CheckError(_File[2],'Couldn''t write to output file.');
        End;
        Seed := Ord(Buf[1]);
        Increment := 1;
        PI := 1;
        Y := 127;
    TextColor(LightGray);
        ClrEOL;
        GetTime(Hour,Min,Sec,Sec100);
        GraphIt(F1,F2,OldX,Hour,Min,Sec,Sec100,True);
        Repeat
                BlockRead(F1, Buf, BufSize, Status);
                CheckError(_File[2],'Couldn''t read input file.');
                CheckAbort(_File[2]);
                GraphIt(F1,F2,OldX,Hour,Min,Sec,Sec100,False);
                For I := 1 To BufSize Do
                        Begin
                                If (Protect) Then
                                        Begin
                                                Buf[I] := Char(Byte(Buf[I]) XOR Byte(Pass[PI]));
                                                If (PI = Length(Pass)) Then Increment := -1;
                                                If (PI = 1) Then Increment := 1;
                                                Inc(PI,Increment);
                                        End
                                Else
                                        Begin
                                                Buf[I] := Char(Byte(Buf[I]) XOR Y);
                                        End;
                        End;
                BlockWrite(F2, Buf, Status);
                CheckError(_File[2],'Couldn''t write to output file.');
        Until (Status < BufSize);
        Close(F1);
        CheckError(_File[2],'Couldn''t close input file.');
        Close(F2);
        CheckError(_File[2],'Couldn''t close output file.');
        {$I+}
(* Successful Encryption *)
        TextColor(LightGray);
        Temp := (Shrink(_File[1]) +' Encoded to '+ Shrink(_File[2]));
        If (Protect) Then Temp := (Temp + ' with Password.');
        Center(WhereY,Temp,1);
        GotoXY(1,WhereY + 1);
        WriteLn;
End;        (* EnCode *)

(*----
        Procedure DeCode();

        Author(s)        :        Mark Midgley
                                        Louis Zirkel

        Comments        :        Cool Man...

----*)

Procedure DeCode( _File : FilePaths );
Var
        Seed,
        PI,
        Y,
        OldX                : Byte;
        I,
        Increment        : Integer;
        Buf                        : Array [1..BufSize] of Char;
        Hour,
        Min,
        Sec,
        Sec100,
        Status                : Word;
        Temp,
        Pass                : String79;
        F1,
        F2                        : File;

Begin        (* DeCode *)
        Pass := '';
        {$I-}
        Assign(F1, _File[1]);
        Assign(F2, _File[2]);
        Reset(F1,1);
        CheckError('','Couldn''t open input file.');
        ReWrite(F2,1);
        CheckError(_File[2],'Couldn''t create output file.');
        BlockRead(F1,Buf[1],SizeOf(Buf[1]),Status);
        CheckError(_File[2],'Couldn''t read input file.');
        Seed := Ord(Buf[1]);
        If (Buf[1] < #127) Then (* There's a Password *)
                GetStr(Pass,'Enter Password: ',_File[2],False);
        Increment := 1;
        PI := 1;
        Y := 127;
        TextColor(LightGray);
        ClrEOL;
        GetTime(Hour,Min,Sec,Sec100);
        GraphIt(F1,F2,OldX,Hour,Min,Sec,Sec100,True);
        Repeat
                BlockRead(F1, Buf, BufSize, Status);
                CheckError(_File[2],'Couldn''t read input file.');
                GraphIt(F1,F2,OldX,Hour,Min,Sec,Sec100,False);
                CheckAbort(_File[2]);
                For I := 1 To BufSize Do
                        Begin
                                If (Pass <> '') Then (* There's a Password *)
                                        Begin
                                                Buf[I] := Char(Byte(Buf[I]) XOR Byte(Pass[PI]));
                                                If (PI = Length(Pass)) Then Increment := -1;
                                                If (PI = 1) Then Increment := 1;
                                                Inc(PI,Increment);
                                        End
                                Else
                                        Begin
                                                Buf[I] := Char(Byte(Buf[I]) XOR Y);
                                        End;
                        End;
                BlockWrite(F2, Buf, Status);
                CheckError(_File[2],'Couldn''t write to output file.');
        Until (Status < BufSize);
        Close(F1);
        CheckError(_File[2],'Couldn''t close input file.');
        Close(F2);
        CheckError(_File[2],'Couldn''t close output file.');
        {$I+}
(* Successful Decryption *)
        Center(WhereY,Shrink(_File[1]) +' Decoded to '+ Shrink(_File[2]),1);
        GotoXY(1,WhereY + 1);
        WriteLn;
End;        (* DeCode *)

Procedure CheckParameters;
Var
        _File        : FilePaths;
        Temp        : String79;
        Mode        : EDMode;
        OkMode,
        Input1,
        Input2        : Boolean;
        X                : Byte;

Begin        (* CheckParameters *)
        For X := 1 To 2 Do _File[x] := '';
        Mode := EnCrypt;
        OkMode := False;
        X := 1;
        While (X <= ParamCount) Do
        Begin
                Temp := (UpStr(ParamStr(x) ) );
                If (Pos('?',Temp) > 0) or (Pos('*',Temp) > 0) Then HelpScreen(True);
                If ((Temp[1] = '/') or (Temp[1] = '-')) And
                  (Length(Temp) = 2) And (Not OkMode) Then
                Begin
                        Case (Temp[2]) of
                                'E'        : Begin
                                                Mode := EnCrypt;
                                                OkMode := True;
                                          End;
                                'D' : Begin
                                                Mode := DeCrypt;
                                                OkMode := True;
                                          End;
                                'P' : Begin
                                                Mode := EnCryptPass;
                                                OkMode := True;
                                          End;
                                'H',
                                '?' : HelpScreen(True);
                                Else
                                        OkMode := False;
                        End;        (* Case *)
                End Else
                Begin
                        If (_File[1] = '') Then _File[1] := Temp Else
                        If (_File[2] = '') Then _File[2] := Temp;
                End;
                Inc(x);
        End;
        If (_File[1] = '') Then
        Begin
                GetStr(_File[1],'Enter Input Path/File : ','',True);
                Input1 := True;
                _File[1] := (UpStr(_File[1]) );
        End Else Input1 := False;
        If (_File[2] = '') Then
        Begin
                GetStr(_File[2],'Enter Output Path/File : ','',True);
                Input2 := True;
                _File[2] := (UpStr(_File[2]) );
        End Else Input2 := False;
        If (Pos('?',_File[1]+_File[2]) > 0) or (Pos('*',_File[1]+_File[2]) > 0)
                Then HelpScreen(True);
        If (Not OkMode) And ((Input1) or (Input2)) And
           (_File[1] <> '') And (_File[2] <> '') Then
        Begin
                WriteXY(1,WhereY,'[E]ncode, Encode with [P]assword, or [D]ecode? ');
                ClrEOL;
                Case (UpCase(ReadKey) ) of
                        'E' : Mode := EnCrypt;
                        'D' : Mode := DeCrypt;
                        'P' : Mode := EnCryptPass;
                        #27 : OutError('',4,2);
                End;        (* Case *)
        End Else If (_File[1] = '') or (_File[2] = '') Then HelpScreen(False);
        If ((ParamCount < 2) or (ParamCount > 3)) And
           (_File[1] = '') And (_File[2] = '') Then OutError('',1,2);
        If (Not(RealFile(_File[1],2) ) ) Then OutError(Shrink(_File[1]),2,2);
        If (RealFile(_File[2],2) ) Then
        Begin
                If (FExpand(_File[1]) = FExpand(_File[2]) ) Then OutError('',3,2);
                TextColor(Red);
                WriteXY(1,WhereY,'Warning! "');
                TextColor(LightRed);
                Write(Shrink(_File[2]) );
                TextColor(Red);
                Write('" already exists...Replace ([Y],N)? ');
                ClrEOL;
                Case (UpCase(ReadKey) ) Of
                        'N',#27 : OutError('',4,2);
                End;        (* Case *)
        End;
        If (Mode = EnCryptPass) Then EnCode(_File,True);
        If (Mode = EnCrypt) Then EnCode(_File,False);
        If (Mode = DeCrypt) Then DeCode(_File);
End;        (* CheckParameters *)

Procedure Main;
Begin        (* Main *)
        CheckBreak := False;
        TextColor(LightGray);
        WriteLn;
        ClrEOL;
        WriteXY(12,WhereY,'DOS file Encrypter v' + Version + ' by ');
        TextColor(LightBlue);
        Write('Zing Merway');
        TextColor(LightGray);
        WriteLn('  CODE/h for Help.');
        WriteLn;
        CheckParameters;
End;        (* Main *)

Begin        (* Code *)
        Main;
End.        (* Code *)