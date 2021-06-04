c  ftn test.f  /usr/local/lib/spicelib.a -o test.e
c JRW 04 Jun 2021: Delivered by R. Gaskell 30 Jan 2021. Converts PDS IMG DTM to BIGMAP

      IMPLICIT NONE

      INTEGER               BTMP
      PARAMETER            (BTMP=2501)

      DOUBLE PRECISION     RPD
      DOUBLE PRECISION     VDOT
      DOUBLE PRECISION     LAT
      DOUBLE PRECISION     LON
      DOUBLE PRECISION     V(3)
      DOUBLE PRECISION     W(3)
      DOUBLE PRECISION     W1(3)
      DOUBLE PRECISION     UX(3)
      DOUBLE PRECISION     UY(3)
      DOUBLE PRECISION     UZ(3)
      DOUBLE PRECISION     VSIG(3)
      DOUBLE PRECISION     R0
      DOUBLE PRECISION     SCALE
      DOUBLE PRECISION     Z1, Z2, Z3
      REAL*4               HT(-BTMP:BTMP,-BTMP:BTMP)
      REAL*4               TMPL(-BTMP:BTMP,-BTMP:BTMP,3)
      INTEGER              I, J
      INTEGER              QSZ
      CHARACTER*6          BIGMAP
      CHARACTER*72         INFILE
      CHARACTER*72         LMRKFILE
      LOGICAL              FOUND
      LOGICAL              HUSE(-BTMP:BTMP,-BTMP:BTMP)

      WRITE(6,*) 'InputIMG file'
      READ(5,FMT='(A72)') INFILE
      WRITE(6,*) 'Input 6 character BIGMAP name'
      READ(5,FMT='(A6)') BIGMAP
      WRITE(6,*) 'Input ltd, elng (deg)'
      READ(5,*) Z1, Z2
      CALL LATREC(1.D0,Z2*RPD(),Z1*RPD(), W)
      CALL VHAT(W,UZ)
      CALL ORIENT(UX,UY,UZ)
      WRITE(6,*) 'scale, qsz, R0' 
      READ(5,*) SCALE, QSZ, R0
      CALL LATREC(R0,Z2*RPD(),Z1*RPD(), V)
      DO I=-QSZ,QSZ
      DO J=-QSZ,QSZ
        HUSE(I,J)=.TRUE.
        FOUND=.FALSE.
        TMPL(I,J,1)=0
        TMPL(I,J,2)=0
        TMPL(I,J,3)=0
        W(1)=V(1)+(I*UY(1)+J*UX(1))*SCALE
        W(2)=V(2)+(I*UY(2)+J*UX(2))*SCALE
        W(3)=V(3)+(I*UY(3)+J*UX(3))*SCALE
        CALL RECLAT(W,Z3,Z2,Z1)
        LAT=Z1/RPD()
        LON=Z2/RPD()
        CALL IMGLATLONVEC(INFILE,LAT,LON,W1,FOUND)
        IF(FOUND) THEN
          HT(I,J)=(VDOT(W1,UZ)-R0)/SCALE
          W(1)=V(1)+(I*UY(1)+J*UX(1)+HT(I,J)*UZ(1))*SCALE
          W(2)=V(2)+(I*UY(2)+J*UX(2)+HT(I,J)*UZ(2))*SCALE
          W(3)=V(3)+(I*UY(3)+J*UX(3)+HT(I,J)*UZ(3))*SCALE
          CALL RECLAT(W,Z3,Z2,Z1)
          LAT=Z1/RPD()
          LON=Z2/RPD()
          CALL IMGLATLONVEC(INFILE,LAT,LON,W1,FOUND)
          IF(FOUND) THEN
            HT(I,J)=(VDOT(W1,UZ)-R0)/SCALE
          ENDIF
        ENDIF
        IF(.NOT.FOUND) HUSE(I,J)=.FALSE.
      ENDDO
      ENDDO
      VSIG(1)=SCALE
      VSIG(2)=SCALE
      VSIG(3)=SCALE

      IF(HUSE(0,0)) THEN
        Z1=HT(0,0)
        DO I=-QSZ,QSZ
        DO J=-QSZ,QSZ
          IF(HUSE(I,J)) HT(I,J)=HT(I,J)-REAL(Z1)
        ENDDO
        ENDDO
        V(1)=V(1)+Z1*SCALE*UZ(1)
        V(2)=V(2)+Z1*SCALE*UZ(2)
        V(3)=V(3)+Z1*SCALE*UZ(3)
      ENDIF

      LMRKFILE='./MAPFILES/'//BIGMAP//'.MAP'
      CALL WRITE_MAP(LMRKFILE,BTMP,QSZ,SCALE,
     .                     V,VSIG,UX,UY,UZ,HT,HUSE,TMPL)

      STOP
      END

