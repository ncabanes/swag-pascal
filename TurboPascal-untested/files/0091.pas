program Delattr;

Uses Dos;


Procedure Usage;
Begin
     Writeln;
     Writeln('DELATTR (C) 1995 Scott Tunstall.');
     Writeln('Gets rid of those annoying undeletable files quickly !');
     Writeln;
     Writeln;
     Writeln('Usage:');
     Writeln;
     Writeln('DELATTR [-r] [-s] [-a] [-h] <FileSpec>');
     Writeln;
     Writeln('   -r will remove the READ ONLY attribute of a file,');
     Writeln('   -s will remove the SYSTEM attribute,');
     Writeln('   -a will remove the ARCHIVE attribute,');
     Writeln('   -h will remove the HIDDEN attribute.');
     Writeln;
     Writeln;
     Writeln('If you do not specify any attribute parameters, the');
     Writeln('program assumes you want to remove ALL of the');
     Writeln('specified file''s attributes. Or Something. :-) ');
     Writeln;
     Writeln('Use ATTRIB if all you want to do is ADD or VIEW ');
     Writeln('the attributes of file(s).');
     Writeln;
End;


Procedure BreakDownMask(TheMask: Word);
Begin
     If TheMask <>0 Then
        Begin
        If TheMask AND Archive = Archive Then
           Write('A ');
        If TheMask AND Directory = Directory Then
           Write('D ');
        If TheMask AND Hidden = Hidden Then
           Write('H ');
        If TheMask AND ReadOnly = ReadOnly Then
           Write('R ');
        If TheMask AND SysFile = SysFile Then
           Write('S ');
        If TheMask AND VolumeID = VolumeID Then
           Write('V ');
        End
     Else
         Write('NULL ');
End;


{
ReadOnly     │  $01
Hidden       │  $02
SysFile      │  $04
VolumeID     │  $08
Directory    │  $10
Archive      │  $20
AnyFile      │  $3F
}

Procedure DoAttrib;
Var Count: Byte;
    FileToChange: File;
    TempParam: string;
    CurrentByteMask: Word;
    ByteMask : Word;
    SearchRc: SearchRec;

Begin
     ByteMask:=0;
     If ParamCount = 1 Then
        ByteMask:=$2f
     Else
         For Count:=1 to (ParamCount -1) do
             Begin
             TempParam:=ParamStr(Count);
             If TempParam[1] = '-' Then
             Begin
                Case upcase(TempParam[2]) of
                'A': ByteMask:=ByteMask OR Archive;
                'D': ByteMask:=ByteMask OR Directory;
                'H': ByteMask:=ByteMask OR Hidden;
                'R': ByteMask:=ByteMask OR ReadOnly;
                'S': ByteMask:=ByteMask OR SysFile;
                'V': ByteMasK:=ByteMask OR VolumeID;
                Else
                    Begin
                    Write(chr(7));
                    Writeln(Paramstr(Count),' is not a valid switch !');
                    Halt;
                    End
                End;
                End
             Else
                 Begin
                 Write(chr(7));
                 Writeln(ParamStr(Count),' is not recognised as a switch !');
                 Halt;
                 End;
         End;

     FindFirst(ParamStr(ParamCount),AnyFile, SearchRc);
     If DosError =0 Then
        Begin
        While DosError = 0 do
              Begin
              Assign(FileToChange,SearchRc.Name);
              GetFAttr(FileToChange,CurrentByteMask);

              If CurrentByteMask <>0 Then
                 Begin

                 CurrentByteMask:=CurrentByteMask AND (65535 - ByteMask);
                 If ByteMask <>$2f Then
                    Begin
                    Write('Changed attributes of ',SearchRc.Name,' to ');
                    BreakDownMask(CurrentByteMask);
                    End
                 Else
                     Write('Removed all attributes from ',SearchRc.Name);

                 SetFAttr(FileToChange,CurrentByteMask);

                 If DosError = 0 Then
                    Write(' [OK].')
                 Else
                     Write('[Access Denied]');

                 Writeln;

                 FindNext(SearchRc);
                 End
              Else
                  Begin
                  Writeln(SearchRc.Name, ' has no file attributes [OK].');
                  FindNext(SearchRc);
              End;
        End;

        Writeln;
        Writeln('Operation complete.');
        Writeln;

        End
     Else
         Begin
         Writeln('Could not find the specified file(s) !');
         Writeln;
         End;
End;





Begin
     If ParamCount = 0 Then
        Usage
     Else
         Doattrib;
End.

