(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0053.PAS
  Description: TENTOOLS documentation
  Author: SWAG SUPPORT TEAM
  Date: 08-30-97  10:08
*)


      TenTools is a set of utility functions implemented in Turbo Pascal 5.5
  which allows easy access to the 10Net network, including the Net Use
  function (and Device Cancel function) which is actually implemented through
  the DOS $5F (Redirect Device) function call (using Int $21).
  All of the functions have been used in programs. Some have been tested more
  rigorously than others. This set of tools is being released to the public
  domain for usage as you deem possible. I hope they will be of some use to
  someone. Before using any functions, PLEASE read all you can first. These
  functions have been used on 10Net Plus and work fine. I'm rushing to make
  these tools available as I'm soon changing companies!

       To use Tentools, the user needs only to "USE" it as a TPU and make
  calls to its procedures. Certain steps need to be made to use certain
  functions. These steps are explained here:


#1  "USING NETWORK DEVICES"
       To use devices (or mount drives) at a Superstation on the network,
  first of all the Superstation must be on the network and the local node
  must also be "Loaded" with network software. Next, the local user must
  "Login" to the Superstation. Once logged into the Superstation, the user
  can check on what devices are available ("GetDevices"). Finally, the user
  can either "NetUse" the device(s) needed or, if the device is a drive
  letter, it can be "Mounted" as a local drive letter. This sequence is
  summarized below:

    TenTools Function/Procedure            Action
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 Attaching:

    LOADED                                 Am I on the Network?
    NODES                                  Is Superstation available?
    LOGIN                                  Attach to Superstation.
    GETDEVICES                             What devices are available?
    NETUSE (or MOUNT)                      Attach to device(s).

 Detaching:

    UNUSE (or UNMOUNT)                     Detach from a device.
    LOGOFF                                 Detach from a Superstation.

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#2   "SENDING CHAT MESSAGES"
        To send a 10net Chat message to another node, you don't need to be
   attached to the node in any way. Both nodes need to be on the network.
   The Chat sequence can be started with the Function "CHAT". For more
   information on using Chat, refer to the 10Net manual.
        Using Chat from within TURBO Pascal allows you to send a message to
   node when a process is finished, or to make them aware that your status
   on the network is changing from within your program.

    TenTools Function/Procedure            Action
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   CHAT                                    Sends a message to another node.


#3  "SENDING/RECEIVING RECORDS"
       There is a set of functions available in the 10Net $6F function calls
   that allows the user to send and receive "Inter-application" messages.
   These messages are limited to 457 bytes each. To make it simpler to use
   this function, the toolbox contains a set of expanded Send/Receive
   functions, TBSEND and TBRECEIVE. Using these functions, one can send
   records of almost any size, limited more by the amount of memory available
   than anything else. Read the documentation of each procedure for an in-
   depth explanation of how to use them.
        One thing to keep in mind when using TBSEND and TBRECEIVE is that
   the "Profile" of those workstations/superstations that use Sends and
   Receives should include a line to set SBUFFERS=n , where n can be from
   8 to 255 (30 or more is recommended here) and DATAGRM=23 (the maximum).
   This sets the number of Small Buffers that Sends and Receives use, as
   well as maximizing the number of Outstanding Receive Datagrams at 10Net
   initialization.
        A second thing to remember is that buffers MUST BE allocated for
   these functions. This is done with the Tentools function TENCONFIG.
   Read the documentation at the TENCONFIG function before using it.
        Finally, before using sends and receives on the network, the user
   should be aware that Sends directed to a NODENAME that is no longer on
   the network will go through a timeout delay waiting for an acknowledgement
   that never arrives. To avoid this delay, the user can set up a sender and
   receiver on different CB Channels, and messages can be sent using the
   CB channel number instead of the NODENAME. Sends on CB Channels require
   no acknowledgement. This has its advantages and its disadvantages. While
   the timeout delay is avoided, you might still have to develop your own
   check for what records were received. TBSEND/TBRECEIVE has an optional
   parameter that can be used for record checking, the TRANSACTIONID. There
   is also a parameter to use to distinguish between communication functions
   or groups, TRANSACTIONTYPE. (There is another variable, ResponseType,
   which is not yet completely implemented in this release.)

    TenTools Function/Procedure            Action
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   TENCONFIG                               Allocates buffers for records.
   TBSEND                                  Sends an InterApp Message.
   TBRECEIVE                               Receives an InterApp Message.
   SETWAIT                                 Sets maximum wait time for
                                           TBReceive messages.
   SETCBCHANNEL                            Sets a CBChannel to receive on.

