
{****************************************************************}
{Delphi 2.0 only                                                 }
{AddBtn95 derives TRadioButton95 and TCheckBox95 from            }
{                 TRadioButton And TCheckBox to Give them the    }
{                 Additional Formatting Functionality found in   }
{                 Windows 95                                     }
{Added or changed properties :                                   }
{  Alignment  : How the Text next to the button is aligned       }
{  AlignmentBtn : Where the Button is positioned                 }
{  LikePushButton : Does the control look Like a Push Button?    }
{  VerticalAlignment : Where the text and button are positioned  }
{  WordWrap : Wrap the text if the box is to narrow              }
{****************************************************************}
{Ver 1.0                                                         }
{Copyright(c) 1996 PA van Lonkhuyzen                             }
{e-mail : peterv@global.co.za                                    }
{****************************************************************}

unit addbtn95;

interface

uses
  Windows,  StdCtrls, Classes, controls;

type
  TVAlignment = (vaTop,vaBottom,vaCenter);
  TCheckBox95 = class(TCheckBox)
  private
   fAlignment : TAlignment;
   fAlignmentBtn : TLeftRight;
   fLikePushButton : Boolean;
   fVerticalAlignment : TVAlignment;
   fWordWrap : Boolean;
  protected
    procedure createparams(var Params: TCreateParams); override;
    Procedure SetLikePushButton(ALikePushButton : Boolean);
    Procedure SetWordWrap(AWordWrap : Boolean);
    Procedure SetAlignment(AAlignment : TAlignment);
    Procedure SetAlignmentBtn(AAlignmentBtn : TLeftRight);
    Procedure SetVerticalAlignment(AVerticalAlignment : TVAlignment);
  public
    { Public declarations }
  published
   Property Alignment : TAlignment Read fAlignment Write SetAlignment;
   Property AlignmentBtn : TLeftRight Read fAlignmentBtn Write SetAlignmentBtn;
   Property LikePushButton : Boolean Read fLikePushButton Write SetLikePushButton;
   Property VerticalAlignment : TVAlignment Read fVerticalAlignment Write SetVerticalAlignment;
   Property WordWrap : Boolean Read fWordWrap Write SetWordWrap;
end;

  TRadioButton95 = class(TRadioButton)
  private
   fAlignment : TAlignment;
   fAlignmentBtn : TLeftRight;
   fLikePushButton : Boolean;
   fVerticalAlignment : TVAlignment;
   fWordWrap : Boolean;
  protected
    procedure createparams(var Params: TCreateParams); override;
    Procedure SetLikePushButton(ALikePushButton : Boolean);
    Procedure SetWordWrap(AWordWrap : Boolean);
    Procedure SetAlignment(AAlignment : TAlignment);
    Procedure SetAlignmentBtn(AAlignmentBtn : TLeftRight);
    Procedure SetVerticalAlignment(AVerticalAlignment : TVAlignment);
  public
    { Public declarations }
  published
   Property Alignment : TAlignment Read fAlignment Write SetAlignment;
   Property AlignmentBtn : TLeftRight Read fAlignmentBtn Write SetAlignmentBtn;
   Property LikePushButton : Boolean Read fLikePushButton Write SetLikePushButton;
   Property VerticalAlignment : TVAlignment Read fVerticalAlignment Write SetVerticalAlignment;
   Property WordWrap : Boolean Read fWordWrap Write SetWordWrap;
end;

procedure Register;

implementation
procedure TRadioButton95.createparams(var Params: TCreateParams);
begin
  Inherited createparams(Params);
  params.style:=params.style and not(BS_LEFT or BS_RIGHT or BS_CENTER OR
                                     BS_LEFTTEXT or BS_RIGHTBUTTON OR
                                     BS_TOP OR BS_BOTTOM OR BS_VCENTER);
  case fVerticalAlignment of
    vaTop : params.style:=params.style or BS_TOP;
    vaBottom : params.style:=params.style or BS_BOTTOM;
    else
      params.style:=params.style or BS_VCENTER;
  end;
  if fAlignmentBtn=taRightJustify then
    params.style:=params.style or BS_RIGHTBUTTON;
  case fAlignment of
    taLeftJustify : params.style:=params.style or BS_LEFT;
    taRightJustify : params.style:=params.style or BS_RIGHT;
    else params.style:=params.style or BS_CENTER;
  End;
  if fLikePushButton then
    params.style:=params.style or bs_pushLike;
  if fwordwrap then
    params.style:=params.style or bs_MultiLine;

