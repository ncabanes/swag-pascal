
If you connect to the Internet a Domain Name Server (DNS) is generally
required to convert English Internet addresses to their natural IP
addresses -- to convert "www.somedomainname.com" to "1.2.3.5" for
example.If you have a need to dynamically change your DNS servers from
your program, all you have to do is call the following
"SetTCPIPDNSAddresses()" function with a list of IPs separated by a
single space.

uses Registry;

procedure
  SaveStringToRegistry_LOCAL_MACHINE(
  sKey, sItem, sVal : string );
var
  reg : TRegIniFile;
begin
  reg := TRegIniFile.Create( '' );
  reg.RootKey := HKEY_LOCAL_MACHINE;
  reg.WriteString(
    sKey, sItem, sVal + #0 );
  reg.Free;
end;

procedure SetTCPIPDNSAddresses(
  sIPs : string );
begin

// Windows NT
  SaveStringToRegistry_LOCAL_MACHINE(
    'SYSTEM\CurrentControlSet\'+
    'Services\Tcpip\Parameters',
    'NameServer',
    sIPs );

// Windows 95
  SaveStringToRegistry_LOCAL_MACHINE(
    'SYSTEM\CurrentControlSet\'+
    'Services\VxD\MSTCP',
    'NameServer',
    sIPs );
end;


For example, if you want to set two DNS servers -- "1.2.3.4" and "5.6.7.8"
-- here's how your function call would look like:

SetTCPIPDNSAddresses('1.2.3.4 5.6.7.8' );