c  ...................................................
      SUBROUTINE IMGLATLONVEC(INFILE,LAT,LON,V,FOUND)
c  ...................................................

      IMPLICIT NONE

      DOUBLE PRECISION     RPD
      DOUBLE PRECISION     LAT
      DOUBLE PRECISION     LON
      DOUBLE PRECISION     V(3)
      DOUBLE PRECISION     R0
      DOUBLE PRECISION     PXPDEG
      DOUBLE PRECISION     MNLAT, MXLAT
      DOUBLE PRECISION     MNLON, MXLON
      DOUBLE PRECISION     CPIC(2)
      DOUBLE PRECISION     B0, B1, B2, B3
      DOUBLE PRECISION     X, Y, R
      DOUBLE PRECISION     Z1
      INTEGER              I
      INTEGER              J
      INTEGER              RB
      INTEGER              NPX
      INTEGER              NLN
      CHARACTER*72         INFILE
      CHARACTER*50000      LINE
      LOGICAL              FOUND
      LOGICAL              READFLAG

      CHARACTER*4          CH4
      REAL*4               RL4
      EQUIVALENCE         (CH4,RL4)

      INTEGER*4            IFF
      SAVE                 IFF, R0, PXPDEG, MXLAT, MNLON,
     .                     RB, NPX, NLN 
      DATA                 IFF/0/

      IF(IFF.EQ.0) THEN
        IFF=1
        RB=50000
        OPEN(UNIT=10,FILE=INFILE,RECL=50000,ACCESS='DIRECT', 
     .       STATUS='OLD')
          READ(10,REC=1) LINE
          I=0
          READFLAG=.TRUE.
