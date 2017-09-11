(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0004.PAS
  Description: FILEDLG1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{
> In particular a collection of Filenames in the current directory sorted
> and the ability to scroll these Strings vertically.

CCompiled and tested under BP7. All Units are standard Units available with
both TP6 and BP7 packages
}

Program ListDirProg;
Uses
  Objects,App,StdDlg;

Type
  MyApp = Object(TApplication)
            Procedure run; Virtual;
          end;

Procedure myapp.run;
Var
  p : PFileDialog;
begin
  New(P,init('*.*','Directory Listing', '~S~earch Specifier', fdokbutton,0));
  if p <> nil then
  begin
    execview(p);
    dispose(p,done);
  end;
end;

Var
  a : myapp;

begin
  a.init;
  a.run;
  a.done;
end.
