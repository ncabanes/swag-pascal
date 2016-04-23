(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Unit - define stack for rekusion algorithm │
   └───────────────────────────────────────────────────────────┘ *)

   { This unit is useful for programers, who are not undestanding
     rukuzive algorithm. This program save the datas to stack when
     is rekusion working and then you can finger the obligation.
     This unit can be useful for programers, who use this program
     when rekusion is working and then they want to make algorithm
     less rekusion. Here are some commands :

     Prvok (item) date typ of variables changeful
     Init - inicializing the stack before rekusion part
     Full - return true if stack is full of variables else return false
     Emty - return true if stack is empty of variables else return false
     Push - Push data to stack
     Pop  - Pop data from stack
     Chyba (error) - write error situation mesage }

(* Recepe how use this program : You muth have correkt rekusion algorithm!
                                 You muth know all rekusive variables !
                                 Correktly record the variables to structure!
                                 And modify this unit for your work, or
                                 use DynStack.pas
 *)

unit oStack;

interface

const maxstack=100;
                        {Prvok = item}
type Prvok=record v,n:integer; a:real end;
     Stack=Object
             st: array[1..maxstack] of Prvok;
             vrch: 0..maxstack;
             p:prvok;
             Procedure init;
             Function  full:boolean;
             Function  empty:boolean;
             Procedure push(p1:prvok);
             Procedure pop(var p1:prvok);
           End;

Implementation

Procedure Error(s:string);      {Chyba = error}
Begin
writeln(s);
halt;
End;

Procedure Stack.init;
Begin
vrch:=0;
p.v:=0;
p.n:=0;
p.a:=0;
End;

Function Stack.full:boolean;
Begin
full:=vrch=maxstack
End;

Function Stack.empty:boolean;
Begin
Empty:=vrch=0
End;

Procedure Stack.push(p1:prvok);
begin
  if full then Error('Full stack!')
  else
    begin
      inc(vrch);
      with st[vrch] do begin p:=p1 end;
    end
end;

Procedure Stack.pop(var p1:prvok);
Begin
  if empty then Error('Empty stack')
  else
    begin
      with st[vrch] do begin p1:=p; end;
      dec(vrch);
    End
End;

End.
