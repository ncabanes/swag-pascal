{*******************************}
{*         î«ñπ½∞ »α«ßΓ«ú«     *}
{*  ¼¡«ú«»α«µÑßß¡«ú« ¼«¡¿Γ«αá  *}
{*          VSTasks v 1.01     *}
{*   ñ½∩ Turbo Pascal ver 7.0  *}
{* (c) Copyright VVSsoft Group *}
{*******************************}
{$F+$S-}

{  v.1.01  ---  »« ßαáó¡Ñ¡¿ε ß óÑαß¿Ñ⌐ 1.0 ¿ß»αáó½Ñ¡ óδσ«ñ ¿º »α«µÑßßá- }
{               »α«µÑñπαδ »« ñ«ßΓ¿ªÑ¡¿ε  END. é »αÑñδñπΘÑ⌐ óÑαß¿¿ ¡πª¡« }
{               íδ½« «í∩ºáΓÑ½∞¡« »ÑαÑñ END-«¼ ßΓáó¿Γ∞  HaltCurrentTask, }
{               ¿¡áτÑ  ß¿ßΓÑ¼á "ó¿ß½á".  ÆÑ»Ñα∞  »α¿  ñ«ßΓ¿ªÑ¡¿¿  ¬«¡µá }
{               »α«µÑßßá-»α«µÑñπαδ áóΓ«¼áΓ«¼ »α«µÑßß ºá¬αδóáÑΓß∩ ...    }
{                                                                       }
{                               (c) VVSsoft Group.  è«¡«¡«ó é½áñ¿¼¿α.   }

Unit VSTasks;

interface {--------------------------------------------}

Type

 PTaskRec =^TTaskRec;  { ---- «»¿ßáΓÑ½∞ »α«µÑßßá -----}
 TTaskRec =
  record
   NumProc  : word;        { π¡¿¬á½∞¡δ⌐ ¡«¼Ñα »α«µÑßßá }
   Next     : PTaskRec;    { ß½ÑñπεΘ¿⌐ «»¿ßáΓÑ½∞ »α«µÑßßá }
   OrignSP,                { º¡áτÑ¡¿Ñ SP ñ½∩ ó«ºóαáΓá }
   OrignSS  : word;        { º¡áτÑ¡¿Ñ SS ñ½∩ ó«ºóαáΓá }
   Stack    : pointer;     { π¬áºáΓÑ½∞ ¡á ßΓÑ¬ »α«µÑßßá }
   SSize    : word;        { αáº¼Ñα ßΓÑ¬á »α«µÑßßá }
  end;

Const

  CountTask   : word = 0;       { óßÑú« ºáαÑú¿ßΓα¿α«óá¡¡« »α«µÑßß«ó }
  PCurTask    : PTaskRec = Nil; { π¬áºáΓÑ½∞ ¡á ΓÑ¬πΘπε óδ»«½¡∩Ñ¼πε ºáñáτπ }
  HeadStack   : PTaskRec = Nil; { π¬áºáΓÑ½∞ ¡á ú«½«óπ ßΓÑ¬á }
  UniNumber   : word = 1;       { π¡¿¬á½∞¡δ⌐ ¡«¼Ñα ñ½∩ ß«ºñáóáÑ¼«ú« »α«µÑßßá }
  CurTask     : word = 0;       { ¡«¼Ñα ΓÑ¬πΘÑú« »α«µÑßßá }

{----------------- ¬«ñδ «Φ¿í«¬ αÑú¿ßΓαáµ¿¿ »α«µÑßßá --------------}

  vstMemoryLow       = 1;   { ¡ÑΓ »á¼∩Γ¿ ñ½∩ ß«ºñá¡¿∩ ßΓÑ¬á »α«µÑßßá }
  vstEmptyStackTask  = 2;   { ¡ÑΓ ºáαÑú¿ßΓα¿α«óá¡¡δσ »α«µÑßß«ó }
  vstMAXLimitProc    = 3;   { ß½¿Φ¬«¼ ¼¡«ú« »α«µÑßß«ó }

Var
  TaskError     : byte;     { »«ß½Ññ¡∩∩ «Φ¿í¬á }


procedure StartTasks;
{--- ºá»πß¬ »α«µÑßß«ó ¡á óδ»«½¡Ñ¡¿Ñ ---}

procedure SwithTasks; far;
{--- »ÑαÑ¬½ετÑ¡¿Ñ ¼Ñªñπ ºáñáτá¼¿ ---}

function RegisterTask(TaskPoint : pointer; SizeStack: word): word;
{--- αÑú¿ßΓαáµ¿∩ ºáñáτ¿ Ñß½¿ - 0, Γ« «Φ¿í¬á ó »ÑαÑ¼Ñ¡¡«⌐ TaskError ---}
{--- ó«ºóαáΘáÑΓ ¡«¼Ñα ºáαÑú¿ßΓα¿α«óá¡¡«ú« »α«µÑßßá ---}

