(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0103.PAS
  Description: File Protection using Encrypt/Decrypt
  Author: KARTHIK RAMAKRISHNAN
  Date: 05-30-97  18:17
*)

{$M 16000,0,0}
Program FP;
Uses
  Crt, Dos,UTILS,ALLMIX,process;  { support files are contained in the XX3402 Code below }
label 1,2;

Const
        BufSize                =        512;
        Version                =        '1.3';
        MaxError    =        7;

Const
  S = '           ';
  archive = $20;

const
    MajorVer = '1';                     { Current major version number }
    MinorVer = '95';                    { Current minor version number }
    Year     = 1991;                    { Release year }

{$IFDEF MsDos}
    fsDirectory = 64;                   { Set directory length }
    faReadOnly = ReadOnly;              { Set directory flags }
    faHidden = Hidden;
    faSysFile = SysFile;
    faVolumeID = VolumeID;
    faDirectory = Directory;
    faArchive = Archive;
    faAnyFile = AnyFile;
{$ENDIF}

{$IFDEF MsDos}
type
        TRegisters = Registers;                                { Used for DOS calls }
    TSearchRec = SearchRec;             { Used for search record }
{$ENDIF}

Type
        EDMode                        =        (EnCrypt,EnCryptPass,DeCrypt);
        String79                =        String[79];
        FilePaths                =        Array [1..2] Of String79;
        Errors                        =        1..(MaxError - 1);


Var
  List         : Array[1..200] of String[15];
  AttrList     : Array[1..200] of String[15];
  filattr      : ARRAY[1..200] OF CHAR;
  COUNT,Pos, First   : Integer;
  C            : Char;
  Cont         : Integer;
  DirInfo      : SearchRec;
  NumFiles     : Integer;
  I,J:INTEGER;
  key:char;
  lasts,LAST,pass:string[15];
  pass1:string[2];
  NEW,point:integer;
  delcount:integer;
  F: file;
  Attr: Word;
  lines:word;
  command:string[25];
 _file:filepaths;

Procedure WriteXY( X,Y : Byte; S : String79 );
Begin        (* WriteXY *)
        GotoXY(X,Y);
        Write(S);
End;        (* WriteXY *)

Procedure Rm( FileName : String79 );
Var
        F : File;

Begin        (* Rm *)
        If (FileName = '') Then Exit;
        Assign(F,FileName);
        Erase(F);
End;        (* Rm *)

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
        Halt(x);
