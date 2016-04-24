(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0039.PAS
  Description: Expression Evaluator
  Author: THAI TRAN
  Date: 11-02-93  05:38
*)

{
THAI TRAN

{
I've netmailed you the full-featured version (800 lines!) that will do
Functions, exponentiation, factorials, and has all the bells and whistles,
but I thought you might want to take a look at a simple version so you can
understand the algorithm.

This one only works With +, -, *, /, (, and ).  I wrote it quickly, so it
makes extensive use of global Variables and has no error checking; Use at
your own risk.

Algorithm to convert infix to postfix (RPN) notation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Parse through the entire expression getting each token (number, arithmetic
operator, left or right parenthesis).  For each token, if it is:
 1. an operand (number)        Send it to the RPN calculator
 2. a left parenthesis         Push it onto the operator stack
 3. a right parenthesis        Pop operators off stack and send to RPN
                               calculator Until the a left parenthesis is
                               on top of the stack.  Pop it also, but don't
                               send it to the calculator.
 4. an operator                While the stack is not empty, pop operators
                               off the stack and send them to the RPN
                               calculator Until you reach one With a higher
                               precedence than the current operator (Note:
                               a left parenthesis has the least precendence).
                               Then push the current operator onto the stack.

This will convert (4+5)*6/(2-3) to 4 5 + 6 * 2 3 - /

Algorithm For RPN calculator
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Note:  this Uses a different stack from the one described above.

In RPN, if an operand (a number) is entered, it is just pushed onto the
stack.  For binary arithmetic operators (+, -, *, /, and ^), the top two
operands are popped off the stack, operated on, and the result pushed back
onto the stack.  if everything has gone correctly, at the end, the answer
should be at the top of the stack.


Released to Public Domain by Thai Tran (if that matters).
}

{$X+}
Program Expression_Evaluator;

Const
  RPNMax = 10;              { I think you only need 4, but just to be safe }
  OpMax  = 25;

Type
  String15 = String[15];

Var
  Expression : String;
  RPNStack   : Array[1..RPNMax] of Real;        { Stack For RPN calculator }
  RPNTop     : Integer;
  OpStack    : Array[1..OpMax] of Char;    { Operator stack For conversion }
  OpTop      : Integer;

Procedure RPNPush(Num : Real); { Add an operand to the top of the RPN stack }
begin
  if RPNTop < RPNMax then
  begin
    Inc(RPNTop);
    RPNStack[RPNTop] := Num;
  end
  else  { Put some error handler here }
end;

Function RPNPop : Real;       { Get the operand at the top of the RPN stack }
begin
  if RPNTop > 0 then
  begin
    RPNPop := RPNStack[RPNTop];
    Dec(RPNTop);
  end
  else  { Put some error handler here }
end;

Procedure RPNCalc(Token : String15);                       { RPN Calculator }
Var
  Temp  : Real;
  Error : Integer;
begin
  Write(Token, ' ');                { This just outputs the RPN expression }

  if (Length(Token) = 1) and (Token[1] in ['+', '-', '*', '/']) then
  Case Token[1] of                                   { Handle operators }
    '+' : RPNPush(RPNPop + RPNPop);
    '-' : RPNPush(-(RPNPop - RPNPop));
    '*' : RPNPush(RPNPop * RPNPop);
    '/' :
    begin
      Temp := RPNPop;
      if Temp <> 0 then
        RPNPush(RPNPop/Temp)
      else  { Handle divide by 0 error }
    end;
  end
  else
  begin                   { Convert String to number and add to stack }
    Val(Token, Temp, Error);
    if Error = 0 then
      RPNPush(Temp)
    else  { Handle error }
  end;
end;

Procedure OpPush(Operator : Char);  { Add an operator onto top of the stack }
begin
  if OpTop < OpMax then
  begin
    Inc(OpTop);
    OpStack[OpTop] := Operator;
  end
  else  { Put some error handler here }
end;

Function OpPop : Char;               { Get operator at the top of the stack }
begin
  if OpTop > 0 then
  begin
    OpPop := OpStack[OpTop];
    Dec(OpTop);
  end
  else  { Put some error handler here }
end;

Function Priority(Operator : Char) : Integer; { Return priority of operator }
begin
  Case Operator OF
    '('      : Priority := 0;
    '+', '-' : Priority := 1;
    '*', '/' : Priority := 2;
    else  { More error handling }
  end;
end;

Procedure Evaluate(Expr : String);                                  { Guess }
Var
  I     : Integer;
  Token : String15;
begin
  OpTop  := 0;                                              { Reset stacks }
  RPNTop := 0;
  Token  := '';

  For I := 1 to Length(Expr) DO
  if Expr[I] in ['0'..'9'] then
  begin       { Build multi-digit numbers }
    Token := Token + Expr[I];
    if I = Length(Expr) then          { Send last one to calculator }
      RPNCalc(Token);
  end
  else
  if Expr[I] in ['+', '-', '*', '/', '(', ')'] then
  begin
    if Token <> '' then
    begin        { Send last built number to calc. }
      RPNCalc(Token);
      Token := '';
    end;

    Case Expr[I] OF
      '(' : OpPush('(');
      ')' :
      begin
        While OpStack[OpTop] <> '(' DO
          RPNCalc(OpPop);
        OpPop;                          { Pop off and ignore the '(' }
      end;

      '+', '-', '*', '/' :
      begin
        While (OpTop > 0) AND
              (Priority(Expr[I]) <= Priority(OpStack[OpTop])) DO
          RPNCalc(OpPop);
        OpPush(Expr[I]);
      end;
    end; { Case }
  end
  else;
      { Handle bad input error }

  While OpTop > 0 do                     { Pop off the remaining operators }
    RPNCalc(OpPop);
end;

begin
  Write('Enter expression: ');
  Readln(Expression);

  Write('RPN Expression = ');
  Evaluate(Expression);
  Writeln;
  Writeln('Answer = ', RPNPop : 0 : 4);
end.

