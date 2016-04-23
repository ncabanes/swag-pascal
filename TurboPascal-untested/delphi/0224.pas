
{$D-,L-,Y-,A+,B-,F+,H+,I-,J-,M-,O+,P+,Q-,R-,T-,U+,V+,W-,X+,Z1}{$HINTS OFF}{$WARNINGS OFF}
Unit RASAPI;

Interface

Uses WinTypes, WinProcs, Dialogs;
{ Copyright (c) 1992, Microsoft Corporation, all rights reserved
  Note: The 'dwSize' member of a structure X must be set to sizeof(X)
  before calling the associated API, otherwise ERROR_INVALID_SIZE is
  returned.  The APIs determine the size using 2-byte packing (the
  default for Microsoft compilers when no /Zp<n> option is supplied).
  Users requiring non-default packing can use the 'dwSize' values
  listed next to each 'dwSize' member in place of sizeof(X). }

Const
  UNLEN = 256;
  PWLEN = 256;
  DNLEN = 15;
  RAS_MaxEntryName      =  256;
  RAS_MaxDeviceName     =  128;
  RAS_MaxDeviceType     =  16;
//RAS_MaxParamKey       =  32;
//RAS_MaxParamValue     = 128;
  RAS_MaxPhoneNumber    = 128;
  RAS_MaxCallbackNumber =  RAS_MaxPhoneNumber;

Type
//UINT = Word;
  PHRASConn = ^HRASConn;
  HRASConn = DWORD;


