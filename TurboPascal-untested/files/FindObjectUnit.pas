(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0081.PAS
  Description: Find Object Unit
  Author: OZZ NIXON
  Date: 11-22-95  13:33
*)


Unit WGFFind; {File Find Object Unit}
{$I WGDEFINE.INC}  { see below for WGDEFINE !! }

Interface

Uses
{$IFDEF WINDOWS}
   WinDos;
{$ELSE}
   Dos;
{$ENDIF}

Const
{searchtypes}
   stReadOnly=$01;
   stHidden=$02;
   stSysFile=$04;
   stVolumeID=$08;
   stDirectory=$10;
   stArchive=$20;
   stAnyFile=$3F;

Type
{$IFDEF WINDOWS}
   PathStr=String[128];
   DirStr=String[128];
   NameStr=String[13];
   ExtStr=String[4];
{$ENDIF}

   FindRec=Record
{$IFDEF WINDOWS}
      SR:TSearchRec;
      TStr:Array[0..180] of Char;
{$ELSE}
      SR:SearchRec;
{$ENDIF}
      Dir:DirStr;
      Name:NameStr;
      Ext:ExtStr;
      DError:Word;
      SearchType:Word;
   End;

   FindObj = Object
      FI: ^FindRec;
      Constructor Init(ST:Word);    {SearchType: Sysfile, AnyFile, Archive}
      Destructor Done;
      Procedure FFirst(FN:String);
      Procedure FNext;
      Function  Found:Boolean;
      Function  GetName:String;
      Function  GetFullPath:String;
      Function  GetDate:LongInt;
      Function  GetSize:LongInt;
      Function  GetAttr:Word;
   End;

Implementation

{$IFDEF WINDOWS}
Function FExpand(Str:String):String;
Var
   IStr:Array[0..128] of Char;
   OStr:Array[0..128] of Char;

Begin
   StrPCopy(IStr,Str);
   FileExpand(OStr,IStr);
   FExpand:=StrPas(OStr);
End;
{$ENDIF}

{$IFDEF WINDOWS}
Procedure FSplit(Path:String;Var Dir:String;Var Name:String;Var Ext:String);
Var
   FPath:Array[0..129] of Char;
   TD:Array[0..129] of Char;
   TN:Array[0..14] of Char;
   TE:Array[0..5] of Char;

Begin
   StrPCopy(FPath,Path);
   FileSplit(FPath,TD,TN,TE);
   Dir:=StrPas(TD);
   Name:=StrPas(TN);
   Ext:=StrPas(TE);
End;
{$ENDIF}

Constructor FindObj.Init;
Begin
   New(FI);
   If FI=Nil then Fail;
   FI^.DError:=1;
   FI^.SearchType:=StArchive+StReadOnly; {default}
End;

Destructor FindObj.Done;
Begin
   If FI<>Nil then Dispose(FI);
End;

Procedure FindObj.FFirst(FN:String);
Begin
   If FI<>Nil then Begin
      FN:=FExpand(FN);
      FSplit(FN,FI^.Dir,FI^.Name,FI^.Ext);
{$IFDEF WINDOWS}
      StrPCopy(FI^.TStr, FN);
      FindFirst(FI^.TStr,FI^.SearchType,FI^.SR);
{$ELSE}
      FindFirst(FN,FI^.SearchType,FI^.SR);
{$ENDIF}
      FI^.DError:=DosError;
   End
   Else FI^.DError:=1;
End;

Function  FindObj.GetName:String;
Begin
   GetName:='';
   If FI<>Nil then
      If Found Then
{$IFDEF WINDOWS}
         GetName:=StrPas(FI^.SR.Name);
{$ELSE}
       GetName:=FI^.SR.Name;
{$ENDIF}
End;

Function FindObj.GetFullPath:String;
Begin
   If FI<>Nil then GetFullPath:=FI^.Dir+GetName
   Else GetFullPath:='';
End;

Function FindObj.GetSize:LongInt;
Begin
   GetSize:=0;
   If FI<>Nil then
      If Found Then GetSize:=FI^.SR.Size;
End;

Function  FindObj.GetDate: LongInt;
Begin
   GetDate:=0;
   If FI<>Nil then
      If Found Then GetDate:=FI^.SR.Time;
End;

Function  FindObj.GetAttr:Word;
Begin
   GetAttr:=0;
   If FI<>Nil then
      If Found Then GetAttr:=FI^.SR.Attr;
End;

Procedure FindObj.FNext;
Begin
   If FI<>Nil then Begin
      FindNext(FI^.SR);
      FI^.DError:=DosError;
   End
   Else FI^.DError:=1;
End;

Function FindObj.Found:Boolean;
Begin
   Found:=(FI^.DError=0);
End;

End.

[WGDEFINE.INC]
{$I-}
{$V-}
{$S+}
{$F+}
{$D-}
{$L-}
{$R-}
{$X+}

{$IFNDEF WINDOWS}
{$O+}                       {Make units overlayable}
{$IFNDEF OS2}
{$X-}                       {Turn off extended syntax}
{$ENDIF}
{$ENDIF}

{$IFDEF WINDOWS}
  {$DEFINE BASMINT}         {Use BASM for interrupts under windows}
{$ENDIF}

{.$.DEFINE OPRO}
{.$.DEFINE DEBUG}
{BBS Definitions below (some that I have tested the new WGMSG*.PAS w/!)}
{$IFDEF MAXIMUS}
   {$DEFINE SQUISH}
{$ENDIF}
{$IFDEF RA2}
   {$DEFINE JAM}
   {$DEFINE HUDSON}
{$ENDIF}
{$IFDEF XENOPHOBE}
   {$DEFINE FIDO}
   {$DEFINE SQUISH}
   {$DEFINE JAM}
{$ENDIF}

