100 DEFINTA-Z:COLOR15,0,0
110 SCREEN5
120 FORI=0TO15:COLOR=(I,0,0,0):NEXT
130 BLOAD"WAVEBACK.SR5",S
140 COLOR=( 8,7,0,0):COLOR=( 9,6,0,1):COLOR=(10,5,0,2):COLOR=(11,4,0,3):COLOR=(12,3,0,4):COLOR=(13,2,0,5):COLOR=(14,1,0,6):COLOR=(15,0,0,7)
150 COLOR=( 9,7,0,0):COLOR=(10,6,0,1):COLOR=(11,5,0,2):COLOR=(12,4,0,3):COLOR=(13,3,0,4):COLOR=(14,2,0,5):COLOR=(15,1,0,6):COLOR=( 8,0,0,7)
160 COLOR=(10,7,0,0):COLOR=(11,6,0,1):COLOR=(12,5,0,2):COLOR=(13,4,0,3):COLOR=(14,3,0,4):COLOR=(15,2,0,5):COLOR=( 8,1,0,6):COLOR=( 9,0,0,7)
170 COLOR=(11,7,0,0):COLOR=(12,6,0,1):COLOR=(13,5,0,2):COLOR=(14,4,0,3):COLOR=(15,3,0,4):COLOR=( 8,2,0,5):COLOR=( 9,1,0,6):COLOR=(10,0,0,7)
180 COLOR=(12,7,0,0):COLOR=(13,6,0,1):COLOR=(14,5,0,2):COLOR=(15,4,0,3):COLOR=( 8,3,0,4):COLOR=( 9,2,0,5):COLOR=(10,1,0,6):COLOR=(11,0,0,7)
190 COLOR=(13,7,0,0):COLOR=(14,6,0,1):COLOR=(15,5,0,2):COLOR=( 8,4,0,3):COLOR=( 9,3,0,4):COLOR=(10,2,0,5):COLOR=(11,1,0,6):COLOR=(12,0,0,7)
200 COLOR=(14,7,0,0):COLOR=(15,6,0,1):COLOR=( 8,5,0,2):COLOR=( 9,4,0,3):COLOR=(10,3,0,4):COLOR=(11,2,0,5):COLOR=(12,1,0,6):COLOR=(13,0,0,7)
210 COLOR=(15,7,0,0):COLOR=( 8,6,0,1):COLOR=( 9,5,0,2):COLOR=(10,4,0,3):COLOR=(11,3,0,4):COLOR=(12,2,0,5):COLOR=(13,1,0,6):COLOR=(14,0,0,7)
220 GOTO 140