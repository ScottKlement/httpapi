     /*-                                                                            +
      * Copyright (c) 2004-2024 Scott C. Klement                                    +
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

      /if defined(HAVE_SRCSTMT_NODEBUGIO)
     H OPTION(*SRCSTMT: *NOSHOWCPY)
      /endif
     H NOMAIN

      /define HTTP_ORIG_SOAPACTION
      /copy httpapi_h
      /copy private_h
      /copy ifsio_h
      /copy errno_h
      /copy socket_h

      /if defined(HTTP_USE_CCSID)
     D CCSID_OR_CP     S             10I 0 inz(O_CCSID)
      /else
     D CCSID_OR_CP     S             10I 0 inz(O_CODEPAGE)
      /endif

     D wkDbg           s             10I 0 inz(-1)
     D wkDbgProc       s               *   procptr inz(*NULL)
     D wkDbgUData      s               *   inz(*NULL)
     D wkDbgCln        s              1N   inz(*on)
     D wkDbgFail       s              1N   inz(*off)
     D wkErrorNo       S             10I 0
     D wkRespCode      S             10I 0
     D wkErrorMsg      S             80A
     D HTTP_DEBUG_LEVEL...
     D                 s             10i 0 inz(1)
     D totAlloc        s             20u 0 inz(0)
     D upper           C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D lower           C                   'abcdefghijklmnopqrstuvwxyz'

     D memset          PR              *   ExtProc('memset')
     D   ptr                           *   value
     D   value                       10I 0 value
     D   length                      10U 0 value
     D strrchr         PR              *   ExtProc('strrchr')
     D   dst                           *   value
     D   char                        10U 0 value

     D debug_proc      PR                  extproc(wkDbgProc)
     D   peData                        *   value
     D   peLen                       10I 0 value
     D   peUserData                    *   value

     D globalOpts      ds                  qualified
     D   timeout                     10i 0 inz(HTTP_TIMEOUT)
     D   modTime                       Z   inz(*loval)
     D   use_cookies                  1n   inz(*on)
     D   local_ccsid                 10i 0 inz(HTTP_EBCDIC)
     D   net_ccsid                   10i 0 inz(HTTP_ASCII)
     D   file_ccsid                  10i 0 inz(HTTP_CCSID)
     D   file_mode                   10i 0 inz(HTTP_IFSMODE)
     D   timeout100                  10i 0 inz(0)
     D   debugLevel                  10i 0 inz(1)
     D   contentType              16384a   varying inz(HTTP_CONTTYPE)
     D   soapActSet                   1n   inz(*off)
     D   soapAction               32768a   varying inz('')
     D   userAgent                16384a   varying inz(HTTP_USERAGENT)
     D   acceptHdr                 4096a   varying inz('')

      /if defined(DEBUG)
     D wkDebug         s              1N   inz(*ON)
      /else
     D wkDebug         s              1N   inz(*OFF)
      /endif

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * util_Diag():
      *   This sends a debugging/diagnostic message (a *DIAG message)
      *   with MSGID CPF9897 to the program's job log.
      *
      *   peMsgTxt   = (input) Text of message to send
      *
      * Returns *OFF if it failed, *ON upon success
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P util_Diag       B                   export
     D util_Diag       PI             1N
     D   peMsgTxt                   256A   const

     D wwMsgLen        S             10I 0
     D wwTheKey        S              4A

     c                   callp     http_dmsg(peMsgTxt)

     c     ' '           checkr    peMsgTxt      wwMsgLen
     c                   if        wwMsgLen<1
     c                   return    *OFF
     c                   endif

     c                   callp     QMHSNDPM( 'CPF9897'
     c                                     : 'QCPFMSG   *LIBL'
     c                                     : peMsgTxt
     c                                     : wwMsgLen
     c                                     : '*DIAG'
     c                                     : '*'
     c                                     : 1
     c                                     : wwTheKey
     c                                     : ApiEscape )
     c                   return    *on
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * debug_setproc:  set a new debugging procedure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P debug_setproc   B                   export
     D debug_setproc   PI
     D   peProc                        *   procptr value
     D   peUserData                    *   value
     c                   eval      wkDbgProc = peProc
     c                   eval      wkDbgUData = peUserData
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_dclose: close current debugging log file
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_dclose     B                   export
     D http_dclose     PI
     c                   if        wkDbg >= 0
     c                   callp     close(wkDbg)
     c                   eval      wkDbg = -1
     c                   endif
     c                   eval      wkDbgFail = *off
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_dwrite()
      *   Write debugging data to the debug log file (off by default)
      *
      *   peData = (input) data to write to debugging log.
      *            should be in ASCII and you need to supply your
      *            own CR/LF stuff.
      *    peLen = (input) length of data to write
      *
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_dwrite     B                   export
     D http_dwrite     PI
     D   peData                        *   value
     D   peLen                       10I 0 value

     D ErrDbg          c                   const('Unable to open -
     D                                     debug file ')
     D CharErr         ds
     D   NumErr                       4s 0
     D MsgKey          s              4a

     D CRLF            C                   x'0d25'
     D wwBuf           s            100A
     D wwLen           s             10I 0
      /if defined(NTLM_SUPPORT)
      /define COPYRIGHT_DSPEC
      /copy NTLM_C
      /endif

     c                   if        wkDebug = *OFF
     c                   return
     c                   endif

     c                   if        wkDbgProc <> *NULL
     c                   callp     debug_proc(peData: peLen: wkDbgUData)
     c                   return
     c                   endif

     c                   if        wkDbg < 0
     c                   eval      wkDbg = open( HTTP_DEBUG_FILE
     c                                         : O_CREAT+O_APPEND+O_WRONLY
     c                                           + CCSID_OR_CP
     c                                         : 511
     c                                         : FILE_CCSID )
     c                   if        wkDbg = -1 and wkDbgFail = *Off
     c                   eval      wkDbgFail = *on
     c                   eval      NumErr = errno
     c                   callp     QMHSNDPM( 'CPE' + CharErr
     c                                     : 'QCPFMSG   *LIBL'
     c                                     : ' '
     c                                     : 0
     c                                     : '*DIAG'
     c                                     : '*'
     c                                     : 0
     c                                     : MsgKey
     c                                     : ApiEscape )
     c                   callp     QMHSNDPM( 'CPF9897'
     c                                     : 'QCPFMSG   *LIBL'
     c                                     : ErrDbg + HTTP_DEBUG_FILE
     c                                     : %len(ErrDbg+HTTP_DEBUG_FILE)
     c                                     : '*DIAG'
     c                                     : '*'
     c                                     : 0
     c                                     : MsgKey
     c                                     : ApiEscape )
     c                   endif
     c                   eval      wwBuf = 'HTTPAPI Ver ' + HTTPAPI_VERSION
     c                                     + ' released ' + HTTPAPI_RELDATE
     c                                     + CRLF
     c                   eval      wwLen = %len(%trimr(wwBuf))
     c                   callp     http_xlate(wwLen: wwBuf: TO_ASCII)
     c                   callp     write(wkDbg: %addr(wwBuf): wwLen)
      /if defined(NTLM_SUPPORT)
     c                   eval      wwBuf = 'NTLM Ver ' + cNTLM_VERSION
     c                                     + ' released ' + cNTLM_DATE
     c                                     + CRLF
     c                   eval      wwLen = %len(%trimr(wwBuf))
     c                   callp     http_xlate(wwLen: wwBuf: TO_ASCII)
     c                   callp     write(wkDbg: %addr(wwBuf): wwLen)
      /endif
     c                   eval      wwBuf = 'OS/400 Ver ' + OS_Release
     c                                     + CRLF + CRLF
     c                   eval      wwLen = %len(%trimr(wwBuf))
     c                   callp     http_xlate(wwLen: wwBuf: TO_ASCII)
     c                   callp     write(wkDbg: %addr(wwBuf): wwLen)
     c                   endif
     c                   if        wkDbg >= 0
     c                   callp     write(wkDbg: peData: peLen)
     c                   eval      wkDbgCln = *off
     c                   endif

     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_dmsg()
      *    Add a diagnostic message to the debugging log
      *
      *    peMsgTxt = message to add to log.  Should be EBCDIC
      *         with no CR/LF needed.
      *
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_dmsg       B                   export
     D http_dmsg       PI
     D   peMsgTxt                   256A   const

     D wwMsg           s            288A
     D wwMsgLen        s             10I 0

     c                   if        wkDebug = *OFF
     c                   return
     c                   endif

     c                   if        wkDbgCln = *Off
     c                   eval      %subst(wwMsg:1:2) = x'0d0a'
     c                   callp     http_dwrite(%addr(wwMsg): 2)
     c                   endif

     c                   if        HTTP_DEBUG_LEVEL > 1
     c                   eval      wwMsg = %char(%timestamp()) + ': '
     c                                   + %trimr(peMsgTxt) + x'0d25'
     c                   else
     c                   eval      wwMsg = %trimr(peMsgTxt) + x'0d25'
     c                   endif

     c                   eval      wwMsgLen = %len(%trimr(wwMsg))
     c                   callp     http_xlate(wwMsgLen: wwMsg: TO_ASCII)

     c                   callp     http_dwrite(%addr(wwMsg): wwMsgLen)
     c                   eval      wkDbgCln = *on

     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * md5():
      *   Calculate an MD5 digest for a string
      *
      *      peData = pointer to data to create a digest for
      *   peDataLen = length of data that you're pointing to
      *    peDigest = (output) digest value in hex
      *
      * Returns *OFF if it failed, *ON upon success
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P md5             B                   export
     D md5             PI             1N
     D   peData                        *   value
     D   peDataLen                   10I 0 value
     D   peDigest                    32A

     D FUNCT_HASH      C                   const(5)
     D HASHALG_MD5     C                   const(x'00')
     D HASHALG_SHA1    C                   const(x'01')

     D dsCtrl          DS
     D  dsCtrl_Funct                  5I 0
     D  dsCtrl_HashAlg...
     D                                1A
     D  dsCtrl_Seq                    1A
     D  dsCtrl_Len                   10I 0
     D  dsCtrl_Resrvd                 8A   inz(*loval)
     D  dsCtrl_CtxPtr                  *

     D cipher          PR                  extproc('_CIPHER')
     D  receiver                       *   value
     D  control                        *   value
     D  source                         *   value

     D cvthc           PR                  EXTPROC('cvthc')
     D  output                       32A
     D  input                        16A
     D  output_len                   10I 0 value

     D wwDigest        S             16A
     D wwWorkArea      S             96A   inz(*loval)
     D p_Receiver      S               *
     D p_Data          S               *
     D wwData          S              1A   based(p_data)

     c                   eval      dsCtrl_Funct = FUNCT_HASH
     c                   eval      dsCtrl_HashAlg = HASHALG_MD5
     c                   eval      dsCtrl_Seq = x'00'
     c                   eval      dsCtrl_Len = peDataLen
     c                   eval      dsCtrl_CtxPtr = %addr(wwWorkArea)
     c                   eval      p_receiver = %addr(wwDigest)
     c                   eval      p_data = peData

     c                   callp     http_xlate(peDataLen: wwData: TO_ASCII)

     c                   callp(e)  cipher(%addr(p_Receiver):
     c                                    %addr(dsCtrl):
     c                                    %addr(peData))
     c                   if        %error
     c                   callp     util_diag('Call to MI built-in ' +
     c                                   '_CIPHER failed!')
     c                   return    *OFF
     c                   endif

     c                   callp(e)  cvthc(peDigest:wwDigest:%size(peDigest))
     c                   if        %error
     c                   callp     util_diag('Error converting char ' +
     c                                'to hex (shouldnt happen!)')
     c                   return    *OFF
     c                   endif

     c     upper:lower   xlate     peDigest      peDigest

     c                   return    *ON
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This takes an RPG timestamp and converts it to an 'HTTP-date'
      *  as defined by RFC 2616 (the RFC for HTTP/1.1)
      *
      *          input: z'2001-10-18-12:46:05.824000'
      *         output: Thu, 18 Oct 2001 12:46:05 GMT
      *
      * This does not have a provision for returning an error, since a
      * timestamp _must_ be a valid time already.  (cross your fingers)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P httpdate        B                   export
     d httpdate        PI            29A
     d  peTS                           Z   const

     D                 ds
     D   dsStr                 1     19A
     D   dsTS                  1     26Z
     D   YYYY                  1      4
     D   MM                    6      7
     D   DD                    9     10
     D   HHMMSS               12     19

     D SUNDAY          C                   d'1899-12-31'

     D wwDate          s               D
     D wwDays          s             10i 0
     D wwJunk          s             10i 0
     D wwDOW           s             10i 0
     D wwStr           S             29A
     D wwSecs          S              8F

     D Month           s              3a
     D Day             s              3a

     c                   callp     http_dmsg('httpdate(): entered')

     c                   eval      dsTS = peTS

     c                   move      peTS          wwDate
     C     wwDate        subdur    SUNDAY        wwDays:*DAYS
     c     wwDays        div       7             wwJunk
     c                   mvr                     wwDOW

     C                   select
     c                   when      MM = '01'
     c                   eval      Month = 'Jan'
     c                   when      MM = '02'
     c                   eval      Month = 'Feb'
     c                   when      MM = '03'
     c                   eval      Month = 'Mar'
     c                   when      MM = '04'
     c                   eval      Month = 'Apr'
     c                   when      MM = '05'
     c                   eval      Month = 'May'
     c                   when      MM = '06'
     c                   eval      Month = 'Jun'
     c                   when      MM = '07'
     c                   eval      Month = 'Jul'
     c                   when      MM = '08'
     c                   eval      Month = 'Aug'
     c                   when      MM = '09'
     c                   eval      Month = 'Sep'
     c                   when      MM = '10'
     c                   eval      Month = 'Oct'
     c                   when      MM = '11'
     c                   eval      Month = 'Nov'
     c                   when      MM = '12'
     c                   eval      Month = 'Dec'
     c                   endsl

     C                   select
     c                   when      wwDOW = 0
     c                   eval      Day = 'Sun'
     c                   when      wwDOW = 1
     c                   eval      Day = 'Mon'
     c                   when      wwDOW = 2
     c                   eval      Day = 'Tue'
     c                   when      wwDOW = 3
     c                   eval      Day = 'Wed'
     c                   when      wwDOW = 4
     c                   eval      Day = 'Thu'
     c                   when      wwDOW = 5
     c                   eval      Day = 'Fri'
     c                   when      wwDOW = 6
     c                   eval      Day = 'Sat'
     c                   endsl

     C     '.':':'       xlate     HHMMSS        HHMMSS

     C                   eval      wwStr = Day + ', '
     C                                   + DD + ' ' + Month + ' ' + YYYY
     C                                   + ' ' + HHMMSS + ' GMT'
     c                   return    wwStr
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This is called by other procedures to set an error message
      *   that calling applications can retrieve with HTTP_ERROR
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SetError        B                   export
     d SetError        PI
     d   peErrorNo                   10I 0 value
     d   peErrorMsg                  80A   const
     c                   callp     http_dmsg('SetError() #' +
     c                                  %trim(%editc(peErrorNo:'L')) +
     c                                  ': '+ peErrorMsg)
     c                   eval      wkErrorNo = peErrorNo
     c                   eval      wkErrorMsg = peErrorMsg
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This is called internally to set the last HTTP response code
      *  it can be retrieved via HTTP_error()
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SetRespCode     B                   export
     d                 PI
     d   peRespCode                  10I 0 value
     c                   select
     c                   when      peRespCode = 1
     c                   eval      wkRespCode = 200
     c                   when      peRespCode <= 0
     c                   eval      wkRespCode = 0
     c                   other
     c                   eval      wkRespCode = peRespCode
     c                   endsl
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_error():   Return the last error that occurred.
      *
      *     peErrorNo = (optional) error number that occurred.
      *    peRespCode = (optional) HTTP response code (if applicable)
      *
      *  Returns the human-readable error message.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_error      B                   export
     D http_error      PI            80A
     D   peErrorNo                   10I 0 options(*nopass:*omit)
     D   peRespCode                  10I 0 options(*nopass:*omit)
     c                   if        %parms>=1 and %addr(peErrorNo)<>*Null
     c                   eval      peErrorNo = wkErrorNo
     c                   endif
     c                   if        %parms>=2 and %addr(peRespCode)<>*null
     c                   eval      peRespCode = wkRespCode
     c                   endif
     c                   return    wkErrorMsg
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_debug():  Turn debugging info *ON or *OFF
      *
      *      peStatus = (input) status (either *ON or *OFF)
      *
      *    peFilename = (input/optional) filename that debug info will be
      *                    written to.  If not defined, the value from
      *                    CONFIG_H is used.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_debug      B                   export
     D http_debug      PI
     D   peStatus                     1N   const
     D   peFilename                 500A   varying const options(*nopass)

     D NumErr          s             10i 0

     c                   eval      wkDebug = peStatus

     c                   if        %parms >= 2
     c                   eval      HTTP_DEBUG_FILE = %trimr(peFilename)
     c                   endif

     c                   callp     http_dclose

     c                   if        peStatus = *ON
     c                   if        unlink(HTTP_DEBUG_FILE) < 0
     c                   eval      NumErr = errno
     c                   if        errno <> ENOENT
     c                   callp     util_diag('Unlink debug file failed +
     c                             with errno=' + %char(NumErr))
     c                   endif
     c                   endif
     c                   endif
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_comp(): Send a completion message
      *
      *      peMessage = message to send.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_comp       B                   export
     D http_comp       PI
     D   peMessage                  256A   const

     D wwTheKey        S              4A

     c                   callp     QMHSNDPM( 'CPF9897'
     c                                     : 'QCPFMSG   *LIBL'
     c                                     : peMessage
     c                                     : %len(%trimr(peMessage))
     c                                     : '*COMP'
     c                                     : '*CTLBDY'
     c                                     : 1
     c                                     : wwTheKey
     c                                     : ApiEscape )
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_diag(): Send a diagnostic message
      *
      *      peMessage = message to send.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_diag       B                   export
     D http_diag       PI
     D   peMessage                  256A   const

     D wwTheKey        S              4A

     c                   callp     QMHSNDPM( 'CPF9897'
     c                                     : 'QCPFMSG   *LIBL'
     c                                     : peMessage
     c                                     : %len(%trimr(peMessage))
     c                                     : '*DIAG'
     c                                     : '*PGMBDY'
     c                                     : 1
     c                                     : wwTheKey
     c                                     : ApiEscape )
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_crash(): Send back an *ESCAPE message containing last
      *               error found in HTTPAPI.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_crash      B                   export
     D http_crash      PI

     D wwMsg           s             80A
     D wwTheKey        S              4A
     c                   eval      wwMsg = http_error

     c                   callp     QMHSNDPM( 'CPF9897'
     c                                     : 'QCPFMSG   *LIBL'
     c                                     : wwMsg
     c                                     : %len(%trimr(wwMsg))
     c                                     : '*ESCAPE'
     c                                     : '*CTLBDY'
     c                                     : 1
     c                                     : wwTheKey
     c                                     : ApiEscape )
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_tempfile():  Generate a unique temporary IFS file name
      *
      * returns the file name
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_tempfile   B                   export
     D http_tempfile   PI            40A   varying

     D tmpnam          PR              *   extproc('_C_IFS_tmpnam')
     D   string                      39A   options(*omit)
     d filename        s             40A   varying

     C                   eval      filename = %str(tmpnam(*omit))
     c                   return    filename
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * xalloc(): Allocate memory
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P xalloc          B                   export
     D xalloc          PI              *
     D   size                        20p 0 value
     D ptr             s               *
      /if defined(TERASPACE)
     C                   eval      ptr = TS_malloc(size)
      /else
     C                   alloc     size          ptr
      /endif
      /if defined(MEMCOUNT)
     C                   eval      totalloc += 1
      /endif
     C                   return    ptr
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * xdealloc(): de-allocate memory
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P xdealloc        B                   export
     D xdealloc        PI
     D   ptr                           *
      /if defined(TERASPACE)
     C                   callp     ts_free(ptr)
      /else
     C                   dealloc                 ptr
      /endif
      /if defined(MEMCOUNT)
     C                   eval      totalloc -= 1
      /endif
     C                   eval      ptr = *null
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * xrealloc(): re-allocate memory
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P xrealloc        B                   export
     D xrealloc        PI              *
     D   ptr                           *   value
     D   size                        20p 0 value
      /if defined(MEMCOUNT)
     c                   if        ptr = *null
     c                   eval      totalloc += 1
     c                   endif
      /endif
      /if defined(TERASPACE)
     c                   if        ptr = *null
     c                   eval      ptr = ts_malloc(size)
     c                   else
     C                   eval      ptr = ts_realloc(ptr: size)
     c                   endif
      /else
     c                   if        ptr = *null
     c                   alloc     size          ptr
     c                   else
     C                   realloc   size          ptr
     c                   endif
      /endif
     C                   return    ptr
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * OS_Release():  Get the version of i5/OS or OS/400 that's running
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P OS_Release      B                   export
     D OS_Release      PI             6a

     D QSZRTVPR        PR                  extpgm('QSZRTVPR')
     D   RcvVar                            like(PRDR0100)
     D   RcvVarLen                   10i 0 const
     D   Format                       8a   const
     D   ProdInfo                          like(PRDINFO)
     D   errCode                      8a   const

     D PRDINFO         DS
     D   f1                           7a   inz('*OPSYS')
     D   f2                           6a   inz('*CUR'  )
     D   f3                           4a   inz('0000'  )
     D   f4                          10a   inz('*CODE' )

     D PRDR0100        DS            32
     D   Release              20     26a

     C                   callp     QSZRTVPR( PRDR0100
     C                                     : %size(PRDR0100)
     C                                     : 'PRDR0100'
     C                                     : PRDINFO
     C                                     : x'00000000' )
     C                   return    Release
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * log the current status of a socket to the debug log
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P socket_status   B                   export
     D                 PI
     D   routine                     50a   varying const
     D   point                       50a   varying const
     D   fd                          10i 0 value

     D cvthc           PR                  EXTPROC('cvthc')
     D  output                        8A
     D  input                        10i 0
     D  output_len                   10I 0 value

     D flags           s             10i 0
     D blocking        s              1n
     D hexflags        s              8a
     D msg             s            256a

     c                   eval      flags = fcntl(fd: F_GETFL)
     c                   callp     cvthc( hexflags: flags: %size(hexflags))
     c                   eval      blocking = (%bitand(flags:O_NONBLOCK) = 0)

     c                   eval      msg = %trim(routine) + '(): '
     c                                 + %trim(point) + ' '
     c                                 + 'socket fd=' + %char(fd)
     c                                 + ', flags=' + %trim(hexflags)
     c                                 + ', blocking=' + blocking
     c                   callp     http_dmsg(msg)

     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * log the current status of select() API details to debug log
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P select_status   B                   export
     D                 PI
     D   routine                     50a   varying const
     D   point                       50a   varying const
     D   fd                          10i 0 value
     D   rset                          *   value
     D   wset                          *   value
     D   eset                          *   value
     D   timeout                       *   value
     D   rc                          10i 0 value options(*nopass)

     D cvthc           PR                  EXTPROC('cvthc')
     D  output                       56a   options(*varsize)
     D  input                          *   value
     D  output_len                   10I 0 value

     D rdeschex        s             56a
     D wdeschex        s                   like(rdeschex)
     D edeschex        s                   like(rdeschex)
     D timehex         s             16a
     D msg             s            256a

     c                   callp     socket_status( routine: point: fd )

     c                   if        rset = *null
     c                   eval      rdeschex = '*NULL'
     c                   else
     c                   callp     cvthc( rdeschex: rset: %size(rdeschex) )
     c                   endif

     c                   if        wset = *null
     c                   eval      wdeschex = '*NULL'
     c                   else
     c                   callp     cvthc( wdeschex: wset: %size(wdeschex) )
     c                   endif

     c                   if        eset = *null
     c                   eval      edeschex = '*NULL'
     c                   else
     c                   callp     cvthc( edeschex: eset: %size(edeschex) )
     c                   endif

     c                   if        timeout = *null
     c                   eval      timehex = '*NULL'
     c                   else
     c                   callp     cvthc( timehex: timeout: %size(timehex) )
     c                   endif

     c                   eval      msg = %trim(routine) + '(): '
     c                                 + %trim(point)   + ': '
     c                                 + 'select fd='   + %char(fd)
     c                                 + ', readset='   + %trimr(rdeschex)
     c                                 + ', writeset='  + %trimr(wdeschex)
     c                                 + ', excpset='   + %trimr(edeschex)
     c                                 + ', timeval='   + %trimr(timehex)

     c                   if        %parms >= 8
     c                   eval      msg = %trimr(msg) +', rc=' + %char(rc)
     c                   endif

     c                   callp     http_dmsg(msg)
     p                 e


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HTTP_setDebugLevel(): Set the debug log level
      *
      *    peDbgLvl = (input) new level to use
      *                1 = Normal
      *                2 = More detailed comm timeout/performance info
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P HTTP_setDebugLevel...
     P                 B                   export
     D                 PI
     D    peDbgLvl                   10i 0 value
     C                   eval      HTTP_DEBUG_LEVEL = peDbgLvl
     C                   eval      globalOpts.debugLevel = peDbgLvl
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  returns the current HTTP_DEBUG_LEVEL value
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P getDebugLevel...
     P                 B                   export
     D                 PI            10i 0
     C                   return    HTTP_DEBUG_LEVEL
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_setOption():  Sets an HTTP option used on subsequent requests
      *
      *   option = (input) option string to set
      *    value = (input) value of option string
      *
      * possible options are:
      *
      * 'timeout' = numeric value.  If this many seconds pass without
      *             any network activity, the request is aborted.
      *
      * 'SoapAction' = Value to be placed in the HTTP "soap-action" header
      *             used when calling web services with the SOAP protocol
      *
      * 'content-type' = When uploading a stream in a POST or PUT request,
      *             this specifies the data type you're sending
      *
      * 'user-agent' = overrides the user-agent string sent to the HTTP
      *             server. This allows you to test servers that require a
      *             particular browser (such as IE or Chrome)
      *
      * '100-timeout' = time to wait for a '100 Continue' response when
      *             sending a request body (such as a POST/PUT request).
      *             Value should be a number of seconds.
      *
      * 'use-cookies' = indicates whether cookie support in HTTPAPI is
      *             enabled or not.  Value should be '1' for enabled or
      *             '0' for disabled.
      *
      * 'local-ccsid' = CCSID to use for your local machine when text data
      *             needs to be translated.  Value should be a number from
      *             1-65533 or the special value '0' for "current job ccsid".
      *             Usually this is some form of EBCDIC.
      *
      * 'network-ccsid' = CCSID to to use for the data sent over the network
      *             to remote sites.  Value should be a number from 1-65533.
      *             Typically this should be 1208 (UTF-8) or for older sites,
      *             some form of ASCII.
      *
      * 'file-ccsid' = When a new file is created in the IFS, HTTPAPI will
      *             assign this CCSID. Value should be a number from 1-65533.
      *             HTTPAPI does not use this to translate the data, it only
      *             puts this in the file description.
      *
      * 'file-mode' = When a new file is created in the IFS, HTTPAPI will
      *             use this parameter as the file's "mode" (authorities).
      *             Value should be a number, same as the 3rd parameter to
      *             the IFS open() API.
      *
      * 'debug-level' = Number indicating the amount of detail written to
      *             the debug/trace file that httpapi creates when you use
      *             the http_debug(*on) feature.  1=Normal, 2=Mode Detailed
      *
      * 'if-modified-since' = value should be a timestamp in *ISO char
      *                  format.  On a GET request, the file will only
      *                  be retrieved if it has changed since this date/time.
      *
      * 'accept' = Media types that you are willing to accept in response
      *                  to an HTTP request
      *
      *returns 0 if successful, -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_setOption  B                   export
     D                 PI            10i 0
     D    option                     32a   varying const
     D    value                   65535a   varying const
     D                                     options(*varsize)
     D opt             s                   like(option)
     D rc              s             10i 0 inz(0)

      /free
       p_global = %addr(globalopts);

       opt = %xlate( 'abcdefghijklmnopqrstuvwxyz'
                   : 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                   : option );

       monitor;

          select;
          when opt = 'TIMEOUT';
             global.timeout = %int(value);
          when opt = 'SOAP-ACTION' or opt = 'SOAPACTION';
             global.soapAction = value;
             global.soapActSet = *ON;
          when opt = 'CONTENT-TYPE';
             global.contentType = value;
          when opt = 'IF-MODIFIED-SINCE';
             global.modTime = %timestamp(value:*iso);
          when opt = 'USER-AGENT';
             global.userAgent = value;
          when opt = '100-TIMEOUT';
             global.timeout100 = %dec( value: 10: 3);
          when opt = 'USE-COOKIES';
             if value='0';
                global.use_cookies = *off;
             else;
                global.use_cookies = *on;
             endif;
          when opt = 'LOCAL-CCSID';
             global.local_ccsid = %int(value);
             rc = HTTP_setCCSIDs( global.net_ccsid
                                : global.local_ccsid );
          when opt = 'NETWORK-CCSID';
             global.net_ccsid = %int(value);
             rc = HTTP_setCCSIDs( global.net_ccsid
                                : global.local_ccsid );
          when opt = 'FILE-CCSID';
             global.file_ccsid = %int(value);
             HTTP_setFileCCSID(global.file_ccsid);
          when opt = 'FILE-MODE';
             global.file_mode = %int(value);
             // FIXME: Used elsewhere, too
          when opt = 'DEBUG-LEVEL';
             HTTP_setDebugLevel(%int(value));
          when opt = 'ACCEPT';
             global.acceptHdr = %trim(value);
          other;
             rc = -1;
          endsl;

       on-error;
          rc = -1;
       endmon;

       return rc;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * getGlobalPtr(): Internal routine to return the global options
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P getGlobalPtr    B                   export
     D                 PI              *
      /free
       p_global = %addr(globalopts);
       return p_global;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * memStatus(): Log memory alloc/dealloc status
      *
      * NOTE: Since HTTP headers are deliberately saved to the activation
      *       group and will be cleaned up later, they are not counted
      *       in the number of allocations.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P memStatus       B                   export
     D                 PI
     D   msg                         50a   varying const
      /if defined(MEMCOUNT)
     D count           s             20u 0
     C                   eval      count = totalloc
     C                                   - http_header_count()
     C                   callp     http_dmsg( msg
     C                                      + ': '
     C                                      + %char(count))
      /endif
     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy ERRNO_H
