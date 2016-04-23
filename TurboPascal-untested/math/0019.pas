{
  Hi, to All:

   ...While recently "tuning up" one of my Programs I'm currently
   working on, I ran a little test to Compare the perfomance
   of the different versions of Turbo Pascal from 5.0 through
   to 7.0. The results were quite suprizing, and I thought I'd
   share this With you guys/gals.

   Here are the results of a "sieve" Program to find all the primes
   in 1 - 100,000, running on my AMI 386SX-25 CPU desktop PC:

      CompILER    EXECUTION TIME    RELATIVE TIME FACtoR
      ==================================================
       TP 7.0        46.7 sec              1.00
       TP 6.0       137.8 sec              2.95
       TP 5.5       137.5 sec              2.94
       TP 5.0       137.6 sec              2.95

   Running the same Program to find all the primes in 1 - 10,000,
   running on my 8086 - 9.54 Mhz NEC V20 CPU laptop PC:

      CompILER    EXECUTION TIME    RELATIVE TIME FACtoR
      ==================================================
       TP 7.0        14.1 sec              1.00
       TP 6.0        28.3 sec              2.00

  notE: This would seem to indicate that the TP 7.0 386 math-
        library is kicking in when run on a 386 CPU.

  Here is the source-code to my "seive" Program:
------------------------------------------------------------------------
}
 {.$DEFinE DebugMode}
 {$DEFinE SaveData}

 {$ifDEF DebugMode}
   {$ifDEF VER70}
     {$ifDEF DPMI}
       {$A+,B-,D+,E-,F-,G-,I+,L+,N-,P+,Q+,R+,S+,T+,V+,X-}
     {$else}
       {$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,P+,Q+,R+,S+,T+,V+,X-}
     {$endif}
   {$else}
     {$ifDEF VER60}
       {$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,R+,S+,V+,X-}
     {$else}
       {$A+,B-,D+,E-,F-,I+,L+,N-,O-,R+,S+,V+}
     {$endif}
   {$endif}
 {$else}
   {$ifDEF VER70}
     {$ifDEF DPMI}
       {$A+,B-,D-,E-,F-,G-,I-,L-,N-,P-,Q-,R-,S+,T-,V-,X-}
     {$else}
       {$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S+,T-,V-,X-}
     {$endif}
   {$else}
     {$ifDEF VER60}
       {$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S+,V-,X-}
     {$else}
       {$A+,B-,D-,E-,F-,I-,L-,N-,O-,R-,S+,V-}
     {$endif}
   {$endif}
 {$endif}

              (* Find prime numbers - Guy McLoughlin, 1993.           *)
Program Find_Primes;

  (***** Check if a number is prime.                                  *)
  (*                                                                  *)
  Function Prime({input } lo_in : LongInt) : {output} Boolean;
  Var
    lo_Stop,
    lo_Loop : LongInt;
  begin
    if (lo_in mod 2 = 0) then
      begin
        Prime := (lo_in = 2);
        Exit
      end;
    if (lo_in mod 3 = 0) then
      begin
        Prime := (lo_in = 3);
        Exit
      end;

    if (lo_in mod 5 = 0) then
      begin
        Prime := (lo_in = 5);
        Exit
      end;
    lo_Stop := 7;
    While ((lo_Stop * lo_Stop) <= lo_in) do
      inc(lo_Stop, 2);
    lo_Loop := 7;
    While (lo_Loop < lo_Stop) do
      begin
        inc(lo_Loop, 2);
        if (lo_in mod lo_Loop = 0) then
          begin
            Prime := False;
            Exit
          end
      end;
    Prime := True
  end;        (* Prime.                                               *)

  (***** Check For File IO errors.                                    *)
  (*                                                                  *)
  Procedure CheckIOerror;
  Var
    by_Error : Byte;
  begin
    by_Error := ioresult;
    if (by_Error <> 0) then
      begin
        Writeln('File Error = ', by_Error);
        halt
      end
  end;        (* CheckIOerror.                                        *)

Var
  bo_Temp       : Boolean;
  wo_PrimeCount : Word;
  lo_Temp,
  lo_Loop       : LongInt;
  fite_Data     : Text;

begin
  lo_Temp := 100000;
  {$ifDEF SaveData}
    {$ifDEF VER50}
      assign(fite_Data, 'PRIME.50');
    {$endif}
    {$ifDEF VER55}
      assign(fite_Data, 'PRIME.55');
    {$endif}
    {$ifDEF VER60}
      assign(fite_Data, 'PRIME.60');
    {$endif}
    {$ifDEF VER70}
      assign(fite_Data, 'PRIME.70');
    {$endif}
    {$I-}
    reWrite(fite_Data);
    {$I+}
    CheckIOerror;
    {$endif}
  wo_PrimeCount := 0;
  For lo_Loop := 2 to lo_Temp do
    if Prime(lo_Loop) then
  {$ifDEF SaveData}
      begin
        Write(fite_Data, lo_Loop:6);
        Write(fite_Data, ', ');
        inc(wo_PrimeCount);
        if ((wo_PrimeCount mod 10) = 0) then
          Writeln(fite_Data)
      end;
    close(fite_Data);
    CheckIOerror;
  {$else}
      inc(wo_PrimeCount);
  {$endif}
    Writeln(wo_PrimeCount, ' primes between: 1 - ', lo_Temp)
end.

{
   ...This little test would put TP 7.0's .EXE's between 2 to 3
   times faster than TP4 - TP6 .EXE's. (I've found simmilar results
   in testing other Programs I've written.) I guess this is one more
   reason to upgrade to TP 7.0 .

   ...I'd be curious to see how StonyBrook's Pascal+ 6.1 Compares
   to TP 7.0, in terms of execution speed With this Program.

                               - Guy
}
