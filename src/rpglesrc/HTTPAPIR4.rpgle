     /*-                                                                            +
      * Copyright (c) 2001-2025 Scott C. Klement                                    +
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

     /*
      * HTTPAPIR4 -- Hypertext transfer protocol API
      *
      *   A suite of routines for doing HTTP from ILE programs.
      *
      *   Requires:
      *       ILE RPG/400 licensed program from IBM.  V4R2 or later.
      *
      *       Optional TLS/SSL capabilities require V4R5 or later.
      *       and require the HTTP server, Client Encryption and
      *       Digital Certificate Manger Licensed programs.
      *
      *       See the README member, included in this package for details.
      *
      *   To Compile:
      *      - Edit the CONFIG_H member to set options.
      *      CRTCLPGM INSTALL SRCFILE(libhttp/QCLSRC)
      *      CALL INSTALL
      *
      *  To Update this module (HTTPAPIR4) without running
      *     the whole install procedure:
      *
      *>      CRTRPGMOD HTTPAPIR4 SRCFILE(LIBHTTP/QRPGLESRC) DBGVIEW(*LIST) -
      *>                OPTION(*SECLVL)
      *>      UPDSRVPGM SRVPGM(LIBHTTP/HTTPAPIR4) MODULE(HTTPAPIR4) -
      *>                EXPORT(*CURRENT)
      */

      /copy VERSION

      /if defined(HAVE_SRCSTMT_NODEBUGIO)
     H OPTION(*NOSHOWCPY: *SRCSTMT: *NODEBUGIO)
      /endif
     H NOMAIN

      /copy NTLM_H

      /define HTTP_ORIG_SHORTFIELD
      /copy RDWR_H
      /copy HTTPAPI_H
      /copy PRIVATE_H
      /copy HEADER_H
      /copy ERRNO_H
      /copy IFSIO_H
      /copy COMM_H

      /if defined(HTTP_USE_CCSID)
     D CCSID_OR_CP     S             10I 0 inz(O_CCSID)
      /else
     D CCSID_OR_CP     S             10I 0 inz(O_CODEPAGE)
      /endif

      ***  Local procedures ***
     D do_oper         PR            10I 0
     D  peOper                       10a   varying const
     D  peSaveProc                     *   value procptr
     D  peSendProc                     *   value procptr
     D  pePostData                     *   value
     D  pePostDataLen                20I 0 value
     D  peComm                         *   value
     D  peFile                       10I 0 value
     D  peTimeout                    10I 0 value
     D  peAbsPath                 32767A   const varying options(*varsize)
     D  peHost                      256A   const
     D  peModTime                      Z   options(*omit)
     D  peUserAgent               16384A   varying options(*omit)
     D  peContentType             16384A   varying options(*omit)
     D  peSoapAction              32767A   varying options(*omit)
     D  pePostProc                     *   value procptr
     D  pePostFD                     10I 0 value
     D  pePort                       10I 0 value
     D  peSecure                      1N   value
     D  peServ                       32A   const
     D  peExtendedCb                  1n   const

     D SendReq         PR            10I 0
     D   peComm                        *   value
     D   peData                        *   value
     D   peDataLen                   10I 0 value
     D   peTimeout                   10I 0 value

     D recvresp        PR            10I 0
     D   peComm                        *   value
     D   peRespChain              32767A   varying options(*varsize)
     D   peRespLen                   10I 0 value
     D   peTimeOut                   10P 3 value
     D   peUse100                     1N   const

     D recvdoc         PR            10I 0
     D   peComm                        *   value
     D   peProcedure                   *   value procptr
     D   peFD                        10I 0 value
     D   peTimeout                   10I 0 value
     D   peCLen                      10U 0 value
     D   peUseCL                      1N   const

     D recvchunk       PR            10I 0
     D   peComm                        *   value
     D   peProcedure                   *   value procptr
     D   peFD                        10I 0 value
     D   peTimeout                   10I 0 value

     D SendDoc         PR            10I 0
     D  peComm                         *   value
     D  pePostData                     *   value
     D  pePostDataLen                20I 0 value
     D  peTimeout                    10I 0 value
     D  peUnused1                      *   value procptr
     D  peUnused2                    10I 0 value

     D SendRaw         PR            10I 0
     D  peComm                         *   value
     D  peUnused1                      *   value
     D  peDataSize                   20I 0 value
     D  peTimeout                    10I 0 value
     D  pePostProc                     *   value procptr
     D  pePostFD                     10I 0 value

     d get_chunk_size  PR            10I 0
     d   peComm                        *   value
     d   peTimeout                   10I 0 value

     D interpret_auth  PR
     D   peRespChain               2048A   const
     D   peKwdPos                    10I 0 value
     D   peResetAuth                   N   value

     D interpret_proxy_auth...
     D                 PR
     D   peRespChain               2048A   const
     D   peKwdPos                    10I 0 value

     D mkdigest        PR         32767A   varying
     D   peMethod                    10A   varying const
     D   peURI                    32767A   varying const options(*varsize)

     D parse_resp_chain...
     D                 PR            10I 0
     D  peRespChain               32767A   varying const
     D  peRC                         10I 0
     D  peTE                         32A
     D  peCLen                       10u 0
     D  peUseCL                       1N
     D  peAuthErr                     1N
     D  peProxyAuthErr...
     D                                1N
     D  peHost                      256A   varying const
     D  pePath                      256A   varying const

     D setUrlAuth      PR
     D   peUsername                  80A   const
     D   pePasswd                  1024A   const

     D upload_sts      PR                  ExtProc(wkUplProc)
     D   peBytesSent                 10U 0 value
     D   peBytesTot                  10U 0 value
     D   peUserData                    *   value

     D download_sts    PR                  ExtProc(wkDwnlProc)
     D   peBytesSent                 10U 0 value
     D   peBytesTot                  10U 0 value
     D   peUserData                    *   value

     D addl_headers    PR                  ExtProc(wkAddHdrProc)
     D   peAddlHdrs               32767A   varying
     D   peUserData                    *   value

     D parse_hdrs      PR                  ExtProc(wkParseHdrProc)
     D   peHdrData                 2048A   const
     D   peUserData                    *   value

     D parse_hdr_long  PR                  ExtProc(wkParseHdrLong)
     D   peHdrData                32767A   const varying
     D   peUserData                    *   value

     D proxy_tunnel    PR            10I 0
     D   peComm                        *   value
     D   peServ                      32a   const
     D   peHost                     256a   const
     D   pePort                      10i 0 value
     D   peTimeout                   10i 0 value

     D getSA           PR         16384A   varying
     D                                     ExtProc('GETREALSA')
     D   peSoapAction                 2a   const
     D getRealSA       PR         16384A   varying
     D   peSoapAction                 2a

     D Buffer_t        ds                  qualified
     D                                     based(TEMPLATE)
     D   Len                         10u 0
     D   Data                          a   len(16000000)

     D getBufferInfo_REAL...
     D                 PR
     D   Buf                               likeds(Buffer_t)
     D   DataPtr                       *
     D   DataLen                     20i 0

     D getBufferInfo   PR                  extproc('GETBUFFERINFO_REAL')
     D   Buf                           a   varying len(16000000)
     D                                     const options(*omit:*varsize)
     D   DataPtr                       *
     D   DataLen                     20i 0

     D rcvToBuf        PR            10i 0
     D   fd                          10i 0 value
     D   data                     65535a   options(*varsize)
     D   len                         10i 0 value

     D ValidateRDWR    PR            10i 0
     D   handle                            like(RDWR_HANDLE) value
     D   Usage                        3u 0 value

     D http_redir_loc_long...
     D                 PR         32767A   varying

      ***  Global Constants  ***

     D CRLF            C                   CONST(x'0d25')
     D upper           C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D lower           C                   'abcdefghijklmnopqrstuvwxyz'
     D SEND_CHUNK_SIZE...
     D                 C                   CONST(8192)

      ***  Global Variables  ***

     D wkRedirLoc      s          32767A   varying inz('')

     D dsAuth          DS
     D   dsAuthType                   1A   inz(HTTP_AUTH_NONE)
     D   dsAuthBasic                  1N   inz(*OFF)
     D   dsAuthDigest                 1N   inz(*OFF)
     D   dsAuthRealm                124A
     D   dsAuthNonce                128A
     D   dsAuthOpaque               128A
     D   dsAuthQOP                   32A
     D   dsAuthCnonce                16A
     D   dsAuthNC                     7P 0 inz(0)
     D   dsAuthUser                  80A
     D   dsAuthPasswd              1024A
     D   dsAuthStr                16384A   varying inz('')

     D dsProxyAuth     DS
     D   dsProxyAuthType...
     D                                1A   inz(HTTP_AUTH_NONE)
     D   dsProxyAuthBasic...
     D                                1N   inz(*OFF)
     D   dsProxyAuthRealm...
     D                              124A
     D   dsProxyAuthUser...
     D                               80A
     D   dsProxyAuthPasswd...
     D                             1024A
     D   dsProxyAuthStr...
     D                             1476A   varying inz('')

     D dsProxy         DS
     D   dsProxyHost               2048A   inz(*blanks)
     D   dsProxyPort                 10I 0 inz(*zeros)
     D   dsProxyTun                   1N   inz(*off)

     D wkSaveAuth      s                   like(dsAuth)

     D wkUplProc       S               *   procptr inz(*NULL)
     D wkUplUdata      S               *   inz(*NULL)
     D wkDwnlProc      S               *   procptr inz(*NULL)
     D wkDwnlUdata     S               *   inz(*NULL)
     D wkAddHdrProc    S               *   procptr inz(*NULL)
     D wkAddHdrData    S               *   inz(*NULL)
     D wkParseHdrProc  S               *   procptr inz(*NULL)
     D wkParseHdrData  S               *   inz(*NULL)
     D wkParseHdrLong  S               *   procptr inz(*NULL)
     D wkParseHdrLongData...
     D                 S               *   inz(*NULL)

     D RcvStrBuf       ds                  qualified
     D   Size                        10u 0 inz(0)
     D   Len                         10u 0 inz(0)
     D   Ptr                           *   inz(*null)

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Close HTTP connection
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_close      B                   export
     D http_close      PI            10I 0
     D  peSock                       10I 0 value
     D  peComm                         *   value

     c                   callp     http_dmsg('http_close(): entered')

     c                   if        %parms < 2
     c                   callp     SetError(HTTP_NOTSUPP
     c                                     : ' using old format of '
     c                                     + 'http_close')
     c                   return    -1
     c                   endif

     c                   callp     http_dclose

     c                   if        peComm <> *null
     c                   eval      p_commdriver = peComm
     c                   if        comm_hangup ( peComm ) = *off
     c                   return    -1
     c                   endif
     c                   callp     comm_cleanup( peComm )
     c                   endif

      /if defined(MEMCOUNT)
     c                   callp     memStatus('allocs at close')
      /endif

     c                   return    0
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * do_oper():  Perform HTTP operation
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P do_oper         B
     D do_oper         PI            10I 0
     D  peOper                       10a   varying const
     D  peSaveProc                     *   value procptr
     D  peSendProc                     *   value procptr
     D  pePostData                     *   value
     D  pePostDataLen                20I 0 value
     D  peComm                         *   value
     D  peFile                       10I 0 value
     D  peTimeout                    10I 0 value
     D  peAbsPath                 32767A   const varying options(*varsize)
     D  peHost                      256A   const
     D  peModTime                      Z   options(*omit)
     D  peUserAgent               16384A   varying options(*omit)
     D  peContentType             16384A   varying options(*omit)
     D  peSoapAction              32767A   varying options(*omit)
     D  pePostProc                     *   value procptr
     D  pePostFD                     10I 0 value
     D  pePort                       10I 0 value
     D  peSecure                      1N   value
     D  peServ                       32A   const
     D  peExtendedCb                  1n   const

     D SendProc        PR            10I 0 extproc(peSendProc)
     D  peComm                         *   value
     D  pePostData                     *   value
     D  pePostDataLen                20I 0 value
     D  peTimeout                    10I 0 value
     D  pePostProc                     *   procptr value
     D  pePostFD                     10I 0 value

     D wwReqChain      S          32767A   varying
     D wwRespChain     S          32767A   varying
     D wwAddlHdr       s          32767A   varying
     D wwModString     S             29A
     D rc              S             10I 0
     D wwPos           S             10I 0
     D wwPos2          S             10I 0
     D wwTE            S             32A
     D wwAuthErr       S              1N   inz(*OFF)
     D wwProxyAuthErr...
     D                 S              1N   inz(*OFF)
     D wwCLen          S             10U 0
     D wwCL            S             32A
     D wwUseCL         s              1N
     D wwFinRC         S             10I 0
     D wwErrorNo       s             10I 0
     D wwErrorMsg      s                   like(http_error)
     D wwErr           s             10I 0
     d wwPathPfx       s           1024A   varying
     D wwSendReqBody   s              1n   inz(*off)

     D wwSaveProc      s                   like(peSaveProc) inz
     D wwFile          s                   like(peFile    ) inz

     c                   callp     http_dmsg( 'do_oper(' + peOper + '): '
     c                                      + 'entered')
     c                   eval      p_global = getGlobalPtr()

      /if defined(MEMCOUNT)
     c                   callp     memStatus('allocs do_oper start')
      /endif

     c                   if        peExtendedCB = *off
     c                   eval      RDWR_Reader_p = *null
     c                   eval      RDWR_Writer_p = *null
     c                   endif

     C*********************************************************
     C* Determine whether there's a message body to upload
     C* with the request
     C*********************************************************
     c                   if        pePostDataLen >= 0 and
     c                             (pePostData<>*null or pePostProc<>*null)
     c                   eval      wwSendReqBody = *on
     c                   endif

     C*********************************************************
     C*  Build an HTTP/1.1 request chain:
     C*********************************************************
     c* If Connection is done via Proxy, an URI instead of just the path has to be sent.
     c                   if        dsProxyHost <> *blanks
     c                               and dsProxyTun = *Off
     c                   eval      wwPathPfx = %trim(peServ) + '://' +
     c                             %trim(peHost)
     c                   if        pePort <> 0
     c                   eval      wwPathPfx = wwPathPfx + ':' +
     c                                        %trim(%editc(pePort:'L'))
     c                   endif
     c                   else
     c                   eval      wwPathPfx = ''
     c                   endif

     c                   eval      wwReqChain = peOper + ' '
     c                             + wwPathPfx + %trim(peAbsPath)
     c                             + ' HTTP/1.1' + CRLF
     c                             + 'Host: ' + %trim(peHost)

     c                   if        pePort = 0
     c                   eval      wwReqChain = wwReqChain + CRLF
     c                   else
     c                   eval      wwReqChain = wwReqChain + ':'
     c                                        + %trim(%editc(pePort:'L'))
     c                                        + CRLF
     c                   endif

     c                   if        %addr(peModTime) <> *NULL
     c                   eval      wwModString = httpdate(peModTime)
     c                   eval      wwReqChain = wwReqChain +
     c                             'If-Modified-Since: '+wwModString+CRLF
     c                   endif

     c                   if        %addr(peUserAgent)<>*NULL
     c                   if        peUserAgent <> *blanks
     c                   eval      wwReqChain = wwReqChain +
     c                             'User-Agent: '+%trimr(peUserAgent)+CRLF
     c                   endif
     c                   else
     c                   eval      wwReqChain = wwReqChain +
     c                             'User-Agent: ' + HTTP_USERAGENT + CRLF
     c                   endif

     c                   if        wwSendReqBody = *on
     c                   if        %addr(peContentType) <> *NULL
     c                   if        peContentType <> *blanks
     c                   eval      wwReqChain = wwReqChain +
     c                             'Content-Type: '+%trimr(peContentType)+
     c                             CRLF
     c                   endif
     c                   else
     c                   eval      wwReqChain = wwReqChain +
     c                             'Content-Type: ' + HTTP_CONTTYPE + CRLF
     c                   endif
     c                   endif

     c                   if        %len(global.acceptHdr) > 0
     c                   eval      wwReqChain = wwReqChain +
     c                             'Accept: ' + global.acceptHdr + CRLF
     c                   endif

     c                   if        %addr(peSOAPAction) <> *NULL
     c                   if        %len(peSOAPAction)>0
     c                              and peSoapAction<>*blanks
     c                   eval      wwReqChain = wwReqChain +
     c                             'SOAPAction: ' +%trimr(peSOAPAction)+
     c                             CRLF
     c                   else
     c                   eval      wwReqChain = wwReqChain +
     c                             'SOAPAction:  ' + CRLF
     c                   endif
     c                   endif

     c                   if        wwSendReqBody=*on and global.timeout100>0
     c                   eval      wwReqChain = wwReqChain +
     c                             'Expect: 100-continue' + CRLF
     c                   endif

     c                   if        wwSendReqBody = *on
     c                   eval      wwReqChain = wwReqChain +
     c                             'Content-Length: ' +
     c                             %trim(%editc(pePostDataLen:'P')) + CRLF
     c                   endif

     c                   if        dsProxyAuthType = HTTP_AUTH_BASIC
     c                                and dsProxyTun = *off
     c                   eval      wwReqChain = wwReqChain +
     c                             'Proxy-Authorization: Basic '+
     c                             dsProxyAuthStr + CRLF
     c                   endif

     c                   select
     c                   when      dsAuthType = HTTP_AUTH_BASIC
     c                   eval      wwReqChain = wwReqChain +
     c                             'Authorization: Basic ' +
     c                              dsAuthStr + CRLF
     c                   when      dsAuthType = HTTP_AUTH_MD5_DIGEST
     c                   eval      wwReqChain = wwReqChain +
     c                             'Authorization: Digest ' +
     c                              mkdigest(peOper:peAbsPath) + CRLF
     c                   when      dsAuthType = HTTP_AUTH_BEARER
     c                             or dsAuthType = HTTP_AUTH_USRDFN
     c                   eval      wwReqChain = wwReqChain +
     c                             'Authorization: ' + dsAuthStr + CRLF
      /if defined(NTLM_SUPPORT)
     c                   other
      *        Add NTLM authentication header for type-1
      *        and type-3 messages.
     c                   callp     AuthPlugin_produceAuthenticationHeader(
     c                                                              wwReqChain)
      /endif
     c                   endsl

      /if defined(MEMCOUNT)
     c                   callp     memStatus('allocs do_oper reqchain1')
      /endif

     c                   if        global.use_cookies = *on
     c                   eval      wwReqChain = wwReqChain +
     c                             header_get_req_cookies( %trim(peHost)
     c                                                   : peAbsPath
     c                                                   : peSecure )
     c                   endif

      /if defined(MEMCOUNT)
     c                   callp     memStatus('allocs do_oper reqchain2')
      /endif

     c                   eval      %len(wwAddlHdr) = 0
     c                   if        wkAddHdrProc <> *NULL
     c                   callp     addl_headers(wwAddlHdr: wkAddHdrData)
     c                   endif

      /if defined(MEMCOUNT)
     c                   callp     memStatus('allocs do_oper reqchain3')
      /endif

      *********************************************************
      *  Send request chain
      *********************************************************
     c                   if        %len(wwAddlHdr) = 0
     c                   eval      wwReqChain = wwReqChain + CRLF
     c                   endif

     c                   eval      rc = SendReq( peComm
     c                                         : %addr(wwReqChain)+VARPREF
     c                                         : %len(wwReqChain)
     c                                         : peTimeout )
     c                   if        rc < 1
     c                   callp     SetRespCode(rc)
     c                   return    rc
     c                   endif

     c                   if        %len(wwAddlHdr) > 0

     c                   eval      rc = SendReq( peComm
     c                                         : %addr(wwAddlHdr)+VARPREF
     c                                         : %len(wwAddlHdr)
     c                                         : peTimeout )
     c                   if        rc < 1
     c                   callp     SetRespCode(rc)
     c                   return    rc
     c                   endif

     c                   eval      wwReqChain = CRLF
     c                   eval      rc = SendReq( peComm
     c                                         : %addr(wwReqChain)+VARPREF
     c                                         : %len(wwReqChain)
     c                                         : peTimeout )
     c                   if        rc < 1
     c                   callp     SetRespCode(rc)
     c                   return    rc
     c                   endif

     c                   endif

      /if defined(MEMCOUNT)
     c                   callp     memStatus('allocs after sendreq')
      /endif

      *********************************************************
      * If this request requires a request-body
      * then it should be sent, here.
      *
      * Some servers send a "100 Continue" block of HTTP
      * headers -- but this is optional.  So we will also
      * attempt to get these in this section, if they are
      * sent.
      *********************************************************
     c                   if        wwSendReqBody = *on

     c                   if        global.timeout100 <= 0
     c                   eval      rc = 0
     c                   else
     c                   eval      rc = RecvResp( peComm
     c                                          : wwRespChain
     c                                          : %size(wwRespChain)
     c                                          : global.timeout100
     c                                          : *ON )
     c                   if        rc < 0
     c                   callp     SetRespCode(rc)
     c                   return    rc
     c                   endif
     c                   endif

      /if defined(MEMCOUNT)
     c                   callp     memStatus('allocs after recvresp1')
      /endif

     c                   if        rc = 0

     c                   eval      wwFinRC = 100
     c                   eval      wwErrorMsg = 'CONTINUE'

     c                   else

     c                   eval      rc = parse_resp_chain( wwRespChain
     c                                                  : rc
     c                                                  : wwTE
     c                                                  : wwCLen
     c                                                  : wwUseCL
     c                                                  : wwAuthErr
     c                                                  : wwProxyAuthErr
     c                                                  : %trim(peHost)
     c                                                  : peAbsPath)
     c                   if        rc<100 or rc=204 or rc=304
     c                   callp     SetRespCode(rc)
     c                   return    rc
     c                   endif

     c                   eval      wwFinRC = rc
     c                   eval      wwErrorMsg = http_error(wwErrorNo)

     c                   endif

      /if defined(MEMCOUNT)
     c                   callp     memStatus('allocs after parseresp1')
      /endif

     c                   if        wwFinRC = 100
     c                   eval      rc = SendProc( peComm
     c                                          : pePostData
     c                                          : pePostDataLen
     c                                          : peTimeout
     c                                          : pePostProc
     c                                          : pePostFD )
     c                   if        rc < 1
     c                   callp     SetRespCode(rc)
     c                   return    rc
     c                   endif
     c                   endif

     c                   endif

      *********************************************************
      *  Receive response chain from server
      *********************************************************
     c                   eval      rc = RecvResp( peComm
     c                                          : wwRespChain
     c                                          : %size(wwRespChain)
     c                                          : peTimeout
     c                                          : *Off )
     c                   if        rc < 1
     c                   callp     SetRespCode(rc)
     c                   return    rc
     c                   endif

      /if defined(MEMCOUNT)
     c                   callp     memStatus('allocs after recvresp2')
      /endif

     c                   eval      rc = parse_resp_chain( wwRespChain
     c                                                  : rc
     c                                                  : wwTE
     c                                                  : wwCLen
     c                                                  : wwUseCL
     c                                                  : wwAuthErr
     c                                                  : wwProxyAuthErr
     c                                                  : %trim(peHost)
     c                                                  : peAbsPath )

      /if defined(MEMCOUNT)
     c                   callp     memStatus('allocs after parseresp2')
      /endif

     c                   eval      wwSaveProc = peSaveProc
     c                   eval      wwFile = peFile

     c                   if        wwAuthErr and wwCLen > 0
      /if defined(NTLM_SUPPORT)
     c                             and AuthPlugin_mustReceiceAuthErrorPage(
     c                                wwSaveProc: wwFile)
      /endif
      *      ignore 401 error for type-1 and type-2 messages
     c                   else
     c                   if        rc<100 or rc=204 or rc=304
     c                   callp     SetRespCode(rc)
     c                   return    rc
     c                   endif
     c                   endif

     c                   eval      wwFinRC = rc
     c                   eval      wwErrorMsg = http_error(wwErrorNo)

     C*********************************************************
     C* receive the document from the server
     C*********************************************************
     c                   if        peOper = 'HEAD'
     c                   eval      wwUseCL = *ON
     c                   eval      wwCLen = 0
     c                   endif

     c                   if        %scan('chunked': wwTE) > 0
     c                   eval      rc = RecvChunk( peComm
     c                                           : wwSaveProc
     c                                           : wwFile
     c                                           : peTimeout )
     c                   else
     c                   eval      rc = RecvDoc( peComm
     c                                         : wwSaveProc
     c                                         : wwFile
     c                                         : peTimeout
     c                                         : wwCLen
     c                                         : wwUseCL )
     c                   endif

      /if defined(MEMCOUNT)
     c                   callp     memStatus('allocs after recvdoc')
      /endif

     c                   select
     c                   when      rc<1 or wwFinRC=200
     c                   callp     SetRespCode(rc)
     c                   return    rc
     c                   when      wwFinRC=401 or wwFinRC=407
     c                   callp     SetError(wwErrorNo: wwErrorMsg)
     c                   callp     SetRespCode(wwFinRC)
     c                   return    -1
     c                   other
     c                   callp     SetError(wwErrorNo: wwErrorMsg)
     c                   callp     SetRespCode(wwFinRC)
     c                   return    wwFinRC
     c                   endsl
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SendReq():  Send request chain
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SendReq         B
     D SendReq         PI            10I 0
     D   peComm                        *   value
     D   peData                        *   value
     D   peDataLen                   10I 0 value
     D   peTimeout                   10I 0 value
     D p_deref         s               *
     D wwDeref         s              1A   based(p_deref)

     c                   callp     http_xlatep( peDataLen
     c                                        : peData
     c                                        : TO_ASCII )

     c                   return    comm_BlockWrite( peComm
     c                                            : peData
     c                                            : peDataLen
     c                                            : peTimeout )
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  recvresp():  Receives an HTTP response chain from the server.
      *
      *      peComm = Comm driver to use when receiving
      * peRespChain = complete request chain to sent
      *   peRespLen = length of request chain data
      *  peTimeOut  = Timeout value in seconds.  If no data can be sent
      *         for this amount of time, it will return a timeout.
      *    peUse100 = Return from recvresp() if a 100-continue comes up
      *
      *  Returns 1 upon success, 0 upon timeout, -1 upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P recvresp        B
     D recvresp        PI            10I 0
     D   peComm                        *   value
     D   peRespChain              32767A   varying options(*varsize)
     D   peRespLen                   10I 0 value
     D   peTimeOut                   10P 3 value
     D   peUse100                     1N   const

     D wwPos           S               *
     D wwRec           S             10I 0
     D wwLen           S             10I 0
     D p_saveaddr      S               *
     D p_check         S               *
     D wwCheck         S              4A   based(p_check)
     D wwRespCode      S             10I 0
     D forever         S              1N   inz(*On)
     D repeating       S              1N   inz(*Off)
     D wwSecs          s             10I 0
     D wwMicroSecs     s             10I 0
     D wwLeft          s             10I 0
     D wwErr           s             10I 0
     D CR              S              1A   inz(x'0d') static

     c                   callp     http_dmsg('recvresp(): entered')
     c                   eval      p_global = getGlobalPtr()

     c                   dou       not repeating

     c                   eval      wwPos = %addr(peRespChain) + VARPREF
     c                   eval      wwLeft = peRespLen - VARPREF
     c                   eval      %len(peRespChain) = wwLeft
     c                   eval      wwLen = 0

     c                   dow       wwLeft > 0

     c                   if        global.debugLevel > 1
     c                   callp     http_dmsg('recvresp: reading response +
     c                             header, space left=' + %char(wwLeft))
     c                   endif

     c                   eval      wwRec = comm_lineread( peComm
     c                                                  : wwPos
     c                                                  : wwLeft
     c                                                  : peTimeout )

     c                   if        wwRec < 1
     c                   callp     http_error(wwErr)
     c                   if        wwErr = HTTP_BRTIME
     c                   callp     http_dmsg('recvresp(): end with timeout')
     c                   return    0
     c                   else
     c                   callp     http_dmsg('recvresp(): end with err')
     c                   return    -1
     c                   endif
     c                   endif

     c                   eval      wwLeft = wwLeft - wwRec
     c                   eval      wwLen = wwLen + wwRec
     c                   if        wwLeft > 0
     c                   eval      wwPos = wwPos + wwRec
     c                   endif

     c                   eval      p_check = wwPos - wwRec
     c                   if        (wwRec=1
     c                             and %subst(wwCheck:1:1)=x'0a')
     c                             or (wwRec=2
     c                             and %subst(wwCheck:1:2)=x'0d0a')
     c                   if        global.debugLevel > 1
     c                   callp     http_dmsg('recvresp: empty line, ending +
     c                                header, number of eol chars=' +
     c                                %char(wwRec))
     c                   endif
     c                   leave
     c                   endif

     c                   enddo

     c                   eval      %len(peRespChain) = wwLen

     C* translate response chain to EBCDIC
     c                   if        wwLen > 0
     c                   callp     http_xlatep( wwLen
     c                                        : %addr(peRespChain)+VARPREF
     c                                        : TO_EBCDIC )
     c                   endif

     C* check for "continue" type codes:
     C* if we get them, we'll look for a whole new chain :)
     c                   if        %subst(peRespChain:1:2) = x'0d25'
     c                   eval      p_check = %addr(peRespChain) + 13
     c                   else
     c                   eval      p_check = %addr(peRespChain) + 11
     c                   endif
     c                   eval      wwRespCode = atoi(wwCheck)

     c                   select
     c                   when      peUse100 and wwRespCode = 100
      *                 we are handling this specially in do_oper
     c                   eval      repeating = *off
     c                   when      wwRespCode > 99 and wwRespCode < 200
     c                   eval      repeating = *on
     c                   when      wwRespCode = 0
     c                   eval      repeating = *on
     c                   other
     c                   eval      repeating = *off
     c                   endsl

     c                   if        global.debugLevel > 1
     c                   callp     http_dmsg('recvresp: header resp code +
     c                                = ' + wwCheck + ' repeating=' +
     c                               repeating)
     c                   endif

     c                   if        %scan(CR:peRespChain) > 1
     c                   callp     SetError(HTTP_RESP: %subst(peRespChain:1:
     c                                 %scan(CR:peRespChain)-1) )
     c                   else
     c                   callp     SetError(HTTP_RESP: peRespChain)
     c                   endif

     c                   enddo

     c                   callp     http_dmsg('recvresp(): end with '
     c                                 + %char(wwRespCode))
     c                   return    wwRespCode
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * recvdoc(): receive (Download) http document
      *
      *       peComm = Comm driver to receive with
      *  peProcedure = procedure to call with received data.
      *    peTimeout = time-out in seconds.  If no data is received
      *          for this amount of time, proc will time out.
      *
      *  returns 1 upon success, 0 upon timeout, -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P recvdoc         B
     D recvdoc         PI            10I 0
     D   peComm                        *   value
     D   peProcedure                   *   value procptr
     D   peFD                        10I 0 value
     D   peTimeout                   10I 0 value
     D   peCLen                      10U 0 value
     D   peUseCL                      1N   const

     D saveproc        PR            10I 0 ExtProc(peProcedure)
     D  fd                           10I 0 value
     D  data                           *   value
     D  length                       10I 0 value

     D wwData          S           8192A
     D forever         S              1N   inz(*on)
     D wwErr           S             10I 0
     D p_saveaddr      S               *
     D wwTimeout       S              8A
     D wwLen           S             10I 0
     D rc              S             10I 0
     D wwChunked       S              1N
     D wwChunk         S             10I 0
     D wwReceived      S             10U 0
     D wwRet           s             10I 0

     c                   callp     http_dmsg('recvdoc(): entered')
     c                   eval      p_global = getGlobalPtr()

     c                   callp     SetError(0: *blanks)
     c                   eval      wwReceived = 0

     c                   if        peUseCL = *OFF
     c                   callp     http_dmsg('recvdoc(): No content-length: +
     c                               receiving until disconnect')
     c                   eval      wwRet = 1
     c                   else
     c                   callp     http_dmsg('recvdoc(): Receiving ' +
     c                                %char(peCLen) + ' bytes.')
     c                   eval      wwRet = -1
     c                   endif

     c                   if        peUseCL=*ON and peCLen=0
     c                   callp     http_dmsg('recvdoc(): Nothing to +
     c                               receive, exiting...')
     c                   return    1
     c                   endif

     c                   dow       forever

     c                   eval      wwLen = comm_read( peComm
     c                                              : %addr(wwData)
     c                                              : %size(wwData)
     c                                              : peTimeout     )

     c                   if        global.debugLevel > 2
     c                   callp     http_dmsg('recvdoc(): comm_read rc = ' +
     c                               %char(wwLen))
     c                   endif

     c                   if        wwLen < 0
     c                   return    wwRet
     c                   endif

     c                   if        global.debugLevel > 2
     c                   callp     http_dmsg('recvdoc(): Calling saveproc +
     c                                for ' + %char(wwLen) + ' bytes')
     c                   endif

     c                   if        RDWR_Writer_p <> *null
     c                   eval      rc = Writer_Write( RDWR_Writer_p
     c                                              : %addr(wwData)
     c                                              : wwLen )
     c                   else
     c                   eval      rc = saveproc( peFD
     c                                          : %addr(wwData)
     c                                          : wwLen )
     c                   endif

     c                   if        global.debugLevel > 2
     c                   callp     http_dmsg('recvdoc(): saveproc returns ' +
     c                                %char(rc) + ' saved')
     c                   endif
     c
     c                   if        rc < wwLen
     c                   callp     SetError(HTTP_RDWERR
     c                                     : 'errno is currently '
     c                                     + %trim(%editc(errno:'L')))
     c                   callp     SetError(HTTP_RDWERR:'recvdoc: saveproc:'+
     c                              ' Not all data was written!')
     c                   return    -1
     c                   endif

     c                   eval      wwReceived = wwReceived + wwLen

     c                   if        global.debugLevel > 1
     c                   callp     http_dmsg('recvdoc():'
     c                                      + ' have ' + %char(wwReceived)
     c                                      + ' of ' + %char(peCLen))
     c                   endif

     c                   if        peUseCL=*ON and wwReceived>=peCLen
     c                   return    1
     c                   endif

     C* Call status proc if defined
     c                   if        wkDwnlProc <> *NULL
     c                   if        global.debugLevel > 2
     c                   callp     http_dmsg('recvdoc(): calling user +
     c                                supplied download_sts routine')
     c                   endif
     c                   callp     download_sts(wwReceived: peCLen
     c                                         : wkDwnlUdata)
     c                   if        global.debugLevel > 2
     c                   callp     http_dmsg('recvdoc(): download_sts +
     c                                 returned')
     c                   endif
     c                   endif

     c                   enddo

     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * recvchunk(): receive (download) data using chunked transfer-encoding
      *
      *       peComm = Comm driver to receive from
      *  peProcedure = procedure to call with received data.
      *    peTimeout = time-out in seconds.  If no data is received
      *          for this amount of time, proc will time out.
      *
      *  returns 1 upon success, 0 upon timeout, -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P recvchunk       B
     D recvchunk       PI            10I 0
     D   peComm                        *   value
     D   peProcedure                   *   value procptr
     D   peFD                        10I 0 value
     D   peTimeout                   10I 0 value

     D saveproc        PR            10I 0 ExtProc(peProcedure)
     D  fd                           10I 0 value
     D  data                           *   value
     D  length                       10I 0 value

     D wwData          s           8192A
     D forever         S              1N   inz(*on)
     D rc              S             10I 0
     D wwLeft          S             10I 0
     D wwRecSize       S             10I 0
     D wwCRLF          s              2A
     D wwReceived      S             10U 0

     c                   callp     http_dmsg('recvchunk(): entered')
     c                   eval      p_global = getGlobalPtr()
     c                   eval      wwReceived = 0

     c                   dow       Forever

     C*********************************************************
     C* Receive the size of the next chunk of data:
     C*********************************************************
     c                   eval      wwLeft = get_chunk_size(peComm:peTimeout)
     c                   callp     http_dmsg('get_chunk_size returned ' +
     c                                          %trim(%editc(wwLeft:'P')))
     c                   select
     c                   when      wwLeft = 0
     c                   return    1
     c                   when      wwLeft = -2
     c                   return    0
     c                   when      wwLeft = -1
     c                   return    -1
     c                   endsl

     C*********************************************************
     c* Receive data until we have an entire chunk:
     C*********************************************************
     c                   dou       wwLeft = 0

     c                   eval      wwRecSize = %size(wwData)
     c                   if        wwLeft < wwRecSize
     c                   eval      wwRecSize = wwLeft
     c                   endif

     c                   callp     http_dmsg('calling comm_blockread')

     c                   if        comm_BlockRead( peComm
     c                                           : %addr(wwData)
     C                                           : wwRecSize
     c                                           : peTimeout ) < wwRecSize
     c                   callp     http_dmsg('comm_blockread failed!')
     c                   return    -1
     c                   endif

     c                   callp     http_dmsg('comm_blockread returned ' +
     c                              %trim(%editc(wwRecSize:'P')) )

     C* Write any received data to the save procedure:
     C                   if        RDWR_Writer_p <> *null
     C                   eval      rc = Writer_write( RDWR_Writer_p
     C                                              : %addr(wwData)
     C                                              : wwRecSize )
     C                   else
     c                   eval      rc = saveproc( peFD
     c                                          : %addr(wwData)
     c                                          : wwRecSize)
     c                   endif

     c                   if        rc < wwRecSize
     c                   callp     SetError(HTTP_RDWERR:'recvchunk: saveproc:'+
     c                              ' Not all data was written!')
     c                   return    -1
     c                   endif

     c                   if        wkDwnlProc <> *NULL
     c                   eval      wwReceived = wwReceived + wwRecSize
     c                   callp     download_sts(wwReceived: 0: wkDwnlUData)
     c                   endif

     c                   eval      wwLeft = wwLeft - wwRecSize
     c                   enddo

     C*********************************************************
     c* Receive the CRLF that follows each chunk
     C*********************************************************
     c                   if        comm_BlockRead( peComm
     c                                           : %addr(wwCRLF)
     c                                           : %size(wwCRLF)
     c                                           : peTimeout ) < 2
     c                             or wwCRLF <> x'0d0a'
     c                   callp     SetError(HTTP_RDCRLF: 'recvchunk: '+
     c                                'No CRLF after reading chunk!')
     c                   return    -1
     c                   endif

     c                   enddo
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This sends a document body, such as those used by the PUT
      *  or POST HTTP commands.
      *
      *  returns 0 for timeout, -1 for error or 1 if successful
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SendDoc         B
     D SendDoc         PI            10I 0
     D  peComm                         *   value
     D  pePostData                     *   value
     D  pePostDataLen                20I 0 value
     D  peTimeout                    10I 0 value
     D  peUnused1                      *   value procptr
     D  peUnused2                    10I 0 value

     D wwPos           S               *
     D wwLeft          S             20I 0
     D wwTimeout       S              8A
     D wwErr           S             10I 0
     D wwSent          S             10I 0
     D wwChunk         S             10I 0
     D wwTotSent       s             20i 0
     D reportTotal     s             10u 0
     D reportSent      s             10u 0

     c                   callp     http_dmsg('senddoc(): entered')
     c                   eval      p_global = getGlobalPtr()

     c                   eval      wwPos = pePostData
     c                   eval      wwLeft = pePostDataLen

     c                   if        pePostDataLen > 4294967295
     c                   eval      reportTotal = 4294967295
     c                   else
     c                   eval      reportTotal = pePostDataLen
     c                   endif

     c                   dow       wwLeft > 0

     c                   if        wwLeft > SEND_CHUNK_SIZE
     c                   eval      wwChunk = SEND_CHUNK_SIZE
     c                   else
     c                   eval      wwChunk = wwLeft
     c                   endif

     c                   if        global.debugLevel > 1
     c                   callp     http_dmsg('senddoc()' +
     c                                 ': data left=' + %char(wwLeft) +
     c                                 ', chunk size=' + %char(wwChunk) +
     c                                 ', timeout=' + %char(peTimeout) +
     c                                 ', calling comm_blockWrite...')
     c                   endif

     c                   eval      wwSent = comm_BlockWrite( peComm
     c                                                     : wwPos
     c                                                     : wwChunk
     c                                                     : peTimeout )
     c                   if        global.debugLevel > 1
     c                   callp     http_dmsg('senddoc(): comm_blockWrite ' +
     c                                 'returned ' + %char(wwSent))
     c                   endif

     c                   if        wwSent < 0
     c                   return    -1
     c                   endif

     c                   eval      wwLeft = wwLeft - wwSent
     c                   if        wwLeft > 0
     c                   eval      wwPos  = wwPos + wwSent
     c                   endif

     c                   if        wkUplProc <> *NULL
     c                   if        global.debugLevel > 1
     c                   callp     http_dmsg('senddoc(): calling user ' +
     c                                 'defined upload_sts routine')
     c                   endif
     c                   eval      wwTotSent = pePostDataLen - wwLeft
     c                   if        wwTotSent > 4294967295
     c                   eval      reportSent = 4294967295
     c                   else
     c                   eval      reportSent = wwTotSent
     c                   endif
     c                   callp     upload_sts( reportSent
     c                                       : reportTotal
     c                                       : wkUplUData )
     c                   if        global.debugLevel > 1
     c                   callp     http_dmsg('senddoc(): upload_sts ' +
     c                                 'returned')
     c                   endif
     c                   endif

     c                   enddo

     c                   return    1
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This sends a document body, such as those used by the PUT
      *  or POST HTTP commands, but uses a callback instead of a buffer
      *
      *  returns 0 for timeout, -1 for error or 1 if successful
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SendRaw         B
     D SendRaw         PI            10I 0
     D  peComm                         *   value
     D  peUnused1                      *   value
     D  peDataSize                   20I 0 value
     D  peTimeout                    10I 0 value
     D  pePostProc                     *   value procptr
     D  pePostFD                     10I 0 value

     D Callback        PR            10I 0 extproc(pePostProc)
     D   fd                          10I 0 value
     D   data                      8192A
     D   size                        10I 0 value

     D wwLen           S             10I 0
     D wwBuf           s           8192A
     D wwSent          S             20I 0
     D wwNeed          S             10I 0
     D rc              s             10i 0
     D reportTotal     s             10u 0
     D reportSent      s             10u 0

     c                   callp     http_dmsg('sendraw(): entered')
     c                   eval      p_global = getGlobalPtr()
     c                   eval      wwSent = 0

     c                   if        peDataSize > 4294967295
     c                   eval      reportTotal = 4294967295
     c                   else
     c                   eval      reportTotal = peDataSize
     c                   endif

     c                   dow       peDataSize > wwSent

     c                   eval      wwNeed = %size(wwBuf)
     c                   if        wwNeed > peDataSize
     c                   eval      wwNeed = peDataSize
     c                   endif

     c                   if        global.debugLevel > 1
     c                   callp     http_dmsg('sendraw()' +
     c                                 ': data sent=' + %char(wwSent) +
     c                                 ', chunk size=' + %char(wwNeed) +
     c                                 ', calling Callback to get data...')
     c                   endif

     c                   if        RDWR_Reader_p <> *null
     c                   eval      wwLen = Reader_read( RDWR_Reader_p
     c                                                : %addr(wwBuf)
     c                                                : wwNeed )
     c                   else
     c                   eval      wwLen = Callback( pePostFD
     c                                             : wwBuf
     c                                             : wwNeed )
     c                   endif

     c                   if        wwLen < 1
     c                   callp     SetError( HTTP_SWCERR
     c                                     : 'SendRaw(): callback '
     c                                     + 'returned an error.')
     c                   return    -1
     c                   endif

     c                   if        wwLen > wwNeed
     c                   callp     SetError( HTTP_SWCERR
     c                                     : 'SendRaw(): callback '
     c                                     + 'supplied too much data.')
     c                   return    -1
     c                   endif

     c                   if        global.debugLevel > 1
     c                   callp     http_dmsg('sendraw()' +
     c                                 ': data sent=' + %char(wwSent) +
     c                                 ', chunk len=' + %char(wwLen) +
     c                                 ', timeout=' + %char(peTimeout) +
     c                                 ', calling comm_BlockWrite...')
     c                   endif

     c                   eval      rc = comm_BlockWrite( peComm
     c                                                 : %addr(wwBuf)
     c                                                 : wwLen
     c                                                 : peTimeout
     c                                                 )

     c                   if        global.debugLevel > 1
     c                   callp     http_dmsg('sendraw(): comm_blockWrite ' +
     c                                 'returned ' + %char(rc))
     c                   endif

     c                   if        rc < wwLen
     c                   return    -1
     c                   endif

     c                   eval      wwSent = wwSent + wwLen

     c                   if        wkUplProc <> *NULL
     c                   if        global.debugLevel > 1
     c                   callp     http_dmsg('sendraw(): calling user ' +
     c                                 'defined upload_sts routine')
     c                   endif
     c                   if        wwSent > 4294967295
     c                   eval      reportSent = 4294967295
     c                   else
     c                   eval      reportSent = wwSent
     c                   endif
     c                   callp     upload_sts( reportSent
     c                                       : reportTotal
     c                                       : wkUplUData )
     c                   if        global.debugLevel > 1
     c                   callp     http_dmsg('sendraw(): upload_sts ' +
     c                                 'returned')
     c                   endif
     c                   endif

     c                   enddo

     c                   return    1
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This receives the chunk size from the http stream.  We use
      *   it so we know how big the next chunk of data is.
      *
      *  XXX: This will crash if 2gb or larger chunks are used.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P get_chunk_size  B
     d get_chunk_size  PI            10I 0
     d   peComm                        *   value
     d   peTimeout                   10I 0 value

     d sscanf          PR            10I 0 extproc('sscanf')
     D  str                            *   value options(*string)
     D  format                         *   value options(*string)
     D  sexyfun                      10U 0

     D wwLen           s             10I 0
     D rc              s             10I 0
     D wwBuf           s             15A
     D wwChunkSize     S             10U 0
     D wwErr           s             10I 0

     c                   callp     http_dmsg('get_chunk_size(): entered')
     c                   eval      p_global = getGlobalPtr()

     c                   eval      wwLen = comm_LineRead( peComm
     c                                                  : %addr(wwBuf)
     c                                                  : %size(wwBuf)
     c                                                  : peTimeout )

     c                   if        wwLen < 1
     c                   callp     http_error(wwErr)
     c                   if        wwErr = HTTP_BRTIME
     c                   return    -2
     c                   else
     c                   return    -1
     c                   endif
     c                   endif

     c                   callp     http_xlate( wwLen
     c                                       : wwBuf
     c                                       : TO_EBCDIC )

     c                   eval      rc = %scan(';': wwBuf)
     c                   if        rc > 1
     c                   eval      wwBuf = %subst(wwBuf:1:rc-1)
     c                   endif

     c                   callp     sscanf(wwBuf: '%x': wwChunkSize)

     c                   callp     http_dmsg('chunk size = ' +
     c                                  %trim(%editc(wwChunkSize:'P')))

     c                   return    wwChunkSize
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_getauth(): Get HTTP Authentication Information
      *
      *   Call this proc after you receive a HTTP_NDAUTH error
      *   to determine the authentication credentials that are required
      *
      *  The following parms are returned to your program:
      *
      *     peBasic = *ON if BASIC auth is allowed
      *    peDigest = *ON if MD5 DIGEST auth is allowed
      *     peRealm = Auth realm.  Present this to the user to identify
      *               which password you're looking for.  For example
      *               if peRealm is "secureserver.com" you might say
      *               "enter password for secureserver.com" to user.
      *      peNTLM = *ON if NTLM auth is allowed
      *
      *   After getting the userid & password from the user (or database)
      *   you'll need to call http_setauth()
      *
      *  Returns -1 upon error, or 0 if successful
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_getauth    B                   export
     D http_getauth    PI            10I 0
     D   peBasic                      1N
     D   peDigest                     1N
     D   peRealm                    124A
     D   peNTLM                       1N   options(*nopass)

     D wwNTLM          S              1N   inz(*OFF)

     c                   callp     http_dmsg('http_getauth(): entered')
     c                   eval      p_global = getGlobalPtr()
     c                   if        dsAuthRealm = *blanks
      /if defined(NTLM_SUPPORT)
     c                             and not
     c                             AuthPlugin_isAuthenticationRequired()
      /endif
     c                   callp     SetError(HTTP_NOAUTH: 'Server did ' +
     c                              'not ask for authentication!')
     c                   return    -1
     c                   endif

      /if defined(NTLM_SUPPORT)
     c                   if        (AuthPlugin_isAuthenticationRequired())
     c                   eval      dsAuthRealm = AuthPlugin_getRealm()
     c                   eval      wwNTLM = *ON
     c                   endif
     c                   if        %parms() >= 4
     c                   eval      peNTLM = wwNTLM
     c                   endif
      /endif

     c                   eval      peBasic = dsAuthBasic
     c                   eval      peDigest = dsAuthDigest
     c                   eval      peRealm = dsAuthRealm

     c                   return    0
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_setauth():   Set HTTP Authentication Information
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_setauth    B                   export
     D http_setauth    PI            10I 0 opdesc
     D   peAuthType                   1A   const
     D   peUsername                  80A   const
     D   pePassword               15000A   const options(*varsize)

     D wwPasswd        s          15000A   varying
     D wwString        S           1105A
     D wwEncoded       S           1476A
     D wwEncLen        S             10I 0

     D descType        s             10i 0
     D dataType        s             10i 0
     D descInf1        s             10i 0
     D descInf2        s             10i 0
     D dataLen         s             10i 0

     D feedback        ds                  qualified
     D   Condition_ID                 4A
     D     MsgSev                     2A   overlay(Condition_ID:1)
     D     MsgNo                      2A   overlay(Condition_ID:3)
     D   Flags                        1a
     D   Facility_ID                  3A
     D   I_S_Info                     4A

     c                   callp     http_dmsg('http_setauth(): entered')
     c                   eval      p_global = getGlobalPtr()

     C*************************************************
     C* Get an OPDESC for the pePassword parameter.
     C* This is used to check its length
     C*************************************************
     c                   callp     CEEDOD( 3
     c                                   : descType
     c                                   : dataType
     c                                   : descInf1
     c                                   : descInf2
     c                                   : dataLen
     c                                   : feedback )

     C*************************************************
     C* Older releases of HTTPAPI had pePassword
     C* defined as char(1024) to maintain compatibility,
     C* if we're unable to get an OPDESC, assume that
     C* it's still passed that way.
     C*************************************************
     c                   if        feedback.Condition_ID <> x'00000000'
     c                   eval      descType = 2
     c                   eval      dataType = 2
     c                   eval      dataLen  = 1024
     c                   endif

     C*************************************************
     C* We currently only support fixed-length strings
     C*************************************************
     C                   if        descType <> 2 or dataType <> 2
     c                   callp     SetError( HTTP_ATHPDT
     c                             : 'Password must be a CHAR field.')
     c                   return    -1
     c                   endif

     C*************************************************
     C* Only use the length that was provided
     C*************************************************
     c                   if        dataLen <= 0 or dataLen > %size(pePassword)
     c                   eval      wwPasswd=''
     c                   else
     c                   eval      wwPasswd=%trim(%subst(pePassword:1:dataLen))
     c                   endif

     C*************************************************
     C* Give any authorization plugins (NTLM) a chance
     C* to handle things
     C*************************************************
      /if defined(NTLM_SUPPORT)
     c                   if        AuthPlugin_setAuthentication(
     c                                   peAuthType: peUsername: wwPasswd)
     c                   return    0
     c                   endif
      /endif

     C*************************************************
     C*  Validate the auth type
     C*************************************************
     c                   if        peAuthType<>HTTP_AUTH_BASIC
     c                               and peAuthType<>HTTP_AUTH_MD5_DIGEST
     c                               and peAuthType<>HTTP_AUTH_BEARER
     c                               and peAuthType<>HTTP_AUTH_USRDFN
     c                               and peAuthType<>HTTP_AUTH_NONE
     c                   callp     SetError(HTTP_ATHTYP: 'Invalid authenti'+
     c                                   'cation type!')
     c                   return    -1
     c                   endif

     C*************************************************
     c* Calculate strings for NO authentication
     C*************************************************
     c                   if        peAuthType = HTTP_AUTH_NONE
     c                   eval      dsAuthType = HTTP_AUTH_NONE
     c                   eval      dsAuthStr = ''
     c                   return    0
     c                   endif

     C*************************************************
     c* BASIC or DIGEST
     C*************************************************
     c                   if        peAuthType = HTTP_AUTH_BASIC
     c                             or peAuthType = HTTP_AUTH_MD5_DIGEST

     c                   if        %scan(':':peUserName) > 0
     c                   callp     SetError(HTTP_ATHVAL: 'HTTP Auth value' +
     c                               's cannot contain a colon!')
     c                   return    -1
     c                   endif

     c                   eval      dsAuthUser = peUserName
     c                   eval      dsAuthPasswd = wwPasswd

     c                   eval      wwString = %trimr(peUserName) + ':' +
     c                                        wwPasswd
     c                   callp     http_xlate( %len(%trimr(wwString))
     c                                       : wwString
     c                                       : TO_ASCII )

     c                   eval      wwEncLen = base64_encode(%addr(wwString):
     c                                             %len(%trimr(wwString)):
     c                                             %addr(wwEncoded):
     c                                             %size(wwEncoded))

     c                   eval      dsAuthStr = %subst(wwEncoded:1:wwEncLen)
     c                   endif

     c*************************************************
     c* BEARER TOKEN (OAuth2, et al)
     c*************************************************
     c                   if        peAuthType = HTTP_AUTH_BEARER
     c                   eval      dsAuthUser = ''
     c                   eval      dsAuthPasswd = ''
     c                   eval      dsAuthStr = 'Bearer ' + wwPasswd
     c                   endif

     c*************************************************
     c* User Defined
     c*************************************************
     c                   if        peAuthType = HTTP_AUTH_USRDFN
     c                   eval      dsAuthUser = peUserName
     c                   eval      dsAuthPasswd = wwPasswd
     c                   eval      dsAuthStr = %trim(peUserName)
     c                                       + ' ' + wwPasswd
     c                   endif

     c                   eval      dsAuthType = peAuthType
     c                   return    0
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * setUrlAuth(): Set auth credentials if found in the URL
      *      peUsername = username found in URL
      *      pePasswd   = password found in URL
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P setUrlAuth      B
     D setUrlAuth      PI
     D   peUsername                  80A   const
     D   pePasswd                  1024A   const
     c                   if        peUsername = *blanks
     c                              and pePasswd = *blanks
     c                   eval      wkSaveAuth = *blanks
     c                   return
     c                   endif

     c                   eval      wkSaveAuth = dsAuth

     c                   if        dsAuthRealm = *blanks
     c                               or dsAuthDigest = *OFF
     c                   callp     http_setAuth( HTTP_AUTH_BASIC
     c                                         : peUsername
     c                                         : pePasswd )
     c                   else
     c                   callp     http_setAuth( HTTP_AUTH_MD5_DIGEST
     c                                         : peUsername
     c                                         : pePasswd )
     c                   endif
     c                   return
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  mkdigest():  Create a digest authorization string
      *
      *      peMethod = HTTP method in use (GET or POST)
      *
      *  Returns the digest authorization response
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P mkdigest        B
     D mkdigest        PI         32767A   varying
     D   peMethod                    10A   varying const
     D   peURI                    32767A   varying const options(*varsize)

     D wwRet           S          32767A   varying
     D wwWork          S          32767A   varying
     D wwA1            S             32A
     D wwA2            S             32A
     D wwResp          S             32A

     c                   callp     http_dmsg('mkdigest(): entered')
     c                   eval      p_global = getGlobalPtr()
     C*  Authorization: Digest username="Mufasa",
     C*         realm="testrealm@host.com",
     C*         nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
     C*         uri="/dir/index.html",
     C*         nc=00000001,
     C*         cnonce="0a4f113b",
     C*         response="6629fae49393a05397450978507c4ef1",
     C*         opaque="5ccc069c403ebaf9f0171e9517f40e41"

     c*  response =
     C*     md5(md5(A1) + ':' + nonce + ':' + nc-value + ':' +
     c*          cnonce + ':' + qop + ':' md5(A2))
     C*  A1 = username + ':' + realm + ':' + passwd
     C*  A2 = method + ':' + uri
     C*
     C*  realm = passed from server
     C*  nonce = passed from server
     C*  nc = count of uses of nonce so far
     C*  qop = auth (if that's a choice on this server)
     C*  cnonce = 8-char hex string that we make up
     C*  opaque = passed by server
     C*  method = GET or POST
     C*  username & password are supplied by the user
     C*  we should know the URI when the request is made

      * FIXME: This CNonce ("client nonce") should be different
      *    with every request, not a fixed string.
     c                   eval      dsAuthCNonce = '7248e2a3711545e8'
     c                   eval      dsAuthNC = dsAuthNC + 1

     c                   eval      wwWork = %trim(dsAuthUser) + ':' +
     c                                      %trim(dsAuthRealm) + ':' +
     c                                      %trim(dsAuthPasswd)
     c                   if        md5( %addr(wwWork)+VARPREF
     c                                : %len(wwWork)
     c                                : wwA1 ) = *OFF
     c                   return    '*error'
     c                   endif

     c                   eval      wwWork = %trim(peMethod) + ':' +
     c                                      %trim(peURI)
     c                   if        md5( %addr(wwWork)+VARPREF
     c                                : %len(wwWork)
     c                                : wwA2 ) = *OFF
     c                   return    '*error'
     c                   endif

     c                   if        %scan('auth': dsAuthQop) > 0
     c                   eval      wwWork = wwA1 + ':' +
     c                                      %trim(dsAuthNonce) + ':' +
     c                                      '0'+%editc(dsAuthNC:'X') + ':' +
     c                                      dsAuthCnonce + ':' +
     c                                      'auth' + ':' +
     c                                      wwA2
     c                   else
     c                   eval      wwWork = wwA1 + ':' +
     c                                      %trim(dsAuthNonce) + ':' +
     c                                      wwA2
     c                   endif

     c                   if        md5( %addr(wwWork)+VARPREF
     c                                : %len(wwWork)
     c                                : wwResp ) = *OFF
     c                   return    '*error'
     c                   endif

     c                   eval      wwRet =
     c                               'username="' +%trim(dsAuthUser)+ '", '+
     c                               'realm="' +%trim(dsAuthRealm)+ '", '+
     c                               'nonce="' +%trim(dsAuthNonce)+ '", '+
     c                               'uri="' +%trim(peURI)+ '", '+
     c                               'response="' + wwResp + '"'

     c                   if        %scan('auth': dsAuthQop) > 0
     c                   eval      wwRet = %trimr(wwRet) + ', ' +
     c                               'algorithm=MD5, ' +
     c                               'nc=0' + %editc(dsAuthNC:'X') + ', ' +
     c                               'cnonce="' + dsAuthCNonce +'", ' +
     c                               'qop="auth"'
     c                   endif

     c                   if        dsAuthOpaque <> *blanks
     c                   eval      wwRet = %trimr(wwRet) + ', ' +
     c                                 'opaque="' + %trim(dsAuthOpaque)+'"'
     c                   endif

     c                   return    wwRet
     P                 E


     P*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P* Interpret (parse & save) the WWW-Authenticate: header
     P*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P interpret_auth  B
     D interpret_auth  PI
     D   peRespChain               2048A   const
     D   peKwdPos                    10I 0 value
     D   peResetAuth                   N   value

     D wwCh            S              1A
     D wwAuth          S           2048A
     D wwPos1          S             10I 0
     D wwPos2          S             10I 0
     D wwLen           S             10I 0
     D p_Word          S               *
     D p_Next          S               *
     D wwWord          S             30A
     D TAB             C                   CONST(x'05')
     D wwOrigNonce     S            128A
     D LF              S              1A   inz(x'25') static

     d strtok          PR              *   extproc('strtok')
     d   nextpos                       *   value
     d   delim                         *   value options(*string)

     c                   callp     http_dmsg('interpret_auth(): entered')
     c                   eval      p_global = getGlobalPtr()
     c                   eval      wwOrigNonce = dsAuthNonce

     c                   if        peResetAuth
     c                   eval      dsAuthBasic = *OFF
     c                   eval      dsAuthDigest = *OFF
     c                   eval      dsAuthDigest = *OFF
     c                   eval      dsAuthRealm = *blanks
     c                   eval      dsAuthNonce = *blanks
     c                   eval      dsAuthOpaque = *blanks
     c                   eval      dsAuthQOP = *blanks
     c                   eval      dsAuthCNonce = *blanks
      /if defined(NTLM_SUPPORT)
     c                   callp     AuthPlugin_resetAuthentication()
      /endif
     c                   endif

     C*********************************************************
     C* extract the value of this keyword (and nothing else)
     C*********************************************************
     c                   eval      wwPos1 =%scan(':':peRespChain:peKwdPos+1)
     c                   eval      peKwdPos = wwPos1 + 1

     c                   dou       wwCh<>' ' and wwCh<>TAB
     c                   eval      wwPos2 = %scan(LF: peRespChain:
     c                                            wwPos1)
     c                   if        wwPos2 < wwPos1
     c                   leave
     c                   endif
     c                   eval      wwPos1 = wwPos2
     c                   eval      wwCh = %subst(peRespChain:wwPos2+1:1)
     c                   enddo

     c                   if        wwPos1 < peKwdPos
     C*             shouldn't happen
     c                   return
     c                   endif

     c                   eval      wwLen = (wwPos1 - peKwdPos) + 1
     c                   eval      wwAuth = %subst( peRespChain:
     c                                              peKwdPos: wwLen) + x'00'
     c                   eval      p_Next = %addr(wwAuth)

      *********************************************************
      * First let the authentication plugin interpret the
      * authentication header, because strtok() damages
      * wwAuth.
      *********************************************************
      /if defined(NTLM_SUPPORT)
     c                   callp     AuthPlugin_interpretAuthenticationHeader(
     c                                                                 wwAuth)
      /endif

     C*********************************************************
     C* Extract one word at a time from the list.  If the word
     C* is something we can use, save it's value to our DS
     C*********************************************************
     c                   dow       1 = 1

     c                   eval      p_Word = strtok(p_Next: ' =,'+TAB)
     c                   if        p_Word = *NULL
     c                   leave
     c                   endif
     c                   eval      p_Next = *NULL

     c                   eval      wwWord = %str(p_Word)

     c     upper:lower   xlate     wwWord        wwWord

     c                   select
     c                   when      wwWord=*blanks
     c                   iter

     c                   when      wwWord = 'basic'
     c                   eval      dsAuthBasic = *on

     c                   when      wwWord = 'digest'
     c                   eval      dsAuthDigest = *on

     c                   when      wwWord = 'realm'
     c                   eval      p_Word = strtok(*NULL: '"')
     c                   if        p_word <> *NULL
     c                   eval      dsAuthRealm = %str(p_word)
     c                   endif

     c                   when      wwWord = 'qop'
     c                   eval      p_Word = strtok(*NULL: '"')
     c                   if        p_word <> *NULL
     c                   eval      dsAuthQOP = %str(p_word)
     c                   endif

     c                   when      wwWord = 'nonce'
     c                   eval      p_Word = strtok(*NULL: '"')
     c                   if        p_word <> *NULL
     c                   eval      dsAuthNonce = %str(p_word)
     c                   if        wwOrigNonce <> dsAuthNonce
     c                   eval      dsAuthNC = 0
     c                   endif
     c                   endif

     c                   when      wwWord = 'opaque'
     c                   eval      p_Word = strtok(*NULL: '"')
     c                   if        p_word <> *NULL
     c                   eval      dsAuthOpaque = %str(p_word)
     c                   endif
     c                   endsl

     c                   enddo

     c                   return
     P                 E

     P*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P* Interpret (parse & save) the Proxy-Authenticate: header
     P*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P interpret_proxy_auth...
     P                 B
     D interpret_proxy_auth...
     D                 PI
     D   peRespChain               2048A   const
     D   peKwdPos                    10I 0 value

     D wwCh            S              1A
     D wwAuth          S           2048A
     D wwPos1          S             10I 0
     D wwPos2          S             10I 0
     D wwLen           S             10I 0
     D TAB             C                   CONST(x'05')
     D LF              S              1A   inz(x'25') static

     c                   callp     http_dmsg('interpret_proxy_auth(): entered')
     c                   eval      p_global = getGlobalPtr()

     C*********************************************************
     C* extract the value of this keyword (and nothing else)
     C*********************************************************
     c                   eval      wwPos1 =%scan(':':peRespChain:peKwdPos+1)
     c                   eval      peKwdPos = wwPos1 + 1

     c                   dou       wwCh<>' ' and wwCh<>TAB
     c                   eval      wwPos2 = %scan(LF: peRespChain:
     c                                            wwPos1)
     c                   if        wwPos2 < wwPos1
     c                   leave
     c                   endif
     c                   eval      wwPos1 = wwPos2
     c                   eval      wwCh = %subst(peRespChain:wwPos2+1:1)
     c                   enddo

     c                   if        wwPos1 < peKwdPos
     C*             shouldn't happen
     c                   return
     c                   endif

     c                   eval      wwLen = (wwPos1 - peKwdPos) + 1
     c                   eval      wwAuth = %subst( peRespChain:
     c                                              peKwdPos: wwLen)

     C*********************************************************
     C* Check if we deal with basic authentication
     C*********************************************************
     c     upper:lower   xlate     peRespChain   wwAuth

     c                   eval      wwPos1 = %scan('basic':wwAuth)
     c                   if        wwPos1 > 0
     c                   eval      dsProxyAuthBasic = *on

     c* Extract the realm, if provided
     c                   eval      wwPos1 = %scan('realm="': wwAuth:
     c                                  wwPos1)
     c                   if        wwPos1 > 0
     c                   eval      wwPos1 = wwPos1 + 7
     c                   eval      wwPos2 = %scan('"': wwAuth: wwPos1)
     c                   if        wwPos2 > wwPos1
     c                   eval      wwLen = wwPos2 - wwPos1
     c                   eval      dsProxyAuthRealm = %subst(peRespChain:
     c                                  wwPos1: wwLen)
     c                   endif
     c                   endif
     c                   endif

     c                   return
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_xproc():  Register a procedure to be called back at
      *                 a given exit point
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_xproc      B                   export
     D http_xproc      PI            10I 0
     D  peExitPoint                  10I 0 value
     D  peProc                         *   procptr value
     D  peUserData                     *   value options(*nopass)

     D wwUserData      s               *   inz(*NULL)

     c                   eval      p_global = getGlobalPtr()

     c                   if        %parms >= 3
     c                   eval      wwUserData = peUserData
     c                   endif

     c                   select
     c                   when      peExitPoint = HTTP_POINT_DEBUG
     c                   callp     debug_setproc(peProc: wwUserData)
     c                   when      peExitPoint = HTTP_POINT_UPLOAD_STATUS
     c                   eval      wkUplProc = peProc
     c                   eval      wkUplUData = wwUserData
     c                   when      peExitPoint = HTTP_POINT_DOWNLOAD_STATUS
     c                   eval      wkDwnlProc = peProc
     c                   eval      wkDwnlUData = wwUserData
     c                   when      peExitPoint = HTTP_POINT_ADDL_HEADER
     c                   eval      wkAddHdrProc = peProc
     c                   eval      wkAddHdrData = wwUserData
     c                   when      peExitPoint = HTTP_POINT_PARSE_HEADER
     c                   eval      wkParseHdrProc = peProc
     c                   eval      wkParseHdrData = wwUserData
     c                   when      peExitPoint = HTTP_POINT_PARSE_HDR_LONG
     c                   eval      wkParseHdrLong = peProc
     c                   eval      wkParseHdrLongData = wwUserData
     c                   when      peExitPoint = HTTP_POINT_PARSE_HDR_LONG
     c                   eval      wkParseHdrLong = peProc
     c                   eval      wkParseHdrLongData = wwUserData
      /if defined(HAVE_SSLAPI)
     c                   when      peExitPoint = HTTP_POINT_CERT_VAL
     c                   callp     commssl_setxproc( peExitPoint
     c                                             : peProc
     c                                             : wwUserData )
     c                   when      peExitPoint = HTTP_POINT_GSKIT_CERT_VAL
     c                   callp     commssl_setxproc( peExitPoint
     c                                             : peProc
     c                                             : wwUserData )
      /endif
     c                   other
     c                   callp     SetError(HTTP_BADPNT: 'Invalid exit ' +
     c                               'point!')
     c                   return    -1
     c                   endsl

     c                   return    0
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_redir_loc(): Retrieve location provided by a redirect
      *   request.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_redir_loc  B                   export
     D http_redir_loc  PI          1024A   varying
     c                   return    wkRedirLoc
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_redir_loc_long(): Retrieve location provided by a redirect
      *   request -- returning a longer string.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_redir_loc_long...
     P                 B                   export
     D                 PI         32767A   varying
     c                   return    wkRedirLoc
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_long_ParseURL(): Parse URL into it's component parts
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_long_ParseURL...
     P                 B                   export
     d http_long_ParseURL...
     D                 PI            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  peService                    32A
     D  peUserName                   32A
     D  pePassword                   32A
     D  peHost                      256A
     D  pePort                       10I 0
     D  pePath                    32767A   varying

     D wwLen           S             10I 0
     D wwURL           S          32767A   varying
     D wwTemp          S             65A
     D wwPos           S             10I 0
     D wwRChk          S              4A
     D wwFound         S             10I 0

     D wwRelOk         s              1N   inz(*OFF)    static
     D wwLastRel       s                   like(wwURL)  static
     D wwLastPath      s                   like(pePath) static
     D NUMBERS         C                   const('0123456789')

     c                   callp     http_dmsg('http_long_ParseURL(): ' +
     c                                       'entered')

     c                   eval      peService = *Blanks
     c                   eval      peUserName = *blanks
     c                   eval      pePassword = *blanks
     c                   eval      peHost = *blanks
     c                   eval      pePort = 0
     c                   eval      pePath = *blanks
     c                   eval      wwURL = peURL

     c                   if        %len(peURL)<1 or peURL=*blanks
     c                   callp     SetError( HTTP_BADURL
     c                                     : 'URL is blank.')
     c                   return    -1
     c                   endif

      ****************************************************************
      * If this is a relative URL and we have a host & path saved
      * from a previous URL, convert it from a relative to an
      * absolute URL.
      ****************************************************************
     c                   if        wwRelOk = *ON
     c                               and %scan('://': peURL) = 0

     c                   callp     http_dmsg('Converting relative URL.')

     c                   if        %len(peURL)>=1
     c                               and %subst(peURL:1:1) = '/'
     c                   eval      wwURL = wwLastRel + peURL
     c                   else
     c                   eval      wwURL = wwLastRel + wwLastPath
     c                                   + peURL
     c                   endif

     c                   callp     http_dmsg('New URL is ' + wwURL)

     c                   endif

     C****************************************************************
     C*  A valid HTTP url should look like:
     C*      http://www.server.com/somedir/somefile.ext
     C*     https://www.server.com/somedir/somefile.ext
     C*
     C*  and may optionally contain a user name, password & port number:
     C*
     C*     http://user:passwd@www.server.com:80/somedir/somefile.ext
     C****************************************************************

     C* First, extract the URL's "scheme" (which in the case of http
     C*  is the service's name as well):
     c                   eval      wwPos = %scan(':': wwURL)
     c                   if        wwPos < 2 or wwPos > (%len(wwURL)-1)
     c                   callp     SetError(HTTP_BADURL:'Relative URLs '+
     c                              'are not supported!')
     c                   return    -1
     c                   endif

     c                   eval      peService = %subst(wwURL:1:wwPos-1)
     c                   eval      wwURL = %subst(wwURL:wwPos+1)
     c     upper:lower   xlate     peService     peService

      /if defined(HAVE_SSLAPI)
     c                   if        peService<>'http' and peService<>'https'
     c                   callp     SetError(HTTP_BADURL:'Only the http and'+
     c                              ' https protocols are available!')
     c                   return    -1
     c                   endif
      /else
     c                   if        peService<>'http'
     c                   callp     SetError(HTTP_BADURL:'Only the http ' +
     c                              'protocol is available!')
     c                   return    -1
     c                   endif
      /endif

     C* now the URL should be //www.server.com/mydir/somefile.ext!
     C*   make sure it does start with the //, and strip that off.

     c                   if        %len(wwURL) >= 2
     c                               and %subst(wwURL:1:2) <> '//'
     c                   callp     SetError(HTTP_BADURL:'Relative URLs '+
     c                              'are not supported!')
     c                   return    -1
     c                   endif

     c                   eval      wwURL = %subst(wwURL:3)

     C* now, either everything up to the first '/' is part of the
     C*  host name, or the entire string is a hostname.

     c                   eval      wwPos = %scan('/': wwURL)
     c                   if        wwPos = 0
     c                   eval      wwPos = %len(wwURL) + 1
     c                   endif

     c                   eval      peHost = %subst(wwURL:1:wwPos-1)
     c                   if        wwPos > %len(wwURL)
     c                   eval      wwURL = ''
     c                   else
     c                   eval      wwURL = %subst(wwURL:wwPos)
     c                   endif

     C* the host name may optionally contain a user name,
     C*  and possibly also a password.

     C* find the last @ symbol in the host name.  It's important
     C* to use the last one, in case the userid is an e-mail address.
     C* for example:
     c*  http://bob@nospam.com:bigboy@www.scottklement.com
     c                   eval      wwPos = 0
     c                   eval      wwFound = %scan('@': peHost)
     c                   dow       wwFound > 1 and wwFound < %size(peHost)
     c                   eval      wwPos = wwFound
     c                   eval      wwFound = %scan('@': peHost: wwFound+1)
     c                   enddo

     C* if @ was found, look for userid/password:
     c                   if        wwPos > 1 and wwPos < %size(peHost)
     c                   eval      wwTemp = %subst(peHost:1:wwPos-1)
     c                   eval      peHost = %subst(peHost:wwPos+1)
     c                   eval      wwPos = %scan(':': wwTemp)
     c                   if        wwPos > 1 and wwPos < %size(wwTemp)
     c                   eval      peUserName = %subst(wwTemp:1:wwPos-1)
     c                   eval      pePassword = %subst(wwTemp:wwPos+1)
     c                   else
     c                   eval      peUserName = wwTemp
     c                   endif
     c                   endif

     C* the host name may also specify a port number:
     c                   eval      wwPos = %scan(':': peHost)
     c                   if        wwPos > 1 and wwPos < %size(peHost)
     c                   eval      wwTemp = %subst(peHost:wwPos+1)
     c                   eval      peHost = %subst(peHost:1:wwPos-1)
     c                   if        %check(NUMBERS: %trimr(wwTemp))=0
     c                   eval      pePort = atoi(%trimr(wwTemp))
     c                   else
     c                   callp     SetError(HTTP_BADURL: 'URL contains'+
     c                              ' a bad port number!')
     c                   return    -1
     c                   endif
     c                   endif

     c* After all that, do we still have a hostname?
     c                   if        peHost=*blanks
     c                   callp     SetError(HTTP_BADURL:'URL does not'+
     c                              ' contain a hostname!')
     c                   return    -1
     c                   endif

     C* Whatever is left should now be the pathname to the file itself.
     C* (or is a parameter or query string for a CGI script)
     c                   eval      pePath = wwURL
     c                   if        %len(pePath)<1 or pePath=*blanks
     c                   eval      pePath = '/'
     c                   endif

     C*
     C*  Replace any blanks in the URL with %20 (like a browser does)
     C*
     c                   eval      pePath = %trimr(pePath)
     c                   eval      wwPos = %scan(' ': pePath)
     c                   dow       wwPos > 0
     c                   eval      pePath = %replace( '%20'
     c                                              : pePath
     c                                              : wwPos
     c                                              : 1 )
     c                   eval      wwPos = %scan(' ': pePath: wwPos)
     c                   enddo

      *
      * Save information about this URL so that we can use it to
      * figure out subsequent "relative" URLs.
      *
     c                   eval      wwLastRel = %trimr(peService) + '://'
     c                   if        peUserName <> *blanks
     c                   eval      wwLastRel = wwLastRel
     c                                       + %trim(peUserName)
     c                   if        pePassword <> *blanks
     c                   eval      wwLastRel = wwLastRel + ':'
     c                                       + %trim(pePassword)
     c                   endif
     c                   eval      wwLastRel = wwLastRel + '@'
     c                   endif
     c                   eval      wwLastRel = wwLastRel + %trim(peHost)
     c                   if        pePort <> 0
     c                   eval      wwLastRel = wwLastRel + ':'
     c                                       + %trim(%editc(pePort:'Z'))
     c                   endif

     c                   eval      wwPos = %len(pePath)
     c                   dou       wwPos <= 1
     c                   if        %subst(pePath:wwPos:1) = '/'
     c                   eval      wwLastPath = %subst(pePath:1:wwPos)
     c                   leave
     c                   endif
     c                   eval      wwPos = wwPos -1
     c                   enddo

     c                   eval      wwRelOk = *ON

     c                   return    0
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_url_get(): Retrieve an HTTP document (to a file)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_url_get    B                   export
     D http_url_get    PI            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  peFilename                32767A   varying const options(*varsize)
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peReserved                   64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)

     D wwFD            S             10I 0
     D rc              S             10I 0

     c                   callp     SetRespCode(0)
     c                   callp     http_dmsg('http_url_get(): entered')
     c                   eval      p_global = getGlobalPtr()

      *********************************************************
      * open file for writing (O_WRONLY = write only)
      *    if it exists, truncate it (O_TRUNC = truncate)
      *    if it doesnt, create it (O_CREAT = create)
      *    and assign the remote codepage to it.
      *********************************************************
     c                   eval      wwFD = open( %trimr(peFilename)
     c                                        : O_WRONLY
     c                                          + O_TRUNC
     c                                          + O_CREAT
     c                                          + CCSID_OR_CP
     c                                          + O_LARGEFILE
     c                                        : global.file_mode
     c                                        : FILE_CCSID())
     c                   if        wwFD < 0
     c                   callp     SetError(HTTP_FDOPEN:'open(): ' +
     c                               %str(strerror(errno)) )
     c                   return    -1
     c                   endif

      *********************************************************
      *  Call the 'raw' get procedure, telling it to use
      *  the IFS API called 'write' to write data.
      *********************************************************
     c                   select
     c                   when      %parms < 3
     c                   eval      rc = http_url_get_raw(peURL: wwFD:
     c                               %paddr('write'))
     c                   when      %parms < 4
     c                   eval      rc = http_url_get_raw(peURL: wwFD:
     c                               %paddr('write'): peTimeout)
     c                   when      %parms < 5
     c                   eval      rc = http_url_get_raw(peURL: wwFD:
     c                               %paddr('write'): peTimeout:
     c                               peUserAgent)
     c                   when      %parms < 6
     c                   eval      rc = http_url_get_raw(peURL: wwFD:
     c                               %paddr('write'): peTimeout:
     c                               peUserAgent: peModTime)
     c                   when      %parms < 7
     c                   eval      rc = http_url_get_raw(peURL: wwFD:
     c                               %paddr('write'): peTimeout:
     c                               peUserAgent: peModTime: peReserved)
     c                   other
     c                   eval      rc = http_url_get_raw(peURL: wwFD:
     c                               %paddr('write'): peTimeout:
     c                               peUserAgent: peModTime: peReserved:
     c                               peSOAPAction)
     c                   endsl

     c                   callp     close(wwFD)

     c                   return    rc
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_url_post(): Post data to CGI script and get document
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_url_post   B                   export
     D http_url_post   PI            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peFilename                32767A   varying const options(*varsize)
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)

     D wwFD            S             10I 0
     D rc              S             10I 0

     c                   callp     SetRespCode(0)
     c                   callp     http_dmsg('http_url_post(): entered')
     c                   eval      p_global = getGlobalPtr()

      *********************************************************
      * open file for writing (O_WRONLY = write only)
      *    if it exists, truncate it (O_TRUNC = truncate)
      *    if it doesnt, create it (O_CREAT = create)
      *    and assign the remote codepage to it.
      *********************************************************
     c                   eval      wwFD = open( %trimr(peFilename)
     c                                        : O_WRONLY
     c                                          + O_TRUNC
     c                                          + O_CREAT
     c                                          + CCSID_OR_CP
     c                                          + O_LARGEFILE
     c                                        : global.file_mode
     c                                        : FILE_CCSID())
     c                   if        wwFD < 0
     c                   callp     SetError(HTTP_FDOPEN:'open(): ' +
     c                               %str(strerror(errno)) )
     c                   return    -1
     c                   endif

      *********************************************************
      *  Call the 'raw' post procedure, telling it to use
      *  the IFS API called 'write' to write data.
      *********************************************************
     c                   select
     c                   when      %parms < 5
     c                   eval      rc = http_url_post_raw(peURL:
     c                               pePostData: pePostDataLen:
     c                               wwFD: %paddr('write'))
     c                   when      %parms < 6
     c                   eval      rc = http_url_post_raw(peURL:
     c                               pePostData: pePostDataLen:
     c                               wwFD: %paddr('write'): peTimeout)
     c                   when      %parms < 7
     c                   eval      rc = http_url_post_raw(peURL:
     c                               pePostData: pePostDataLen:
     c                               wwFD: %paddr('write'): peTimeout:
     c                               peUserAgent)
     c                   when      %parms < 8
     c                   eval      rc = http_url_post_raw(peURL:
     c                               pePostData: pePostDataLen:
     c                               wwFD: %paddr('write'): peTimeout:
     c                               peUserAgent: peContentType)
     c                   other
     c                   eval      rc = http_url_post_raw(peURL:
     c                               pePostData: pePostDataLen:
     c                               wwFD: %paddr('write'): peTimeout:
     c                               peUserAgent: peContentType:
     c                               peSOAPAction)
     c                   endsl

     c                   callp     close(wwFD)

     c                   return    rc
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_url_get_raw(): Retrieve an HTTP document (in raw mode)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_url_get_raw...
     P                 B                   export
     D http_url_get_raw...
     D                 PI            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  peFD                         10I 0 value
     D  peProc                         *   value procptr
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peReserved                   64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)

     D wwComm          s               *
     D rc              s             10I 0

     c                   callp     SetRespCode(0)
     c                   eval      p_global = getGlobalPtr()

      *********************************************************
      * Connect.
      *********************************************************
     c                   if        %parms < 4
     c                   eval      wwComm = http_persist_open( peURL )
     c                   else
     c                   eval      wwComm = http_persist_open( peURL
     c                                                       : peTimeout )
     c                   endif

     c                   if        wwComm = *NULL
     c                   return    -1
     c                   endif

      *********************************************************
      * Get.
      *********************************************************
     c                   select
     c                   when      %parms < 4
     c                   eval      rc = http_persist_get( wwComm
     c                                                  : peURL
     c                                                  : peFD
     c                                                  : peProc )
     c                   when      %parms < 5
     c                   eval      rc = http_persist_get( wwComm
     c                                                  : peURL
     c                                                  : peFD
     c                                                  : peProc
     c                                                  : peTimeout )
     c                   when      %parms < 6
     c                   eval      rc = http_persist_get( wwComm
     c                                                  : peURL
     c                                                  : peFD
     c                                                  : peProc
     c                                                  : peTimeout
     c                                                  : peUserAgent )
     c                   when      %parms < 7
     c                   eval      rc = http_persist_get( wwComm
     c                                                  : peURL
     c                                                  : peFD
     c                                                  : peProc
     c                                                  : peTimeout
     c                                                  : peUserAgent
     c                                                  : peModTime )
     c                   when      %parms < 8
     c                   eval      rc = http_persist_get( wwComm
     c                                                  : peURL
     c                                                  : peFD
     c                                                  : peProc
     c                                                  : peTimeout
     c                                                  : peUserAgent
     c                                                  : peModTime
     c                                                  : peReserved )
     c                   other
     c                   eval      rc = http_persist_get( wwComm
     c                                                  : peURL
     c                                                  : peFD
     c                                                  : peProc
     c                                                  : peTimeout
     c                                                  : peUserAgent
     c                                                  : peModTime
     c                                                  : peReserved
     c                                                  : peSoapAction )
     c                   endsl

      *********************************************************
      * Disconnect.
      *********************************************************
     c                   callp     http_persist_close( wwComm )
     c                   return    rc
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_url_post_raw(): Post data to CGI script and get document
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_url_post_raw...
     P                 B                   export
     D http_url_post_raw...
     D                 PI            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peFD                         10I 0 value
     D  peProc                         *   value procptr
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)

     D wwComm          s               *
     D rc              s             10I 0

     c                   callp     SetRespCode(0)
     c                   eval      p_global = getGlobalPtr()

      *********************************************************
      * Connect.
      *********************************************************
     c                   if        %parms < 6
     c                   eval      wwComm = http_persist_open( peURL )
     c                   else
     c                   eval      wwComm = http_persist_open( peURL
     c                                                       : peTimeout )
     c                   endif

     c                   if        wwComm = *NULL
     c                   return    -1
     c                   endif

      *********************************************************
      * Post.
      *********************************************************
     c                   select
     c                   when      %parms < 6
     c                   eval      rc = http_persist_post( wwComm
     c                                                   : peURL
     c                                                   : 0
     c                                                   : *NULL
     c                                                   : pePostData
     c                                                   : pePostDataLen
     c                                                   : peFD
     c                                                   : peProc )

     c                   when      %parms < 7
     c                   eval      rc = http_persist_post( wwComm
     c                                                   : peURL
     c                                                   : 0
     c                                                   : *NULL
     c                                                   : pePostData
     c                                                   : pePostDataLen
     c                                                   : peFD
     c                                                   : peProc
     c                                                   : peTimeout )

     c                   when      %parms < 8
     c                   eval      rc = http_persist_post( wwComm
     c                                                   : peURL
     c                                                   : 0
     c                                                   : *NULL
     c                                                   : pePostData
     c                                                   : pePostDataLen
     c                                                   : peFD
     c                                                   : peProc
     c                                                   : peTimeout
     c                                                   : peUserAgent )
     c

     c                   when      %parms < 9
     c                   eval      rc = http_persist_post( wwComm
     c                                                   : peURL
     c                                                   : 0
     c                                                   : *NULL
     c                                                   : pePostData
     c                                                   : pePostDataLen
     c                                                   : peFD
     c                                                   : peProc
     c                                                   : peTimeout
     c                                                   : peUserAgent
     c                                                   : peContentType )

     c                   when      %parms < 10
     c                   eval      rc = http_persist_post( wwComm
     c                                                   : peURL
     c                                                   : 0
     c                                                   : *NULL
     c                                                   : pePostData
     c                                                   : pePostDataLen
     c                                                   : peFD
     c                                                   : peProc
     c                                                   : peTimeout
     c                                                   : peUserAgent
     c                                                   : peContentType
     c                                                   : peSOAPAction )
     c                   endsl

      *********************************************************
      * Disconnect.
      *********************************************************
     c                   callp     http_persist_close( wwComm )
     c                   return    rc
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_select_commdriver():  Select & initialize communications
      *    driver.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_select_commdriver...
     P                 B                   export
     D http_select_commdriver...
     D                 PI              *
     D   peCommType                  32A   const

     c                   select
     c                   when      peCommType = 'http'
     c                   eval      p_CommNew = %paddr('COMMTCP_NEW')
      /if defined(HAVE_SSLAPI)
     c                   when      peCommType = 'https'
     c                   eval      p_CommNew = %paddr('COMMSSL_NEW')
      /endif
     c                   other
     c                   callp     SetError( HTTP_NOCDRIV
     c                                     : 'No comm driver to handle '
     c                                     +  %trimr(peCommType)
     c                                     +  ' protocool' )
     c                   return    *NULL
     c                   endsl

     c                   eval      p_CommDriver = comm_new
     c                   return    p_CommDriver
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_url_post_raw2(): Post data to CGI script and get document
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_url_post_raw2...
     P                 B                   export
     D http_url_post_raw2...
     D                 PI            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostFD                     10I 0 value
     D  pePostProc                     *   procptr value
     D  peDataLen                    10I 0 value
     D  peSaveFD                     10I 0 value
     D  peSaveProc                     *   value procptr
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)
     D  peDataLen64                  20i 0 value options(*nopass)

     D wwComm          s               *
     D rc              s             10I 0

     c                   callp     SetRespCode(0)
     c                   eval      p_global = getGlobalPtr()

      *********************************************************
      * Connect.
      *********************************************************
     c                   if        %parms < 7
     c                   eval      wwComm = http_persist_open( peURL )
     c                   else
     c                   eval      wwComm = http_persist_open( peURL
     c                                                       : peTimeout )
     c                   endif

     c                   if        wwComm = *NULL
     c                   return    -1
     c                   endif

      *********************************************************
      * Post.
      *********************************************************
     c                   select
     c                   when      %parms < 7
     c                   eval      rc = http_persist_post( wwComm
     c                                                   : peURL
     c                                                   : pePostFD
     c                                                   : pePostProc
     c                                                   : *NULL
     c                                                   : peDataLen
     c                                                   : peSaveFD
     c                                                   : peSaveProc )

     c                   when      %parms < 8
     c                   eval      rc = http_persist_post( wwComm
     c                                                   : peURL
     c                                                   : pePostFD
     c                                                   : pePostProc
     c                                                   : *NULL
     c                                                   : peDataLen
     c                                                   : peSaveFD
     c                                                   : peSaveProc
     c                                                   : peTimeout  )

     c                   when      %parms < 9
     c                   eval      rc = http_persist_post( wwComm
     c                                                   : peURL
     c                                                   : pePostFD
     c                                                   : pePostProc
     c                                                   : *NULL
     c                                                   : peDataLen
     c                                                   : peSaveFD
     c                                                   : peSaveProc
     c                                                   : peTimeout
     c                                                   : peUserAgent )

     c                   when      %parms < 10
     c                   eval      rc = http_persist_post( wwComm
     c                                                   : peURL
     c                                                   : pePostFD
     c                                                   : pePostProc
     c                                                   : *NULL
     c                                                   : peDataLen
     c                                                   : peSaveFD
     c                                                   : peSaveProc
     c                                                   : peTimeout
     c                                                   : peUserAgent
     c                                                   : peContentType )

     c                   when      %parms < 11
     c                   eval      rc = http_persist_post( wwComm
     c                                                   : peURL
     c                                                   : pePostFD
     c                                                   : pePostProc
     c                                                   : *NULL
     c                                                   : peDataLen
     c                                                   : peSaveFD
     c                                                   : peSaveProc
     c                                                   : peTimeout
     c                                                   : peUserAgent
     c                                                   : peContentType
     c                                                   : peSOAPAction )

     c                   other
     c                   eval      rc = http_persist_post( wwComm
     c                                                   : peURL
     c                                                   : pePostFD
     c                                                   : pePostProc
     c                                                   : *NULL
     c                                                   : peDataLen
     c                                                   : peSaveFD
     c                                                   : peSaveProc
     c                                                   : peTimeout
     c                                                   : peUserAgent
     c                                                   : peContentType
     c                                                   : peSOAPAction
     c                                                   : peDataLen64 )
     c                   endsl

      *********************************************************
      * Disconnect.
      *********************************************************
     c                   callp     http_persist_close( wwComm )
     c                   return    rc
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_url_post_stmf(): Post data to CGI script from stream file
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_url_post_stmf...
     P                 B                   export
     D http_url_post_stmf...
     D                 PI            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostFile                32767A   varying const options(*varsize)
     D  peRecvFile                32767A   varying const options(*varsize)
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)

     D wwPostFD        S             10I 0
     D wwRecvFD        S             10I 0
     D wwDataSize      s             10I 0
     D wwDataSize64    s             20I 0
     D rc              S             10I 0
     D wwStat          ds                  likeds(statds64)
     D wwTimeout       s                   like(peTimeout) inz(HTTP_TIMEOUT)
     D p_UserAgent     s               *   inz(*null)
     D wwUserAgent     s          16384a   varying
     D                                     based(p_UserAgent)
     D stgUserAgent    s          16384a   varying
     D p_ContentType   s               *   inz(*null)
     D wwContentType   s          16384a   varying
     D                                     based(p_ContentType)
     D stgContentType  s          16384a   varying
     D p_SOAPAction    s               *   inz(*null)
     D wwSOAPAction    s          16384a   varying
     D                                     based(p_SOAPAction)
     D stgSOAPAction   s          16384a   varying

     c                   callp     SetRespCode(0)
     c                   callp     http_dmsg('http_url_post_stmf(): ' +
     c                                      'entered')
     c                   eval      p_global = getGlobalPtr()

      *********************************************************
      * open file to be posted
      *********************************************************
     c                   callp     http_dmsg('getting post file size...')
     c                   if        stat64(pePostFile: wwStat) < 0
     c                   callp     SetError(HTTP_FDSTAT:'stat64(): ' +
     c                                        %str(strerror(errno)) )
     c                   return    -1
     c                   endif

     c                   if        wwStat.st_size > 2147483647
     c                   eval      wwDataSize64 = wwStat.st_size
     c                   eval      wwDataSize = 0
     c                   else
     c                   eval      wwDataSize = wwStat.st_size
     c                   eval      wwDataSize64 = 0
     c                   endif

     c                   callp     http_dmsg('opening file to be sent...')
     c                   eval      wwPostFD = open( %trimr(pePostFile)
     c                                            : O_LARGEFILE + O_RDONLY )
     c                   if        wwPostFD < 0
     c                   callp     SetError(HTTP_FDOPEN:'open(): ' +
     c                                        %str(strerror(errno)) )
     c                   return    -1
     c                   endif

      *********************************************************
      * do something to handle optional parameters
      *********************************************************
     c                   if         %parms >= 4
     c                   eval       wwTimeout = peTimeout
     c                   endif

     c                   if         %parms >= 5 
     c                              and %addr(peUserAgent) <> *null
     c                   eval       p_UserAgent = %addr(stgUserAgent)
     C                   eval       stgUserAgent = getSA(peUserAgent)
     c                   endif
     
     c                   if         %parms >= 6 
     c                              and %addr(peContentType) <> *null
     c                   eval       p_ContentType = %addr(stgContentType)
     C                   eval       stgContentType = getSA(peContentType)
     c                   endif
     
     c                   if         %parms >= 7
     c                              and %addr(peSOAPAction) <> *null
     c                   eval       p_SOAPAction = %addr(stgSOAPAction)
     C                   eval       stgSOAPAction = getSA(peSOAPAction)
     c                   endif

      *********************************************************
      * open file for writing (O_WRONLY = write only)
      *    if it exists, truncate it (O_TRUNC = truncate)
      *    if it doesnt, create it (O_CREAT = create)
      *    allow >2gb files (O_LARGEFILE)
      *    and assign the remote codepage to it.
      *********************************************************
     c                   callp     http_dmsg('opening file to be received')
     c                   eval      wwRecvFD = open( %trimr(peRecvFile)
     c                                            : O_WRONLY
     c                                            + O_TRUNC
     c                                            + O_CREAT
     c                                            + CCSID_OR_CP
     c                                            + O_LARGEFILE
     c                                            : global.file_mode
     c                                            : FILE_CCSID()
     c                                            )
     c                   if        wwRecvFD < 0
     c                   callp     SetError(HTTP_FDOPEN:'open(): ' +
     c                               %str(strerror(errno)) )
     c                   callp     close(wwPostFD)
     c                   return    -1
     c                   endif

      *********************************************************
      *  Call the 'raw' post procedure, telling it to use
      *  the IFS API called 'write' to write data.
      *********************************************************
     
     c                   eval      rc = http_url_post_raw2( peURL
     c                                                    : wwPostFD
     c                                                    : %paddr('read')
     c                                                    : wwDataSize
     c                                                    : wwRecvFD
     c                                                    : %paddr('write')
     c                                                    : wwTimeout
     c                                                    : wwUserAgent
     c                                                    : wwContentType
     c                                                    : wwSOAPAction
     c                                                    : wwDataSize64 )

     c                   callp     close(wwPostFD)
     c                   callp     close(wwRecvFD)
     c                   return    rc
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_persist_open(): Open a persistent HTTP session
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_persist_open...
     P                 B                   export
     D http_persist_open...
     D                 PI              *
     D  peURL                     32767A   varying const options(*varsize)
     D  peTimeout                    10I 0 value options(*nopass)

     D wwTimeout       S             10I 0
     D wwServ          S             32A
     D wwUser          S             32A
     D wwPass          S             32A
     D wwHost          S            256A
     D wwPort          S             10I 0
     D wwOrigHost      S            256A
     D wwOrigPort      S             10I 0
     D wwPath          S          32767A   varying
     D wwComm          s               *
     D p_addr          s               *

     c                   callp     SetRespCode(0)
     c                   eval      p_global = getGlobalPtr()

     c                   callp     http_dmsg('http_persist_open():'
     c                                     + ' entered')

      *********************************************************
      * Set up optional parameters (timeout)
      *********************************************************
     c                   if        %parms>=2 and peTimeout>=0
     c                   eval      wwTimeout = peTimeout
     c                   else
     c                   eval      wwTimeout = HTTP_TIMEOUT
     c                   endif

      *********************************************************
      *  Parse URL into it's components
      *********************************************************
     c                   if        http_long_ParseURL(peURL: wwServ: wwUser:
     c                                wwPass: wwHost: wwPort: wwPath) < 0
     c                   return    *NULL
     c                   endif

      *********************************************************
      *  Proxy address provided?
      *********************************************************
     c                   eval      wwOrigHost = wwHost
     c                   eval      wwOrigPort = wwPort

     c                   if        dsProxyHost <> *blanks
     c                   eval      wwHost = dsProxyHost
     c                   endif

     c                   if        dsProxyPort <> *zeros
     c                   eval      wwPort = dsProxyPort
     c                   endif

     c                   if        dsProxyHost <> *blanks
     c                               and wwServ='https'
     c                   eval      dsProxyTun = *ON
     c                   else
     c                   eval      dsProxyTun = *OFF
     c                   endif

      *********************************************************
      *  Select comm driver & build a socket address structure
      *********************************************************
     c                   eval      wwComm = http_select_commdriver(wwServ)
     c                   if        wwComm = *NULL
     c                   return    *NULL
     c                   endif

     c                   eval      p_addr = comm_resolve( wwComm
     c                                                  : %trimr(wwHost)
     c                                                  : %trimr(wwServ)
     c                                                  : wwPort
     c                                                  : *OFF    )

     c                   if        p_addr = *NULL
     c                   callp     comm_cleanup(wwComm)
     c                   return    *NULL
     c                   endif

      *********************************************************
      * Connect to server
      *********************************************************
     c                   if        comm_Connect( wwComm
     c                                         : p_addr
     c                                         : wwTimeout
     c                                         ) = *OFF
     c                   callp     comm_cleanup(wwComm)
     c                   return    *NULL
     c                   endif

      *********************************************************
      * Establish proxy tunnelling if necessary
      *********************************************************
     c                   if        dsProxyTun = *ON
     c                   if        proxy_tunnel( wwComm
     c                                         : wwServ
     C                                         : wwOrigHost
     c                                         : wwOrigPort
     c                                         : wwTimeout ) <> 0
     c                   callp     comm_cleanup(wwComm)
     c                   callp     http_persist_close( wwComm )
     c                   return    *NULL
     c                   endif
     c                   endif

      *********************************************************
      * Upgrade connection security (if driver supports it)
      * (if wwComm is the SSL driver, this starts SSL encryption)
      *
      * Note: the endpoint hostname is passed here so that
      *       TLS server name indicator (SNI) knows the host
      *       name (even if connecting via a proxy)
      *********************************************************
     c                   if        comm_Upgrade( wwComm
     c                                         : wwTimeout
     c                                         : %trimr(wwOrigHost)
     c                                         ) = *OFF
     c                   callp     comm_cleanup(wwComm)
     c                   return    *NULL
     c                   endif

     c                   return    wwComm
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_persist_get(): GET an HTTP resource using a persistent session
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_persist_get...
     P                 B                   export
     D http_persist_get...
     D                 PI            10I 0
     D  peComm                         *   value
     D  peURL                     32767A   varying const options(*varsize)
     D  peFD                         10I 0 value
     D  peProc                         *   value procptr
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)

     D wwUA            S          16384A   varying
     D wwMT            S               Z
     D wwCT            S          16384a   varying
     D wwSA            S          32767A   varying
     D wwTimeout       S             10I 0
     D p_UserAgent     S               *
     D wwUserAgent     S          16384A   varying based(p_UserAgent)
     D p_ModTime       S               *
     D wwModTime       S               Z   based(p_ModTime)
     D p_ContentType   S               *
     D wwContentType   S          16384A   varying based(p_ContentType)
     D p_SOAPAction    S               *
     D wwSOAPAction    S          32767A   varying based(p_SOAPAction)

     c                   callp     SetRespCode(0)
     c                   eval      p_global = getGlobalPtr()

     c                   callp     http_dmsg('http_persist_get():'
     c                                     + ' entered')

      *********************************************************
      * Set up optional parameters
      *********************************************************
      * If no timeout given, default to 5 minutes
     c                   if        %parms>=5 and peTimeout>=0
     c                   eval      wwTimeout = peTimeout
     c                   else
     c                   eval      wwTimeout = HTTP_TIMEOUT
     c                   endif

      * If no user-agent given, pass '*OMIT' to next proc
     c                   if        %parms >= 6
     c                             and %addr(peUserAgent)<>*null
     c                   eval      p_UserAgent = %addr(wwUA)
     c                   eval      wwUserAgent = getSA(peUserAgent)
     c                   else
     c                   eval      p_UserAgent = *NULL
     c                   endif

      * If no mod time given, pass '*OMIT' to next proc
     c                   if        %parms >= 7
     c                             and %addr(peModTime)<>*null
     c                   eval      p_ModTime = %addr(wwMT)
     c                   eval      wwModTime = peModTime
     c                   else
     c                   eval      p_ModTime = *NULL
     c                   endif

      * If no content-type given, pass '*OMIT' to next proc
     c                   if        %parms >= 8
     c                             and %addr(peContentType)<>*null
     c                   eval      p_ContentType = %addr(wwCT)
     c                   eval      wwContentType = getSA(peContentType)
     c                   else
     c                   eval      p_ContentType = *NULL
     c                   endif

      * If no SoapAction given, pass '*OMIT' to next proc
     c                   if        %parms >= 9
     c                             and %addr(peSoapAction)<>*null
     c                   eval      p_SOAPAction = %addr(wwSA)
     c                   eval      wwSOAPAction = getSA(peSOAPAction)
     c                   else
     c                   eval      p_SOAPAction = *NULL
     c                   endif

     c                   return    http_persist_req( 'GET'
     c                                             : peComm
     c                                             : peURL
     c                                             : 0
     c                                             : *null
     c                                             : *null
     c                                             : 0
     c                                             : peFD
     c                                             : peProc
     c                                             : wwTimeout
     c                                             : wwUserAgent
     c                                             : wwContentType
     c                                             : wwSoapAction
     c                                             : wwModTime )

     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_persist_post(): POST data to an HTTP resource, and get back
      *                       response using a persistent connection
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_persist_post...
     P                 B                   export
     D http_persist_post...
     D                 PI            10I 0
