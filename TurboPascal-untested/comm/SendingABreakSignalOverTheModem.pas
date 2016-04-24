(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0061.PAS
  Description: Sending A Break Signal Over the Modem
  Author: DANIEL SANDS
  Date: 11-26-94  05:05
*)

{
Set your modem to send a break signal
Then enable break: (assuming COM1)
}

port[$3fb] := port[$3fb] or $40;
delay(100);
port[$3fb] := port[$3fb] and $bf;

