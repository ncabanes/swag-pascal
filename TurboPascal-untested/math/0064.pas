unit ufinance;                                      { last modified 920520 }

{ Math Routines for Finance Calculations in Turbo Pascal }
{ Copyright 1992, J. W. Rider                            }
{ CIS mail: [70007,4652]                                 }

{  These are pascal implementations some of the finance functions
   available for ObjectVision and Quattro Pro. They are intended to
   work exactly as described in the Quattro Pro 3.0 @Functions manual.

   The following are the Lotus 1-2-3 compatibility functions.

           CTERM ( Rate, FV,      PV)
           DDB   ( cost, salvage, life, period)
           FV    ( Pmt,  Rate,    Nper)
           PMT   ( PV,   RATE,    Nper)
           PV    ( Pmt,  Rate,    Nper)
           RATE  ( FV,   PV,      Nper)
           SLN   ( cost, salvage, life)
           SYD   ( cost, salvage, life, period)
           TERM  ( pmt,  rate,    fv)

   Also implemented are the extended versions of the routines that
   balance the following "cash-flow" equation:

 pval*(1+rate)^nper + paymt*(1+rate*ptype)*((1+rate)^nper-1)/rate + fval = 0

           IRATE (            nper, pmt, pv, fv, ptype)
           NPER  ( rate,            pmt, pv, fv, ptype)
           PAYMT ( rate,      nper,      pv, fv, ptype)
           PPAYMT( rate, per, nper,      pv, fv, ptype)
           IPAYMT( rate, per, nper,      pv, fv, ptype)
           PVAL  ( rate,      nper, pmt,     fv, ptype)
           FVAL  ( rate,      nper, pmt, pv,     ptype)

   In QPro and OV, the ptype code is either 0 or 1 to indicate that the
   is made at the end or beginning of the month respectively.  My preferred
   explanation is that "ptype" is the fraction of the interest rate that is
   applied to a payment in the period that it is paid.  This has the same
   effect when ptype is 0 or 1, but complicates the explanation for what is
   right when ptype=1. THE EXAMPLES IN THE QPRO AND OV MANUALS DO NOT AGREE
   FOR THE "PPAYMT" FUNCTION.  Someone needs to explain these discrepancies.
   UFinance follows the QPro3 style, but the formula is different than what
   QPro3 function reference says is used for IPaymt.

   The "block" financial functions from QPro3 are also implemented:

                   IRR ( guess, block)
                   NPV ( rate, block, ptype)

   These make use of the "UBlock.BlockType" object designed especially
   for these functions.  The BlockType object provides access to a list
   of indexed floating point numbers. See the test program FINTEST.PAS
   for an example of BlockType usage.

   Caveats:  under no circumstances will I be held responsible if someone
   misuses this code.  The code is provided for the convenience of other
   programmers.  It is the someone else's responsibility to ensure that
   these functions satisfy financial needs.

   While this is a relatively complete set of functions, it is not possible
   to calculate all desirved components in the compound interest equation
   directly.  In particular, there is no way provided to compute directly
   the interest rate on an annuity or loan that goes from "pv" to "fv" in
   "nper" intervals, paying "pmt" each period.  The "RATE" function
   provided only determines the rate at which a compounded amount grows.
   The "IRATE" function computes a value by successive approximation and
   is inherently unstable. (The "IRR" function is subject to similar
   instability.)

   One way in which programmers go wrong is misunderstanding the
   distinction between binary floating point representations of numbers and
   decimal floating point representation.  Turbo Pascal, as well as most
   other high speed number processing systems, uses the binary form.  While
   such binary operations give results that are close to their decimal
   counterparts, some differences may arise.  Especially, when you expect
   results to round one way versus the other.
}

interface

uses ublock; { for "blocktype" of NPV and IRR functions }

{ "Extended" math is used if $N+ is set.  Otherwise, use "real" math.}

{$ifopt N-}
type extended = real;
{$endif}

function CTERM ( Rate, FV, PV: extended):extended;
  { number of compounding periods for initial amount "PV" to accumulate
    into amount "FV" at interest "Rate" }

function DDB   ( cost, salvage, life, period:extended):extended;
  { double declining balance depreciation for the "period" (should be a
    positive, whole number) interval on an item with initial "cost" and
    final "salvage" value at the end of "life" intervals }

function FV    ( Pmt, Rate, Nper:extended):extended;
  { accumulated amount from making "nper" payments of amount "pmt" with
    interest accruing on the accumulated amount at interest "rate"
    compounded per interval }

