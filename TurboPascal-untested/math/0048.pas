{
From: WARREN PORTER
Subj: eval
Program to evaluate expressions using a stack. }

const
  Maxstack = 100;

type

  stack = record
        top : 0..Maxstack;
        Item : array[1..Maxstack] of char
        end;

  RealStack = record
        top: 0..Maxstack;
        Item : array[1..Maxstack] of real
        end;

  xptype = record
        oper : char;
        opnd : real
        end;

Function Empty(var A:stack):boolean;

Begin
  Empty:= A.top = 0;
End;

Function Pop(var A:stack):char;

Begin
  if A.Top < 1 then
    begin
      writeln('Attempt to pop an empty stack');
      halt(1)
    end;
  Pop:= A.item[A.top];
  A.top:= A.top - 1
End;

Procedure Push(var A:stack; Nchar:char);

Begin
  if A.Top = Maxstack then
    begin
      writeln('Stack already full');
      halt(1)
    end;
  A.top:= A.top + 1;
  A.item[A.top]:=Nchar
End;

     {The following functions are for the real stack only.}

Function REmpty(var D:RealStack):boolean;

Begin
  REmpty:= D.top = 0;
End;

Function RPop(var D:RealStack):real;

Begin
  if D.Top < 1 then
    begin
      writeln('Attempt to pop an empty RealStack');
      halt(1)
    end;
  RPop:= D.item[D.top];
  D.top:= D.top - 1
End;

Procedure RPush(var D:RealStack; Nreal:real);

Begin
  if D.Top = MaxStack then
    begin
      writeln('Stack already full');
      halt(1)
    end;
  D.top:= D.top + 1;
  D.item[D.top]:=Nreal
End;

Function pri(op1, op2:char):boolean;

var
  tpri: boolean;
Begin
  if op2 = ')' then
    tpri:= true                            else
  if (op1 = '$') and (op2 <> '$') and (op2 <> '(')  then
    tpri:= true                            else
  if (op1 in ['*','/']) and (op2 in ['+','-']) then
    tpri:= true
  else
    tpri:= false;
  pri:= tpri{;
  write('Eval op 1= ',op1, ' op2 = ',op2);
  if tpri= false then
     writeln(' false')
  else
     writeln(' true')}
End;

Function ConvReal(a:real;NumDec:integer):real;

var
   i, tenpower: integer;

Begin
   tenpower:= 1;
   for i:= 1 to NumDec do
      tenpower:= tenpower * 10;
   ConvReal:= a / tenpower
End;

Function ROper(opnd1, opnd2: real; oper: char):real;
Var temp: real;

Begin
   Case oper of
      '+': temp:= opnd1 + opnd2;
      '-': temp:= opnd1 - opnd2;
      '*': temp:= opnd1 * opnd2;
      '/': temp:= opnd1 / opnd2;
      '$': temp:= exp(ln(opnd1) * opnd2)
   End {Case}     ;
   {Writeln(opnd1:6:3,' ',oper,' ',opnd2:6:3 ,' = ',temp:6:3);}
   ROper := temp
End; {R oper}

{Main procedure starts here}

var
  A: stack;
  Inbuff:string[Maxstack];
  len, i, j, NumDecPnt, lenexp: integer;
  temp, opnd1, opnd2, result : real;
  valid, expdigit, expdec, isneg, openok: boolean;
  operators, digits : set of char;
  HoldTop : char;
  B: array[1..Maxstack] of xptype;
  C: array[1..Maxstack] of xptype;
  D: RealStack;

