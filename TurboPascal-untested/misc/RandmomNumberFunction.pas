(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0022.PAS
  Description: Randmom Number Function
  Author: KENT BRIGGS
  Date: 07-16-93  06:13
*)

===========================================================================
 BBS: Canada Remote Systems
Date: 06-18-93 (23:27)             Number: 26893
From: KENT BRIGGS                  Refer#: NONE
  To: BRIAN PAPE                    Recvd: NO  
Subj: RANDOM NUMBERS                 Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
 -=> Quoting Brian Pape to Erik Johnson <=-

 BP> Please- I *am* looking for the source code to a decent random number
 BP> generator so that I'm not dependant on Borland.

 Brian, Borland did change their random:word function when they released
 7.0.  However the random:real function, the randomize procedure, and their
 method of updating randseed remain the same as ver 6.0.  Using DJ Murdoch's
 CycleRandseed procedure and reverse engineering TP6's and TP7's Random
 functions, I came up with the following routines:

const rseed: longint = 0;

procedure randomize67;      {TP 6.0 & 7.0 seed generator}
begin
  reg.ah:=$2c;
  msdos(reg);    {get time: ch=hour,cl=min,dh=sec,dl=sec/100}
  rseed:=reg.dx;
  rseed:=(rseed shl 16) or reg.cx;
end;

function rand_word6(x: word): word;    {TP 6.0 RNG: word}
begin
  rseed:=rseed*134775813+1;
  rand_word6:=(rseed shr 16) mod x;
end;

function rand_word7(x: word): word;    {TP 7.0 RNG: word}
begin
  rseed:=rseed*134775813+1;
  rand_word7:=((rseed shr 16)*x+((rseed and $ffff)*x shr 16)) shr 16;
end;

function rand_real67: real;    {TP 6.0 & 7.0 RNG: real}
begin
  rseed:=rseed*134775813+1;
  if rseed<0 then rand_real67:=rseed/4294967296.0+1.0 else
  rand_real67:=rseed/4294967296.0;
end;

If anyone can improve on these please post some code here, thanks.

___ Blue Wave/QWK v2.12
--- Renegade v06-11 Beta

 * Origin: Snipe's Castle BBS, Waco TX   (817)-757-0169 (1:388/26)

