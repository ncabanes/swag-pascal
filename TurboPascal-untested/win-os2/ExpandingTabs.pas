(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0069.PAS
  Description: Expanding Tabs
  Author: MICHAEL TEATOR
  Date: 05-27-95  10:37
*)


program ExpandTabsWindows;

{
    Public domain by Michael Teator
    February 1995
}

uses
    WinCrt;

const
    Space:  byte =  32;

type
    TextFile =  file of byte;

var
    OutputFile, InputFile:  TextFile;
    OutputName, InputName:  string;
    t, Pos, TabSpace, ch:   byte;

begin

    writeln ('Tab Epander 1.0  Public Domain by Michael Teator');
    writeln;
    write ('Input File: ');
    readln (InputName);

    write ('Output File: ');
    readln (OutputName);
    if InputName = OutputName then begin
        writeln ('Output file cannot be the same as the input file.');
        halt (1)
    end;

    write ('Spaces between tabs: ');
    readln (TabSpace);

    if TabSpace < 1 then TabSpace := 1;

    assign (InputFile, InputName);
    assign (OutputFile, OutputName);
    reset (InputFile);
    rewrite (OutputFile);

    Pos := 0;
    while not eof(InputFile) do begin
        read (InputFile, ch);
        case ch of
            9:      for t := 1 to (TabSpace - (Pos mod TabSpace)) do begin
                        write (OutputFile, Space);
                        inc (Pos)
                    end;
            13, 10: begin
                        Pos := 0;
                        write (OutputFile, ch)
                    end;
        else    begin
                    write (OutputFile, ch);
                    inc (Pos)
                end;
        end; { case }
    end; { while }

    close (InputFile);
    close (OutputFile);
    writeln ('Done.')

end.
