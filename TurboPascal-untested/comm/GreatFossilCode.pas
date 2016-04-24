(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0049.PAS
  Description: Great Fossil Code
  Author: JORDAN RITTER
  Date: 08-24-94  13:40
*)


Unit Fossil;

Interface

Uses Dos;

Type
   DriverInfo      = Record
   StrucSize       : Word;
   MajorVersion    : Byte;
   CurrentRevision : Byte;
   IDPtr           : Array[1..2] of Word;
   InputBufferSize : Word;
   InputBufferFree : Word;
   OutputBufferSize: Word;
   OutputBufferFree: Word;
   ScreenWidth     : Byte;
   ScreenHieght    : Byte;
   BaudRate        : Byte;
   DriverName      : String[80];
                     End;
   MaxStr = String[255];
   Str80  = String[80];

Var
    Regs            : Registers;
    FossilInfo      : DriverInfo;

Function Port_Status(Port:Byte):Word;
Procedure Set_Baud( Port:Byte; Speed:Byte);
Function Xmit(Port:Byte; OutChar:Char):Word;
Function CommWrite(Port:Byte; OutString:MaxStr):Word;
Function CommRead(Port:Byte):Char;
Function Init_Fossil(Port:Byte; BreakAddr:Word; Var MaxFunctionNum:Byte;
                     Var RevDoc:Byte):Word;
Procedure DeInit_Fossil(Port:Byte);
Procedure ModemDTR(Port:Byte; DTRUp:Boolean);
Procedure Get_Timer_Data(Var InterruptNum:Byte;  (* Return Timing Info *)
                         Var  TicksPerSec:Byte;
                         Var MillisecsPer:Word);
Procedure Flush_Output_Buffer(Port:Byte);
Procedure Purge_Output_Buffer(Port:Byte);
Procedure Purge_Input_Buffer(Port:Byte);
Function Xmit_Nowait(Port:Byte; OutChar:Char):Boolean;
Function Read_Ahead(Port:Byte):Char;
Function KeyRead_Nowait:Word;
Function Keyread:Word;
Procedure Flow_Control(Port:Byte; ControlMask:Byte);
Function Abort_Control(Port:Byte; Flags:Byte):Word;
Procedure Set_CursorXY(X,Y:Byte);
Procedure Get_CursorLoc(Var X,Y:Byte);
Procedure ANSI_Write(OutChar:Char);
Procedure Watchdog(Port:Byte; CarrierWatch:Boolean);
Procedure BIOS_Write(OutChar:Char);
Function TimerChain(Add:Boolean; FunctionSeg:Word; FunctionOfs:Word):Boolean;
Procedure System_Reboot(ColdBoot:Boolean);
Function ReadBlock(Port:Byte; MaxBytes:Word; Var Buffer):Word;
Function WriteBlock(Port:Byte; MaxBytes:Word; Var Buffer):Word;
Procedure SendBreak(Port:Byte; SendOn:Boolean);
Procedure Driver_Info(Port:Byte; Var FossilInfo:DriverInfo);
Function Install_Application(CodeNum:Byte; EntrySeg:Word; EntryOfs:Word):Boolean;
Function Remove_Application(CodeNum:Byte; EntrySeg:Word; EntryOfs:Word):Boolean;

implementation

Function Port_Status;
Begin
Regs.AH := $03;
Regs.DX := Port;
Intr($14,Regs);
Port_Status := Regs.AX;
End;

Procedure Set_Baud;                (* Speed  2 = 300   Baud   *)
                                   (*        3 = 600   Baud   *)
Begin                              (*        4 = 1200  Baud   *)
    Regs.AL := (Speed SHL 5) + 3;  (*        5 = 2400  Baud   *)
    Regs.DX := Port;               (*        6 = 4800  Baud   *)
    Intr($14,Regs);                (*        7 = 9600  Baud   *)
                                   (*        0 = 19200 Baud   *)
End;                               (*        1 = 38400 Baud   *)

Function Xmit;
Begin                            (* Send One character to the Port *)
    Regs.AH := $01;
    Regs.DX := Port;
    Regs.AL := Ord(OutChar);
    Intr($14,Regs);
    Xmit := Regs.AX;
End;

