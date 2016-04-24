(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0052.PAS
  Description: Dealing Poker
  Author: ANDY MCFARLAND
  Date: 11-02-93  10:32
*)

{ ANDY MCFARLAND }

Var
  pick : Array [1..52] of Byte;
  i, n,
  temp : Word;

begin
  { start With an ordered deck }
  For i := 1 to 52 do
     pick[i] := i ;

  For i:= 52 downto 2 do
  begin                       { [i+1..52] has been shuffled }
     { pick any card in the unshuffled part of the deck }
     n := random(i) + 1 ;     { N in [1..i] }
     temp := pick[n] ;        { exchange pick[i] pick[n] }
     pick[n] := pick[i] ;
     pick[i] := temp ;
  end ;
end;

