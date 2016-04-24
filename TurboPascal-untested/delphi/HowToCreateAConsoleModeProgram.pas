(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0247.PAS
  Description: How to create a console mode program
  Author: CHAMI
  Date: 05-30-97  18:17
*)


--------------------------------------------------------------------------------
You can write console mode (or command line) programs (programs that
usually does not use Windows graphical user interface) using Delphi.

(1) Create a new application using "File | New Application"
(2) Go to the "Project Manager" ("View | Project Manager")
(3) Remove the default form from the project (highlight the unit and press
DELETE -- do not save changes)
(4) Go to the "Project Source" ("View | Project Source")
(5) Edit your project source file:
(a) Remove code inside "begin" and "end." -- code that begins with
"Application."
(b) Replace the "Forms" unit in the "uses" section with "SysUtils."
(c) You do not need to load the resource file -- remove {$R *.RES}.
(d) Finally place "{$apptype console}" in a line by itself right after
the "program" statement.

(6) You just created a console mode program skeleton in Delphi. Now you
can add your code in between "begin" and "end." statements.

program console;

{$apptype console}

uses
  SysUtils;

begin
  // add your code here...
  WriteLn( 'hello, world!' );
end.