procedure HaltCurrentTask;
{--- ß¡∩Γ¿Ñ ΓÑ¬πΘÑ⌐ ºáñáτ¿ ---}

procedure HaltAllTasks;
{--- ß¡∩Γ¿Ñ óßÑσ ºáñáτ ---}

implementation
{----------------------------------------------------------------}

Var
    OriginalSS,                { áñαÑß «α¿ú¿¡á½∞¡«ú« ßΓÑ¬á »α«úαá¼¼δ     }
    OriginalSP     : word;     { π¬áºáΓÑ½∞ «α¿ú¿¡á½∞¡«ú« ßΓÑ¬á »α«úαá¼¼δ }
    PDopPoint      : PTaskRec; { ñ«»«½¡¿ΓÑ½∞¡δ⌐ π¬áºáΓÑ½∞ }

{------- »ÑαÑ«»αÑñÑ½Ñ¡¡δÑ Σπ¡¬µ¿¿ ñ½∩ αáí«Γδ ß BASM«¼ ---------}

function mMemAvail: word;
Var M: longint;
    T: record
        L,H: word;
       end;
begin
 M:=MaxAvail;
 If M>$FFFF then mMemAvail:=$FFFF
  else
   begin
    Move(M,T,SizeOf(longint));
    mMemAvail:=T.L;
   end;
end;

function mGetMem(S:word): pointer;
Var P:pointer;
begin
 GetMem(P,S);
 mGetMem:=P;
end;

procedure mFreeMem(P: pointer;S: word);
Var D: pointer;
begin
 D:=P;
 FreeMem(P,S);
end;

procedure StartTasks; assembler;
{ --- ºá»πß¬ »α«µÑßß«ó ¡á óδ»«½¡Ñ¡¿Ñ --- }
asm
    { 1) çá»«¼¡¿Γ∞ ó ßΓÑ¬Ñ αÑú¿ßΓαδ;
      2) çá»«¼¡¿Γ∞ ó ßΓÑ¬Ñ Γ«τ¬π óδσ«ñá ¿º ¼Ñ¡ÑñªÑαá »α«µÑßß«ó;
      3) æ«σαá¡¿Γ∞ αÑú¿ßΓαδ SS ¿ SP ñ½∩ «ß¡«ó¡«⌐ »α«úαá¼¼δ;
      4) ìá⌐Γ¿ »Ñαóδ⌐ »α«µÑßß ñ½∩ ºá»πß¬á;
      5) ÅÑαÑπßΓá¡«ó¿Γ∞ óßÑ ΓÑ¬πΘ¿Ñ »ÑαÑ¼Ñ¡¡δÑ;
      6) ÅÑαÑπßΓá¡«ó¿Γ∞ SS:SP ¿ ó«ßßΓá¡«ó¿Γ∞ αÑú¿ßΓαδ;
      7) Åα«¿ºóÑßΓ¿ "ñ½¿¡¡δ⌐ óδσ«ñ" (τ¿Γá⌐ óσ«ñ) RETF ó »α«µÑßß;
      8) Å«ß½Ñ ó«ºóαáΓá ó Γ«τ¬π óδσ«ñá ¿º »α«µÑßßá, ó«ßßΓá¡«ó¿Γ∞
         αÑú¿ßΓαδ. }
   {----------------------------------------------------}
                 PUSH BP                    { ß«σαá¡∩Ñ¼ αÑú¿ßΓαδ            }
                 PUSH DI                    {}
                 PUSH SI                    {}
                 PUSH DS                    {}
                 PUSH ES                    {}
                 LEA  DI, @ExitPoint        { ó DI ß¼ÑΘÑ¡¿Ñ óδσ«ñá          }
                 PUSH CS                    { ß«σαá¡∩Ñ¼ Γ«τ¬π óδσ«ñá ¿º     }
                 PUSH DI                    { »α«µÑßß«ó                     }
                 MOV  OriginalSS, SS        { ß«σαá¡∩Ñ¼ SS:SP               }
                 MOV  OriginalSP, SP        {}
                 MOV  AX, CountTask         { Ñß½¿ ¡ÑΓ ºáαÑú¿ßΓα¿α«ó. ºáñáτ }
                 XOR  BX, BX                {}
                 CMP  AX, BX                {}
                 JE   @Exit                 { «τÑαÑñ∞ »α«µÑßß«ó »πßΓá       }
                 MOV  DI, HeadStack.word[0] { ó ES:DI π¬áºáΓÑ½∞ ¡á          }
                 MOV  ES, HeadStack.word[2] { «»¿ßáΓÑ½∞ »α«µÑßßá            }
                 MOV  AX, ES:[DI]           { ¡«¼Ñα ΓÑ¬πΘÑú« »α«µÑßßá       }
                 MOV  CurTask, AX           {}
                 MOV  PCurTask.word[0], DI  { PCurTask αáó¡« »Ñαó«¼π        }
                 MOV  PCurTask.word[2], ES  { »α«µÑßßπ                      }
                 CLI                        {}
                 MOV  SS, ES:[DI+8]         { »ÑαÑπßΓá¡«ó¬á ßΓÑ¬á           }
                 MOV  SP, ES:[DI+6]         {}
                 STI                        {}
                 POP  BP                    { ó«ßΓá¡áó½¿óáÑ¼ αÑú¿ßΓαδ       }
                 POP  ES                    { »α«µÑßßá                      }
                 POP  DS                    {}
                 RETF                       { "óδσ«ñ" ó »α«µÑßß             }
 @Exit:          POP  AX                    { ñ«ßΓáÑ¼ ¿º ßΓÑ¬á ¡Ñ¡πª¡«Ñ     }
                 POP  AX                    {}
                 MOV  AL, vstEmptyStackTask {}
                 MOV  TaskError, AL         {}
 @ExitPoint:     POP  ES                    { ó«ßßΓá¡áó½¿óáÑ¼ αÑú¿ßΓαδ      }
                 POP  DS                    {}
                 POP  SI                    {}
                 POP  DI                    {}
                 POP  BP                    {}
