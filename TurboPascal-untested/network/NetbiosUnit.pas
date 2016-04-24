(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0055.PAS
  Description: NETBIOS Unit
  Author: ALON GINGOLD
  Date: 08-30-97  10:09
*)


{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,R+,S+,V-,X-}
{$M 30000,0,50000}

{                      Turbo Pascal NetBios Interface
                          Written by Alon Gingold
                             Hitch Hiker's BBS
                                  Israel

   This Interface represents many hours of work, and of "why for god's sake
   does'nt it work ???" so  if you decide to use this Interface in your
   programs, please send your contributions to me.
   Anything more then 5 USD will do. Please note that if you send a cheque,
   then sending less then 10 USD will most likely cost me more then the
   cheque's value itself !

   Please post your contributions to :

   Alon Gingold
   P.O.B 450
   Raanana
   Israel 43104


   Introduction
   ------------

   This unit is an interface to a comunication way used on some LAN systems
   called NetBios. As far as I know, the only system on which NetBios is not
   built in, is NOVEL, but there is a small utility that comes with Novel
   to give it the NetBios support.

   So, why do I need to comunicate using netbios, if I can simply write to the
   remote's Disk ??  well, I asked myself the same question some time ago, and
   decided to try. I wrote a program the sent pages after a request was recived
   from a remote. the request was written to the host's ramdisk, and the reply
   was written there as well, and read by the remote. it took about 1 sec. for
   the screen to be transfered (It takes some time for the host to prepair the
   screen).
   After I rewritten the program using this NetBios interface, I could send
   about 5 screens per sec !

   I have used CBIS's Netbios text file documentation to learn about NetBios.
   I have included the COMPLETE package of CBIS's text file with no changes
   to the text. That text file is copyrighted by them , and is only added
   here to make it easier for you to find it. it is not a part of my work.

   TIPS
   ----

   1. Never use DataGrams ! they stinks ! when you receive one DataGram , you
      loose two others.

   2. When local names are added to the list, it is , sometimes, imposible
      to delete them from the list. The fact is , that adding and deleting
      names from the list takes quite a while (2 - 3 sec. on lantastic)
      If you write a program that you run, exit from ,and run it again, you
      should NOT try to delete the local name , but simply use the NetStatus
      command , and search to see if the name is allready there. If it is,
      use it, if not, add it.

   3. Local names must be unique to each computer on the lan. If you write
      a program that uses a specific name, run it on one computer, then try
      to run it on another computer, you'll get error. As sometimes it is
      imposible to delete a name from the local list, you better use unique
      names on each computer...

   4. Never call non POST netbios functions from a POST routine. a post routine
      should update a global table, and a global pointer of that table, and
      then execute the same command that brought up the post, with a post to
      itself. this is most likely a LISTEN command.

   5. NetBios's CANCEL command does'nt work that good. it is advised not to use
      it. The way to cancel POST routines is as follows :

      A. add an IF in the post routine , that if a specific boolean is true,
         don't execute the Post command again.

      B. set that boolean to true.

      C. add another name (save the original name, name nunmber) and send a
         command to match the post routine (i.e. A CALL to a listen post).
         then HangUp that session.


}



Unit NetBios;
interface
uses Dos{,service};

