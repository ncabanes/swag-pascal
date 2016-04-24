(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0107.PAS
  Description: String Arrays
  Author: CHRISTOPHER CHANDRA
  Date: 05-26-95  22:58
*)


{ Updated STRINGS.SWG on May 26, 1995 }

{
 OK, this is the working version of the old one.
 I tested it and it worked.

 Insert_Arr2Strs procedure, and a little demo on how to use it

 by Christopher J. Chandra - 1/25/95

 PUBLIC DOMAIN CODE
}

uses crt;

type str_array=array[1..128] of char;
     str127=string[127];

procedure insert_arr2strs(s:str_array;var r1,r2:str127);
var cnt,cnt2,eidx:integer;

begin
 cnt:=1;
 eidx:=length(r1);
 r2:='';

 {assuming that the array is a NULL terminated string...}

 while ((s[cnt]<>#0) and (cnt<128) and (eidx+cnt<128)) do
 begin
  r1[eidx+cnt]:=s[cnt];    {copy the array into the 1st result string}
  inc(cnt);
 end;
  r1[0]:=chr(eidx+cnt-1);  {store the string length}

 {if any left over, do ...}

 cnt2:=1;

 while ((s[cnt]<>#0) and (cnt<129)) do
 begin
  r2[cnt2]:=s[cnt];        {copy the left over into the 2nd result string}
   inc(cnt);
   inc(cnt2);
 end;
  r2[0]:=chr(cnt2-1);      {store the string length}

end;

var myarray:str_array;
    mystr1,mystr2:str127;
    cnt:integer;
    s:string;

begin
 clrscr;

 s:='Ain''t that a nice song?  OK, here is another one ... ';
 for cnt:=1 to length(s) do myarray[cnt]:=s[cnt];myarray[cnt+1]:=#0;

 mystr1:='London Bridge is falling down, falling'+
         ' down, falling down.  London Bridge is'+
         ' falling down, my fair lady. WHOOSH!  ';
 mystr2:='';

 textcolor(12);writeln('Before insertation ...');
 textcolor(10);write('String 1:');
 textcolor(14);writeln('"',mystr1,'"');
 textcolor(10);write('String 2:');
 textcolor(14);writeln('"',mystr2,'"');writeln;
 textcolor(11);write('String Array to be inserted:');
 textcolor(13);writeln('"',s,'"');writeln;

 insert_arr2strs(myarray,mystr1,mystr2);

 textcolor(12);writeln('After insertation ... using String 2 for leftovers');
 textcolor(10);write('String 1:');
 textcolor(14);writeln('"',mystr1,'"');
 textcolor(10);write('String 2:');
 textcolor(14);writeln('"',mystr2,'"');writeln;

 s:='One Little Two Little Three Little Indians.  '+
    'Four Little Five Little Six Little Indians.  '+
    'Seven Little Eight Little ';
 for cnt:=1 to length(s) do myarray[cnt]:=s[cnt];myarray[cnt+1]:=#0;

 textcolor(11);write('String Array to be inserted:');
 textcolor(13);writeln('"',s,'"');writeln;

 insert_arr2strs(myarray,mystr2,mystr1);

 textcolor(12);writeln('After insertation ... using String 1 for leftovers');
 textcolor(10);write('String 1:');
 textcolor(14);writeln('"',mystr1,'"');
 textcolor(10);write('String 2:');
 textcolor(14);writeln('"',mystr2,'"');writeln;

 textcolor(12);writeln('End of demo.  :)');

end.

