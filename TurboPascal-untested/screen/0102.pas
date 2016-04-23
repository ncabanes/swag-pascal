{----------------------------------------------------------------------------}
{ NAME		  : SCREEN.PAS 																  }
{ DESCRIPTION : Dynamic Windowing Unit 												  }
{ AUTHOR 	  : Kim Forwood  <kim.forwood@access.cn.camriv.bc.ca>            }
{ DATE		  : May 30, 1996  															  }
{----------------------------------------------------------------------------}
UNIT Screen;
{$A-,B-,D+,E-,I-,L+,N-,O-,P-,Q-,R-,S-,V-,X-}
INTERFACE
type
	Row = array[1..160] of byte;
	LineArray = array[1..25] of ^Row;
	WinRec = record
		PWin: ^LineArray;
		X1, X2, Y1, Y2: byte;
		Xcoord, Ycoord: byte;
		Wdth,Hght: byte;
		Loc: integer;
      Attr: byte;
	end;
type
   TScrArray = array[0..3999] of byte;
   ScrRec = record
      ScreenArray: TScrArray;
      Xcoord: byte;
      Ycoord: byte;
      TxAttr: byte;
   end;
const
	WinNum: byte = 0;                   { specifies to the current window }
var
	W: array[1..10] of WinRec;          { increase this for more windows  }

   { returns the address of video memory }
   FUNCTION  VidSeg: word;
   { direct video text and color handling routines }
	FUNCTION  ReadXY(X,Y: byte): char;
	PROCEDURE WriteXY(X,Y: byte; Ch: char);
	PROCEDURE ColorXY(X,Y,Attr: byte);
	PROCEDURE ColorAt(X,Y,Len,Attr: byte);
	PROCEDURE WriteAt(X,Y: byte; S: string);
   PROCEDURE ColorWrite(X,Y,Attr: byte; S: string);
   PROCEDURE ColorBlock(x1,y1,x2,y2,Attr: byte);
	FUNCTION  ReadScreen(X,Y,Len: byte): string;
   { save and restore text video to disk file }
	PROCEDURE ScreenSave(FName: string);
	PROCEDURE ScreenRestore(FName: string);
   { close the current pop-up window }
	PROCEDURE CloseWindow;
   { various pop-up window routines }
	PROCEDURE PopWindow(x1,y1,x2,y2,Attr,bAttr,Frame: byte);
	PROCEDURE TitleWindow(x1,y1,x2,y2,Attr,bAttr,tAttr,Frame: byte; Title: string);
	PROCEDURE PlainWindow(x1,y1,x2,y2,Attr: byte);
	PROCEDURE ShadowWindow(x1,y1,x2,y2,Attr,bAttr,Frame: byte);
	PROCEDURE ShadowTitleWindow(x1,y1,x2,y2,Attr,bAttr,tAttr,Frame: byte; Title: string);
	PROCEDURE DialogWindow(Attr,Frame: byte; S: string);
	PROCEDURE MsgWindow(Attr,Frame: byte; S: string);
   PROCEDURE TimedMsgWindow(Attr,Frame: byte; S: string; Wait: word);
	PROCEDURE PromptWindow(var Ch: char; Attr,Frame: byte; S: string);

IMPLEMENTATION
uses Crt;
const
	NilFrame: string[6] = '      ';      { frame 0 }
	SglFrame: string[6] = '─│┌┐└┘';      { frame 1 }
	DblFrame: string[6] = '═║╔╗╚╝';      { frame 2 }
var
	WP: array[1..10] of pointer;
	ArraySize: word;
   Location: word;
	VS : word;

{============================================================================}
 FUNCTION VidSeg: word;
{----------------------------------------------------------------------------}
BEGIN
   if Mem[$0000:$0449] = 7 then VidSeg := $B000
   else VidSeg := $B800;
END; { VidSeg }
{============================================================================}
 FUNCTION ReadXY(X,Y: byte): char;
{----------------------------------------------------------------------------}
begin
	ReadXY := Chr(Mem[VS:160*(Y-1)+2*(X-1)]);
end; { ReadXY }
{============================================================================}
 PROCEDURE WriteXY(X,Y: byte; Ch: char);
{----------------------------------------------------------------------------}
begin
	Mem[VS:160*(Y-1)+2*(X-1)] := Ord(Ch);
end; { WriteXY }
{============================================================================}
 PROCEDURE ColorXY(X,Y,Attr: byte);
{----------------------------------------------------------------------------}
begin
	Mem[VS:160*(Y-1)+2*(X-1)+1] := Attr;
end; { ColorXY }
{============================================================================}
 PROCEDURE ColorAt(X,Y,Len,Attr: byte);
{----------------------------------------------------------------------------}
var
	I: byte;
