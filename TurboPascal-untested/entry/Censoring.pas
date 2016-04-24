(*
  Category: SWAG Title: INPUT AND FIELD ENTRY ROUTINES
  Original name: 0027.PAS
  Description: Censoring
  Author: ERWIN ELDERING
  Date: 11-22-95  13:29
*)

{
 BG> I have created a shield program that password-protects a specific
 BG> program. However, I cannot figure out how to make the password, when
 BG> being typed by the person entering the code, to make a * or other
 BG> character instead of the letter, so someone can't see what he's typing.
 BG> Any help here?

Well, here is your help:

-----------------------------------SOURCE-------------------------------------
}
Program Test;

Procedure EnterPW(Var S:String;Idx,PosX,PosY:Byte);
Var Ch,Ch2:Char;
Begin
S:='';
    Repeat
     GotoXy(PosX+Idx,PosY);
     Ch:=Upcase(ReadKey);
      Case (Ord(Ch)) Of
       0      : Begin 
                 Ch2:=Readkey;
                 If Ord(Ch2)=75 Then 
                 Begin 
                  Delete(S,Length(S),1); Dec(Idx);
                 End; 
                End;        
       65..90 : Begin 
                 Inc(Idx); 
                 S:=S+Ch; 
                End;
       97..122: Begin 
                 Inc(Idx); 
                 S:=S+Ch;
                End;
       08     : Begin 
                 Delete(S,Length(S),1); 
                 Dec(Idx); 
                End;        
       1..7   : Write(#7);
       9..12  : Write(#7);
       14..64 : Write(#7);
       91..96 : Write(#7);
       122..255:Write(#7);
      End;

      GotoXy(11+Idx,PosY);
      Write('*');
      If (Ord(Ch)=8) OR (Ord(Ch2)=75) Then 
      Begin 
       Ch2:=#0;
       GotoXy(12+Idx,PosY); 
       Write('░');
      End;
     Until Ord(Ch)=13;
    WriteLn;
End;


Var
Pw, PwV:String[8];
I,X,Y:Byte;

Begin
    Writeln;
    Write('Password : ');
    X:=WhereX;
    Y:=WhereY;
    WriteLn('░░░░░░░░');
    I:=0;
    EnterPw(Pw,I,X,Y);
    Write('Password : ');
    X:=WhereX;
    Y:=WhereY;
    WriteLn('░░░░░░░░ (for verifying purposes)');
    I:=0;
    EnterPw(PwV,I,X,Y);
    If UpStr(Pw)<>Upstr(PwV) Then WriteLn('Verifying password
failed...Aborting');End.