10        I=I+1
          IF(LINE(I:I+1).EQ.'/*') READFLAG=.FALSE.
          IF(LINE(I:I+1).EQ.'*/') READFLAG=.TRUE.
          IF(.NOT.READFLAG) GO TO 10
          IF(LINE(I:I+11).EQ.'RECORD_BYTES') THEN
            J=0
            DO WHILE (LINE(I+11+J:I+11+J).NE.'=')
              J=J+1
            ENDDO
            READ(LINE(I+12+J:50000),*) RB
            GO TO 10
          ENDIF
          IF(LINE(I:I+4).EQ.'LINES') THEN
            J=0
            DO WHILE (LINE(I+4+J:I+4+J).NE.'=')
              J=J+1
            ENDDO
            READ(LINE(I+5+J:50000),*) NLN
            GO TO 10
          ENDIF
          IF(LINE(I:I+11).EQ.'LINE_SAMPLES') THEN
            J=0
            DO WHILE (LINE(I+11+J:I+11+J).NE.'=')
              J=J+1
            ENDDO
            READ(LINE(I+12+J:50000),*) NPX
            GO TO 10
          ENDIF
          IF(LINE(I:I+12).EQ.'A_AXIS_RADIUS') THEN
            J=0
            DO WHILE (LINE(I+12+J:I+12+J).NE.'=')
              J=J+1
            ENDDO
            READ(LINE(I+13+J:50000),*) R0
            GO TO 10
          ENDIF
          IF(LINE(I:I+13).EQ.'MAP_RESOLUTION') THEN
            J=0
            DO WHILE (LINE(I+13+J:I+13+J).NE.'=')
              J=J+1
            ENDDO
            READ(LINE(I+14+J:50000),*) PXPDEG
            GO TO 10
          ENDIF
          IF(LINE(I:I+15).EQ.'MAXIMUM_LATITUDE') THEN
            J=0
            DO WHILE (LINE(I+15+J:I+15+J).NE.'=')
              J=J+1
            ENDDO
            READ(LINE(I+16+J:50000),*) MXLAT
            GO TO 10
          ENDIF
          IF(LINE(I:I+15).EQ.'MINIMUM_LATITUDE') THEN
            J=0
            DO WHILE (LINE(I+15+J:I+15+J).NE.'=')
              J=J+1
            ENDDO
            READ(LINE(I+16+J:50000),*) MNLAT
            GO TO 10
          ENDIF
          IF(LINE(I:I+20).EQ.'EASTERNMOST_LONGITUDE') THEN
            J=0
            DO WHILE (LINE(I+20+J:I+20+J).NE.'=')
              J=J+1
            ENDDO
            READ(LINE(I+21+J:50000),*) MXLON
            GO TO 10
          ENDIF
          IF(LINE(I:I+20).EQ.'WESTERNMOST_LONGITUDE') THEN
            J=0
            DO WHILE (LINE(I+20+J:I+20+J).NE.'=')
              J=J+1
            ENDDO
            READ(LINE(I+21+J:50000),*) MNLON
            GO TO 10
          ENDIF
          IF(I.LT.RB) GO TO 10
        CLOSE(UNIT=10)
        WRITE(6,FMT='(3I10)') NPX, NLN, RB
        WRITE(6,FMT='(2F15.2)') R0, PXPDEG
        WRITE(6,FMT='(2F15.2)') MNLAT, MXLAT
        WRITE(6,FMT='(2F15.2)') MNLON, MXLON
      ENDIF

      X=1+(LON-MNLON)*PXPDEG
      IF(X.LT.1) X=1+(LON+360-MNLON)*PXPDEG
      Y=1+(MXLAT-LAT)*PXPDEG
      FOUND=.TRUE.
      IF((X.LT.1).OR.(X.GE.NPX).OR.(Y.LT.1).OR.(Y.GE.NLN)) THEN
        FOUND=.FALSE.
        V(1)=0.D0
        V(2)=0.D0
        V(3)=0.D0
        RETURN
      ENDIF

      I=INT(X)
      J=INT(Y)
      OPEN(UNIT=10,FILE=INFILE,RECL=RB,ACCESS='DIRECT', STATUS='OLD')
        READ(10,REC=J+1) LINE(1:RB)
        CH4=LINE(4*I-3:4*I)
        B0=RL4
        CH4=LINE(4*I+1:4*I+4)
        B1=RL4
        READ(10,REC=J+2) LINE(1:RB)
        CH4=LINE(4*I-3:4*I)
        B2=RL4
        CH4=LINE(4*I+1:4*I+4)
        B3=RL4
      CLOSE(UNIT=10)
      Z1=20000
      IF((ABS(B0).GT.Z1).OR.(ABS(B1).GT.Z1).OR.
     .   (ABS(B2).GT.Z1).OR.(ABS(B3).GT.Z1)) THEN
        FOUND=.FALSE.
        V(1)=0.D0
        V(2)=0.D0
        V(3)=0.D0
        RETURN
      ENDIF
      B3=B0-B1-B2+B3
      B1=B1-B0
      B2=B2-B0
      X=X-I
      Y=Y-J
      R=R0+(B0+B1*X+B2*Y+B3*X*Y)/1000
      V(1)=R*COS(LON*RPD())*COS(LAT*RPD())
      V(2)=R*SIN(LON*RPD())*COS(LAT*RPD())
      V(3)=R*SIN(LAT*RPD())

      RETURN
      END

C$Procedure
 
      SUBROUTINE WRITE_MAP(LMRKFILE,NTMP,QSZ,SCALE,
     .                     V,VSIG,UX,UY,UZ,HT,HUSE,TMPL)