Const                             {Command number}
  NC_Reset            = $32;
  NC_Cancel           = $35;
  NC_AddName          = $30;
  NC_DelName          = $31;
  NC_AddGroup         = $36;
  NC_Call             = $10;
  NC_Listen           = $11;
  NC_HangUp           = $12;
  NC_ReceiveAny       = $16;
  NC_Receive          = $15;
  NC_Send             = $14;
  NC_SendDataGram     = $20;
  NC_ReceiveDataGram  = $21;
  NC_GetStatus        = $34;
  NC_GetAdapterStatus = $33;

  Listen_TimeOut :Byte = 2;       {TimeOuts on several Commands}
  Recive_TimeOut :Byte = 10;
  Send_TimeOut :Byte  = 10;
  Call_TimeOut :Byte = 10;

  Net_NoWait : Boolean = False;   {Generate a POST call. Turn this on}
  Net_Jump : Pointer = Nil;       {and set this Pointer to location to
                                  {jump to when the function ends}
                                  {don't forget to turn the boolean off}
                                  {after the call !}


Type
  NetBiosType = Record
                  Command:Byte;       {Command to execute}
                  RetCode:Byte;       {Return Code, 0 if ok}
                  LSN:Byte;           {Local Session Number}
                  Num:Byte;           {Name Number}
                  BufAdr:Pointer;     {Address of Message Buffer}
                  BufLen:Integer;     {Length of message, up to 512}
                  CallName:String[15];{Name to call, don't use as string!!!}
                  Name:String[15];    {Local Name used  "   "    "  "}
                  RTO:Byte;           {Recieve Time Out 0.5 incr}
                  STO:Byte;           {Send Time Out in 0.5 incr}
                  Post:Pointer;       {Address of User Interupt routine}
                  LANA_Num:Byte;      {Number of Adapter card}
                  CMD_Done:Byte;      {Command Completed Flag.}
                  RES:String[13]      {Internal use of NetBios}
                end;


  NetStatusType = record
                    NameNum:Byte;
                    Sessions:Byte;
                    OutStandingDataGram:Byte;
                    OutStanding:Byte;
                    S:Array[1..20] of Record
                      LSN:Byte;
                      State:Byte;
                      Name:String[15];
                      CallName:String[15];
                      OutStandingDataGram:Byte;
                      OutStanding:Byte;
                    end;
                  end;

  NetAdapterStatusType = record
                           Node:String[5];
                           Jumper:byte;
                           Power:Byte;
                           version:Word;
                           minutes:Word;
                           CrcErrors:Word;
                           AlignErrors:Word;
                           TransErrors:Word;
                           AbortErrors:Word;
                           SentPacketes:LongInt;
                           RecvPacketes:LongInt;
                           Retransmits:word;
                           OutofBuffers:Word;
                           Reserved:array[1..8] of byte;
                           NCBFree:Word;
                           ResetNCB:Word;
                           MaxResetNCB:Word;
                           Reserved2:array[1..4] of byte;
                           ActiveSessions:Word;
                           ResetSessions:Word;
                           MaxResetSessions:Word;
                           PackMaxLen:Word;
                           NamesNum:Word;
                           Names:Array[1..20] of record
                             Name:String[15];
                             Num:Byte;
                             Status:Byte;
                           end;
                         end;


var
  Net_Name:String[15];  {Name of this local machine}
  Net_NameNum:Byte;     {Name Number}
  Net_LastError:Byte;   {Last Error}
  NetB:NetBiosType;     {The NCB that is used on most commands.}
                        {Listen uses a user's NCB cause it's used}
                        {mostly for post}


procedure PutString(var Dest:String; Source:String; l:integer);
{
  Takes the source PASCAL string and puts it in the ASCIIZ (zero terminated)
  string in Dest. note that the DEST string is used from possition zero !
  l is the length of the Dest string (paded with zeros) should be equal
  to the sizeof(dest) - or to the Dest string length + 1
}

procedure GetString(Source:String; var Dest:String; l:integer);
{
  The oposite of PutString..
  Takes the ASCIIZ string from Source with the length l, and puts it into
  Pascal's Dest string
}

{               All the following routines return FALSE if an error had
                occoured. The error numer is found in the Net_LastError
                The strings are PASCAL strings. the asciiz translation
                is automaticaly done.
}


procedure Net_Do(var NetB:NetBiosType);
{
  Execute the NetBios command in NetB. this will call NetBios with or without
  POST as in Net_NoWait boolean, and return the error in Net_LastError.
}


Function Net_Reset:Boolean;
{
  Reset the NetBios. This is a NO NO ! , a reset on lantastic caused the
  computer to be disconnected from the rest of the lan !
}


Function Net_Cancel(var NetBOld:NetBiosType):boolean;
{
  Cancel the NetBios command in the NCB pointed bt NetBOld
  This does'nt allways work, and should not be used if other ways could be
  insted
}


Function Net_AddName(NameSt:String):Boolean;
{
  Add a name to the local name table. The name will be saved in Net_Name.
  The Name number is entered into Net_NameNum.
  Only the last name added is saved , and if more then one name is used, they
  must be saved by the user (Name Numbers as well)
}

Function Net_DelName:Boolean;
{
  Delete the name that is in the Net_Name.
}


Function Net_AddGroup(Name:String):Boolean;
{
  Add a GROUP name. this is used for the broadCast messages. BroadCasts are not
  implemented in this interface, but can be easily implemented from the Data
  Gram equavalents
}



Function Net_Call(CallToName:String; var SessionNum:byte):Boolean;
{
  Call a remote computer. SessionNum returnes the Session Number if the call
  was successfull
}


Function Net_Listen(var NetB:NetBiosType; var NameCalled:string; var SessionNum:byte):Boolean;
{
  Listen for Calls. NetB is a user NetBiosType. I made it use a different
  NetBios var , as I used it as a POST routine.
  NameCalled should have a name to listen to , or * for all systems, and will
  return the name of the calling computer , if * was used
  SessionNum returns the Session number , if successfull.
}

Function Net_Receive(ReceiveFrom:Byte; var MsgTxt; var MsgLen:Integer):Boolean;
{
  Recive data from an online session. SessionNumber should be in ReciveFrom,
  MsgTxt is a pointer to the buffer, and MsgLen should have the maximum msg
  length to receive. It will be changed to the actuall size of the msg recived
}

Function Net_ReceiveAny(var MsgTxt; var MsgLen:Integer; var Session:byte):Boolean;
{
  Recived from any online session. Session will return the session the msg was
  recived from
}

Function Net_Send(SendToSession:Byte; var MsgTxt; var MsgLen:Integer):Boolean;
{
  Send data to an online session. MsgLen should have the size of the message
  as pointed by MsgTxt
}

Function Net_SendDataGram(CallToName:String; var MsgTxt; var MsgLen:Integer):Boolean;
{
  Send DataGram to CallToName. max size is 512 byte
}

Function Net_ReceiveDataGram(Num:byte; var NameCalled:string; var MsgTxt; var MsgLen:Integer):Boolean;
{
  Recived DataGram to Name Number Num. NameCalled will return the name of the
  remote computer who sent the datagram, MsgTxt is a pointer to where the
  message will be written to, and MsgLen is the max length (will return the
  actuall size

}

Function Net_GetStatus(Var Status:NetStatusType):Boolean;
{
  Get NetStatus.
}

Function Net_GetAdapterStatus(Name:string;Var Status:NetAdapterStatusType):Boolean;
{
  Get Adapter Status.
}

Function Net_HangUp(SessionNum:Byte):Boolean;
{
  HangUp session number SessionNum
}

function Net_NameRestore(NameToRestore:String):boolean;  {Restore Specific name from name table}
{
  Retrive NameToRestore from the local name table. if found, Net_Name, and
  Net_NameNum will be set.
}


implementation


procedure PutString(var Dest:String; Source:String; l:integer);
var
  i:integer;
begin
  fillChar(Dest,l,#0);
  for i := 1 to length(source) do Dest[i-1] := Source[i];
end;

procedure GetString(Source:String; var Dest:String; l:integer);
var
  i:integer;
begin
  Dest := '';
  i := 0;
  while (Source[i] <> #0) and (i<=l) do begin
    Dest[i+1] := Source[i];
    inc(i);
  end;
  Dest[0] := char(i);
end;


procedure Net_Do(var NetB:NetBiosType);
var
  reg:Registers;
begin
  if Net_NoWait then begin
    NetB.Command := NetB.Command or $80;
    if Net_Jump <> nil then NetB.Post := Net_Jump;
  end;
  Reg.ES := seg(NetB);
  Reg.BX := ofs(NetB);
  Intr($5C,Reg);
  Net_LastError := NetB.RETCode;
end;


Function Net_Reset:Boolean;
begin
  FillChar(NetB,sizeof(NetBiosType),#0);
  NetB.Command := NC_Reset;  {Reset Net Bios}
  Net_Do(NetB);
  Net_Reset := (NetB.RetCode = 0);
end;

Function Net_Cancel(var NETBOLD:NetBiosType):boolean;
var
  NetB:NetBiosType;
begin
  FillChar(NetB,sizeof(NetBiosType),#0);
  NetB.Command := NC_Cancel;
  NetB.BufAdr := addr(NetBold);
  PutString(NetB.Name,Net_Name,16);
  Net_Do(NetB);
  Net_NameNum := NetB.Num;
  Net_Cancel := (NetB.RetCode = 0);
end;


Function Net_AddName(NameSt:String):Boolean;
begin
  Net_Name := NameSt;
  FillChar(NetB,sizeof(NetBiosType),#0);
  NetB.Command := NC_AddName;
  PutString(NetB.Name,Net_Name,16);
  Net_Do(NetB);
  Net_NameNum := NetB.Num;
  Net_AddName := (NetB.RetCode = 0);
end;


Function Net_DelName:Boolean;
begin
  FillChar(NetB,sizeof(NetBiosType),#0);
  NetB.Command := NC_DelName;
  PutString(NetB.Name,Net_Name,16);
  Net_Do(NetB);
  Net_DelName := (NetB.RetCode = 0);
end;


Function Net_AddGroup(Name:String):Boolean;
begin
  FillChar(NetB,sizeof(NetBiosType),#0);
  NetB.Command := NC_AddGroup;
  PutString(NetB.Name,Name,16);
  Net_Do(NetB);
  Net_AddGroup := (NetB.RetCode = 0);
end;

Function Net_Call(CallToName:String; var SessionNum:byte):Boolean;
begin
  FillChar(NetB,sizeof(NetBiosType),#0);
  NetB.Command := NC_Call;
  PutString(NetB.Name,Net_Name,16);
  PutString(NetB.CallName,CallToName,16);
  NetB.RTO := Call_TimeOut;
  NetB.STO := Call_TimeOut;
  {directwrite(Net_Name,5,20);
  directwrite(CallToName,20,20);}
  Net_Do(NetB);
  SessionNum := NetB.LSN ;
  Net_Call := (NetB.RetCode = 0);
end;

Function Net_Listen(var NetB:NetBiosType; var NameCalled:string; var SessionNum:byte):Boolean;
begin
  FillChar(NetB,sizeof(NetBiosType),#0);
  NetB.Command := NC_Listen;
  PutString(NetB.Name,Net_Name,16);
{ NameCalled := '*';}
  PutString(NetB.CallName,NameCalled,16);
  NetB.RTO := Listen_TimeOut;
  NetB.STO := Listen_TimeOut;
  {directwrite(Net_Name,5,20);
  directwrite(NameCalled,20,20);}
  Net_Do(NetB);
  GetString(NetB.CallName,NameCalled,16);
  SessionNum := NetB.LSN ;
  Net_Listen := (NetB.RetCode = 0);
end;


Function Net_ReceiveAny(var MsgTxt; var MsgLen:Integer; var Session:byte):Boolean;
begin
  FillChar(NetB,sizeof(NetBiosType),#0);
  NetB.Command := NC_ReceiveAny;
  NetB.Num := $FF;  {Recive messages from All callers}
  NetB.BufAdr := addr(MsgTxt);
  NetB.BufLen := MsgLen;
  Net_Do(NetB);
  Session := NetB.LSN;
  MsgLen := NetB.BufLen;
  Net_ReceiveAny := (NetB.RetCode = 0);
end;

Function Net_Receive(ReceiveFrom:Byte; var MsgTxt; var MsgLen:Integer):Boolean;
begin
  FillChar(NetB,sizeof(NetBiosType),#0);
  NetB.Command := NC_Receive;
  NetB.LSN := ReceiveFrom;
  NetB.BufAdr := addr(MsgTxt);
  NetB.BufLen := MsgLen;
  Net_Do(NetB);
  MsgLen := NetB.BufLen;
  Net_Receive := (NetB.RetCode = 0);
end;

Function Net_Send(SendToSession:Byte; var MsgTxt; var MsgLen:Integer):Boolean;
begin
  FillChar(NetB,sizeof(NetBiosType),#0);
  NetB.Command := NC_Send;
  NetB.LSN := SendToSession;
  NetB.BufAdr := addr(MsgTxt);
  NetB.BufLen := MsgLen;
  Net_Do(NetB);
  Net_Send := (NetB.RetCode = 0);
end;

Function Net_SendDataGram(CallToName:String; var MsgTxt; var MsgLen:Integer):Boolean;
begin
  FillChar(NetB,sizeof(NetBiosType),#0);
  NetB.Command := NC_SendDataGram;
  PutString(NetB.CallName,CallToName,16);
  NetB.Num := Net_NameNum;
  NetB.BufAdr := addr(MsgTxt);
  NetB.BufLen := MsgLen;
  Net_Do(NetB);
  Net_SendDataGram := (NetB.RetCode = 0);
end;

Function Net_ReceiveDataGram(Num:Byte; var NameCalled:string; var MsgTxt; var MsgLen:Integer):Boolean;
begin
  FillChar(NetB,sizeof(NetBiosType),#0);
  NetB.Command := NC_ReceiveDataGram;
  NetB.Num := Num;
  NetB.BufAdr := addr(MsgTxt);
  NetB.BufLen := MsgLen;
  Net_Do(NetB);
  GetString(NetB.CallName,NameCalled,16);
  MsgLen := NetB.BufLen;
  Net_ReceiveDataGram := (NetB.RetCode = 0);
end;


Function Net_GetStatus(Var Status:NetStatusType):Boolean;
begin
  FillChar(NetB,sizeof(NetBiosType),#0);
  NetB.Command := NC_GetStatus;
  NetB.BufAdr := addr(Status);
  NetB.BufLen := sizeof(Status);
  PutString(NetB.Name,Net_Name,16);
  Net_Do(NetB);
  Net_GetStatus := (NetB.RetCode = 0);
end;

Function Net_GetAdapterStatus(Name:string;Var Status:NetAdapterStatusType):Boolean;
begin
  FillChar(NetB,sizeof(NetBiosType),#0);
  NetB.Command := NC_GetAdapterStatus;
  NetB.BufAdr := addr(Status);
  NetB.BufLen := sizeof(Status);
  PutString(NetB.Name,Net_Name,16);

  PutString(NetB.CallName,Name,16);

  Net_Do(NetB);
  Net_GetAdapterStatus := (NetB.RetCode = 0);
end;

Function Net_HangUp(SessionNum:Byte):Boolean;
begin
  FillChar(NetB,sizeof(NetBiosType),#0);
  NetB.Command := NC_HangUp;
  NetB.LSN := SessionNum;
  Net_Do(NetB);
  Net_HangUp := (NetB.RetCode = 0);
end;

function NET_NameRestore(NameToRestore:String):boolean;
var
  Status:NetAdapterStatusType;
  Name:String;
  i:word;
begin
  Net_Name := '';
  if Net_GetAdapterStatus('*',Status) then begin
    for i := 1 to Status.Namesnum do begin
      GetString(Status.Names[i].Name,name,16);
      if Name = NameToRestore then begin
        Net_Name := Name;
        Net_NameNum := Status.Names[i].Num;
      end;
    end;
  end;
  NET_NameRestore := (Net_Name=NameToRestore);
end;


begin
  Net_Name := '';
end.