1    D  peComm                         *   value
2    D  peURL                     32767A   varying const options(*varsize)
3    D  pePostFD                     10I 0 value
4    D  pePostProc                     *   value procptr
5    D  pePostData                     *   value
6    D  pePostDataLen                10I 0 value
7    D  peSaveFD                     10I 0 value
8    D  peSaveProc                     *   value procptr
9    D  peTimeout                    10I 0 value options(*nopass)
10   D  peUserAgent                  64A   const options(*nopass:*omit)
11   D  peContentType                64A   const options(*nopass:*omit)
12   D  peSOAPAction                 64A   const options(*nopass:*omit)
13   D  pePostDataLen64...
     D                               20i 0 value options(*nopass)

     D wwUA            S          16384A   varying
     D wwCT            S          16384A   varying
     D wwSA            S          32767A   varying
     D wwTimeout       S             10I 0
     D p_UserAgent     S               *
     D wwUserAgent     S          16384A   varying based(p_UserAgent)
     D p_ContentType   S               *
     D wwContentType   S          16384A   varying based(p_ContentType)
     D p_SOAPAction    S               *
     D wwSOAPAction    S          32767A   varying based(p_SOAPAction)
     D dataLen         s             10i 0
     D dataLen64       s             20i 0

     c                   callp     SetRespCode(0)
     c                   eval      p_global = getGlobalPtr()
     c                   callp     http_dmsg('http_persist_post(): entered')

      *********************************************************
      *  Handle the optional parameters
      *********************************************************
      * If no timeout, default to 5 mins
     c                   if        %parms>=9 and peTimeout>=0
     c                   eval      wwTimeout = peTimeout
     c                   else
     c                   eval      wwTimeout = HTTP_TIMEOUT
     c                   endif

      * If no user-agent, pass '*OMIT' to next proc
     c                   if        %parms>=10
     c                             and %addr(peUserAgent)<>*null
     c                   eval      p_UserAgent = %addr(wwUA)
     c                   eval      wwUserAgent = getSA(peUserAgent)
     c                   else
     c                   eval      p_UserAgent = *NULL
     c                   endif

      * If no content-type, pass '*OMIT' to next proc
     c                   if        %parms>=11
     c                             and %addr(peContentType)<>*null
     c                   eval      p_ContentType = %addr(wwCT)
     c                   eval      wwContentType = getSA(peContentType)
     c                   else
     c                   eval      p_ContentType = *NULL
     c                   endif

      * If no SOAPaction, pass '*OMIT' to next proc
     c                   if        %parms>=12
     c                             and %addr(peSoapAction)<>*null
     c                   eval      p_SOAPAction = %addr(wwSA)
     c                   eval      wwSOAPAction = getSA(peSOAPAction)
     c                   else
     c                   eval      p_SOAPAction = *NULL
     c                   endif

      * If no 64-bit data length, use the 32-bit one
     c                   if        %parms>=13
     c                             and pePostDataLen64 > 0
     c                   eval      dataLen64 = pePostDataLen64
     c                   eval      dataLen = 0
     c                   else
     c                   eval      dataLen = pePostDataLen
     c                   eval      dataLen64 = 0
     c                   endif

     c                   return    http_persist_req( 'POST'
     c                                             : peComm
     c                                             : peURL
     c                                             : pePostFD
     c                                             : pePostProc
     c                                             : pePostData
     c                                             : dataLen
     c                                             : peSaveFD
     c                                             : peSaveProc
     c                                             : wwTimeout
     c                                             : wwUserAgent
     c                                             : wwContentType
     c                                             : wwSoapAction
     c                                             : *omit
     c                                             : dataLen64 )

     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_persist_req(): Perform (any) Persistent HTTP Request
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_persist_req...
     P                 B                   export
     D http_persist_req...
     D                 PI            10I 0
