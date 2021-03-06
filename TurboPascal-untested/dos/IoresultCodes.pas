(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0051.PAS
  Description: IOResult Codes
  Author: DAVID ADAMSON
  Date: 05-25-94  08:04
*)

 
unit CustExit;
(*--------------------------------------------------------------------------
     Original source code by David Drzyzga, FidoNet 1:2619/209, SysOp of
         =>> CUTTER JOHN'S <<= (516) 234-1737 [HST/DS/v32bis/v32ter]
                  Offered to the public domain 04-04-1994
---------------------------------------------------------------------------*)
interface
implementation
uses
  Crt;
var
  ExitAddress : pointer;
{$F+}
procedure ErrorExit;
{$F-}
begin
  if ErrorAddr <> Nil then begin
    NormVideo;
    ClrScr;
    Writeln('Program terminated with error number ', ExitCode:3, '.');
      case ExitCode of
        1..18     : write( ^G + 'DOS ERROR: ');
        100..106  : write( ^G + 'I/O ERROR: ');
        150..162,
        200..216  : write( ^G + 'CRITICAL ERROR: ');
      end;
      Case ExitCode of
          1 : Writeln('Invalid function number.');
          2 : Writeln('File not found.');
          3 : Writeln('Path not found.');
          4 : Writeln('Too many open files.');
          5 : Writeln('File access denied.');
          6 : Writeln('Invalid file handle.');
         12 : Writeln('Invalid file access code.');
         15 : Writeln('Invalid drive number.');
         16 : Writeln('Cannot remove current directory.');
         17 : Writeln('Cannot rename across drives.');
         18 : Writeln('No More Files.');
        100 : Writeln('Disk read error.');
        101 : Writeln('Disk write error.');
        102 : Writeln('File not assigned.');
        103 : Writeln('File not open.');
        104 : Writeln('File not open for input.');
        105 : Writeln('File not open for output.');
        106 : Writeln('Invalid numeric format.');
        150 : Writeln('Disk is write-protected.');
        151 : Writeln('Unknown unit.');
        152 : Writeln('Drive not ready.');
        153 : Writeln('Unknown command.');
        154 : Writeln('CRC error in data.');
        155 : Writeln('Bad drive request structure length.');
        156 : Writeln('Disk seek error.');
        157 : Writeln('Unknown media type.');
        158 : Writeln('Sector not found.');
        159 : Writeln('Printer out of paper.');
        160 : Writeln('Device write fault.');
        161 : Writeln('Device read fault.');
        162 : Writeln('Hardware failure.');
        200 : Writeln('Division by zero.');
        201 : Writeln('Range check error.');
        202 : Writeln('Stack overflow error.');
        203 : Writeln('Heap overflow error.');
        204 : Writeln('Invalid pointer operation.');
        205 : Writeln('Floating point overflow.');
        206 : Writeln('Floating point underflow.');
        207 : Writeln('Invalid floating point operation.');
        208 : Writeln('Overlay manager not installed.');
        209 : Writeln('Overlay file read error.');
        210 : Writeln('Object not initialized.');
        211 : Writeln('Call to abstract method.');
        212 : Writeln('Stream registration error.');
        213 : Writeln('Collection index out of range.');
        214 : Writeln('Collection overflow error.');
        215 : Writeln('Arithmetic overflow error.');
        216 : Writeln('General Protection fault.');
      else
        Writeln( ^G + 'Unknown Error.');
      end; { Case }
    ErrorAddr := Nil;
  end;
  Exitproc := ExitAddress;   { Restore original exit address }
end; { ErrorExit }
begin
  ExitAddress := ExitProc;   { Save original exit address    }
  ExitProc    := @ErrorExit; { Install custom exit procedure }
end. { Unit CustExit }

