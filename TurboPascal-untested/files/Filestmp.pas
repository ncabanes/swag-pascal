(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0005.PAS
  Description: FILESTMP.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:46
*)

{ Example For GetFTime, PackTime,
  SetFTime, and UnpackTime }

Uses Dos;
Var
  f: Text;
  h, m, s, hund : Word; { For GetTime}
  ftime : LongInt; { For Get/SetFTime}
  dt : DateTime; { For Pack/UnpackTime}
Function LeadingZero(w : Word) : String;
Var
  s : String;
begin
  Str(w:0,s);
  if Length(s) = 1 then
    s := '0' + s;
  LeadingZero := s;
end;
begin
  Assign(f, 'RECURSEP.PAS');
  GetTime(h,m,s,hund);
  ReWrite(f); { Create new File }
  GetFTime(f,ftime); { Get creation time }
  WriteLn('File created at ',LeadingZero(h),
          ':',LeadingZero(m),':',
          LeadingZero(s));
  UnpackTime(ftime,dt);
  With dt do
    begin
      WriteLn('File timestamp is ',
              LeadingZero(hour),':',
              LeadingZero(min),':',
              LeadingZero(sec));
      hour := 0;
      min := 1;
      sec := 0;
      PackTime(dt,ftime);
      WriteLn('Setting File timestamp ',
              'to one minute after midnight');
      Reset(f); { Reopen File For reading }
      { (otherwise, close will update time) }
      SetFTime(f,ftime);
    end;
  Close(f);   { Close File }
end.

