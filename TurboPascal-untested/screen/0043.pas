{
From: STEFAN XENOS
Subj: ScreenBuffer Object

Notes:
  - 0,0 is recognised as the top-left corner of the screen.
  - They seem to work perfectly when only popping one thing up at once.
}

Uses Crt;

Type
 TScreenBuf = Object
  Constructor Init (NewX,NewY,NewHeight,NewWidth:Byte);
  Destructor Done;
  Procedure KillBuffer; Virtual;
  Procedure Clip;
  Procedure Paste;
  Private
   Buffer :Pointer;
   Size :Byte;
   x,
   y,
   Height,
   Width :Byte;
 end;

Var
 MaxX,
 MaxY :Byte;
 ScreenSeg :Word;

Procedure GoXY (x,y:Byte);
Begin
 gotoXY (x+1,y+1);
end;

Procedure FillWith (aChar:Char);
Var
 offset:Word;
Begin
 ClrScr;
 For offset := 0 to maxx*maxy
  do move (aChar,Ptr (ScreenSeg,offset*2)^,1);
End;

{TScreenBuf}
Constructor TScreenBuf.Init (NewX,NewY,NewHeight,NewWidth:Byte);
Begin
 x := newx;
 y := newy;
 height := newheight;
 width := newwidth;
 Buffer := nil;
 KillBuffer;
End;

Destructor TScreenBuf.Done;
Begin
 KillBuffer;
End;

Procedure TScreenBuf.KillBuffer;
Begin
 If Buffer <> nil
  then FreeMem (Buffer,Size);
 Size := 0;
 Buffer := nil;
End;

Procedure TScreenBuf.Clip;
Var
 ScanY :Byte;
Begin
 KillBuffer;
 Size := Height*Width*2;
 GetMem (Buffer,Size);
 For ScanY := 0 to Height
  do begin
   Move (Ptr (ScreenSeg,(Y*MaxX+ScanY*MaxX+X)*2)^,
    Ptr (Seg (Buffer^),Ofs(Buffer^)+(ScanY*Width)*2)^,Width*2);
  end;
End;

Procedure TScreenBuf.Paste;
Var
 ScanY :Byte;
Begin
 For ScanY := 0 to Height
  do begin
   Move (Ptr (Seg (Buffer^),Ofs(Buffer^)+(ScanY*Width)*2)^,
    Ptr (ScreenSeg,(Y*MaxX+ScanY*MaxX+X)*2)^,Width*2);
  end;
End;

Var
 Clip :TScreenBuf;

Begin
 if Lastmode = Mono
  then screenSeg := $B000          {Mono}
 else screenSeg := $B800;          {Colour}
 if Lastmode
  and font8x8 <> 0
  then MaxY := 50                  {25X80}
 else MaxY := 25;                  {50X80}
 MaxX := 80;

 textcolor (darkgray);
 textbackground (lightgray);
 FillWith (#178);
 textcolor (yellow);
 textbackground (blue);
 Clip.Init (10,10,1,21);
 Clip.Clip;
 goXY (10,10);
 Write ('Hit ENTER to continue');
 While Readkey <> #13 do;
 Clip.Paste;
 Clip.Done;
End.
