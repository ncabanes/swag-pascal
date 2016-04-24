(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0026.PAS
  Description: DOS Exec with full memory
  Author: THILO WAGNER
  Date: 11-26-94  05:02
*)

(*
> Can anyone post some code on swapping a TP (7.0) program out of
> memory and executing a batch file (or EXE file; show both if they're
> different please). Thanx.  [I can do it in assembly... :)... but
> Pascal's a different story].

With this you must increase the maximum heap with {$M....}. But I found a
very good exec-Routine, which gives all the heap free before executing the
shell:
*)

Function DosShell(command:String):Integer;Var
 OldHeapEnd,
 NewHeapEnd: Word;
 Error:Integer;
Begin
 Error:=0;
 If MemAvail<$1000 then Error:=8;
 If Error=0 then Begin
  NewHeapEnd:=Seg(HeapPtr^)-PrefixSeg;
  OldHeapEnd:=Seg(HeapEnd^)-PrefixSeg;
   asm
    mov ah,4Ah
    mov bx,NewHeapEnd
    mov es,PrefixSeg
    Int 21h
    jnc @EXIT
    mov Error,ax
    @EXIT:
   end; {asm}
  If Error=0 then begin
   SwapVectors;
   Exec(GetEnv('COMSPEC'),command);
   SwapVectors;
    asm
     mov ah,4Ah
     mov bx,OldHeapEnd
     mov es,PrefixSeg
     Int 21h
     jnc @EXIT
     mov Error,ax
     @EXIT:
    end; {asm}
  end;   {If}
 end;    {If}
 DosShell:=Error;
end;     {Function}

Procedure LittleShellDemo;
Begin
 DosShell('');               { a simple DOS-Shell }
 DosShell('/c TEST.BAT');    { Start the batch-file TEST.BAT }
End;