end;


Procedure TRadioButton95.SetAlignment(AAlignment : TAlignment);
Begin
   If (AAlignment <> fAlignment) then
   begin
     fAlignment := AAlignment;
     recreatewnd;
   end;
End;


Procedure TRadioButton95.SetAlignmentBtn(AAlignmentBtn : TLeftRight);
Begin
   If (AAlignmentBtn <> fAlignmentBtn) then
   begin
     fAlignmentBtn := AAlignmentBtn;
     recreatewnd;
   end;
End;

Procedure TRadioButton95.SetLikePushButton(ALikePushButton : Boolean);
Begin
   If (ALikePushButton <> fLikePushButton) then
   begin
     fLikePushButton := ALikePushButton;
     recreatewnd;
   end;
End;

Procedure TRadioButton95.SetWordWrap(AWordWrap : Boolean);
Begin
   If (AWordWrap <> fWordwrap) then
   begin
     fWordwrap := AWordWrap;
     recreatewnd;
   end;
End;


Procedure TRadioButton95.SetVerticalAlignment(AVerticalAlignment : TVAlignment);
Begin
   If (AVerticalAlignment <> fVerticalAlignment) then
   begin
     fVerticalAlignment := AVerticalAlignment;
     Recreatewnd;
   end;
End;

procedure TCheckBox95.createparams(var Params: TCreateParams);
begin
  Inherited createparams(Params);
  params.style:=params.style and not(BS_LEFT or BS_RIGHT or BS_CENTER OR
                                     BS_LEFTTEXT or BS_RIGHTBUTTON OR
                                     BS_TOP OR BS_BOTTOM OR BS_VCENTER);
  case fVerticalAlignment of
    vaTop : params.style:=params.style or BS_TOP;
    vaBottom : params.style:=params.style or BS_BOTTOM;
    else
      params.style:=params.style or BS_VCENTER;
  end;    
  if fAlignmentBtn=taRightJustify then
    params.style:=params.style or BS_RIGHTBUTTON;
  case fAlignment of
    taLeftJustify : params.style:=params.style or BS_LEFT;
    taRightJustify : params.style:=params.style or BS_RIGHT;
    else params.style:=params.style or BS_CENTER;
  End;
  if fLikePushButton then
    params.style:=params.style or bs_PushLike;
  if fwordwrap then
    params.style:=params.style or bs_MultiLine;

end;


Procedure TCheckBox95.SetAlignment(AAlignment : TAlignment);
Begin
   If (AAlignment <> fAlignment) then
   begin
     fAlignment := AAlignment;
     recreatewnd;
   end;
End;


Procedure TCheckBox95.SetAlignmentBtn(AAlignmentBtn : TLeftRight);
Begin
   If (AAlignmentBtn <> fAlignmentBtn) then
   begin
     fAlignmentBtn := AAlignmentBtn;
     recreatewnd;
   end;
End;

Procedure TCheckBox95.SetLikePushButton(ALikePushButton : Boolean);
Begin
   If (ALikePushButton <> fLikePushButton) then
   begin
     fLikePushButton := ALikePushButton;
     recreatewnd;
   end;
End;

Procedure TCheckBox95.SetWordWrap(AWordWrap : Boolean);
Begin
   If (AWordWrap <> fWordwrap) then
   begin
     fWordwrap := AWordWrap;
     recreatewnd;
   end;
End;


Procedure TCheckBox95.SetVerticalAlignment(AVerticalAlignment : TVAlignment);
Begin
   If (AVerticalAlignment <> fVerticalAlignment) then
   begin
     fVerticalAlignment := AVerticalAlignment;
     Recreatewnd;
   end;
End;

procedure Register;
begin
  RegisterComponents('Win95', [TCheckBox95,TRadioButton95]);
end;

end.