begin
	for I := 1 to Len do
		Mem[VS:160*(Y-1)+((X+I-1)*2-2)+1] := Attr;
end; { ColorAt }
{============================================================================}
 PROCEDURE WriteAt(X,Y: byte; S: string);
{----------------------------------------------------------------------------}
var
	I: byte;
begin
	for I := 1 to Length(S) do
		Mem[VS:160*(Y-1)+((X+I-1)*2-2)] := Ord(S[I]);
end; { WriteAt }
{============================================================================}
 PROCEDURE ColorWrite(X,Y,Attr: byte; S: string);
{----------------------------------------------------------------------------}
var
   I: byte;
begin
	for I := 1 to Length(S) do begin
		Mem[VS:160*(Y-1)+((X+I-1)*2-2)] := Ord(S[I]);
		Mem[VS:160*(Y-1)+((X+I-1)*2-2)+1] := Attr;
   end;
end; { ColorWrite }
{============================================================================}
 PROCEDURE ColorBlock(x1,y1,x2,y2,Attr: byte);
{----------------------------------------------------------------------------}
var
   Wdth,Hght,I: byte;
begin
   Wdth := X2-X1+1;
   Hght := Y2-Y1+1;
  	for I := 1 to Hght do
      ColorAt(x1,y1-1+I,Wdth,Attr);
end; { ColorBlock }
{============================================================================}
 FUNCTION ReadScreen(X,Y,Len: byte): string;
{----------------------------------------------------------------------------}
var
	S: string[80];
	C: char;
	I: byte;
begin
	S := '';
	for I := 0 to Len-1 do begin
		C := Chr(Mem[VS:160*(Y-1)+2*((X+I)-1)]);
		S := S + C;
	end;
	ReadScreen := S;
end; { ReadScreen }
{============================================================================}
 PROCEDURE ScreenSave(FName: string);
{----------------------------------------------------------------------------}
var
   F: file of ScrRec;
   W: ^ScrRec;
   P: pointer;
begin
	if MaxAvail < 4096 then Exit;
   GetMem(W,SizeOf(ScrRec));
  	W^.Xcoord := WhereX;
	W^.Ycoord := WhereY;
   W^.TxAttr := TextAttr;
	Move(Mem[VS:0000],W^.ScreenArray,4000);
   Assign(F,FName);
   ReWrite(F);
   Write(F,W^);
   Close(F);
   FreeMem(W,SizeOf(ScrRec));
end; { ScreenSave }
{============================================================================}
 PROCEDURE ScreenRestore(FName: string);
{----------------------------------------------------------------------------}
var
   F: file of ScrRec;
   W: ^ScrRec;
   P: pointer;
begin
	if MaxAvail < 4096 then Exit;
   GetMem(W,SizeOf(ScrRec));
   Assign(F,FName);
   {$I-}
   ReSet(F);
   {$I+}
   if IoResult <> 0 then Exit;
   Read(F,W^);
   Close(F);
   Erase(F);
	Move(W^.ScreenArray,Mem[VidSeg:0000],4000);
	Window(1,1,80,25);
	GotoXY(W^.Xcoord,W^.Ycoord);
   TextAttr := W^.TxAttr;
   FreeMem(W,SizeOf(ScrRec));
end; { ScreenRestore }
{============================================================================}
 PROCEDURE GetWindow(X1,Y1,X2,Y2: byte);
{----------------------------------------------------------------------------}
var
   I: byte;
begin
	if (x2 < 79) and (y2 < 25) then begin
		Inc(x2,2);
		Inc(y2);
	end;
	W[WinNum].Loc := (160*(Y1-1)+2*X1)-2;
	W[WinNum].Wdth := (X2-X1+1)*2;
	W[WinNum].Hght := (Y2-Y1+1);
	ArraySize := W[WinNum].Wdth*W[WinNum].Hght;
	Location := W[WinNum].Loc;
	with W[WinNum] do
		for I := 1 to Hght do begin
			GetMem(PWin^[I],Wdth);
			Move(Mem[VS:Location],PWin^[I]^,Wdth);
			Inc(Location,160);
		end;
end; { GetWindow }
{============================================================================}
 PROCEDURE CloseWindow;
{----------------------------------------------------------------------------}
var
	Wdth,Hght,I: byte;
