
  {NEWCMD.PAS}
{$M $4000,0,0 }   { 16K stack, no heap }

PROGRAM RunDos( input, output, ProgramFileInstance );

USES Dos,CRT;

TYPE
    ProgramRecordType = RECORD
                              ProgramName   : string;
                              CmdLine       : string;
                              BootCount     : integer;
                              ExecuteTarget : integer;
                        END; { of record ProgramRecordType }

    ProgramFile = FILE OF ProgramRecordType;

VAR
   MyProgramRecord : ProgramRecordType;
   ProgramFileInstance : ProgramFile;
   I,LastParam : word;

{ ******************************************************************* }

Function EmptyFile ( VAR MyFile : ProgramFile ) : Boolean;
    VAR
       MyFileSize : integer;

    BEGIN
       MyFileSize := FileSize( MyFile );

       if MyFileSize = 0 then
          BEGIN
               EmptyFile := true;
          END;

    END; { End of function EmptyFile }

{ ******************************************************************* }

PROCEDURE FirstTimeInit( VAR ProgramRecord : ProgramRecordType );

    BEGIN
         writeln('NEWCOMMAND Version 95.1');
         writeln;
         writeln('This program is Public Domain software');
         writeln;
         writeln('Enter program to execute? ');
         writeln('Use the full path including extension');
         writeln('Example:  c:\dos\myfile.exe');
         readLn(ProgramRecord.ProgramName);

         writeln('Command line options to pass to ', ProgramRecord.ProgramName );
         writeln('Example: c: /U  ');
         readLn(ProgramRecord.CmdLine);

         write('Execute program after how many computer startups?: ');
         readln( ProgramRecord.ExecuteTarget );

         ProgramRecord.BootCount := 0;

    END; { of procedure FirstTimeInit }

{ *******************************************************************  }

Procedure ExecuteProgram( VAR MyFile : ProgramFile; VAR ProgramRecord : ProgramRecordType );

VAR
   I : integer;
   J : integer;
    BEGIN
         writeLn('About to Execute: ', ProgramRecord.ProgramName ,
                   ProgramRecord.CmdLine );
         writeln;
         write('Press any key to halt...');
         for I := 1 to 10 do
             begin
               delay( 1000  );
               write('.');
               if KeyPressed then
                  begin
                       close( MyFile );
                       halt(0);
                  end;
             end;

         writeln;
         writeln;

         SwapVectors;
         Exec( ProgramRecord.ProgramName, ProgramRecord.CmdLine );
         SwapVectors;

         writeLn('...back from Executing ');

             if DosError <> 0 then{ Error? }
                writeLn('Dos error #', DosError)
             else
                 writeLn('Exec successful. ','Child process exit code = ',
                      DosExitCode);
     END; { of procedure ExecuteProgram }

{ ******************************************************************** }

PROCEDURE PrintDialog;
    BEGIN
         writeln('NEWCOMMAND Version 95.1');
         writeln('written by Andy onlin@aol.com');
         writeln('This program is public domain software');
         writeln;
         writeln('NEWCOMMAND Version 95.1 is a DOS batch scheduling program.');
         writeln('Its purpose is to launch the execution of other programs from your autoexec.bat');
         writeln('file. SYNTAX: newcmd2 [ drive:path filename1...drive:path filenameN ]');
         writeln('A computer running DOS 3.3 or later is all that you need to use NEWCOMMAND.');
         writeln('To use this program:');
         writeln(' 1.   copy newcmd2.exe to your hard drive');
         writeln(' 2.   type its full path in the last line of autoexec.bat');
         writeln('      with descriptive file(s) argument(s)');
         writeln('          example: c:\dos\newcmd.exe c:\mydefrag.rec c:\myscan.rec');
         writeln(' 3.   the first time newcmd.exe runs it will prompt for');
         writeln('      the program you wish to schedule, then any command line options');
         writeln('      that you can use with the newly schedule program.  Last you need');
         writeln('      to enter how many times you will start the computer');
         writeln('      before newcmd2.exe launches the program you specified above.');
         writeln;
         writeln('The specified program will launch at the specified interval until you remove');
         writeln('the record file from the command line.');

    END; { of procedure PrintDialog }

{ ******************************************************************* }

BEGIN
     LastParam := ParamCount;

     if LastParam = 0 then
        PrintDialog
     else
         BEGIN
              for I := 1 to LastParam do
                  BEGIN
                       assign( ProgramFileInstance, ParamStr(I));
                       {$I-}
                       Reset(ProgramFileInstance);
                       {$I+}
                       if IOResult <> 0 then
                           rewrite( ProgramFileInstance );

                       if  EmptyFile( ProgramFileInstance ) = true  then
                           BEGIN
                                FirstTimeInit( MyProgramRecord );
                                write ( ProgramFileInstance, MyProgramRecord );
                           END;

                       seek( ProgramFileInstance, 0 );

                       read( ProgramFileInstance, MyProgramRecord );

                       if MyProgramRecord.BootCount >= MyProgramRecord.ExecuteTarget then
                          BEGIN
                               ExecuteProgram( ProgramFileInstance, MyProgramRecord );
                               MyProgramRecord.BootCount := 1;
                          END
                       ELSE
                           MyProgramRecord.BootCount := MyProgramRecord.BootCount + 1;

                       seek( ProgramFileInstance, 0 );
                       write( ProgramFileInstance, MyProgramRecord );
                       close ( ProgramFileInstance );
                  END;
         END;
END.
