Unit BitOper;
{$F+,O+}
Interface

Function GetBit(a,n: byte):byte;              { é«ºóαáΘáÑΓ º¡áτÑ¡¿Ñ n-«ú« í¿Γá
}
Function SetBitZero(a,n:byte):byte;                      { æíαáßδóáÑΓ n-δ⌐ í¿Γ
}
Function SetBitOne(a,n:byte):byte;                    { ôßΓá¡áó½¿óáÑΓ n-δ⌐ í¿Γ
}

Implementation

Function GetBit(a,n: byte):byte;              { é«ºóαáΘáÑΓ º¡áτÑ¡¿Ñ n-«ú« í¿Γá
}
Begin
    GetBit:=1 and (a shr n);
End;

Function SetBitZero(a,n:byte):byte;                      { æíαáßδóáÑΓ n-δ⌐ í¿Γ
}
Begin
    SetBitZero:=a and (not(1 shl n));
End;

Function SetBitOne(a,n:byte):byte;                    { ôßΓá¡áó½¿óáÑΓ n-δ⌐ í¿Γ
}
Begin
    SetBitOne:=a or (1 shl n);
End;

End.