1    D  peMethod                     10a   varying const
2    D  peComm                         *   value
3    D  peURL                     32767A   varying const options(*varsize)
4    D  peUplFD                      10I 0 value
5    D  peUplProc                      *   value procptr
6    D  peUplData                      *   value
7    D  peUplDataLen                 10I 0 value
8    D  peSaveFD                     10I 0 value
9    D  peSaveProc                     *   value procptr
10   D  peTimeout                    10I 0 value options(*nopass)
11   D  peUserAgent               16384A   varying const
     D                                     options(*nopass:*omit)
12   D  peContentType             16384A   varying const
     D                                     options(*nopass:*omit)
13   D  peSoapAction              32767A   varying const
     D                                     options(*nopass:*omit)
14   D  peModTime                      Z   const options(*nopass:*omit)
15   D  peUplDataLen64...
     D                               20i 0 value options(*nopass)

     D wwMethod        s                   like(peMethod)
     D wwUA            S          16384A   varying
     D wwCT            S          16384A   varying
     D wwSA            S          32767A   varying
     D wwTimeout       S             10I 0
     D p_UserAgent     S               *
     D wwUserAgent     S          16384A   varying based(p_UserAgent)
     D p_ContentType   S               *
     D wwContentType   S          16384A   varying based(p_ContentType)
     D p_SOAPAction    S               *
     D wwSOAPAction    S          32767A   varying based(p_SOAPAction)
     D wwServ          S             32A
     D wwUser          S             32A
     D wwPass          S             32A
     D wwHost          S            256A
     D wwPort          S             10I 0
     D wwPath          S          32767A   varying
     D rc              S             10I 0
     D wwUplProc       s               *   procptr
     D wwSecure        s              1N   inz(*OFF)
     D wwUplData       s                   like(peUplData) inz(*null)
     D p_ModTime       S               *
     D wwModTime       S               Z   based(p_ModTime)
     D wwMT            S               Z
     D wwFreeData      S              1N   INZ(*OFF)
     D dataLen         s             20i 0

     c                   eval      RDWR_Reader_p = *null
     c                   eval      RDWR_Writer_p = *null

     c                   callp     SetRespCode(0)
     c                   eval      p_global = getGlobalPtr()

     c                   eval      wwMethod = %trim(peMethod)
     c     lower:upper   xlate     wwMethod      wwMethod

     c                   callp     http_dmsg('http_persist_req('
     c                                      + wwMethod + ') entered.')

      *********************************************************
      *  Handle the optional parameters
      *********************************************************
      * If no timeout, default to 5 mins
     c                   if        %parms>=10 and peTimeout>=0
     c                   eval      wwTimeout = peTimeout
     c                   else
     c                   eval      wwTimeout = HTTP_TIMEOUT
     c                   endif

      * If no user-agent, pass '*OMIT' to next proc
     c                   if        %parms>=11
     c                             and %addr(peUserAgent)<>*null
     c                   eval      p_UserAgent = %addr(wwUA)
     c                   eval      wwUserAgent = peUserAgent
     c                   else
     c                   eval      p_UserAgent = *NULL
     c                   endif

      * If no content-type, pass '*OMIT' to next proc
     c                   if        %parms>=12
     c                             and %addr(peContentType)<>*null
     c                   eval      p_ContentType = %addr(wwCT)
     c                   eval      wwContentType = peContentType
     c                   else
     c                   eval      p_ContentType = *NULL
     c                   endif

      * If no SOAPaction, pass '*OMIT' to next proc
     c                   if        %parms>=13
     c                             and %addr(peSoapAction)<>*null
     c                   eval      p_SOAPAction = %addr(wwSA)
     c                   eval      wwSOAPAction = peSOAPAction
     c                   else
     c                   eval      p_SOAPAction = *NULL
     c                   endif

      * If no mod time given, pass '*OMIT' to next proc
     c                   if        %parms >= 14
     c                             and %addr(peModTime)<>*null
     c                             and peModTime <> *loval
     c                   eval      p_ModTime = %addr(wwMT)
     c                   eval      wwModTime = peModTime
     c                   else
     c                   eval      p_ModTime = *NULL
     c                   endif

      * if no 64-bit data length, use the 32-bit one
     c                   if        %parms >= 15 
     c                             and peUplDataLen64 > 0
     c                   eval      dataLen = peUplDataLen64
     c                   else
     c                   eval      dataLen = peUplDataLen
     c                   endif

      *********************************************************
      *  Parse URL into it's components, and then look up
      *  host & build a socket address structure:
      *********************************************************
     c                   if        http_long_ParseURL( peURL
     c                                               : wwServ
     c                                               : wwUser
     c                                               : wwPass
     c                                               : wwHost
     c                                               : wwPort
     c                                               : wwPath ) < 0
     c                   return    -1
     c                   endif

     c                   if        wwServ = 'https'
     c                   eval      wwSecure = *ON
     c                   endif

     c                   callp     setUrlAuth(wwUser: wwPass)

      *********************************************************
      * Negotiate NTLM
      *********************************************************
      *
      /if defined(NTLM_SUPPORT)
     c                   if        AuthPlugin_negotiateAuthentication(
     c                                peComm: peURL: wwTimeout) < 0
     c                   return    -1
     c                   endif
      /endif

      *********************************************************
      * Translate Upload data to remote character encoding
      *  (if necessary)
      *
      * NOTE: Sizes larger than 2gb are currently only allowed
      *       when using an upload proc.
      *********************************************************
     c                   eval      wwUplData = peUplData
     c                   if        dataLen>0 and peUplProc=*NULL
     c                   if        dataLen > 2147483647
     c                   eval      dataLen = 2147483647
     c                   endif
     c                   eval      dataLen = http_xlatedyn( dataLen
     c                                                    : peUplData
     c                                                    : TO_ASCII
     c                                                    : wwUplData )
     c                   if        dataLen = -1
     c                   return    -1
     c                   endif
     c                   eval      wwFreeData = *on
     c                   endif

      *********************************************************
      * Perform the requested method
      *********************************************************
     c                   if        peUplProc = *NULL
     c                   eval      wwUplProc = %paddr('SENDDOC')
     c                   else
     c                   eval      wwUplProc = %paddr('SENDRAW')
     c                   eval      wwUplData = *NULL
     c                   endif

      /if defined(MEMCOUNT)
     c                   callp     memStatus('allocs before do_oper')
      /endif

     c                   eval      rc = do_oper( wwMethod
     c                                         : peSaveProc
     c                                         : wwUplProc
     c                                         : wwUplData
     c                                         : dataLen 
     c                                         : peComm
     c                                         : peSaveFD
     c                                         : wwTimeout
     c                                         : wwPath
     c                                         : wwHost
     c                                         : wwModTime
     c                                         : wwUserAgent
     c                                         : wwContentType
     c                                         : wwSOAPAction
     c                                         : peUplProc
     c                                         : peUplFD
     c                                         : wwPort
     c                                         : wwSecure
     c                                         : wwServ
     c                                         : *OFF
     c                                         )

      /if defined(MEMCOUNT)
     c                   callp     memStatus('allocs after do_oper')
      /endif

     c                   if        wkSaveAuth <> *blanks
     c                   eval      dsAuth = wkSaveAuth
     c                   eval      wkSaveAuth = *blanks
     c                   endif

     c                   if        wwFreeData = *ON and wwUplData <> *Null
     c                   callp     xdealloc(wwUplData)
     c                   endif

     c                   return    rc
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_persist_close(): End a persistent HTTP session
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_persist_close...
     P                 B                   export
     D http_persist_close...
     D                 PI            10I 0
     D  peComm                         *   value
     c                   eval      p_global = getGlobalPtr()
     c                   return    http_close( 0 : peComm)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * parse important fields from the response chain
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P parse_resp_chain...
     P                 B
     D parse_resp_chain...
     D                 PI            10I 0
     D  peRespChain               32767A   varying const
     D  peRC                         10I 0
     D  peTE                         32A
     D  peCLen                       10u 0
     D  peUseCL                       1N
     D  peAuthErr                     1N
     D  peProxyAuthErr...
     D                                1N
     D  peHost                      256A   varying const
     D  pePath                      256A   varying const

     D wwChain         S          32767A   varying
     D wwPos           S             10I 0
     D wwPos2          S             10I 0
     D wwCL            S             32A
     D LF              S              1A   inz(x'25') static
     D CRLF            S              2A   inz(x'0d25') static
     D wwResetAuth     S              1N   inz(*Off)
     D wwContent       s              1N   inz(*on)

     c                   select
     c                   when      peRC = 401
     c                   eval      peAuthErr = *on

     c                   when      peRC = 407
     c                   eval      peProxyAuthErr = *on

     c                   when      peRC<=100 or peRC=204 or peRC=304
     c****               return    peRC
     c                   eval      wwContent = *off
     c                   callp     http_dmsg('No content expected with '
     c                                + %trim(%editc(peRC:'P')))
     c                   endsl

      *********************************************************
      * Make an uppercase copy of the response chain so
      * we can do case-insensitive searching on it.
      *********************************************************
     c                   eval      wwChain = peRespChain
     c     upper:lower   xlate     wwChain       wwChain

      *********************************************************
      * parse out transfer-encoding:
      *********************************************************
     c                   if        wwContent = *on

     c                   eval      peTE = 'identity'
     c                   eval      wwPos = %scan(LF+'transfer-encoding:':
     c                                  wwChain)
     c                   if        wwPos > 0
     c                   eval      wwPos = wwPos + 19
     c                   eval      wwPos2 = %scan(CRLF:wwChain:wwPos)
     c                   eval      wwPos2 = wwPos2 - wwPos
     c                   if        wwPos2 > 0
     c                   eval      peTE= %trim(%subst(wwChain:wwPos:wwPos2))
     c                   endif
     c                   endif

     c                   if        %scan('chunked': peTE)=0  and
     c                               %scan('identity': peTE)=0
     c                   callp     SetError(HTTP_XFRENC: 'The "' +
     c                              %trim(peTE) + '" transfer encoding is'+
     c                              ' not supported.')
     c                   return    -1
     c                   endif

     c                   endif
      *********************************************************
      *  parse out content-length if using "identity,"
      *   (this is irrelevant for "chunked")
      *********************************************************
     c                   if        wwContent = *on

     c                   eval      wwCL = '0'
     c                   eval      peUseCL = *OFF
     c                   if        %scan('identity': peTE) > 0
     c                   eval      wwPos = %scan(LF+'content-length:':
     c                                           wwChain)
     c                   if        wwPos > 0
     c                   eval      wwPos = wwPos + 16
     c                   eval      wwPos2 = %scan(CRLF:wwChain:wwPos)
     c                   eval      wwPos2 = wwPos2 - wwPos
     c                   if        wwPos2 > 0
     c                   eval      wwCL= %trim(%subst(wwChain:wwPos:wwPos2))
     c                   eval      peUseCL = *ON
     c                   endif
     c                   endif
     c                   endif
     c                   eval      peCLen = atoll(wwCL)

     c                   callp     http_dmsg('recvdoc parms: '+%trim(peTE)+
     c                                ' ' + %trim(%editc(peCLen:'P')))

     c                   endif
      *********************************************************
      * parse out www-authenticate: header:
      * (used when userid/password for actual site is required)
      *********************************************************
     c                   eval      wwPos=%scan('www-authenticate:':wwChain)
     c                   if        wwPos > 0
     c                   eval      wwResetAuth = *On

     c                   dow       wwPos > 0
     c                   callp     interpret_auth(peRespChain:wwPos:wwResetAuth)
     c                   eval      wwPos=%scan('www-authenticate:':wwChain:
     c                               wwPos+1)
     c                   eval      wwResetAuth = *Off
     c                   enddo
     c                   endif

     c                   if        peAuthErr = *On
     c                   callp     SetError(HTTP_NDAUTH:'This page requires' +
     c                               ' a user-id & password')
     c**                 return    -1
     c                   endif

      *********************************************************
      * parse proxy-authenticate: header
      * (used when userid/password for proxy is required)
      * this header may occur more than once (especially on
      * MS ISA servers, where Kerberos, NTLM, Basic, etc.
      * may be provided)
      *********************************************************
     c                   eval      dsProxyAuthBasic = *off
     c                   eval      dsProxyAuthRealm = *blanks
     c                   eval      wwPos=%scan(LF+'proxy-authenticate:':wwChain)
     c                   dow       wwPos > 0
     c                   callp     interpret_proxy_auth(peRespChain: wwPos)
     c                   eval      wwPos=%scan(LF+'proxy-authenticate:':wwChain:
     c                               wwPos+1)
     c                   enddo

     c                   if        peProxyAuthErr = *On
     c                   callp     SetError(HTTP_PXNDAUTH:'This proxy ' +
     c                               ' requires a user-id & password')
     c**                 return    -1
     c                   endif

      *********************************************************
      * parse out 'location:' header:
      *  (used for redirects)
      *********************************************************
     c                   eval      %len(wkRedirLoc) = 0
     c                   eval      wwPos = %scan(LF+'location:':
     c                                           wwChain)
     c                   if        wwPos > 0
     c                   eval      wwPos = wwPos + 11
     c                   eval      wwPos2 = %scan(CRLF:wwChain:wwPos)
     c                   eval      wwPos2 = wwPos2 - wwPos
     c                   if        wwPos2 > 0
     c                   eval      wkRedirLoc =
     c                             %trim(%subst(peRespChain:wwPos:wwPos2))
     c                   endif
     c                   endif

      *********************************************************
      * Call HTTP header parsing module
      *********************************************************
      /if defined(MEMCOUNT)
     c                   callp     memStatus('allocs before header_parse')
      /endif
     c                   callp     header_parse(peRespChain: *NULL)

      /if defined(MEMCOUNT)
     c                   callp     memStatus('allocs before load_cookies')
      /endif
     c                   if        global.use_cookies = *on
     c                   callp     header_load_cookies(peHost: pePath)
     c                   endif

      /if defined(MEMCOUNT)
     c                   callp     memStatus('allocs after load_cookies')
      /endif

      *********************************************************
      * Call user supplied parsing proc if available
      *********************************************************
     c                   if        wkParseHdrProc <> *NULL
     c                   callp     parse_hdrs(peRespChain: wkParseHdrdata)
     c                   endif
     c                   if        wkParseHdrLong <> *NULL
     c                   callp     parse_hdr_long( peRespChain
     c                                           : wkParseHdrLongData )
     c                   endif

     c                   return    peRC
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_set_100_timeout(): Set value for 100-continue timeouts.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_set_100_timeout...
     P                 B                   export
     D http_set_100_timeout...
     D                 PI
     D peTimeout                     10P 3 value
     c                   eval      p_global = getGlobalPtr()
     c                   eval      global.timeout100 = peTimeout
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_use_cookies(): Turns on/off HTTPAPI's cookie parsing and
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_use_cookies...
     P                 B                   export
     D http_use_cookies...
     D                 PI
     D   peSetting                    1N   const
     c                   eval      p_global = getGlobalPtr()
     c                   eval      global.use_cookies = peSetting
     P                 E

      ****************************************************************
      * Proxy support                                                *
      ****************************************************************

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_proxy_setauth():   Set HTTP Proxy Authentication Information
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_proxy_setauth...
     P                 B                   export
     D http_proxy_setauth...
     D                 PI            10I 0
     D   peAuthType                   1A   const
     D   peUsername                  80A   const
     D   pePasswd                  1024A   const

     D wwString        S           1105A
     D wwEncoded       S           1476A
     D wwEncLen        S             10I 0

     c                   callp     http_dmsg('http_proxy_setauth(): entered')
     c                   eval      p_global = getGlobalPtr()
     c                   if        peAuthType<>HTTP_AUTH_BASIC
     c                               and peAuthType<>HTTP_AUTH_NONE
     c                   callp     SetError(HTTP_ATHTYP: 'Invalid authenti'+
     c                                   'cation type!')
     c                   return    -1
     c                   endif

     C*************************************************
     c* Calculate strings for NO authentication
     C*************************************************
     c                   if        peAuthType = HTTP_AUTH_NONE
     c                   eval      dsProxyAuthType = HTTP_AUTH_NONE
     c                   eval      dsProxyAuthStr = ''
     c                   return    0
     c                   endif

     c                   if        %scan(':':peUserName) > 0
     c                   callp     SetError(HTTP_ATHVAL: 'HTTP Proxy Auth '+
     c                               'values cannot contain a colon!')
     c                   return    -1
     c                   endif

     c                   eval      dsProxyAuthUser = peUserName
     c                   eval      dsProxyAuthPasswd = pePasswd

     c                   eval      wwString = %trimr(peUserName) + ':' +
     c                                        %trimr(pePasswd)
     c                   callp     http_xlate( %len(%trimr(wwString))
     c                                       : wwString
     c                                       : TO_ASCII )

     c                   eval      wwEncLen = base64_encode(%addr(wwString):
     c                                             %len(%trimr(wwString)):
     c                                             %addr(wwEncoded):
     c                                             %size(wwEncoded))

     c                   eval      dsProxyAuthStr = %subst(wwEncoded:1:wwEncLen)
     c                   eval      dsProxyAuthType = peAuthType

     c                   return    0
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_setproxy():   Set HTTP Proxy Address
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_setproxy   B                   export
     D http_setproxy   PI            10I 0
     D   peHost                     256A   const
     D   pePort                      10I 0 const

     c                   eval      p_global = getGlobalPtr()
     c                   eval      dsProxyHost = peHost
     c                   eval      dsProxyPort = pePort
     c                   eval      dsProxyTun  = *off

     c                   return    0

     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_proxy_getauth():   Get HTTP Proxy Authentication Information
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_proxy_getauth...
     P                 B                   export
     D http_proxy_getauth...
     D                 PI            10I 0
     D   peBasic                      1N
     D   peRealm                    124A

     c                   callp     http_dmsg('http_proxy_getauth(): entered')
     c                   eval      p_global = getGlobalPtr()
     c                   if        dsProxyAuthRealm = *blanks
     c                   callp     SetError(HTTP_NOAUTH: 'Proxy did ' +
     c                              'not ask for authentication!')
     c                   return    -1
     c                   endif

     c                   eval      peBasic = dsProxyAuthBasic
     c                   eval      peRealm = dsProxyAuthRealm

     c                   return    0
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * proxy_tunnel(): This establishes a tunnel through a proxy,
      *                 this lets us communicate directly with the
      *                 destination HTTP server (required for SSL)
      *
      *    peComm = Communication driver
      *    peServ = Service (http or https)
      *    peHost = destination (not proxy) host
      *    pePort = destination port number
      * peTimeout = timeout
      *
      * returns 0 if successful, otherwise an HTTP response number
      *         or -1 upon internal error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P proxy_tunnel    B
     D proxy_tunnel    PI            10I 0
     D   peComm                        *   value
     D   peServ                      32a   const
     D   peHost                     256a   const
     D   pePort                      10i 0 value
     D   peTimeout                   10i 0 value

     D wwReq           S          32767A   varying
     D wwResp          s          32767A   varying

     D rc              S             10I 0
     D wwPort          S             10I 0
     D wwTE            S             32A
     D wwClen          s             10U 0
     D wwUseCL         s              1N
     D wwAuthErr       S              1N   inz(*OFF)
     D wwProxyAuthErr...
     D                 S              1N   inz(*OFF)

      *************************************************
      * Create proxy tunnelling request string
      *************************************************
     c                   eval      wwPort = pePort

     c                   if        pePort=0
     c                   if        peServ='https'
     c                   eval      wwPort=443
     c                   else
     c                   eval      wwPort=80
     c                   endif
     c                   endif

     c                   eval      wwReq = 'CONNECT ' + %trim(peHost)
     c                                   + ':' + %trim(%editc(wwPort:'L'))
     c                                   + ' HTTP/1.1'
     C                                   + CRLF

     c                   if        pePort = 0
     c                   eval      wwReq = wwReq
     C                                   + 'Host: ' + %trim(peHost)
     C                                   + CRLF
     c                   else
     c                   eval      wwReq = wwReq
     C                                   + 'Host: ' + %trim(peHost)
     c                                   + ':' + %trim(%editc(pePort:'L'))
     C                                   + CRLF
     c                   endif

     c                   eval      wwReq = wwReq
     C                                   + 'User-Agent: ' + HTTP_USERAGENT
     C                                   + CRLF
     c                                   + 'Proxy-Connection: keep-alive'
     c                                   + CRLF

     c                   if        dsProxyAuthType = HTTP_AUTH_BASIC
     c                   eval      wwReq = wwReq
     c                                   + 'Proxy-Authorization: Basic '
     c                                   + dsProxyAuthStr + CRLF
     c                   endif

     C                   eval      wwReq = wwReq + CRLF

      *************************************************
      * Send request to proxy server
      *************************************************
     c                   eval      rc = SendReq( peComm
     c                                         : %addr(wwReq)+VARPREF
     c                                         : %len(wwReq)
     c                                         : peTimeout )
     c                   if        rc < 1
     c                   return    rc
     c                   endif

      *************************************************
      * Receive & parse proxy server's response.
      *************************************************
     c                   eval      rc = RecvResp( peComm
     c                                          : wwResp
     c                                          : %size(wwResp)
     c                                          : peTimeout
     c                                          : *OFF )
     c                   if        rc < 1
     c                   return    rc
     c                   endif

     c                   eval      rc = parse_resp_chain( wwResp
     c                                                  : rc
     c                                                  : wwTE
     c                                                  : wwCLen
     c                                                  : wwUseCL
     c                                                  : wwAuthErr
     c                                                  : wwProxyAuthErr
     c                                                  : %trim(dsProxyHost)
     c                                                  : '/' )
     c                   if        rc < 200 or rc > 299
     c                   return    rc
     c                   endif

     c                   return    0
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * getRealSA(): Okay, this one's hard to explain :)
      *
      * The original peSoapAction parameter to HTTPAPI was defined as
      * fixed length "64A CONST".  This was problematic because people
      * needed to be able to specify longer strings.  So they'd use
      * XPROC -- but that's really cumbersome.
      *
      * I wanted to allow longer SoapAction, but I don't want to break
      * backward compatibility!  This is where it gets tricky...  how
      * can old programs pass a 64A, and new programs pass a 16384A
      * and have the routine work in either case??
      *
      * If the parameter is "16384A VARYING" the first two bytes must
      * be the length of the data.  Since the original peSoapAction
      * wasn't VARYING, the first two bytes would be actual data.
      * and due to the nature of a Soap-Action, they'd have to be
      * human readable.  That means the first character in the
      * SoapAction would have to be > x'40' (Blank in EBCDIC)
      *
      * So a VARYING string that's 16384 long would be hex x'4000'
      * in the first two bytes, but the lowest valid soap-action would
      * be x'4040'
      *
      * This routine uses that fact to distinguish between the two
      * types of SoapAction parameters and return the correct result
      * (is this clever? or ugly?)
      *
      * NOTE: This is now used for content-type and useragent as well
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P getRealSA       B                   export
     D getRealSA       PI         16384A   varying
     D   peSoapAction                 2a

     D wwOldStyle      s             64a   based(p_SA)
     D wwNewStyle      s          16384a   varying based(p_SA)

     C                   eval      p_SA = %addr(peSoapAction)
     C                   if        peSoapAction > x'4000'
     c                   return    %trim(wwOldStyle)
     c                   else
     c                   return    %trim(wwNewStyle)
     c                   endif
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  HTTP_req(): Perform any HTTP request and get input/output from
      *              either a string or an IFS stream file.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_req        B                   export
     D                 PI            10i 0 opdesc
     D   Type                        10a   varying const
     D   URL                      32767a   varying const
     D   ResultStmf                5000a   varying const
     D                                     options(*varsize:*omit)
     D   ResultStr                     a   len(16000000) varying
     D                                     options(*varsize:*omit:*nopass)
     D   SendStmf                  5000a   varying const
     D                                     options(*varsize:*omit:*nopass)
     D   SendStr                       a   len(16000000) varying const
     D                                     options(*varsize:*omit:*nopass)
     D   ContentType              16384A   varying const
     D                                     options(*varsize:*omit:*nopass)

     D comm            s               *
     D sndFd           s             10i 0 inz(-1)
     D rcvFd           s             10i 0 inz(-1)
     D rcvProc         s               *   procptr
     D sndProc         s               *   procptr

     D ResultPtr       s               *   inz(*null)
     D ResultSize      s             10i 0 inz(0)
     D ResultLen       s             20i 0 inz(0)

     D SendPtr         s               *   inz(*null)
     D SendLen         s             10i 0 inz(0)
     D SendLen64       s             20i 0 inz(0)
     D dtype           s             10i 0
     D vtype           s             10i 0
     D inf1            s             10i 0
     D inf2            s             10i 0
     D rc              s             10i 0
     D Len             s             10i 0
     D p_Result        s               *
     D ct              s                   like(ContentType)
     D stmfInfo        ds                  likeds(statds64)

     D SoapAction      s          32767a   varying
     D                                     based(p_SoapAction)

      /free
        SetRespCode(0);
        p_global = getGlobalPtr();

        if %parms >= 5 and %addr(SendStmf) <> *null;
           sndFd = open( %trimr(SendStmf) : O_RDONLY + O_LARGEFILE );
           if sndFd = -1;
              SetError( HTTP_FDOPEN
                      :'open(): ' + %str(strerror(errno)) );
              return -1;
           endif;
           sndProc = %paddr(read);
           if stat64( %trimr(SendStmf): stmfInfo ) = -1;
              SetError( HTTP_FDSTAT
                      : 'stat64(): '+ %str(strerror(errno)) );
              callp close(sndFd);
              return -1;
           endif;
           sendLen64 = stmfInfo.st_size;
        endif;

        if sndFd=-1 and %parms >= 6 and %addr(SendStr) <> *null;
           getBufferInfo(SendStr: SendPtr: SendLen64 );
           sndProc = *null;
        endif;

        if %parms >= 3 and %addr(ResultStmf) <> *null;
           rcvFd = open( %trimr(ResultStmf)
                       : O_CREAT + O_TRUNC + O_WRONLY 
                        + CCSID_OR_CP + O_LARGEFILE
                       : global.file_mode
                       : global.file_ccsid );
           if rcvFd = -1;
              SetError( HTTP_FDOPEN
                      : 'open(): ' + %str(strerror(errno)) );
              return -1;
           endif;
           RcvProc = %paddr(write);
        endif;

        RcvStrBuf.Size = 0;
        RcvStrBuf.Len  = 0;
        RcvStrBuf.Ptr  = *null;

        if rcvFd=-1 and %parms >= 4 and %addr(ResultStr) <> *null;
           CEEDOD(4: dtype: vtype: inf1: inf2: ResultSize: *omit );
           getBufferInfo(ResultStr: ResultPtr: ResultLen );
           RcvStrBuf.Size = ResultSize;
           RcvStrBuf.Len  = 0;
           RcvStrBuf.Ptr  = ResultPtr;
           RcvProc = %paddr(RcvToBuf);
        endif;

        if %parms >= 7 and %addr(ContentType) <> *null;
           ct = ContentType;
        else;
           ct = global.contentType;
        endif;

        comm = http_persist_open( URL: global.timeout );
        if comm = *null;
           exsr closeFiles;
           http_persist_close(comm);
           return -1;
        endif;

        if global.soapActSet = *on;
           p_SoapAction = %addr(global.soapAction);
        else;
           p_SoapAction = *null;
        endif;

        if sendLen64 <= 2147483647;
          sendLen = sendLen64;
          sendLen64 = 0;
        else;
          sendLen = 0;
        endif;

        rc = http_persist_req( Type
                             : comm
                             : URL
                             : sndFd
                             : sndProc
                             : SendPtr
                             : SendLen
                             : rcvFd
                             : rcvProc
                             : global.timeout
                             : global.userAgent
                             : ct
                             : soapAction
                             : global.modTime
                             : sendLen64 );

        exsr closeFiles;
        http_persist_close(comm);
        global.soapActSet = *off;

        if RcvStrBuf.Ptr <> *null;
           if RcvStrBuf.Len <= 0;
              %len(resultStr) = 0;
           else;
              Len = HTTP_xlatedyn( RcvStrBuf.Len
                                 : RcvStrBuf.Ptr
                                 : TO_SYSTEM
                                 : p_Result );
              if Len < 1;
                %len(resultStr) = 0;
              else;
                if Len > ResultSize;
                  Len = ResultSize;
                endif;
                %len(resultstr) = Len;
                memcpy(resultPtr: p_Result: Len);
                xdealloc(p_Result);
              endif;
           endif;
        endif;

        return rc;

        begsr closeFiles;

           if sndFd <> -1;
              callp close(sndFd);
              sndFd = -1;
           endif;

           if rcvFd <> -1;
              callp close(rcvFd);
              rcvFd = -1;
           endif;

       endsr;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  getBufferInfo_REAL(): Dereferences location of CONST VARYING
      *                        buffer, and extracts length
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P getBufferInfo_REAL...
     P                 B                   export
     D                 PI
     D   Buf                               likeds(Buffer_t)
     D   DataPtr                       *
     D   DataLen                     20i 0
      /free
       if %addr(buf) = *null;
          DataPtr = *null;
          DataLen = 0;
       else;
          DataPtr = %addr(Buf.Data);
          DataLen = Buf.Len;
       endif;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * rcvToBuf(): This is a callback that will be used to receive
      *             data into a buffer in memory
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P rcvToBuf        B
     D                 PI            10i 0
     D   fd                          10i 0 value
     D   data                     65535a   options(*varsize)
     D   len                         10i 0 value

     D buf             s          65535a   based(p_buf)
     D newlen          s             10i 0

      /free

       newlen = len;
       if RcvStrBuf.len + newlen > RcvStrBuf.Size;
          newlen = RcvStrBuf.Size - RcvStrBuf.Len;
       endif;

       if newlen > 0;
          p_buf = RcvStrBuf.Ptr + RcvStrBuf.Len;
          %subst(buf:1:newlen) = %subst(data:1:newlen);
          RcvStrBuf.len += newlen;
       endif;

       return len;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  HTTP_string(): Perform any HTTP request using short strings
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_string     B                   export
     D                 PI        100000a   varying
     D   Type                        10a   varying const
     D   URL                      32767a   varying const
     D   SendStr                 100000a   varying const
     D                                     options(*varsize:*omit:*nopass)
     D   ContentType              16384A   varying const
     D                                     options(*varsize:*omit:*nopass)

     D rc              s             10i 0
     D Output          s         100000a   varying
     D msgText         s             80a   varying
     D msgKey          s              4a

     D ct              s                         like(ContentType)

      /free

       SetRespCode(0);
       p_global = getGlobalPtr();

       if %parms >= 4 and %addr(ContentType) <> *null;
          ct = ContentType;
       else;
          ct = global.contentType;
       endif;

       if %parms >= 3 and %addr(SendStr) <> *null;
          rc = http_req(Type: URL: *omit: Output: *omit: SendStr: ct );
       else;
          rc = http_req(Type: URL: *omit: Output);
       endif;

       if rc<>1 and (rc<200 or rc>299);
          msgText = %trimr(http_error());
          QMHSNDPM( 'CPF9897'
                  : 'QCPFMSG   *LIBL'
                  : msgText
                  : %len(msgText)
                  : '*ESCAPE'
                  : '*'
                  : 1
                  : msgKey
                  : ApiEscape );
       endif;

       return Output;
      /end-free
     P                 e


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  HTTP_stmf(): Perform any HTTP request using stream files
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_stmf       B                   export
     D                 PI
     D   Type                        10a   varying const
     D   URL                      32767a   varying const
     D   RespStmf                  5000a   varying const options(*varsize)
     D   SendStmf                  5000a   varying const
     D                                     options(*varsize:*omit:*nopass)
     D   ContentType              16384A   varying const
     D                                     options(*varsize:*omit:*nopass)

     D rc              s             10i 0
     D msgText         s             80a   varying
     D msgKey          s              4a
     D ct              s                         like(ContentType)

      /free

       SetRespCode(0);
       p_global = getGlobalPtr();

       if %parms >= 5 and %addr(ContentType) <> *null;
          ct = ContentType;
       else;
          ct = global.contentType;
       endif;

       if %parms >= 4 and %addr(SendStmf) <> *null;
          rc = http_req(Type: URL: RespStmf: *omit: SendStmf: *omit: ct );
       else;
          rc = http_req(Type: URL: RespStmf);
       endif;

       if rc <> 1 and (rc<200 or rc>299);
          msgText = %trimr(http_error());
          QMHSNDPM( 'CPF9897'
                  : 'QCPFMSG   *LIBL'
                  : msgText
                  : %len(msgText)
                  : '*ESCAPE'
                  : '*'
                  : 1
                  : msgKey
                  : ApiEscape );
       endif;

      /end-free
     P                 e


      /if defined(WORK_IN_PROGRESS)

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_persist(): Perform (any) Persistent HTTP Request
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_persist    B                   export
     D                 PI            10I 0
     D   Method                      10a   varying const
     D   comm                          *   value
     D   URL                      32767A   varying const options(*varsize)
     D   hWriter                       *   const
     D   hReader                       *   const options(*nopass:*omit)
     D

     D UseReader       s              1n   inz(*off)
     D SoapAction      s          32767a   varying
     D                                     based(p_SoapAction)
     D ContentType     s          16384a   varying
     D ContentLength   s             10u 0
     D myMethod        s                   like(Method)
     D Service         S             32A
     D UserId          S             32A
     D Password        S             32A
     D HostName        S            256A
     D Port            S             10I 0
     D Path            S          32767A   varying
     D Secure          S              1N
     D RC              s             10i 0
     D p_ModTime       S               *   inz(*null)
     D ModTime         S               Z   based(p_ModTime)

      /free
       SetRespCode(0);
       p_global = getGlobalPtr();
       RDWR_Reader_p = *null;
       RDWR_Writer_p = *null;

       http_dmsg('http_persist(' + myMethod + ') entered.');

       myMethod = %xlate(lower:upper:%trim(Method));

       if %parms >= 5 and %addr(Reader) <> *null;
          UseReader = *on;
       endif;

       if global.soapActSet = *on;
          p_SoapAction = %addr(global.soapAction);
       else;
          p_SoapAction = *null;
       endif;

       if ValidateRDWR(hWriter: RDWR_READER) = -1;
          return -1;
       endif;

       RDWR_Writer_p = hWriter;
       Writer.setError = %paddr(SetError);
       Writer.maxBufSize = 8192;
       Writer.LocCCSID = global.local_ccsid;
       Writer.NetCCSID = global.net_ccsid;

       if UseReader;
          if ValidateRDWR(hReader: RDWR_READER) = -1;
             return -1;
          endif;
          RDWR_Reader_p = hReader;
          Reader.setError = %paddr(SetError);
          Reader.maxBufSize = 8192;
          Reader.LocCCSID = global.local_ccsid;
          Reader.NetCCSID = global.net_ccsid;
       endif;

       if http_long_parseURL( URL
                            : Service
                            : UserId
                            : Password
                            : HostName
                            : Port
                            : Path ) < 0;
          return -1;
       endif;

       if Service = 'https';
          Secure = *ON;
       endif;

       setUrlAuth(UserId: Password);

       if Writer_Open( hWriter : RDWR_WRITER ) = -1;
          return -1;
       endif;

       ContentType = global.contentType;

       if UseReader
          and Reader_Open( hReader
                         : RDWR_Reader
                         : ContentType
                         : ContentLength ) = -1;
          Writer_Close(hWriter);
          return -1;
       endif;

       /if defined(NTLM_SUPPORT)
       if AuthPlugin_negotiateAuthentication( comm
                                     : url
                                     : global.timeout ) < 0;
          return -1;
       endif;
       /endif

       rc = do_oper( myMethod
                   : *null
                   : *null
                   : *null
                   : ContentLength
                   : comm
                   : 0
                   : global.timeout
                   : Path
                   : HostName
                   : ModTime
                   : global.userAgent
                   : ContentType
                   : soapAction
                   : *null
                   : 0
                   : Port
                   : Secure
                   : Service
                   : *ON
                   );

       if wkSaveAuth <> *blanks;
          dsAuth = wkSaveAuth;
          wkSaveAuth = *blanks;
       endif;

       if UseReader;
          Reader_Close(hReader);
          Reader_Cleanup(hReader);
       endif;

       Writer_Close(hWriter);
       Writer_Cleanup(hWriter);

       return rc;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  HTTP(): Perform any HTTP request using a flexible "reader/writer"
      *          approach.
      *
      *       Method = (input) HTTP method to use in the request
      *          URL = (input) URL to make request to
      *       Writer = (input) writer utility that will save the result
      *       Reader = (input) reader utility that will read the data to send
      *
      *  Sends an exception method upon error. (call http_error for details)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http            B                   export
     D                 PI
     D   Method                      10a   varying const
     D   URL                      32767a   varying const
     D   hWriter                       *   const
     D   hReader                       *   const
     D                                     options(*nopass:*omit)

     D msgText         s             80a   varying
     D msgKey          s              4a
     D comm            s               *
     D rc              s             10i 0
     D UseReader       s              1n

      /free
       SetRespCode(0);
       p_global = getGlobalPtr();

       if %parms >= 4 and %addr(hReader) <> *null;
          UseReader = *on;
       endif;

       comm = http_persist_open( URL: global.timeout );
       if comm = *null;
          rc = -1;
       endif;

       if rc = 0;

          if UseReader;
             rc = http_persist( Method
                              : comm
                              : URL
                              : hWriter
                              : hReader );
          else;
             rc = http_persist( Method
                              : comm
                              : URL
                              : hWriter
                              : *OMIT );
          endif;

          http_persist_close(comm);

       endif;

       if rc <> 1;
          msgText = %trimr(http_error());
          QMHSNDPM( 'CPF9897'
                  : 'QCPFMSG   *LIBL'
                  : msgText
                  : %len(msgText)
                  : '*ESCAPE'
                  : '*'
                  : 1
                  : msgKey
                  : ApiEscape );
       endif;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * ValidateRDWR(): Validates that a reader or writer provided to
      *                 HTTPAPI is following the Reader/Writer interface
      *                 specifications.
      *
      *   handle = (input) RDWR handle data structure
      *    Usage = (input) Direction to validate for
      *
      * Returns 0 if RDWR is valid, -1 upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ValidateRDWR    B
     D                 PI            10i 0
     D   handle                            like(RDWR_HANDLE) value
     D   Usage                        3u 0 value

     D h               ds                  likeds(RDWR_t) based(handle)
     D type            s             10a   varying

      /free
       if Usage = RDWR_READER;
          Type = 'Reader';
       else;
          Type = 'Writer';
       endif;

       if h.length < %size(RDWR_t);
          SetError( HTTP_BAD_RDWR
                  : Type + ' provided an invalid +
                     handle length');
          return -1;
       endif;

       if h.version <> x'0101';
          SetError( HTTP_BAD_RDWR
                  : Type + ' version is unsupported +
                     by this version of HTTPAPI');
          return -1;
       endif;

       if %bitand( h.Direction : Usage) <> Usage;
          SetError( HTTP_BAD_RDWR : 'The routine provided +
                    in the ' + Type + ' parameter is not +
                    a ' + Type + ' routine');
          return -1;
       endif;

       if h.open = *null
          or h.close = *null
          or h.cleanup = *null
          or (Usage=RDWR_READER and h.read = *null)
          or (Usage=RDWR_WRITER and h.write = *null);
          SetError( HTTP_BAD_RDWR
                  : Type + ' does not provide the required +
                    functions');
          return -1;
       endif;

       return 0;
      /end-free
     P                 e

      /endif

      /define ERRNO_LOAD_PROCEDURE
      /copy ERRNO_H
