     /*-                                                                            +
      * Copyright (c) 2004-2023 Scott C. Klement                                    +
      * All rights reserved.                                                        +
      *                                                                             +
      * Redistribution and use in source and binary forms, with or without          +
      * modification, are permitted provided that the following conditions          +
      * are met:                                                                    +
      * 1. Redistributions of source code must retain the above copyright           +
      *    notice, this list of conditions and the following disclaimer.            +
      * 2. Redistributions in binary form must reproduce the above copyright        +
      *    notice, this list of conditions and the following disclaimer in the      +
      *    documentation and/or other materials provided with the distribution.     +
      *                                                                             +
      * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ''AS IS'' AND      +
      * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       +
      * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE  +
      * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE     +
      * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  +
      * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS     +
      * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)       +
      * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT  +
      * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY   +
      * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF      +
      * SUCH DAMAGE.                                                                +
      *                                                                             +
      */                                                                            +
      /copy VERSION

     H DFTACTGRP(*NO)

     FCONFIGS   CF   E             WORKSTN sfile(CONFIG2S: WKRRN2)
     F                                     sfile(CONFIG3S: WKRRN3)
     FSRCPF     UF   F  112        DISK    USROPN

      /copy HTTPAPI_H

     D QCMDEXC         PR                  ExtPgm('QCMDEXC')
     D   command                    200A   const
     D   length                      15P 5 const

     D WKRRN2          s              4P 0
     D WKRRN3          s              4P 0
     D wkVersion       s                   like(scVersion)
     D wkPos           s             10I 0
     D Teraspace       s              1a   inz(*OFF)

     ISRCPF     NS
     I                                 13   90  WKLINE

     c     *entry        plist
     c                   parm                    peVersion         6
     c                   parm                    peCancel          1
     c                   parm                    peBldSSL          1
     c                   parm                    peBldSamp         1
     c                   parm                    peBldExpat        1
     c                   parm                    peBldXml          1
     c                   parm                    peSrcLib         10
     c                   parm                    peInstLib        10
     c                   parm                    peUseLibl         1
     c                   parm                    peBldNtlm         1

     c                   eval      peCancel = 'N'
     c                   eval      *inlr = *on

     C****************************************************************
     C* Load the LICENSE member onto the screen
     C****************************************************************
     c                   callp     QCMDEXC('OVRDBF FILE(SRCPF) '
     c                                    +      ' TOFILE(QRPGLESRC) '
     c                                    +      ' MBR(LICENSE)'
     c                                    : 200)

     c                   open      SRCPF
     c                   read(N)   SRCPF

     c                   dow       not %eof(SRCPF)
     c                   eval      wkRRN2 = wkRRN2 + 1
     c                   eval      scLine = wkLine
     c                   write     CONFIG2S
     c                   read(N)   SRCPF
     c                   enddo

     c                   close     SRCPF
     c                   callp     QCMDEXC('DLTOVR FILE(SRCPF)'
     c                                    : 200)

     C****************************************************************
     C* Load the eXpat COPYING member onto the screen
     C****************************************************************
     c                   callp     QCMDEXC('OVRDBF FILE(SRCPF) '
     c                                    +      ' TOFILE(EXPAT) '
     c                                    +      ' MBR(COPYING)'
     c                                    : 200)

     c                   open      SRCPF
     c                   read(N)   SRCPF

     c                   dow       not %eof(SRCPF)
     c                   eval      wkRRN3 = wkRRN3 + 1
     c                   eval      scLine = wkLine
     c                   write     CONFIG3S
     c                   read(N)   SRCPF
     c                   enddo

     c                   close     SRCPF
     c                   callp     QCMDEXC('DLTOVR FILE(SRCPF)'
     c                                    : 200)

     C****************************************************************
     c* Display License
     C****************************************************************
     c                   dou       *INKH = *ON

     c                   write     CONFIG2F
     c                   exfmt     CONFIG2C

     c                   if        *INKC = *ON
     c                   eval      peCancel = 'Y'
     c                   return
     c                   endif

     c                   enddo

     C****************************************************************
     c* Set up defaults for options screen
     C****************************************************************
     c                   eval      wkVersion = 'Version ' + HTTPAPI_VERSION
     c                                   +   ' Released ' + HTTPAPI_RELDATE
     c                   eval      wkPos = %size(scVersion)/2
     c                                   - %len(%trimr(wkVersion))/2
     c                                   + 1
     c                   eval      %subst(scVersion:wkPos) = wkVersion

     c                   eval      scBldSamp = 'Y'
     c                   eval      scBldSSL =  'N'
     c                   eval      scBldExpat = 'N'
     c                   eval      scBldXml = 'N'

      /if defined(HAVE_SSLAPI)
     c                   eval      scBldSSL = 'Y'
      /endif

     c                   if        peVersion < 'V4R5M0'
     c                   eval      scBldSSL = 'N'
     c                   endif

     c                   if        peVersion >= 'V5R1M0'
     c                   eval      scBldExpat = 'Y'
     c                   eval      scBldXml = 'Y'
     c                   endif

     C****************************************************************
     C* display options screen
     C****************************************************************
     c                   dou       (scBldSamp='Y' or scBldSamp='N')
     c                             and (scBldSSL='Y' or scBldSSL='N')

     c                   exfmt     CONFIGS1
     c                   if        *INKC = *ON
     c                   eval      peCancel = 'Y'
     c                   return
     c                   endif

     c                   enddo

     C****************************************************************
     C* display XML options screen
     C****************************************************************
     c                   dou       (scBldXML='Y' or scBldXML='N')
     c                             and (scBldExpat='Y' or scBldExpat='N')

     c                   exfmt     CONFIGS4
     c                   if        *INKC = *ON
     c                   eval      peCancel = 'Y'
     c                   return
     c                   endif

     c                   enddo

     C****************************************************************
     c* Display eXpat License if selected
     C****************************************************************
     c                   if        scBldExpat = 'Y'

     c                   dou       *INKH = *ON

     c                   write     CONFIG3F
     c                   exfmt     CONFIG3C

     c                   if        *INKC = *ON
     c                   eval      peCancel = 'Y'
     c                   return
     c                   endif

     c                   enddo

     c                   endif

     C****************************************************************
     c* Ask for source/installation libraries
     C****************************************************************
     c                   eval      scSrcLib = peSrcLib
     c                   eval      scInstLib = peInstLib
     c                   eval      scUseLibl = 'Y'

     c                   dou       scMsg = *blanks

     c                   exfmt     CONFIGS5
     c                   eval      scMsg = *blanks

     c                   if        *INKC = *ON
     c                   eval      peCancel = 'Y'
     c                   return
     c                   endif

     c                   if        scUseLibl<>'Y' and scUseLibl<>'N'
     C                   eval      scMsg = 'Use *LIBL must be Y or N'
     c                   endif

     c                   if        scSrcLib <> '*LIBL'
     c                   callp(e)  QCMDEXC('CHKOBJ OBJ(' + %trim(scSrcLib)
     c                                    + ') OBJTYPE(*LIB)': 200)
     c                   if        %error
     c                   eval      scMsg = 'Library ' + %trim(scSrcLib)
     c                                   + ' not found.'
     c                   endif
     c                   endif

     c                   if        scInstLib <> '*CURLIB'
     c                   callp(e)  QCMDEXC('CHKOBJ OBJ(' + %trim(scInstLib)
     c                                    + ') OBJTYPE(*LIB)': 200)
     c                   if        %error
     c                   eval      scMsg = 'Library ' + %trim(scInstLib)
     c                                   + ' not found.'
     c                   endif
     c                   endif

     c                   enddo


     C****************************************************************
     C* modify CONFIG_H according to SSL build info & version
     C****************************************************************
     c                   callp     QCMDEXC('OVRDBF FILE(SRCPF) '
     c                                    +      ' TOFILE(QRPGLESRC) '
     c                                    +      ' MBR(CONFIG_H)'
     c                                    : 200)

     c                   open      SRCPF
     c                   read      SRCPF

     c                   dow       not %eof(SRCPF)

     c                   if        %scan('HAVE_SSLAPI': wkLine) > 0
     c                   if        scBldSSL = 'Y'
     c                   eval      wkLine = '     D/define HAVE_SSLAPI'
     c                   else
     c                   eval      wkLine = '     D/undefine HAVE_SSLAPI'
     c                   endif
     c                   except    updconfig
     c                   endif

     c                   if        %scan('HAVE_INT64': wkLine) > 0
     c                   if        peVersion >= 'V4R4M0'
     c                   eval      wkLine = '     D/define HAVE_INT64'
     c                   else
     c                   eval      wkLine = '     D/undefine HAVE_INT64'
     c                   endif
     c                   except    updconfig
     c                   endif

     c                   if        %scan('HAVE_SRCSTMT_NODEBUGIO':wkLine)>0
     c                   if        peVersion >= 'V4R4M0'
     c                   eval      wkLine = '     D/define HAVE_SRC' +
     c                                      'STMT_NODEBUGIO'
     c                   else
     c                   eval      wkLine = '     D/undefine HAVE_SRC' +
     c                                      'STMT_NODEBUGIO'
     c                   endif
     c                   except    updconfig
     c                   endif

     c                   if        %scan('V4R5_GSKIT':wkLine)>0
     c                   if        peVersion <= 'V4R5M0' and scBldSSL='Y'
     c                   eval      wkLine = '     D/define V4R5_GSKIT'
     c                   else
     c                   eval      wkLine = '     D/undefine V4R5_GSKIT'
     c                   endif
     c                   except    updconfig
     c                   endif

     c                   if        %scan('V5R3_GSKIT':wkLine)>0
     c                   if        peVersion >= 'V5R3M0' and scBldSSL='Y'
     c                   eval      wkLine = '     D/define V5R3_GSKIT'
     c                   else
     c                   eval      wkLine = '     D/undefine V5R3_GSKIT'
     c                   endif
     c                   except    updconfig
     c                   endif

     c                   if        %scan('NTLM_SUPPORT': wkLine)>0
     c                   if        peVersion >= 'V5R3M0'
     c                   eval      wkLine = '     D/define NTLM_SUPPORT'
     c                   eval      peBldNtlm = 'Y'
     c                   else
     c                   eval      wkLine = '     D/undefine NTLM_SUPPORT'
     c                   eval      peBldNtlm = 'N'
     c                   endif
     c                   except    updconfig
     c                   endif

     c                   if        ( %subst(wkLine:7:2)='/d'
     c                             or %subst(wkLine:7:2) = '/D' )
     c                   if        %scan('TERASPACE': wkLine)>0
     c                   eval      Teraspace = *on
     c                   endif
     c                   endif

     c                   if        %scan('USE_TS_MALLOC64':wkLine)>0
     c                   if        peVersion<'V5R2M0' or Teraspace=*off
     c                   eval      wkLine = '     D/undefine '
     c                                    + 'USE_TS_MALLOC64'
     c                   else
     c                   eval      wkLine = '     D/define '
     c                                    + 'USE_TS_MALLOC64'
     c                   endif
     c                   except    updconfig
     c                   endif

     c                   if        %scan('HTTP_USE_CCSID':wkLine)>0
     c                   if        peVersion >= 'V5R1M0'
     c                   eval      wkLine = '     D/define HTTP_USE_CCSID'
     c                   else
     c                   eval      wkLine = '     D/undefine HTTP_USE_CCSID'
     c                   endif
     c                   except    updconfig
     c                   endif

     c                   read      SRCPF
     c                   enddo

     c                   close     SRCPF
     c                   callp     QCMDEXC('DLTOVR FILE(SRCPF)'
     c                                    : 200)

     C****************************************************************
     C* modify CONFIG_H according to SSL build info & version
     C****************************************************************
     c                   callp     QCMDEXC('OVRDBF FILE(SRCPF) '
     c                                    +      ' TOFILE(QRPGLESRC) '
     c                                    +      ' MBR(HTTPAPI_H)'
     c                                    : 200)

     c                   open      SRCPF
     c                   read      SRCPF

     c                   dow       not %eof(SRCPF)

     c                   if        %scan('qrpglesrc,config_h':wkLine)>0
     c                   if        scSrcLib <> *blanks
     c                   eval      wkLine = '      /copy '
     c                                    + %trim(scSrcLib) + '/'
     c                                    + 'qrpglesrc,config_h'
     c                   except    updconfig
     c                   endif
     c                   endif

     c                   read      SRCPF
     c                   enddo

     c                   close     SRCPF
     c                   callp     QCMDEXC('DLTOVR FILE(SRCPF)'
     c                                    : 200)

     C****************************************************************
     C* return parameters
     C****************************************************************
     c                   eval      peBldSSL   = scBldSSL
     c                   eval      peBldSamp  = scBldSamp
     c                   eval      peCancel   = 'N'
     c                   eval      peBldExpat = scBldExpat
     c                   eval      peBldXml   = scBldXml
     c                   eval      peSrcLib   = scSrcLib
     c                   eval      peInstLib  = scInstLib
     c                   eval      peUseLibl  = scUseLibl
     c                   return

     OSRCPF     E            updconfig
     O                       wkLine              90
