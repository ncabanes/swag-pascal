{
From: Norman.User@telos.org (Norman User)
Here is the revised NewSquishList function you need.
}

Function NewSquishList(Urec,Arec:MaxRecPtr;NewOnly,ToYouOnly:Boolean):pointer;
   Var
     Sq : SqiColPtr;
     f  : PDosStream;
     fb : PBufStream;
     sql: sqlType;
     sqi: sqiType;
     Sqp: SqiPtr;
     tempN : longint;
     lhn   : LongInt;
     lhs   : string;
     sqz   : Longint;
   Begin
     NewSquishList := nil;
     sq    := nil;
     sql   := 0;
     tempN := 0;
     if   NewOnly
     then Begin
            (***** last read message number from the SQL file *****)
            New(F,init(StrPas(@MaxAreaRec(Arec^.rec^).mpath) +         
                       '.SQL',StOpenRead or StDenyNone));
            if   f^.status = StOk
            then begin
                   f^.seek(MaxUserRec(Urec^.rec^).LastRead*SizeOf(sqlType));
                   if f^.status = stok then f^.read(sql,sizeof(sql));
                   if f^.status <> Stok then sql := -1;
                 end;
            dispose(f,done);
            if sql < 0 then exit;
          End;
     lhn := sql;
     sqz := sql;
     fillchar(sqi,sizeof(sqi),0);
     New(fb,init(StrPas(@MaxAreaRec(Arec^.rec^).mpath) + '.SQI',StOpenRead or  
                StDenyNone,2048));
     if fb^.status = StOk then fb^.read(sqi,sizeof(sqitype));
     while (fb^.status = StOk) and (sqi.msgnum <= sql)
     do    begin
             inc(tempN);
             fillchar(sqi,sizeof(sqitype),0);
             fb^.read(sqi,sizeof(sqitype));
           end;
     while (fb^.status = StOk)
     do    begin
             if   Sqi.msgnum > SQZ
             then begin
                    sqz := sqi.MsgNum;
                    inc(tempN);
                    if Sqi.MsgNum > lhn
                    then lhn := Sqi.MsgNum;
                    sqi.msgnum := TempN;
                    if   (Not ToYouOnly) or                          
                         (SqHashName(StrPas(@MaxUserRec(Urec^.rec^).name)) = 
                          Sqi.Hashname)
                    then begin
                            new(sqp);
                            sqp^ := sqi;
                            if sq = nil then new(sq,init(20,5));
                            sq^.insert(sqp);
                          end
                   end
             else inc(tempN);
             fb^.read(sqi,sizeof(sqitype));
           end;
     dispose(fb,done);
     if   lhn > sql
     then begin
            if   LRMCollection = Nil
            then New(LRMCollection,init(10,5));
            lhs := StrPas(@MaxAreaRec(Arec^.rec^).mpath) + '.SQL';
            LRMCollection^.Insert(New(P0Base,init(newstr(lhs),
                           LongInt((MaxUserRec(Urec^.rec^).lastread)),
                           lhn,true)));
          end;
     NewSquishList := sq;
End;