C$ Abstract
C     This subroutine will create a mapfile <LMRKFILE>.
C
C     The mapfile is made up of 72 byte records.  The first record contains
C     information describing the size, scale, orientation and position of the 
C     map:
C
C     bytes 1-6   Unused
C     bytes 7-10  Scale in km/pixel (real*4 msb)
C     bytes 11-12 qsz where map is 2*qsz+1 x 2*qsz+1 pixels (unsigned short lsb) 
C     bytes 16-27 map center body fixed position vector in km 3 x (real*4 msb)
C     bytes 28-39 Ux body fixed unit map axis vector 3 x (real*4 msb)
C     bytes 40-51 Uy body fixed unit map axis vector 3 x (real*4 msb)
C     bytes 52-63 Uz body fixed unit map normal vector 3 x (real*4 msb)
C     bytes 64-67 Hscale = maximum abs(height)/30000 (real*4 msb)          *
C     byte 13     255* X position uncertainty unit vector component (byte) +
C     byte 14     255* Y position uncertainty unit vector component (byte) +
C     byte 15     255* Z position uncertainty unit vector component (byte) +
C     bytes 68-71 magnitude of position uncertainty (real*4 msb)           +
C     byte 72     Unused 
C 
C     * heights are in units of map scale
C     + these are pretty much unused as far as I can see. 
C
C     The remaining records are made up of 3 byte chunks:
C
C     bytes 1-2   height/hscale (integer*2 msb)
C     byte 3      relative "albedo" (1-199) (byte)
C
C     If there is missing data at any point, both height and albedo
C     are set to zero.
C
C     The map array is filled row by row from the upper left (i,j = -qsz).
C     Rows are increasing in the Uy direction with spacing = scale
C     Columns are increasing in the Ux direction with spacing = scale
C     Heights are positive in the Uz direction with units = scale
C
C$ Disclaimer
C     None
C
C$ Required_Reading
C
C     R.W. Gaskell, et.al, "Characterizing and navigating small bodies
C           with imaging data", Meteoritics & Planetary Science 43,
C           Nr 6, 1049-1061 (2008)
C
C
C$ Declarations

      IMPLICIT NONE
      
      INTEGER*2             IX2
      INTEGER*2             I2
      INTEGER               NTMP
      INTEGER               QSZ
      INTEGER               I
      INTEGER               II
      INTEGER               J
      INTEGER               K
      INTEGER               NREC
      INTEGER               MAPVERS

      DOUBLE PRECISION      VNORM
      DOUBLE PRECISION      SCALE
      DOUBLE PRECISION      V(3)
      DOUBLE PRECISION      VSIG(3)
      DOUBLE PRECISION      UX(3)
      DOUBLE PRECISION      UY(3)
      DOUBLE PRECISION      UZ(3)
      DOUBLE PRECISION      Z1

      REAL*4                HT(-NTMP:NTMP,-NTMP:NTMP)
      REAL*4                TMPL(-NTMP:NTMP,-NTMP:NTMP,3)
      REAL*4                HSCALE
      REAL*4                RL4

      CHARACTER*1           CH1
      CHARACTER*2           CH2, CH2F
      CHARACTER*2           C2
      CHARACTER*4           CH4, CH4F
      CHARACTER*72          BLINE
      CHARACTER*72          LMRKFILE
      CHARACTER*80          LINE

      LOGICAL               HUSE(-NTMP:NTMP,-NTMP:NTMP)
      LOGICAL               LFLAG
      LOGICAL               EX

      EQUIVALENCE          (IX2,CH2)
      EQUIVALENCE          (RL4,CH4)
      EQUIVALENCE          (I2,C2)
 
