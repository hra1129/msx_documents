100 CLEAR100,&HD7FF:SCREEN1:DEFINTA-Z
110 FORI=0TO&H44:READD:POKE&HD800+I,D:NEXT
120 DEFUSR0=&HD800:A=USR(0)
130 END
140 DATA &H3E,&H04,&HCD,&H5F,&H00,&H3E,&H01,&H32,&HAF,&HFC,&H21,&HBF,&H1B,&H11,&H00,&H00
150 DATA &H01,&H00,&H08,&HCD,&H5C,&H00,&H21,&HBF,&H1B,&H11,&H00,&H08,&H01,&H00,&H08,&HCD
160 DATA &H5C,&H00,&H21,&HBF,&H1B,&H11,&H00,&H10,&H01,&H00,&H08,&HCD,&H5C,&H00,&H21,&H00
170 DATA &H20,&H3E,&HF4,&H01,&H00,&H18,&HCD,&H56,&H00,&H21,&H00,&H18,&H3E,&H20,&H01,&H00
180 DATA &H03,&HCD,&H56,&H00,&HC9
