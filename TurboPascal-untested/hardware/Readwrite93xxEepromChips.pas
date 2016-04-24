(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0060.PAS
  Description: Read/Write 93xx EEPROM chips
  Author: IVAN BELTRAME
  Date: 01-02-98  07:33
*)

{
              Unit       :Eeprom
	      File       :EEPROM.PAS
              Author     :Ivan Beltrame (ivan.beltrame@nline.it)
              Date       :5 August 1997
              Rev.       :1.00b

              Note       :This unit provide to read and write in 93xx EEPROM.
                          93xx chip are present in many circuit board to
                          storage of a password,to retain some data in non
			  volatile memory,or to limit the 'life' of a device.
                          It is very easy to use it but this version has
                          a little 'bug' : *timing !*
                          Since I'm a TP6 beginner I'm not able to implement
                          a *compact* and *serious* "delay" routine that run
			  over microsecond or nanosecond, then I have used
			  "FastWait" unit by Southern Software from the
			  SWAG archive (not included in this source).
                          Use of this unit it's free, but comments on my
                          programming mode (self-made) will be apreciated.

              Important  :I decline any responsibilities or liabilities
                          resulting from the use of these informations
                          (source and schematics).


	           ------------------------------------------------------

                          Pin connections of the parallel port vs chip:

                      LPTx                    chip
                       v                       v

                                          ____________
                                  2 K    !   o        !
                     16(C2)   ---\/\/\---! 1(CS)    8 !------> +5 Volt
                                  2 K    !            !
                     2 (D0)   ---\/\/\---! 2(CK)    7 !--x
                                  2 K    !            !
                     1 (C0)   ---\/\/\---! 3(DI)    6 !--x
                                100 ohm  !            !
                     11(S7)   ---\/\/\---! 4(DO)    5 !---*---> GND
                                         !____________!   I
                                                          I
                     18(GND)  ____________________________I

                                             9306
                                             9346

}


Unit Eeprom;

interface

var
  PData      :word;                            { may be $378 or $278 or $3BC }

