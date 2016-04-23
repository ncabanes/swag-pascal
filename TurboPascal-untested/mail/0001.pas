{
After lots of controversy, and a lot of reteaching myself the meanings of
a few Words, I've redone my *.MSG reader....
}

Const MSGPRIVATE  = $0001;
Const MSGConst    = $0002;
Const MSGREAD     = $0004;
Const MSGSENT     = $0008;
Const MSGFile     = $0010;
Const MSGFWD      = $0020;
Const MSGorPHAN   = $0040;
Const MSGKILL     = $0080;
Const MSGLOCAL    = $0100;
Const MSGHOLD     = $0200;
Const MSGCRAP     = $0400;
Const MSGFRQ      = $0800;
Const MSGRRQ      = $1000;
Const MSGCPT      = $2000;
Const MSGARQ      = $4000;
Const MSGURQ      = $8000;

Type
     Fido_FromType    = Array [1..35] of Char;
     Fido_toType      = Array [1..35] of Char;
     Fido_SubType     = Array [1..71] of Char;
     Fido_DateType    = Array [1..19] of Char;

     FidoMsgType = Record
      From         : Fido_FromType; (* 0   *)
      toWhom       : Fido_toType;   (* 35  *)
      Subject      : Fido_SubType;  (* 71  *)
      AZDate       : Fido_DateType; (* 142 *)
      TimesRead    : Word;          (* 162 *)
      Dest_Node    : Word;          (* 164 *)
      orig_Node    : Word;          (* 166 *)
      Cost         : Word;          (* 168 *)
      orig_Net     : Word;          (* 170 *)
      Dest_Net     : Word;          (* 172 *)
      Date_Written : LongInt;       (* 176 *)
      Date_Arrived : LongInt;       (* 180 *)
      Reply        : Word;          (* 184 *)
      Attr         : Word;          (* 186 *)
      Up           : Word;          (* 188 *)
     end;

   MsgTxtPtr  = ^MsgTxtType;
   MsgTxtType = Array [1..65535] of Char;

Var
  MessageFile : File;
  Msg         : FidoMsgType;
  MsgTxt      : MsgTxtPtr;

Procedure ReadMessage(Fname : PathStr);
Var
  Left : Word;
begin
  Assign(MessageFile,FName);
  Reset(MessageFile,1);
  BlockRead(MessageFile,Msg,190);
  Left:=FileSize(MessageFile) - 190;
  New(MsgTxt);
  BlockRead(MessageFile,MsgTxt^,Left);
end;
{
This will correctly read in a *.MSG File in two parts..THe Header(stored in
Msg), and the Text which is a 64k buffer(stored in Pointer MsgTxt)...
}