{ Pass this string to the RegisterWindowMessage() API to get the message
** number that will be used for notifications on the hwnd you pass to the
** RasDial() API.  WM_RASDIALEVENT is used only if a unique message cannot be
** registered. }
const
  RASDialEvent = 'RASDialEvent';
  WM_RASDialEvent = $0CCCD;
  { Enumerates intermediate states to a Connection.  (See RasDial) }
  RASCS_Paused = $1000;
  RASCS_Done   = $2000;

  RASBase = 600;
  Success = 0;
{ Error Codes }
  PENDING                              = (RASBase+0);
  ERROR_INVALID_PORT_HANDLE            = (RASBase+1);
  ERROR_PORT_ALREADY_OPEN              = (RASBase+2);
  ERROR_BUFFER_TOO_SMALL               = (RASBase+3);
  ERROR_WRONG_INFO_SPECIFIED           = (RASBase+4);
  ERROR_CANNOT_SET_PORT_INFO           = (RASBase+5);
  ERROR_PORT_NOT_ConnECTED             = (RASBase+6);
  ERROR_EVENT_INVALID                  = (RASBase+7);
  ERROR_DEVICE_DOES_NOT_EXIST          = (RASBase+8);
  ERROR_DEVICETYPE_DOES_NOT_EXIST      = (RASBase+9);
  ERROR_INVALID_BUFFER                 = (RASBase+10);
  ERROR_ROUTE_NOT_AVAILABLE            = (RASBase+11);
  ERROR_ROUTE_NOT_ALLOCATED            = (RASBase+12);
  ERROR_INVALID_COMPRESSION_SPECIFIED  = (RASBase+13);
  ERROR_OUT_OF_BUFFERS                 = (RASBase+14);
  ERROR_PORT_NOT_FOUND                 = (RASBase+15);
  ERROR_ASYNC_REQUEST_PENDING          = (RASBase+16);
  ERROR_ALREADY_DISConnECTING          = (RASBase+17);
  ERROR_PORT_NOT_OPEN                  = (RASBase+18);
  ERROR_PORT_DISConnECTED              = (RASBase+19);
  ERROR_NO_ENDPOINTS                   = (RASBase+20);
  ERROR_CANNOT_OPEN_PHONEBOOK          = (RASBase+21);
  ERROR_CANNOT_LOAD_PHONEBOOK          = (RASBase+22);
  ERROR_CANNOT_FIND_PHONEBOOK_ENTRY    = (RASBase+23);
  ERROR_CANNOT_WRITE_PHONEBOOK         = (RASBase+24);
  ERROR_CORRUPT_PHONEBOOK              = (RASBase+25);
  ERROR_CANNOT_LOAD_STRING             = (RASBase+26);
  ERROR_KEY_NOT_FOUND                  = (RASBase+27);
  ERROR_DISConnECTION                  = (RASBase+28);
  ERROR_REMOTE_DISConnECTION           = (RASBase+29);
  ERROR_HARDWARE_FAILURE               = (RASBase+30);
  ERROR_USER_DISConnECTION             = (RASBase+31);
  ERROR_INVALID_SIZE                   = (RASBase+32);
  ERROR_PORT_NOT_AVAILABLE             = (RASBase+33);
  ERROR_CANNOT_PROJECT_CLIENT          = (RASBase+34);
  ERROR_UNKNOWN                        = (RASBase+35);
  ERROR_WRONG_DEVICE_ATTACHED          = (RASBase+36);
  ERROR_BAD_STRING                     = (RASBase+37);
  ERROR_REQUEST_TIMEOUT                = (RASBase+38);
  ERROR_CANNOT_GET_LANA                = (RASBase+39);
  ERROR_NETBIOS_ERROR                  = (RASBase+40);
  ERROR_SERVER_OUT_OF_RESOURCES        = (RASBase+41);
  ERROR_NAME_EXISTS_ON_NET             = (RASBase+42);
  ERROR_SERVER_GENERAL_NET_FAILURE     = (RASBase+43);
  WARNING_MSG_ALIAS_NOT_ADDED          = (RASBase+44);
  ERROR_AUTH_INTERNAL                  = (RASBase+45);
  ERROR_RESTRICTED_LOGON_HOURS         = (RASBase+46);
  ERROR_ACCT_DISABLED                  = (RASBase+47);
  ERROR_PASSWD_EXPIRED                 = (RASBase+48);
  ERROR_NO_DIALIN_PERMISSION           = (RASBase+49);
  ERROR_SERVER_NOT_RESPONDING          = (RASBase+50);
  ERROR_FROM_DEVICE                    = (RASBase+51);
  ERROR_UNRECOGNIZED_RESPONSE          = (RASBase+52);
  ERROR_MACRO_NOT_FOUND                = (RASBase+53);
  ERROR_MACRO_NOT_DEFINED              = (RASBase+54);
  ERROR_MESSAGE_MACRO_NOT_FOUND        = (RASBase+55);
  ERROR_DEFAULTOFF_MACRO_NOT_FOUND     = (RASBase+56);
  ERROR_FILE_COULD_NOT_BE_OPENED       = (RASBase+57);
  ERROR_DEVICENAME_TOO_LONG            = (RASBase+58);
  ERROR_DEVICENAME_NOT_FOUND           = (RASBase+59);
  ERROR_NO_RESPONSES                   = (RASBase+60);
  ERROR_NO_COMMAND_FOUND               = (RASBase+61);
  ERROR_WRONG_KEY_SPECIFIED            = (RASBase+62);
  ERROR_UNKNOWN_DEVICE_TYPE            = (RASBase+63);
  ERROR_ALLOCATING_MEMORY              = (RASBase+64);
  ERROR_PORT_NOT_CONFIGURED            = (RASBase+65);
  ERROR_DEVICE_NOT_READY               = (RASBase+66);
  ERROR_READING_INI_FILE               = (RASBase+67);
  ERROR_NO_ConnECTION                  = (RASBase+68);
  ERROR_BAD_USAGE_IN_INI_FILE          = (RASBase+69);
  ERROR_READING_SECTIONNAME            = (RASBase+70);
  ERROR_READING_DEVICETYPE             = (RASBase+71);
  ERROR_READING_DEVICENAME             = (RASBase+72);
  ERROR_READING_USAGE                  = (RASBase+73);
  ERROR_READING_MAXConnECTBPS          = (RASBase+74);
  ERROR_READING_MAXCARRIERBPS          = (RASBase+75);
  ERROR_LINE_BUSY                      = (RASBase+76);
  ERROR_VOICE_ANSWER                   = (RASBase+77);
  ERROR_NO_ANSWER                      = (RASBase+78);
  ERROR_NO_CARRIER                     = (RASBase+79);
  ERROR_NO_DIALTONE                    = (RASBase+80);
  ERROR_IN_COMMAND                     = (RASBase+81);
  ERROR_WRITING_SECTIONNAME            = (RASBase+82);
  ERROR_WRITING_DEVICETYPE             = (RASBase+83);
  ERROR_WRITING_DEVICENAME             = (RASBase+84);
  ERROR_WRITING_MAXConnECTBPS          = (RASBase+85);
  ERROR_WRITING_MAXCARRIERBPS          = (RASBase+86);
  ERROR_WRITING_USAGE                  = (RASBase+87);
  ERROR_WRITING_DEFAULTOFF             = (RASBase+88);
  ERROR_READING_DEFAULTOFF             = (RASBase+89);
  ERROR_EMPTY_INI_FILE                 = (RASBase+90);
  ERROR_AUTHENTICATION_FAILURE         = (RASBase+91);
  ERROR_PORT_OR_DEVICE                 = (RASBase+92);
  ERROR_NOT_BINARY_MACRO               = (RASBase+93);
  ERROR_DCB_NOT_FOUND                  = (RASBase+94);
  ERROR_STATE_MACHINES_NOT_STARTED     = (RASBase+95);
  ERROR_STATE_MACHINES_ALREADY_STARTED = (RASBase+96);
  ERROR_PARTIAL_RESPONSE_LOOPING       = (RASBase+97);
  ERROR_UNKNOWN_RESPONSE_KEY           = (RASBase+98);
  ERROR_RECV_BUF_FULL                  = (RASBase+99);
  ERROR_CMD_TOO_LONG                   = (RASBase+100);
  ERROR_UNSUPPORTED_BPS                = (RASBase+101);
  ERROR_UNEXPECTED_RESPONSE            = (RASBase+102);
  ERROR_INTERACTIVE_MODE               = (RASBase+103);
  ERROR_BAD_CALLBACK_NUMBER            = (RASBase+104);
  ERROR_INVALID_AUTH_STATE             = (RASBase+105);
  ERROR_WRITING_INITBPS                = (RASBase+106);
  ERROR_INVALID_WIN_HANDLE             = (RASBase+107);
  ERROR_NO_PASSWORD                    = (RASBase+108);
  ERROR_NO_USERNAME                    = (RASBase+109);
  ERROR_CANNOT_START_STATE_MACHINE     = (RASBase+110);
  ERROR_GETTING_COMMSTATE              = (RASBase+111);
  ERROR_SETTING_COMMSTATE              = (RASBase+112);
  ERROR_COMM_FUNCTION                  = (RASBase+113);
  ERROR_CONFIGURATION_PROBLEM          = (RASBase+114);
  ERROR_X25_DIAGNOSTIC                 = (RASBase+115);
  ERROR_TOO_MANY_LINE_ERRORS           = (RASBase+116);
  ERROR_OVERRUN                        = (RASBase+117);
  ERROR_ACCT_EXPIRED                   = (RASBase+118);
  ERROR_CHANGING_PASSWORD              = (RASBase+119);
  ERROR_NO_ACTIVE_ISDN_LINES           = (RASBase+120);
  ERROR_NO_ISDN_CHANNELS_AVAILABLE     = (RASBase+121);