C$ Variable_I/O
C
C     Variable  I/O  Description
C     --------  ---  --------------------------------------------------
C     LMRKFILE   I   Basename of the maplet file to write to
C     NTMP       I
C     QSZ        I   Map size/2
C     SCALE      I   Scale of Map in km
C     V          I   
C     VSIG       I   Uncertainties in V vector values
C     UX         I   X unit vector
C     UY         I   Y unit vector
C     UZ         I   Z unit vector
C     HT         I   Height
C     HUSE       I   Use flag
C     TMPL       I   Map values
C
C$ File_I/O
C
C     Filename                      I/O  Description
C     ----------------------------  ---  -------------------------------
C     <LMRKFILE>                     O   Map file that will be created 
C                                        or updated.
C
C$ Restrictions
C     None
C
C$ Software_Documentation
C
C     OSIRIS-REx Stereophotoclinometry Software Design Document
C     OSIRIS-REx Stereophotoclinometry Software User's Guide
C
C$ Author_and_Institution
C
C     R.W. Gaskell    (PSI)
C
C$ Version
C
C
C
C$ SPC_functions_called
C     None
C
C$ SPC_subroutines_called
C     FLIP
C
C$ SPICELIB_functions_called
C     VNORM
C
C$ SPICELIB_subroutines_called
C     None
C
C$ Called_by_SPC_Programs
C     LITHOS
C

C     check for big/little endian format and set LFLAG 
      C2='69'
      LFLAG=.TRUE.
      IF(I2.EQ.13881) LFLAG=.FALSE.

C     set map version for a new map 

      MAPVERS=0
      OPEN(UNIT=25,FILE='INIT_LITHOS.TXT',STATUS='OLD')
13      CONTINUE
        READ(25,FMT='(A80)') LINE
        IF(LINE(1:3).NE.'END') THEN
          IF(LINE(1:8).EQ.'MAPVERS=') READ(LINE(9:80),*) MAPVERS
          GO TO 13
        ENDIF 
      CLOSE(UNIT=25)

c     if map already exists, preserve its version.
c     if old version = -1 preserve bytes 1-6.

      INQUIRE(FILE=LMRKFILE, EXIST=EX)
      IF(EX) THEN
        OPEN(UNIT=10,FILE=LMRKFILE,ACCESS='DIRECT',
     .       RECL=72,STATUS='UNKNOWN')
          READ(10,REC=1) BLINE
        CLOSE(UNIT=10)
        K=ICHAR(BLINE(72:72))
        IF(K.LE.127) THEN
          DO K=1,6
            BLINE(K:K)=CHAR(0)
          ENDDO
        ENDIF
      ELSE
        DO K=1,6
          BLINE(K:K)=CHAR(0)
        ENDDO
        IF(MAPVERS.LT.0) MAPVERS=MAPVERS+256
        BLINE(72:72)=CHAR(MAPVERS)
      ENDIF

C     Open any old map file of the same name and 
C     delete it, then open a new file for writing
      OPEN(UNIT=10,FILE=LMRKFILE,STATUS='UNKNOWN')
      CLOSE(UNIT=10,STATUS='DELETE')
      OPEN(UNIT=10,FILE=LMRKFILE,ACCESS='DIRECT',
     .     RECL=72,STATUS='UNKNOWN')