function FVAL  ( rate, nper, pmt, pv, ptype:extended):extended;
  { extended version of the FV function }

function IPAYMT(rate, per, nper, pv, fv, ptype:extended):extended;
  { computes the portion of a loan payment that is interest on the
    principal }

function IRATE ( nper, pmt, pv, fv, ptype:extended):extended;
  { extended version of the RATE function }

function IRR   ( guess: extended; var block: blocktype): extended;
  { returns internal rate-of-return of sequence of cashflows }

function NPER  ( rate, pmt, pv, fv, ptype:extended):extended;
  { extended version of the CTERM and TERM functions }

function NPV   (
  rate: extended; var block: blocktype; ptype:extended): extended;
  { return net present value of sequence of cash flows }

function PAYMT ( rate, nper, pv, fv, ptype:extended):extended;
  { extended version of the PMT function }

function PMT   ( PV, RATE, Nper: extended): extended;
  { payment amount per interval on loan or annuity of initial value "PV"
    with payments spread out over "nper" intervals and with interest
    accruing at "rate" per interval }

function PPAYMT( rate, per, nper, pv, fv, ptype:extended):extended;
  { computes the portion of a loan payment that reduces the principal }

function PV    ( Pmt, Rate, Nper: extended): extended;
  { initial value of loan or annuity that can be paid off by making "nper"
    payments of "pmt" which interest on the unpaid amount accrues at
    "rate" per interval }

function PVAL  ( rate, nper, pmt, fv, ptype:extended):extended;
  { extended version of the PV function }

function RATE  ( FV, PV, Nper: extended): extended;
  { determines interest rate per interval when initial amount "pv"
    accumulates into amount "fv" by compounding over "nper" intervals }

function SLN   ( cost, salvage, life: extended): extended;
  { straight line depreciation per interval when item of initial value
    "cost" has a value of "salvage" after "life" intervals }

function SYD   ( cost, salvage, life, period: extended): extended;
  { sum-of-year-digits depreciation amount for the "period" (should be a
    positive, whole number) interval on a item with initial "cost" and
    final "salvage" value at the end of "life" intervals }

function TERM  ( pmt, rate, fv: extended): extended;
  { number of compounding periods required to accumulate "fv" by making
    periodic deposits of "pmt" with interest accumulating at "rate" per
    period }

implementation

function CTERM ( Rate, FV, PV: extended):extended;
begin cterm:=ln(fv/pv)/ln(1+rate) end;

function DDB   ( cost, salvage, life, period:extended):extended;
var x:extended; n:integer;
begin
  x:=0; n:=0;
  while period>n do begin
    x:=2*cost/life;
    if (cost-x)<salvage then x:=cost-salvage;
    if x<0 then x:=0;
    cost:=cost-x; inc(n); end;
  ddb:=x;
end;

function FV    ( Pmt, Rate, Nper:extended):extended;
begin
  if abs(rate)>1e-6 then fv:=pmt*(exp(nper*ln(1+rate))-1)/rate
  else                   fv:=pmt*nper*(1+(nper-1)*rate/2); end;

function FVAL  ( rate, nper, pmt, pv, ptype:extended):extended;
var f: extended;
begin
  f:=exp(nper*ln(1+rate));
  if abs(rate)<1e-6 then
    fval :=-pmt*nper*(1+(nper-1)*rate/2)*(1+rate*ptype)-pv*f
  else
    fval := pmt*(1-f)*(1/rate+ptype)-pv*f;
end;

function IPAYMT(rate, per, nper, pv, fv, ptype:extended):extended;
begin
  ipaymt := rate
    * fval( rate, per-ptype-1, paymt( rate, nper, pv, fv, ptype), pv, ptype);
end;

function IRATE ( nper, pmt, pv, fv, ptype:extended):extended;
var rate,x0,x1,y0,y1:extended;

  function y:extended;
  var f:extended;
  begin
    if abs(rate)<1e-6 then y:=pv*(1+nper*rate)+pmt*(1+rate*ptype)*nper+fv
    else begin
      f:=exp(nper*ln(1+rate));
      y:=pv*f+pmt*(1/rate+ptype)*(f-1)+fv; end; end;

begin {irate}

  { JWR: There are two fundamental problems with solutions by successive
    approximation.  One is figuring out where you want to start; the
    other is figuring out where you want to stop.  If you don't set them
    right, then your solution will approximate successively forever.
    This is my guess, but there is no guarantee that the solution will
    even exist, much less converge. }

  rate:=0; y0:=pv+pmt*nper+fv; x0:=rate;
  rate:=exp(1/nper)-1; y1:=y; x1:=rate;
  while abs(y0-y1)>1e-6 do begin { find root by secant method }
    rate:=(y1*x0-y0*x1)/(y1-y0); x0:=x1; x1:=rate; y0:=y1; y1:=y; end;
  irate:=rate;
