(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0013.PAS
  Description: DOS ICA Put/Get Routine
  Author: ROB GREEN
  Date: 07-16-93  06:09
*)

===========================================================================
 BBS: Canada Remote Systems
Date: 06-30-93 (07:05)             Number: 28694
From: ROB GREEN                    Refer#: NONE
  To: RAND NOWELL                   Recvd: NO  
Subj: CODE FOR PROGRAM               Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
 > Another way would be to, upon program startup, is create an
 > enviornment var refering to your program. Say the program is
 > RR.EXE, create a var as Set RR = INSTALLED!  then when you
 > shell, search the enviornment for RR, if it equals INSTALLED!
 > then present message, if the RR var not exists, then load the
 > program.  Of course when the program quits you want to seet RR =
 >    (nothing).....

Heres the way i do it...

unit AmLoaded;

interface

type
   ICAType   = record
       Stext : string[13];
       chksum: integer;
   end;

var
  ica : icaType absolute $0000:$04f0;

Procedure PutICA(sText:string);

procedure GetIca(var stext:string);

function  IcaSame(Stext:string):boolean;


implementation

Procedure PutICA(sText:string);
var
   j:byte;
Begin
   fillchar(ica.stext,sizeof(ica.stext),0);
   ica.stext:=copy(stext,1,13);
   ica.stext[0]:=#13;
   Ica.ChkSum:=0;
   for j:=0 to 13 do
      Ica.ChkSum:=Ica.ChkSum+ord(ica.stext[j]);
End;


Procedure GetIca(var stext:string);
Begin
   stext:=ica.stext;
End;

function  IcaSame:boolean;
var
   j:byte;
   k,m:integer;
begin
   k:=0;
   m:=0;
   for j:=0 to 13 do
   Begin
      k:=k+ord(ica.stext[j]);
      m:=m+ord(stext[j]);
   end;
   if k=m then
   Begin
      if ica.chksum=m then
         IcaSame:=true
      else
         IcaSame:=False;
   end
   else
      icasame:=false;
end;

end.
-----------------------
Test program:

uses AmLoaded;
Begin
   PutIca('ATEST');
   Writeln('ATEST, should come back as same');
   {Check to see if we can read it back without changing anything}
   If IcaSame('ATEST') then
      writeln('Same')
   else
      writeln('Not Same');
   PutICA('Another Test');
   Writeln('Another Test, should come back as not same');
   {Change the lower case 'h' into an uppercase 'H'}
   Ica.Stext[5]:='H';
   If IcaSame('Another Test') then
      writeln('Same')
   else
      writeln('Not same');
   PutIca('hello world');
   writeln('Hello world, should come back as not same');
   {Change the chksum}
   ica.chksum:=111;
   If IcaSame('hello world'); then
      writeln('Same')
   else
      writeln('Not same');
End.
-------------------------------------------

Before doing EXEC do this:
PutICA('Program name');  {up to 13 chars}
EXEC(getenv('COMSPEC'),'Whatever');
PutIca('            ');  {Or null}

Then when starting your program do this:
If ICASame('Program name') then
   writeln('Can''t load Program name on top of itself');


Rob

--- FMail 0.94
 * Origin: The Rush Room - We OWN Orlando - (407) 678 & 0749 (1:363/166)

