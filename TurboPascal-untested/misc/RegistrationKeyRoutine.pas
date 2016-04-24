(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0095.PAS
  Description: Registration Key Routine
  Author: LARS P. FRIEND
  Date: 05-25-94  08:21
*)

{
* In a message originally to All, Brad Larned said:
BL >Hello All!

BL >Does anyone have a good registration key routine, they would
BL >be willing to
BL >share, I can download Net-Mail or a response in this message
BL >base will be fine..

Here goes.... }

type regpass:array[1..23] of byte;

function checkregister:boolean;
var
 f:file of regpass;
 p:regpass;
 a,x,y,z,c:word;
begin
 assign(f,'REGISTER.KEY');
 reset(f);
 read(f,p);
 close(f);


 for a:=1 to 20 do
  begin
   z:=z+p[a];
   x:=x XOR p[a];
   y:=y+NOT(p[a]);
   end;
 c:=z;
 z:=z MOD 256;
 x:=x MOD 256;
 y:=y MOD 256;
 checkregister:=false;

 if ((x=p[21]) AND (y=p[22])) AND (z=p[23]) then checkregister:=true;
 if c=0 then checkregister:=false;

end;

This routine allows you to have both somebody's name and a checksum stored. 
If they don't match up, it appears that it isn't a registered copy.  You can 
stash whatever in the first 20 bytes, and the last three are reserved for a 
chacksum.  This is the routine that I use, and it seems to be pretty 
muck-proof;

You can write the routine to create the file and do the checksums yourself.
It's idioticly simple.  C-ya...

