PROGRAM Fact;
{************************************************
* FACTOR - Lookup table demonstration using the        *
* factorial series.                                                                      *
*                                               *
*************************************************}

{$N+,E+}     {Set so you can use other real types}
USES Crt,Dos,Timer;   { t1Start, t1Get, t1Format }
CONST
   BigFact = 500;  {largest factorial is for 1754}
TYPE   {defined type for file definition later}
    TableType = ARRAY [0..BigFact] OF Extended;
VAR
   Table : TableType;

{************************************************
* factorial - compute the factorial of a number        *
*                                               *
* INP:        i - the # to compute the factorial of        *
* OUT:        The factorial of the number, unless a        *
*                number greater than BIG_FACT or less      *
*                than zero is passed in (which results     *
*                in 0.0).                                  *
*************************************************}

FUNCTION Factorial(I: Integer): Extended;
VAR
   K : Integer;
        F : Extended;
BEGIN
        IF I = 0 THEN
                F := 1
        ELSE
       BEGIN
          IF (I > 0) AND (I <= BigFact) THEN
             BEGIN
                F := 1;
                FOR K := 1 TO I DO
                   F := F * K
             END
          ELSE
             F := 0
       END;
        Factorial := F
END;

{************************************************
* Main - generate & save table of factorials    *
*************************************************}

VAR
   I, J, N            : Integer;
   F                  : Extended;
   T1, T2, T3         : Longint;
   Facts              : FILE OF TableType;
BEGIN
        { STEP 1 - compute each factorial 5 times }
   ClrScr;
        WriteLn('Now computing each factorial 5 times');
        T1 := tStart;
        FOR I :=0 TO 4 DO
                FOR J := 0 TO BigFact DO
                        F := Factorial(J);              { f=j! }
        T2 := tGet;
        WriteLn('Computing all factorials from 0..n ');
        WriteLn('5 times took ',tFormat(T1,T2),
                ' secs.');
   WriteLn;
        { STEP 2 - compute the table, then look up
                                 each factorial 5 times.                        }
        WriteLn('Now compute table and look up each ',
                'factorial 5 times.');
        T1 := tStart;
        FOR I := 0 TO BigFact DO
                Table[I] := Factorial(I);
        T2 := tGet;
        FOR I := 0 TO 4 DO
                FOR J :=0 TO BigFact DO
                        F := Table[J]; { f=j! }
        T3 := tGet;
        WriteLn('Computing table took ',tFormat(T1,T2),
                ' seconds');
        WriteLn('Looking up each factorial 5 times to',
           'ok ',tFormat(T2,T3),' seconds');
        WriteLn('Total: ',tFormat(T1,T3),' seconds');
   WriteLn;
{STEP 3 - Compute each factorial as it is needed}
        WriteLn('Clearing the table,',
                ' and computing each ');
        WriteLn('factorial as it is needed',
                ' (for 5) lookups.');
   WriteLn;
        T1 := tStart;
        FOR I := 0 TO BigFact DO
                Table[I] := -1;            { unknown Val }
        FOR I := 0 TO 4 DO
                FOR J := 0 TO BigFact DO
           BEGIN
                        F := Table[J];
                        IF F < 0 THEN
                                BEGIN
                                  F := Factorial(J);
                        Table[J] := F    { F = J! }
                END
           END;
        T2 := tGet;
        WriteLn('Clearing table and computing each');
        WriteLn(' factorial as it was needed for 5');
   WriteLn('lookups took ',tFormat(T1,T2),
           ' secs.');
        { STEP 4 - write the table to disk (we are
     not timing this step, because if you are
     loading it from disk,        you presumably do not
     care how long it took to compute it.      }
   Assign(Facts,'Fact_tbl.tmp');
   Rewrite(Facts);
   Write(Facts,Table);
        Close(Facts);
        { Flush the disk buffer, so that the time
          is not affected by having the data in a
          disk buffer.                                                                }
        Exec('C:\COMMAND.COM','/C CHKDSK');
        { STEP 5 - read the table from disk, and
                                 use each factorial 5 times                }
        T1 := tStart;
   Assign(Facts,'Fact_tbl.TMP');
   Reset(Facts);
   Read(Facts,Table);
   Close(Facts);
        T2 := tGet;
        FOR I := 0 TO 4 DO
                FOR J :=0 TO BigFact DO
           F := Table[J];                 { f=j! }
        T3 := tGet;
        WriteLn('Reading the Table from disk took ',
                        tFormat(T1,T2),' seconds.');
        WriteLn('Looking up each Factorial 5 times ',
        'to ok took ',tFormat(T2,T3),' seconds.');
        WriteLn('Total: ',tFormat(T1,T3),' seconds.');
   WriteLn;
   WriteLn('Press Enter TO see the factorials');
   ReadLN;
   FOR I:=0 TO BigFact DO
      WriteLn('[',I,'] = ',Table[I]);
end.