Function CommWrite;
Var
   I     : Byte;         (* Uninterruptable string to the port         *)
   Len   : Byte;         (* If you're not going to look for keystrokes *)
   Stat  : Byte;         (* piling up in the buffer.  This is a quick  *)
   Error : Byte;         (* way to send a whole string to the port     *)

Begin
    Len  := Length(OutString);
    Stat := 128;
    I    := 1;
    While (I < Len) and ((Stat AND 128) = 128) Do
        Begin
        Regs.AH := $01;
        Regs.AL := Ord(OutString[I]);
        Regs.DX := Port;
        Intr($14,Regs);
        Stat := Regs.AL;
        Inc(I);
        End;
CommWrite := Port_Status(Port);
End;

Function CommRead;                      (* Read one character waiting at *)
Begin                                   (* the comm port                 *)
Regs.AH := $02;
Regs.DX := Port;
Intr($14,Regs);
CommRead := Chr(Regs.AL);
End;

Function Init_Fossil;                      (* Initialize the fossil driver *)
                                           (* Raise DTR and prepare out/in *)
                                           (* buffers for communications   *)
Begin
Regs.AH := $04;
Regs.DX := Port;
If BreakAddr > 0 Then
   Begin
   Regs.BX := $4F50;
   Regs.CX := BreakAddr;
   End;
Intr($14,Regs);
MaxFunctionNum := Regs.BL;
RevDoc := Regs.BH;
Init_Fossil := Regs.AX;
End;

Procedure DeInit_Fossil;                       (* Tell Fossil that comm *)
Begin                                          (* Operations are ended  *)
Regs.AH := $05;
Regs.DX := Port;
Intr($14,Regs);
End;

Procedure ModemDTR;               (* RAISE/Lower Modem DTR   *)
Begin                             (* DTRUp = True  DTR is UP *)
Regs.AH := $06;
Regs.DX := Port;
If DTRUp Then Regs.AL := 1
         Else Regs.AL := 0;
Intr($14,Regs);
End;

Procedure Get_Timer_Data;         (* Return Timing Info *)
Begin
Regs.AH := $07;
Intr($14,Regs);
InterruptNum := Regs.AL;
TicksPerSec := Regs.AH;
MillisecsPer := Regs.DX;
End;

Procedure Flush_Output_Buffer;      (* Send any remaining Data *)
Begin
Regs.AH := $08;
Regs.DX := Port;
Intr($14,Regs);
End;

Procedure Purge_Output_Buffer;      (* Discard Data In Buffer *)
Begin
Regs.AH := $09;
Regs.DX := Port;
Intr($14,Regs);
End;

Procedure Purge_Input_Buffer;
Begin                                (* Discard all pending Input *)
Regs.AH := $0A;
Regs.DX := Port;
Intr($14,Regs);
End;

Function Xmit_Nowait;
Begin                                      (* Send character Unbuffered to  *)
Regs.AH := $0B;                            (* port.  Returns true if op was *)
Regs.DX := Port;                           (* successful (there was room in *)
Regs.AL := Ord(OutChar);                   (* the output buffer)            *)
Intr($14,Regs);
If Regs.AX = 1 Then Xmit_NoWait := True
               Else Xmit_NoWait := False;
End;

Function Read_Ahead;                    (* See what character is waiting *)
Begin                                   (* in the buffer without reading *)
Regs.AH := $0C;                         (* it out.  * PEEK *             *)
Regs.DX := Port;
Intr($14,Regs);
Read_Ahead := Chr(Regs.AX);
End;

Function KeyRead_Nowait;                 (* Does not wait for keypressed *)
Begin                                    (* Returns $FFFF if no key is   *)
Regs.AH := $0D;                          (* waiting.  Acts as "standard" *)
Intr($14,Regs);                          (* keyscan-- ScanCode in high   *)
Keyread_Nowait := Regs.AX;               (* order byte -- character in   *)
End;                                     (* low byte                     *)

Function Keyread;                        (* As above but waits for key *)
Begin
Regs.AH := $0E;
Intr($14,Regs);
KeyRead := Regs.AX;
End;

Procedure Flow_Control;
Begin                                  (* Enable/Disable Flow Control      *)
Regs.AH := $0F;                        (* ControlMask Values               *)
Regs.DX := Port;                       (* 0 = Disable                      *)
Regs.AL := (ControlMask AND 15) + $F0; (* Bit 0 Set = Enable XON/XOFF Recv *)
Intr($14,Regs);                        (* Bit 1 Set = CTS/RTS              *)
End;                                   (* Bit 2  is reserved for DSR/DTR   *)
                                       (* Bit 3 Set = Enable XON/XOFF Send *)

Function Abort_Control;
Begin                                  (* Not Well documented.             *)
Regs.AH := $10;                        (* Flags = 1 Toggle ^C ^K chek      *)
Regs.DX := Port;                       (* Flags = 2 Toggle Transmit ON/OFF *)
Regs.AL := Flags;                      (* Huh?  I guess ON/OFF is stoping  *)
Intr($14,Regs);                        (* data flow.  The present flag val *)
Abort_Control := Regs.AX;              (* is stored and returned on the    *)
End;                                   (* next call to this function       *)

Procedure Set_CursorXY;                (* Set Cursor Location               *)
Begin                                  (* X,Y is 0 relative  X=Col Y=Row    *)
Regs.AH := $11;                        (* I'm not sure if it just sets the  *)
Regs.DH := Y;                          (* cursor on the screen or produces  *)
Regs.DL := X;                          (* ANSI codes to do it on the remote *)
Intr($14,Regs);                        (* I assume since there is no port   *)
End;                                   (* that it is just the local term    *)

Procedure Get_CursorLoc;               (* Zero Relative as above            *)
Begin
Regs.AH := $12;
Intr($14,Regs);
Y:= Regs.DH;
X:= Regs.DL;
End;

Procedure ANSI_Write;                  (* Character to Screen Routed thru    *)
Begin                                  (* ANSI.SYS                           *)
Regs.AH := $13;
Regs.AL := Ord(OutChar);
Intr($14,Regs);
End;

Procedure Watchdog;
Begin                                  (* CarrierWatch = True Reboot on     *)
Regs.AH := $14;                        (* Carrier Loss.                     *)
Regs.DX := Port;
If CarrierWatch Then Regs.AL := 1
                Else Regs.AL := 0;
Intr($14,Regs);
End;

Procedure BIOS_Write;                  (* BIOS write to the screen         *)
Begin
Regs.AH := $15;
Regs.AL := Ord(OutChar);
Intr($14,Regs);
End;

Function TimerChain;                    (* Add/Delete function from timer  *)
                                        (* Chain.  Creates or deletes from *)
                                        (* dynamic list of function addr's *)
Begin                                   (* to be exec'd during timer proc  *)
Regs.AH := $16;
Regs.ES := FunctionSeg;
Regs.DX := FunctionOfs;
If Add Then Regs.AL := 1
       Else Regs.AL := 0;
Intr($14,Regs);
If Regs.AX = $FFFF Then TimerChain := False
                   Else TimerChain := True;
End;

Procedure System_Reboot;                   (* Reboot System,               *)
Begin                                      (* ColdBoot = True = Hard Reset *)
Regs.AH := $17;                            (* Coldboot = False = BootStrap *)
If Coldboot Then Regs.AL := 0
            Else Regs.AL := 1;
Intr($14,regs);
End;

Function ReadBlock;                   (* Reads Communications Buffer       *)
                                      (* Into the Untyped Array Buffer     *)
                                      (* Maxbytes is the size of the array *)
                                      (* Returns the number of Bytes       *)
                                      (* Actually Sent                     *)
Begin
Regs.AH := $18;
Regs.DX := Port;
Regs.CX := MaxBytes;
Regs.ES := OFS(Buffer);
Regs.DI := Seg(Buffer);
Intr($14,Regs);
ReadBlock := Regs.AX;
End;

Function WriteBlock;                  (* Writes To Communications buffer   *)
                                      (* From the Untyped Array Buffer.    *)
                                      (* Maxbytes is the size of the array *)
Var                                   (* Returns the number of Bytes       *)
   BufferAddr : Byte Absolute Buffer; (* Actually Sent                     *)

Begin
Regs.AH := $19;
Regs.DX := Port;
Regs.CX := MaxBytes;
Regs.ES := OFS(BufferAddr);
Regs.DI := Seg(BufferAddr);
Intr($14,Regs);
WriteBlock := Regs.AX;
End;

Procedure SendBreak;                             (* Send Break to Port til *)
Begin                                            (* Called With SendON = F *)
Regs.AH := $1A;
Regs.DX := Port;
If SendOn Then Regs.AL := 1
          Else Regs.AL := 0;
Intr($14,Regs);
End;

Procedure Driver_Info;
Var
   Temp     : String[80];            (* Return Driver Information in record *)
   Segment  : Word;                  (* Structure Type of DriverInfo        *)
   OffSet   : Word;
   InputChr : Char;

Begin
Regs.AH := $1B;
Regs.DX := Port;
Regs.ES := Seg(FossilInfo);
Regs.DI := Ofs(FossilInfo);
Regs.CX := SizeOf(FossilInfo);
Intr($14,Regs);
Segment := FossilInfo.IdPtr[2];
OffSet  := FossilInfo.IdPtr[1];
Temp := '';
InputChr := ' ';
While Ord(InputChr) <> 0 Do
    Begin
    InputChr := Chr(Mem[Segment:OffSet]);
    Inc(OffSet);
    Temp := Temp + InputChr;
    End;
FossilInfo.DriverName := Temp;
End;

Function Install_Application;
Begin
Regs.AH := $7E;
Regs.AL := CodeNum;
Regs.DX := EntryOfs;
Regs.DS := EntrySeg;
Intr($14,Regs);
If (Regs.AX = $1954) and (Regs.BH = 1) Then Install_Application := True
                                       Else Install_Application := False;
End;

Function Remove_Application;
Begin
Regs.AH := $7F;
Regs.AL := Codenum;
Regs.DX := EntryOfs;
Regs.DS := EntrySeg;
Intr($14,Regs);
If (Regs.AX = $1954) and (Regs.BH = 1) Then Remove_Application := True
                                       Else Remove_Application := False;
End;
End.

