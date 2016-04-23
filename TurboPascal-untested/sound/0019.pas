UNIT Tones;

{ TONES - a set of functions that provide some
  interesting sonic effects.  Useful for games
  or alerts.                                                                        }

INTERFACE

PROCEDURE Tone(CycleLen,NbrCycles: Integer);
PROCEDURE Noise(D: Longint);
PROCEDURE Chirp(F1,F2,Cycles: Integer);
PROCEDURE Sound2(F: Longint);
PROCEDURE NoSound2;

IMPLEMENTATION

{ Tone - output a tone

  INP:        cyclen - Length (counts) for 1/2 cycle
         numcyc - number of cycles to make  }

PROCEDURE Tone(CycleLen,NbrCycles: Integer);

VAR
        T,I,J : Integer;

BEGIN
   NbrCycles := NbrCycles SHL 1;  {# half Cycles}
        T := Port[$61];                {Port contents}
        FOR I := 1 TO NbrCycles DO
                BEGIN
                  T := T XOR 2;
                  Port[$61] := T;
        FOR J :=1 TO CycleLen DO
      END
END;


{ Noise - make noise for a certain amount of
  counts.

  INP:   D - the number of kilocounts of Noise}

PROCEDURE Noise(D: Longint);
VAR
        Count : Longint;
        T,J,I : Integer;
BEGIN
        T := Port[$61];
        Count := 0;
        WHILE Count < D DO
      BEGIN
         J := (Random(32768) MOD 128) SHL 4;
         FOR I := 1 TO J DO;
         T := T XOR 2;
                   Port[$61] := T;
                        Inc(Count,J)
      END
END;

{ Chirp - create a 'bird Chirp' TYPE Noise

  INP:F1 - # OF counts FOR the starting freq.
                 F2 - # OF counts FOR the ending freq.
  Cycles - # OF Cycles OF each frequency }

PROCEDURE Chirp(F1,F2,Cycles: Integer);
VAR
        I,J,K,L : Integer;
BEGIN
        L := Port[$61];
        Cycles := Cycles * 2;
        I := F1;
        WHILE I <> F2 DO
                BEGIN
                        FOR J := 1 TO Cycles DO
                                BEGIN
                                        L := L XOR 2;
                                        Port[$61] := L;
                                        FOR K := 1 TO I DO
                                END;
                        IF F1 > F2 THEN Dec(I)
                        ELSE Inc(I)
                END
END;

{ Sound2 - Generate a continuous tone using the
  internal timer.

  INP:        F - the desired frequeny }

PROCEDURE Sound2(F: Longint);
VAR
        C : Longint;
BEGIN
        IF F < 19 THEN F := 19;             {Prevent overflow}
        C := 1193180 DIV F;
        Port[$43] := $B6;         {Program new divisor}
        Port[$42] := C MOD 256;   {Rate into the timer}
        Port[$42] := C DIV 256;
        C := Port[$61];         {Enable speaker output}
        Port[$61] := C OR 3     {from the timer       }
END;


{ NoSound2 - turn off the continuous tone               }

PROCEDURE NoSound2;
VAR
        C : Integer;
BEGIN
        C := Port[$61];             {Mask off speaker}
        Port[$61] := C AND $FC      {output from timer}
END;

END.
