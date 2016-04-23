
>Hello,
>I know I can use {$IFDEF WIN32} to check for Delphi 2,
>but how can I do conditional compilation for Delphi 3.
>
>
>Thanks in advance,
>Bruno Fierens
Use VER80 for Delphi1, VER90 for Delphi2, VER100 for Delphi3, as:

 {$ifdef VER80}
   Showmessage('Delphi 1.0');
 {$endif}
 {$ifdef VER90}
   Showmessage('Delphi 2.0');
 {$endif}
 {$ifdef VER100}
   Showmessage('Delphi 3.0');
 {$endif}