Begin
  digits:= ['0'..'9'];
  operators:= ['$','*','/','+','-','(',')'];
  Writeln('Enter expression to evaluate or RETURN to stop');
  Writeln('A space should follow a minus sign unless it is used to');
  Writeln('negate the following number.  Real numbers with multi-');
  Writeln('digits and decimal point (if needed) may be entered.');
  Writeln;
  Readln(Inbuff);
  len:=length(Inbuff);

  repeat
    i:= 1;
    A.top:= 0;
    valid:= true;
    repeat
      if Inbuff[i] in ['(','[','{'] then
        push(A,Inbuff[i])
      else
        if Inbuff[i] in [')',']','}'] then
          if empty(A) then
            valid:= false
          else
            if (ord(Inbuff[i]) - ord(Pop(A))) > 2 then
              valid:= false;
      i:= i + 1
    until (i > len) or (not valid);
    if not empty(A) then
      valid:= false;
    if not valid then
      Writeln('The expression is invalid')
    else
      Begin
         {Change all groupings to parenthesis}
         for i:= 1 to len do Begin
           if Inbuff[i] in ['[','{'] then
              Inbuff[i]:= '('  else
           if Inbuff[i] in [']','}'] then
              Inbuff[i]:= ')';
           B[i].oper:= ' ';
           B[i].opnd:= 0;
           C[i].oper:= ' ';
           C[i].opnd:= 0    End;

         { The B array will be the reformatted input string.
           The C array will be the postfix expression. }

         i:= 1; j:= 1; expdigit:= false; expdec:= false; isneg:= false;
         while i <= len do
            Begin
               if (Inbuff[i] = '-') and (Inbuff[i + 1] in digits) then
                  Begin
                     isneg:= true;
                     i:= i + 1
                  End;
               if (Inbuff[i] = '.' ) then  Begin
                  i:= i + 1;
                  expdec:= true            End;
               if Inbuff[i] in digits then
                  Begin
                     if expdec then
                        NumDecPnt:= NumDecPnt + 1;
                     if expdigit then
                        temp:= temp * 10 + ord(inbuff[i]) - ord('0')
                     else                  Begin
                        temp:= ord(inbuff[i]) - ord('0');
                        expdigit:= true    End
                  End
               else
                  if expdigit = true then    Begin
                     if isneg then
                        temp:= temp * -1;
                     B[j].opnd:= ConvReal(temp,NumDecPnt);
                     j:= j + 1;
                     expdigit := false;
                     expdec   := false;
                     NumDecPnt:= 0;
                     isneg:= false           End;

               If Inbuff[i] in operators     then Begin
                  B[j].oper:= Inbuff[i];
                  j:= j + 1                       End;

               if not (Inbuff[i] in digits)    and
                  not (Inbuff[i] in operators) and
                  not (Inbuff[i] = ' ') then                Begin
                  Writeln('Found invalid operator: ',Inbuff[i]);
                  valid:= false                             End;

               i:= i + 1;

            End;  {While loop to parse string.}

            if expdigit = true then    Begin
               if isneg then
                  temp:= temp * -1;
               B[j].opnd:= ConvReal(temp,NumDecPnt);
               j:= j + 1;
               expdigit := false;
               expdec   := false;
               NumDecPnt:= 0;
               isneg:= false           End;

      End; {First if valid loop.  Next one won't run if invalid operator}

    if valid then
      Begin
         lenexp:= j - 1;    {Length of converted expression}
         writeln;
         for i:= 1 to lenexp do
            Begin
               if B[i].oper = ' ' then
                  write(B[i].opnd:2:3)
               else
                  write(B[i].oper);
               write(' ')
            End;

         {Ready to create postfix expression in array C }

         A.top:= 0;
         j:= 0;

         for i:= 1 to lenexp do
            Begin
               {writeln('i = ',i);}
               if B[i].oper = ' ' then       Begin
                  j:= j + 1;
                  C[j].opnd:= B[i].opnd      End
               else
                  Begin
                  openok := true;
                     while (not empty(A) and openok and
                           pri(A.item[A.top],B[i].oper)) do
                        Begin
                           HoldTop:= pop(A);
                           if HoldTop = '(' then
                              openok:= false
                           else
                              Begin
                                 j:= j + 1;
                                 C[j].oper:=HoldTop
                              End
                        End;
                     if B[i].oper <> ')' then
                        push(A,B[i].oper);
                  End; {Else}
            End; {For loop}

            while not empty(A) do
               Begin
                  HoldTop:= pop(A);
                  if HoldTop <> '(' then
                     Begin
                        j:= j + 1;
                        C[j].oper:=HoldTop
                     End
               End;

         lenexp:= j;  {Since parenthesis are not included in postfix.}

         for i:= 1 to lenexp do
            Begin
               if C[i].oper = ' ' then
                  write(C[i].opnd:2:3)
               else
                  write(C[i].oper);
               write(' ')
            End;

         {The following evaluates the expression in the real stack}

         D.top:=0;
         for i:= 1 to lenexp do
            Begin
               if C[i].oper = ' ' then
                  Rpush(D,C[i].opnd)
               else
                  Begin
                     opnd2:= Rpop(D);
                     opnd1:= Rpop(D);
                     result:= ROper(opnd1,opnd2,C[i].oper);
                     Rpush(D,result)
                  End {else}
            End; {for loop}
         result:= Rpop(D);
         if Rempty(D) then
            writeln('    = ',result:2:3)
         else
            writeln('    Could not evaluate',chr(7))
      End;

    Readln(Inbuff);
    len:= length(Inbuff)
  until len = 0
End.

