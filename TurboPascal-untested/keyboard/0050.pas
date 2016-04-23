(*
From: MARC BIR
Subj: KEYBOARD Simulation

{BW>Ok, here is my problem...I am trying to read a string from a
file, poke it i the keyboard buffer, and then dump the contents of
the buffer, so as to simulate that the user actually typed the
string...This way the user doesnt have to type it all out..My
program works fine, except if the string is more than characters, and
if I try to clear the buffer after 16 characters, all I get the last
few characters in the string..Can anyone please help?  I would real
like to finish this dang project! :>  Thank you.}

{This should work, tested it out.  If it returns a false, you have to
stop sending characters, until those that are in the buffer are used,
doesn't matter what scancode is if you don't use, ditto for asciicode }
*)

Function SimulateKey( AsciiCode, ScanCode : Byte ) : Boolean; Assembler
Asm
 Mov  AH, 05H
 Mov  CH, ScanCode
 Mov  CL, AsciiCode
 Int  16H
 XOR  AX, 1       { bios returns 1 = error, 0 = false, pascal opposite }
End; { Returns false if buffer is full }
