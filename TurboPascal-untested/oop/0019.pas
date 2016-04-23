{
here's some code to insert your one personal desktop in TurboVision.
}
{$L SBLOGO}
Procedure Logo; external;
{
The only use of this Procedure is to link in the ansi drawing. It's a TP
Compatible Object File (you can make them With TheDraw). But every video
dump will do. This drawing should have the dimension 22 * 80.
}
Type
  PAnsiBackGround = ^TAnsiBackGround;
  TAnsiBackGround = Object (TBackGround)
    BckGrnd : Pointer;
    { This is the Pointer to your video dump }

    Constructor Init (Var Bounds : TRect; APattern : Char);
    Procedure Draw; Virtual;
    end;

Constructor TAnsiBackGround.Init;
begin
  TBackGround.Init (Bounds, APattern);
  BckGrnd := @Logo;

end;

Procedure TAnsiBackGround.Draw;
begin
  TView.Draw;
  WriteBuf (0,0, 80, 23, BckGrnd^);
  { The TV buffer Type is nothing more then a dump of the video memory }

end;

Type
  PAnsiDesktop = ^TAnsiDesktop;
  TAnsiDesktop = Object (TDesktop)
    Procedure InitBackGround; Virtual;
    end;

Procedure TAnsiDesktop.InitBackGround;
Var
  R: TRect;
  AB : PAnsiBackGround;
begin
  GetExtent(R);
  New (AB, Init(R, #176));
  BackGround := AB;

end;

{ Your applications InitDesktop method should look like this : }

Procedure TGenericApp.InitDesktop ;
Var
  AB : PAnsiDesktop;
  R : TRect;
begin
  GetExtent(R);
  Inc(R.A.Y);
  Dec(R.B.Y);
  New(AB, Init(R));
  Desktop := AB;

end;
{
The only problem With this approach is that it doesn't work in 43 line mode
since your background covers only 22 lines. if anyone has some nice code
to move this ansi-picture in an buffer which fills up 43 lines mode I Really
appreciate it !!
}