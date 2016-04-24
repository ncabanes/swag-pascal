(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0102.PAS
  Description: Re: Formula for payments
  Author: GEORGE ROBERTS
  Date: 11-22-95  13:32
*)

(*
 KVR> Hello All,
 KVR> I am busy with a pascal course and I gotta formula I must work out.
 KVR> My maths ended in std 8 so I got noclu of what I'm doin but im doin it
 KVR> anyway!! HELP PLease anybody!!
 KVR> 
 KVR> 12n
 KVR> Ar[1+(r/1200)]
 KVR> P= -----------------------
 KVR> 12n   
 KVR> 1200{[1+(r/1200)]    -1}
 KVR> 
 KVR> This is a formula for monthly mortgage payments.
 KVR> P=repayment value,A=amount borrowed, n=amount of years,
 KVR> r=annual mortgage interest rate.
 KVR> I've done this:
 KVR> 
 KVR> B:=((1+(r/1200))*exp(12*n);
 KVR> P:=((A*r)*B)/(1200*(B-1));
 KVR> and I get some real cockeyed answers 8-)

Here you go.  Keep in mind that all variables are of type REAL except the
<n> variable which is type WORD.  Keep in mind that your result is going to
be a real variable, so if you do a writeln(p); you are going to get a really
weird looking answer.  To see it correctly you should use writeln(p:2:2);

-----------------------------------/ Cut /------------------------------------
*)

Program ShowPayment;
uses crt;

var A,P,r:real;
    n:word;

function sign(number:real):real;
begin
if number = 0.0 then sign:=1 else sign:=abs(number) / number;
end;

function raise(number,power:real):real;
begin
if number =0.0 then
   if power = 0.0 then raise:=1.0 else raise:=0.0
else raise:=sign(number) * exp(power * ln(abs(number)));
end;

begin

 {P=repayment value,A=amount borrowed, n=amount of years,
 r=annual mortgage interest rate. }

A:=2000.0;
r:=10.0;
n:=1;
P:=(A*r*(raise((1.0+(r/1200)),12.0*n)))/(1200.0*(raise((1.0+(r/1200.0)),
        12.0*n)-1.0));
writeln(p:2:2);
end.

