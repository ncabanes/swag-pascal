{
> Ok I am playing and trying to get a unit to do this stuff
> AddFunction( fn : string);  (* add a function name to the loop *)
> RemoveFuction( fn : string); ReadyLoop; StartLoop; EndLoop; ClearLoop;
> basicly the statloop will run ALL the AddFunction'ed functoins til the
> code hits a EndLoop;

You could have an array of procedures/functions... thus:
}

Type
 MyFunction:Function (X,Y,Z:Byte; R:Real; S:String; Var W:Word):String;
 {Create exactly what you need. You probibly only want function:Boolean or
  something}

Var
 Funcs:Array[1..20] Of MyFunction;
 FuncsCount:Byte;

{$F+}
Function Example_My_Func(X,Y,Z:Byte; R:Real; S:String; Var W:Word):String;
Begin
 {Any code here!}
 Example_My_Func:=S+'!';
End;
{$F-}

Procedure Add_Function(Func:MyFunction);
Begin
 Inc(FuncsCount);
 Funcs[FuncsCount]:=Func;
End;

Procedure Call_All_Funcs;
Var
 L:Byte;
 A_Word:Word;
Begin
 For L:=1 To FuncsCount Do
  Writeln(Funcs[FuncsCount](1,2,3,1.55,'Yay',A_Word));
End;

Begin
 FuncsCount:=0; {Initialisation}
 Add_Function(@Example_My_Func);   {<= Not sure if the '@' symbol is needed}
 Call_All_Funcs;
  {Dont need to remove them or anything.}
End.