end; {irate}

function IRR( guess: extended; var block: blocktype): extended;
var orate, rate: extended;

  function drate(rate:extended):extended;
  var npv,npvprime,blockvaluei:extended; i:longint;
  begin
    npv:=0; npvprime:=0; rate:=1/(1+rate);
    for I:=block.count downto 1 do begin
      blockvaluei:=block.value(i);
      npv:=npv*rate+blockvaluei;
      npvprime:=(npvprime+blockvaluei*i)*rate; end;
    if abs(npvprime)<1e-6 then drate:=npv*1e-6 { a guess }
    else                       drate:=npv/npvprime; end;

begin {IRR}

  { JWR: same caveats as for IRate }

  orate:=guess; rate:=orate+drate(orate);
  while abs(rate-orate)>1e-6 do begin { find root by newton-raphson }
    orate:=rate; rate:=rate+drate(rate); end;
  irr:=rate;
end;

function NPER  ( rate, pmt, pv, fv, ptype:extended):extended;
var f:extended;
begin
  f:=pmt*(1+rate*ptype);
  if abs(rate)>1e-6 then
    nper:=ln((f-rate*fv)/(pv*rate+f))/ln(1+rate)
  else
    nper:=-(fv+pv)/(pv*rate+f); end;

function NPV   (
  rate: extended; var block: blocktype; ptype:extended): extended;
var x:extended; i:longint;
begin
  x:=0; rate:=1/(1+rate); {note: change in meaning of "rate"!}
  for I:=block.count downto 1 do x:=x*rate+block.value(i);
  npv:=x*exp((1-ptype)*ln(rate)); end;

function PAYMT ( rate, nper, pv, fv, ptype:extended):extended;
var f:extended;
begin
  f:=exp(nper*ln(1+rate));
  paymt:= (fv+pv*f)*rate/((1+rate*ptype)*(1-f)); end;

function PMT   ( PV, RATE, Nper: extended): extended;
begin pmt:=pv*rate/(1-exp(-nper*ln(1+rate))) end;

function PPAYMT( rate, per, nper, pv, fv, ptype:extended):extended;
var f:extended;
begin
  f:=paymt(rate,nper,pv,fv,ptype);
  ppaymt:=f-rate*fval(rate,per-ptype-1,f,pv,ptype);
end;

function PV    ( Pmt, Rate, Nper: extended): extended;
begin
  if abs(rate)>1e-6 then
    pv:=pmt*(1-exp(-nper*ln(1+rate)))/rate
  else
    pv:=pmt*nper*(1+(nper-1)*rate/2)/(1+nper*rate)
end;

function PVAL  ( rate, nper, pmt, fv, ptype:extended):extended;
var f:extended;
begin
  if abs(rate)>1e-6 then begin
    f:=exp(nper*ln(1+rate)); pval := (pmt*(1/rate+ptype)*(1-f)-fv)/f; end
  else
    pval:=-(pmt*(1+rate*ptype)*nper+fv)/(1+nper*rate)
end;

function RATE  ( FV, PV, Nper: extended): extended;
begin rate:=exp(ln(fv/pv)/nper)-1 end;

function SLN   ( cost, salvage, life: extended): extended;
begin sln:=(cost-salvage)/life end;

function SYD   ( cost, salvage, life, period: extended): extended;
begin syd:=2*(cost-salvage)*(life-period+1)/(life*(life+1)) end;

function TERM  ( pmt, rate, fv: extended): extended;
begin  term:=ln(1+(fv/pmt)*rate)/ln(1+rate) end;

end.

{ ----------------------    CUT HERE -------------------------- }

unit ublock;

{ defines the "BlockType" object used for the UFinance NPV and IRR functions }
{ Copyright 1992 by J. W. Rider }
{ CIS mail: [70007,4652] }

interface

{$ifopt N-}
type
  extended = real;
{$endif}

type

  { the abstract "block": this is the type that is used for the
    type of "var" parameters in procedures and functions }
  BlockTypePtr = ^BlockType;
  BlockType = object
    function count: longint; virtual;  { number of values in "block" }
    function value(n:longint):extended; virtual; { return nth value }
    destructor done; virtual;
    end;