procedure LptInit;                { initialize LPTx wires and port registers }
procedure Eral;                            { reset all registers in the chip }
procedure Wral(EEfill :word);             { write all reg. with EEfill value }
procedure EraseLoc(Erase_Loc :byte);                      { reset a register }
procedure EEwrite(WrLoc :byte; WrValue :word);         { write in a register }
function EEvalue(Loc :byte) :word;               { return a register's value }


{ Notice: Eral procedure sets all registers at $FFFF;  EraseLoc sets
          selected location to $FFFF. }


implementation


uses
  crt, FastWait; { also available in SWAG  -- TIMING.SWG}

var
  Weight     :word;
  s          :byte;
  PStatus    :word;
  PControl   :word;


procedure CK;

{ Generate a clock pulse in the CK wire }
{ Produce un impulso di clock sul filo CK }

begin
  Wait(2);                                { ritardo dopo il dato (2 mS) }
  port[PData] := port[PData] or 1;        { CK = 1 }
  Wait(4);                                { tempo di CK alto (4 mS) }
  port[PData] := port[PData] and 254;     { CK = 0 }
  Wait(6);                                { tempo di CK basso (6 mS) }
end;


procedure CSon;

{ Abilita il chip (Chip Select on) *e lo lascia abilitato* }
{ Enable the chip (Chip Select on) *and it remain still enabled* }

begin
  Wait(4);                                { ritardo dal precedente CSon }
  port[PControl] := port[PControl] or 4;  { CS = 1 }
  CK;                                     { un CK a vuoto (necessario) }
end;


procedure CSoff;

{ Disabilita il chip (Chip Select off) *e lo lascia disabilitato* }
{ Disable the chip (Chip Select off) *and it remain still disabled* }

begin
	port[PControl] := port[PControl] and 251;  { CS = 0 }
end;


procedure DI1;

{ Attiva il filo DI (Data Input) del chip }
{ Brought DI wire (Data Input) high }

begin
  port[PControl] := port[PControl] and 30;   { DI = 1 }
end;


procedure DI0;

{ Disattiva il filo DI (Data Input) del chip }
{ Brought DI wire (Data Input) low }

begin
  port[PControl] := port[PControl] or 1;     { DI = 0 }
end;

procedure LptInit;

begin
  PStatus := PData + 1;
  PControl := PData + 2;
  CSoff;                         { evita confusioni }
  DI0;                           { evita confusioni }
end;


procedure EEcmd(EEcode :word;EEloc :byte);

{ Invia il codice operativo al chip }
{ Send operating code to the chip }

begin
  CSon;
  EEcode := EEcode + EEloc;     { Codice operativo = Operazione + Locazione }
  for s:= 8 downto 0 do
  begin                         { invia stringa di bit seriali sul filo DI }
    Weight := 1 shl(s);
    if EEcode < Weight then
    begin
      DI0; CK;
    end
    else
    begin
      EEcode := EEcode - Weight;
      DI1; CK;
    end;
  end;
end;


procedure Ewen;

{ Ordine di abilitazione alla scrittura/cancellazione al chip }
{ Enable command for writing/erasing operations to the chip }

const
  EwenCode     = 304;

begin
  EEcmd(EwenCode,0);            { il campo EELoc deve essere = 0 }
  DI0;                          { ripristina DI = 0 (evita confusioni) }
  CSoff;                        { disabilita il chip dopo il comando }
end;


procedure Ewds;

{ Ordine di disabilitazione alla scrittura/cancellazione al chip }
{ Disable command for writing/erasing operations to the chip }

const
  EwdsCode     = 256;

begin
  EEcmd(EwdsCode,0);            { il campo EELoc deve essere = 0 }
  CSoff;                        { disabilita il chip dopo il comando }
end;


procedure Eral;

{ Ordine di cancellazione totale al chip. Tutte le loc diventeranno $FFFF }
{ Erase all command to the chip. All locations become $FFFF }

const
  EralCode     = 288;

begin

  Ewen;                         { abilita il chip alla cancellazione totale }

  EEcmd(EralCode,0);            { il campo EELoc deve essere = 0 }
  CSoff;                        { disabilita il chip dopo il comando }

  Ewds;                         { disab. il chip alla cancellazione totale }

end;



procedure Wral(EEfill :word);

{ Ordine di riempimento delle loc del chip con un valore 'EEfill' }
{ Fill all locations with 'EEfill' value }

const
  WralCode     = 272;

begin

  Eral;                         { "ERAL" necessario per affidabilita' }

  Ewen;                         { abilita il chip alla scrittura }

  EEcmd(WralCode,0);            { comando "WRAL" }
  for s:= 15 downto 0 do
  begin                         { invia stringa di bit seriali }
    Weight := 1 shl(s);         { per specificare il dato di }
    if EEfill < Weight then     { riempimento }
    begin
      DI0; CK;
    end
    else
    begin
      EEfill := EEfill - Weight;
      DI1; CK;
    end;
  end;
  DI0;                          { ripristina DI = 0 (evita confusioni) }
  CSoff;                        { Disabilita il chip }

  Ewds;                         { disab. il chip alla scrittura }

end;


procedure EraseLoc(Erase_Loc :byte);

{ Ordine di resettare una locazione; il suo valore diventera' $FFFF }
{ Reset command for a single location; it become $FFFF }

const
  EraseCode = 448;

begin

  Ewen;                         { abilita il chip alla cancellazione }

  EEcmd(EraseCode,Erase_Loc);   { il campo Erase_Loc deve avere il }
  DI0;                          { ripristina DI = 0 (evita confusioni) }
  CSoff;                        { numero della locazione da resettare }

  Ewds;                         { disab. il chip alla cancellazione  }

end;


procedure EEwrite(WrLoc :byte; WrValue :word);

{ Ordine di scrivere un dato 'WrValue' alla loc 'WrLoc' }
{ Writing command; it will write a 'WrValue' in a 'WrLoc' location }

const
  WrCode  = 320;

begin

  Ewen;                            { abilita il chip alla scrittura }

  EEcmd(WrCode,WrLoc);             { comando di scrittura alla loc WrLoc }
  for s:= 15 downto 0 do
  begin                            { invia stringa di bit seriali sul DI }
    Weight := 1 shl(s);
    if WrValue < Weight then
    begin
      DI0; CK;
    end
    else
    begin
      WrValue := WrValue - Weight;
      DI1; CK;
    end;
  end;
  DI0;                             { ripristina DI = 0 (evita confusioni) }
  CSoff;                           { disabilita il chip }

  Ewds;                            { disabilita il chip alla scrittura }

end;

function EEvalue(Loc :byte) :word;

{ Ritorna il valore letto nella 'Loc' }
{ It return a Loc's value }

const
  ReadCode      = 384;
var
  Value         :byte;
  EEval         :word;

begin
  EEvalue := 0;
  EEval   := 0;
  EEcmd(ReadCode,Loc);             { comando di lettura alla 'Loc' }
  for s := 0 to 15 do
  begin
    CK;                            { invia impulso di clock }
    wait(5);
    Value := port[PStatus];        { legge sul filo DO il livello logico }

    if Value < 128 then EEval :=  EEval + (1 shl(15 - s));

    { poiche' quando il filo "S7" della porta e' a "1" il peso 7 del byte }
    { di stato e' a "0" potremmo dire di avere un "1" quando Value < 128. }
    { Se ad ogni ciclo incrementiamo o decrementiamo i pesi di EEval a }
    { seconda del valore di DO, ci ritroveremo col dato della locazione. }

  end;
  DI0;                             { ripristina DI = 0 (evita confusioni) }
  CSoff;                           { disabilita il chip }
  EEvalue := EEval;
end;




End.


{ There are some examples }

{

program EEpromTest;

uses EEprom;

var
  j  :byte;
  h  :word;

begin
  PData := $378;                 { You must specify the parallel port in use }
  LptInit;                       { initialize LPTx wires and port regs }
  writeln('Reading test on EEPROM 9306');
  writeln;

  for j := 0 to 15 do            { this "for"cicle put on "h" }
  begin                          { the "j" location           }
    h := EEvalue(j);             { of the EEPROM chip         }
    write (h,' ');               {                            }
  end;

  readln;

  Eral;                          { this procedure sets all regs }
                                 { in the EEPROM chip = 65535   }
  readln;
  h := 100;

  Wral(h);                       { this procedure sets all regs }
                                 { in the EEPROM chip = "h"     }
  readln;
  j := 5;

  EraseLoc(j);                   { this procedure sets the "j"  }
                                 { reg in the EEPROM = 65535    }
  readln;
  j := 10;
  h := 1500;
  EEwrite(j,h);                  { this procedure sets the reg  }
                                 { "j" = "h" in the EEPROM      }
                                 { Notice : in certain cases it }
                                 { is necessary to perform an   }
                                 { EaseLoc(j) before of EEwrite(j,.... }


end.                             

