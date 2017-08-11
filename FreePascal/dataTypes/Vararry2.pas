(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0013.PAS
  Description: VARARRY2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

{
>  I'm trying to figure out a way to declair a Variable, such as an
>  Array, and I don't know the size Until I've loaded the Program.
>  I've tried stuff like........
>  Type
>      Buf : Array[1..1000] of Char;
>  Var
>      Buffer : ^Buf
>  begin
>    Getmem(Buffer,xxx)
}

Type
  TElement = LongInt ;     { Here use your own }

Const
  MaxElement = (*65500*) 2000000000 div Sizeof(TElement) ;

Type
  TElementArray = Array[1..MaxElement] of TElement ;
  PElementArray = ^TElementArray ;

Var
  i    : (*word*) longint ;
  Elms : PElementArray ;

begin
  Write('How many of ''em do you feel like using ? :') ;
  ReadLn(i) ;
  if i>MaxElement then
  begin
    WriteLn('That''s more than I can hold, sorry...') ;
    Halt(1) ;
  end ;
  WriteLn('Getting memory...') ;
  GetMem(Elms, i*Sizeof(TElement)) ;

  { Now, use Elms^[1] to Elms^[i] }

  WriteLn('Freeing memory...') ;
  FreeMem(Elms, i*Sizeof(TElement)) ;
end.

{
Please note that the previous allows you to keep range checking on, but that
does not garanty you any security : access to an element which's index is
greater than i would cause no RTE, but writing to it will quite mess up things
in memory...
}
