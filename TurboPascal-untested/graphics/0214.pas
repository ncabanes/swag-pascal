Uses Crt,Newgraph;
     { NOTE : NewGraph - in GRAPHICS.SWG }


Var ImgPointer: pointer;

    FUNCTION IntToStr(Value : LONGINT) : STRING;
    VAR
      Stg : STRING;
    BEGIN
       STR (value : 13, Stg);
       IntToStr := Stg;
    END;

Begin
     LoadShape(ParamStr(1),ImgPointer);
     InitVGAMode;
     Blit(0,0,ImgPointer^);
     OutTextXY(0,190,IntToStr(ShapeWidth(ImgPointer^)));
     OutTextXY(20,190,IntToStr(ShapeHeight(ImgPointer^)));
     Repeat Until keypressed;
End.