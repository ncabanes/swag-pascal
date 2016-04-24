(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0080.PAS
  Description: Matrix Algebra Unit
  Author: VITUS WAGNER
  Date: 11-26-94  05:00
*)

{
From: "Victor B. Wagner" <vitus@agropc.msk.su>
************************************************************
*                   ALGEBRA.PAS                            *
*           a simple matrix algebra unit                   *
*           Turbo Pascal 4.0 or higher                     *
*           Copyright (c) by Vitus Wagner,1990             *
************************************************************
}
unit algebra;
interface
   const MaxN=30;{You can increase it up to 100,not greater
                 but each matrix variable would have size of
                 sqr(MaxN)*sizeof(Real). It is possible to write
                 unit for work with dinamically sized matrices,
                 but i have no needs to do this.
                 You can work with matrices with size less that MaxN,
                 but while you work with this unit you must allocate
                 memory for matrix MaxN x MaxN and leave rest of space
                 unised}
   type vector=array[1..MaxN]of real;
        matrix=array[1..MaxN,1..MaxN]of real;
        sett=set of 1..MaxN;
 var algebrerr:boolean;
 function scalar(a,b:vector;n:integer):real;
 {Scalar multiplication of vectors a and b of n components}
 procedure systeq(a:matrix;b:vector;var x:vector;n:integer);
 { solving n line equation system A*X=B by Gauss method}
 { sets algebrerr to True if system cannot be solved}
 procedure matmult(a,b:matrix;var c:matrix;n:integer);
 { multiplication of two NxN matrixs A and B.Result - matrix C AxB=C}
 procedure matadd(a,b:matrix;var c :matrix;n:integer);
 { addition of two NxN matrixs A+B=C }
 procedure matconst(c:real;a:matrix;var b:matrix;n:integer);
 { multiplication matrix A on constant c  cxA=B }
 procedure matcadd(c1:real;a1:matrix;c2:real;a2:matrix;var b:matrix;n:integer);
 { addition of two NxN matrixs with multiplication each of them on constant
   c1xA1+c2xA2=B }
 procedure matinv(a:matrix;var ainv:matrix;n:integer);
 { inversion of NxN matrix A}
 { sets algebrerr to True if matrix cannot be inverted}
 procedure matvec(a:matrix;b:vector;var c:vector;n:integer);
 { multiplication NxN matrix A to N-component vector B AxB=C}
 function det(a:matrix;n:integer):real;
 { determinant of NxN matrix }
 procedure compress(a:matrix;var b:matrix;n:integer;s:sett);
 { converse triangle matrix to simmetric,exclude rows and columns that is not
   in set s (type sett=set of 0..maxN)}
 function distance(a,b:vector;n:integer):real;
 { Calculate Euclide distantion in N-dimensioned space between A & B }
 Procedure Transpose(var A:Matrix;M,N:Integer);
 { Transpose MxN Matrix. Put result in the same place}
 Procedure EMatrix(var A:Matrix;N:Integer);
 {Fills matrix by 0 and main diagonal by 1}