end;

procedure SwithTasks; assembler;
{ --- »ÑαÑ¬½ετÑ¡¿Ñ ¼Ñªñπ ºáñáτá¼¿ --- }
asm
    { 1) C«σαá¡Ñ¡¿Ñ óßÑσ αÑú¿ßΓα«ó ΓÑ¬πΘÑú« »α«µÑßßá [DS,ES,BP];
      2) ìáσ«ªñÑ¡¿Ñ ß½ÑñπεΘÑú« »α«µÑßßá ñ½∩ ¿ß»«½¡Ñ¡¿∩;
      3) C«σαá¡Ñ¡¿Ñ π¬áºáΓÑ½Ñ⌐ SS:SP ¡á ßΓÑ¬ ΓÑ¬πΘÑú« »α«µÑßßá;
      4) êº¼Ñ¡Ñ¡¿Ñ π¬áºáΓÑ½Ñ⌐ SS:SP ¡á ßΓÑ¬ ñ½∩ »«ß½ÑñπεΘÑú« »α«µÑßßá;
      5) êº¼Ñ¡Ñ¡¿Ñ óßÑσ ΓÑ¬πΘ¿σ »ÑαÑ¼Ñ¡¡δσ;
      6) é«ßßΓá¡«ó½Ñ¡¿Ñ αÑú¿ßΓα«ó ñ½∩ ¡«ó«ú« »α«µÑßßá [BP,ES,DS]; }
   {-----------------------------------------------------------------}
                 PUSH DS                    { ß«σαá¡Ñ¡¿Ñ αÑú¿ßΓα«ó ßΓáα«ú«  }
                 PUSH ES                    { »α«µÑßßá                      }
                 PUSH BP                    {}
                 MOV  AX, SEG @Data         { πßΓá¡«ó¬á ßÑú¼Ñ¡Γá ñá¡¡δσ     }
                 MOV  DS, AX                {}
                 MOV  ES, PCurTask.word[2]  { ó ES:DI π¬áºáΓÑ½∞ ¡á «»¿ßáΓÑ½∞}
                 MOV  DI, PCurTask.word[0]  { ΓÑ¬πΘÑú« »α«µÑßßá             }
                 MOV  ES:[DI+8], SS         { ß«σαá¡∩Ñ¼ SS:SP ó ΓÑ¬πΘÑ¼     }
                 MOV  ES:[DI+6], SP         { «»¿ßáΓÑ½Ñ »α«µÑßßá            }
                 MOV  BX, ES:[DI+4]         { ó BX:SI π¬áºáΓÑ½∞ ¡á ß½ÑñπεΘ¿⌐}
                 MOV  SI, ES:[DI+2]         { »α«µÑßß                       }
                 MOV  ES, BX                { πªÑ ó ES:SI                   }
                 XOR  AX, AX                { »α«óÑα¬á ¡á Nil               }
                 CMP  BX, AX                {}
                 JNE  @Next                 { Ñß½¿ ¡Ñ Nil-¬ «íαáí«Γ¬Ñ       }
                 CMP  SI, AX                {}
                 JNE  @Next                 {}
                 MOV  ES, HeadStack.word[2] { ¿¡áτÑ ß½ÑñπεΘ¿⌐ - ¡áτá½∞¡δ⌐   }
                 MOV  SI, HeadStack.word[0] { «»¿ßáΓÑ½∞ HeadStack           }
 @Next:          MOV  PCurTask.word[2], ES  { ¼Ñ¡∩Ñ¼ π¬áºáΓÑ½∞ ¡á ΓÑ¬πΘ¿⌐   }
                 MOV  PCurTask.word[0], SI  { «»¿ßáΓÑ½∞                     }
                 MOV  AX, ES:[SI]           { ¼Ñ¡∩Ñ¼ ¡«¼Ñα ΓÑ¬πΘÑú« »α«µÑßßá}
                 MOV  CurTask, AX           {}
                 CLI                        {}
                 MOV  SS, ES:[SI+8]         { ¼Ñ¡∩Ñ¼ π¬áºáΓÑ½¿ ßΓÑ¬á        }
                 MOV  SP, ES:[SI+6]         { »«ñ ¡«óδ⌐ »α«µÑßß             }
                 STI                        {}
                 POP  BP                    { ó«ßßΓá¡«ó½Ñ¡¿Ñ αÑú¿ßΓα«ó      }
                 POP  ES                    { ¡«ó«ú« »α«µÑßßá               }
                 POP  DS                    {}