End;        (* OutError *)


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
                OldX := 1;
         {       GotoXY(1,WhereY);
                WriteLn('╔═════════════════════════════════════════════════════════════════════════════╗');
                WriteLn('║                                                                             ║');
                WriteLn('╚═════════════════════════════════════════════════════════════════════════════╝');}
            {    GotoXY(3,WhereY - 2);}
        End Else
        Begin
           textattr:=red+(16*white);
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
                textattr:=lightred+(16*white);   {*************************}
{**}            For X := OldX To NewX Do WriteXY(X,{WhereY}23,#249);{}
                OldX := NewX;
                textattr:=9+(16*white);
                Center({WhereY}1 + {1}23,(#181 + ' ' + Temp + ' ' + #198),5);
                GotoXY(NewX,WhereY - 1);
        End;
End;        (* GraphIt *)

Function Shrink( P : PathStr ) : String79;
Var
        D        : DirStr;
        N        : NameStr;
        E        : ExtStr;

Begin        (* Shrink *)
        FSplit(P,D,N,E);
        Shrink := N + E;
End;        (* Shrink *)

Function UpStr( S : String ) : String;
Var
        X        : Byte;

Begin        (* UpStr *)
        For X := 1 To Length(S) Do
                S[x] := (UpCase(S[x]) );
        UpStr := S;
End;        (* UpStr *)

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
        {CheckError('','Couldn''t open input file.');}
        ReWrite(F2,1);
        {CheckError(_File[2],'Couldn''t create output file.');}
        Randomize;
{**}    If (Protect) Then
        Begin
       gotoxy(61,18);
       readln(pass);
{                GetStr(Pass,'(3 Char min, 25 Char max) Enter Password: ',_File[2],False);}
                Buf[1] := Chr(Random(127) );
                BlockWrite(F2,Buf[1],SizeOf(Buf[1]),Status);
                {CheckError(_File[2],'Couldn''t write to output file.');}
        End Else
        Begin
                Buf[1] := Chr(Random(127) + 127);
                BlockWrite(F2,Buf[1],SizeOf(Buf[1]),Status);
                {CheckError(_File[2],'Couldn''t write to output file.');}
        End;
        Seed := Ord(Buf[1]);
        Increment := 1;
        PI := 1;
        Y := 127;
    {TextColor(LightGray);
{        ClrEOL;}
        GetTime(Hour,Min,Sec,Sec100);
        GraphIt(F1,F2,OldX,Hour,Min,Sec,Sec100,True);
        Repeat
                BlockRead(F1, Buf, BufSize, Status);
                {CheckError(_File[2],'Couldn''t read input file.');}
                {CheckAbort(_File[2]);}
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
                {CheckError(_File[2],'Couldn''t write to output file.');}
        Until (Status < BufSize);
        Close(F1);
        {CheckError(_File[2],'Couldn''t close input file.');}
        Close(F2);
        {CheckError(_File[2],'Couldn''t close output file.');}
        {$I+}
(* Successful Encryption *)
        TextColor(LightGray);
        Temp := (Shrink(_File[1]) +' Encoded to '+ Shrink(_File[2]));
        If (Protect) Then Temp := (Temp + ' with Password.');
        Center(WhereY,Temp,1);
       { GotoXY(1,WhereY + 1);}
{        WriteLn;}
End;        (* EnCode *)

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
        {CheckError('','Couldn''t open input file.');}
        ReWrite(F2,1);
        {CheckError(_File[2],'Couldn''t create output file.');}
        BlockRead(F1,Buf[1],SizeOf(Buf[1]),Status);
        {CheckError(_File[2],'Couldn''t read input file.');}
        Seed := Ord(Buf[1]);
        If (Buf[1] < #127) Then (* There's a Password *)
 {               GetStr(Pass,'Enter Password: ',_File[2],False);}
       gotoxy(61,18);
       readln(pass);
        Increment := 1;
        PI := 1;
        Y := 127;
        TextColor(LightGray);
        ClrEOL;
        GetTime(Hour,Min,Sec,Sec100);
        GraphIt(F1,F2,OldX,Hour,Min,Sec,Sec100,True);
        Repeat
                BlockRead(F1, Buf, BufSize, Status);
                {CheckError(_File[2],'Couldn''t read input file.');}
                GraphIt(F1,F2,OldX,Hour,Min,Sec,Sec100,False);
                {CheckAbort(_File[2]);}
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
                {CheckError(_File[2],'Couldn''t write to output file.');}
        Until (Status < BufSize);
        Close(F1);
        {CheckError(_File[2],'Couldn''t close input file.');}
        Close(F2);
        {CheckError(_File[2],'Couldn''t close output file.');}
        {$I+}
(* Successful Decryption *)
        Center(WhereY,Shrink(_File[1]) +' Decoded to '+ Shrink(_File[2]),1);
        GotoXY(1,WhereY + 1);
      {  WriteLn;}
End;        (* DeCode *)





function DeleteFile(FN : PathStr) : Boolean;
var
  Regs : Registers;
begin
  FN := FN + #0;          { Add NUL chr for DOS }
  Regs.AH := $41;
  Regs.DX := Ofs(FN) + 1; { Add 1 to bypass length byte }
  Regs.DS := Seg(FN);
  MsDos(Regs);
  DeleteFile := NOT (Regs.Flags AND $0 = $0)
end;

PROCEDURE BOX;
BEGIN
textattr:=9+(16*0);
FOR J:=1 TO 24 DO
FOR I:=1 TO 80 DO
 BEGIN
 GOTOXY(I,J);
 WRITELN('█');
 END;
textattr:=white+(16*0);
FOR I:=1 TO 80 DO
BEGIN
GOTOXY(I,1);
WRITELN('█');
GOTOXY(I,23);
WRITELN('█');
END;
textattr:=black+(16*white);
GOTOXY(3,1);
WRITELN('File Protection, Encoder/Decoder Ver 1.1');
{GOTOXY(16,23);
WRITELN('E-Encode File, D-Decode File, Esc Exit Utility');

{TEXTCOLOR(WHITE);
TEXTBACKGROUND(BLACK);     }
textattr:=white+(16*9);
FOR I:=1 TO 27 DO
 BEGIN
 GOTOXY(2+I,3);
 WRITELN('─');
 GOTOXY(2+I,20);
 WRITELN('─');
 END;
FOR J:=1 TO 16 DO
 BEGIN
 GOTOXY(2,3+J);
 WRITELN('│');
 GOTOXY(29,3+J);
 WRITELN('│');
 END;
 GOTOXY(29,3);
 WRITELN('┐');
 GOTOXY(29,20);
 WRITELN('┘');
 GOTOXY(2,3);
 WRITELN('┌');
 GOTOXY(2,20);
 WRITELN('└');
textattr:=9+(16*0);
for j:=1 to 16 do
for i:=1 to 26 do
begin
gotoxy(2+i,3+j);
writeln('█');
end;
EnableHighBgd;
textattr:=10+(16*9);
GOTOXY(4,3);
WRITELN('List');
textattr:=9+(16*9);
gotoxy(3,19);
writeln('                          ');
SHADOW(20,3,20,29);
SHADOW(3,29,20,29);
END;

PROCEDURE BOX2;
BEGIN
textattr:=white+(16*9);
FOR I:=1 TO 37 DO
 BEGIN
 GOTOXY(40+I,3);
 WRITELN('─');
 GOTOXY(40+I,5);
 WRITELN('─');
 END;
 GOTOXY(40,4);
 WRITELN('│');
 GOTOXY(77,4);
 WRITELN('│');
 GOTOXY(77,3);
 WRITELN('┐');
 GOTOXY(77,5);
 WRITELN('┘');
 GOTOXY(40,3);
 WRITELN('┌');
 GOTOXY(40,5);
 WRITELN('└');
textattr:=9+(16*0);
for i:=1 to 36 do
begin
gotoxy(40+i,4);
writeln('█');
end;
textattr:=10+(16*9);
gotoxy(42,3);
writeln('Last Modification');
gotoxy(42,4);
writeln(last);
SHADOW(3,77,4,77);
SHADOW(5,41,5,77);
END;

PROCEDURE BOX3;
BEGIN
textattr:=white+(16*9);
FOR I:=1 TO 37 DO
 BEGIN
 GOTOXY(40+I,7);
 WRITELN('─');
 GOTOXY(40+I,10);
 WRITELN('─');
 END;
 GOTOXY(40,8);
 WRITELN('│');
 GOTOXY(77,8);
 WRITELN('│');
 GOTOXY(40,9);
 WRITELN('│');
 GOTOXY(77,9);
 WRITELN('│');
 GOTOXY(77,7);
 WRITELN('┐');
 GOTOXY(77,10);
 WRITELN('┘');
 GOTOXY(40,7);
 WRITELN('┌');
 GOTOXY(40,10);
 WRITELN('└');
textattr:=9+(16*9);
FOR J:=1 TO 2 DO
for i:=1 to 36 do
begin
gotoxy(40+i,7+J);
writeln('█');
end;
textattr:=10+(16*9);
gotoxy(42,7);
writeln('User Information');
SHADOW(7,77,9,77);
SHADOW(10,41,10,77);
textattr:=lightgreen+(16*9);
GOTOXY(42,8);
WRITELN('E- Encode File');
GOTOXY(42,9);
WRITELN('D- Decode File');

GOTOXY(60,8);
WRITELN('Del- Delete File');
GOTOXY(60,9);
WRITELN('Esc -Exit');
END;


PROCEDURE DELdir;
BEGIN
lines:=0;
if pos<15 then
  pass:=list[pos]
else
pass:=list[cont-1];
textattr:=white+(16*9);
gotoxy(3,23);
write('Do You Wish To Remove Thise Directory And All Its Contents [y/n]');
key:=readkey;
IF (KEY='Y') OR (KEY='y') THEN
BEGIN
Assign(f,pass);
SetFAttr(f, Archive);
NukeDir (pass,true, false,false,faAnyFile,lines);
LAST:=PASS;
END
ELSE
IF (KEY='N') OR (KEY='n') THEN
BEGIN
lasts:=pass;
END;
END;



PROCEDURE MAIN;
begin
  TextBackground(Black);
  TextColor(LightGray);
{  ClrScr;}

  For Cont := 1 to 15 do
  begin
    List[Cont] := '';
    AttrList[Cont] := '';
  end;

  NumFiles := 0;
  FindFirst('*.*', AnyFile, DirInfo);    {replace here path to *.*}

  While (DosError = 0) do
  begin
    Inc(NumFiles, 1);
    List[NumFiles] := Concat(DirInfo.Name,
                      Copy(S, 1, 12 - Length(DirInfo.Name)));
    If (DirInfo.Attr = $10) Then
      AttrList[NumFiles] := '<DIR>'
    Else
      Str(DirInfo.Size, AttrList[NumFiles]);
    AttrList[NumFiles] := Concat(AttrList[NumFiles],
                          Copy(S, 1, 6 - Length(AttrList[NumFiles])));
    FindNext(DirInfo);
  end;

  First := 1;
  Pos   := 1;
END;

PROCEDURE DIRCHANGE;
BEGIN
 command:='cd..';
 SwapVectors;
 Exec(GetEnv('COMSPEC'), '/C ' + Command);
 SwapVectors;
END;

PROCEDURE DIRCHANGE1;
BEGIN
 command:='cd '+pass;
 SwapVectors;
 Exec(GetEnv('COMSPEC'), '/C ' + Command);
 SwapVectors;
END;

PROCEDURE userinf;
BEGIN
textattr:=white+(16*9);
FOR I:=1 TO 37 DO
 BEGIN
 GOTOXY(40+I,12);
 WRITELN('─');
 GOTOXY(40+I,20);
 WRITELN('─');
 END;
FOR I:=1 TO 7 DO
BEGIN
 GOTOXY(40,12+I);
 WRITELN('│');
 GOTOXY(77,12+I);
 WRITELN('│');
END;
 GOTOXY(77,12);
 WRITELN('┐');
 GOTOXY(77,20);
 WRITELN('┘');
 GOTOXY(40,12);
 WRITELN('┌');
 GOTOXY(40,20);
 WRITELN('└');
textattr:=9+(16*0);
FOR J:=1 TO 7 DO
for i:=1 to 36 do
begin
gotoxy(40+i,12+J);
writeln('█');
end;
SHADOW(12,77,19,77);
SHADOW(20,41,20,77);

textattr:=LIGHTGREEN+(16*9);
GOTOXY(42,14);
WRITELN('Source File Name : ',pass);
_FILE[1]:=PASS;
_File[1] := (UpStr(_File[1]) );
GOTOXY(42,16);
WRITE('Target File Name : ');

GOTOXY(61,16);
WRITE('             ');
GOTOXY(61,16);
READLN(_FILE[2]);
{GetStr(_File[2],'','',True);}
_File[2] := (UpStr(_File[2]) );
GOTOXY(42,18);
WRITELN('File Password    : ');
END;


PROCEDURE CONFIRM_ENCODE;
BEGIN
lines:=0;
if pos<15 then
  pass:=list[pos]
else
pass:=list[cont-1];
textattr:=WHITE+(16*9);
FOR I:=1 TO 57 DO
 BEGIN
 GOTOXY(10+I,7);
 WRITELN('─');
 GOTOXY(10+I,9);
 WRITELN('─');
 END;
 GOTOXY(10,8);
 WRITELN('│');
 GOTOXY(67,8);
 WRITELN('│');
 GOTOXY(67,7);
 WRITELN('┐');
 GOTOXY(67,9);
 WRITELN('┘');
 GOTOXY(10,7);
 WRITELN('┌');
 GOTOXY(10,9);
 WRITELN('└');
textattr:=9+(16*0);
for i:=1 to 56 do
begin
gotoxy(10+i,8);
writeln('█');
end;
textattr:=10+(16*9);
gotoxy(12,7);
writeln('Encode File Confirmation [y/n]');
gotoxy(42,4);
writeln(last);
SHADOW(7,67,8,67);
SHADOW(9,11,9,67);

textattr:=white+(16*9);
GOTOXY(12,8);
WRITELN('Do You Wish To Encode File : ',pass); {<----}
key:=readkey;
if (key='N') OR (key='n') THEN
BEGIN
END
ELSE
if (key='Y') OR (key='y') THEN
BEGIN
{MAIN CODE HERE}
userinf;
EnCode(_file,true);
END;
END;

PROCEDURE CONFIRM_DECODE;
BEGIN
lines:=0;
if pos<15 then
  pass:=list[pos]
else
pass:=list[cont-1];
textattr:=WHITE+(16*9);
FOR I:=1 TO 57 DO
 BEGIN
 GOTOXY(10+I,7);
 WRITELN('─');
 GOTOXY(10+I,9);
 WRITELN('─');
 END;
 GOTOXY(10,8);
 WRITELN('│');
 GOTOXY(67,8);
 WRITELN('│');
 GOTOXY(67,7);
 WRITELN('┐');
 GOTOXY(67,9);
 WRITELN('┘');
 GOTOXY(10,7);
 WRITELN('┌');
 GOTOXY(10,9);
 WRITELN('└');
textattr:=9+(16*0);
for i:=1 to 56 do
begin
gotoxy(10+i,8);
writeln('█');
end;
textattr:=10+(16*9);
gotoxy(12,7);
writeln('Decode File Confirmation [y/n]');
gotoxy(42,4);
writeln(last);
SHADOW(7,67,8,67);
SHADOW(9,11,9,67);

textattr:=white+(16*9);
GOTOXY(12,8);
WRITELN('Do You Wish To Decode File : ',pass); {<----}
key:=readkey;
if (key='N') OR (key='n') THEN
BEGIN
END
ELSE
if (key='Y') OR (key='y') THEN
BEGIN
{MAIN CODE HERE}
userinf;
deCode(_file);
END;
END;

PROCEDURE DELFILE;
BEGIN
if pos<15 then
  pass:=list[pos]
else
pass:=list[cont-1];

textattr:=BLACK+(16*WHITE);
GOTOXY(1,23);
WRITE('Do You Wish To Delete File [y/n] : ',pass);
REPEAT
key:=READKEY;
UNTIL (KEY='N') OR (KEY='n') OR (KEY='Y') OR (KEY='y');
IF (KEY='Y') OR (KEY='y') THEN
 BEGIN
 Assign(F, pass);
 SetFAttr(F, Archive);          { For Windows: faArchive }
 DeleteFile(pass);
 LAST:=PASS;
 END
ELSE
IF (KEY='N') OR (KEY='n') THEN
 BEGIN
 END;
END;

BEGIN
2:TEXTMODE(CO80);
1:BOX;
BOX2;
BOX3;
MAIN;
  Repeat
    For Cont := First To First + 15 do
    begin
      If (Cont - First + 1 = Pos) Then
      begin
        TextBackground(Blue);
        TextColor(Yellow);
      end
      Else
      begin
      textattr:=lightgreen+(16*9);

      end;
      GotoXY(5, Cont - First + 4);
      Write(' ', List[Cont], '  ', AttrList[Cont]);
    end;
    C := ReadKey;
    If (C = #72) Then
      If (Pos > 1) Then
        Dec(Pos, 1)
      Else
      If (First > 1) Then
        Dec(First,1);

    If (C = #80) Then
      If (Pos < 15) Then
        Inc(Pos, 1)
      Else
      If (First + 15 < NumFiles) Then
        Inc(First,1);

    IF (C=#27) THEN
    begin
    textmode(co80);
    EXIT;
    end;

    IF (C='D') OR (C='d') THEN
    begin
    CONFIRM_DECODE;
    GOTO 1;
    end;

    IF (C='E') OR (C='e') THEN
    begin
    CONFIRM_ENCODE;
    GOTO 1;
    end;

    IF (C=#13) THEN
    BEGIN
    if pos<15 then
    pass1:=list[pos]
    else
    pass1:=list[cont-1];
    if pass1='..' then
     begin
     DIRCHANGE;
     goto 1;
     end
    else
     begin
     if pos<15 then
     pass:=list[pos]
     else
     pass:=list[cont-1];
     dirchange1;
     goto 1;
     end;
    END;

    IF (C=#83) THEN
    BEGIN
    if pos<15 then
    pass1:=list[pos]
    else
    pass1:=list[cont-1];
     Delfile;
     goto 1;
    END;

  Until (Ord(c) = 13);{}
END.

GetStr(_File[1],'Enter Input Path/File : ','',True);
_File[1] := (UpStr(_File[1]) );
GetStr(_File[2],'Enter Output Path/File : ','',True);
_File[2] := (UpStr(_File[2]) );
{EnCode(_file,true);}
decode(_file);

{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-011488-090697--72--85-13646----------FP.ZIP--1-OF--3
I2g1--E++++++D6IjG6++++++++++++++++4++++JIt7J3AjI2g1-+c++++++2EJjG8h8+UJ
5++++-k++++8++++IYJ-F2p39ZFMJ2N7H2IUFIt1HoF39oF3Eox2FG-JJ2ZAGJFN1EdEGkA2
3++0++U+QopO6gxWMi0r2+++M06++-++++-JHYZIImx-H2lBGJUiJ3-JjJZvQ7FJZXzrSzLL
bItrVm+4N+6P2PCkViu61W6WSHK77DEfsGKpEomOD0cYP1wUePKmMLJXW6HJRKh4aJ9EMJm9
-GQmp0kuCt-0bf6nEy21JuHKcFlbK+7M03If7BpvnjpiRvcvMQPxNnhobyzwviySSwuttxvv
TFyprXcTsCQWf6AxxcKC6zXr+TvRQZVn7iJQbEGkkMnB4g+aQst3VzzfdlgQNfQt6U5spCqa
Bwpfx7+mHzx64a0PpOWam7wertA-TeMxclyGWLx-vpAyIGyfcBqZYPu1csSpAteevxBZoqHH
TOO5HIyPfe-Lnq5PCmf+8ZC9CH5SKiKYSN2uO+7Mm-7ME0idfeudKUJEC5UH0Va5+ZrVG5+1
UCKcXU1y0wVZzZdAlARtv8OVZrg0+DTzcN1dX5GpffOe4d3PIM+wEflNapcOUlphkIUY48dV
km1V5kqvaXIk1Hflec2vsRAA1eOjVbKmrv+s-ygXYJ19InVw1P8aQB-ftWMrpXQ3xuB-em9l
09UJvCp52Zsv-VVN4cPLw3j6j3OXIoR9Ckvm0K7uhU75Y2AqYbu4UUoRcQOPVdyCWlGpZ0Jd
Q6wo3oT7cWZWbHX6HLODN5XXMprcrIoqBu2ft7Ui6NGoPHWwjeIhu744EM2SK0mF1KfoG0IZ
vo2QP4I9ptNuD9LJbeJ3hOheeO4oB9D-upx-1KJZp70B1SIJeFr8mnBkHrItsFIJV3gFfkbU
V-IxwA+1-9jR-4QVX3lDIK-ps+XnG2iL2ad5B3-FKyQJtVR95eamAi3Dc8umb-f8GzWsJJK7
QR34PIJBYGj+wGSSG7ce8pZSLVJMJcGxe4LNgYGDtQY6TWLtK7IclnYWhoy+Z8cfcK-H4-B6
bnLm10l0bpnT5cMwXZ1BuAkb9uhM1JCHW2TquGh84Vh1kL+Mdb5s2tttblucrlFosul+DcTT
Y4PUbDbAMMFdgZnEbgEzZbqadycXa1oL5C9cGMIP6LFnGvg9HaOWyAw3NxDEQ3SsgGDgUgwn
IKvVemHO75AIzvbUunEi2j5D-PQm9L-IMEbI8WKLBh10dpJV-Ygm8kSEAop-Dngu6aoRHK1X
x1nJg9QlpB4ocPsRZr+0zLDq3CGwdjVIhBLG++KQ5-7fa4Aii1Q71YUyIrZ9e8dxTETAsiUP
7dtutUMjpzilCjsPKGJhPHzk9mq3AllxLQpMvb7miTAhY3PU+59QWYzev66nGYfde+oRPFoV
C7i8OOgf+ggx9jV6GLKLUwLkwLXkETVYD1UTneK0IW++bme7gb3WWggwBHJMzJ0c2VfIodDt
RwZYxWGHuIDCJSl7JFi6VC+hrbBbFgygN2xfgiTnm5Z6xf2+53-HGZf0eZKo-71520W4qWEk
FoDUERWhdLKN1nSGk3sNUMSUr7H4S-XyCFrsDbmN-+dJ--P+T1qBwEUwakf6+NQHDgd+L119
b20KabnmWa+66VlNX02qeLvBLo2vsVPOvi3J926hKoYtHswUcunOLpvZNvc1xLz7M1-i4Qj6
ftRpPCmW5M1dh6LMgwO6J2gGo0sZwNzTOLsnAGguKw8F9TdAd5mOEUzlAiHAnP9TIVv2omlc
K0v2taz5IPY9Wi9DfaWjTuchKBbGp3nOpAVo7n9ihqO4RAvYhtKrVBCM0l-rXKBSpzkKqg10
1O3Ug7rdGl-vB6AZ4ODHBWUBmztgr-cXSDEZiZHGDQKRiqVDGbsho3nTq94NuJtgCtiRnZKA
t4LwL+GzmJrT4DF26on5yklsltPdSuj7friX2LQ75jdALsT6R5guFnJGH0bAzDYdSJKmce8e
ZibBGDqVDRDwcnW3zcd+fQTDGFgFqXKCR75txEezryAjxOlWSWQW9sofgDzT4vNjfSBjq9GY
9uZLFmrb9L4y7xBRG8GtM1-CbQH8oeYQOQyJbXJUr5DTgTXMSYbVCiqt3-5p97MCl-7R9mAb
9-oM7NqmHmB4gpv9qccpvPA2Ce8V-Zvd-P5MCI4VVhfuI3AkMXGA7VeaNjYocsTInI2Oh-V-
Umr3FV9UiWmTKicDpXR86lmXdPwAWOIfEmqFc5Ef0R7tFOCIFhR9hqsESX9fXbS3Sj9wEks3
QX59G7tDdlCzjLt1Q9M4eXsKuKGfn9RLbyFSLj-qT7uSn8TWltgFOES5u4NYsXZtnVf4zYxO
mIogTNuDkTWyAHDaebOjQJROc+5VhAMef1tp-L2Z7yTGTGABiQ6TP708firHXRh51PumbYLH
vt7tfOdRK9wkNhq0Mkfn4BU3MLtrWjY9swpTo-BrdrugVZ+s01cRHhBGpfZlUZ8Ugv61qPz0
3UyTVI+kQd2r4NwZsXjysv5sXJobckTkqnhZUVsyhOcRHoBd7DshVfgjCzooNAbHI2eSVewU
tlym8H2BnTIVuHPjG+oOC4pSqonPtxYogNqi+WiiuAHnVIzeQVJMYg0JP4EI3yXdX48Qf-E+
3oUwbh-XqHvK6gKGihraMurGO37TMjCnBO1rcM5BhglhRan1pC-3qyjMjgL4bnfE+uxhPA+i
R0-J1ob1QR6HZHVWmv4TEvpCxvE5mvcOqc7qy8KhHeQZJRrFgN3qhXdHSP0-Z7yHUcRVSuGZ
DFew03zOuf0u6u23Q-qjJhOrFD9VZ8pC7OlsBhDgRGe-lJMQehvSOkzPXEZm9wQ3J+-lqfdc
+QqqynFzcuSxfEgnH01hp+jhDfamdF3Hb21sgRwJlUUHWATiIod01QoMN+e7yOLV4CZrKavo
WSB595fyQE0z7F5D0++nVGkIVS6Iyc8IYeJDdN1fV4kKQeDcpkb4ph4HsMRLO8jsvsTAmSZr
oK4BrsTMEJX8NEyrC-jxz-58Nx0DzGXjFPyCoud0SMsC89HnFtEzFHZ8nysMlmGgxTLcvlmI
at3LVf67tIeI7l1TWH86pUyWb6PlzUSXBlA79yKmI6FvarXUlwj2UnsSgB36GpiMwwcvkZWM
vHJf0Wk4hQVP2e0KEIM5JHL4KkDrUIKpUWrDl5zASKBz-elOfOft5ds0T0I+ayWFEN7AAdAN
MrGWPA5dSEvHsvBAAfgg2dXbsGqPFMNQg6B0izafq4ortaJy9WUmt2+q9j5I0tUlAwTVg4WU
a4XTdgSk1v0jVQYGkuwgGGUJqeEzktavUDaSCpjFJ6j1h+MlSiPu+xtKK1HJ8Xq1k-I2fb7+
goeonxt+s1MCBRRgnbLYHbIch1ieaB7gVe+XJtoulStEO4St4w3wNULvJ0r9-DVD-NKKt1n2
WpYqq-FEn4MfzZeb8PENnAK47Ik5auNCbntRIxm6JR3f39M6wsGVmEmRZmGUID04ZGZAcTQb
ecEHEtSdvH73muUs7JcW9m1zbr1EqTOz-6jBUNwgIBv2VZog0pv5EGrNBahCXWeRF4kD1jej
H22WxJQfEe4CIBrKrvi4Rh125QT0rbZ0cnrqgV75yHdmJD0qabbnMMluNSjFJi1OqAwnWk5Q
oRxCp15firFgLNMqkC3lD0GY4jfDwEEpnQ7b2l3G9ElBF90Y25syYExzaY17SqKW58FqCnxV
1WeWjnL4m4cpsLSN1HS0JXB3PJmHuFSl8GJ4z94h54Tgp4bLoDOVqGSo2BPBETXOSz1fiDTo
OKLhb86tP0pCxA3eaFCr13T9qnvQzjuqwmA1rMD5BaZv3rZ0oe-bnsjC8xzgrbtysB0-YGYf
gKb8mgGMBiCexT4-vaQ3Gft1F9uo1reuTp6IZGzx00xSoT3WCzGvLtbZKCG6DbNbIkDRPkUA
CP2d8pgx8Ef3TPaGfCW9xAXX+sSIC3ft1fO21O8bu2aT9pL3mSp7oLhuiUSZeBPHjLxVl1ta
ogXX-kdEhfEgYGoh8t4hEv5MgIqKjIOWI-iZt6qZ9FMX9qCXkZfIRBkRNtSyE6SuFrZ99-Ym
+OpgP31nI6HMoeLxq-UPGPBX+-CktIjD7arTiX3ZNHDc+sR4Fh7nMFWXtjUjFX02Kqbhnm+T
6dPbSoR45iqxBF6NBClZ4VXHYokB5J+i8zW9olozxM2CMrh7DiP3ySLSZz0Aqrfx67HxyWw4
wLFTAcBGmrVmpnCFrDIgKMdjHpG8CmWbrKxDACRj7sjaiDj57EDibqppvxdqNejvfM5i5M9y
j5jjTNGhEMWk7LriC5RIGL4IZengQ+rx-4jPkRSKK2eN34BhXyAQDCgEQNlpd0sdGoMQbBHL
KrFBLAmvRfFPor-SbBRcqVkWpQtsOc2PSfDYG7oBHXZIR0ql0cwe8EqdFQnbsvjuxlq4zfDX
6sF-nHvua7OAe-wXxjNXhBszuOGK8+OBMLr4YfIyo1pKxzrioHvrvLvrvILiW97cTRFokVqH
sD9RVDUF0L22hpzJBPHJ5LjS5HjpDhaS9CdwSD7lxlLdiDgOKg9OfClnTxDjpjb3xJP5EDSk
Q+lNCf3GAHvdzStVvzUxxsVaF7+MFRi3oyiCouOhQzhMRWDxPWhS95GDP2Nhx96QQsxm7tPk
W0mwvTPauLri49L3yhol9sPffTgXVFr1hiUZp93zx-VKw-j7l6Y8TLQ7jDSNDDmK5faBDx5P
vtqEbIBLGohRtsTvbUAcqr6Pt8RjiAvr58MRKsbxMk8vahvhd1k6JojljTS6vpqEjqZTTT4h
IuSBtHdN2XAoKIfiVF+zhgaKgjgBowFBPYoImX1TZW+yTiJmg1YiHgvS8v4msvr1AMNfhzRK
P80LlPTqLczpR3hlLyfjzHdaNLrsqxBhGSWGcSg7LH3o9O5D7BrkFtGN3GkB0xQqVdi8BXLJ
XmLCBSExL8KMNjQwNcfOHaW7pEu1ZuodqY5iib42SwPe6TskDcLUBr34vonRB-95R1szmYuR
FWXLiEjjjz+4wUJuVdU2yUh2j3j64I6Ks8A8DOjAVJnGaFDvbQFyXu0YpyC9IPu+gYnkesHo
0fZ8m0S3bINVdoLM0EYvasKRdkLzvkJzay0z8DUv-5ybsCwKj5q0hpzkTWZsEs7rHD-y6rUT
0hvbUjQvkTh8w8s7rUr-4lIwWFYw2nBs1aPkva649twNj5g3fp1kL69rgC+x9bXZUcQrs5kS
DAm6jpP6hI9yEBVd3bMq01iPV7qz3LNu-9yLtHjdKLEPrbDHgy2C6RwIsykFxjM9Szxaj3G3
ToQvUqXbTK5rd91vOqPIWkrnE2xjWo5rsWAHnbiigtAzhlMumJ+h3D9lpkXSJgtHMPjUjGHY
emXd4LQDDVaFbJw6zgS0ztbUzNSEZp-KGjGEZChgFjaha8wMXjgmDLQnMxkQx5C7H5YrqVwE
TdiErsTh7Q9CYmWx2XpT6svh4kGyZTl+yIC-zlXZmp7e5O2xp9wEyiwd1hGN42xXVdsXx0ZW
T2qgBvC6wl4Agl0AxRAdwYXtw4+wSK1sNTGXyJFkbSdwrb83bcQwmhjrvg0P7DGdUdQDWHm+
Yxstz-J8SiTk2C9oPe7Ol9xKlBwesih+yELJZR1vF9kj0TpZ4AgjxTyym4i3O5w0lubYQSIu
wmFufq5UnK9QPf5S-cHRZoLvemZqzoSWxmV4TaMZQGAidt1ZMfpKWTJOWz7HyUxzMSyjly9b
yP29CELffwzMbvXyBqbtDADi3r8yY6w8iHdZDfx+zlsIwpeCwveFvsD4j0sLTewJwrdMxAjV
ReNVD0GbklmV3khx+ReVzcxlDFx8VNoecGwLj3fF1zRNzUtdfMVXLJcQyTXKmC+tY2TnAELy
3p-9+kEI++6+0++7JJcWS2wjr9YF+++6Gk++2E+++3JCGJFH9p-GHoB3IpAiI23HnHlfXxiq
Zhw1t1ykE+17fS7sohji7fvSMX8DlgVYNa-BYaOn8I-9h8oPaHF6OeOyUznrtG2dWLfNQXTH
***** END OF BLOCK 1 *****



*XX3402-011488-090697--72--85-26893----------FP.ZIP--2-OF--3
fhD4gYUS5VsSbXRnznruFbwSDp7zcwhrPwu4pwQVaaxFiA8Ic1S2QrHMlw6mbpCG2YY2kYVY
wnXV778APl4aAG8rV4zZ8e39Z2UIAGdlEgKk4xNZxcKU-SDcx0d2RnmFYZ-oYz2tExRMF1V3
DkpzucZL+Sh1EaBq7kdsaE028Z1RPYT1YEDfDS2WMJGxTO2bjaGrN1ob51rzAI-59psQxOTL
BzfnxT4XlswmaYWosGkWEckTDoec75m-6u7O--4D5xozaNuTbdqXhy8I0HKWq8mfQ+mhNtSb
ozCjNHyvSBhHzHeNrEHkfEM287EwcIhF4TbsIQGcY4P+KzkjlhwHXWP6Cz94fIGsFmQNtsF8
h6PSuBNGZaOObbPehkYh69rseFqI+kZuRo1uG91VusbSdkt6At6G9+XOEayxf1PG9QFdkRUH
xDAzleqkEW7FSE-GEdRmZKCnk1C0smiO+c1wQPkPkW93Gp20S7r2AO3ei5YMtyz1fHVDIe6O
v3DFwduZqNdAHpJHzZWoiEgebcjKMluhYZi+ONz83fepgxab4ZTImGSr4p9mrwqA9-AV0FSO
1DNtjCw+rOBrUgG3N6VkaVO2iEY7JXXCG+EIm7z5LSC3vc5IUVaDoJQLyJjA1IXJaIzd7dDc
7F8Oxnwt5D-tL69BJ2w3GqkM3EEt-yqMWXjJZ6wTxlSi5I0jy37Vg-iVSxIfKGMIdksLtKH0
T2bYjj2ZJoW482VECrl4pimKeC3nlZ80OTg7a0uQWL2YAtmaKvII4-ivt7YFYOJm5nXPWmo+
3F1O1cG9V-6FfhURJJ1i46z5zEZwOEG3Udg030Eo4A5E+VTWspV8bglrkvt5yWVUrHI17GUN
WfIyh99Y4qhj9T5XX-BoTj9883uBUExzVlgG3Tgv49Tdu6Le7ek0Z0i0rcNDsHkdM4WFoIW0
3DILb8oRjHQO1CrYaCApUTDu2VZ6Og7+DzZW+2iT2vjuq6mUH2qeCdxUWVW6DYgPUoN0BEuF
ZSI3skmziPMgpUMq+NkWjyHGwcEOBUoI6a8HsaqU3dk7ZyJ9thjrkJLaiQLQQddtAuU+HROP
Z8k7ZFVk-5kvhnabSaKPGkZv+lgtgP8hl1PaWHuuoEfnwOtnAJ81Mv9+KGc1R+EWDY1DpRQf
xy-Fj+NUa5CwzHEO1jzXAlmY2fMx39ePAsnw6RpFnqiXwa4e4u4OwtmlIQPbuNTigpUO-DCI
FJxeVU-wC6Z2wazG0S6SLP-Z+eOUJEmuRo9FT+jblc4oG3698KJoaJ+tPdI7bSBX9AYieL8D
Hf2x6iUC0tFW6EjHhP6WQSgGx4WY8EfnXEjdGTWhcnOf3CKOXMfyLFGpx60ZOBeu84+OgrIb
7E+3owD0e4s9cT5MoPb+iWwp-sxnXPC2wp7O1DPx1JZjEiacJjDu2ex7G7O-TfVOt2RhL21L
XSevoXNLk0ZoiISz2cY2KQ7-pAs9Kmk2oQc5d3FlwfvKg7WIHHyUOALxoO082LFFQ5ovkarJ
e2nI387cJI0C8XXbkxKjERbUX0kOvh2dovUOlRioZ60WkyDTMC0Htmx46sTEkxAELZiIrMNk
aXScCRq4Anr063a-B9LjmzvO3jGVRH1iZXvLa+j9y77dTjXOE9-ZihwOotZpjhPfDDfl6-lC
GkK3B4I--y-ICBQJKRlev1uQjXx70SNjtetGpuy2rj2jN1hbaARcbWoKV5xn-Rf+knqtPESp
C3TJrFXZj1qZYjhDXbsCYBYFwzNidSaiRqZsffoTC6bbzoos4u+74UpEn59tsonFa4PYuCfq
eHclqnL2W0n91UqOJ7q7jt6tDi-2jW3PZnbUZR0G5kBreAt2W+TY0sj0+LnFiKZBuXQcPaTv
emZSq73HAGD4V0FlpI-oH4upt9IqyitKF8s6v6FOkN9XhET49vWLX0CKGLV8-C63m6QnU1gF
9rPBqPZ1zDCw9vf3OJOpS26NHw37yzpJiurF-H8IaANMqlt+cGf28yqQzqaEZidTRr9YnwwD
+3ol5y6MXVjM1hTVhMitesIO37eUOwaBw5jpKs0S5DpbIpLRcqiKe0YYguAojRi6os1qkc3K
-EDx0nX4Z7UFaL48PaPjnZ0mg5AZFhg6ACqlm2TOiOigBI4y5jAvyiRzqMuztoTtPneoZxZu
-U3SOzGuVxKgpemC3g2-1fqNwJ73l+aV1yaNpd0f5AVEnzsVWSL8qes6nkJ9AoZ+QDtXx-9y
DVvLFsGZnxAqs8EdYEgw7gXrTER8bBmWcx3cB30saqxswxlwCTWpvz51vKabEnzM5JqeNEh+
M8hlP4hNT2CWN74E43In4XVBrJE4S1MN3wYhGPS3KbP17AJcW0P6JStBl4uMHIRBxBleibPQ
fARbsVDuH8dltfQ1eoxKdDBHF1pmwDO31RNUHNQhkfm6wFk0LMRGGhUagc6Lc1+6XZPqSDL1
5M6f7imI-rBP+r-zYUsuHVAsIg+2PWkpp8dha9-DUckPgT6G3L8or0mhw5JQB21bllTV4K7U
7BkZUXlgwiXzRn0g25jxshoVVU+5usluOp3cgkAjbJH-1VTkb54LiIdPtXFPfvQB0fn4B2u-
A1-aRtlsNPfuqWcrF6bIimINh-UWjl8d3imD+Yi7kLWjyR3CVV9YmEcU3cq1xe1vWIM71d6o
8MAOIKqIrkW5F3-DHIk1x8xAmDncCLZTTwanxHkpGwkbGFP6donaI+MUKaWHcGcChyzxMXx1
xPw5m-TiCYVZ6uM8yyIwcP3ullJGSXD-zk5Hn46-nSTEubjT1vzrUYd0fBWS6CQRg3kAr+j4
BZcHuCE6dZgrutp+W7pZh2VpQ96VK3MLvjgKu--G1-eKAzY+v8LFE9zqHtYsstllszeeJxq7
LTRHH+-Faox5bk4YBzE4CNrrdLxrkljhU3SCeL4nneU6YGmdPktAEJcBR3+H7m4Fto0RcfB9
cFqWllvFGGvP8dUPxFCUopmYLFiZR4nrKaSIeh+7RQ9c7-L2vC0Tr7R1xWe5ShVC5P7vxFYu
lvQkf03NneiA6xyams+UUyNtzgPQABf3+qQQ0q8vhjRn7JV0Zs34JmQ-HRM0JdXEWCj0+3-J
846NfLWUxEyklSZiOPOH4aqT1nmFt69uLdb0+sa8j8-AokP6ylxjBzLODZAOyGrgLjwMEvu1
U4+EOCd38l7xCM-CpwPs+k3bY2-fddtnnyAdSXskkPtjGobTixNCCQVgW6V7dgrsV4NYC-lu
TQVK-fZuvhp-p9JFfaHFn9G+ifcYToXToITkDZDsdsuSoCSlo3LHFNh7Y6UwtFdMwwBMt7lI
hkuqmVdVHcJ6ptsMqw61EfN6n+oHjgCnpe8-mdlSge8QM8QKQ51M9QKvVbNPKXePdiMZHFAn
BuAV0k3qj7oOZaq87ed9f0rjzgboOQhtaOpfeoKRZhyP72ovH9Jm6uRLhdN0Ouna3Xe9+0It
fW1skxTK+5X1YLVMJzy4jRhg06Ss2ewsyHoeP-nLvsHFKw8Z5EKgbqak2FM2cTv3XlIrDkGD
J-i1-Wcuf70mx-Ap9VcJ2synwM6yM9xziC1IDh6vPZiWrY6psd7k7pzfRbICU4aOE3hSLwMs
U7WU6xUNIo9buvlcaTUlsnsZbu5Tiwo7e5jv7XzrCQ9+neeZW2Yx86BS728SOmyY6ldZuP85
EE3ALeaXEotZQABKn9E3dyMYNLTR1Cf2cGel7m2lZmVJIk7zMPaLEQisWA2EVdNVevy9ETiG
TYS+MMS2vGueCwbsLVVZ8IJXS3atq-qPg8K9Ye43QKZBgM2cpQzukin-GwWQuJLiebWfP7hH
uvOjWCvS4jptZAp45ui-0kSN0FeBxtPThG3nQD0XNkHYqoEzujUN1VUQa0W8qXWW2PUcKkyA
LXX3ljeLfFnKnvN4C51WMnbX3TIZVPLNfuIK4M5hpAfEvCvyU2X1bJPjWUZqFIZu4MwJbWlz
z3+81KSmdUBJhR8pbpR-xzy0kJ5BW9JyWbvqQhv8LPkRC3cuxe7NVzpidrPIUxRzXdnPSYv-
JTSbI+xuk-G4VLhCgB8R1s-i1oJDw46f73Yrk9TtT8JDpyfBpQzL9bxijtCmlp2dZOH9ViD4
Q7rsdNomKWydIcpF+jvuk0PKOmn0ioF48yE9wxqGvSjV+o12kWHu6fNSMlczpS29n7SNfgEp
ZHBJKwhCq4ZWaTP+X17xkQ+m4Gc+RqWiG+jCk1XF7YC2zYMHesroI9vPYPtlzM-iLHWZATY1
AY67beRpMu8QgSNOJtq2OxW22kUwDHre9UzHUGQaTCgja0IAUhlHw1KII56zUTVZilVc2SoJ
54iSgkt4zd56TE6VRuQNRscBKyVi4cTaW4ZQJ9wpJZyqf0XDnpln8CpMQa60VjaZfXmQ03Q+
bMgSc4bmypg-F6O1sV7K9dMeYIXzN80ukCoepFii2Q63EezKhP+8x32f8d-L7BrYFmv5GojZ
QVDFDm2cdDcL0zSxLnkHN6MBJ1w0JCnKoO1J38XhZ7LQ7VlHjuYM6+npmoXBhGd9TPJWe6Xs
UUWpV+z2oqktE3jzBUVu-nul1Kmky6ky3PVwvUjVmcnJuLUAoWdBqNpsqFf3R5PjXLbnVd0B
fLCcLBbIyTU6eVa-PpVaQaRWi+zguych2uBySsuRJQQKhY5DsK3pi35BDQQShpqCMEiRHWmx
va2v3m1ooJdr10sU7cgYojQro7kgEDr05UAJbu6MD+fCAj3RBo66+QHrtgpvkiRAZAZrBldE
MntRYv3vbQ+WyEqgdmWwiDfkrHv0L7grpypJ4gCyHDeFNGX0318xCZg81AQNQuzuhBBKLxqx
UvUaX1Jc7+ioJT1m6YYBf3N2KMLK8bdngEEL9Ph9D1eiaM39qtFfnxvYuftqJKuWgLT2q-ij
hCLmuqIRA3zLM68ER00xxVeyHkbEDXaSrvU-TvMPzekjzC6aOqC4QDQAMRwNr1ihZEaCRoxk
r7k+SZXEjFJwkNAbVd4-3M5pmiapra0ak1QL4fOhHEOpgSKiv2F7ZS9ivPXfaf7nPrJGugVG
hkvurDoqih8+eQE8XF-tWIdt+vhzETpWqY4hv0yjo8YJoNbvOD+Y1SEm1IL7LRBlOIO1wZDY
N2yAQpF-dN5wOCtuau3U1Nqk7Qc8581Bwec6fHda5G8c10HMZ2dPCAbQoXoobBGUafoCN6ho
4d2g69qZyFn1SM6PbsZgK6ftdS32U74MsxMayvhcQN0HOf+4cg4qJHI3aVDEde-58dOXHF3M
rB+2zRVjUlrRd8qldavufYjjynQ8bTCfqRjXay3kCD1qv5Wl4mk15wRYmuqFQ5dqAZJUddSz
ReTiOYfYcnTcbHAhYHtKYs5u1BzBnjH15HPJrpSj9eMrNvDX4m--6edAoaob+-rQTxp1-lQn
4VCC2jb9RycDwXwyilkMKP4jC8OwJBFRXa7ZXPZLrsNLTiByIjVoPLpR6q0uEBuK0+xkxvOS
OdC2EnoazDvccT11xCPYBF72-fY-UmLON7hBMtBwP4OTe63bcLJLb5RSrOLFqxVD39q0-eet
bxppZGfY3yf9oWRn7+7fXUHitCyxEP0zVg2NQCrNi0kkcpjcDuWJHqZ9eSDQ8BHL66pozHCF
Kv0whWnX83el769mm3i0pcF5KmWupmq0NOavLe7kQ7pbJpoq9b9Y-531-pKI9dZVrtVFAhlx
XhKoCV-HW0Y6SZavL7QmqddcFnH-OsB35t3In3P8PMnKF+WwpANjhKkQPUO5vuujfw8nIph1
rj8j95HJ6CmnRQkz2sEKK0ojRd6x3FkCef9cARh89SY9qQWxgvFitEosvhc9VUqpfVl5feyY
3U5-2jVDJXpZc3CN1GVpGKgci-6AiKGIC818jMB6lm79oEd0ALzdxfLb38P4TPd9l8eucTP8
fEWAAOPEv+dgyxunpk3uBUio85UK6Vj+09c564H1eAyCPSxRypa7XI4c8sxjeNzz0p-9+kEI
++6+0+0XP9YWRnWuUo66++0H3U++1k+++3JCGJFH9pJIGIlH9Z--IwJMSqzPC-9zjo0zklkE
***** END OF BLOCK 2 *****



*XX3402-011488-090697--72--85-19075----------FP.ZIP--3-OF--3
s76B5QWCYvPqxWtCb4mRGpeXHfj33Pq0ZiW6XGE86dLMOzEXrbSu4J8G7HyuSvU3HbwYob+S
jrZkCDFmPr16nZhgq48LVymelLtdgJ49rFmmhmrqfgLShxWYlHsSgYy5rtwzKyvREhRvRQcw
tbo5KB7ryzHsNFQ7dmQbluQSzBlGIT16cpkUzsR24gWBX5ETZX-Rk9I82vURkgG6B-G7JUYU
aomAm4PQ3mWVVMOVoikWAzrbnx+YL8YA-BQ9mAFAN09l-FU31q8VGTPtAvB6IF-U806Nry25
j2NKLqI-IE3Ae59BYo+nxlo6LwMw8fys2QKfYP5c+QwmjjXg5Fqpjs0OkIL6gnuhWmGkU++i
wWkfvCl5UeBWe1x9o6hseW762MI6o-wP1U9Ps+CHQMkAOwcurYeoI9IVOypyNRjgAh+dld9h
AjhpoqtVhd9QNHIHOMEA-zquO22AL1NQF4SlcSVwa+nMNNudJ9-fbj9Yc6mUmVCH9PMYOsX0
aD0M4uix-vzWIfw-pSg-uMJq1kfRoCa-pJwWdUlBb+xCGtLIPXCdFRJ66n6cK8gmudQ47m9Z
4HQeorLx1NFZGTEfZ9zm-TV63Maz+8ZVNhaB0pCdMmXjdR43XjC32IpDWqKNf1GJkd5m5nfR
A8i2ZMc2HzcfsPgAYmxboCaqEdJbs7B67QypiCLd-MwW7txa0ZCMNmijPtFum3AkT-c7EUy1
mQJc-5y1jNRSeEOnlKyYBVWVhHWrpyBwAFfK8uY5HtFMhzNSO72xMaVUDJojRit-Jo4XN8PU
BHF8m2TTU-N4kltAAOWccWnYRUzqFwC7z2pgcb-DeLWsMnIEMrsjhgjSVQ60QWKlej41Wei1
xXyY3DovWWj4LRbaRx-kvt3bBFzTDRH1JYzoYZWW++8-8a8N0D0R0DsDA4YFjrSN8XGx3rtB
Imq2pjchbnz7k6EgtjBEmDjEZ2J7elAz2m8d6ZTPb9N9zzhDSl1ki0l4C6xYwj-iBihj2dA4
vS7apASYssfMrvgO51ELwomfP3pBEGIxJrbW4uYGi7k9DnRWzmqD-HBQFdUVPY7hgcD8qsft
GYPWQWupoTgnT2os5FxXN7xMxX7HelB8qlUOpzJKBTvepGhPtZALuswiylBl5mBngx7Q3bUE
N1rspoeRLPhFhePKxa5bFJorkALvAMCPiv5Rx8vsP+N5QFc7AgX7Bu6wTtNiWG-kfIKARYWA
utVolicFSAVUnqivefHQA0g1xPpYwiT6R6KDvOc42j32fMqMOsQJUc8xhZRpgcwm2+cgp0lD
1H4JCmLRnCPz19-xoXq4DlzUlCGn4LKmTFx1vyD9kSxUDOZEFElwOwaDs1KyKVFn-CIXclzO
ZF-Lj1eyolK89FieMLc7PtIFM27iw+xmrR0FFKzQBnaD6-DrIeBv18OtUTArw3K5p5ey+cyo
UeY+XR2mmW4cSo6NPrjSQIaM2g51dlP6rI0HznjCxizUT0xs30aT4r2fMdIhxgSMrL5NpK3E
EnxktatFCkkyAFVbMWPb2r3TIGwb13SenrBYceoDeQZUTBWlynRCkLMWFqEqXhSouwzSzMDS
FsZDYjW8V7th4jbIuOed5fl-xvc17q++xXfKoKjT8geBPGV0+kl509EGgsP5ODWBsCZZ2f1V
OCTOMMRRHWmAr00Cmm7oivchI9i3JPyhNfwh6FnbChlWPyTGtU8Nr0N+x2re5I9PlYrovIPl
zmswyBwaYaOjxSed3WNDDDocT-cu8xdEuGA8qEyNhaag8UspL4ONgjPToQEve8fWCjYBAnxI
WJWfYK4xFa07-YmS7G-61sqaHl8hHUKx1Xv-jdk-HlM5hV3NRRhHzkTDndr75peDPk6BA72A
DdR8jdExyNMz01SmzhAplIw63kMVyViuon9EIoiz0CxVA4RkDZxhD7cO8JyT7z9kTDu3UJSh
1N3p6ZR-kgzigSS3XQbx3q4+6+2r7dDHr6XWva+1qKa58za6kFKDh3VhjnNgD2jYYR5TGloy
qOI+hrhUEu7Gg04VzaGtez0uKxati7Q7QGtFKffayKVD9NcZVBMZDYlTl9K7OLtw1Gy6AE3R
X08xpv-rvbYS0AHPd9vojDtel04ZF2xBhZykARjorNmv3QXryUl8kXfrzTp6vHz776XtzC0U
LoMKjqGQlo+fuUZGdGIJZKPk32cz-7tFDmkJZfBgcH4IRMp9Wm+inT6YUBLsOym7ELRleQJT
bA9O56kO8xuTGVIzRIXdtawKafH3ud3ax1WabmCCmUhn9FHqhaIjWz+VxPaKGHb-NmbNCphB
wavaAstQn5uKJdledDRmXbcldICZsJ3YabPSnr-wJ3rUu8GXVkOCMmxoF7asOqpFdU-yb1ei
09YQuRjI3SNNivFJhWXs8uJ6n6p6+V3IBl8Ni-gkEjXfqi-JUn3bQ5fWZLMd3DMr4gZcParm
HiSgpKuGUXaPndgYTwuuvFpiTTBzv2A7DF+dyM9WzsoHbL+1PyoSRZHS71QwO16JZx2aJsqX
i56SLMm418Irb6SHDynwSGuX+4sIrIu9OzzrnHnQr6orXPnokgoMy+IODr6LwvDXbWBccpnf
7JVykJxMIgeKqhblKZnEgdfBO5UffnahHOhPcEEp80YR5IHHVPZ+PwhBvMNS6Aub3Rw9sEmQ
RLiPDdQNa2TQfCqRCfNjIF5wYmMHMGp1wIooSSNyS3xWs4i73ffrSHcz1CELV-1ht1wvuHL1
5em5jJj2GFJshChE8oiTelwZo-Hxl3G+9FksunV1vRsDl8fX1hZvexwxwCwFaTgDI2g-+VE+
3+++++++wVGx6U++++++++++++++++M++++++++++E+k+++++++++3JCGJFH9p-9+E6I++c+
+++++2EJjG8h8+UJ5++++-k++++8++++++++++2+6++++0E+++-GFI32HIIiJ3VII2g-+VE+
3++0++U+QopO6gxWMi0r2+++M06++-+++++++++++++U++++O++++3JCGJFH9o3AH2p7K0tI
I3JEGk203++I++6+0++7JJcWS2wjr9YF+++6Gk++2E+++++++++-+0++++-B2E++JIt7J3Aj
I37DEoJHImtEEJBEGk203++I++6+0+0XP9YWRnWuUo66++0H3U++1k+++++++++-+0+++++p
6k++JIt7J3AjJJF7H3AiI23HI2g3-U+++++3++I+7U2++8Ef++++++++
***** END OF BLOCK 3 *****


