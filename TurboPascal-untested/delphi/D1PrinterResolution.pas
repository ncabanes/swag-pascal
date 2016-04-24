(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0307.PAS
  Description: Re: D1: Printer Resolution
  Author: STEPHEN POSEY
  Date: 08-30-97  10:08
*)

>
> Does anyone have experience determining the resolution of the default
> printer? At run-time, I don't know what the size of the paper is,
> either. Right now, I have the user enter the resolution manually. This
> has obvous problems. I've tried the DeviceCapabilities() function, but
> delphi can't seem to find it. (I have included both WinTypes and
> WinProcs) the online help shows the syntax for the command, but
> curiously leaves out the function name thus:

You want GetDeviceCaps() instead, try this:

var
  VertPix, HorzPix : integer ;
begin
  VertPix := GetDeviceCaps( Printer.Canvas.Handle,LOGPIXELSX ) ;
  HorzPix := GetDeviceCaps( Printer.Canvas.Handle,LOGPIXELSY ) ;


