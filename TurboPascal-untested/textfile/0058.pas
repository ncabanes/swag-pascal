
UNIT seq;

 (*  DESCRIPTION :
       Treatment of sequential files :
  * assign,open,read,selection and count of records,close in ONE Procedure
  * 3 control breaks possible ,either a data base field or a variable of
    type string[30]. Use conversion functions if necessary
  * user-defined selection function
  * heading procedure optional
  * 11 aggregate functions like totals,subtotals,first,last,maximum,minimum

     RELEASE     :  1.0
     DATE        :  17/11/91
     AUTHOR      :  Fernand LEMOINE
                    rue du Collège 34
                    B-6200 CHATELET
                    BELGIQUE
     All code granted to the public domain
     Questions and comments are welcome
     REQUIREMENT :  Turbo Pascal 5.0 or later : procedural parameters
     Compatible with Borland Pascal protected mode
  *)

INTERFACE
USES dos;
CONST
  all = MaxLongInt;

TYPE
  Boolfunc = FUNCTION(VAR buffer) : Boolean;
  Proc = PROCEDURE;
  PProc = PROCEDURE(VAR buffer);
  Str30 = String[30];

VAR
  level : Byte;

(* empty function or procedures for type Boolfunc *)
FUNCTION NoSelect(VAR buffer) : Boolean;
(* empty function or procedures for type PProc *)
PROCEDURE NoPProc(VAR buffer);
(* empty function or procedures for type Proc *)
PROCEDURE NoProc;

(* Number of records selected *)
FUNCTION DCount : LongInt;

(* Necessary in Detail_proc to prepare use of aggregate functions .
increment novar for each numeric variable chosen for computation ,max=10 *)
PROCEDURE DCalc(novar : Byte; nombre : Real);

(* Here begins  aggregate functions *)
(* Subtotal for the variable with the number novar *)
FUNCTION DSum(novar : Byte) : Real;
(* Grand total for the variable with the number novar *)
FUNCTION DTotal(novar : Byte) : Real;
(* Minimum     for the variable with the number novar *)
FUNCTION DMin(novar : Byte) : Real;
(* Maximum     for the variable with the number novar *)
FUNCTION DMax(novar : Byte) : Real;
(* The same as Dcount except for null value           *)
FUNCTION DNCount(novar : Byte) : Real;
(* The same as DMin   except for null value           *)
FUNCTION DNMin(novar : Byte) : Real;
(* Average     for the variable with the number novar *)
FUNCTION DAvg(novar : Byte) : Real;
(* The same as DAvg   except for null value           *)
FUNCTION DNAvg(novar : Byte) : Real;
(* Variance    for the variable with the number novar
  opt = 'P' = population
        'S' = sample    *)
FUNCTION DVar(novar : Byte; opt : char) : Real;
(* Standard deviation for the variable with the number novar
opt = 'P' = population
        'S' = sample    *)
FUNCTION DStd(novar : Byte; opt : char) : Real;
(* The previous value of the variable with the number novar *)
FUNCTION DOld(novar : Byte) : Str30;
(* Here ends  aggregate functions *)

(* Set control break in Break_Proc  : always of type string[30]  *)
PROCEDURE Control(contr1, contr2, contr3 : Str30);

(* Only detail lines (Detail_Proc) and total lines (Final_Proc).
  No control break
  User-defined selection function : boolean type
  Scope = all  : all the records read  otherwise a number of records
  reclen       : size of the record computed by the function sizeof
                                                                        *)

PROCEDURE ReadFile(Name_File : PathStr; scope : LongInt;
                  Select_Func : Boolfunc; Detail_Proc : PProc;
                  Final_Proc : Proc; RecLen : Word);

(*
*  Detail lines (Detail_Proc).
*  1/2/3 subtotal lines and total lines (Total_Proc ). The same procedure
    with the variable level varying from 3 - minor break -  to 0 - grand
    total
*  Control break (Break_Proc)
*  User-defined selection function (Select_Func) : boolean type
*  Scope = all  : all the records read  otherwise a number of records
*  reclen       : size of the record computed by the function sizeof
*)

PROCEDURE ReadBreakFile(Name_File : PathStr;  Break_Proc : PProc;
                       Select_Func : Boolfunc; Detail_Proc : PProc;
                       Heading_Proc, Total_Proc : Proc; RecLen : Word);


IMPLEMENTATION
CONST
 maxlevel = 3;
 maxvar = 10;
 maxcalc = 8;
 maxbuffer = 500;
