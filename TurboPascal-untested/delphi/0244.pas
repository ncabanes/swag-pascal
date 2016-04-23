
{ Updated DELPHI.SWG on May 30, 1997 }


> Nowadays everyone uses QuickReport.
> But is there among You someone who did printouts without QuickReport?
> I'd like to do it. But I don't know how to get the default printers
> resolution.
> The Printer.PageHeight and PageWidth tells me the size size of a page in
> pixels, but it could be A4, or Fanfold, or even A3 with a poor resolution.
> I'm looking for something like Printer.PixelsPerInch.
> Can somebody help me with this?
> Thanks in advance.
>
> Laszlo Kovacs
> Budapest, Hungary
>
> mailto:kovacs_l@mail.elender.hu
> mailto:kovacsl@usa.net

When I started using Delphi 1, I had a big struggle with ReportSmith and
gave it up. I did all my printing with an object called TPrinto. I gave
the object some nice methods to ease my printing, The following
procedure uses PixelsPerInch. I like to use centimeters so I translated
the Inches to cm's.

procedure TPrinto.StartDoc;
begin
   pageNo := 0;
   Printer.Canvas.Font.Name := 'MS SansSerif';
   Printer.Canvas.Font.Size := 10;
   Printer.Canvas.Pen.width := 4;
   Printer.Canvas.TextOut(0, 0, '');
   TextHeight := Abs(Printer.Canvas.Font.Height);
   LinesPerPage := Printer.PageHeight div (TextHeight + 4);
   cm := Round(Printer.Canvas.Font.PixelsPerInch / 2.54);
   LeftMargin := Round(1.5 * cm);
   CurrentLine := 0;
end;