Const
  RASCS_OpenPort = 0;
  RASCS_PortOpened = 1;
  RASCS_ConnectDevice = 2;
  RASCS_DeviceConnected = 3;
  RASCS_AllDevicesConnected = 4;
  RASCS_Authenticate = 5;
  RASCS_AuthNotify = 6;
  RASCS_AuthRetry = 7;
  RASCS_AuthCallback = 8;
  RASCS_AuthChangePassword = 9;
  RASCS_AuthProject = 10;
  RASCS_AuthLinkSpeed = 11;
  RASCS_AuthAck = 12;
  RASCS_ReAuthenticate = 13;
  RASCS_Authenticated = 14;
  RASCS_PrepareForCallback = 15;
  RASCS_WaitForModemReset = 16;
  RASCS_WaitForCallback = 17;

  RASCS_Interactive         = RASCS_Paused;
  RASCS_RetryAuthentication = RASCS_Paused + 1;
  RASCS_CallbackSetByCaller = RASCS_Paused + 2;
  RASCS_PasswordExpired     = RASCS_Paused + 3;

  RASCS_Connected    = RASCS_Done;
  RASCS_DisConnected = RASCS_Done + 1;

Type
{ Identifies an active RAS Connection.  (See RasConnectEnum) }
  PRASConn = ^TRASConn;
  TRASConn = record
     dwSize: DWORD;  
     rasConn: HRASConn;
     szEntryName: Array[0..RAS_MaxEntryName] Of Char;
     szDeviceType : Array[0..RAS_MaxDeviceType] Of Char;
     szDeviceName : Array [0..RAS_MaxDeviceName] of char;
  end;

  PRASConnStatus = ^TRASConnStatus;
  TRASConnStatus = Record
    dwSize: LongInt;
    rasConnstate: Word;
    dwError: LongInt;
    szDeviceType: Array[0..RAS_MaxDeviceType] Of Char;
    szDeviceName: Array[0..RAS_MaxDeviceName] Of Char;
  End;

  PRASDIALEXTENSIONS= ^TRASDIALEXTENSIONS;
  TRASDIALEXTENSIONS= Record
    dwSize: DWORD;
    dwfOptions: DWORD;
    hwndParent: HWnd;
    reserved: DWORD;
   end;

  PRASDialParams = ^TRASDialParams;
  TRASDialParams = Record
    dwSize: DWORD;  
    szEntryName: Array[0..RAS_MaxEntryName] Of Char;
    szPhoneNumber: Array[0..RAS_MaxPhoneNumber] Of Char;
    szCallbackNumber: Array[0..RAS_MaxCallbackNumber] Of Char;
    szUserName: Array[0..UNLEN] Of Char;
    szPassword: Array[0..PWLEN] Of Char;
    szDomain: Array[0..DNLEN] Of Char;
  end;

  PRASEntryName = ^TRASEntryName;
  TRASEntryName = Record
    dwSize: LongInt;
    szEntryName: Array[0..RAS_MaxEntryName] Of Char;