begin
   Location := W[WinNum].Loc;
	Wdth := W[WinNum].Wdth;
	Hght := W[WinNum].Hght;
	ArraySize := Wdth*Hght;
	for I := 1 to Hght do begin
		Move(W[WinNum].PWin^[I]^,Mem[VS:Location],Wdth);
		Inc(Location,160);
	end;
	Window(W[WinNum].X1, W[WinNum].Y1, W[WinNum].X2, W[WinNum].Y2);
	GotoXY(W[WinNum].Xcoord,W[WinNum].Ycoord);
   TextAttr := W[WinNum].Attr;
   begin
      for I := 1 to Hght do FreeMem(W[WinNum].PWin^[I],Wdth);
	   Dispose(W[WinNum].PWin);
   end;
	Dec(WinNum);
end; { CloseWindow }
{============================================================================}
 PROCEDURE DrawBox(X1,Y1,X2,Y2,Attr,Frame: byte);
{----------------------------------------------------------------------------}
var
	X, Y: byte;
	Fm: string[6];
begin
	if Frame = 0 then Fm := NilFrame;
	if Frame = 1 then Fm := SglFrame;
	if Frame = 2 then Fm := DblFrame;
	for X := (X1+1) to (X2-1) do begin
		Mem[VS:160*(Y1-1)+2*(X-1)] := Ord(Fm[1]);
		Mem[VS:160*(Y1-1)+2*(X-1)+1] := Attr;
	end;
	for X := (X1+1) to (X2-1) do begin
		Mem[VS:160*(Y2-1)+2*(X-1)] := Ord(Fm[1]);
		Mem[VS:160*(Y2-1)+2*(X-1)+1] := Attr;
	end;
	for Y := (Y1+1) to (Y2-1) do begin
		Mem[VS:160*(Y-1)+2*(X1-1)] := Ord(Fm[2]);
		Mem[VS:160*(Y-1)+2*(X1-1)+1] := Attr;
		Mem[VS:160*(Y-1)+2*(X2-1)] := Ord(Fm[2]);
		Mem[VS:160*(Y-1)+2*(X2-1)+1] := Attr;
	end;
	Mem[VS:160*(Y1-1)+2*(X1-1)] := Ord(Fm[3]);
	Mem[VS:160*(Y1-1)+2*(X1-1)+1] := Attr;
	Mem[VS:160*(Y1-1)+2*(X2-1)] := Ord(Fm[4]);
	Mem[VS:160*(Y1-1)+2*(X2-1)+1] := Attr;
	Mem[VS:160*(Y2-1)+2*(X1-1)] := Ord(Fm[5]);
	Mem[VS:160*(Y2-1)+2*(X1-1)+1] := Attr;
	Mem[VS:160*(Y2-1)+2*(X2-1)] := Ord(Fm[6]);
	Mem[VS:160*(Y2-1)+2*(X2-1)+1] := Attr;
end; { DrawBox }
{============================================================================}
 PROCEDURE DrawTitleBox(x1,y1,x2,y2,Attr,tAttr,Frame: byte; Title: string);
{----------------------------------------------------------------------------}
var
	X, Y: byte;
begin
	DrawBox(x1,y1,x2,y2,Attr,Frame);
	Title := ' ' + Title + ' ';
	WriteAt(x1+1,y1,Title);
	ColorAt(x1+1,y1,Length(Title),tAttr);
end; { DrawTitleBox }
{============================================================================}
 PROCEDURE DrawShadow(X1,Y1,X2,Y2: byte);
{----------------------------------------------------------------------------}
var
	I,X,Y: byte;
	J: word;
begin
	if (x2 < 79) and (y2 < 25) then begin
		X := X2;
		Y := Y1;
		for I := 1 to Y2-Y1+1 do begin
			J := 160*(Y)+2*(X)+1;
			Mem[VS:J] := $08;
			Mem[VS:J+2] := $08;
			Inc(Y);
		end;
		J := 160*(Y2)+2*(X1+1)+1;
		for I := 1 to X2-X1+1 do begin
			Mem[VS:J] := $08;
			Inc(J,2);
		end;
	end;
end; { DrawShadow }
{============================================================================}
 PROCEDURE WindowInit(x1,y1,x2,y2: byte);
{----------------------------------------------------------------------------}
begin
	Inc(WinNum);
	New(W[WinNum].PWin);
	W[WinNum].Xcoord := WhereX;
	W[WinNum].Ycoord := WhereY;
   W[WinNum].Attr := TextAttr;
	W[WinNum].X1 := Lo(WindMin)+1;
	W[WinNum].X2 := Lo(WindMax)+1;
	W[WinNum].Y1 := Hi(WindMin)+1;
	W[WinNum].Y2 := Hi(WindMax)+1;
