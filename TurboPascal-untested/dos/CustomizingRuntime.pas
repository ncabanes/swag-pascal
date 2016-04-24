(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0055.PAS
  Description: Customizing Run-Time!
  Author: THOMAS SKOGESTAD
  Date: 05-25-94  08:22
*)


Unit SHOWREM;
{Show Runtime Error Messages}
{Written by C. Enders (1994)}
{Usage : Write the next line in your Main pascal program.
 Uses Showrem;
 This unit provides the meaning of the error codes while you are running
 your pascal programs. If other users are using your program they get
 frustrated if they see a message like
   Runtime error 200: at 1234:abcd.
 This unit let your program show error messages like :
   Runtime Error 200: Division by zero.
 Use of this program is free and no royalties must be paid if you use this
 routines in your (commercial) programs (perhaps some credits like thanks
 to ...).
 If you need any help e-mail at C.W.G.M.ENDERS@KUB.NL
}

InterFace

Implementation

Procedure WriteErrormessage;
Begin
  Writeln;
  Case Exitcode of
      1 : Writeln('Runtime Error ',exitcode,': ','Invalid function number.');
      2 : Writeln('Runtime Error ',exitcode,': ','File not found.');
      3 : Writeln('Runtime Error ',exitcode,': ','Path not found.');
      4 : Writeln('Runtime Error ',exitcode,': ','Too many open files.');
      5 : Writeln('Runtime Error ',exitcode,': ','File access denied.');
      6 : Writeln('Runtime Error ',exitcode,': ','Invalid file handle.');
     12 : Writeln('Runtime Error ',exitcode,': ','Invalid file access code.');
     15 : Writeln('Runtime Error ',exitcode,': ','Invalid drive number.');
     16 : Writeln('Runtime Error ',exitcode,': ','Cannot remove current
directory.');
     17 : Writeln('Runtime Error ',exitcode,': ','Cannot rename across
drives.');
     18 : Writeln('Runtime Error ',exitcode,': ','No more files.');
    100 : Writeln('Runtime Error ',exitcode,': ','Disk read error.');
    101 : Writeln('Runtime Error ',exitcode,': ','Disk write error.');
    102 : Writeln('Runtime Error ',exitcode,': ','File not assigned.');
    103 : Writeln('Runtime Error ',exitcode,': ','File not open.');
    104 : Writeln('Runtime Error ',exitcode,': ','File not open for input.');
    105 : Writeln('Runtime Error ',exitcode,': ','File not open for output.');
    106 : Writeln('Runtime Error ',exitcode,': ','Invalid numeric format.');
    150 : Writeln('Runtime Error ',exitcode,': ','Disk is write-protected.');
    151 : Writeln('Runtime Error ',exitcode,': ','Bad drive request struct
length.');
    152 : Writeln('Runtime Error ',exitcode,': ','Drive not ready.');
    154 : Writeln('Runtime Error ',exitcode,': ','CRC error in data.');
    156 : Writeln('Runtime Error ',exitcode,': ','Disk seek error.');
    157 : Writeln('Runtime Error ',exitcode,': ','Unknown media type.');
    158 : Writeln('Runtime Error ',exitcode,': ','Sector Not Found.');
    159 : Writeln('Runtime Error ',exitcode,': ','Printer out of paper.');
    160 : Writeln('Runtime Error ',exitcode,': ','Device write fault.');
    161 : Writeln('Runtime Error ',exitcode,': ','Device read fault.');
    162 : Writeln('Runtime Error ',exitcode,': ','Hardware failure.');
    200 : Writeln('Runtime Error ',exitcode,': ','Division by zero.');
    201 : Writeln('Runtime Error ',exitcode,': ','Range check error.');
    202 : Writeln('Runtime Error ',exitcode,': ','Stack overflow error.');
    203 : Writeln('Runtime Error ',exitcode,': ','Heap overflow error.');
    204 : Writeln('Runtime Error ',exitcode,': ','Invalid pointer operation.');
    205 : Writeln('Runtime Error ',exitcode,': ','Floating point overflow.');
    206 : Writeln('Runtime Error ',exitcode,': ','Floating point underflow.');
    207 : Writeln('Runtime Error ',exitcode,': ','Invalid floating point operation.');
    208 : Writeln('Runtime Error ',exitcode,': ','Overlay manager not installed.');
    209 : Writeln('Runtime Error ',exitcode,': ','Overlay file read error.');
    210 : Writeln('Runtime Error ',exitcode,': ','Object not initialized.');
    211 : Writeln('Runtime Error ',exitcode,': ','Call to abstract method.');
    212 : Writeln('Runtime Error ',exitcode,': ','Stream registration error.');
    213 : Writeln('Runtime Error ',exitcode,': ','Collection index out of range.');
    214 : Writeln('Runtime Error ',exitcode,': ','Collection overflow error.');
    215 : Writeln('Runtime Error ',exitcode,': ','Arithmetic overflow error.');
    216 : Writeln('Runtime Error ',exitcode,': ','General Protection fault.');
  End; {case}
  ErrorAddr := Nil; {This can be Nil, if so you borland IDE will not
                     display the Runtime Error Message}
End; {WriteErrorMessage}

Procedure InitError;
Begin
  ExitProc := @WriteErrormessage;
End;{InitError}

Begin{Body}
  InitError;
End.

