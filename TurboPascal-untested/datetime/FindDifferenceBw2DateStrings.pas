(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0055.PAS
  Description: Find Difference b/w 2 Date Strings
  Author: SCOTT STONE
  Date: 05-26-95  23:30
*)

{From: Scott Stone <Scott.Stone@m.cc.utah.edu> }

Procedure CompTimes(t1,t2 : string);
Var
  h1,h2,m1,m2,s1,s2 : string;
  x0,x1,x2,x3,x4,x5,sec0,sec1 : integer;
  err : integer;
  timediff : integer;
Begin
  h1:=t1[1]+t1[2];
  h2:=t2[1]+t2[2];
  m1:=t1[4]+t1[5];
  m2:=t2[4]+t2[5];
  s1:=t1[7]+t1[8];
  s2:=t2[7]+t2[8];
  val(h1,x0,err);
  val(h2,x1,err);
  val(m1,x2,err);
  val(m2,x3,err);
  val(s1,x4,err);
  val(s2,x5,err);
  sec0:=((3600*x0)+(60*x2)+(x4));
  sec1:=((3600*x1)+(60*x3)+(x5));
  timediff:=abs(sec1-sec0);
  writeln('Time Difference is ',timediff,' seconds.');
End;

begin
  CompTimes('11:23:31','16:32:21');
end.
