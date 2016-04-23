unit Blotter3;

interface

uses
	SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
	Forms, Dialogs, ExtCtrls;

type
	TmeiSmoothBlotter = class(TPanel)

	private
		{ Private declarations }

	protected
		{ Protected declarations }
		procedure Paint; override;

	public
		{ Public declarations }
		constructor Create(AOwner: TComponent); override;

	published
		{ Published declarations }
{		property BorderWidth default 8;
		property Color default clGreen;}

 end;

procedure Register;

implementation

constructor TmeiSmoothBlotter.Create(AOwner: TComponent);
	Begin
	Inherited Create(Aowner);
	if (csDesigning in ComponentState) then
	begin
		BorderWidth := 8;
		Color := clGreen;
		Align := alClient;
	end;
	End;

procedure TmeiSmoothBlotter.Paint;
var
	bmpBlotter : TBitMap;

Begin

bmpBlotter := TBitMap.Create;

try

{size the bitmap}
	With Canvas do
	begin
		bmpBlotter.Height := Height;
		bmpBlotter.Width := Width;
	end;

{draw on the bitmap}
	With bmpBlotter.Canvas Do
		Begin

		Brush.Color := Color; {BlotterColor;}
		Rectangle(0,0,Width,Height);

	{**************************************************}
		{draw vertical lines on left side of form}
		Pen.Color := clBlack;
		Moveto(0,0);                {column,row}
		Lineto(0,Height);

		Pen.Color := clSilver;
		Moveto(0+1,0);                {column,row}
		Lineto(0+1,Height);

		Pen.Color := clBlack;
		Moveto(0+4,0);                {column,row}
		Lineto(0+4,Height);

		{draw vertical line on right side of form}
		Pen.Color := clSilver;
		Moveto(Width-4,0);
		Lineto(Width-4,Height);

		Pen.Color := clBlack;
		Moveto(Width-1,0);
		Lineto(Width-1,Height);

		{draw horizontal line on top side of form}
		Pen.Color := clBlack;
		Moveto(0,0);
		Lineto(Width,0);

		Pen.Color := clSilver;
		Moveto(0,0+1);
		Lineto(Width,0+1);

		Pen.Color := clBlack;
		Moveto(0,0+4);
		Lineto(Width,0+4);

		{draw horizontal line on bottom side of form}
		Pen.Color := clSilver;
		Moveto(0,Height-4);
		Lineto(Width,Height-4);

		Pen.Color := clBlack;
		Moveto(0,Height-1);
		Lineto(Width,Height-1);

		{***************************************************}
		{draw blotter outer corners}
		Pen.Color := clYellow;
		{Upper Left vertical and horizontal}
		MoveTo(0+1,0+1);
		LineTo(0+1,15);
		Moveto(0+1,0+1);
		LineTo(15,0+1);
		{Lower Left vertical only }
		MoveTo(0+1,Height-1);
		LineTo(0+1,Height-16);
		{Lower Right}
		Pen.Color := clBlack;
		MoveTo(Width-2,Height-1);
		LineTo(Width-15,Height-1);
		MoveTo(Width-1,Height-1);
		LineTo(Width-1,Height-15);
		Pen.Color := clYellow;
		MoveTo(Width-15,Height-1);
		LineTo(Width-16,Height-1);
		MoveTo(Width-1,Height-15);
		LineTo(Width-1,Height-16);
		{Upper Right, horizontal only}
		MoveTo(Width-15, 1);
		LineTo(Width-1, 1);

	{************************************************}
		{draw blotter inner corners}
		Pen.Color := clBlack;
		Brush.Color := clBlack;
		{Upper Left}
		MoveTo(0+5,0+5);
		LineTo(0+5,6+6);
		Moveto(0+5,0+5);
		LineTo(6+6,0+5);

		{Lower Left}
		MoveTo(0+5,Height-5);
		LineTo(0+5,(Height-5)-7);    {draw vert}
		Moveto(0+5,Height-5);
		LineTo(12,Height-5);    {draw horiz}

		Pen.Color := clYellow;
		MoveTo(0+6,Height-5);
		LineTo(11,Height-5);
		Pen.Color := clBlack;

			{lower right}
		Pen.Color := clYellow;
		MoveTo(Width-5,Height-5);
		LineTo(Width-5,Height-12);
		MoveTo(Width-5,Height-5);
		LineTo(Width-12,Height-5);

		{Upper Right}
		Pen.Color := clBlack;
		MoveTo(Width-11,5);
		LineTo(Width-5,5);
		Pen.Color := clYellow;
		MoveTo(Width-5,5);
		LineTo(Width-5,13);

	{************************************************}
		{draw the staircase pixels}
		Pen.Color := clBlack;

		{upper left}
				{lower pixels}
		MoveTo(0+1,15);
		LineTo(0+4,12);

		Moveto(2,Height-13);
		LineTo(3,Height-12);
		Moveto(4,Height-11);
		LineTo(4,Height-11);

				{upper pixels}
		MoveTo(15,0+1);
		LineTo(12,0+4);


		{lower left}
				{upper pixels}
		Pen.Color := clYellow;
		Moveto(2,Height-14);
		LineTo(5,Height-11);

		Pen.Color := clBlack;
		MoveTo(11,Height-5);
		LineTo(15,Height-1);

		{lower right}
		Pen.Color := clYellow;
		MoveTo(Width-15,Height-1);
		LineTo(Width-10,Height-6);
		MoveTo(Width-1,Height-15);
		LineTo(Width-6,Height-10);

		{ Upper Right}
		Pen.Color := clBlack;
		MoveTo(Width-1,16);
		LineTo(Width-5,12);

		MoveTo(Width-14,2);
		LineTo(Width-12,4);

	{****************************************************}
		{fill in "brass" areas for corners}
		Brush.Color := clOlive;
		Pen.Color := clOlive;

		{upper left}
		{fill in large areas}
		Rectangle(2,2,5,12);
		Rectangle(2,2,12,5);

		{fill in upper pixels}
		Moveto(12,2);
		LineTo(14,2);
		Moveto(12,3);
		LineTo(13,3);
		{fill in lower pixels}
		MoveTo(2,12);
		LineTo(2,14);
		MoveTo(3,12);
		LineTo(3,13);

	{------------------------}
		{lower left}
		{fill in large areas}
		Rectangle(2,Height-1,12,Height-4);
		Rectangle(2,Height-2,5,Height-11);

		{fill in upper pixels}
		Moveto(2,Height-13);
		LineTo(3,Height-12);
		Moveto(2,Height-12);
		LineTo(4,Height-12);
		Moveto(4,Height-11);
		LineTo(4,Height-11);
		{fill in lower pixels}
		MoveTo(12,Height-3);
		LineTo(13,Height-2);
		MoveTo(14,Height-1);
		LineTo(14,Height-1);
		MoveTo(12,Height-2);
		LineTo(14,Height-2);

		{-----------------------}
			{lower right}

			{fill in large areas}
		Rectangle(Width-1,Height-1,Width-11,
																						Height-4);
		Rectangle(Width-1,Height-1,Width-4,Height-11);

		{fill in upper pixels}
		MoveTo(Width-3,Height-12);
		LineTo(Width-1,Height-12);
		MoveTo(Width-2,Height-13);
		LineTo(Width-1,Height-13);

		{fill in lower pixels}
		MoveTo(Width-12,Height-3);
		LineTo(Width-12,Height-1);
		MoveTo(Width-13,Height-2);
		LineTo(Width-13,Height-1);

		{-----------------------}
			{upper right}

			{fill in large areas}
		Rectangle(Width-11,2,Width-1,5);
		Rectangle(Width-1,13,Width-4,2);

			{fill in upper pixels}
			MoveTo(Width-12,2);
			LineTo(Width-12,4);
			MoveTo(Width-13,2);
			LineTo(Width-13,1);

			{fill in lower pixels}
			MoveTo(Width-2,13);
			LineTo(Width-4,13);
			MoveTo(Width-2,14);
			LineTo(Width-1,14);

	{***************************************************}
		{cleanup corner pixels}
		Pen.Color := clBlack;
		Moveto(0,0);
		LineTo(0,10);

		{Lower Left}
		MoveTo(0,Height-1);
		LineTo(13,Height-1);
		MoveTo(0,Height-1);
		LineTo(0,Height-14);

			{Upper Right}
		Moveto(Width-1,0);
		LineTo(Width-14,0);
		Moveto(Width-1,0);
		LineTo(Width-1,13);

		{Lower Right}
		MoveTo(Width-1,Height-1);
		LineTo(Width-14,Height-1);
		MoveTo(Width-1,Height-1);
		LineTo(Width-1,Height-14);

		end;

		{copy the bitmap image to the panel's canvas}

		Canvas.Draw(0,0,bmpBlotter);

finally
	bmpBlotter.Free;
end;

end;

procedure Register;
begin
	RegisterComponents('PRIME', [TmeiSmoothBlotter]);
end;

end.
