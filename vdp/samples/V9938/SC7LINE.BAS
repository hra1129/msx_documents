100 DEFINTA-Z:COLOR15,4,7:SCREEN7:C(0)=&HC4:C(1)=&H4C
110 FORY=0TO211:X=Y\2:GOSUB130:NEXT
120 GOTO120
130 A!=(X\2)+(Y*256):VPOKEA!,C(XAND1):RETURN