end;

function RegisterTask(TaskPoint: pointer; SizeStack: word): word; assembler;
{ --- αÑú¿ßΓαáµ¿∩ ºáñáτ¿ --- }
{ Ñß½¿ ó«ΘºóαáΘÑ¡ 0, Γ« «Φ¿í¬á ó »ÑαÑ¼Ñ¡¡«⌐ TaskError }
asm
    { 1) æ«ºñá¡¿Ñ ó »á¼∩Γ¿ «»¿ßáΓÑ½∩ »α«µÑßßá;
      2) éδñÑ½Ñ¡¿Ñ »á¼∩Γ¿ »«ñ ßΓÑ¬ »α«µÑßßá;
      3) ìáσ«ªñÑ¡¿Ñ π¡¿¬á½∞¡«ú« «»¿ßáΓÑ½∩ »α«µÑßßá;
      4) ôó∩º¬á «»¿ßáΓÑ½∩ ¡«ó«ú« »α«µÑßßá ó µÑ»«τ¬π »α«µÑßß«ó;
      5) æ«σαá¡Ñ¡¿Ñ ó ßΓÑ¬Ñ »α«µÑßßá áñαÑßá óσ«ñá ó »α«µÑßß ¿ αÑú¿ßΓα«ó;
      6) éδσ«ñ ó «ß¡«ó¡πε »α«úαá¼¼π. }
    {---------------------------------------------------------}
                 XOR  AX, AX                {}
                 NOT  AX                    {}
                 CMP  AX, UniNumber         {}
                 JE   @TooManyProc          { ß½¿Φ¬«¼ ¼¡«ú« »α«µÑßß«ó       }
                 CALL mMemAvail             { »α«óÑα¬á ¡á½¿τ¿∩ »á¼∩Γ¿       }
                 MOV  BX, SizeStack         {}
                 CMP  AX, BX                {}
                 JB   @LowMem               { Ñß½¿ »á¼∩Γ¿ ¡ÑΓ               }
                 PUSH BX                    {}
                 CALL mGetMem               { ó DX:AX π¬áºáΓÑ½∞ ¡á ßΓÑ¬     }
                 PUSH DX                    {}
                 PUSH AX                    {}
                 CALL mMemAvail             { »á¼∩Γ∞ ñ½∩ TTaskRec           }
                 MOV  CX, TYPE TTaskRec     {}
                 CMP  AX, CX                {}
                 JB   @LowMemAndFree        { Ñß½¿ ¡Ñ σóáΓ¿Γ                }
                 PUSH CX                    { ú«Γ«ó¿¼ »áαá¼ÑΓαδ             }
                 CALL mGetMem               { óδñÑ½∩Ñ¼ »á¼∩Γ∞               }
                 PUSH ES                    {}
                 MOV  ES, DX                { ES:DI π¬áºδóáÑΓ ¡á «»¿ßáΓÑ½∞  }
                 MOV  DI, AX                { ¡«ó«ú« »α«µÑßßá               }
                 MOV  AX, UniNumber         { »α¿ßóá¿óáÑ¼ π¡¿¬á½∞¡δ⌐ ¡«¼Ñα  }
                 MOV  ES:[DI], AX           {}
                 INC  AX                    { ¿¡¬αÑ¼Ñ¡Γ UniNumber           }
                 MOV  UniNumber, AX         {}
                 MOV  BX, HeadStack.word[0] { π¬áºáΓÑ½∞ ¡á ß½ÑñπεΘ¿⌐        }
                 MOV  CX, HeadStack.word[2] { «»¿ßáΓÑ½∞ = HeadStack         }
                 MOV  ES:[DI+2], BX         {}
                 MOV  ES:[DI+4], CX         {}
                 POP  CX                    { ó CX  º¡áτÑ¡¿Ñ ES             }
                 POP  AX                    { ó AX ß¼ÑΘÑ¡¿Ñ ßΓÑ¬á           }
                 MOV  ES:[DI+10], AX        { ß¼ÑΘÑ¡¿Ñ π¬áºáΓÑ½∩ Stack      }
                 MOV  BX, SizeStack         { ß«σαá¡∩Ñ¼ αáº¼Ñα ßΓÑ¬á ó      }
                 MOV  ES:[DI+14], BX        { SSize ΓÑ¬πΘÑú« «»¿ßáΓÑ½∩      }
                 ADD  AX, BX                { óδτ¿ß½∩Ñ¼ º¡áτÑ¡¿Ñ SP         }
                 JNC  @NotCorrect           { Ñß½¿ ¬«ααÑ¬µ¿∩ ¡Ñ ¡πª¡á       }
                 XOR  AX, AX                {}
                 NOT  AX                    { AX=$FFFF                      }
 @NotCorrect:    SUB  AX, $01               {}
                 POP  BX                    { ó BX ßÑú¼Ñ¡Γ ßΓÑ¬á            }
                 MOV  ES:[DI+12], BX        { ßÑú¼Ñ¡Γ π¬áºáΓÑ½∩ Stack       }
                 MOV  ES:[DI+8], BX         { OrignSS=BX                    }
                 PUSH ES                    { ß«σαá¡∩Ñ¼ ßÑú¼Ñ¡Γ π¬áºáΓÑ½∩   }
                 MOV  ES, CX                { ó«ßßΓá¡«ó¿½¿ ES               }
                 MOV  CX, TaskPoint.WORD[0] { ß¼ÑΘÑ¡¿Ñ ¡áτá½á ºáñáτ¿        }
                 MOV  DX, TaskPoint.WORD[2] { ßÑú¼Ñ¡Γ ¡áτá½á ºáñáτ¿         }
                 PUSH BP
                 CLI                        {}
                 MOV  SI, SS                { ß«σαá¡∩Ñ¼ SS ó SI             }
                 MOV  BP, SP                { ß«σαá¡∩Ñ¼ SP ó BP             }
                 MOV  SS, BX                { »ÑαÑπßΓá¡áó½¿óáÑ¼ ßΓÑ¬        }
                 MOV  SP, AX                {}
                 MOV  BX,SEG    HaltCurrentTask { áóΓ«¼áΓ¿τÑß¬¿⌐ óδσ«ñ ó    }
                 MOV  AX,OFFSet HaltCurrentTask { »α«µÑñπαπ HaltCurrentTask }
                 PUSH BX                    { »« ñ«ßΓ¿ªÑ¡¿ε «»ÑαáΓ«αá END   }
                 PUSH AX                    { ΓÑ¬πΘÑ⌐ »α«µÑñπαδ-»α«µÑßßá    }
                 PUSH DX                    { ß«σαá¡∩Ñ¼ Γ«τ¬π óσ«ñá ó       }
                 PUSH CX                    { »α«µÑßß                       }
                 PUSH DS                    { ß«σαá¡∩Ñ¼ ó ¡Ñ¼ DS            }
                 PUSH ES                    { -\\- ES                       }
                 MOV  DX, SP                { ú«Γ«ó¿¼ »ßÑóñ« BP             }
                 ADD  DX, $02               { ºáΓá½¬¿óáÑ¼ Ñú« ó ßΓÑ¬        }
                 PUSH DX                    {}
                 MOV  CX, SP                {}
                 MOV  SS, SI                { ó«ßßΓá¡áó½¿óáÑ¼ ßΓÑ¬          }
                 MOV  SP, BP                {}
                 STI                        {}
                 POP  BP                    { ó«ßßΓá¡áó½¿óáÑ¼ BP            }
                 MOV  AX, ES                {}
                 POP  ES                    {}
                 MOV  ES:[DI+6], CX         { OrignSP=CX                    }
                 PUSH ES                    {}
                 MOV  ES, AX                {}
                 POP  AX                    {}
                 MOV  HeadStack.WORD[0], DI { »ÑαÑπßΓá¡áó½¿óáÑ¼ π¬áºáΓÑ½∞   }
                 MOV  HeadStack.WORD[2], AX { HeadStack                     }
                 MOV  AX, CountTask         { ¿¡¬αÑ¼Ñ¡Γ¿απÑ¼ CountTask      }
                 INC  AX                    {}
                 MOV  CountTask, AX         {}
                 MOV  AX, UniNumber         { ó«ºóαáΘáÑ¼δ⌐ ¡«¼Ñα »α«µÑßßá   }
                 DEC  AX                    {}
                 JMP  @Exit                 { óδσ«ñ ¿º »α«µÑñπαδ            }
 @TooManyProc:   MOV  AL, vstMAXLimitProc   {}
                 MOV  TaskError, AL         {}
                 JMP  @ErrExit              {}
 @LowMemAndFree: MOV  BX, SizeStack         {}
                 PUSH BX                    {}
                 CALL mFreeMem              {}
 @LowMem:        MOV  AL, vstMemoryLow      {}
                 MOV  TaskError, AL         {}
 @ErrExit:       XOR  AX, AX                {}
 @Exit:
end;

procedure HaltCurrentTask; assembler;
{ --- ß¡∩Γ¿Ñ ΓÑ¬πΘÑ⌐ ºáñáτ¿ --- }
asm
    { 1) ìáσ«ªñÑ¡¿Ñ ó «τÑαÑñ¿ »α«µÑßß«ó ß½ÑñπεΘÑú« »α«µÑßßá;
      2) ÅÑαÑ¬½ετÑ¡¿Ñ ¡á Ñú« SS ¿ SP;
      3) ÅÑαÑπßΓá¡«ó¬á óßÑσ »ÑαÑ¼Ñ¡¡δσ;
      4) ô¡¿τΓ«ªÑ¡¿Ñ ßΓÑ¬á »αÑñδñπΘÑú« »α«µÑßßá;
      5) ôñá½Ñ¡¿Ñ ¿º «τÑαÑñ¿ »α«µÑßß«ó «»¿ßáΓÑ½∩ »α«µÑßßá;
      6) ôñá½Ñ¡¿Ñ ¿º »á¼∩Γ¿ «»¿ßáΓÑ½∩ »α«µÑßßá;
      7a) àß½¿ íδ½ ¡á⌐ñÑ¡ ß½ÑñπεΘ¿⌐ »α«µÑßß - Γ« ó«ßßΓá¡«ó½Ñ¡¿Ñ
          Ñú« αÑú¿ßΓα«ó ¿ RETF;
      7b) àß½¿ í«½∞ΦÑ »α«µÑßß«ó ¡ÑΓ, Γ« πßΓá¡«ó¬á SS:SP «ß¡«ó¡«⌐
          »α«úαá¼¼δ ¿ RETF ó ¡ÑÑ. }
   {--------------------------------------------------------------}
                 MOV  AX, SEG @Data         { »ÑαÑπßΓá¡«ó¬á ßÑú¼Ñ¡Γá DS     }
                 MOV  ES, PCurTask.word[2]  { ó ES:DI π¬áºáΓÑ½∞ ¡á ΓÑ¬πΘ¿⌐  }
                 MOV  DI, PCurTask.word[0]  { «»¿ßáΓÑ½∞                     }
                 XOR  AX, AX                { «í¡π½Ñ¡¿Ñ ñ«»«½¡¿ΓÑ½∞¡«ú«     }
                 MOV  PDopPoint.word[0], AX { π¬áºáΓÑ½∩                     }
                 MOV  PDopPoint.word[2], AX {}
                 MOV  AX, ES                { AX:DI                         }
                 MOV  DX, HeadStack.word[2] { ó DX:BX º¡áτÑ¡¿Ñ ¡áτá½á ßΓÑ¬á }
                 MOV  BX, HeadStack.word[0] { »α«µÑßß«ó                     }
 @Loop:          CMP  DX, AX                { »α«óÑα¬á αáóÑ¡ßΓóá π¬áºáΓÑ½Ñ⌐ }
                 JNE  @NextProc             { AX:DI ¿ DX:BX                 }
                 CMP  BX, DI                { Ñß½¿ ¡Ñ αáó¡δ, Γ« »«¿ß¬ αáó¡δσ}
                 JNE  @NextProc             {}
                 JMP  @DelProcess           { ¬ πñá½Ñ¡¿ε »α«µÑßßá           }
 @NextProc:      MOV  ES, DX                { ßΓα«¿¼ αÑú¿ßΓα«óπε »áαπ       }
                 MOV  SI, BX                { ES:SI - π¬áºáΓÑ½∞             }
                 MOV  PDopPoint.word[0], BX { ß«σαá¡∩Ñ¼ π¬áºáΓÑ½∞ ¡á        }
                 MOV  PDopPoint.word[2], DX { »αÑñδñπΘ¿⌐ φ½Ñ¼Ñ¡Γ «»¿ßáΓÑ½∞  }
                 MOV  DX, ES:[SI+4]         { ó DX:BX π¬áºáΓÑ½∞ ¡á ß½ÑñπεΘ¿⌐}
                 MOV  BX, ES:[SI+2]         { φ½Ñ¼Ñ¡Γ ßΓÑ¬á «»¿ßáΓÑ½Ñ⌐      }
                 JMP  @Loop                 {}
 @DelProcess:    MOV  ES, AX                { ES:DI                         }
                 MOV  BX, ES:[DI+2]         { ó BX ß¼ÑΘÑ¡¿Ñ ß½ÑñπεΘÑú«      }
                 MOV  PCurTask.word[0], BX  { φ½Ñ¼Ñ¡Γá                      }
                 MOV  DX, ES:[DI+4]         { Γ«ªÑ ß ßÑú¼Ñ¡Γ«¼              }
                 MOV  PCurTask.word[2], DX  {}
                 XOR  CX, CX                { »α«óÑα∩Ñ¼ PDopPoint ¡á Nil    }
                 CMP  CX, PDopPoint.word[0] {}
                 JNE  @NotNil               { Ñß½¿ ¡Ñ Nil                   }
                 CMP  CX, PDopPoint.word[2] {}
                 JNE  @NotNil               {}
                 MOV  HeadStack.word[0], BX { »ÑαÑßΓáó½∩Ñ¼ π¬áºáΓÑ½∞ ¡á     }
                 MOV  HeadStack.word[2], DX { ¡áτá½« ßΓÑ¬á                  }
                 JMP  @FreeMem              {}
 @NotNil:        PUSH ES                    {}
                 PUSH DI                    {}
                 MOV  ES, PDopPoint.word[2] { ó ES:DI π¬áºáΓÑ½∞ ¡á          }
                 MOV  DI, PDopPoint.word[0] { »αÑñδñπΘ¿⌐ φ½Ñ¼Ñ¡Γ            }
                 MOV  ES:[DI+2], BX         { »ÑαÑßΓáó½∩Ñ¼ π¬áºáΓÑ½∞ Next π }
                 MOV  ES:[DI+4], DX         { »αÑñδñπΘÑú« φ½Ñ¼Ñ¡Γá          }
                 POP  DI                    { ó ES:DI π¬áºáΓÑ½∞ ¡á πñá½∩Ñ¼δ⌐}
                 POP  ES                    { φ½Ñ¼Ñ¡Γ                       }
 @FreeMem:       CLI                        {}
                 MOV  SS, OriginalSS        { ó«ßßΓá¡áó½¿óáÑ¼ ßΓÑ¬          }
                 MOV  SP, OriginalSP        { «ß¡«ó¡«⌐ »α«úαá¼¼δ            }
                 STI                        {}
                 MOV  DX, ES:[DI+12]        { ó DX:BX π¬áºáΓÑ½∞ ¡á  ßΓÑ¬    }
                 MOV  BX, ES:[DI+10]        { πñá½∩Ñ¼«ú« »α«µÑßßá           }
                 MOV  CX, ES:[DI+14]        { ó CX αáº¼Ñα ßΓÑ¬á             }
                 PUSH ES                    {}
                 PUSH DI
                 PUSH DX                    { ú«Γ«ó¿¼ ßΓÑ¬ ¿ «ßó«í«ªñáÑ¼    }
                 PUSH BX                    { »á¼∩Γ∞ ßΓÑ¬á πñá½∩Ñ¼«ú«       }
                 PUSH CX                    { »α«µÑßßá                      }
                 CALL mFreeMem              {}
                 POP  DI                    {}
                 POP  ES                    {}
                 MOV  CX, TYPE TTaskRec     { αáº¼Ñα ºá»¿ß¿ TTaskRec -> CX  }
                 PUSH ES                    { πñá½∩Ñ¼ «»¿ßáΓÑ½∞ »α«µÑßßá ¿º }
                 PUSH DI                    { »á¼∩Γ¿                        }
                 PUSH CX                    {}
                 CALL mFreeMem              {}
                 XOR  AX, AX                { «í¡π½¿Γ∞ ¡«¼Ñα ΓÑπΘÑú« »α«µÑßßá}
                 MOV  CurTask, AX           {}
                 MOV  AX, CountTask         { ñÑ¬αÑ¼Ñ¡Γ CountTask           }
                 DEC  AX                    {}
                 MOV  CountTask, AX         {}
                 JZ   @Exit                 { »α«µÑßß«ó í«½∞ΦÑ ¡ÑΓ          }
                 MOV  ES, PCurTask.word[2]  { PCurTask -> ES:DI             }
                 MOV  DI, PCurTask.word[0]  {}
                 MOV  BX, ES                {}
                 XOR  AX, AX                {}
                 CMP  AX, BX                { Ñß½¿ PCurTask ¡Ñ αáóÑ¡        }
                 JNE  @SetProcess           { Nil, Γ« »ÑαÑπßΓá¡«ó¿Γ∞        }
                 CMP  AX, DI                { ΓÑ¬πΘ¿⌐ »α«µÑßß               }
                 JNE  @SetProcess           {}
                 MOV  ES, HeadStack.word[2] { HeadStack -> ES:DI            }
                 MOV  DI, HeadStack.word[0] {}
                 MOV  PCurTask.word[2], ES  { ES:DI -> PCurTask             }
                 MOV  PCurTask.word[0], DI  {}
 @SetProcess:    MOV  AX, ES:[DI]           { NumProc -> AX                 }
                 MOV  CurTask, AX           {}
                 CLI                        {}
                 MOV  SS, ES:[DI+8]         { »ÑαÑπßΓá¡«ó¬á ßΓÑ¬á           }
                 MOV  SP, ES:[DI+6]         {}
                 STI                        {}
                 POP  BP                    { ó«ßßΓá¡«ó½Ñ¡¿Ñ αÑú¿ßΓα«ó      }
                 POP  ES                    { »α«µÑßßá                      }
                 POP  DS                    {}
 @Exit:
end;

procedure HaltAllTasks; assembler;
{ --- ß¡∩Γ¿Ñ óßÑσ ºáñáτ --- }
asm
    { 1) Äí¡π½Ñ¡¿Ñ óßÑσ »ÑαÑ¼Ñ¡¡δσ;
      2) ôñá½Ñ¡¿Ñ «τÑαÑñ¿ »α«µÑßß«ó ß« ßΓÑ¬á¼¿;
      3) ôßΓá¡«ó¬á SS:SP «ß¡«ó¡«⌐ »α«úαá¼¼δ ¿ RETF ó ¡ÑÑ. }
                 MOV  AX, SEG @Data         { ó«ßßΓá¡áó½¿óáÑ¼ ßÑú¼Ñ¡Γ DS    }
                 MOV  DS, AX                {}
                 XOR  AX, AX                { PCurTask=Nil                  }
                 MOV  PCurTask.word[0], AX  {}
                 MOV  PCurTask.word[2], AX  {}
                 CLI                        {}
                 MOV  SS, OriginalSS        { ó«ßßΓá¡áó½¿óáÑ¼ ßΓÑ¬ »α«úαá¼¼δ}
                 MOV  SP, OriginalSP        {}
                 STI                        {}
 @Loop:          XOR  AX, AX                {}
                 CMP  AX, CountTask         { ß¼«Γα¿¼ ÑßΓ∞ ½¿ »α«µÑßßδ      }
                 JE   @StackEmpty           { Ñß½¿ ¡ÑΓ óδσ«ñ                }
                 MOV  ES, HeadStack.word[2] { ó ES:DI π¬áºáΓÑ½∞ ¡á »Ñαóδ⌐   }
                 MOV  DI, HeadStack.word[0] { φ½Ñ¼Ñ¡Γ «τÑαÑñ¿ »α«µÑßß«ó     }
                 MOV  DX, ES:[DI+4]         { DX:BX π¬áºáΓÑ½∞ ¡á ß½ÑñπεΘ¿⌐  }
                 MOV  BX, ES:[DI+2]         { φ½Ñ¼Ñ¡Γ ßΓÑ¬á ¿½¿ Nil         }
                 MOV  HeadStack.word[2], DX { HeadStack = DX:BX             }
                 MOV  HeadStack.word[0], BX {}
                 MOV  AX, ES:[DI+12]        { ó AX:CX π¬áºáΓÑ½∞ ¡á ßΓÑ¬     }
                 MOV  CX, ES:[DI+10]        { »α«µÑßßá                      }
                 PUSH ES                    { ú«Γ«ó¿¼ ßΓÑ¬ ñ½∩ óδº«óá »α«µÑ-}
                 PUSH DI                    { ñπαδ «τ¿ßΓ¬¿ »á¼∩Γ¿           }
                 PUSH AX                    { AX:CX - π¬áºáΓÑ½∞ ¡á ßΓÑ¬     }
                 PUSH CX                    { »α«µÑßßá                      }
                 MOV  AX, ES:[DI+14]        { ó AX αáº¼Ñα ßΓÑ¬á             }
                 PUSH AX                    {}
                 CALL mFreeMem              { π¡¿τΓ«ªáÑ¼ ßΓÑ¬ »α«µÑßßá      }
                 MOV  AX, TYPE TTaskRec     { ó AX αáº¼Ñα «»¿ßáΓÑ½∩ »α«µÑßßá}
                 PUSH AX                    {}
                 CALL mFreeMem              { π¡¿τΓ«ªáÑ¼ «»¿ßáΓÑ½∞ »α«µÑßßá }
                 MOV  AX, CountTask         { ñÑ¬αÑ¼Ñ¡Γ¿απÑ¼ CountTask      }
                 DEC  AX                    {}
                 MOV  CountTask, AX         {}
                 JMP  @Loop                 { π¡¿τΓ«ªáΓ∞ ß½ÑñπεΘ¿⌐ »α«µÑßß  }
 @StackEmpty:    MOV  CurTask, AX           { CurTask=0                     }
end;

{----------------------------------------------------------------}
end.