type
  ExtendedArrayPtr = ^ExtendedArray;
  ExtendedArray = array [1..$fff8 div sizeof(extended)] of extended;

type
  { a special-purpose block that extracts values from "extended" arrays.
    This is the type that would be declared as "const" or "var" or
    allocated on the heap in your program.  This one is very simple; you
    could easily extend the abstract block to other storage forms. }
  {  Note that "extended" means the same as "real" if $N-. }
  ExtendedArrayBlockTypePtr = ^ExtendedArrayBlockType;
  ExtendedArrayBlockType = object(BlockType)
    c: word;
    d: extendedarrayptr;
    function count:longint; virtual;
    function value(n:longint):extended; virtual;
    constructor init(dim:word; var firstvalue:extended);
    end;

implementation

function blocktype.count; begin count:=0 end;
function extendedarrayblocktype.count; begin count:=c; end;

destructor blocktype.done; begin end;

constructor extendedarrayblocktype.init; begin c:=dim; d:=@firstvalue; end;

function blocktype.value; begin value:=0; end;
function extendedarrayblocktype.value; begin value:=d^[n] end;

end.

{ ========================   DEMO ============================= }

{JWR: The output scrolls without stopping.  You might want to replace
 "writeln;" with "readln;" so that you can follow along in the QPRO
 manual while you run the example. What I usually do for testing is
 just to redirect everything to a file from the command line and then
 examine the file.}

program fintest;
uses ufinance,ublock;

{ these types and consts are used for the IRR and NPV functions }

type
  xray3 = array [1..3] of extended;
  xray5 = array [1..5] of extended;
  xray7 = array [1..7] of extended;
  bt = object(extendedarrayblocktype) end;

const
  x1: xray3 = (-10,150,-145);
  x2: xray3 = (-10,150.1,-145);
  a: xray7 = (-3000,700,600,750,900,1000,1400);
  b: xray7 = (-50000,-8000,2000,4000,6000,5000,4500);
  c: xray7 = (-10000,1000,1000,1200,2000,3000,4000);
  a2: xray5 = (-5000,2000,2000,2000,2000);
  b2: xray7 = (8000,9000,8500,9500,10000,11000,10000);
  c2: xray7 = (200,350,-300,600,700,1000,1200);
  d2: xray7 = (3500,4000,3000,5000,4000,6500,7000);

  block1:bt = (c:3; d:@x1);
  block2:bt = (c:3; d:@x2);
  block3:bt = (c:7; d:@a);
  block4:bt = (c:7; d:@b);
  block5:bt = (c:7; d:@c);
  block6:bt = (c:5; d:@a2);
  block7:bt = (c:4; d:@a2[2]);
  block8:bt = (c:7; d:@b2);
  block9:bt = (c:7; d:@c2);
  block10:bt = (c:7; d:@d2);

