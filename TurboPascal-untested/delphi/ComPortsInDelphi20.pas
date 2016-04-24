(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0185.PAS
  Description: Com ports in Delphi 2.0
  Author: KEITH ANDERSON
  Date: 11-29-96  08:17
*)


>What I need to do is write an arbitrary number of bytes to a serial
>port.  Period.  No modem commands, no acknowledgement from the
>distant end of the serial line, no reading of the port (at least, not
>yet), no nothing except FOR i := 1 TO X DO Send(AByte);

Well, that's an easy task in D2.  Here is how you open the port:

  Var Port:STRING;  Handle:INTEGER;

  Port:='COM2';  // or whatever COM port
  Handle:=CreateFile(PChar(Port),GENERIC_READ+GENERIC_WRITE,
                               0,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
  If Handle=INVALID_HANDLE_VALUE then exit; // handle the error if it didn't open

  SetupComm(8192,8192);  // works best if you set the buffer size high

Now you write the characters to the port using one of two ways...

Using WriteFile:

  Var DataToSend:STRING;  Written:DWORD;

   WriteFile(Handle,DataToSend[1],Length(String),Written,Nil);

The above will use the buffer to send the data, so it will return before
the actual data has been sent to the port, so be sure to delay a bit
before closing the port so you don't truncate the outgoing data.  The
parameters are Modem handle, Where the data is, The number of
bytes to send, Returns the number of bytes actually sent, and the last
parameter is if you want to do overlapped writes (sounds to me like
you don't need to in your situation).

The other way to send data to the port is

  Var K:CHAR;
  While not TransmitCommChar(Handle,K) do Application.ProcessMessages;

This sends one character at a time.  TransmitCommChar will return
FALSE if the last character sent hasn't actually gone out the port yet,
so you have to loop like above to send every character. It also returns
FALSE if the port hasn't been opened properly, so make sure it was
opened before you get stuck in a loop somewhere./

When you are done with the port, use

   CloseHandle(Handle);

To close the port and turn off the modem.   Make sure you do this
in your error handlers because if the application terminates without
doing this you'll have to reboot your system to get access to the
COM port a second time.

I hope this is what you were looking for.

Regards, Keith


