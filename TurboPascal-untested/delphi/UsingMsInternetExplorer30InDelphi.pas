(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0202.PAS
  Description: Using MS Internet Explorer 3.0 in Delphi
  Author: SWAG SUPPORT TEAM
  Date: 11-29-96  08:17
*)



Topic:  Access Violation when using MS Internet Explorer 3.0 
WebBrowser as an OCX in Delphi.

Problem:  When you create an OCX wrapper class in Delphi to host the
Internet Explorer 3.0 HTML viewer control (named TExplorer or 
TWebBrowser depending on the age of your IE installation) and use it
in a Delphi app that calls the Navigate method of that OCX control, 
you'll get an access violation as well as possibly ruin your whole 
Win95 OLE session.

Reason:  IE 3.0 calls the IOleClientSite.GetContainer method of 
Delphi's OCX wrapper implementation.  Delphi returns an error code 
E_NOTIMPL, but IE 3.0 only looks for error code E_NOINTERFACE.  IE 
3.0 ignores all other error codes and plows ahead with using the 
bogus interface pointer, thus the access violation occurs.

Solution:  In Delphi 2.0's OleCtrls.pas, modify method 
TOleClientSite.GetContainer to return E_NOINTERFACE instead of 
E_NOTIMPL as its function result.  Note that this doesn't entirely 
solve the IE 3.0 error checking problem, but it at least placates it.

Important Note: Delphi Developer and Delphi C/S customers can make
the change and recompile without affecting any other units.  Delphi 
Desktop customers don't have the VCL source code, so they will need 
an updated DCU from Borland in order to fix it.

Special Thanks:  Danny Thorpe