begin

  writeln('Test of UFinance unit.  Examples from');
  writeln('    Quattro Pro 3.0 @Functions and Macros manual');
  writeln;
  writeln('page 29 (CTERM):');
  writeln(cterm(0.07,5000,3000):10:2);
  writeln(nper(0.07,0,-3000,5000,0):10:2,'(nper)');
  writeln(cterm(0.1,5000,3000):10:6);
  writeln(cterm(0.12,5000,3000):10:6);
  writeln(cterm(0.12,10000,7000):10:6);
  writeln;
  writeln('pages 35-36 (DDB):');
  writeln(ddb(4000,350,8,2):10:0);
  writeln(ddb(15000,3000,10,1):10:0);
  writeln(ddb(15000,3000,10,2):10:0);
  writeln(ddb(15000,3000,10,3):10:0);
  writeln(ddb(15000,3000,10,4):10:0);
  writeln(ddb(15000,3000,10,5):10:0);
  writeln;
  writeln('page 48 (FV):');
  writeln(fv(500,0.15,6):10:2);
  writeln(fval(0.15,6,-500,0,0):10:2,'(fval)');
  writeln(fv(200,0.12,5):10:2);
  writeln(fv(500,0.9,4):10:2);
  writeln(fv(800,0.9,3):10:2);
  writeln(fv(800,0.9,6):10:2);
  writeln;
  writeln('page 49 (FVAL):');
  writeln(fval(0.15,6,-500,0,1):10:2);
  writeln(fval(0.15,6,-500,-340,1):10:2);
  writeln;
  writeln('page 57 (IPAYMT):');
  writeln(ipaymt(0.1/12,2*12,30*12,100000,0,0):10:2);
  writeln;
  writeln('pages 57-58 (IRATE):');
  writeln(irate(5*12,-500,15000,0,0):10:5);
  writeln(irate(5,-2000,-2.38,15000,0):10:4);
  writeln;
  writeln('pages 60-61 (IRR):');
  writeln(irr(0,block1)*100:10:2,'%');
  writeln(irr(10,block1)*100:10:0,'%');
  writeln(irr(0,block2)*100:10:2,'%');
  writeln(irr(10,block2)*100:10:0,'%');
  writeln(irr(0,block3)*100:10:2,'%');
  writeln(irr(0,block4)*100:10:2,'%');
  writeln(irr(0,block5)*100:10:2,'%');
  writeln;
  writeln('page 73 (NPER):');
  writeln(nper(0.115,-2000,-633,50000,0):10:2);
  writeln;
  writeln('page 75 (NPV):');
  writeln(npv(0.1,block6,1):10:0);
  writeln(a2[1]+npv(0.1,block7,0):10:0);
  writeln(npv(0.0125,block8,0):10:2);
  writeln(npv(0.15/12,block9,0):10:0);
  writeln(npv(0.15/12,block10,0):10:0);
  writeln;
  writeln('page 77 (PAYMT):');
  writeln(paymt(0.175/12,12*30,175000,0,0):10:2);
  writeln(paymt(0.175/12,12*30,175000,0,1):10:2);
  writeln(paymt(0.175/12,12*30,175000,-80000,0):10:2);
  writeln;
  writeln('pages 78-79 (PMT)');
  writeln(pmt(10000,0.15/12,3*12):10:2);
  writeln(paymt(0.15/12,3*12,10000,0,0):10:2,'(paymt)');
  writeln(pmt(1000,0.12,5):10:2);
  writeln(pmt(500,0.16,12):10:2);
  writeln(pmt(5000,0.16/12,12):10:2);
  writeln(pmt(12000,0.11,15):10:2);
  writeln;
  writeln('page 79 (PPAYMT):');
  writeln(ppaymt(0.1/12,2*12,30*12,100000,0,0):10:2);
  writeln(ppaymt(0.15/4,24,40,10000,0,1):10:2);
  writeln;
  writeln('page 81 (PV)');
  writeln(pv(350,0.07/12,5*12):10:2);
  writeln(pval(0.07/12,5*12,-350,0,0):10:2,'(pval)');
  writeln(pv(277,0.12,5):10:2);
  writeln(pv(600,0.17,10):10:2);
  writeln(pv(100,0.11,12):10:2);
  writeln;
  writeln('page 82 (PVAL)');
  writeln(pval(0.1,12,2000,0,0):10:2);
  writeln(pval(0.1,15,0,30000,0):10:2);
  writeln;
  writeln('page 84 (RATE)');
  writeln(rate(4000,2000,10)*100:6:2,'%');
  writeln(rate(10000,7000,6*12)*100:6:2,'%');
  writeln(rate(1200,1000,3)*100:6:2,'%');
  writeln(rate(500,100,25)*100:6:2,'%');
  writeln;
  writeln('page 89 (SLN)');
  writeln(sln(4000,350,8):10:2);
  writeln(sln(15000,3000,10):10:0);
  writeln(sln(5000,500,5):10:0);
  writeln(sln(1800,0,3):10:0);
  writeln;
  writeln('pages 94-95 (SYD)');
  writeln(syd(4000,350,8,2):10:2);
  writeln(syd(12000,1000,5,1):10:0);
  writeln(syd(12000,1000,5,2):10:0);
  writeln(syd(12000,1000,5,3):10:0);
  writeln(syd(12000,1000,5,4):10:0);
  writeln(syd(12000,1000,5,5):10:0);
  writeln;
  writeln(ddb(12000,1000,5,1):10:0,'(ddb)');
  writeln(ddb(12000,1000,5,2):10:0,'(ddb)');
  writeln(ddb(12000,1000,5,3):10:0,'(ddb)');
  writeln(ddb(12000,1000,5,4):10:0,'(ddb)');
  writeln(ddb(12000,1000,5,5):10:0,'(ddb)');
  writeln;
  writeln('page 96 (TERM)');
  writeln(term(2000,0.11,50000):10:2);
  writeln(nper(0.11,-2000,0,50000,0):10:2,'(nper)');
  writeln(term(300,0.06,5000):10:1);
  writeln(term(500,0.07,1000):10:2);
  writeln(term(500,0.07,1000):10:2);
  writeln(term(1000,0.10,50000):10:1);
  writeln(term(100,0.05,1000):10:1);
end.