end; { WindowInit }
{============================================================================}
 PROCEDURE PopWindow(x1,y1,x2,y2,Attr,bAttr,Frame: byte);
{----------------------------------------------------------------------------}
begin
	if MaxAvail < 4096 then Exit;
	WindowInit(x1,y1,x2,y2);
	Window(1,1,80,25);
	GetWindow(x1,y1,x2,y2);
	DrawBox(x1,y1,x2,y2, bAttr, Frame);
	Window(x1+1,y1+1,x2-1,y2-1);
	TextAttr := Attr;
	ClrScr;
end; { PopWindow }
{============================================================================}
 PROCEDURE TitleWindow(x1,y1,x2,y2,Attr,bAttr,tAttr,Frame: byte; Title: string);
{----------------------------------------------------------------------------}
begin
	if MaxAvail < 4096 then Exit;
	WindowInit(x1,y1,x2,y2);
	Window(1,1,80,25);
	GetWindow(x1,y1,x2,y2);
	DrawTitleBox(X1,Y1,X2,Y2,bAttr,tAttr,Frame,Title);
	Window(X1+1,Y1+1,X2-1,Y2-1);
	TextAttr := Attr;
	ClrScr;
end; { TitleWindow }
{============================================================================}
 PROCEDURE PlainWindow(x1,y1,x2,y2,Attr: byte);
{----------------------------------------------------------------------------}
begin
	if MaxAvail < 4096 then Exit;
	WindowInit(x1,y1,x2,y2);
	GetWindow(x1,y1,x2,y2);
	Window(x1,y1,x2,y2);
	TextAttr := Attr;
	ClrScr;
end; { PlainWindow }
{============================================================================}
 PROCEDURE ShadowWindow(x1,y1,x2,y2,Attr,bAttr,Frame: byte);
{----------------------------------------------------------------------------}
begin
	if MaxAvail < 4096 then Exit;
	WindowInit(x1,y1,x2,y2);
	Window(1,1,80,25);
	GetWindow(x1,y1,x2,y2);
	DrawBox(X1,Y1,X2,Y2,bAttr,Frame);
	DrawShadow(X1,Y1,X2,Y2);
	Window(X1+1,Y1+1,X2-1,Y2-1);
	TextAttr := Attr;
	ClrScr;
end; { ShadowWindow }
{============================================================================}
 PROCEDURE ShadowTitleWindow(x1,y1,x2,y2,Attr,bAttr,tAttr,Frame: byte; Title: string);
{----------------------------------------------------------------------------}
begin
	if MaxAvail < 4096 then Exit;
	WindowInit(x1,y1,x2,y2);
	Window(1,1,80,25);
	GetWindow(x1,y1,x2,y2);
	DrawTitleBox(X1,Y1,X2,Y2,bAttr,tAttr,Frame,Title);
	DrawShadow(X1,Y1,X2,Y2);
	Window(X1+1,Y1+1,X2-1,Y2-1);
	TextAttr := Attr;
	ClrScr;
end; { ShadowTitleWindow }
{============================================================================}
 PROCEDURE DialogWindow(Attr,Frame: byte; S: string);
{----------------------------------------------------------------------------}
var
	x1, x2: integer;
	Ch: char;
begin
	x1 := 40 - (Length(S) div 2) - 2;
	x2 := 40 + (Length(S) div 2) + 2;
	{CursOff;}
	ShadowWindow(x1,10,x2,12,Attr,Attr,Frame);
	Write(' ', S);
	Ch := ReadKey;
	CloseWindow;
end; { DialogWindow }
{============================================================================}
 PROCEDURE MsgWindow(Attr,Frame: byte; S: string);
{----------------------------------------------------------------------------}
var
	x1, x2: integer;
begin
	x1 := 40 - (Length(S) div 2) - 2;
	x2 := 40 + (Length(S) div 2) + 2;
	{CursOff;}
	ShadowWindow(x1,12,x2,14,Attr,Attr,Frame);
	Write(' ', S);
end; { MsgWindow }
{============================================================================}
 PROCEDURE TimedMsgWindow(Attr,Frame: byte; S: string; Wait: word);
{----------------------------------------------------------------------------}
begin
   MsgWindow(Attr,Frame,S);
   Delay(Wait);
   CloseWindow;
end; { TimedMsgWindow }
{============================================================================}
 PROCEDURE PromptWindow(var Ch: char; Attr,Frame: byte; S: string);
{----------------------------------------------------------------------------}
var
	x1, x2: integer;
begin
	x1 := 40 - (Length(S) div 2) - 2;
	x2 := 40 + (Length(S) div 2) + 2;
	{CursOff;}
	ShadowWindow(x1,12,x2,14,Attr,Attr,Frame);
	Write(' ', S);
	Ch := UpCase(ReadKey);
	CloseWindow;
end; { PromptWindow }
BEGIN
   VS := VidSeg;
END.
