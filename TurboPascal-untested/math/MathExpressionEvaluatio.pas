(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0060.PAS
  Description: Math Expression Evaluatio
  Author: PAT DANT
  Date: 01-27-94  17:37
*)

unit Eval;
interface

  function ExpValue (ExpLine : string; var Error : boolean) : real;

implementation

  function ExpValue (ExpLine : string; var Error : boolean) : real;
  var
    Index            : integer;
    Ltr              : char;
    NextLtr          : char;
    Token            : char;
    TokenValue       : real;

    procedure GetLtr;
    begin {GetLtr}
      Ltr := NextLtr;
      if Index < length (ExpLine) then begin
        Index := succ (Index);
        NextLtr := ExpLine [Index];
      end else begin
        NextLtr := '%';
      end;
    end;

    procedure GetToken;
      procedure GetNum;
        var
          Str : string;
          E   : integer;
      begin
        Str := '0'+Ltr; {Avoids problems if first char is '.'}
        while NextLtr in ['0'..'9'] do begin
          GetLtr;
          Str := Str + Ltr;
        end; {while}
        if NextLtr = '.' then begin
          GetLtr;
          Str := Str + Ltr;
          while NextLtr in ['0'..'9'] do begin
            GetLtr;
            Str := Str + Ltr;
          end; {while}
          Str := Str + '0'; {Avoids problems if last char is '.'}
        end;
        val (Str,TokenValue,E);
        Error := E <> 0;
      end;

    begin {GetToken}
      GetLtr;
      while Ltr = ' ' do GetLtr;
      if Ltr in ['0'..'9','.'] then begin
        GetNum;
        Token := '#';
      end else begin
        Token := Ltr;
      end;
    end;

function Expression : real;
  var
    IExp             : real;

    function Term : real;
    var
      ITerm : real;
      TFact : real;

      function Factor : real;
      var
        IFact : real;

      begin {Factor}
        case Token of
          '(' :
            begin
              GetToken;
              IFact := Expression;
              if Token <> ')' then Error := true;
            end;
          '#' :
            begin
              IFact := TokenValue;
            end;
          else
            Error := true;
        end;
        Factor := IFact;
        GetToken;
      end;

    begin {Term}
      if Token = '-' then begin
        GetToken;
        ITerm := -Factor;
      end else begin
        if Token = '+' then begin
          GetToken;
        end;
        ITerm := Factor;
      end;
      if not Error then begin
        while Token in ['*','/'] do begin
          case Token of
            '*' :
              begin
                GetToken;
                ITerm := ITerm * Factor;
              end;
            '/' :
              begin
                GetToken;
                TFact := Factor;
                if TFact <> 0 then begin
                  ITerm := ITerm / TFact;
                end else begin
                  Error := true;
                end;
              end;
          end; {case}
        end; {while}
      end; {if}
      Term := ITerm;
    end; {Term}

  begin {Expression}
    IExp := Term;
    if not Error then begin
      while Token in ['+','-'] do begin
        case Token of
          '+' :
            begin
              GetToken;
              IExp := IExp + Term;
            end;
          '-' :
            begin
              GetToken;
              IExp := IExp - Term;
            end;
        end; {case}
      end; {while}
    end; {if}
    Expression := IExp;
  end; {Expression}

  begin {ExpValue};
    Error := false;
    Index := 0;
    NextLtr := ' ';
    GetLtr;
    GetToken;
    if Token = '%' then begin
      ExpValue := 0.0;
    end else begin
      ExpValue := Expression;
      if Token <> '%' then Error := true;
    end;
  end;

end.

{ --------------------------------   DEMO  --------------------- }

Program Evaluate;
(* 10/1189  *)
(* Uploaded by Pat Dant  *)
(* Based on the Pascal Unit Eval that allows you to take a string
   and perform a recurssive math function on the string resulting
   in a real answer.
   This Exe version allows the command line argument to be the string
   and will print the answer on the screen at the current cursor position.*)

(* ExpValue unit is designed by Don McIver in his very well written program
   SCB Checkbook Program. Currently version 4.2.*)

Uses  Dos, Crt, Eval;

const
 EvalStrPos           =  1;

var
 EvalString           :  string;
 Answer               :  real;
 EvalError            :  Boolean;

 begin
   ClrScr;
   Answer := 0;
   EvalError := False;
   Answer := ExpValue(ParamStr(EvalStrPos),EvalError );
   if EvalError then begin
      Writeln('Error in Command Line Format : ',Answer:8:2);
      Halt;
   end;
   Write(Answer:8:2);
 end.



