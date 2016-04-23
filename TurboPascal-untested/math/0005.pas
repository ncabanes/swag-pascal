Program Gauss_Elimination;

Uses Crt,Printer;

(***************************************************************************)
(* STEPHEN ABRAHAM                                                         *)
(* MCEN 3030 Comp METHODS                                                  *)
(* ASSGN #3                                                                *)
(* DUE: 2-12-93                                                            *)
(*                                                                         *)
(* GAUSS ELIMinATION (TURBO PASCAL VERSION by STEPHEN ABRAHAM)             *)
(*                                                                         *)
(***************************************************************************)
{                                                                           }
{                                                                           }
{------------------VarIABLE DECLARATION and  DEFinITIONS--------------------}

Const
  MAXROW = 50; (* Maximum # of rows in a matrix    *)
  MAXCOL = 50; (* Maximum # of columns in a matrix *)

Type
  Mat_Array = Array[1..MAXROW,1..MAXCOL] of Real; (* 2-D Matrix of Reals *)
  Col_Array = Array[1..MAXCOL] of Real; (* 1-D Matrix of Real numbers    *)
  Int_Array = Array[1..MAXCOL] of Integer; (* 1-D Matrix of Integers     *)

Var
  N_EQNS      : Integer;   (* User Input : Number of equations in system  *)
  COEFF_MAT   : Mat_Array; (* User Input : Coefficient Matrix of system   *)
  COL_MAT     : Col_Array; (* User Input : Column matrix of Constants     *)
  X_MAT       : Col_Array; (* OutPut : Solution matrix For unknowns       *)
  orDER_VECT  : Int_Array; (* Defined to pivot rows where necessary       *)
  SCALE_VECT  : Col_Array; (* Defined to divide by largest element in     *)
                           (* row For normalizing effect                  *)
  I,J,K       : Integer;   (* Loop control and Array subscripts           *)
  Ans         : Char;      (* Yes/No response to check inputted matrix    *)


{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}



{^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^}
{>>>>>>>>>>>>>>>>>>>>>>>>>   ProcedureS    <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<}
{...........................................................................}


Procedure Home;  (* clears screen and positions cursor at (1,1)            *)
begin
   ClrScr;
   GotoXY(1,1);
end; (* Procedure Home *)

{---------------------------------------------------------------------------}


Procedure Instruct;  (* provides user instructions if wanted               *)

Var
  Ans : Char;  (* Yes/No answer by user For instructions or not            *)

begin
   Home; (* calls Home Procedure *)
   GotoXY(22,8); Writeln('STEVE`S GAUSSIAN ELIMinATION Program');
   GotoXY(36,10); Writeln('2-12-92');
   GotoXY(31,18); Write('Instructions(Y/N):');
   GotoXY(31,49); readln(Ans);
   if Ans in ['Y','y'] then
   begin
     Home; (* calls Home Procedure *)
     Writeln('  Welcome to Steve`s Gaussian elimination Program.  With this');
     Writeln('Program you will be able to enter the augmented matrix of    ');
     Writeln('your system of liNear equations and have returned to you the ');
     Writeln('solutions For each unknown.  The Computer will ask you to    ');
     Writeln('input the number of equations in your system and will then   ');
     Writeln('have you input your coefficient matrix and then your column  ');
     Writeln('matrix.  Please remember For n unknowns, you will need to    ');
     Writeln('have n equations.  ThereFore you should be entering a square ');
     Writeln('(nxn) coefficient matrix.  Have FUN!!!!                      ');
     Writeln('(hit <enter> to continue...)');  (* Delay *)
     readln;
   end;
end;


{---------------------------------------------------------------------------}


Procedure Initialize_Array( Var Coeff_Mat : Mat_Array ;
                            Var Col_Mat,X_Mat, Scale_Vect : Col_Array;
                            Var order_Vect : Int_Array);

(*** This Procedure initializes all matrices to be used in Program       ***)
(*** ON ENTRY : Matrices have undefined values in them                   ***)
(*** ON Exit  : All Matrices are zero matrices                           ***)


Const
  MAXROW = 50; { maximum # of rows in matrix    }
  MAXCOL = 50; { maximum # of columns in matrix }

Var
  I : Integer; { I & J are both loop control and Array subscripts }
  J : Integer;

begin
  For I :=  1 to MaxRow do   { row indices }
  begin
    Col_Mat[I]    := 0;
    X_Mat[I]      := 0;
    order_Vect[I] := 0;
    Scale_Vect[I] := 0;
    For J := 1 to MaxCol do   { column indices }
      Coeff_Mat[I,J] := 0;
  end;
end; (* Procedure initialize_Array *)


{---------------------------------------------------------------------------}

Procedure Input(Var N : Integer;
                Var Coeff_Mat1 : Mat_Array;
                Var Col_Mat1 : Col_Array);

(*** This Procedure lets the user input the number of equations and the  ***)
(*** augmented matrix of their system of equations                       ***)
(*** ON ENTRY : N => number of equations : UNDEFinED
                Coeff_Mat1 => coefficient matrix : UNDEFinED
                Col_Mat1 => column matrix :UNDEFinED
     ON Exit  : N => # of equations input by user
                Coeff_Mat1 => defined coefficient matrix
                Col_Mat1 => defined column matrix input by user          ***)



Var
  I,J : Integer;  (* loop control and Array indices *)

begin
  Home; (* calls Procedure Home *)
  Write('Enter the number of equations in your system: ');
  readln(N);
  Writeln;
  Writeln('Now you will enter your coefficient and column matrix:');
  For I := 1 to N do     { row indice }
  begin
    Writeln('ROW #',I);
    For J := 1 to N do   {column indice }
    begin
      Write('a(',I,',',J,'):');
      readln(Coeff_Mat1[I,J]);    {input of coefficient matrix}
    end;
    Write('c(',I,'):');
    readln(Col_Mat1[I]);          {input of Constant matrix}
  end;
  readln;
end;  (* Procedure Input *)


{---------------------------------------------------------------------------}


Procedure Check_Input( Coeff_Mat1 : Mat_Array;
                          N : Integer; Var Ans : Char);

(*** This Procedure displays the user's input matrix and asks if it is  ***)
(*** correct.                                                           ***)
(*** ON ENTRY : Coeff_Mat1 => inputted matrix
                N => inputted number of equations
                Ans => UNDEFinED                                        ***)
(*** ON Exit  : Coeff_Mat1 => n/a
                N => n/a
                Ans => Y,y or N,n                                       ***)


Var
  I,J   : Integer;  (* loop control and Array indices *)

begin
  Home; (* calls Home Procedure *)
  Writeln; Writeln('Your inputted augmented matrix is:');Writeln;Writeln;

  For I := 1 to N do   { row indice }
  begin
    For J := 1 to N do { column indice }
      Write(Coeff_Mat[I,J]:12:4);
    Writeln(Col_Mat[I]:12:4);
  end;
  Writeln; Write('Is this your desired matrix?(Y/N):'); (* Gets Answer *)
  readln(Ans);
end;  (* Procedure Check_Input *)


{---------------------------------------------------------------------------}


Procedure order(Var Scale_Vect1 : Col_Array;
                Var order_Vect1 : Int_Array;
                Var Coeff_Mat1  : Mat_Array;
                    N           : Integer);

(*** This Procedure finds the order and scaling value For each row of the
     inputted coefficient matrix.                                        ***)
(*** ON ENTRY : Scale_Vect1 => UNDEFinED
                order_Vect1 => UNDEFinED
                Coeff_Mat1  => as inputted
                N           => # of equations
     ON Exit  : Scale_Vect1 => contains highest value For each row of the
                               coefficient matrix
                order_Vect1 => is assigned the row number of each row from
                               the coefficient matrix in order
                Coeff_Mat   => n/a
                N           => n/a                                      ***)


Var
  I,J : Integer;  {loop control and Array indices}

begin
For I := 1 to N do
  begin
    order_Vect1[I] := I;  (* ordervect gets the row number of each row *)
    Scale_Vect1[I] := Abs(Coeff_Mat1[I,1]); (* gets the first number of each row *)
    For J := 2 to N do { goes through the columns }
      begin  (* Compares values in each row of the coefficient matrix and
                stores this value in scale_vect[i] *)
        if Abs(Coeff_Mat1[I,J]) > Scale_Vect1[I] then
           Scale_Vect1[I] := Abs(Coeff_Mat1[I,J]);
      end;
  end;
end;  (* Procedure order *)


{---------------------------------------------------------------------------}


Procedure Pivot(Var Scale_Vect1 : Col_Array;
                    Coeff_Mat1  : Mat_Array;
                Var order_Vect1 : Int_Array;
                    K,N         : Integer);

(*** This Procedure finds the largest number in each column after it has been
     scaled and Compares it With the number in the corresponding diagonal
     position. For example, in column one, a(1,1) is divided by the scaling
     factor of row one. then each value in the matrix that is in column one
     is divided by its own row's scaling vector and Compared With the
     position above it. So a(1,1)/scalevect[1] is Compared to a[2,1]/scalevect[2]
     and which ever is greater has its row number stored as pivot. Once the
     highest value For a column is found, rows will be switched so that the
     leading position has the highest possible value after being scaled. ***)

(*** ON ENTRY : Scale_Vect1 => the normalizing value of each row
                Coeff_Mat1  => the inputted coefficient matrix
                order_Vect1 => the row number of each row in original order
                K           => passed in from the eliminate Procedure
                N           => number of equations
     ON Exit  : Scale_Vect  => same
                Coeff_Mat1  => same
                order_Vect  => contains the row number With highest scaled
                               value
                k           => n/a
                N           => n/a                                      ***)

Var
  I           : Integer; {loop control and Array indice }
  Pivot, Idum : Integer; {holds temporary values For pivoting }
  Big,Dummy   : Real; {used to Compare values of each column }
begin
  Pivot := K;
  Big := Abs(Coeff_Mat1[order_Vect1[K],K]/Scale_Vect1[order_Vect1[K]]);
  For I := K+1 to N do
    begin
    Dummy := Abs(Coeff_Mat1[order_Vect1[I],K]/Scale_Vect1[order_Vect1[I]]);
    if Dummy > Big then
    begin
      Big := Dummy;
      Pivot := I;
    end;
    end;
  Idum := order_Vect1[Pivot];              { switching routine }
  order_Vect1[Pivot] := order_Vect1[K];
  order_Vect1[K] := Idum;
end; { Procedure pivot }


{---------------------------------------------------------------------------}

Procedure Eliminate(Var Col_Mat1, Scale_Vect1 : Col_Array;
                    Var Coeff_Mat1 : Mat_Array;
                    Var order_Vect1 : Int_Array;
                    N : Integer);


Var
  I,J,K       : Integer;
  Factor      : Real;

begin
 For K := 1 to N-1 do
 begin
   Pivot (Scale_Vect1,Coeff_Mat1,order_Vect1,K,N);
   For I := K+1 to N do
   begin
     Factor := Coeff_Mat1[order_Vect1[I],K]/Coeff_Mat1[order_Vect1[K],K];
     For J := K+1 to N do
     begin
       Coeff_Mat1[order_Vect1[I],J] := Coeff_Mat1[order_Vect1[I],J] -
                                        Factor*Coeff_Mat1[order_Vect1[K],J];
     end;
   Col_Mat1[order_Vect1[I]] := Col_Mat1[order_Vect1[I]] - Factor*Col_Mat1[order_Vect1[K]];
   end;
 end;
end;


{---------------------------------------------------------------------------}


Procedure Substitute(Var Col_Mat1, X_Mat1 : Col_Array;
                         Coeff_Mat1 : Mat_Array;
                     Var order_Vect1 : Int_Array;
                     N : Integer);

(*** This Procedure will backsubstitute to find the solutions to your
     system of liNear equations.
     ON ENTRY : Col_Mat => your modified Constant column matrix
                X_Mat1  => UNDEFinED
                Coeff_Mat1 => modified into upper triangular matrix
                order_Vect => contains the order of your rows
                N          => number of equations
     ON Exit  : Col_Mat => n/a
                X_MAt1  => your solutions !!!!!!!!!!!!!
                Coeff_Mat1 => n/a
                order_Vect1 => who cares
                N           => n/a                                      ***)


Var
  I, J  : Integer; (* loop and indice of Array control *)
  Sum   : Real;    (* used to sum each row's elements *)

begin
  X_Mat1[N] := Col_Mat1[order_Vect1[N]]/Coeff_Mat1[order_Vect1[N],N];
  (***** This gives you the value of x[n] *********)

  For I := N-1 downto 1 do
  begin
    Sum := 0.0;
    For J := I+1 to N do
      Sum := Sum + Coeff_Mat1[order_Vect1[I],J]*X_Mat1[J];
    X_Mat1[I] := (Col_Mat1[order_Vect1[I]] - Sum)/Coeff_Mat1[order_Vect1[I],I];
  end;
end;   (** Procedure substitute **)


{---------------------------------------------------------------------------}


Procedure Output(X_Mat1: Col_Array; N : Integer);

(*** This Procedure outputs the solutions to the inputted system of     ***)
(*** equations                                                          ***)
(*** ON ENTRY : X_Mat1 => the solutions to the system of equations
                N => the number of equations
     ON Exit  : X_Mat1 => n/a
                N => n/a                                                ***)


Var
  I    : Integer; (* loop control and Array indice *)

begin
  Writeln;Writeln;Writeln; (* skips lines *)
  Writeln('The solutions to your sytem of equations are:');
  For I := 1 to N do
  Writeln('X(',I,') := ',X_Mat1[I]);
end;   (* Procedure /output *)



{---------------------------------------------------------------------------}
(*                                                                         *)
(*                                                                         *)
(*                                                                         *)
(***************************************************************************)

begin

  Repeat
    Instruct;  (* calls Procedure Instruct *)
    Initialize_Array(Coeff_Mat, Col_Mat, X_Mat, Scale_Vect, order_Vect);
             (* calls Procedure Initialize_Array *)
    Repeat
      Input(N_EQNS, Coeff_Mat, Col_Mat); (* calls Procedure Input *)
      Check_Input(Coeff_Mat,N_EQNS,Ans); (* calls Procedure check_Input *)
    Until Ans in ['Y','y']; (* loops Until user inputs correct matrix *)

    order(Scale_Vect,order_Vect,Coeff_Mat,N_EQNS); (* calls Procedure order *)
    Eliminate(Col_Mat,Scale_Vect,Coeff_Mat,order_Vect,N_EQNS);   (*etc..*)
    Substitute(Col_Mat,X_Mat,Coeff_Mat,order_Vect,N_EQNS);       (*etc..*)
    Output(X_Mat,N_EQNS);                                        (*etc..*)

    Writeln;
    Write('Do you wish to solve another system of equations?(Y/N):');
    readln(Ans);
  Until Ans in ['N','n'];


end. (*************** end of Program GAUSS_ELIMinATION *******************)
