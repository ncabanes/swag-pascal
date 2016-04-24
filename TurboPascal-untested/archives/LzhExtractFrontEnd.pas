(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0039.PAS
  Description: LZH Extract Front End
  Author: SCOTT TUNSTALL
  Date: 05-31-96  09:17
*)

{
INSTALLER

Param 1 : Path to where .LZH files reside
      2 : Path to install to.
      3 (optional) : Where LHA.EXE program resides,
        default is C:\DOS

All of the LZH files in the directory shall be unpacked to
the install directory.
}

Uses CRT, DOS;

Var  DirInfo: SearchRec;
     Archive_Loc : char;
     LhaPath: pathstr;
     LZH_Count: byte;
     LZH_Name: string[8];


{$M 4000,0,0}

Begin
     If ParamCount in[2,3] Then
     Begin
        TextBackground(Blue);
        TextColor(White);
        ClrScr;

        TextBackground(LightGray);
        TextColor(Black);

        ClrEol;
        Writeln('LHArc INSTALLER (C) 1994 Scott Tunstall. All rights reserved.');
        Writeln;

        TextBackground(Blue);
        TextColor(LightGray);

        Writeln('Installing .LZH files FROM : ', ParamStr(1));
        Writeln('                      TO   : ', ParamStr(2));


        { O.K. That's the end of the niceness. }


        If ParamCount=3 Then
           Begin
           LhaPath:=Paramstr(3);
           If LhaPath[Length(LHAPath)]<>'\' Then
              LhaPath:=LhaPath+'\';
           End
        Else
            LhaPath:='C:';


        Writeln;
        Writeln;
        Writeln('Looking for LHA.EXE in directory ',LHAPath,'..');

        If Fsearch('LHA.EXE',LHAPath)<>'' Then
           Begin
           LZH_Count:=0;
           LZH_Name:=ParamStr(1)+'*.LZH';

           FindFirst(LZH_Name,AnyFile,DirInfo);

           If DosError <>0 Then
              Writeln('Could not find any .LZH files ! Check your SOURCE PATH !')
           Else
           Begin
               While (DosError = 0) do
               Begin
                  SwapVectors;
                  Exec(LhaPath+'LHA.EXE','e '+ParamStr(1)+DirInfo.Name+' '+ParamStr(2));
                  SwapVectors;

                  If DosError = 0  Then
                     Begin
                     Inc(LZH_Count);
                     FindNext(DirInfo);
                     End
                  Else
                      Begin
                      Writeln;
                      Writeln('A DOS error has occurred!. Program execution halted.');
                  End;

               End;
               Writeln;
               Writeln;
               Writeln(LZH_Count,' archive(s) transferred. All done!');
           End;
           End
        Else
            Begin
            Writeln;
            Writeln('Could not find LHA.EXE, the Main Archival Program.');
            Writeln('Please check that it is in the appropriate directory!');
            Writeln;
        End;

     End
Else
    Begin
    Writeln;
    Writeln('LZH UNPACKER  (C) 1994 SCOTT "TOODY" TUNSTALL');
    Writeln;
    Writeln;
    Writeln('Usage :');
    Writeln;
    Writeln('DECRUNCH <src file path> <dest path> [path to LHA program]');
    Writeln;
    Writeln('i.e. To decrunch all .LZH files in directory A:\WORK');
    Writeln('to directory C:\GAMES you would type :');
    Writeln;
    Writeln('DECRUNCH A:\ C:\GAMES\   <- REMEMBER THE BACKSLASH "\" !');
    Writeln;
    Writeln;
    Writeln('Finally, the last parameter is the PATH to where the LHA');
    Writeln('program resides on disk. It should ALWAYS be on a fixed');
    Writeln('disk (hard disk) system where it can be continually accessed.');
    Writeln('The DEFAULT PATH is C:, which means this param is optional !');
    Writeln;
    Writeln;
    Writeln('Finally, hello to all the guys at Lauder College who love to');
    Writeln('go out and get STEAMIN!.');
    Writeln;
    End;
End.


