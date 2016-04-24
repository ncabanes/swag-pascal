(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0267.PAS
  Description: Change NETSCAPE preferences programatica
  Author: CHAMI
  Date: 05-30-97  18:17
*)


How to change Netscape preferences from your program (and access multiple
email accounts)


--------------------------------------------------------------------------------
If you've been wondering how to change Netscape Navigator's preferences
(or settings) from your program, take a look at the following function:

procedure SetNetscapeMailPreferences(
  sUserName,
  sMailboxName,
  sFromAddress,
  sReplyToAddress,
  sOrganization,
  sSignatureFile,
  sSMTPServer,
  sPOPServer
    : string );
var
  r : TRegIniFile;

  procedure Save( a, b, c : string );
  begin
    r.WriteString( a, b, c + #0 );
  end;

begin
  r := TRegIniFile.Create(
         'Software\'
       + 'Netscape\Netscape Navigator'
       );

  Save( 'Mail', 'POP Name',
    sMailboxName );

  Save( 'Services', 'POP_Server',
    sPOPServer );

  Save( 'Services', 'SMTP_Server',
    sSMTPServer );

  Save( 'User', 'User_Addr',
    sFromAddress );

  Save( 'User', 'User_Name',
    sUserName );

  Save( 'User', 'Reply_To',
    sReplyToAddress );

  Save( 'User', 'User_Organization',
    sOrganization );

  Save( 'User', 'Sig_File',
    sSignatureFile );

  r.Free;
end;


As you can see, Netscape stores its settings in the following registry key:

HKEY_CURRENT_USER\
  Software\
    Netscape\
      Netscape Navigator

To get a list of all the settings you can change, simply run the "Registry
Editor" (RegEdit.exe) and select the above registry key.

Our example function "SetNetscapeMailPreferences()" will let you change your
Netscape's mail preferences, which means you can utilize it to write a
program that will let users access multiple email accounts using a single
installation of Netscape Navigator. Here's a sample call:

SetNetscapeMailPreferences(
  'Bob B Bob',
  'bob',
  'bob@bob.com',
  'bob@bob.com',
  'Bob Inc.',
  'C:\Sign.TXT',
  'bob.com',
  'bob.com' 
);


NOTE: Netscape should be closed at the time you make modifications to it's
registry entires. Otherwise, your changes may not take effect.