VAR
 FileSeq : FILE;
 RR : Word;
 Tab_Count : ARRAY[0..maxlevel] OF LongInt;
 Tab_Control, Old_Control : ARRAY[1..maxlevel] OF Str30;
 Old_Total : ARRAY[1..maxvar] OF Real;

 buffer : ARRAY[1..maxbuffer] OF Byte;
 Tab_Calc : ARRAY[1..maxvar, 1..maxcalc, 0..maxlevel] OF Real;
 Endfile  : Boolean;
 nbrlevel : Byte;

 FUNCTION NoSelect(VAR buffer) : Boolean;
 BEGIN
   NoSelect := True;
 END;

 PROCEDURE NoPProc(VAR buffer);
 BEGIN
 END;

 PROCEDURE NoProc;
 BEGIN
 END;

 FUNCTION DCount : LongInt;
 VAR i : Byte;
 BEGIN
   DCount := Tab_Count[level];
 END;

 PROCEDURE DCalc(novar : Byte; nombre : Real);
 VAR
   i : Byte;
 BEGIN
   FOR i := 0 TO nbrlevel DO
   BEGIN
     Tab_Calc[novar, 1, i] := Tab_Calc[novar, 1, i] + nombre;
     IF Tab_Calc[novar, 2, i] < nombre THEN
       Tab_Calc[novar, 2, i] := nombre;
     IF Tab_Count[i] = 1 THEN Tab_Calc[novar, 3, i] := nombre
     ELSE IF Tab_Calc[novar, 3, i] > nombre THEN
       Tab_Calc[novar, 3, i] := nombre;
     IF nombre <> 0 THEN
       Tab_Calc[novar, 4, i] := Tab_Calc[novar, 4, i] + 1;
     IF (Tab_Count[i] = 1) AND (nombre <> 0) THEN
       Tab_Calc[novar, 5, i] := nombre;
     IF Tab_Calc[novar, 5, i] = 0 THEN
       Tab_Calc[novar, 5, i] := nombre;
     IF (Tab_Calc[novar, 5, i] > nombre) AND (nombre <> 0) THEN
       Tab_Calc[novar, 5, i] := nombre;
     Tab_Calc[novar, 6, i] := Tab_Calc[novar, 6, i] + Sqr(nombre);
   END;
 END;

 PROCEDURE DCompute(novar : Byte; nombre : Real);
 BEGIN
   Old_Total[novar] := Old_Total[novar] + nombre;
 END;

 FUNCTION DTotal(novar : Byte) : Real;
 BEGIN
   IF Old_Total[novar] <> 0 THEN
     DTotal := Old_Total[novar]
   ELSE
     DTotal := Tab_Calc[novar, 1, 0];
 END;

 FUNCTION DSum(novar : Byte) : Real;
 BEGIN
   DSum := Tab_Calc[novar, 1, level];
 END;

 FUNCTION DOld(novar : Byte) : Str30;
 BEGIN
   DOld := Old_Control[novar];
 END;

 FUNCTION DMin(novar : Byte) : Real;
 BEGIN
   DMin := Tab_Calc[novar, 3, level];
 END;

 FUNCTION DMax(novar : Byte) : Real;
 BEGIN
   DMax := Tab_Calc[novar, 2, level];
 END;

 FUNCTION DNCount(novar : Byte) : Real;
 BEGIN
   DNCount := Tab_Calc[novar, 4, level];
 END;

 FUNCTION DNMin(novar : Byte) : Real;
 BEGIN
   DNMin := Tab_Calc[novar, 5, level];
 END;

 FUNCTION DAvg(novar : Byte) : Real;
 BEGIN
   IF DCount <> 0 THEN
     DAvg := Tab_Calc[novar, 1, level] / DCount
   ELSE
     DAvg := 0;
 END;

 FUNCTION DNAvg(novar : Byte) : Real;
 BEGIN
   IF DNCount(novar) <> 0 THEN
     DNAvg := Tab_Calc[novar, 1, level] / DNCount(novar)
   ELSE
     DNAvg := 0;
 END;

 FUNCTION DVar(novar : Byte; opt : char) : Real;
 VAR
   Int : Real;
 BEGIN
   Int := Sqr(Tab_Calc[novar, 1, level] / DCount);
   if upcase(opt)  = 'P' then
     DVar := (Tab_Calc[novar, 6, level] - Int) / DCount
   else
     DVar := (Tab_Calc[novar, 6, level] - Int) / (DCount - 1);
 END;

 FUNCTION DStd(novar : Byte; opt : char) : Real;
 VAR
   Int : Real;
 BEGIN
   Int := Sqr(Tab_Calc[novar, 1, level] / DCount);
   if upcase(opt)  = 'P' then
     DStd := Sqrt((Tab_Calc[novar, 6, level] - Int) / DCount)
   else
     DStd := Sqrt((Tab_Calc[novar, 6, level] - Int) / (DCount - 1));
  END;

 (* ---------------------------------------------------------------------- *)

  PROCEDURE ReadFile(Name_File : PathStr; scope : LongInt;
                     Select_Func : Boolfunc; Detail_Proc : PProc;
                     Final_Proc : Proc; RecLen : Word);

    PROCEDURE Debut(Name_File : PathStr);
    VAR i, j, k : Byte;
    BEGIN
      level := 0; nbrlevel := 0;
      Assign(FileSeq, Name_File);
      Reset(FileSeq, RecLen);
      Tab_Count[level] := 0;
      FOR i := 1 TO maxvar DO
        FOR j := 1 TO maxcalc DO
          FOR k := 0 TO maxlevel DO
            Tab_Calc[i, j, k] := 0;
      BlockRead(FileSeq, buffer, 1, RR);
      Endfile := EoF(FileSeq);

    END;

    PROCEDURE rec (Select_Func : Boolfunc; Detail_Proc : PProc);
      PROCEDURE Trait(Detail_Proc : PProc);
      BEGIN
        Tab_Count[level] := Tab_Count[level] + 1;
        Detail_Proc(buffer);
      END;

      PROCEDURE fin_rec ;
      BEGIN
        IF EoF(FileSeq) THEN Endfile := True
        ELSE BlockRead(FileSeq, buffer, 1, RR);
      END;

    BEGIN
      IF Select_Func(buffer) THEN
        Trait(Detail_Proc);
      fin_rec ;
    END;

    PROCEDURE fin(Final_Proc : Proc);
    BEGIN
      Final_Proc;
      Close(FileSeq);
    END;

  BEGIN
    Debut(Name_File);
    WHILE (NOT Endfile) AND (DCount < scope)
    DO rec (Select_Func, Detail_Proc);
    fin(Final_Proc);
  END;
  (* ------------------------------------------------------------------*)
  PROCEDURE Control(contr1, contr2, contr3 : Str30);
  BEGIN
    IF contr1 <> '' THEN
    BEGIN
      Tab_Control[1] := contr1; nbrlevel := 1;
    END;
    IF contr2 <> '' THEN
    BEGIN
      Tab_Control[2] := contr2; nbrlevel := 2;
    END;
    IF contr3 <> '' THEN
    BEGIN
      Tab_Control[3] := contr3; nbrlevel := 3;
    END;
  END;

  PROCEDURE Transfert_Old;
  VAR i : Byte;
  BEGIN
    FOR i := 1 TO nbrlevel DO
      Old_Control[i] := Tab_Control[i];
  END;

  PROCEDURE Trans_Old;
  VAR i : Byte;
  BEGIN
    Old_Control[level] := Tab_Control[level];
  END;

  PROCEDURE Init_Tab(level : Byte);
  VAR
    i, j, k : Byte;
  BEGIN
    FOR i := 1 TO maxvar DO
      FOR j := 1 TO maxcalc DO
        FOR k := level TO nbrlevel DO
          Tab_Calc[i, j, k] := 0;
    FOR i := level TO nbrlevel DO Tab_Count[i] := 0;
  END;

  PROCEDURE ReadBreakFile(Name_File : PathStr; Break_Proc : PProc;
                          Select_Func : Boolfunc; Detail_Proc : PProc;
                          Heading_Proc, Total_Proc : Proc; RecLen : Word);
  VAR i : Byte;

    PROCEDURE Debut(Name_File : PathStr; Break_Proc : PProc);
    VAR i : Byte;
    BEGIN
      level := 0; nbrlevel := 0;
      Assign(FileSeq, Name_File);
      Reset(FileSeq, RecLen);
      BlockRead(FileSeq, buffer, 1, RR);
      Endfile := EoF(FileSeq);
      Break_Proc(buffer);
      Transfert_Old;
    END;

    PROCEDURE Detail(Select_Func : Boolfunc; Detail_Proc, Break_Proc : PProc;
                     VAR Endfile : Boolean);
    VAR i : Byte;
    BEGIN
      
      IF Select_Func(buffer) THEN
      BEGIN
        FOR i := 0 TO nbrlevel DO
          Tab_Count[i] := Tab_Count[i] + 1;
        Detail_Proc(buffer);
        Transfert_Old;
      END;
      IF EoF(FileSeq) THEN Endfile := True
      ELSE BlockRead(FileSeq, buffer, 1, RR);
      Break_Proc(buffer);
    END;

    PROCEDURE Fin(Total_Proc : Proc);
    BEGIN
      level := 0;
      Total_Proc;
      Close(FileSeq);
    END;

    PROCEDURE Debut_Niv(PLevel : Byte; Heading_Proc : Proc);
    BEGIN
      level := PLevel;
      Heading_Proc;
      Init_Tab(PLevel);
    END;

    PROCEDURE Fin_Niv(PLevel : Byte; Total_Proc : Proc);
    BEGIN
      level := PLevel;
      Total_Proc;
      Trans_Old;
    END;

    PROCEDURE Niv3(Heading_Proc : Proc; Select_Func : Boolfunc;
                   Detail_Proc, Break_Proc : PProc;
                   Total_Proc : Proc; VAR Endfile : Boolean);
    BEGIN
      Debut_Niv(3, Heading_Proc);

      WHILE (Tab_Control[1] = Old_Control[1]) AND
      (Tab_Control[2] = Old_Control[2]) AND
      (Tab_Control[3] = Old_Control[3]) AND
      (NOT Endfile) DO
        Detail(Select_Func, Detail_Proc, Break_Proc, Endfile);
      Fin_Niv(3, Total_Proc);
    END;

    PROCEDURE Niv2(Heading_Proc : Proc; Select_Func : Boolfunc;
                   Detail_Proc, Break_Proc : PProc;
                   Total_Proc : Proc; VAR Endfile : Boolean);
    BEGIN
      Debut_Niv(2, Heading_Proc);

      WHILE (Tab_Control[1] = Old_Control[1]) AND
      (Tab_Control[2] = Old_Control[2]) AND (NOT Endfile) DO
      BEGIN
        IF nbrlevel = 2 THEN Detail(Select_Func, Detail_Proc, Break_Proc, Endfile)
        ELSE Niv3(Heading_Proc, Select_Func, Detail_Proc,
                  Break_Proc, Total_Proc, Endfile);
      END;
      Fin_Niv(2, Total_Proc);
    END;

    PROCEDURE Niv1(Heading_Proc : Proc; Select_Func : Boolfunc;
                   Detail_Proc, Break_Proc : PProc;
                   Total_Proc : Proc; VAR Endfile : Boolean);
    BEGIN
      Debut_Niv(1, Heading_Proc);
      WHILE (Tab_Control[1] = Old_Control[1]) AND (NOT Endfile) DO
      BEGIN
        IF nbrlevel = 1 THEN Detail(Select_Func, Detail_Proc, Break_Proc, Endfile)
        ELSE Niv2(Heading_Proc, Select_Func, Detail_Proc,
                  Break_Proc, Total_Proc, Endfile);
      END;
      Fin_Niv(1, Total_Proc);
    END;

  BEGIN
    FOR i := 0 TO maxlevel DO Tab_Count[i] := 0;
    FOR i := 1 TO maxvar DO Old_Total[i] := 0;
    Init_Tab(0);

    FOR i := 0 TO maxlevel DO Tab_Count[i] := 0;
    Debut(Name_File, Break_Proc);
    WHILE NOT Endfile DO Niv1(Heading_Proc, Select_Func,
                              Detail_Proc, Break_Proc, Total_Proc, Endfile);
    Fin(Total_Proc);
  END;

