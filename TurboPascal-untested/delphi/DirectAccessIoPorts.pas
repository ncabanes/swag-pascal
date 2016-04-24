(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0144.PAS
  Description: Direct Access I/O Ports
  Author: SWAG SUPPORT TEAM
  Date: 05-31-96  09:20
*)

{
There have been several posts about _real-time_ port I/O under Windows.
I've used the following scheme to control via I/O ports and tell the user what is going on via
wav files.

{----------------------------------------}
For port I/O under Delphi 1, use

var  i,j:word;

 port[i]:=j; {write to port i}
 j:=port[i];  {read from port i}

  The sound stuff (see below) was not very satisfactory - either make async, and sometimes get 
the end chopped off the sound when a second sound is started, or make sync and freeze activity 
because you have to wait until the sound has played.

{----------------------------------------}
Under Delphi 2.0 and Win95, for port I/O use something like:

procedure SetPort(address,value:Word);
var bvalue:byte;
begin
   bvalue:=trunc(value and 255);
   asm
      mov dx,address
      mov AL,bvalue
      out DX,AL
   end;
end;

function GetPort(address:Word):Word;
var bvalue:byte;
begin
   asm
      mov dx,address
      in aL,dx
      mov bvalue,aL
   end;
   result:=bvalue;
end;

and then 
var i,j:word;
begin
   Setport(i,j);
   j:=GetPort(i);
end;

{----------------------------------------}
Under Win NT, you have to use a Vxd for port I/O.
See Dr. Dobbs Journal, Nov. 1995 for an exxample which contains no port I/O.

