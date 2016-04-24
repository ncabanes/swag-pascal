(*
  Category: SWAG Title: INPUT AND FIELD ENTRY ROUTINES
  Original name: 0015.PAS
  Description: Generic Data Entry
  Author: RAPHAEL VANNEY
  Date: 08-24-94  13:55
*)


{-----------------------------------------------------------------------------}
{                                                                             }
{ SAISIE.PAS - (c) Raphaël VANNEY, 1993                                       }
{                                                                             }
{ Generic data entry unit.                                                    }
{ Langage : Borland Pascal 7                                                  }
{                                                                             }
{ This unit intends to provide a tool for data entry from a Pascal program,   }
{ in a more fancy fashion that what ReadLn allows for.                        }
{                                                                             }
{ I wrote it not because I felt like reinventing the wheel, but rather        }
{ because I needed something that was not available for the OS/2 patch of     }
{ Borland Pascal.                                                             }
{                                                                             }
{ As a result, this unit will compile and run DOS, DPMI and OS/2 programs.    }
{                                                                             }
{ Note : depending on the version of the OS/2 patch you use, this unit        }
{        may not work properly (problem with extended keys).                  }
{                                                                             }
{-----------------------------------------------------------------------------}
{$b-,x+}

{$IfDef OS2}
     {$c Moveable Discardable DemandLoad}
{$EndIf}

Unit Saisie ;

Interface

Uses Objects ;