//    Reserved: Byte;
  End;


Function RasDial(
    lpRasDialExtensions : PRASDIALEXTENSIONS ;	// pointer to function extensions data
    lpszPhonebook: PChar;	// pointer to full path and filename of phonebook file
    lpRasDialParams : PRASDIALPARAMS;	// pointer to calling parameters data
    dwNotifierType : DWORD;	// specifies type of RasDial event handler
    lpvNotifier: DWORD;	// specifies a handler for RasDial events
    var rasConn: HRASConn 	// pointer to variable to receive connection handle
   ): DWORD; stdcall;

function RasEnumConnections(RASConn: PrasConn;	   { buffer to receive Connections data }
                            var BufSize: DWord;	   { size in bytes of buffer }
                            var Connections: DWord	{ number of Connections written to buffer }
                            ): LongInt; stdcall;

Function RasEnumEntries (
    reserved: PChar;	// reserved, must be NULL
    lpszPhonebook: PChar  ;	// pointer to full path and filename of phonebook file
    lprasentryname: PRASENTRYNAME ;	// buffer to receive phonebook entries
    var lpcb : 	DWORD;// size in bytes of buffer
    var lpcEntries : DWORD// number of entries written to buffer
   ) : DWORD; stdcall;

function RasGetConnectStatus(RASConn: hrasConn;	{ handle to Remote Access Connection of interest }
                             RASConnStatus: PRASConnStatus	{ buffer to receive status data }
                             ): LongInt; stdcall;

function RasGetErrorString(ErrorCode: DWord;	{ error code to get string for }
                           szErrorString: PChar;	{ buffer to hold error string }
                           BufSize: DWord	{ sizeof buffer }
                           ): LongInt; stdcall;

function RasHangUp(RASConn: hrasConn	{ handle to the Remote Access Connection to hang up }
                   ): LongInt; stdcall;

function RasGetEntryDialParams(
    lpszPhonebook:PChar;	// pointer to the full path and filename of the phonebook file
    VAR lprasdialparams:TRASDIALPARAMS;	// pointer to a structure that receives the connection parameters
    VAR lpfPassword : BOOL	// indicates whether the user's password was retrieved
   ): DWORD; stdcall;

implementation

const
  RAS_DLL = 'RASAPI32';

function RasDial; external RAS_DLL name 'RasDialA';
function RasEnumConnections; external RAS_DLL name 'RasEnumConnectionsA';
function RasEnumEntries; external RAS_DLL name 'RasEnumEntriesA';
function RasGetConnectStatus; external RAS_DLL name 'RasGetConnectStatusA';
function RasGetErrorString; external RAS_DLL name 'RasGetErrorStringA';
function RasHangUp; external RAS_DLL name 'RasHangUpA';
function RasGetEntryDialParams; external RAS_DLL name 'RasGetEntryDialParamsA';
end.

