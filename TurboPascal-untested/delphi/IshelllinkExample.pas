(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0230.PAS
  Description: Re: IShellLink Example
  Author: RADEK VOLTR
  Date: 03-04-97  13:18
*)


     This is last source code for my ShellLink component.

     //******************************************************* //*
     Shell Link Component for Delphi 2.0           * //*
                                      * //*   this is end version
                         * //*
            * //*   for new versions send e-mail,s-mail,fax           * //*
       with you name and e-mail adress to >              * //*
                                            * //*
     voltr.radek/4600/epr@epr1.ccmail.x400.cez.cz     * //*
                                         * //*    (c) 1996 Radek Voltr
                            * //*             Kozeluzska 1523
               * //*             Kadan 43201    CZECH Republic   Europe  *
     //*             fax. 42 398 2776                        * //*
     note: this version is free                     *
     //*******************************************************

     unit SheLink;

     interface

     uses
     Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
     Dialogs, Ole2;

     const
     SLR_NO_UI           = _0001;
     SLR_ANY_MATCH       = _0002;
     SLR_UPDATE          = _0004;

     SLGP_SHORTPATH      = _0001;
     SLGP_UNCPRIORITY    = _0002;

     CLSID_ShellLink:    TCLSID = (D1:_00021401; D2:_0; D3:_0;
     D4:(_C0,_0,_0,_0,_0,_0,_0,_46));
     IID_IShellLink:      TCLSID = (D1:_000214EE; D2:_0; D3:_0;
     D4:(_C0,_0,_0,_0,_0,_0,_0,_46));

     type
     PShellLink = ^IShellLink;
     IShellLink = class(IUnknown)
     public
     Function GetPath(pszFile:PChar;cchMaxPath:Integer;var
     pfd:TWin32FindData;fFlags:DWord):HResult; virtual; stdcall; abstract;
     Function GetIDList(ppidl:pointer) :HResult; virtual; stdcall;
     abstract; Function SetIDList(const pidl:pointer) :HResult; virtual;
     stdcall; abstract; Function
     GetDescription(pszName:PChar;cchMaxName:Integer) :HResult; virtual;
     stdcall; abstract;
     Function SetDescription(Const pszName:PChar) :HResult; virtual;
     stdcall;
     abstract;
     Function GetWorkingDirectory(pszDir:PChar;cchMaxPath:Integer)
     :HResult;
     virtual; stdcall; abstract;
     Function SetWorkingDirectory(const pszDir:PChar) :HResult; virtual;
     stdcall;
     abstract;
     Function GetArguments(pszDir:PChar;cchMaxPath:Integer) :HResult;
     virtual;
     stdcall; abstract;
     Function SetArguments(const pszArgs:PChar) :HResult; virtual; stdcall;
     abstract;
     Function GetHotkey(pwHotkey:PWord) :HResult; virtual; stdcall;
     abstract; Function SetHotkey(wHotkey:Word) :HResult; virtual; stdcall;
     abstract; Function GetShowCmd(piShowCmd:PInteger) :HResult; virtual;
     stdcall;
     abstract;
     Function SetShowCmd(iShowCmd:Integer) :HResult; virtual; stdcall;
     abstract; Function
     GetIconLocation(pszIconPath:PChar;cchIconPath:Integer;piIcon:PInteger)
     :HResult; virtual; stdcall; abstract;
     Function SetIconLocation(const pszIconPath:PChar;iIcon:Integer)
     :HResult;
     virtual; stdcall; abstract;
     Function SetRelativePath(const pszPathRel:PChar;dwReserved:Dword)
     :HResult;
     virtual; stdcall; abstract;
     Function Resolve(wnd:hWnd;fFlags:Dword) :HResult; virtual; stdcall;
     abstract;
     Function SetPath(Const pszFile:PChar) :HResult; virtual; stdcall;
     abstract;
     end;


     type
     TShellLink = class(TComponent)
     private
     { Private declarations }
     procedure fSetSelfPath(const S:String); protected
     { Protected declarations }
     fUpdate:Boolean;
     fPath,
     fTarget,
     fWorkingDir,
     fDescription,
     fArguments,
     fIconLocation:String;
     fIconNumber,
     fShowCmd,
     fHotKey:Word;
     public
     { Public declarations }
     //    constructor Create;
     procedure SetSelfPath(const S:String); procedure SetUpdate(const
     S:Boolean); procedure CreateNew(const Path,Target:String); procedure
     SaveToFile(const Path:String);
     published
     { Published declarations }
     property Path:String read fPath write fSetSelfPath; property
     Target:String read fTarget write fTarget;
     property WorkingDir:String read fWorkingDir write fWorkingDir;
     property Description:String read fDescription write fDescription;
     property Arguments:String read fArguments write fArguments;
     property IconLocation:String read fIconLocation write fIconLocation;
     property HotKey:word read fHotKey write fHotKey;
     property ShowCmd:word read fShowCmd write fShowCmd;
     property IconNumber:word read fIconNumber write fIconNumber; property
     Update:boolean read fUpdate write SetUpdate;
     end;

     procedure Register;

     implementation

     procedure Register;
     begin
     RegisterComponents('Win95', [TShellLink]); end;


     procedure TShellLink.SetSelfPath(const S:String); var X3:PChar;
     hresx:HResult;
     Psl:IShellLink;
     Ppf:IPersistFile;
     Saver:Array [0..Max_Path] of WideChar; X1:Array [0..255] Of Char;
     Data:TWin32FindData;I,Y:INteger;W:Word;
     begin
     hresx:=CoCreateInstance(CLSID_ShellLink,nil,CLSCTX_INPROC_SERVER,IID_I
     ShellLink, psl);
     If hresx<>0 then Exit;
     hresx:=psl.QueryInterface(IID_IPersistFile,ppf); If hresx<>0 then
     Exit;
     X3:=StrAlloc(255);
     StrPCopy(X3,S);
     MultiByteToWideChar(CP_ACP,0,X3,-1,Saver,Max_Path);
     hresx:=ppf.Load(Saver,STGM_READ);
     If hresx<>0 then
     begin
     MessageBox(0,'File not found (or not link)','!! Error !!',mb_IconHand
     or mb_ok); Exit;
     end;
     hresx:=psl.Resolve(0,SLR_ANY_MATCH); If hresx<>0 then Exit; hresx:=
     psl.GetWorkingDirectory(@X1,MAX_PATH ); If hresx<>0 then begin
     MessageBox(0,'Error in get WD','!! Error !!',mb_IconHand or mb_ok);
     Exit;
     end;
     fWorkingDir:=StrPas(@X1);

     hresx:= psl.GetPath( @X1,MAX_PATH,Data,SLGP_UNCPRIORITY); If hresx<>0
     then
     begin
     MessageBox(0,'Error in get GP','!! Error !!',mb_IconHand or mb_ok);
     Exit;
     end;
     fTarget:=StrPas(@X1);

     hresx:=psl.GetIconLocation(@X1,MAX_PATH,@I); If hresx<>0 then begin
     MessageBox(0,'Error in get IL','!! Error !!',mb_IconHand or mb_ok);
     Exit;
     end;
     fIconLocation:=StrPas(@X1);
     fIconNumber:=I;

     hresx:= psl.GetDescription(@X1,MAX_PATH ); If hresx<>0 then begin
     MessageBox(0,'Error in get DE','!! Error !!',mb_IconHand or mb_ok);
     Exit;
     end;
     fDescription:=StrPas(@X1);

     Y:=0;
     hresx:= psl.GetShowCmd(@Y);
     If hresx<>0 then
     begin
     MessageBox(0,'Error in get SC','!! Error !!',mb_IconHand or mb_ok);
     Exit;
     end;
     fShowCmd:=Y;

     W:=0;
     hresx:= psl.GetHotKey(@W);
     If hresx<>0 then
     begin
     MessageBox(0,'Error in get HK','!! Error !!',mb_IconHand or mb_ok);
     Exit;
     end;
     fHotKey:=W;

     hresx:= psl.GetArguments(@X1,MAX_PATH ); If hresx<>0 then begin
     MessageBox(0,'Error in get AR','!! Error !!',mb_IconHand or mb_ok);
     Exit;
     end;
     fArguments:=StrPas(@X1);

     ppf.release;
     psl.release;
     StrDispose(X3);
     fPath:=S;
     end;

     procedure TShellLink.SetUpdate(const S:Boolean); begin
     SetSelfPath(fPath);
     fUpdate:=True;
     end;

     procedure TShellLink.fSetSelfPath(const S:String); begin
     SetSelfPath(S);
     end;

     procedure TShellLink.CreateNew(const Path,Target:String); var
     X1,X3:PChar;S,S2,S3:String[255];
     hresx:HResult;
     Psl:IShellLink;
     Ppf:IPersistFile;
     Saver:Array [0..Max_Path] of WideChar; begin
     hresx:=0;
     hresx:=CoCreateInstance(CLSID_ShellLink,nil,CLSCTX_INPROC_SERVER,IID_I
     ShellLink, psl);
     If hresx<>0 then
     begin
     MessageBox(0,'Error in create instance','!! Error !!',mb_IconHand or
     mb_ok); Exit;
     end;

     X1:=StrAlloc(255);
     X3:=StrAlloc(255);
     try
     StrPCopy(X1,Target);
     hresx:=psl.SetPath(X1);
     if hresx<>0 then
     begin
     MessageBox(0,'Error in set path','!! Error !!',mb_IconHand or mb_ok);
     Exit;
     end;

     hresx:=psl.QueryInterface(IID_IPersistFile,ppf); if hresx<>0 then
     begin
     MessageBox(0,'Error in query interface','!! Error !!',mb_IconHand or
     mb_ok); Exit;
     end;

     StrPCopy(X3,Path);

     MultiByteToWideChar(CP_ACP,0,X3,-1,Saver,Max_Path);

     hresx:=ppf.Save(Saver,True);
     If hresx=0 then
     begin
     MessageBox(0,'Error in save','!! Error !!',mb_IconHand or mb_ok);
     Exit;
     end;

     finally
     ppf.release;
     psl.release;
     StrDispose(X1);
     StrDispose(X3);
     end;
     End;

     procedure TShellLink.SaveToFile(const Path:String); var
     X1,X3:PChar;S,S2,S3:String[255];
     hresx:HResult;
     Psl:IShellLink;
     Ppf:IPersistFile;
     Saver:Array [0..Max_Path] of WideChar; begin
     hresx:=0;
     hresx:=CoCreateInstance(CLSID_ShellLink,nil,CLSCTX_INPROC_SERVER,IID_I
     ShellLink, psl);
     If hresx<>0 then
     begin
     MessageBox(0,'Error in create instance','!! Error !!',mb_IconHand or
     mb_ok); Exit;
     end;

     X1:=StrAlloc(255);
     X3:=StrAlloc(255);
     try
     StrPCopy(X1,fTarget);
     hresx:=psl.SetPath(PChar(fTarget));
     If hresx<>0 then
     begin
     MessageBox(0,'Error in set path','!! Error !!',mb_IconHand or mb_ok);
     Exit;
     end;

     StrPCopy(X1,fDescription);
     hresx:=psl.SetDescription(X1);
     hresx:=psl.SetWorkingDirectory(PChar(fWorkingDir));
     hresx:=psl.SetArguments(PChar(fArguments));
     hresx:=psl.SetHotKey(fHotKey);
     hresx:=psl.SetShowCmd(fShowCmd);
     hresx:=psl.SetIconLocation(PChar(fIconLocation),IconNumber);


     hresx:=psl.QueryInterface(IID_IPersistFile,ppf); If hresx<>0 then
     begin
     MessageBox(0,'Error in query interface','!! Error !!',mb_IconHand or
     mb_ok); Exit;
     end;

     StrPCopy(X3,Path);

     MultiByteToWideChar(CP_ACP,0,X3,-1,Saver,Max_Path);

     hresx:=ppf.Save(Saver,True);

     If hresx<>0 then
     begin
     MessageBox(0,'Error in save','!! Error !!',mb_IconHand or mb_ok);
     Exit;
     end;
     ppf.release;
     finally
     psl.release;
     StrDispose(X1);
     StrDispose(X3);
     end;
     End;


     begin
     end.


     *******************************************************
     and this is sample code for create link and retrieve information from
     link
     *******************************************************

     unit test1;

     interface

     uses
     Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
     Dialogs, SheLink, StdCtrls,Ole2;

     type
     TForm1 = class(TForm)
     GroupBox1: TGroupBox;
     Memo1: TMemo;
     Button1: TButton;
     Link: TShellLink;
     Open1: TOpenDialog;
     GroupBox2: TGroupBox;
     Edit1: TEdit;
     Label1: TLabel;
     Button2: TButton;
     Label2: TLabel;
     Edit2: TEdit;
     Button3: TButton;
     Open2: TOpenDialog;
     Save: TSaveDialog;
     Button4: TButton;
     procedure Button1Click(Sender: TObject); procedure
     Button2Click(Sender: TObject); procedure Button3Click(Sender:
     TObject); procedure Button4Click(Sender: TObject); procedure
     FormCreate(Sender: TObject); procedure FormDestroy(Sender: TObject);
     private
     { Private declarations }
     public
     { Public declarations }
     end;

     var
     Form1: TForm1;

     implementation

     {_R *.DFM}

     procedure TForm1.Button1Click(Sender: TObject); begin If Not
     Open1.Execute then Exit;
     Link.SetSelfPath(Open1.FileName);
     Memo1.Lines.Add('Arguments :'+Link.Arguments);
     Memo1.Lines.Add('Description :'+Link.Description);
     Memo1.Lines.Add('Hotkey :'+IntToStr(Link.Hotkey));
     Memo1.Lines.Add('Target :'+Link.Target); Memo1.Lines.Add('WorkingDir
     :'+Link.WorkingDir); end;

     procedure TForm1.Button2Click(Sender: TObject); begin If Open2.Execute
     then Edit1.Text:=Open2.FileName; end;

     procedure TForm1.Button3Click(Sender: TObject); begin If Save.Execute
     then Edit2.Text:=Save.FileName; end;

     procedure TForm1.Button4Click(Sender: TObject); begin
     Link.CreateNew(Edit2.Text,Edit1.Text); end;

     procedure TForm1.FormCreate(Sender: TObject); begin CoInitialize(nil);
                       // required for Shell link end;

     procedure TForm1.FormDestroy(Sender: TObject); begin
     CoUninitialize;                      // required for Shell link end;

     end.

     a tadu je k tomu form

     object Form1: TForm1
     Left = 223
     Top = 107
     Width = 435
     Height = 300
     Caption = 'Shell Link Demo'
     Font.Color = clWindowText
     Font.Height = -11
     Font.Name = 'MS Sans Serif'
     Font.Style = []
     OnCreate = FormCreate
     OnDestroy = FormDestroy
     PixelsPerInch = 96
     TextHeight = 13
     object GroupBox1: TGroupBox
     Left = 4
     Top = 4
     Width = 419
     Height = 147
     Caption = ' Get info from shell link ' TabOrder = 0 object Memo1:
     TMemo
     Left = 6
     Top = 18
     Width = 407
     Height = 101
     TabOrder = 0
     end
     object Button1: TButton
     Left = 6
     Top = 120
     Width = 407
     Height = 25
     Caption = 'Get info'
     TabOrder = 1
     OnClick = Button1Click
     end
     end
     object GroupBox2: TGroupBox
     Left = 4
     Top = 154
     Width = 419
     Height = 117
     Caption = ' Create new link '
     TabOrder = 1
     object Label1: TLabel
     Left = 12
     Top = 14
     Width = 34
     Height = 13
     Caption = 'Target '
     end
     object Label2: TLabel
     Left = 12
     Top = 52
     Width = 82
     Height = 13
     Caption = 'Name of new link'
     end
     object Edit1: TEdit
     Left = 10
     Top = 30
     Width = 321
     Height = 21
     TabOrder = 0
     Text = 'C:\Autoexec.bat'
     end
     object Button2: TButton
     Left = 338
     Top = 26
     Width = 75
     Height = 25
     Caption = 'Browse'
     TabOrder = 1
     OnClick = Button2Click
     end
     object Edit2: TEdit
     Left = 10
     Top = 68
     Width = 321
     Height = 21
     TabOrder = 2
     Text = 'C:\this is shortcut to Autoexec.bat.lnk' end
     object Button3: TButton
     Left = 338
     Top = 64
     Width = 75
     Height = 25
     Caption = 'Browse'
     TabOrder = 3
     OnClick = Button3Click
     end
     object Button4: TButton
     Left = 10
     Top = 90
     Width = 405
     Height = 25
     Caption = 'Create new link (shortcut)' TabOrder = 4 OnClick =
     Button4Click
     end
     end
     object Link: TShellLink
     HotKey = 0
     ShowCmd = 0
     IconNumber = 0
     Update = True
     Left = 378
     Top = 24
     end
     object Open1: TOpenDialog
     FileEditStyle = fsEdit
     Filter = 'Link files|*.lnk|Pif files|*.pif' Options =
     [ofNoDereferenceLinks]
     Left = 378
     Top = 56
     end
     object Open2: TOpenDialog
     FileEditStyle = fsEdit
     Filter = 'All files|*.*'
     Left = 302
     Top = 170
     end
     object Save: TSaveDialog
     DefaultExt = '*.lnk'
     FileEditStyle = fsEdit
     Filter = '*.lnk|*.lnk'
     Left = 302
     Top = 216
     end
     end



     Bye Radek Voltr

     voltrr1@epr1.ccmail.x400.cez.cz