Const
     { A few key codes, as returned by LitTouche }
     kbTab          = 9 ;
     kbEntree       = 13 ;         { enter }
     kbRetour       = 8 ;          { backspace }
     kbCtrlEntree   = 10 ;         { ctrl-enter }
     kbEchap        = 27 ;         { escape }
     kbHaut         = 18432 ;      { up }
     kbBas          = 20480 ;      { down }
     kbDroite       = 19712 ;      { right }
     kbGauche       = 19200 ;      { left }
     kbPageHaut     = 18688 ;      { PgUp }
     kbPageBas      = 20736 ;      { PgDn }
     kbFin          = 20224 ;      { end }
     kbDebut        = 18176 ;      { home }
     kbIns          = 20992 ;
     kbSuppr        = 21248 ;      { del }

     kbCtrlD        = 4 ;
     kbCtrlT        = 20 ;
     kbCtrlY        = 25 ;

     kbCtrlDroite   = 29696 ;      { ctrl-right }
     kbCtrlGauche   = 29440 ;      { ctrl-left }

     Caracteres     : Set Of Char = ['a'..'z', 'A'..'Z', #128..#165] ;


Type { TListeChaines is an unsorted collection of PString's                }
     TListeChaines =
     Object(TCollection)
          Procedure      FreeItem(Item : Pointer) ; Virtual ;
     End ;
     PListeChaines = ^TListeChaines ;

     { TChampSaisie is the basic, ancestor data entry field                }
     TChampSaisie =
     Object(TObject)
          Contenu        : String ;     { content during keyboard input    }
          x, y,                         { screen coordinates               }
          Largeur,                      { on-screen width of field         }
          Taille,                       { size of the field                }
          AttrActif,                    { active field colors              }
          AttrPassif     : Byte ;       { passive field colors             }
          Variable       : Pointer ;    { pointer to variable to fill      }
          EffaceAuto     : Boolean ;    { True if automatic clearing       }

          Constructor    Init(     _x, _y         : Integer ;
                                   _Largeur       : Integer ;
                                   _Taille        : Integer ;
                                   _AttrActif,
                                   _AttrPassif    : Integer ;
                                   Var _Variable) ;

          { Dessine draws the entry field on screen. Decalage is an
            optional shifting (if content is wider than screen field)      }
          Procedure      Dessine(  Actif     : Boolean ;
                                   Decalage  : Integer) ; Virtual ;

          { Runs the data entry. Returns the code of the key used to exit. }
          Function       Execute : Word ; Virtual ;

          { Reads a key from keyboard. May be redefined by child objects,
            for instance to handle the mouse.                              }
          Function       LitTouche : Word ; Virtual ;

          { Checks whether or not a key is valid or not, given cursor pos.
            Should be redefined for numeric fields, etc...                 }
          Function       ToucheValide(  Position  : Integer ;
                                        Touche    : Word) : Boolean ; Virtual ;

          { Handles the key. Returns True if the key was accepted.         }
          Function       GereTouche(Var Position  : Integer ;
                                    Var Touche    : Word) : Boolean ; Virtual ;

          { Reads the content of the user variable (pointed to by
            Variable) to Contenu.                                          }
          Procedure      LitResultat ; Virtual ;

          { Moves Contenu to the user variable.                            }
          Procedure      EcritResultat ; Virtual ;

          { Checks whether Contenu's (what the user typed!) is valid.      }
          Function       ContenuValide : Boolean ; Virtual ;
     End ;
     PChampSaisie   = ^TChampSaisie ;

     { The next objects are specialized childrens of TChampSaisie. Now,
       what is OOP for ? ;-)                                               }

     { TChampLongint specializes in handling LongInt input.                }
     TChampLongInt  =
     Object(TChampSaisie)
          Function       ToucheValide(  Position  : Integer ;
                                        Touche    : Word) : Boolean ; Virtual ;
          Procedure      LitResultat ; Virtual ;
          Procedure      EcritResultat ; Virtual ;
          Function       ContenuValide : Boolean ; Virtual ;
     End ;
     PChampLongInt  = ^TChampLongInt ;

     { TChampOctet is done to handle Byte input.                           }
     TChampOctet    =
     Object(TChampLongInt)
          Mini,
          Maxi      : Byte ;

          Constructor    Init(     _x, _y         : Integer ;
                                   _Largeur       : Integer ;
                                   _Taille        : Integer ;
                                   _AttrActif,
                                   _AttrPassif    : Integer ;
                                   _Mini, _Maxi   : Byte ;
                                   Var _Variable  : Byte) ;
          Procedure      LitResultat ; Virtual ;
          Procedure      EcritResultat ; Virtual ;
          Function       ContenuValide : Boolean ; Virtual ;
     End ;
     PChampOctet    = ^TChampOctet ;

     { TChampMajuscules will uppercase what the user types in.             }
     TChampMajuscules =
     Object(TChampSaisie)
          Function       GereTouche(Var Position  : Integer ;
                                    Var Touche    : Word) : Boolean ; Virtual ;
     End ;
     PChampMajuscules = ^TChampMajuscules ;

     { TChampChoixListe will let the user make a choice within a defined
       list. See the 'Sex' field in TEST.PAS.                              }
     TChampChoixListe =
     Object(TChampSaisie)
          Liste          : PListeChaines ;   { choices list                }
          Courant        : Integer ;         { current choice              }

          { _Variable contains (and will be so updated) the index of the
            selected entry in the _Liste list of choices.                  }
          Constructor    Init(     _x, _y         : Integer ;
                                   _Largeur       : Integer ;
                                   _AttrActif,
                                   _AttrPassif    : Integer ;
                                   _Liste         : PListeChaines ;
                                   Var _Variable  : Integer) ;
          Function       ToucheValide(  Position  : Integer ;
                                        Touche    : Word) : Boolean ; Virtual ;
          Function       GereTouche(Var Position  : Integer ;
                                    Var Touche    : Word) : Boolean ; Virtual ;
          Procedure      LitResultat ; Virtual ;
          Procedure      EcritResultat ; Virtual ;

          Private

          Procedure      MetAJourContenu ;
     End ;
     PChampChoixListe = ^TChampChoixListe ;

     { TChampPChar will let you input a ASCIIZ string.                     }
     TChampPChar    =
     Object(TChampSaisie)
          Procedure      LitResultat ; Virtual ;
          Procedure      EcritResultat ; Virtual ;
     End ;
     PChampPChar    = ^TChampPChar ;

     { TChampBoolean handles Boolean fields input.                         }
     TChampBooleen  =
     Object(TChampSaisie)
          Constructor    Init(     _x, _y         : Integer ;
                                   _AttrActif,
                                   _AttrPassif    : Integer ;
                                   Var _Variable  : Boolean) ;
          Function       ToucheValide(  Position  : Integer ;
                                        Touche    : Word) : Boolean ; Virtual ;
          Function       GereTouche(Var Position  : Integer ;
                                    Var Touche    : Word) : Boolean ; Virtual ;
          Procedure      LitResultat ; Virtual ;
          Procedure      EcritResultat ; Virtual ;
     End ;
     PChampBooleen  = ^TChampBooleen ;

     { TGroupeSaisie is a collection of TChampSaisie. The Execute method
       will handle cycling through entry fields, etc...                    }
     TGroupeSaisie  =
     Object(TCollection)
          Function  Execute : Word ;
     End ;
     PGroupeSaisie  = ^TGroupeSaisie ;

{ Utilities                                                                }
Function Complete(St : OpenString ; Len : Integer) : String ;
Function LitClavier : Integer ;

{--------------------------------------------------------------------------}
{--------------------------------------------------------------------------}

Implementation

Uses DOS,
     Strings,
{$IfDef OS2}
     OS2Subs,
{$EndIf}
     CRT ;

{-----------------------------------------------------------------------------}

Function LitClavier : Integer ;
Var  t    : Word ;
Begin
     t:=Ord(ReadKey) ;
     If t=0 Then t:=Ord(ReadKey) ShL 8 ;
     LitClavier:=t ;
End ;

Function Complete(St : OpenString ; Len : Integer) : String ;
Var  i    : Integer ;
Begin
     For i:=Length(St)+1 To Len Do St[i]:=' ' ;
     St[0]:=Chr(Len) ;
     Complete:=St ;
End ;

Constructor TChampSaisie.Init ;
Begin
     x:=_x ;
     y:=_y ;
     Largeur:=_Largeur ;
     If (Largeur<0) Or (Largeur>80) Then Fail ;
     Taille:=_Taille ;
     AttrActif:=_AttrActif ;
     AttrPassif:=_AttrPassif ;
     Variable:=Addr(_Variable) ;
     EffaceAuto:=True ;

     LitResultat ;
     If Length(Contenu)>Taille Then
          Contenu:=Copy(Contenu, 1, Taille) ;
End ;

Procedure TChampSaisie.Dessine ;
Var  St   : String ;
Begin
     If Actif Then TextAttr:=AttrActif
              Else TextAttr:=AttrPassif ;
     St:=Copy(Contenu, Decalage, Largeur) ;
     If Length(St)<Largeur Then St:=Complete(St, Largeur) ;
{$IfDef OS2}
     VioWrtCharStrAtt(   @St[1], Length(St),
                         y+Hi(WindMin)-1, x+Lo(WindMin)-1,
                         TextAttr, 0) ;
{$Else}
     GoToXY(x, y) ;
     Write(St) ;
{$EndIf}
End ;

Function TChampSaisie.Execute ;
Var  Touche    : Word ;
     Position  : Integer ;
     Decalage  : Integer ;
     Termine   : Boolean ;
     Premiere  : Boolean ;
Begin
     Decalage:=1 ;
     Position:=1 ;
     Termine:=False ;
     Premiere:=True ;

     Repeat
          Dessine(True, Decalage) ;
          GoToXY(x-Decalage+Position, y) ;
          Touche:=LitTouche ;
          If EffaceAuto Then
          If Premiere Then
          If (Touche>31) And (Touche<256) Then
          If ToucheValide(Position, Touche) Then Contenu:='' ;
          Premiere:=False ;
          If Not GereTouche(Position, Touche) Then
          { A-t-on terminé ? }
          If (Touche<32) Or (Touche>255) Then Termine:=True ;
          { Adaptons Decalage à Position }
          If Position<Decalage Then Decalage:=Position ;
          If Position>=(Decalage+Largeur) Then Decalage:=Position-Largeur+1 ;

          If Termine Then
          Begin
               Termine:=ContenuValide ;
               If Not Termine Then
               Begin
{$IfDef OS2}
                    PlaySound(300, 200) ;
{$Else}
                    Sound(300) ;
                    Delay(200) ;
                    NoSound ;
{$EndIf}
               End ;
          End ;
     Until Termine ;

     If Touche<>kbEchap Then EcritResultat
                        Else LitResultat ;
     Dessine(False, 1) ;
     Execute:=Touche ;
End ;

Function TChampSaisie.LitTouche ;
Begin
     LitTouche:=LitClavier ;
End ;

Function TChampSaisie.ToucheValide ;
Begin
     ToucheValide:=True ;
End ;

Function TChampSaisie.ContenuValide ;
Begin
     ContenuValide:=True ;
End ;

Function TChampSaisie.GereTouche ;
Begin
     GereTouche:=True ;
     If ToucheValide(Position, Touche) Then
     Begin
          Case Touche Of
               32..255   :
               Begin
                    Insert(Chr(Touche), Contenu, Position) ;
                    If Length(Contenu)>Taille Then Dec(Contenu[0]) ;
                    If Position<Taille Then Inc(Position) ;
               End ;
               kbCtrlD,
               kbDroite  :
               Begin
                    If Position<=Length(Contenu) Then Inc(Position) ;
                    If Position>Taille Then Dec(Position) ;
               End ;
               kbGauche  :
               Begin
                    If Position>1 Then Dec(Position) ;
               End ;
               kbRetour  :
               Begin
                    If Position>1 Then
                    Begin
                         Dec(Position) ;
                         Delete(Contenu, Position, 1) ;
                    End ;
               End ;
               kbSuppr   :
               Begin
                    If Position<=Length(Contenu) Then
                    Begin
                         Delete(Contenu, Position, 1) ;
                    End ;
               End ;
               kbFin     : Position:=Length(Contenu)+1 ;
               kbDebut   : Position:=1 ;
               kbCtrlY   :
               Begin
                    Contenu:='' ;
                    Position:=1 ;
               End ;
               kbCtrlT   :
               Begin
                    While (Position<Length(Contenu)) And
                          (Contenu[Position] In Caracteres) Do
                         Delete(Contenu, Position, 1) ;
                    If Position<=Length(Contenu) Then
                         Delete(Contenu, Position, 1) ;
               End ;
               kbCtrlGauche :
               Begin
                    If Position>1 Then Dec(Position) ;
                    While (Position>1) And
                          (Contenu[Position-1] In Caracteres) Do Dec(Position) ;
               End ;
               kbCtrlDroite :
               Begin
                    While (Position<Length(Contenu)) And
                          (Contenu[Position] In Caracteres) Do Inc(Position) ;
                    If Position<=Length(Contenu) Then Inc(Position) ;
                    If Position>Taille Then Dec(Position) ;
               End ;
               Else GereTouche:=False ;
          End ;
     End Else
     Begin
{$IfDef OS2}
          PlaySound(1000, 100) ;
{$Else}
          Sound(1000) ;
          Delay(100) ;
          NoSound ;
{$EndIf}
     End ;
End ;

Procedure TChampSaisie.LitResultat ;
Begin
     Move(Variable^, Contenu, Taille+1) ;
End ;

Procedure TChampSaisie.EcritResultat ;
Begin
     Move(Contenu, Variable^, Length(Contenu)+1) ;
End ;

{-------------------------------------- TGroupeSaisie ------------------------}

Function TGroupeSaisie.Execute ;

     Procedure Affiche(Champ : PChampSaisie) ; Far ;
     Begin
          Champ^.Dessine(False, 1) ;
     End ;

Var  Touche    : Word ;
     Courant   : Integer ;
     Termine   : Boolean ;

Begin
     ForEach(@Affiche) ;

     Termine:=Count=0 ;
     Courant:=0 ;
     Touche:=kbEchap ;

     Repeat
          Touche:=PChampSaisie(At(Courant))^.Execute ;
          Case Touche Of
               kbHaut    :
               Begin
                    Dec(Courant) ;
                    If Courant<0 Then Courant:=Pred(Count) ;
               End ;
               kbEntree,
               kbTab,
               kbBas     :
               Begin
                    Inc(Courant) ;
                    If Courant>=Count Then Courant:=0 ;
               End ;
               kbPageHaut,
               kbPageBas,
               kbEchap,
               kbCtrlEntree :
               Begin
                    Termine:=True ;
               End ;
          End ;
     Until Termine ;

     Execute:=Touche ;
End ;

{-------------------------------------- TChampLongInt ------------------------}

Function TChampLongInt.ToucheValide ;
Begin
     ToucheValide:=(Touche<32) Or (Touche>255) Or
                   ((Touche>=Ord('0')) And (Touche<=Ord('9'))) ;
End ;

Procedure TChampLongInt.LitResultat ;
Type PLongInt  = ^LongInt ;
3Begin
     Str(PLongInt(Variable)^, Contenu) ;
End ;

Procedure TChampLongInt.EcritResultat ;
Type PLongInt  = ^LongInt ;
Var  Err  : Integer ;
Begin
     Val(Contenu, PLongInt(Variable)^, Err) ;
End ;

Function TChampLongInt.ContenuValide ;
Type PLongInt  = ^LongInt ;
Var  Err  : Integer ;
Begin
     Val(Contenu, PLongInt(Variable)^, Err) ;
     ContenuValide:=Err=0 ;
End ;

{-------------------------------------- TChampOctet --------------------------}

Constructor TChampOctet.Init ;
Begin
     Mini:=_Mini ;
     Maxi:=_Maxi ;
     If Not Inherited Init(_x, _y, _Largeur, _Largeur, _AttrActif,
                           _AttrPassif, _Variable) Then Fail ;
     If Not ContenuValide Then
     Begin
          _Variable:=Mini ;
          LitResultat ;
     End ;
End ;

Procedure TChampOctet.LitResultat ;
Type PByte     = ^Byte ;
Begin
     Str(PByte(Variable)^, Contenu) ;
End ;

Procedure TChampOctet.EcritResultat ;
Type PByte  = ^Byte ;
Var  Err  : Integer ;
Begin
     Val(Contenu, PByte(Variable)^, Err) ;
End ;

Function TChampOctet.ContenuValide ;
Type PByte     = ^Byte ;
Var  Err  : Integer ;
Begin
     Val(Contenu, PByte(Variable)^, Err) ;
     ContenuValide:=(Err=0) And
                    (PByte(Variable)^>=Mini) And
                    (PByte(Variable)^<=Maxi) ;
End ;

{-------------------------------------- TChampMajuscules ------------------}
{ This should give you ideas if you need input masks...                    }

Function TChampMajuscules.GereTouche ;
Begin
     If (Touche>=Ord('a')) And (Touche<=Ord('z')) Then Dec(Touche, 32) ;
     GereTouche:=Inherited GereTouche(Position, Touche) ;
End ;

{-------------------------------------- TListeChaines ------------------------}

Procedure TListeChaines.FreeItem ;
Begin
     If Item<>Nil Then DisposeStr(PString(Item)) ;
End ;

{-------------------------------------- TChampChoixListe ---------------------}

Constructor TChampChoixListe.Init ;
Begin
     Liste:=_Liste ;
     If Not Inherited Init(_x, _y, _Largeur, _Largeur, _AttrActif,
                           _AttrPassif, _Variable) Then Fail ;
End ;

Procedure TChampChoixListe.LitResultat ;
Type PInteger = ^Integer ;
Begin
     Courant:=PInteger(Variable)^ ;
     If (Courant<0) Or
        (Courant>=Liste^.Count) Then Courant:=0 ;
     MetAJourContenu ;
End ;

Procedure TChampChoixListe.EcritResultat ;
Type PInteger  = ^Integer ;
Begin
     PInteger(Variable)^:=Courant ;
End ;

Function TChampChoixListe.ToucheValide ;
Begin
     ToucheValide:=(Touche<32) Or (Touche>255) ;
End ;

Function TChampChoixListe.GereTouche ;
Begin
     GereTouche:=True ;
     If ToucheValide(Position, Touche) Then
     Begin
          Case Touche Of
               kbDroite       :
               Begin
                    Inc(Courant) ;
                    If Courant>=Liste^.Count Then Courant:=0 ;
                    MetAJourContenu ;
               End ;
               kbGauche       :
               Begin
                    Dec(Courant) ;
                    If Courant<0 Then Courant:=Pred(Liste^.Count) ;
                    MetAJourContenu ;
               End ;
               Else GereTouche:=False ;
          End ;
     End Else
     Begin
{$IfDef OS2}
          PlaySound(1000, 100) ;
{$Else}
          Sound(1000) ;
          Delay(100) ;
          NoSound ;
{$EndIf}
     End ;
End ;

Procedure TChampChoixListe.MetAJourContenu ;
Var  Tmp  : String[80] ;
Begin
     If Liste^.At(Courant)=Nil
     Then Tmp:=''
     Else Tmp:=Copy(PString(Liste^.At(Courant))^, 1, Largeur-2) ;
     Contenu:=#17+Complete(Tmp, Largeur-2)+#16 ;
End ;

{-------------------------------------- TChampPChar --------------------------}

Procedure TChampPChar.LitResultat ;
Begin
     Contenu:=StrPas(Variable) ;
End ;

Procedure TChampPChar.EcritResultat ;
Begin
     StrPCopy(Variable, Contenu) ;
End ;

{-------------------------------------- TChampBooleen ------------------------}

Constructor TChampBooleen.Init ;
Begin
     If Not Inherited Init(_x, _y, 3, 3, _AttrActif,
                           _AttrPassif, _Variable) Then Fail ;
     EffaceAuto:=False ;
End ;

Function TChampBooleen.ToucheValide ;
Begin
     ToucheValide:=(Touche<=32) Or (Touche>255) ;
End ;

Function TChampBooleen.GereTouche ;
Begin
     If (Touche=32) Or
        (Touche=kbDroite) Or
        (Touche=kbGauche) Then
     Begin
          GereTouche:=True ;
          If Contenu[2]=' ' Then Contenu[2]:='■'
                            Else Contenu[2]:=' ' ;
     End Else
     Begin
          GereTouche:=Inherited GereTouche(Position, Touche) ;
     End ;
End ;

Procedure TChampBooleen.LitResultat ;
Type PBoolean  = ^Boolean ;
Begin
     If PBoolean(Variable)^ Then Contenu:='[■]'
                            Else Contenu:='[ ]' ;
End ;

Procedure TChampBooleen.EcritResultat ;
Type PBoolean  = ^Boolean ;
Begin
     PBoolean(Variable)^:=Contenu[2]<>' ' ;
End ;

End.

{ ---------------------    DEMO ----------------------------}
{ Example for the SAISIE unit. Raphaël Vanney, 07/94 }

{$d+,l+,x+}

Uses CRT,
     Saisie,
     Strings,
     Objects,
     DOS ;

Var  Test      : PGroupeSaisie ;

     Enreg     :
     Record
          LastName       : String[30] ;
          FirstName      : String[30] ;
          Address        : String[100] ;
          ZipCode        : LongInt ;
          City           : String[30] ;
          Sex            : Integer ;
     End ;
     Liste     : PListeChaines ;

Begin
     ClrScr ;
     TextColor(LightCyan) ;
     TextBackGround(Blue) ;

     FillChar(Enreg, SizeOf(Enreg), #0) ;
     TextColor(LightGreen) ;
     GoToXY(1, 1) ;
     Write('^Enter to validate') ;

     Liste:=New(PListeChaines, Init(2, 2)) ;
     Liste^.Insert(NewStr('Unknown')) ;
     Liste^.Insert(NewStr('Male')) ;
     Liste^.Insert(NewStr('Female')) ;

     Test:=New(PGroupeSaisie, Init(2, 2)) ;
     With Enreg Do
     Begin
          GoToXY(1, 10) ; Write('Last name : ') ;
          Test^.Insert(New(PChampMajuscules, Init(12, 10,
                                                  20,
                                                  SizeOf(LastName)-1,
                                                  (Blue ShL 4)+White,
                                                  (Blue ShL 4)+LightGray,
                                                  LastName))) ;
          GoToXY(1, 11) ; Write('FirstName : ') ;
          Test^.Insert(New(PChampSaisie, Init(12, 11,
                                             20,
                                             SizeOf(FirstName)-1,
                                             (Blue ShL 4)+White,
                                             (Blue ShL 4)+LightGray,
                                             FirstName))) ;
          GoToXY(1, 12) ; Write('Address   : ') ;
          Test^.Insert(New(PChampSaisie, Init(12, 12,
                                             20,
                                             SizeOf(Address)-1,
                                             (Blue ShL 4)+White,
                                             (Blue ShL 4)+LightGray,
                                             Address))) ;
          GoToXY(1, 13) ; Write('Zip code  : ') ;
          Test^.Insert(New(PChampLongInt, Init(   12, 13,
                                                  6,
                                                  5,
                                                  (Blue ShL 4)+White,
                                                  (Blue ShL 4)+LightGray,
                                                  ZipCode))) ;
          GoToXY(1, 14) ; Write('City      : ') ;
          Test^.Insert(New(PChampMajuscules, Init(12, 14,
                                                  20,
                                                  SizeOf(City)-1,
                                                  (Blue ShL 4)+White,
                                                  (Blue ShL 4)+LightGray,
                                                  City))) ;
          GoToXY(1, 15) ; Write('Sex       : ') ;
          Test^.Insert(New(PChampChoixListe, Init(12, 15,
                                                  20,
                                                  (Blue ShL 4)+White,
                                                  (Blue ShL 4)+LightGray,
                                                  Liste,
                                                  Sex))) ;
     End ;

     Test^.Execute ;
     Dispose(Liste, Done) ;
     Dispose(Test, Done) ;

     GoToXY(1, 18) ;
     TextAttr:=LightGray ;
     With Enreg Do
     Begin
          WriteLn('LastName        =', LastName) ;
          WriteLn('FirstName       =', FirstName) ;
          WriteLn('Address         =', Address) ;
          WriteLn('ZipCode         =', ZipCode) ;
          WriteLn('City            =', City) ;
          WriteLn('Sex             =', Sex) ;
     End ;
End.

