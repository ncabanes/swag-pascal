{
Set your modem to send a break signal
Then enable break: (assuming COM1)
}

port[$3fb] := port[$3fb] or $40;
delay(100);
port[$3fb] := port[$3fb] and $bf;