C     Configure BLINE for the 1st record of the map file
C     and write it to file (this is mostly header info)
      RL4=SNGL(SCALE)
      CALL FLIP(4,LFLAG,CH4,CH4F)
      BLINE(7:10)=CH4F
      BLINE(11:11)=CHAR(QSZ-256*(QSZ/256))  !!!*
      BLINE(12:12)=CHAR(QSZ/256)
      RL4=SNGL(VNORM(VSIG))
      CALL FLIP(4,LFLAG,CH4,CH4F)
      BLINE(68:71)=CH4F
      BLINE(13:13)=CHAR(NINT(255*VSIG(1)/RL4))
      BLINE(14:14)=CHAR(NINT(255*VSIG(2)/RL4))
      BLINE(15:15)=CHAR(NINT(255*VSIG(3)/RL4))
      DO K=1,3
        RL4=SNGL(V(K))
        CALL FLIP(4,LFLAG,CH4,CH4F)
        BLINE(12+4*K:15+4*K)=CH4F
        RL4=SNGL(UX(K))
        CALL FLIP(4,LFLAG,CH4,CH4F)
        BLINE(24+4*K:27+4*K)=CH4F
        RL4=SNGL(UY(K))
        CALL FLIP(4,LFLAG,CH4,CH4F)
        BLINE(36+4*K:39+4*K)=CH4F
        RL4=SNGL(UZ(K))
        CALL FLIP(4,LFLAG,CH4,CH4F)
        BLINE(48+4*K:51+4*K)=CH4F
      ENDDO
      Z1=0.D0
      DO J=-QSZ,QSZ
        DO I=-QSZ,QSZ
          IF(HUSE(I,J)) THEN
            Z1=MAX(Z1,ABS(HT(I,J)))
          ENDIF
        ENDDO
      ENDDO
      HSCALE=SNGL(Z1/30000)
      RL4=HSCALE
      CALL FLIP(4,LFLAG,CH4,CH4F)
      BLINE(64:67)=CH4F
      NREC=1
      WRITE(10,REC=NREC) BLINE
      K=0

C     For each point in the map
      DO J=-QSZ,QSZ
        DO I=-QSZ,QSZ

C         If height exists scale II = "albedo" between 1 and 199        
          IF(HUSE(I,J)) THEN
            II=NINT(100*(1+TMPL(I,J,3)))
            II=MAX(1,II)
            II=MIN(199,II)

C         else set height and II to zero
          ELSE
            HT(I,J)=0
            II=0
          ENDIF
          K=K+1
          IX2=INT2(NINT(HT(I,J)/HSCALE))
          CH1=CHAR(II)
          CALL FLIP(2,LFLAG,CH2,CH2F)
          BLINE(3*K-2:3*K-1)=CH2F
          BLINE(3*K:3*K)=CH1

C         If 24 values have been processed the next record has been
C         complete and will be written to file
          IF(K.EQ.24) THEN
            NREC=NREC+1
            WRITE(10, REC=NREC) BLINE
            DO K=1,72
              BLINE(K:K)=CHAR(0)
            ENDDO
            K=0
          ENDIF
        ENDDO
      ENDDO

C     Write out final record of map file
      IF(K.NE.0) THEN
        NREC=NREC+1
        WRITE(10, REC=NREC) BLINE
      ENDIF
      CLOSE(UNIT=10)

      RETURN
      END     

C$Procedure
 
      SUBROUTINE FLIP(N,LFLAG,CH1,CH2)

C$ Abstract
C     The subroutine will change the endian of the N byte 
C     variable CH1 and return the value in CH2 if the logical
C     variable is set to true, else the CH1 value is returned
C     in CH2.  The calling routine analyzes the hardware 
C     architecture and set the LFLAG based on the analysis.
C
C$ Disclaimer
C     None
C
C$ Required_Reading
C
C     R.W. Gaskell, et.al, "Characterizing and navigating small bodies
C           with imaging data", Meteoritics & Planetary Science 43,
C           Nr 6, 1049-1061 (2008)
C
C
C$ Declarations
 
      INTEGER*4        N, I
      CHARACTER*(*)    CH1, CH2
      LOGICAL          LFLAG
 
C$ Variable_I/O
C
C     Variable  I/O  Description
C     --------  ---  --------------------------------------------------
C     N          I   Number of bytes
C     LFLAG      I   Logical flag set to TRUE if flip is to be done
C     CH1        O   Input variable to be operated on
C     CH2        O   Returned value of the operation
C
C$ File_I/O
C
C     Filename                      I/O  Description
C     ----------------------------  ---  -------------------------------
C     None 
C
C$ Restrictions
C     None 
C
C$ Software_Documentation
C
C     OSIRIS-REx Stereophotoclinometry Software Design Document
C     OSIRIS-REx Stereophotoclinometry Software User's Guide
C
C$ Author_and_Institution
C
C     R.W. Gaskell    (PSI)
C
C$ Version
C
C
C
C$ SPC_functions_called
C     None 
C
C$ SPC_subroutines_called
C     None 
C
C$ SPICELIB_functions_called
C     None 
C
C$ SPICELIB_subroutines_called
C     None 
C
C$ Called_by_SPC_Programs
C     AUTOREGISTERP
C     LITHOSP
C     POLE
C     SHIFT
C     DENSIFY
C     DENSIFYA
C     SPHEREMAPSA
C     SPHEREMAPSB
C

