(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0357.PAS
  Description: Delphi CGI unit
  Author: ANN LYNNWORTH
  Date: 01-02-98  07:33
*)

unit Cgi;

{ cgi.pas

  NOTE : The resource file for this unit is located at the end !!

  Original Author: Ann Lynnworth
  Copyright (c) 1995-1996, Ann Lynnworth.  All Rights Reserved.

  Thanks to Fred Thompson for adding getSmallMultiField().

  Thanks to Dagur Georgsson for testing and debugging the
  internationalization of getSmallField.

  Thanks to Shane Hall <shaneh@clyde.its.unimelb.edu.au> for
  making it work with Microsoft Internet Information Server 1.0.
  Shane's company is Web Down Under P/L in Australia.

  This program may be freely used and modified by anyone.  It would be
  considerate to keep at least these credits and copyright notice intact.

  It is distributed with a "don't laugh at my code" disclaimer.
  This was my first attempt at writing a Delphi component back
  in June '95.  If I change it now, hundreds of web-applications
  will break.  So I'm leaving the data structures alone.

  What would I do different?  For starters, I wouldn't use pstrings
  on the published properties!

  URLs of note:

  http://super.sonic.net/ann/delphi/cgicomp/ -- home of this component
  http://www.href.com/ -- home of my company, HREF Tools Corp., with newer cgi tools
  http://website.ora.com/ -- home of WebSite 32-bit server
  http://www.borland.com/ -- you remember Borland; they made Delphi for us <g>
}

{ Technical support -- sorry, there isn't any.  This is a FREE component.

  Here are the 3 things I usually tell people to get them started:

  1. download the free demo project from http://super.sonic.net/ann/delphi/cgicomp/code.html
  2. If you're following the directions in cgihelp.hlp, make sure you also
     connect the form create method to the form's onCreate event handler.
     That's easy to overlook and of course your app won't work.
  3. To test, you need to run the .exe from a browser using an http command
     in the form: http://127.0.0.1/cgi-win/demo1.exe

     That IP references your local drive.  You can use any other IP
     or domain name.

     You will not be able to test or debug your web-application within Delphi.

     These components do not work as-is with Netscape server, at least
     not with Netscape's implementation of win-cgi as of 2/23/96.
     They only work with WebSite server from O'Reilly & Associates.
}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes,
  forms, iniFiles, Dialogs;

type
  NTWebServerType = (WebSite);   {only one choice; I meant to have more}

type
  TWebServer = class(TComponent);

