(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0037.PAS
  Description: Error Code Library
  Author: ALEX RUSSKIH
  Date: 11-22-95  13:30
*)

$A-,B-,D-,E-,F+,G-,I-,L-,N-,O+,P-,R-,S-,V-,X-}
Unit RunTime;
Interface

Implementation

Procedure WriteErrormessage;
Const
  RTError = 'Run-Time Error ';
Begin
  Writeln;
  Case Exitcode of
      1 : Writeln(RTError,ExitCode,': ','Invalid function number.');
      2 : Writeln(RTError,ExitCode,': ','File not found.');
      3 : Writeln(RTError,ExitCode,': ','Path not found.');
      4 : Writeln(RTError,ExitCode,': ','Too many open files.');
      5 : Writeln(RTError,ExitCode,': ','File access denied.');
      6 : Writeln(RTError,ExitCode,': ','Invalid file handle.');
     12 : Writeln(RTError,ExitCode,': ','Invalid file access code.');
     15 : Writeln(RTError,ExitCode,': ','Invalid drive number.');
     16 : Writeln(RTError,ExitCode,': ','Cannot remove current directory.');
     17 : Writeln(RTError,ExitCode,': ','Cannot rename across drives.');
     18 : Writeln(RTError,ExitCode,': ','No more files.');
    100 : Writeln(RTError,ExitCode,': ','Disk read error.');
    101 : Writeln(RTError,ExitCode,': ','Disk write error.');
    102 : Writeln(RTError,ExitCode,': ','File not assigned.');
    103 : Writeln(RTError,ExitCode,': ','File not open.');
    104 : Writeln(RTError,ExitCode,': ','File not open for input.');
    105 : Writeln(RTError,ExitCode,': ','File not open for output.');
    106 : Writeln(RTError,ExitCode,': ','Invalid numeric format.');
    150 : Writeln(RTError,ExitCode,': ','Disk is write-protected.');
    151 : Writeln(RTError,ExitCode,': ','Bad drive request struct length.');
    152 : Writeln(RTError,ExitCode,': ','Drive not ready.');
    154 : Writeln(RTError,ExitCode,': ','CRC error in data.');
    156 : Writeln(RTError,ExitCode,': ','Disk seek error.');
    157 : Writeln(RTError,ExitCode,': ','Unknown media type.');
    158 : Writeln(RTError,ExitCode,': ','Sector Not Found.');
    159 : Writeln(RTError,ExitCode,': ','Printer out of paper.');
    160 : Writeln(RTError,ExitCode,': ','Device write fault.');
    161 : Writeln(RTError,ExitCode,': ','Device read fault.');
    162 : Writeln(RTError,ExitCode,': ','Hardware failure.');
    200 : Writeln(RTError,ExitCode,': ','Division by zero.');
    201 : Writeln(RTError,ExitCode,': ','Range check error.');
    202 : Writeln(RTError,ExitCode,': ','Stack overflow error.');
    203 : Writeln(RTError,ExitCode,': ','Heap overflow error.');
    204 : Writeln(RTError,ExitCode,': ','Invalid pointer operation.');
    205 : Writeln(RTError,ExitCode,': ','Floating point overflow.');
    206 : Writeln(RTError,ExitCode,': ','Floating point underflow.');
    207 : Writeln(RTError,ExitCode,': ','Invalid floating point operation.');
    208 : Writeln(RTError,ExitCode,': ','Overlay manager not installed.');
    209 : Writeln(RTError,ExitCode,': ','Overlay file read error.');
    210 : Writeln(RTError,ExitCode,': ','Object not initialized.');
    211 : Writeln(RTError,ExitCode,': ','Call to abstract method.');
    212 : Writeln(RTError,ExitCode,': ','Stream registration error.');
    213 : Writeln(RTError,ExitCode,': ','Collection index out of range.');
    214 : Writeln(RTError,ExitCode,': ','Collection overflow error.');
    215 : Writeln(RTError,ExitCode,': ','Arithmetic overflow error.');
    216 : Writeln(RTError,ExitCode,': ','General Protection fault.');
  End; {case}
  ErrorAddr := Nil; {This can be Nil, if so you borland IDE will not
                     display the Runtime Error Message}
End;

Procedure InitError;
Begin
  ExitProc := @WriteErrormessage;
End;

Begin
  InitError;
End.

