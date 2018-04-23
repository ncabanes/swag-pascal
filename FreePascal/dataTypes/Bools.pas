(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0003.PAS
  Description: BOOLS.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

{
  This is a small Unit I wrote when I got tired of writing great gobs
  of nested "if thens" or pages of parenthetic blobs.
  With this Unit you can Write as many Boolean expressions
  as you like as a block of Boolean.
  True mode:
       all interior expressions must be True For the block to be True.
       if one interior expression is False then the block is False.
  False mode:
       all interior expressions must be False For the block to be False.
       if one interior expression is True then the block is True.
  Any ideas on enhancing it?
}
Uses
  Crt;

Const
  AllBool  : Boolean = True;
  BoolMode : Boolean = True;

Var
  S : String;

Procedure SetBool(Mode : Boolean);
begin
  AllBool  := Mode;
  BoolMode := Mode;
end;

Procedure Bool(Expression : Boolean);
begin
  if ((BoolMode) and (not Expression)) then
    AllBool := False;
  if ((not BoolMode) and (Expression)) then
    AllBool := True;
end;

begin
  ClrScr;
  S := '1 This is the best there is \.';      {init. String}
  SetBool(True);                {set checkmode For all True}
  Bool( Length(s) > 4 );        {series of Boolean expressions}
  Bool( s[3] in ['A'..'Z'] );
  Bool( Ord(s[1]) - 48 < 10 );
  Bool( Pos('This', s) > 0 );
  Bool( s[Length(s)] = '.');
  Bool( 2 + 3 = 5);
  if AllBool then
    Writeln('1. All expressions are True')
  else
    Writeln('1. At least one expression is False');

  SetBool(False);              {set checkmode For all False}
  Bool( Length(s) > 44 );      {series of Boolean expressions}
  Bool( s[3] in ['a'..'z'] );
  Bool( Ord(s[1]) - 48 > 10 );
  Bool( Pos('This', s) = 0 );
  Bool( s[Length(s)] = 'g');
  Bool( 2 + 3 = 4);
  if not AllBool then
    Writeln('2. All expressions are False')
  else
    Writeln('2. At least one expression is True');
  Readln;
end.
