(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0010.PAS
  Description: MISCFUNC.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:51
*)

Unit MiscFunc;

{ MiscFunc version 1.0 Scott D. Ramsay }

{   This is my misc. Function Unit.  Some of the Functions have      }
{ nothing to do With games design but, my Units use it so ...        }
{   MiscFunc.pas is free.  Go crazy.                                 }
{   I've been writing comments to these Units all night.  Since you  }
{ have the source to this, I'll let you figure out what each one     }
{ does.   }

Interface

Function strint(s:String):LongInt;
Function intstr(l:LongInt):String;
Function ups(s:String):String;
Function st(h:LongInt):String;
Function Compare(s1,s2:String):Boolean;
Function dtcmp(Var s1,s2;size:Word):Boolean;
Function lz(i,w:LongInt):String;
Function vl(h:String):LongInt;
Function spaces(h:Integer):String;
Function repstr(h:Integer;ch:Char):String;
Function anything(s:String):Boolean;
Function exist(f:String):Boolean;
Function errmsg(n:Integer):String;
Function turboerror(errorcode:Integer) : String;
Procedure funpad(Var s:String);
Procedure unpad(Var s:String);
Procedure munpad(Var s:String;b:Byte);
Function fpad(s:String;h:Integer):String;
Procedure pad(Var s:String;h:Integer);
Procedure fix(Var s:String;h:String);
Procedure fixh(Var s:String);
Function range(x,y,x1,y1,x2,y2:Integer) : Boolean;
Function between(x,x1,x2:Integer):Boolean;

Implementation


Function range(x,y,x1,y1,x2,y2:Integer) : Boolean;
{ returns True if (x,y) is in the rectangular region (x1,y1,x2,y2) }
begin
  range := ((x>=x1) and (x<=x2) and (y>=y1) and (y<=y2));
end;


Procedure fix(Var s:String;h:String);
begin
  if pos('.',s)=0
    then s := s+h;
end;


Procedure fixh(Var s:String);
Var
  d : Integer;
begin
  For d := 1 to length(s) do
    if s[d]<#32
      then s[d] := ' ';
  For d := length(s)+1 to 255 do
    s[d] := ' ';
end;


Function strint(s:String):LongInt;
Var
  l : LongInt;
begin
  move(s[1],l,sizeof(l));
  strint := l;
end;


Function intstr(l:LongInt):String;
Var
  s : String;
begin
  move(l,s[1],sizeof(l));
  s[0] := #4;
  intstr := s;
end;


Function ups(s:String):String;
Var
  d : Integer;
begin
  For d := 1 to length(s) do
    s[d] := upCase(s[d]);
  ups := s;
end;


Function st(h:LongInt):String;
Var
  s : String;
begin
  str(h,s);
  st := s;
end;


Function Compare(s1,s2:String):Boolean;
Var
  d : Byte;
  e : Boolean;
begin
  e := True;
  For d := 1 to length(s1) do
    if upCase(s1[d])<>upCase(s2[d])
      then e := False;
  Compare := e;
end;


Function dtcmp(Var s1,s2;size:Word):Boolean;
Var
  d : Word;
  e : Boolean;
begin
  e := True;
  d := size;
  While (d>0) and e do
    begin
      dec(d);
      e := (mem[seg(s1):ofs(s1)+d]=mem[seg(s2):ofs(s2)+d]);
    end;
  dtcmp := e;
end;


Function lz(i,w:LongInt):String;
Var
  d : LongInt;
  s : String;
begin
  str(i,s);
  For d := length(s) to w-1 do
    s := concat('0',s);
  lz := s;
end;


Function vl(h:String):LongInt;
Var
  d : LongInt;
  e : Integer;
begin
  val(h,d,e);
  vl := d;
end;


Function spaces(h:Integer):String;
Var
  s : String;
begin
  s := '';
  While h>0 do
    begin
      dec(h);
      s := concat(s,' ');
    end;
  spaces := s;
end;


Function repstr(h:Integer;ch:Char):String;
Var
  s : String;
begin
  s := '';
  While h>0 do
    begin
      dec(h);
      s := s+ch;
    end;
  repstr := s;
end;


Function anything(s:String):Boolean;
Var
  d : Integer;
  h : Boolean;
begin
  if length(s)=0
    then
      begin
        anything := False;
        Exit;
      end;
  h := False;
  For d := 1 to length(s) do
    if s[d]>#32
      then h := True;
  anything := h;
end;


Function exist(f:String):Boolean;
Var
  fil : File;
begin
  if f=''
    then
      begin
        exist := False;
        Exit;
      end;
  assign(fil,f);
 {$i- }
  reset(fil);
  close(fil);
 {$i+ }
  exist := (ioresult=0);
end;


Function errmsg(n:Integer):String;
begin
   Case n of
      -1 : errmsg := '';
      -2 : errmsg := 'Error reading data File';
      -3 : errmsg := '';
      -4 : errmsg := 'equal current data File name';
     150 : errmsg := 'Disk is Write protected';
     152 : errmsg := 'Drive is not ready';
     156 : errmsg := 'Disk seek error';
     158 : errmsg := 'Sector not found';
     159 : errmsg := 'Out of Paper';
     160 : errmsg := 'Error writing to Printer';
    1000 : errmsg := 'Record too large';
    1001 : errmsg := 'Record too small';
    1002 : errmsg := 'Key too large';
    1003 : errmsg := 'Record size mismatch';
    1004 : errmsg := 'Key size mismatch';
    1005 : errmsg := 'Memory overflow';
     else errmsg := 'Error result #'+st(n);
   end;
end;


Function turboerror(errorcode:Integer) : String;
begin
  Case errorcode of
      1: turboerror := 'Invalid Dos Function code';
      2: turboerror := 'File not found';
      3: turboerror := 'Path not found';
      4: turboerror := 'too many open Files';
      5: turboerror := 'File access denied';
      6: turboerror := 'Invalid File handle';
      8: turboerror := 'not enough memory';
     12: turboerror := 'Invalid File access code';
     15: turboerror := 'Invalid drive number';
     16: turboerror := 'Cannot remove current directory';
     17: turboerror := 'Cannot rename across drives';
    100: turboerror := 'Disk read error';
    101: turboerror := 'Disk Write error';
    102: turboerror := 'File not assigned';
    103: turboerror := 'File not open';
    104: turboerror := 'File not open For input';
    105: turboerror := 'File not open For output';
    106: turboerror := 'Invalid numeric Format';
    200: turboerror := 'division by zero';
    201: turboerror := 'Range check error';
    202: turboerror := 'Stack overflow error';
    203: turboerror := 'Heap overflow error';
    204: turboerror := 'Invalid Pointer operation';
    else turboerror := errmsg(errorcode);
  end;
end;


Procedure funpad(Var s:String);
begin
   While s[1]=' ' do
      delete(s,1,1);
end;


Procedure unpad(Var s:String);
begin
   While (length(s)>0) and (s[length(s)]<=' ') do
      delete(s,length(s),1);
end;


Procedure munpad(Var s:String;b:Byte);
begin
   s[0] := Char(b);
   While (length(s)>0) and (s[length(s)]<=' ') do
      delete(s,length(s),1);
end;


Function fpad(s:String;h:Integer):String;
begin
   While length(s)<h do
      s := concat(s,' ');
   fpad := s;
end;


Procedure pad(Var s:String;h:Integer);
begin
   While length(s)<h do
      s := concat(s,' ');
end;


Function between(x,x1,x2:Integer):Boolean;
begin
  between := ((x>=x1) and (x<=x2));
end;


end.