type
  TCGIEnvData = class(TComponent)
  private
    { Private declarations -- custom for this component }
    fServerType : NTWebServerType;
    fServerComponent : TWebServer;
    fStdOut : integer;
    fAddress : string;
    { for use with WebSite only }
    finiFilename : string;
    {CGI section of web site INI file}
    fCGICGIVersion : string;
    fCGIRequestProtocol : string;
    fCGIRequestMethod : string;  { 'GET' or 'POST' -- should be POST }
    fCGIExecutablePath : string;
    fCGILogicalPath : string;
    fCGIPhysicalPath : string;
    fCGIQueryString : string;
    fCGIContentType : string;
    fCGIContentLength : longInt;
    fCGIServerSoftware : string;
    fCGIServerName : string;
    fCGIServerPort : string;
    fCGIServerAdmin : string;
    fCGIReferer : string;
    fCGIFrom : string;
    fCGIRemoteHost : string;
    fCGIRemoteAddress : string;
    fCGIAuthenticatedUsername : string;
    fCGIAuthenticatedPassword : string;
    fCGIAuthenticationMethod : string;
    fCGIAuthenticationRealm : string;
    fSystemGMTOffset : double;
    fSystemOutputFile : string;
    fSystemContentFile : string;
    fSystemDebugMode : string;
    {Custom Private Procedures & Functions }
    procedure getCGIItem( p : pString; key : string; okEmpty : boolean );
    { CGI }
    function  getCGICGIVersion : pstring;
    function  getCGIRequestProtocol : pstring;
    function  getCGIRequestMethod : pstring;
    function  getCGIExecutablePath : pstring;
    function  getCGILogicalPath : pstring;
    function  getCGIPhysicalPath : pString;
    function  getCGIQueryString : pString;
    function  getCGIContentType : pString;
    function  getCGIContentLength : longInt;
    function  getCGIServerSoftware : pstring;
    function  getCGIServerName : pstring;
    function  getCGIServerPort : pString;
    function  getCGIServerAdmin : pString;
    function  getCGIReferer : pString;
    function  getCGIFrom : pString;
    function  getCGIRemoteHost : pString;
    function  getCGIRemoteAddress : pString;
    function  getCGIAuthenticatedUsername : pString;
    function  getCGIAuthenticatedPassword : pString;
    function  getCGIAuthenticationMethod  : pString;
    function  getCGIAuthenticationRealm   : pString;
    { system }
    {function  getSystemGMTOffset: pstring;}
    function  getSystemOutputFile : pstring;
    function  getSystemDebugMode : pstring;
    function  getSystemContentFile : pstring;
  protected
    { Protected declarations }
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
  public
    { Public declarations }
    { misc }

    { WebSite only }
    procedure setIniFilename( value : string );
    {CGI}
    { Regarding all these pstrings.  I didn't know better.  I was trying to save
      255 bytes x this many properties.  "Don't laugh at my code."  Or laugh away,
      just do it in private. <g> }
    property  CGICGIVersion      : pstring read getCGICGIVersion stored false;
    property  CGIRequestProtocol : pstring read getCGIRequestProtocol stored false;
    property  CGIRequestMethod   : pstring read getCGIRequestMethod stored false;
    property  CGIExecutablePath  : pstring read getCGIExecutablePath stored false;
    property  CGILogicalPath     : pstring read getCGILogicalPath stored false;
    property  CGIPhysicalPath    : pstring read getCGIPhysicalPath stored false;
    property  CGIQueryString     : pString read getCGIQueryString stored false;
    property  CGIContentType     : pString read getCGIContentType stored false;
    property  CGIContentLength   : longInt read getCGIContentLength stored false;
    property  CGIServerSoftware  : pString read getCGIServerSoftware stored false;
    property  CGIServerPort      : pString read getCGIServerPort stored false;
    property  CGIServerName      : pString read getCGIServerName stored false;
    property  CGIServerAdmin     : pstring read getCGIServerAdmin stored false;
    property  CGIReferer         : pString read getCGIReferer stored false;
    property  CGIFrom            : pString read getCGIFrom stored false;
    property  CGIRemoteHost      : pString read getCGIRemoteHost stored false;
    property  CGIRemoteAddress   : pString read getCGIRemoteAddress stored false;
    property  CGIAuthenticatedUsername : pString read getCGIAuthenticatedUsername stored false;
    property  CGIAuthenticatedPassword : pString read getCGIAuthenticatedPassword stored false;
    property  CGIAuthenticationMethod  : pString read getCGIAuthenticationMethod  stored false;
    property  CGIAuthenticationRealm   : pString read getCGIAuthenticationRealm   stored false;
    {System}
    property  SystemGMToffset : double read fSystemGMToffset stored false;
    property  SystemOutputFile : pstring read getSystemOutputFile stored false;
    property  SystemContentFile : pstring read getSystemContentFile stored false;
    property  SystemDebugMode : pstring read getSystemDebugMode stored false;
  published
    { Published declarations }

    { set this to your address, e.g. ann@href.com }
    property    address : string read fAddress write fAddress;

    { ServerTypes WebSite and httpd16 are functionally equivalent. }
    { The whole issue of ServerType is silly. }
    { Property is left in for compatibility only. 1-Jan-96 }
    property    ServerType : NTWebServerType read fServerType write fServerType;

    function    swapChar( s : string; fromChar : char; toChar : char ) : string;

    { set this to paramstr(1) at the beginning of your program }
    property    webSiteIniFilename : string read finiFilename write setIniFilename;

    { ***************************** }

    { Use the LOCATION: URL feature to "bounce" a user to a URL }
    procedure   bounceToLocation( goHere : string );

    { set application.onException to TCGIEnvData1.cgiErrorHandler as soon as you can in your app! }
    procedure   cgiErrorHandler( sender : TObject; e : Exception ) ;

    { call this at the end of your program }
    procedure   closeStdout;

    { This opens the stdout file based on filename created by WebSite;
      if you forget this line, the first send command will take care of it
      for you automatically. }
    function    createStdout : boolean;

    { get data from a named External field {size between 255 and 64K chars
      and put it into a PChar.  If you're basically working with input from
      a TextArea on a form, see getTextArea below.  It will be much more
      convenient. }
    function    getExternalField( key : string; var externFilename : string; dest : PChar ) : boolean;

    { get everything in a section ('Form Literal' or 'Form External').  Refer to
      readSectionValues in Delphi Help. This is the same thing -- it just automatically
      goes to the correct INI file for you. }
    function    getSectionValues( sectionName : string; strings : TStringList ) : boolean;

    { get data from an HTML form based on field name ("key") }
    function    getSmallField( key : string ) : string;

    {***********************************************************************}
    {*** getSmallMultiField - added Dec. 17, 1995 - Fred Thompson **********}
    {***********************************************************************}
    { get Multiple data from an HTML form based on field name ("key")       }
    { Return value contains all the values selected.                        }
    function    getSmallMultiField( key : string ) : Tstringlist;
    {***********************************************************************}

    { TextAreas are tricky.  If the user only enters one line of text, that
      text is stored as a "small field" in the [Form Literal] section.  This
      function hides that complexity and lets you simply work with a string
      list (which might only have one string in it).  }
    function    getTextArea( key : string; dest : TStringList ) : boolean;

    { send a line of code to stdout (including required CR/LF) }
    function    send( s : string ) : boolean ;
    function    sendString( s : string; appendNewline : boolean ) : boolean;

    { send contents of Address property }
    function    sendAddress : boolean;

    function    sendAuthRequest : boolean;

    { send wallpaper background command (HTML 3.0) -- no color control yet }
    function    sendBackground( imageFilename : string ) : boolean;

    { send a string to stdout, as a comment.  This is used internally to
      alert you to warnings/errors. }
    procedure   sendComment( s : string );

    { send header, e.g. H1, H2, etc. }
    function    sendHdr( hdrLevel : char; hdrText : string ) : boolean;

    { send horizonal ruler line command }
    function    sendHR : boolean;

    { send A HREF command including optional image and optional (netscape) attributes
      such as align=left or hspace=5 }
    function    sendHREF( imageFilename : string; imageAttrib : string;
                          visiblePhrase : string; linkedURL : string ) : boolean;

    { send a simple IMG SRC phase.  attrib can be hspace=5 or align=left }
    function    sendIMG( imageFilename : string; imageAttrib : string ) : boolean;

    procedure   sendMailto( emailAddress : string );

    { do nothing; copied from Bob Denny's cgi.bas.  Bob Denny is the author of
      Win-Httpd and WebSite server.  He has my endless gratitude for answering
      my endless questions in May '95. }
    procedure   sendNoOp;

    { send HTTP/1.0 200 OK etc. }
    function    sendPrologue : boolean;

    { send TITLE phrase }
    function    sendTitle( title : string ) : boolean;

    { convert Delphi date/time to GMT for use in HTML header }
    function    webDate (dt : TDateTime ) : string ;

  end;

{***************************************************************}
{***************************************************************}

type
  TWebsite = class(TWebServer)
  private
    fServerType : NTWebServerType;
    fCGI : TCGIEnvData;
    fIniFile : TIniFile;
    { custom }
    procedure CGIData( p : pString; key : string; okEmpty : boolean );
    procedure initData;
    function  readWebSiteCGIString( key : string; okEmpty : boolean ) : string;
    function  getExternalField( key : string; var externFilename : string; dest : PChar ) : boolean;
    function  getTextArea( key : string; dest : TStringList ) : boolean;
  public
    { Public declarations }
    property    INIFile: TIniFile read fIniFile stored false;
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
  published
    function    getSmallField( key : string ) : string;
    function    getSmallMultiField( key: string) :Tstringlist;     {*FWT*}
end;

const
     MAXTABLEFIELDS = 255;  { no more than 255 fields displayed in HTML Table }

     CGINOTFOUND = 'AAAKEY NOT FOUND';

     MAX_CMDARGS = 8;       { Max # of command line args }
     ENUM_BUF_SIZE = 4096;  { Key enumeration buffer, see GetProfile() }
     { These are the limits in the server }
     MAX_XHDR = 100;        { Max # of "extra" request headers }
     MAX_ACCTYPE = 100;     { Max # of Accept: types in request }
     MAX_FORM_TUPLES = 100; { Max # form key=value pairs }
     MAX_HUGE_TUPLES = 16;  { Max # "huge" form fields }

procedure closeApp( app : TApplication );
procedure Register;

implementation

{$IFDEF WIN32}
{$R CGI32.RES}
{$ELSE}
{$R CGI.DCR}
{$ENDIF}

constructor TCGIEnvData.Create(AOwner: TComponent);
begin

  inherited Create(AOwner);

    fStdOut := -99;
    fAddress := '';

  { CGI section }
    fCGICGIVersion := '';
    fCGIRequestProtocol := '';
    fCGIRequestMethod := '';
    fCGIExecutablePath := '';
    fCGILogicalPath := '';
    fCGIPhysicalPath := '';
    fCGIQueryString := '';
    fCGIContentType := '';
    fCGIContentLength := -1;   { init to -1 }
    fCGIServerSoftware := '';
    fCGIServerName := '';
    fCGIServerPort := '';
    fCGIServerAdmin := '';
    fCGIReferer := '';
    fCGIFrom := '';
    fCGIRemoteHost := '';
    fCGIRemoteAddress := '';
    fCGIAuthenticatedUsername := '';
    fCGIAuthenticatedPassword := '';
    fCGIAuthenticationMethod  := '';
    fCGIAuthenticationRealm   := '';

  { System section }
    fSystemGMTOffset := 0;
    fSystemOutputFile := '';
    fSystemContentFile := '';
    fSystemDebugMode := '';

    { Please realize that I thought there might be different
      components for different web servers, and the correct one
      would be linked in.  That whole strategy was abandoned. }
    fServerComponent := nil;
    if NOT (csDesigning in ComponentState) then
      fServerComponent := TWebsite.create( self );
end;

destructor TCGIEnvData.Destroy;
begin
     if fStdOut > 0 then
        closeStdOut;
     if NOT (csDesigning in ComponentState) then
       fServerComponent.free;
     inherited Destroy;
end;

{ **************************************************************
          get CGI information from variables from INI file
  ************************************************************** }

function  TCGIEnvData.getCGICGIVersion : pString;
begin
  result := addr( fCGICGIVersion );
end;

procedure TCGIEnvData.getCGIItem( p : pString; key : string; okEmpty : boolean );
var
  x : TWebsite;
begin
  x := TWebsite( fServerComponent );
  x.CGIData( p, key, okEmpty );
end;

function  TCGIEnvData.getCGIRequestProtocol : pstring ;
begin
  getCGIitem( addr( fCGIRequestProtocol ), 'Request Protocol', TRUE );
  result := addr( fCGIRequestProtocol );
end;

function  TCGIEnvData.getCGIRequestMethod : pString;
begin
  result := addr( fCGIRequestMethod );
end;

function  TCGIEnvData.getCGIExecutablePath : pString;
begin
  result := addr( fCGIExecutablePath );
end;

function  TCGIEnvData.getCGILogicalPath : pstring ;
begin
  getCGIItem( addr( fCGILogicalPath ), 'Logical Path', FALSE );
  result := addr( fCGILogicalPath );
end;

function  TCGIEnvData.getCGIPhysicalPath : pString ;
begin
  getCGIItem( addr( fCGIPhysicalPath ), 'Physical Path', FALSE );
  result := addr( fCGIPhysicalPath );
end;

function  TCGIEnvData.getCGIQueryString : pString;
begin
  { it's because of QueryString being blank sometimes that the
    okEmpty parameter was added throughout. }
  getCGIItem( addr( fCGIQueryString ), 'Query String', TRUE );
  result := addr( fCGIQueryString );
end;

function  TCGIEnvData.getCGIContentType : pString;
begin
  getCGIItem( addr( fCGIContentType ), 'Content Type', FALSE );
  result := addr( fCGIContentType );
end;

function  TCGIEnvData.getCGIContentLength : longInt;
var
  x : TWebSite;
begin
  if fCGIContentLength <> -1 then begin
    { we've already loaded the information }
    result := fCGIContentLength;
    exit;
    end;
  x := TWebsite( fServerComponent );
  fCGIContentLength := x.fIniFile.readInteger( 'CGI', 'Content Length', 0 );
  result := fCGIContentLength;
end;

function  TCGIEnvData.getCGIServerSoftware : pString;
begin
  result := addr( fCGIServerSoftware );
end;

function  TCGIEnvData.getCGIServerName : pstring ;
begin
  getCGIItem( addr( fCGIServerName ), 'Server Name', FALSE );
  result := addr( fCGIServerName );
end;

function  TCGIEnvData.getCGIServerPort : pstring ;
begin
  getCGIItem( addr( fCGIServerPort ), 'Server Name', FALSE );
  result := addr( fCGIServerPort );
end;

function  TCGIEnvData.getCGIServerAdmin : pString;
begin
  result := addr( fCGIServerAdmin );
end;

function  TCGIEnvData.getCGIReferer : pstring ;
var
  x : TWebSite;

begin
  getCGIItem( addr( fCGIReferer ), 'Referer', FALSE );
  if fCGIReferer = cginotfound then begin
    x := TWebsite( fServerComponent );
    fCGIReferer := x.fIniFile.readString( 'Extra Headers', 'Referer', cginotfound );
    end;
  result := addr( fCGIReferer );
end;

function  TCGIEnvData.getCGIFrom : pstring ;
begin
  getCGIItem( addr( fCGIFrom ), 'From', FALSE );
  result := addr( fCGIFrom );
end;

function  TCGIEnvData.getCGIRemoteHost : pstring ;
begin
  getCGIItem( addr( fCGIRemoteHost ), 'Remote Host', FALSE );
  result := addr( fCGIRemoteHost );
end;

function  TCGIEnvData.getCGIRemoteAddress : pstring ;
begin
  getCGIItem( addr( fCGIRemoteAddress ), 'Remote Address', FALSE );
  result := addr( fCGIRemoteAddress );
end;

function  TCGIEnvData.getCGIAuthenticatedUsername : pstring ;
begin
  getCGIItem( addr( fCGIAuthenticatedUsername ), 'Authenticated Username', TRUE );
  result := addr( fCGIAuthenticatedUsername );
end;

function  TCGIEnvData.getCGIAuthenticatedPassword : pstring ;
begin
  getCGIItem( addr( fCGIAuthenticatedPassword ), 'Authenticated Password', TRUE );
  result := addr( fCGIAuthenticatedPassword );
end;

function  TCGIEnvData.getCGIAuthenticationMethod : pstring ;
begin
  getCGIItem( addr( fCGIAuthenticationMethod ), 'Authentication Method', TRUE );
  result := addr( fCGIAuthenticationMethod );
end;

function  TCGIEnvData.getCGIAuthenticationRealm : pstring ;
begin
  getCGIItem( addr( fCGIAuthenticationRealm ), 'Authentication Realm', TRUE );
  result := addr( fCGIAuthenticationRealm );
end;

function  TCGIEnvData.getSectionValues( sectionName : string; strings : TStringList ) : boolean;
var
  x : TWebsite;
begin
  strings.clear;
  x := TWebsite( fServerComponent );
  x.fIniFile.readSectionValues( sectionName, strings );
  result := (strings.count > 0);
end;


{ **************************************************************
          get SYSTEM information from variables from INI file
  ************************************************************** }

function  TCGIEnvData.getSystemOutputFile : pString;
begin
  result := addr( fSystemOutputFile );
end;

function  TCGIEnvData.getSystemContentFile : pstring ;
var
   x : TWebSite;
begin
  if fSystemContentFile = '' then begin
    x := TWebsite( fServerComponent );
    fSystemContentFile := x.fIniFile.readString( 'System', 'Content File', cginotfound );
    end;
  result := addr( fSystemContentFile );
end;

function  TCGIEnvData.getSystemDebugMode : pstring ;
var
   x : TWebSite;
begin
  if fSystemDebugMode = '' then
  begin
    case fServerType of
    webSite :
      begin
        x := TWebsite( fServerComponent );
        fSystemDebugMode := x.fIniFile.readString( 'System', 'Debug Mode', cginotfound );
      end;
    else
      raise exception.create( 'Can not get Debug Mode; invalid web server type' );
    end;
  end;
  result := addr( fSystemDebugMode );
end;

{ Get the value of a "small" form field given the key
  Signals an error if field does not exist }
function TCGIEnvData.getSmallField( key : string ) : string;
var
   x : TWebsite;
   FileName: string;
   i,FileHandle:  integer;
   read:          byte;
   buffer:array[0..255] of char;
   r1 : string;
begin
  x := TWebsite( fServerComponent );
  result := x.getSmallField( key );
  {************* code added to handle long or control chars **********FWT*}
  if result = cginotfound then  begin
      result := x.fIniFile.readString( 'Form External', key, cginotfound );
      if result = cginotfound then
          exit;
      i := pos( ' ', result );
      FileName := copy( result, 0, i - 1 );
      i := strToInt( copy( result, i, 10 ) ) ;
      read := 255;
      FileHandle := fileOpen( FileName, fmOpenRead );
      if FileHandle > 0 then begin
          fileRead( FileHandle, buffer[0], read );
          fileClose( FileHandle );
          buffer[read] := #0;                     {mark the ending}
          if i > read then begin                  {indicate truncation}
            buffer[254] := '*';
            buffer[255] := '$';
            end
          else begin
            result := copy(strpas(buffer), 1, i);  {...'i' contains the correct string length...}
            end
          end
        else
          result := cginotfound;
      end;

  {******************** end of code added for long or control chars***FWT*}
end;

{************************** routine added - start of change **************FWT*}
{ Get the values of a "small" multiple selection form field given the key
  Signals an error if field does not exist }
function TCGIEnvData.getSmallMultiField( key : string ) : Tstringlist;
var
   x : TWebsite;
begin
  x := TWebsite( fServerComponent );
  result := x.getSmallMultiField( key );
end;
{************************** routine added - end of change ***************FWT*}

function TCGIEnvData.getExternalField( key : string; var externFilename : string; dest : PChar ) : boolean;
var
  x : TWebsite;
begin
  x := TWebsite( fServerComponent );
  result := x.getExternalField( key, externFilename, dest );
end;

function TCGIEnvData.getTextArea( key : string; dest : TStringList ) : boolean;
var
  x : TWebsite;
begin
  x := TWebsite( fServerComponent );
  result := x.getTextArea( key, dest );
end;

{ ************************************************************}

function TCGIEnvData.createStdout : boolean ;
begin
  { create output file and save pointer to it }
  {// ssh}
  if fCGIServerSoftware = 'Microsoft-Internet-Information-Server/1.0' then
      fStdout := fileOpen( fSystemOutputFile, fmOpenWrite or fmShareDenyNone )
  else
      fStdout := fileCreate( fSystemOutputFile );
  if fStdOut < 0 then begin
    raise exception.create( 'Error code [' + intToStr( fStdOut ) +
      '] when creating file (' + fSystemOutputFile + ')' );
  end;
  result := TRUE;
end;



function TCGIEnvData.send( s : string ) : boolean ;
begin

  result := sendString( s, TRUE );

end;

function TCGIEnvData.sendAuthRequest : boolean;
begin

    closeStdout;
    createStdout;

    result := send( 'HTTP/1.0 401 Unauthorized' );

    closeStdout;

end;

function TCGIEnvData.sendString( s : string; appendNewline : boolean ) : boolean;
const
  newLine : string[4] = #13#10;   {what's the minimum size here? 2? 3? 4? }
var
  s2 : string;
  count : longInt;
begin

  if fStdOut < 0 then
     if NOT createStdout then
       raise exception.create( 'Can not create stdout' );

  if appendNewline then
    s2 := s + newLine
  else
    s2 := s; { will performance suffer? should there be a separate routine here? }

  count := length( s2 );

  { since the first byte of s2 contains the length, we shouldn't write
  that out. Start instead with the next byte, which is s2[1]. }
  result := ( fileWrite( fStdout, s2[1], count ) = count );

end;

procedure TCGIEnvData.closeStdout;
begin
     fileClose( fStdout );
end;

{ SendNoOp() - Tell browser to do nothing.
  Most browsers will do nothing. Netscape 1.0N leaves hourglass
  cursor until the mouse is waved around. Enhanced Mosaic 2.0
  oputs up an alert saying "URL leads nowhere". Your results may
  vary...}
procedure TCGIEnvData.sendNoOp;
begin
    Send ('HTTP/1.0 204 No Response');
    Send ('Server: ' + fCGIServerSoftware );
    Send ('');
end;

{ WebDate - Return an HTTP/1.0 compliant date/time string

  Inputs:   dt = Local time as TDateTime (e.g., returned by Now)
  Returns:  Properly formatted HTTP/1.0 date/time in GMT }

function TCGIEnvData.webDate (dt : TDateTime ) : String ;
begin
    WebDate := FormatDateTime('ddd dd mmm yyyy hh:mm:ss "GMT"',
               dt - fSystemGMTOffset );
end;

procedure TCGIEnvData.bounceToLocation( goHere : string );
begin
    closeStdout;
    createStdout;
    Send ('LOCATION: ' + goHere );
    Send ('');
    closeStdout;
end;

function  TCGIEnvData.sendAddress : boolean;
begin
  if fAddress = '' then
     result := FALSE
  else
      result := send( '<ADDRESS>' + fAddress + '</ADDRESS>' );
end;

function  TCGIEnvData.sendHR : boolean;
begin
  result := send( '<HR>' );
end;

function  TCGIEnvData.sendHdr( hdrLevel : char; hdrText : string ) : boolean;
begin
  if ( hdrLevel < '1' ) OR ( hdrLevel > '6' ) then
  begin
    sendComment( 'hdrLevel should be between 1 and 6.  Ref: ' + hdrText );
    result := FALSE;
  end
  else
    result := send( '<H' + hdrLevel + '>' + hdrText + '</H' + hdrLevel + '>' );
end;

function  TCGIEnvData.sendHREF( imageFilename : string;
                                    imageAttrib : string;
                                    visiblePhrase : string;
                                    linkedURL : string ) : boolean;
begin

  if linkedURL = '' then begin
     result := FALSE;
     exit;
    end;

{ Here is a sample of what this can result in:
<A HREF="http://www.sonic.net/~ann/htmlsmnr.html">
<IMG SRC="/html/ann/infobahn.gif"
>InfoBahn Construction Workshop</A>!
}
  send( '<A HREF="' + linkedURL + '">' );
  if imageFilename <> '' then
    send( '<IMG ' + imageAttrib + ' SRC="' + imageFilename + '">' );

  result := send( visiblePhrase + '</A>' );
end;

function  TCGIEnvData.sendIMG( imageFilename : string; imageAttrib : string ) : boolean;
begin
  result := send( '<IMG ' + imageAttrib + ' SRC="' + imageFilename + '">' );
end;

function  TCGIEnvData.sendPrologue : boolean;
begin
  try
    send( 'HTTP/1.0 200 OK' );
    send( 'SERVER: ' + fCGIServerSoftware );
    send( 'DATE: ' + webDate( now ) );
    send( 'Content-type: text/html' );
    send( '' );          { required blank line }
    result := TRUE;
  except
    result := FALSE;
  end;
end;


function  TCGIEnvData.sendTitle( title : string ) : boolean;
begin
  result := send( '<TITLE>' + title + '</TITLE>' );
end;

function  TCGIEnvData.sendBackground( imageFilename : string ) : boolean;
begin
  {<body background="bkground.gif">}
  result := send( '<BODY BACKGROUND="' + imageFilename + '"' );
end;

procedure TCGIEnvData.sendComment( s : string );
begin
  send( '<!-- ' + s + ' -->' );
end;

procedure TCGIEnvData.sendMailto( emailAddress : string );
begin
  send( '<A HREF="mailto:' + emailAddress + '">' + emailAddress + '</A>' );
end;

procedure TCGIEnvData.cgiErrorHandler( sender: TObject; e : Exception );
begin
     if fStdout = -99 then
        { haven't even gotten as far as opening stdout at all yet! }
        { this would be a bad time to count on writing to that file !! }
       closeApp( application );
try
    createStdout;
    Send ('HTTP/1.0 500 Internal Error');
    Send ('SERVER: ' + fCGIServerSoftware);
    Send ('DATE: ' + WebDate(Now) );
    Send ('Content-type: text/html' );
    Send ('');
    Send ('<HTML><HEAD>');
    Send ('<TITLE>Error in ' + fCGIExecutablePath + '</TITLE>' );
    Send ('</HEAD><BODY>');
    SendHdr( '2', 'Error in ' + fCGIExecutablePath );
    Send ('An internal error has occurred in this program: ' + fCGIExecutablePath + '.');
    Send ('<PRE>' + e.message + '</PRE>');
    Send ('<I>Please</I> note what you were doing when this problem occurred, ');
    Send ('so we can identify and correct it. Write down the Web page you were using, ');
    Send ('any data you may have entered into a form or search box, the' );
    Send ('date and time listed below, and ');
    Send ('anything else that may help us duplicate the problem. Then contact the ');
    Send ('administrator of this service: ');
    Send ('<A HREF="mailto:' + fCGIServerAdmin + '">' + fCGIServerAdmin + '</A> ' );
    SendHR;
    send( 'Generated on: ' + webDate( now ) );
    Send ('</BODY></HTML>');
    fileClose( fStdOut );
    fStdOut := -99;
finally
  { the bottom line! }
    closeApp( application );
end;

end;

procedure TCGIEnvData.setIniFilename( value : string );
var
   x : TWebSite;
begin
  fINIFilename := value;
  if NOT ( csDesigning in componentState ) then begin
    x := TWebSite( fServerComponent );
    x.initData;
    end;
end;

function TCGIEnvData.swapChar( s : string; fromChar : char; toChar : char ) : string;
var
  i : shortint;
begin
  for i := 1 to length( s ) do
    if s[i] = fromChar then
      s[i] := toChar;
  result := s;
end;

{***************************************************************}
{***************************************************************}

constructor TWebsite.create(AOwner: TComponent);
begin
  if AOwner = nil then
    raise exception.create( 'Tried to create TWebsite object with nil owner.' );

  inherited Create(AOwner);

  fIniFile := nil;
  fServerType := WebSite;

  { this works only if AOwner is a valid pointer, which it should be
  since we're only created from within a CGIEnvData component }
  fCGI := TCGIEnvData(AOwner);  { connect back to CGIEnvData }
end;

procedure TWebSite.initData;
begin
  if fCGI.WebSiteINIFilename = '' then
    raise exception.create( 'WebSiteINIFilename is blank' );

  try
     { create pointer to INI file }
     fIniFile := tInifile.create( fCGI.WebSiteIniFilename );
  except
     raise exception.create( 'Can not create tIniFile object' );
  end;

  with fCGI do begin
    { [CGI]                <== The standard CGI variables }
    fCGICGIVersion     := readWebSiteCGIString( 'CGI Version', FALSE );
    fCGIRequestMethod  := readWebSiteCGIString( 'Request Method', FALSE );
    { Request Protocol handled elsewhere }
    {//ssh}
    fCGIServerSoftware := readWebSiteCGIString( 'Server Software', FALSE );
    if fCGIServerSoftware = 'Microsoft-Internet-Information-Server/1.0' then
        fCGIExecutablePath := readWebSiteCGIString( 'Referer', FALSE )
    else
        fCGIExecutablePath := readWebSiteCGIString( 'Executable Path', FALSE );

    fCGIServerAdmin    := readWebSiteCGIString( 'Server Admin', TRUE );
    end;

  with fIniFile do begin
    { [System]             <== Windows interface specifics }
    { in visual basic: CGI_GMTOffset = CVDate(CDbl(buf) / 86400#)' Timeserial offset }
    fCGI.fSystemGMToffset := ( readInteger( 'System', 'GMT Offset', 0 ) / 86400 );  { fixed 6/12/95 aml }
    fCGI.fSystemOutputFile  := readString( 'System', 'Output File', 'ann_x.out' );
    fCGI.fSystemContentFile := readString( 'System', 'Content File', '' );
  end;
end;

destructor TWebsite.Destroy;
begin
     fIniFile.free;
     inherited Destroy;
end;

function TWebsite.readWebSiteCGIString( key : string; okEmpty : boolean ) : string;
begin
  result := fINIfile.readString( 'CGI', key, cginotfound );
{ notfound is not always bad, e.g. user might not be authenticated first time around }
   if result = cginotfound then
     if NOT okEmpty then
       fCGI.sendComment( '[CGI] ' + key + ' key not found in WebSite INI file' );
end;

procedure TWebsite.CGIData( p : pString; key : string; okEmpty : boolean );
begin
     if p^ = '' then
        p^ := readWebSiteCGIString( key, okEmpty );
end;

{ returns KEY NOT FOUND and logs sendComment if that happens; otherwise full text }
function TWebsite.getSmallField( key : string ) : string;
begin
  with fIniFile do
    result := readString( 'Form Literal', key, cginotfound );

  if result = cginotfound then
    fCGI.sendComment( 'Field ' + key + ' is not in [Form Literal] section of WebSite .ini file.' );
end;

{ returns KEY NOT FOUND and logs sendComment if that happens; otherwise full text }
function TWebsite.getSmallMultiField( key : string ) : Tstringlist;
var
  varval, varname: string;
begin
  result := TStringList.create;
  varname := key;
  varval  := 'start';
  while varval <> cginotfound do begin
    with fIniFile do
      varval := readString( 'Form Literal', varname, cginotfound );
      if varval <> cginotfound then begin
          result.add( varval );
          varname := key+'_'+IntToStr(result.count);
          end;
    end;
end;

{ if key not found, then 3 things happen.  1. returns false
  2. externFilename set to ''   3. error comment sent out }
function TWebsite.getExternalField( key : string;
                                    var externFilename : string;
                                    dest : PChar ) : boolean;
var
  info : string;
  buffer : string;
  x : byte;
  dataSize : integer;
  fileHandle : integer;

begin

{ [Form External]  notes written by Bob Denny and included in cgi.bas
  If the decoded value string is more than 254 characters long,
  or if the decoded value string contains any control characters,
  the server puts the decoded value into an external tempfile and
  lists the field in this section as:
     key=<pathname> <length>
  where <pathname> is the path and name of the tempfile containing
  the decoded value string, and <length> is the length in bytes
  of the decoded value string.

  Data larger than 65,536 bytes goes to [Form Huge] section. }

     with fIniFile do
       info := readString( 'Form External', key, cginotfound );

     if info = cginotfound then
     begin
       result := FALSE;
       externFilename := '';
       fCGI.sendComment( 'Field ' + key + ' is not in [Form External] section of WebSite .ini file.' );
       exit;
     end;

     x := pos( ' ', info );
     externFilename := copy( info, 0, x - 1 );

     dataSize := strToInt( copy( info, x, 10 ) ) ;
     dest := strAlloc( dataSize + 1 );

     { !!! need more error checking in this routine }
     fileHandle := fileOpen( externFilename, fmOpenRead );
     fileRead( fileHandle, dest, dataSize );
     fileClose( fileHandle );
     result := TRUE;
end;

function TWebsite.getTextArea( key : string; dest : TStringList ) : boolean;
var
  info : string;
  buffer : string;
  x : byte;
  dataSize : integer;
  f : textFile;
  externfilename : string;

begin

     result := TRUE;

     if dest = nil then
     begin
       dest := TStringList.create;
       fCGI.sendComment( 'TstringList was nil in call to getExternalStrList.  ' +
                            'You should be using TStringList.create and .free yourself.' );
     end;

     dest.clear;

     { first see whether it's there as a one-liner }
     buffer := getSmallField( key );
     if buffer <> cginotfound then
     begin
       dest.add( buffer );    { all done }
       exit;
     end;


     with fIniFile do
       info := readString( 'Form External', key, cginotfound );

     if info = cginotfound then
     begin
       result := FALSE;
       fCGI.sendComment( 'Field ' + key + ' is not in [Form External] section of WebSite .ini file.' );
       exit;
     end;

     x := pos( ' ', info );
     externFilename := copy( info, 0, x - 1 );

     dataSize := strToInt( copy( info, x, 10 ) ) ;

     { !!! need more error checking in this routine }
     assignFile( f, externFilename );
     reset(f);
     while NOT eof(f) do
     begin
       readLn( f, buffer );
       dest.add( buffer );
     end;
     closeFile( f );
     result := TRUE;

end;

procedure closeApp( app : TApplication );
begin
  {Thanks to Charlie Calvert for the postMessage syntax. }
  { FYI: app.close; doesn't work and halt(1) is bad because resources aren't freed. }
  postMessage( app.Handle, wm_Close, 0, 0);
end;

{***************************************************************}
{***************************************************************}

procedure Register;
begin
  RegisterComponents('CGI', [TCGIEnvData]);
end;

end.

{ ----------------------------  RESOURCE FILE FOR THIS UNIT --------------- }

{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-000476-310396--72--85-41950-------CGI32.RES--1-OF--1
+++++0++++1zzk++zzw+++++++++++++++++++++++06+E++B++++Dzz+U-I+2A+Fk-7+2I+
HU-K+2E+EE-I+22+++++++++A+++++++++++++++8++++-U++++M+++++E+2+++++++U+E++
+++++++++++++++++++++++++++++6+++6++++0+U+0+++++U+0++60+++0+U6++kA1+++++
zk++zk+++Dzz+Dw+++1z+Dw+zzw++Dzzzk-rRrRrRrF2FrRrRrS6W6W6W6W6V6W6W6S6W6V2
G6V2V6G6W6S6W6G6V6G6F6G6W6S6W6G6W6G6V6G6W6S6W6G6W6G6V6G6W6S6W6G6V6G6F6G6
W6S6W6V2G6V2V6G6W6S6W6W6W6W6W6W6W6S6W6W6W6W6W6G6W6S6W6nAr6mAnAW6W6S6WAm6
WAP6W6n6W6S6W-X6X6m-WCVcW6S6WAWAu6m6n6X6W6S6WAW6n6mAm6X6W6S6W4W6mAH6m6XM
W6S6WAW6n6mAO6X6W6S6W2WAu6m6n6X6W6S6WAX6X6mBWAX6W6S6WAm6WA56W6n6W6S6W6n6
W6m6WAu6W6S6W6XArAnAlAW6W6S6W6W6W6W6W6W6W6S6W6W6W6W6W6W6W6Q+
***** END OF BLOCK 1 *****


