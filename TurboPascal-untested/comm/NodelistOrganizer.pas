(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0072.PAS
  Description: Nodelist Organizer
  Author: PETER BEEFTINK
  Date: 11-26-94  05:05
*)

{
For those who are active in other nets than fidonet, and who regularly get a
new small nodelist as an update, this little program gets rid of all but the
latest nodelists, allowing the whole process to be handled by a simple batch
file.Easily adaptable to the names of your nodelists, see last lines.
}

Program clean;
{$M 16384,80000,80000}

Uses Dos,Crt;

TYPE
  Line     = string[80];
  Lines    = ARRAY[1..100] OF Line;
  LinesP   = ^Lines;

var
  Dirbuf   : LinesP;
  Index,Number,i,j:integer;
  dirinfo:SearchRec;
  filetime:array[1..100] of longint;
  latest:longint;
  f:file;

Procedure remove(s:string);

Begin
New(Dirbuf);
Number:=0;
  FindFirst(s+'.*', Anyfile, DirInfo);
    while DosError = 0 do
     begin
      if (Dirinfo.name[1] <> '.') AND (dirinfo.attr<>16) then
          {attribute 16 would be directory file}
            begin
      inc(Number);
      Dirbuf^[Number]:=Dirinfo.name;
      filetime[Number]:=Dirinfo.time;
            end;

      FindNext(DirInfo);
     end;

if Number<2 then {only one nodelist.nnn found, do nothing.}
            Begin
            dispose(dirbuf);
            exit;
            End;

latest:=filetime[1]; {you have to start somewhere}

for i:=1 to Number do if filetime[i]>=latest then
                   Begin
                   latest:=filetime[i];
                   Index:=i;
                   End;
{Index now points to the newest file, so this is the one
 that we should NOT erase!}
for i:=1 to Number do if i<>Index then
 Begin
  assign(f,DIRBUF^[I]);
  erase(f);
 End;

Dispose(Dirbuf);

end;

Begin {OF MAIN PROGRAM}
remove('TATTLE');
remove('22NET-NL');
remove('NODELIST');
End.

