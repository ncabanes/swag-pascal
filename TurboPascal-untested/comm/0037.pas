
unit cdchk;

Interface

 Function CarrierDetected( ComPort : byte ) : Boolean;

Implementation

 Function CarrierDetected( ComPort : byte ) : Boolean;

 Const MSR      = 6;

 VAR
       BASEPORT : Array[0..3] Of Word absolute $40:0;

 VAR   P : Word;

 begin
   CarrierDetected := FALSE;    { Assume no Carrier }
   dec( ComPort );
   if ComPort in [0..3] then    { range check for COMx }
   begin                        { ... not valid ? }
     P := BasePort[ComPort];    { Bios-Var for COMx... }
     If P <> 0 then             { ... not assigned ?! }
     begin
       CarrierDetected := (Port[P+ MSR] And $80) = 0;
     end;
   end
 end;
 { No Initializing ... }
 end.

-------------------------------------------------------------
 P.S.:  If P=0 ...
   Port[P+MSR] ==> Port[6]
   this would read the DMA Channel#3-LowAdress-Byte .... (:-))
-------------------------------------------------------------