END.

{ -------------------------   DEMO PROGRAM ----------------- }

program demoseq;
uses crt,seq,editform,opstring;
const
 c_pay = 1;

type                               (* cf file demo.dat  *)
        Rec = record
        name  : string[5];
        state : string[2];
        zip   : longint;
        pay   : real;
             end;

    {$F+}        (* --->  necessary   or use far directive   *)

  Function Select (var Buffer): boolean;    (* can be modified by user *)
  begin
  Select := true;
  end;

  Procedure Control_Proc(var Buffer);
  begin
  with Rec(buffer) do
    Control(state,long2str(zip),'');
  end;

  Procedure Detail_Proc(var Buffer);
  begin
  with Rec(buffer) do
   begin
    DCalc(c_pay,pay);
    writeln(name,'   ',state,'  ',zip,'  ',RealForm('####.##',pay));
   end;
  end;

  Procedure Total_Proc;
  begin
  case level of
  0: begin write('Final  '); end;
  1: begin write('State subtotal  '); end;
  2: begin write('Zip subtotal  ');   end;
  end;

  writeln('Count : ',DCount,' STATE: ',Dold(1),' ZIP: ',Dold(2));
  writeln('Max  : ',RealForm('####.##',Dmax(c_pay)),
          ' Min : ',RealForm('####.##',Dmin(c_pay)),
          ' Avg : ',RealForm('#####.##',DAvg(c_pay)),
          ' Sum : ',RealForm('#####.##',DSum(c_pay)),
          ' Total : ',RealForm('#####.##',DTotal(c_pay)));
  if level = 2 then writeln;
  end;

   {$F-}

    begin
   Clrscr;
   Writeln('Demo seq unit , file : demo.dat '); writeln;
   ReadBreakFile('Demo.dat',Control_proc,NoSelect,
      Detail_Proc, Noproc,Total_Proc,SizeOf(Rec));
   delay (2500);
    end.