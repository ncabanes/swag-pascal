(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Statical Ostack for beginers               │
   └───────────────────────────────────────────────────────────┘ *)

{
      Well, I had a lot of mails about statical stack. Some programers
  write me : The statical stack is difficult to use and they have some
  problems about Record prvok. They have problems with rekord, because
  it is struktured type and ... .
      It is not so difficult to update to this version. This version
  is absolutly easy to undestand. The type record have all variables
  used in rekusion. (for example n,a are used, but v is REKUSIVE
  VARIABLE) You muth not to remember !!! This is usualy mistake.
  This version is for rekpic19.pas. If you want to use this unit
  in your program, you muth use first statical stack or this, but
  you muth to update this in correkt version !

  Update this unit : In record write all parameters for rekusion.
                     Find rekusion variable !
                     Update all paremeters (input/output) in metods
                     in this unit ! (push, pop)
                     Please control positions of parameters in record
                     in our program !
}

unit oStack_b;

interface

Const maxstack=100;

Type prvok=record
                 V,N:integer;
                 A:real
                 End;

           {prvok = item}

     Stack=object
             st: Array[1..maxstack] of prvok;
             vrch: 0..maxstack;
             Procedure init;
             Function  full:boolean;
             Function  empty:boolean;
             Procedure push(v1,n1:integer; a1:real);
             Procedure pop(var v1,n1:integer; var a1:real);
           End;

Implementation

Procedure chyba(s:string);
Begin
writeln(s);
halt;
End;

Procedure Stack.init;
Begin
vrch:=0;
End;

Function Stack.full:boolean;
Begin
full:=vrch=maxstack;
End;

Function Stack.empty:boolean;
Begin
empty:=vrch=0
End;

Procedure Stack.push(v1,n1:integer; a1:real);
Begin
  if full Then chyba('Full stack !')      {Chyba = mistake}
          Else Begin
               Inc(vrch);
               With st[vrch] do begin v:=v1; n:=n1; a:=a1 end;
               End
End;

Procedure Stack.pop(var v1,n1:integer; var a1:real);
begin
  If empty Then chyba('Empty stack !')
           Else Begin
                With st[vrch] do begin v1:=v; n1:=n; a1:=a end;
                Dec(vrch);
                End
End;

end.