C     If LFLAG is TRUE then change the endian of the input var
      IF(LFLAG) THEN
        DO I=1,N
          CH2(I:I)=CH1(N-I+1:N-I+1)
        ENDDO
C     Else do nothing and return the input var in the output var        
      ELSE
        CH2=CH1
      ENDIF      
      
      RETURN
      END

C$Procedure
 
      SUBROUTINE ORIENT(UX,UY,UZ)

C$ Abstract
C     This routine will generate a set of x, y, z 3 dimensional unit
C     vectors from the set of x, y, z three dimensional unit supplied
C     by the calling program.  The output values will over write the
C     input values.
C
C$ Disclaimer
C     None
C
C$ Required_Reading
C
C     R.W. Gaskell, et.al, "Characterizing and navigating small bodies
C           with imaging data", Meteoritics & Planetary Science 43,
C           Nr 6, 1049-1061 (2008)
C
C$ Declarations
 
      IMPLICIT NONE

      DOUBLE PRECISION      UX(3)
      DOUBLE PRECISION      UY(3)
      DOUBLE PRECISION      UZ(3)
 
C$ Variable_I/O
C
C     Variable  I/O  Description
C     --------  ---  --------------------------------------------------
C     UX         I   3 dimensional x vector
C     UY         I   3 dimensional y vector
C     UZ         I   3 dimensional z vector
C     UX         O   3 dimensional x unit vector
C     UY         O   3 dimensional y unit vector
C     UZ         O   3 dimensional x unit vector
C
C$ File_I/O
C
C     Filename                      I/O  Description
C     ----------------------------  ---  -------------------------------
C     None
C
C$ Restrictions
C     None
C
C$ Software_Documentation
C
C     OSIRIS-REx Stereophotoclinometry Software Design Document
C     OSIRIS-REx Stereophotoclinometry Software User's Guide
C
C$ Author_and_Institution
C
C     R.W. Gaskell    (PSI)
C
C$ Version
C
C
C
C$ SPC_functions_called
C     None
C
C$ SPC_subroutines_called
C     None
C
C$ SPICELIB_functions_called
C     None
C
C$ SPICELIB_subroutines_called
C     VHAT
C     UCRSS
C
C$ Called_by_SPC_Programs
C     LITHOS
C     BIGMAP
C     BIGMAPL
C     SUBROUTINE CREATE_LMFILE
C

C     If 3rd component of z vector is > 1
C     set z vector = (0,0,1) and y vector 
C     normal to z vector at (0,1,0)
      IF(UZ(3).GT.(0.9998)) THEN
        UZ(1)=0
        UZ(2)=0
        UZ(3)=1
        UY(1)=0
        UY(2)=1
        UY(3)=0
      ELSE
C     Else if 3rd component of z vector is < -1
C     set z vector = (0,0,-1) and y vector 
C     normal to z vector at (0,1,0)
        IF(UZ(3).LT.(-0.9998)) THEN
          UZ(1)=0
          UZ(2)=0
          UZ(3)=-1
          UY(1)=0
          UY(2)=1
          UY(3)=0
C       Else 3rd component of z vector is between 1 & -1
C       set y vector component to be orthogonal to z
        ELSE
          UY(1)=-UZ(2)
          UY(2)=+UZ(1)                               
          UY(3)=0
C         Call SPICE toolkit routine to convert UY to unit vector 
          CALL VHAT(UY,UY)
        ENDIF
      ENDIF
C     Call SPICE toolkit routine to generate an orthogonal vector UX
C     to both UY and UZ 
      CALL UCRSS(UY,UZ,UX)

      RETURN
      END

 
