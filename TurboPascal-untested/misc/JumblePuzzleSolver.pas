(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0163.PAS
  Description: Jumble puzzle solver
  Author: CAMERON CLARK
  Date: 11-22-95  13:28
*)

{
    For those of you out there that really hate getting stuck on a "jumble"
type puzzle, here's a program to solve yer problem.

  [EG. GILTH = ?   LIGHT]

    For those of you who don't really quite know how important recursive
programming is, study and enjoy. The first example [unjumble2] is shorter than
[unjumble1] but it is very inefficient.
}

{$A+,B-,D+,E-,F-,G+,I-,L+,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{$M 8192,0,655360}

 
{ Swag Ready }
 
program jumble;
{: Can be used to solve that popular "Jumble"(R) puzzle :}
 
 
{ Takes a string and finds all the possiblites of }
{ a scrabmled word.                               }
 
 
{ possiblities len ^ lenth power }
{ with replacement               }
 
procedure unjumble2( S : string );      { unefficient }
VAR count : longInt;

procedure rec( O,S : string; N,len : byte);
VAR I : byte;
 
begin
  IF  n > len then begin
      if  (count mod (80 div (len +2 ))) =0 then Writeln;
      inc( count );
      write( S:len+1 );
 
  end else begin
      For I := 1 to len do begin
          s[n] := o[I];
          Rec(o,S, (N+1), len);
      end;
  end;
end;
 
 
begin
  count := 1;
  rec( s,s, 1,ord(s[0]));
  writeln;
  writeln(count);
end;
 
 
 
{ possibilities len! factorial }
{ without replacement          }
 
procedure unjumble( S : string );       { unefficient }
VAR T     : char;
    Count : longInt;
 
 
procedure rec2( o : string; n,len : byte) ;
VAR I : byte;
begin
  IF  n > len then begin
      if  (count mod (80 div (len +2 ))) =0 then Writeln;
      inc ( count );
      write( o:len+1 );
  end else begin
      For I := n to len do begin
          IF  I <> n then begin
              t := o[n];
              o[n] := o[I];
              o[i] := T;
          end;
          Rec2(o, (N+1), len);
      end;
  end;
end;
 

begin
  count := 1;
  rec2(S,1,ord(s[0]));
  writeln;
  writeln(count);
end;
 
 
begin
unjumble2('snac'); { "cans" backwards }  { 4 = 256 possibilites }
unjumble ('snac');                       { 4!  = 24  possibilites }
end.


[end code]

NOTE: A ten letter word will have 100,000,000,000 poss's via unjumble2
      and 3,628,800 via unjumble - obviously your computer might fail
      before then.