#4 STATUS/INFORMATIONAL FUNCTIONS
        There are many informational functions that provide the user with
   status, configuration, counts, and other information on the network. Those
   provided within TenTools are listed below:

    TenTools Function/Procedure      Action
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   STATUS                            Returns a block of status data from a
                                     node if it is on the network.
   LOADED                            Am I on the network?
   NODENAME                          Returns the local Nodename.
   NODES                             Returns a list of Nodes on the network.
   MOUNTLIST                         What am I mounted to?
   LOGLIST                           Who am I logged to?
   MOUNTSAVAIL                       How many total mounts can I make?
   GETDEVICES                        What devices are at a node?

#5 OTHER FUNCTIONS AVAILABLE
        The other functions that are available in TenTools are listed below:

    TenTools Function/Procedure      Action
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   TIMESTAMP/STAMPAGE                Timestamp utilities (used internally)
   GETREMOTEMEMORY                   Grab a block of memory from a remote
                                     node.
   SETCBCHANNEL                      Sets the Channel to listen for.
   GETTABLEDATA                      Used internally; see 10Net Programmer's
                                     Reference Manual for details.
   GET10TIME                         Returns the date/time from a remote
                                     node.
   SETUSERNAME                       Changes the local Username.
   SUBMIT                            Submits a commandline to a Superstation
                                     if Submit Permit is on at Superstation.
   SETSPOOL                          Initiates a "template" for a print
                                     spool.
   OPENSPOOL                         Opens an initiated spool.
   CLOSESPOOL                        Closes/prints an initiated spool.

_____________________________________________________________________________
<10Net><10Net><10Net><10Net><10Net><10Net><10Net><10Net><10Net><10Net><10Net>
-----------------------------------------------------------------------------

What follows is an alphabetical listing of the functions/procedures available
in TenTools and their descriptions:

Function Chat(NodeID : S12; VAR DBuffer {:String[n]} ) : Word;
{ The DBuffer should be a Turbo Pascal String (length indicator in byte 0)
  The string should be no more than 100 bytes long. This function sends a
  10Net Chat message to the NodeID specified. }

Function CloseSpool : Word;
{ Calls to CloseSpool, after a spool has been started through OpenSpool and
  some print has been "sent to the printer", will cause the Spoolfile to
  close and printing to begin if the Print Permit is ON at the location
  where the printer is mounted.
     "Sending print to the printer" is done in the usual manner, from within
  programs, by "Typing and Piping" (TYPE>LPT1 <filename>), by Copying from a
  file to the printer, etc.}

Function GetDevices(ServerID : S12;
             VAR Device : DeviceArray;
             VAR DeviceCount : Integer): Word;
{ Returns a list of devices through the Variable parameter Devices (which is
  defined as Array[1..25] of S8). Uses the Get/Set/Delete/Get User Shared
  Device (Int-$6F,Service-$15) function call.
  }

Function GetRemoteMemory(NodeID : S12; VAR DBuffer; VAR DLength : Integer;
                         RemSeg,RemOfs : Word) : Word;
{Copy a section of memory from a remote node to DBuffer
 ( maximum of 470 bytes ) }

Function GetTableData(VAR TableBuffer : GetTableDataRec): Word;
{A function which gets the 10Net TableData from a Remote Node}

Function Get10Time(NodeName : S15 ;VAR TenTime : DateTimeRec) : Word;
{Returns the Date and Time in a DateTimeRec Record from the Node Requested)
}

Function Loaded : Boolean;
{ Is 10Net Loaded? }

Function Login(ServerID : S12;PW10Net : S8): Word;
{ Logs into the requested server. }