implementation
 function scalar(a,b:vector;n:integer):real;
  var i:integer;
      r:real;
  begin
   r:=0.0;
   for i:=1 to n do
    r:=r+a[i]*b[i];
   scalar:=r;
  end;
 procedure systeq(a:matrix;b:vector;var x:vector;n:integer);
  var i,j,k:integer;
      max:real;
  begin
  algebrerr:=false;
   { Conversion matrix to triangle }
   for i:=1 to n do
    begin
     max:=abs(a[i,i]);k:=i;
     for j:=succ(i) to n do
      if abs(a[j,i])>max then
       begin
        max:=abs(a[j,i]);k:=j
       end;
      if max<1E-10 then begin algebrerr:=true;exit end;
      if k<>i then
       begin
        for  j:=i to n do
         begin
          max:=a[k,j];
          a[k,j]:=a[i,j];
          a[i,j]:=max;
         end;
        max:=b[k];
        b[k]:=b[i];
        b[i]:=max;
       end;
      for j:=succ(i) to n do
       a[i,j]:=a[i,j]/a[i,i];
       b[i]:=b[i]/a[i,i];
      for j:=succ(i) to n do
       begin
        for k:=succ(i) to n do
         a[j,k]:=a[j,k]-a[i,k]*a[j,i];
        b[j]:=b[j]-b[i]*a[j,i];
       end;
    end;
     { X calculation}
     x[n]:=b[n];
     for i:=pred(n) downto 1 do
      begin
       max:=b[i];
       for j:=succ(i) to n do
        max:=max-a[i,j]*x[j];
       x[i]:=max;
      end;
  end;
 procedure matmult(a,b:matrix;var c:matrix;n:integer);
  var i,j,k:integer;r:real;
  begin
   for i:=1 to n do
    for j:=1 to n do
     begin
      r:=0.0;
      for k:=1 to n do
       r:=r+a[i,k]*b[k,j];
      c[i,j]:=r;
     end;
  end;
 procedure matadd(a,b:matrix;var c :matrix;n:integer);
  var i,j:integer;
  begin
   for i:=1 to n do
    for j:=1 to n do
     c[i,j]:=a[i,j]+b[i,j];
  end;
 procedure matinv(a:matrix;var ainv:matrix;n:integer);
  var i,j,k:integer;
      e:matrix;
      max:real;
  begin
   algebrerr:=false;
   { creating single matrix }
   for i:=1 to n do
    for j:=1 to n do
     e[i,j]:=0.0;
   for i:=1 to n do
    e[i,i]:=1.0;
   { Conversion matrix to triangle }
   for i:=1 to n do
{1} begin
     max:=abs(a[i,i]);k:=i;
     for j:=succ(i) to n do
      if abs(a[j,i])>max then
{2}    begin
        max:=abs(a[j,i]);k:=j
{2}    end;
      if max<1E-10 then begin algebrerr:=true;exit end;
      if k<>i then
{2}    begin
        for  j:=i to n do
{3}      begin
          max:=a[k,j];
          a[k,j]:=a[i,j];
          a[i,j]:=max;
{3}      end;
      for j:=1 to n do
{3}    begin
        max:=e[k,j];
        e[k,j]:=e[i,j];
        e[i,j]:=max;
{3}    end;
{2}   end;
      for j:=succ(i) to n do
       a[i,j]:=a[i,j]/a[i,i];
       for k:=1 to n do
       e[i,k]:=e[i,k]/a[i,i];
      for j:=succ(i) to n do
{2}    begin
        for k:=succ(i) to n do
         a[j,k]:=a[j,k]-a[i,k]*a[j,i];
        for k:=1 to n do
        e[j,k]:=e[j,k]-e[i,k]*a[j,i];
{2}    end;
{1} end;
     { ainv calculation}
    for k:=1 to n do
{1} begin
     ainv[n,k]:=e[n,k];
     for i:=pred(n) downto 1 do
{2}   begin
       max:=e[i,k];
       for j:=succ(i) to n do
        max:=max-a[i,j]*ainv[j,k];
       ainv[i,k]:=max;
{2}   end;
{1}  end;
  end;
 procedure matvec(a:matrix;b:vector;var c:vector;n:integer);
  var i,j:integer;r:real;
  begin
   for i:=1 to n do
    begin
     r:=0.0;
     for j:=1 to n do
      r:=r+a[i,j]*b[j];
     c[i]:=r;
    end;
  end;
 function det(a:matrix;n:integer):real;
  var i,j,k:integer;d:real;
  begin
   for i:=1 to pred(n) do
    begin
     if abs(a[i,i])<1E-10 then begin det:=0.0;exit end;
     for j:=succ(i) to n do
      begin
       d:=a[j,i]/a[i,i];
       for k:=i to n do
        a[j,k]:=a[j,k]-d*a[i,k];
      end;
    end;
   d:=1.0;
   for i:=1 to n do
    d:=d*a[i,i];
   det:=d;
  end;
 procedure matconst(c:real;a:matrix;var b:matrix;n:integer);
 var i,j:integer;
 begin
  for i:=1 to n do
   for j:=1 to n do
    b[i,j]:=c*a[i,j];
 end;
 procedure matcadd(c1:real;a1:matrix;c2:real;a2:matrix;var b:matrix;n:integer);
 var i,j:integer;
 begin
  for i:=1 to n do
   for j:=1 to n do
    b[i,j]:=c1*a1[i,j]+c2*a2[i,j];
 end;
 procedure compress(a:matrix;var b:matrix;n:integer;s:sett);
 var i,j,k,l:integer;
  begin
   k:=1;
   for i:=1 to pred(n) do
    if i in s then
     begin
      l:=1;
      b[k,k]:=a[i,i];
      for j:=succ(i) to n do
       if j in s then
        begin
         b[k,l]:=a[i,j];
         b[l,k]:=a[i,j];
         inc(l);
        end;
      inc(k);
     end;
  end;
 function distance(a,b:vector;n:integer):real;
 var i:integer;r:real;
 begin
  r:=0;
  for i:=1 to n do
   r:=r+sqr(a[i]-b[i]);
  distance:=sqrt(r);
 end;
Procedure Transpose(var A:Matrix;M,N:Integer);
var i,j:Integer;Tmp:Real;
begin
 For i:=1 to n do
  for j:=i+1 to m do
   begin
    Tmp:=A[i,j];
    A[i,j]:=A[j,i];
    A[J,i]:=Tmp;
   end;
end;
Procedure EMatrix(var A:Matrix;N:Integer);
var I:Integer;
begin
  FillChar(A,SizeOf(A),0);
  For i:=1 to n do
   A[i,i]:=1.0;
end;

end.


