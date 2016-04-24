(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0026.PAS
  Description: Call NETAPI.DLL function
  Author: ROBIN BOWES
  Date: 08-25-94  09:04
*)

(*
From: ROBIN@plato.ucsalf.ac.uk (Robin Bowes)

I'm trying to call a function in a Windows .dll from
Turbo Pascal for Windows v1.5.

The .dll in question is NETAPI.DLL.  The function I want to call is
defined as follows (in C format):

(from Microsoft LAN Manager Programmer's Reference, )

NetWkstaGetInfo ( const char far *  pszServer,
       short      sLevel,
       char far *    pbBuffer,
       unsigned short   cbBuffer,
       unsigned short far * pcbTotalAvail
      );

where

pszServer
 contains the name of the server on which to execute NetWkstGetInfo.

sLevel
 specfies the level of detail to be supplied in the return buffer

pbBuffer
 points to the buffer in which data is returned

cbBuffer
 specifies the size of the buffer pointed to by pbBuffer

pcbTotalAvail
 points to an unsigned integer in which the number of bytes of
 information available is returned.


The detail level I require is 10 which means that the buffer returned
will contain a wksta_info_10 structure which is defined as follows:

struct wksta_info_10 {
 char far *  wki10_computername;
 char far *  wki10_username;
 char far *  wki10_langroup;
 unsigned char wki10_ver_major;
 unsigned char wki10_ver_minor;
 char far *  wki10_logon_domain;
 char far *  wki10_oth_domains;
};


I am having trouble getting this function to work.  It will be a .dll
eventually but for now I'm jsut coding it as a program using WinCrt.

My code so far looks something like this:
*)
program Username;

uses WinTypes, WinCrt;

const
 NERR_BufTooSmall = 2123;
  NERR_Success   = 0;

type
 Wksta_info_10 =
  record
   wki10_computername : pChar;
   wki10_username   : pChar;
   wki10_langroup   : pChar;
   wki10_ver_major   : Byte;
   wki10_ver_minor   : Byte;
   wki10_logon_domain : pChar;
   wki10_oth_domains  : pChar;
  end;
 pWksta_info_10 = ^Wksta_info_10;

function NetWkstaGetInfo( pszServer     : pChar;
             sLevel      : Integer;
             var pbBuffer   : pWksta_info_10;
             cbBuffer     : Word;
             var pcbTotalAvail : pWord
            ) : Integer; far; external 'NETAPI';

function getUsername(var Username : pChar) : Integer;
var
 pWI        : pWksta_info_10;
 sWorkStationInfo : Word;
 pbBufLen     : pWord;
 pbTotalAvail   : pWord;
 uRetCode     : Integer;

begin
 {first call will fail but should return the size of the
 buffer needed to hold all the available data}
 getMem(pbBufLen, sizeOf(pbBufLen));
  pwI := nil;
 uRetCode := NetWkstaGetInfo(nil,   {Servername (nil -> local machine)}
               10,    {Reporting level}    
               pWI,   {target buffer for info}
               0,    {Size of target buffer}
               pbBufLen {Count of bytes available}
               );
 {check the return code from the function}
 if (uRetCode = NERR_BufTooSmall) then
  { check available memory }
  begin
  if maxAvail < pbBufLen^ then
   begin
   getUsername := -1;
      Exit
   end
    else
   {allocate memory for buffer to hold information}
   begin
   getMem(pWI, pbBufLen^)
   end
  end
 else
   {Unexpected error returned}
  begin
    {Pass return code back to calling program}
  getUsername := uRetCode;
  Exit
  end;

 {second call to get information}
 getMem(pbTotalAvail, sizeOf(pbTotalAvail));
 uRetCode := NetWkstaGetInfo(nil, 10, pWI,  pbBufLen^, pbTotalAvail);
 getUsername := uRetCode;
 if uRetCode = NERR_Success then
   begin
  Username := pWI^.wki10_username;
  end;
 freeMem(pbBufLen, sizeOf(pbBufLen));
 freeMem(pbTotalAvail, sizeOf(pbTotalAvail))
end;

{exports
 getUsername  index 1;}

var
 retVal : Integer;
 uName : pChar;

begin
getMem(uName, sizeOf(uName));
retVal := getUserName(uName);
if retVal = NERR_Success then
 writeln(uName)
else
 writeln('Error returned: ', retVal);
freeMem(uName, sizeOf(uName));
end.
{

This compiles OK but throws a GPF in NETAPI.DLL.

I'm fairly sure it's the conversion of the structure type that's causing
the problem.

Has anybody got any ideas ?

}