Function LogList(VAR Logins : LogArray;VAR TableEntries : Integer): Word;
{Returns a list of nodes that the local station is logged into. LogArray
 is a TYPE defined as Array[0..19] of String[12] and can be used in the
 calling program. }

Function Logoff(ServerID : S12): Word;
{ Logs off the requested server. }

Function Mount(ServerID : S12; LocalDevice,RemoteDevice : Char) : Word;
{ For Drive mounting, mounts drive REMOTEDRIVE at SERVERID as LOCALDRIVE
 locally; for printer mounting, use "1" for LPT1, etc. }

Function MountList(VAR MountTable : DriveArray;VAR PrintTable : PrintArray;VAR TableEntries : Integer): Word;
{Returns a mountlist of type DriveTable (with TableEntries as a count of
actual table entries returned), and PrintTable of Printer reassignments.
The caller must specify a maximum tablesize by setting table entries before
calling. Returns with a value of 0 if it worked without any hitches, and the
value of a 10net error if there is any problem. Will return with a value of
$FFFF if not loaded. Will return names of Devices if any are currently
"NetUsed".}

Function MountsAvail : Integer;
{How many total Mounts is the local station configured for?}

Function NetUse(ServerID : S12; LocalDrive : Char; RemoteDevice : String;NetUsePassWord : S8) : Word;
{ Attaches to a Device at a Remote Server. The RemoteDevice can be an ALIAS }

Function NODEName : S12;
{Returns the current nodename }

Function Nodes(VAR NodeBuffer;VAR MaxNodes : Integer;
                  SuperstationsOnly : Boolean) : Word;
{ A call to this function should be made with NODEBUFFER being an
 Array[1..MaxNodes] of S12. MaxNodes being the largest number of nodes you
 expect to see on the network. If the Returncode of NODES is 0, MaxNodes will
 have the actual number of nodenames returned and the array will be filled
 with their names. SuperstationsOnly is a boolean which allows nodes to be
 called to list only superstations. }

Function OpenSpool(NewSpoolname : S12) : Word;
 {Once SetSpool has "configured" your spool, calls to OpenSpool will
  create a new spoolfile with the optional Newspoolname, or with a name
  automatically set by 10Net if NewSpoolName=''. }

Function Receive(VAR DBuffer; Secs : Word; VAR Available : Integer; VAR CBMessage : Boolean): Word;
{Receive a data packet on the network in the structure below:
         data           bytes
         =====================
         SenderNodeID : 12
         Len          : 2
         Data         : (Len)
  Available is set to the number of packets available INCLUDING the
  current message. Receives data sent through the SEND function, which is
  limited to data structures of length 470 or less. TBSend and TBReceive
  (which use Send and Receive) can be used for larger structures.
}


