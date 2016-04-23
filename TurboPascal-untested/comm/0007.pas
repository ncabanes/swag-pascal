{
 GL> I am writing a simple dialer and would like to know how do
 GL> I recieve the mode String like "BUSY" and "NO CARRIER" , I
 GL> tried opening the Comport For reading but i just hung the
 GL> Computer. Could you please tell me how ?
 GL> Regards , Gareth

  Gareth,
  I didn't see any replies to your message, but I've been looking
  For the same inFormation myself.  I saw the following code, based
  on a message from Norbert Igl, last year.  When I dial my own
  phone number, it gives me a busy signal For a second or two, and
  then hangs up.  I don't know what makes the busy signal stop.  and
  I don't know how to receive the modem String "BUSY" or "NO CARRIER"
  or "NO DIALtoNE".

  I noticed in my modem manual that modem command X4 will
  generate the following responses:

  Number Response       Word Response
  (V0 command)           (V1 command)

     6                      NO DIALtoNE
     7                      BUSY
     8                      NO ANSWER
                            (The modem responds With 8 if you send
                            the @ command [Wait For Quiet Answer],
                            and it didn't subsequently detect 5
                            seconds of silence.)

     I wish I could figure out a way to "capture" the response, either the
     number (say, 7) or the Word ('BUSY').  if I could detect a busy
     signal, I could then create a loop that would make the
     Program continually redial if it detected busy signals.

     if you figure it out, could you post your solution?

     Here's how Norbert's code With a few modifications:

 Date: 29 Jun 92  23:15:00
 From: Norbert Igl
 to:   Jud Mccranie
 Subj: Dialing the phone

   here's a COM3-able version...(:-)}

   Program Dialing;
   Uses Crt;
   (* no error checking... *)

   Var ch : Char;
       num : String;

   Function Dial( Nb:String; ComPort:Byte ):Char;
            Const  DialCmd = 'ATDT';
                   OnHook  = 'ATH';
                   CR      =  #13;
                   Status  =  5;
            Var    UserKey : Char;
            PortAdr : Word;

            Procedure Com_Write( S: String );
                      Var i:Byte;

                      Function OutputOk:Boolean;
                          begin
                          OutPutOk := ( Port[PortAdr+Status] and $20) > 0;
                          end;

                      Procedure ComWriteCh( Var CH:Char);
                          begin
                          Repeat Until OutPutOk;
                          Port[PortAdr] := Byte(CH);
                          end;

                      begin
                      For i := 1 to length(s) do ComWriteCh(S[i]);
                      end;

            Procedure Com_Writeln( S : String );
                      begin
                      Com_Write( S + CR )
                      end;

   { DIAL.Main }
   begin
   if (ComPort < 1) or ( ComPort > 4) then Exit;
   PortAdr := MemW[$40:(ComPort-1)*2 ];
   if PortAdr = 0 then Exit;
   Repeat
       Com_Writeln( OnHook );
       Delay( 500 );
       Com_Write  ( DialCmd );
       Com_Writeln( Nb );
       UserKey := ReadKey;
       Until UserKey <> ' ';         { Hit [SPACE] to redial ! }
   Com_Writeln( OnHook );        { switch the line to the handset ...}
   Dial := UserKey;              { see what key the user pressed... }
   end;

  begin
    ClrScr;
    Write ('Enter your own phone number:  ');
    Readln(Num);
    Writeln('Dialing now... Should get a busy signal.');
    ch := dial(Num,2);
  end.
