(*
  Category: SWAG Title: PARSING/TOKENIZING ROUTINES
  Original name: 0012.PAS
  Description: Infix to Postfix expression parser #2
  Author: HARRY MARX
  Date: 05-31-96  09:16
*)

{
>      Is there a standard of "best" algorithm used to convert algebraic format
> statements, such as a Pascal assignment statement, to a postfix format, such
> as usually used inside the compiler in preparation to generating machine
> language object file?

>      Or, to put it another way, what is the best know way to convert
>           X := 4*(Lastval + Curval)/3.0;
>      to
>           Lastval, Curval + 4 * 3.0 /
>       ?
>                                        Joel Lichtenwalner


I don't know about the best or standard, but I recently wrote a procedure
that does this without using any recursion or stacks. OK, it uses a few
array's to hold few WORD's.

What's nice about it is that it allows for only 4 temperary values to be
stored, which can be expanded to mean AX,BX,CX and DX. (You can increase this
to whatever you want) What's even nicer is that I have not been able to
write an infix expression complex enough to use more than 2 of the 4
temperary variables! It's very short, so I added it to the message (you may
flame me with your newest gem ... :)
{-----------------------------------------------------------------------}

const

   OpChars = ['+','-','/','*']; {These two sets must be mutually exclusive}

   SymbolChars=['a'..'z','A'..'Z','0'..'9','.','_'];



const

   TempVars:string='adcb';{The 4 temporary variables (or registers)}

function GetTempResult(s:string):char;
{Returns the best place to store the temporary result}
   var n,c:integer; p:array[1..5] of byte;
   begin
      c:=0;
      for n:=1 to length(s) do if s[n] in ['a'..'d'] then begin
         inc(c);
         p[c]:=n;
      end;
      case c of
         0:begin
            GetTempResult:=TempVars[1];
            delete(TempVars,1,1);
         end;
         1:GetTempResult:=s[p[1]];
         else begin
            for n:=2 to c do TempVars:=s[p[n]]+TempVars;
            GetTempResult:=s[p[1]];
         end;
      end;
   end;

function Priority(s:string):byte;
{Returns the oprator's priority}
   begin
      if length(s)=1 then
         case s[1] of
            '+','-':Priority:=0;
            '*','/':Priority:=1;
         end
      else;
   end;

procedure Error(S:string);
{Reports an error}
   begin
      writeln(';***Error***: ',S);
      Halt;
   end;

function PostFix(InFix:string):string;
   var
      Ops:array[1..255] of byte;{Allows only <=255 operators in one...}
      Pri:array[1..255] of word;{...expression}
      OC,n,L,R,Shell,MaxOp:integer;
      LS,Op,RS:string;
   begin
      OC:=0;
      Shell:=0;
      MaxOp:=1;
      n:=1;
      while n<=length(InFix) do begin
         if Infix[n] in OpChars then begin
            R:=n;
            while (R<length(InFix)) and (InFix[R] in OpChars) do inc(R);
            Op:=copy(InFix,n,R-n);
            inc(OC);
            Ops[OC]:=n;
            Pri[OC]:=Priority(Op)+Shell;
            if Pri[OC]>=Pri[MaxOp] then MaxOp:=OC;
            n:=R-1;
         end else
         case InFix[n] of
            '(':inc(Shell,100);{Allows for 100 levels of priorities...}
            ')':dec(Shell,100);{...for operators}
         end;
         inc(n);
       end;
       if Shell>0 then Error('Too few ")".');{Although I report this errors...}
       if Shell<0 then Error('Too few "(".');{... the procedure still works...}
                                             {...if you don't}
       while OC>0 do begin
          n:=Ops[MaxOp]-1;  {Read Left Parameter}
          while (n>0) and not(InFix[n] in SymbolChars) do dec(n);
          L:=n;
          while (L>0) and (InFix[L] in SymbolChars) do dec(L);
          LS:=copy(InFix,L+1,n-L);

          n:=Ops[MaxOp]+1; {Read Right Paramter}
          while (n<=length(InFix)) and not(InFix[n] in SymbolChars) do inc(n);
          R:=n;
          while (R<=length(InFix)) and (InFix[R] in SymbolChars) do inc(R);
          RS:=copy(InFix,n,R-n);
          {PS. Only allows for 2 parameter ops.}

          Op:=GetTempResult(LS+RS);
          writeln(LS,RS,InFix[Ops[MaxOp]],' -> ',Op);

          InFix[L+1]:=Op[1]; InFix[L+2]:=' ';
          InFix[R-1]:=Op[1]; InFix[R-2]:=' ';

          dec(OC);
          for n:=MaxOp to OC do begin
             Pri[n]:=Pri[n+1];
             Ops[n]:=Ops[n+1];
          end;
          if MaxOp>OC then dec(MaxOp);
          while (MaxOp>1) and (Pri[MaxOp-1]>Pri[MaxOp]) do dec(MaxOp);
       end;
       PostFix:=Op;
    end;


 var Infix:string;
 begin
    Infix:='(A+B)+(B/B+A*(C-D)+(E-F*G+H))';
    writeln(InFix);
    writeln(PostFix(InFix));
    readln;
 end.