Function Send(NodeID : S12; VAR DBuffer; DLength :Integer): Word;
{Send a data packet on the network to NODEID ( or on a CB Channel if
NODEID is CB##, limited to 470 byte packets. Used within the Toolbox to
accomplish TBSend, which allows large records to be sent.}

Procedure SetCBChannel(CBChannel : Byte);
{      This procedure will set your "Listening" Channel to the CBCHANNEL (1
 through 40 are available) specified. TBSends to this CBChannel from other
 nodes will be available here through TBReceive. TBSends to other CBChannels
 will not be seen here. TBSends directed specifically to this node will also
 be seen here, of course.
       The advantages of CB messaging are that many nodes can be setup to
 receive messages on a particular channel, and the sender will not be held
 up waiting for a network handshake to tell him that his Send was Received.
}

Function SetSpool(Printer : Byte; SpoolName : S12; Notification : NotifySet; RDays : Byte): Word;
{ When SetSpool is first called, it merely sets up a "Template" for
  subsequent calls to OpenSpool and CloseSpool. You must be logged into the
  Superstation where you want to spool and be mounted to a printer and a
  drive on that Superstation. SetSpool will determine where the Printer
  (1,2, or 3 for your local LPT1:,LPT2:, or LPT3:) is mounted and a drive
  letter that you are mounted to. }

Procedure SetUserName(UName : S8);
{Changes the Username in the Network Table and in the Global variable
  USERNAME}

Function SetWait(WaitLimit : Integer): Word;
{ Changes the maximum seconds to wait for receive packets in the same record,
  Defaults to 30. Used in conjunction with TBReceive.}

Function StampAge(StartTime : Real): LongInt;
{ Returns the difference in seconds between the currenttime and the
"Starttime" timestamp.}

Function Status(NodeName : S15; VAR SBlock : StatusBlock): Word;
{ Returns a Block of Status information from the Nodename requested if
  that node is on the network.}

Function Submit(ServerID : S12; CommandLine : String): Word;
{ If the local User is LOGGED INTO the node SERVERID, and the submit permit
 is ON at ServerID, and ServerID is currently at a DOS prompt, then the
 Commandline will be SUBMITTED to ServerID. If it is not currently at a DOS
 prompt, it will be SUBMITTED when it reaches a DOS prompt. }

Function TBReceive( VAR SenderID: S12;      {Sending NodeID : String12       }
                    VAR DBuffer;           {Variable (record) to receive    }
                    VAR DLength : Integer; {Maximum length record to receive}
              VAR TransactionID : TID;     {See description of TBSend       }
                  VAR TransType : Integer; {See description of TBSend       }
                  VAR Available : Integer; {Number of records available
                                            including the one passed back   }
                                    VAR CB : Boolean)        {Was this a CB transmission?     }
                         : Word;  {Return code indicates a 10Net error($XXFF)
                                   or an error in a passed parameter ($FFXX)}

Function TBSend(NodeID : S12;            {Node to send to                 }
           VAR DBuffer;                   {The data record                 }
                DLength : Integer;        {Length (bytes) of data          }
          TransactionID : TID;            {Tag to identify record (6 bytes)}
              TransType : Integer;        {Transaction Type - (external to
                                          this toolbox) an integer type used
                                          to maintain that one is receiving
                                          only the correct type of records.}
           ResponseType : Byte            { Not Implemented yet...
                                How is the TBReceive to act-
                                0 - no immediate response
                                1 - Acknowledge when total message received
                                2 - Acknowledge each packet }
              ) : Word;
{ TBSend will send a large interapplication message (DBuffer) of length
DLENGTH across the network. The TransactionID is user defineable and can be
used to acknowledge the receipt or processing of a record to the originator.
TransType, optional, can be used to identify the type of processing required
of a record. The data in DBuffer can be of any structure.
     The message is effectively broken into packets, and sent with a
"packet marker" to assist in its reconstruction when received. Unique
Transaction IDs is essential for records larger than 457 bytes to maintain
unique record identity. Packet Data consists of a PRec (see data Type
definitions) and 457 bytes of the DataRec.
     The network provides handshaking with Sends and Receives if they are
directed to a particular node. If CB# is used instead, there is no
handshaking provided. If a node is specified, and it is not currently
available or its 10Net SBuffers buffering is full, the sending node will
be stuck waiting for a timeout or until the receiver or buffer space appears.
For this reason, in some applications which can't be held up waiting, it is
wise to use CB channel communication. (See the "SetCBChannel" function for a
discussion of its usage.)
}

Function TenConfig(MaxSendRec,MaxRecvRec : Integer; {Size of largest records
                                                     to send/receive}
                   MaxRecs : Integer)   {Maximum number of Records to recv}
                          : Word;
{ This function allows the user to dynamically change the size of the
buffers being used by TBSend and TBReceive to optimize usage.
MaxSendRec is the size of the largest TBSEND record
MaxRecvRec is the size of the largest TBRECEIVE record
MaxRecs is the number of TBReceive records to buffer
}

Function TimeStamp : Real;
{Returns a timestamp of 6 bytes ordered, Year,Month,Day,Hour(24),Minute,
 Second }

Function UnMount(LocalDrive : Char) : Word;
{ Unmounts previously mounted drive or printer }

Function UnUse(LocalDrive : Char) : Word;
{ Detaches from a shared device at a remote server. The attachment was made
through a Net Use (or NetUse), and the local drive letter is all that is
needed to detach}

Function UpCase8(Str_8 : S8): S8;
{Expands and "Upcases" an 8 character string}

Function UpCase12(Str_12 : S12): S12;
{Expands and "Upcases" a 12 character string}


