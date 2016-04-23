{ PW> Does anyone have any code or info on how to Program Graphics on an HP
 PW> Laserjet?

--------------<start here >------------
}

Unit LJGraph;
{$F+,O+}
Interface

Const
  PorTRAIT       =0;
  LandSCAPE      =1;
  GRAYSCALE      =2;

Var
  SCRNIMAGE      :Pointer;
  NEGATIVE       :Boolean;
  PROMPTPOS      :Integer;
  GraphDRIVER,GraphMODE:Integer;

Procedure PRinTPAUSE(inVERT:Boolean);

Implementation

Uses Graph,Printer,Crt;

  Procedure PROMPTLinE(MSG:String);
  Var
    CHRHT,
    MAXX,
    MAXY           :Integer;


  begin
    MAXX:=GETMAXX;
    MAXY:=GETMAXY;
    SETCOLor(BLACK);
    SETTextSTYLE(DEFAULTFONT,HorIZDIR,1);
    SETTextJUSTifY(CENTERText,toPText);
    CHRHT:=TextHEIGHT('H');
    PROMPTPOS:=MAXY-(CHRHT+4);
    GETMEM(SCRNIMAGE,IMAGESIZE(0,PROMPTPOS,MAXX,MAXY));
    GETIMAGE(0,PROMPTPOS,MAXX,MAXY,SCRNIMAGE^);
    BAR(0,PROMPTPOS,MAXX,MAXY);
    RECTANGLE(0,PROMPTPOS,MAXX,MAXY);
    OUTTextXY(MAXX div 2,MAXY-(CHRHT+2),MSG);
  end;

  Function FMT(MSGPOS:Real):Integer;
  Var
    WIDTH          :Integer;

  begin
    WIDTH:=6;
    if(MSGPOS<1000.0)then
      DEC(WIDTH);
    if(MSGPOS<100.0)then
      DEC(WIDTH);
    if(MSGPOS<10.0)then
      DEC(WIDTH);
    FMT:=WIDTH;
  end;

  Function SETGRAYSCALE(SCANLinE,GPIXEL:Integer):Integer;
  Var
    GRAY           :Integer;

  begin
    GRAY:=0;
    if(GraphDRIVER=CGA) and(GraphMODE<>CGAHI)then
      begin
        Case SCANLinE of
          0:
          begin
              if GPIXEL and 1<>0 then
                GRAY:=GRAY or 9;
              if GPIXEL and 2<>0 then
                GRAY:=GRAY or 6;
            end;
          1:
          begin
              if GPIXEL and 1<>0 then
                GRAY:=GRAY or 4;
              if GPIXEL and 2<>0 then
                GRAY:=GRAY or 11;
            end;
          2:
          begin
              if GPIXEL and 1<>0 then
                GRAY:=GRAY or 2;
              if GPIXEL and 2<>0 then
                GRAY:=GRAY or 13;
            end;
          3:
          begin
              if GPIXEL and 1<>0 then
                GRAY:=GRAY or 9;
              if GPIXEL and 2<>0 then
                GRAY:=GRAY or 6;
            end;
        end;
      end
    else
      begin
        Case SCANLinE of
          0:
          begin
              if GPIXEL and 4<>0 then
                GRAY:=GRAY or 5;
              if GPIXEL and 8<>0 then
                GRAY:=GRAY or 10;
            end;
          1:
          begin
              if GPIXEL and 1<>0 then
                GRAY:=GRAY or 2;
              if GPIXEL and 2<>0 then
                GRAY:=GRAY or 8;
              if GPIXEL and 8<>0 then
                GRAY:=GRAY or 5;
            end;
          2:
          begin
              if GPIXEL and 4<>0 then
                GRAY:=GRAY or 5;
              if GPIXEL and 8<>0 then
                GRAY:=GRAY or 10;
            end;
          3:
          begin
              if GPIXEL and 2<>0 then
                GRAY:=GRAY or 2;
              if GPIXEL and 8<>0 then
                GRAY:=GRAY or 5;
            end;
        end;
      end;
    if NEGATIVE then
      GRAY:=GRAY xor $0F;
    SETGRAYSCALE:=GRAY;
  end;

  Procedure LJGraphIC(MODE:Integer);
  Const
    ESC            =#$1B;
    GRendS         =ESC+'*rB';
    GRinIT         =ESC+'E'+ESC+'&11H'+ESC+
    '&10'+ESC+'*pOY'+ESC+'*t';

  Var
    I,
    J,
    K,
    P,
    Q,
    M,
    MAXX,
    MAXY           :Integer;
    XASP,
    YASP           :Word;
    XPRN,
    YPRN,
    PRSTEP,
    ASPR           :Real;

  begin
    PUTIMAGE(0,PROMPTPOS,SCRNIMAGE^,COPYPUT);
    MAXX:=GETMAXX+1;
    MAXY:=GETMAXY+1;
    GETASPECTRATIO(XASP,YASP);
    ASPR:=XASP/YASP;
    SETVIEWPorT(0,0,MAXX,MAXY,False);
    Case MODE of
      PorTRAIT:
      begin
                 XPRN:=690.0;
                 YPRN:=500.0;
                 PRSTEP:=7.2/ASPR;
                 Write(LST,GRinIT,'100R');
                 For J:=0 to MAXY do
                   begin
                     Write(LST,ESC,'&A',
                           XPRN:FMT(XPRN):1,'h',
                           YPRN:FMT(YPRN):1,'V');
                     YPRN:=YPRN+PRSTEP;
                     Write(LST,ESC,'*r1A',ESC,'*b',MAXX div 8,'W');
                     For I:=0 to MAXX div 8 do
                       begin
                         M:=0;
                         For K:=0 to 7 do
                           begin
                             M:=M SHL 1;
                             if GETPIXEL(I*8+K,J)<>0 then
                               inC(M);
                           end;
                         Write(LST,Char(M));
                       end;
                     Write(LST,GRendS);
                   end;
               end;
      LandSCAPE:
      begin
                  XPRN:=1000.0;
                  YPRN:=1000.0;
                  PRSTEP:=9.6*ASPR;
                  Write(LST,GRinIT,'75R');
                  For J:=0 to MAXX-1 do
                    begin
                      Write(LST,ESC,'&a',
                            XPRN:FMT(XPRN):1,'h',
                            YPRN:FMT(YPRN):1,'V');
                      YPRN:=YPRN+PRSTEP;
                      Write(LST,ESC,'*r1A',ESC,'*b',MAXX div 8,'W');
                      For I:=0 to MAXY div 8 do
                        begin
                          M:=0;
                          For K:=0 to 7 do
                            begin
                              M:=M SHL 1;
                              if GETPIXEL(MAXX-J-1,I*8+K)<>0 then
                                inC(M);
                            end;
                          Write(LST,Char(M));
                        end;
                      Write(LST,GRendS);
                    end;
                end;
      GRAYSCALE:
      begin
                  XPRN:=1000.0;
                  YPRN:=1000.0;
                  PRSTEP:=2.4*ASPR;
                  Write(LST,GRinIT,'300R');
                  For J:=0 to MAXX do
                    For P:=0 to 3 do
                      begin
                        Write(LST,ESC,'&a',
                              XPRN:FMT(XPRN):1,'h',
                              YPRN:FMT(YPRN):1,'V');
                        YPRN:=YPRN+PRSTEP;
                        Write(LST,ESC,'*r1A',ESC,'*b',MAXY div 2,'W');
                        For I:=0 to MAXY div 2 do
                          begin
                            M:=0;
                            For K:=0 to 1 do
                              begin
                                M:=M SHL 4;
                                M:=M or SETGRAYSCALE(P,GETPIXEL(MAXX-J,I*2+K));
                              end;
                            Write(LST,Char(M));
                          end;
                        Write(LST,GRendS);
                      end;
                end;
    end;
    Write(LST,#$0C,ESC,'&10',ESC,'(8U',ESC,'(sp10h12vsb0T',ESC,'&11H');
  end;


  Procedure PRinTPAUSE(inVERT:Boolean);
  Var
    CH             :Char;
    doNE           :Boolean;

  begin
    DETECTGraph(GraphDRIVER,GraphMODE);
    doNE:=False;
    NEGATIVE:=inVERT;
    While not doNE do
      begin
        PROMPTLinE('PRESS THE <P> KEY to PRinT THIS Graph '+
                   'or ANY OTHER to Exit....');
        While KeyPressed do
          CH:=ReadKey;
        CH:=ReadKey;
        PUTIMAGE(0,PROMPTPOS,SCRNIMAGE,COPYPUT);
        Case UPCase(CH)of
          'P':
          begin
                LJGraphIC(GRAYSCALE);
                doNE:=True;
              end;
        else
          doNE:=True;
        end;
        DISPOSE(SCRNIMAGE);
      end;
  end;
end.
{
---------- stop here --------
So first you init the Graph driver. Next you draw the Graph you want. then
you use printpause afterwards you can close the Graphdriver.
}