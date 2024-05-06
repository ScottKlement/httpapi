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
      */                                                                            +
      *
      *
      * COMMSSLR4: Comm driver for TLS (Transport Layer Security)
      *
      *
      *> ign: DLTMOD &O/&ON
      *>      CRTRPGMOD MODULE(&O/&ON) SRCFILE(&L/&F) DBGVIEW(&DV)
      *>      UPDSRVPGM SRVPGM(&O/HTTPAPIR4) MODULE((&O/&ON))
      *> ign: DLTMOD &O/&ON
      *
      /if defined(HAVE_SRCSTMT_NODEBUGIO)
     H OPTION(*SRCSTMT: *NOSHOWCPY)
      /endif
     H NOMAIN

      /define HTTP_ORIG_SOAPACTION
      /copy httpapi_h
      /copy socket_h
      /copy gskssl_h
      /copy errno_h
      /copy private_h

     D p_CommSSL       s               *
     D CommSSL         ds                  based(p_CommSSL)
     D    p_Resolve...
     D                                 *   procptr
     D    p_Connect...
     D                                 *   procptr
     D    p_Upgrade...
     D                                 *   procptr
     D    p_Read...
     D                                 *   procptr
     D    p_BlockRead...
     D                                 *   procptr
     D    p_BlockWrite...
     D                                 *   procptr
     D    p_LineRead...
     D                                 *   procptr
     D    p_LineWrite...
     D                                 *   procptr
     D    p_Hangup...
     D                                 *   procptr
     D    p_Cleanup...
     D                                 *   procptr
     D    fd                         10I 0
     D    bufSize                    10u 0
     D    bufLen                     10u 0
     D    sslmode                     1n
     D                                3a
     D    bufBase                      *
     D    bufCurr                      *
     D    sslh                         *


     D CommSSL_New     PR              *

     D CommSSL_Resolve...
     D                 PR              *
     D   peHandle                      *   value
     D   peHost                        *   value options(*string)
     D   peService                     *   value options(*string)
     D   pePort                      10I 0 value
     D   peForced                     1N   const

     D CommSSL_Connect...
     D                 PR             1N
     D   peHandle                      *   value
     D   peSockaddr                    *   value
     D   peTimeout                   10P 3 value

     D CommSSL_Upgrade...
     D                 PR             1N
     D   peHandle                      *   value
     D   peTimeout                   10P 3 value
     D   peEndHost                     *   value options(*string)

     D CommSSL_Read...
     D                 PR            10I 0
     D   peHandle                      *   value
     D   peBuffer                      *   value
     D   peSize                      10I 0 value
     D   peTimeout                   10P 3 value

     D CommSSL_BlockRead...
     D                 PR            10I 0
     D   peHandle                      *   value
     D   peBuffer                      *   value
     D   peSize                      10I 0 value
     D   peTimeout                   10P 3 value

     D CommSSL_BlockWrite...
     D                 PR            10I 0
     D   peHandle                      *   value
     D   peBuffer                      *   value
     D   peSize                      10I 0 value
     D   peTimeout                   10P 3 value

     D CommSSL_LineRead...
     D                 PR            10I 0
     D   handle                        *   value
     D   buffer                        *   value
     D   bufsize                     10I 0 value
     D   peTimeout                   10P 3 value

     D CommSSL_LineWrite...
     D                 PR            10I 0
     D   peHandle                      *   value
     D   peBuffer                      *   value
     D   peBufSize                   10I 0 value
     D   peTimeout                   10P 3 value

     D CommSSL_Hangup...
     D                 PR             1N
     D   peHandle                      *   value

     D CommSSL_Cleanup...
     D                 PR             1N
     D   peHandle                      *   value

     D ssl_error       PR           256A
     D   peErr                       10I 0 value

     D SSL_protocol    PR            20A   varying
     D    peHandle                         like(gsk_handle) value
     D    peVersion                        like(GSK_ENUM_ID)
     D                                     options(*omit)

     D SSL_force_protocol...
     D                 PR             1N
     D    peHandle                         like(gsk_handle) value
     D    peSSLv2                     1N   const
     D    peSSLv3                     1N   const
     D    peTLSv10                    1N   const

     D TLS_force_protocol...
     D                 PR             1N
     D    peHandle                         like(gsk_handle) value
     D    peTLSv10                    1N   const
     D    peTLSv11                    1N   const
     D    peTLSv12                    1N   const
     D    peTLSv13                    1N   const

     D TLS_set_version...
     D                 PR             1N
     D    peHandle                         like(gsk_handle) value
     D    peVersion                        like(GSK_ENUM_ID) value
     D    peValue                     1N   const

     D gskit_cleanup   PR
     D   peAgMark                    10U 0
     D   peReason                    10U 0
     D   peResult                    10U 0
     D   peUserRc                    10U 0

     D https_connect   PR            10I 0
     D   peSockAddr                    *   value
     D   peTimeout                   10I 0 value
     D   peSSLh                        *

     D https_close     PR            10I 0
     D  peSSLh                             like(gsk_handle) value

     D SSL_debug_cert_info...
     D                 PR
     D   peSSLh                            like(GSK_HANDLE) value
     D   peInfoID                    10I 0 value
     D SSL_debug_cert_body...
     D                 PR
     d    peBody                       *   value
     D    peLen                      10I 0 value
     D SSL_debug_cert_elem...
     D                 PR
     D    peElemNo                   10I 0 value
     D    peData                       *   value
     D    peLen                      10I 0 value
     D SSL_validate_cert...
     D                 PR            10i 0
     D   peSSLh                            like(GSK_HANDLE) value
     D SSL_get_proto   PR
     D   peValue                     10a   dim(10)

     D refill          PR            10i 0
     D   peTimeout                   10P 3 value

     D wkEnvH          s               *   inz(*NULL)
     D wkFullAuth      s              1n   inz(*OFF)
     D wkValProc       s               *   inz(*null) procptr
     D wkValUsrDta     s               *   inz(*null)
     D wkGskValProc    s               *   inz(*null) procptr
     D wkGskValUsrDta  s               *   inz(*null)
     D HTTP_DEBUG_LEVEL...
     D                 s             10i 0 inz(1)

     D Kdb             ds                  qualified
     D   Override                     1n   inz(*off)
     D   Path                       256a   varying inz('')
     D   Label                      256a   varying inz('')
     D   Password                   256a   varying inz('')

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Build a new TCP communications driver
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommSSL_New     B                   export
     D CommSSL_New     PI              *

     C                   eval      p_CommSSL = xalloc(%size(CommSSL))

     c                   eval      CommSSL = *ALLx'00'
      * Initially, the connection is in plain text mode,
      * so the CommTCP driver is used for most things.
      * (The Upgrade() function will change this, however)
     c                   eval      p_Read      =%paddr('COMMTCP_READ')
     c                   eval      p_BlockRead =%paddr('COMMTCP_BLOCKREAD')
     c                   eval      p_BlockWrite=%paddr('COMMTCP_BLOCKWRITE')
     c                   eval      p_LineRead  =%paddr('COMMTCP_LINEREAD')
     c                   eval      p_LineWrite =%paddr('COMMTCP_LINEWRITE')
     c                   eval      p_Hangup    =%paddr('COMMTCP_HANGUP')
      * Some functions, however, are SSL-specific:
     c                   eval      p_Resolve   =%paddr('COMMSSL_RESOLVE')
     c                   eval      p_Connect   =%paddr('COMMSSL_CONNECT')
     c                   eval      p_Upgrade   =%paddr('COMMSSL_UPGRADE')
     c                   eval      p_Cleanup   =%paddr('COMMSSL_CLEANUP')
     c                   eval      fd = -1
     c                   eval      sslh = *NULL
     c                   eval      sslmode = *off

     c                   eval      bufSize = 131072
     c                   eval      bufBase = xalloc(bufSize)
     c                   eval      bufLen  = 0
     c                   eval      bufCurr = bufBase

     c                   eval      HTTP_DEBUG_LEVEL = getDebugLevel()
     c                   return    p_CommSSL
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Resolve host name
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommSSL_Resolve...
     P                 B                   export
     D                 PI              *
     D   peHandle                      *   value
     D   peHost                        *   value options(*string)
     D   peService                     *   value options(*string)
     D   pePort                      10I 0 value
     D   peForced                     1N   const

      * Use the standard TCP/IP resolver... nothing SSL-specific here.
     c                   return    CommTcp_Resolve( peHandle
     c                                            : peHost
     c                                            : peService
     c                                            : pePort
     c                                            : peForced )
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * connect to a server
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommSSL_Connect...
     P                 B                   export
     D CommSSL_Connect...
     D                 PI             1N
     D   peHandle                      *   value
     D   peSockaddr                    *   value
     D   peTimeout                   10P 3 value

     D s               S             10I 0

     c                   eval      p_CommSSL = peHandle

     C*********************************************************
     C* If SSL has not yet been initialized, initialize it
     C* with default values.
     C*********************************************************
     c                   if        wkEnvH = *NULL
     c                   if        https_init(*blanks) = -1
     c                   return    *OFF
     c                   endif
     c                   endif

     C*********************************************************
     C* We "Borrow" the connect() functionality from CommTCPR4
     C*********************************************************
     c                   eval      s = CommTCP_ConnectNonBlock( peSockAddr
     c                                                        : peTimeout )
     C                   if        s < 0
     c                   return    *OFF
     c                   endif

     c                   eval      fd = s
     C                   return    *ON
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Upgrade socket to SSL
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommSSL_Upgrade...
     P                 B                   export
     D CommSSL_Upgrade...
     D                 PI             1N
     D   peHandle                      *   value
     D   peTimeout                   10P 3 value
     D   peEndHost                     *   value options(*string)

     D s               S             10I 0
     D wwfds           S                   like(fdset)
     D wwFlags         S             10U 0
     D wwBufSize       s             10I 0
     D wwTV            s                   like(timeval)
     D wwSSLh          s               *
     D rc              S             10I 0
     D wwValCode       s             10I 0
     D wwSniHost       s            256a   inz(*blanks)

     c                   eval      p_CommSSL = peHandle
     c                   eval      s = fd

      *********************************************************
      *  Get endpoint host name if provided as a parameter
      *  this is used for server name indication (SNI) later
      *********************************************************
     c                   if        %parms >= 3 and peEndHost <> *null
     c                   eval      wwSniHost = %str(peEndHost)
     c                   endif

     C*********************************************************
     C* create a secure socket from the environment handle,
     C*   associate it with our socket, and initialize it.
     C*********************************************************
     c                   eval      rc = gsk_secure_soc_open(wkEnvH: wwSSLh)
     c                   if        rc <> GSK_OK
     c                   callp     SetError(HTTP_SSOPEN: 'gsk_sec_soc_open: ' +
     c                               ssl_error(rc))
     c                   callp     close(s)
     c                   return    *OFF
     c                   endif

     c                   eval      rc = gsk_attribute_set_numeric_value(
     c                             wwSSLh: GSK_HANDSHAKE_TIMEOUT: peTimeout)
     c                   if        rc <> GSK_OK
     c                   callp     SetError(HTTP_SSSNTO: 'Setting timeout: ' +
     c                               ssl_error(rc))
     c                   callp     close(s)
     c                   callp     gsk_secure_soc_close(wwsslh)
     c                   return    *OFF
     c                   endif

     c                   eval      rc = gsk_attribute_set_numeric_value(
     c                             wwSSLh: GSK_IBMI_READ_TIMEOUT:
     c                             peTimeout * 1000 )
     c                   if        rc <> GSK_OK
     c                   callp     SetError(HTTP_SSSNTO: 'Setting timeout: ' +
     c                               ssl_error(rc))
     c                   callp     close(s)
     c                   callp     gsk_secure_soc_close(wwsslh)
     c                   return    *OFF
     c                   endif

     c                   eval      rc = gsk_attribute_set_numeric_value(
     c                              wwSslh: GSK_FD: s)
     c                   if        rc <> GSK_OK
     c                   callp     SetError(HTTP_SSSNFD: 'Setting fd: ' +
     c                               ssl_error(rc))
     c                   callp     close(s)
     c                   callp     gsk_secure_soc_close(wwsslh)
     c                   return    *OFF
     c                   endif

     c                   if        wwSniHost <> *blanks
     c                   eval      rc = gsk_attribute_set_buffer( wwSSLh
     c                                : GSK_SSL_EXTN_SERVERNAME_REQUEST
     c                                : %trim(wwSniHost)
     c                                : %len(%trim(wwSniHost)) )
     c                   if        rc = GSK_OK
     c                   callp     http_dmsg('SNI hostname set to: '
     c                              + %trim(wwSniHost))
     c                   else
     c                   callp     http_dmsg('SNI hostname error: '
     c                              + ssl_error(rc))
     c                   callp     http_dmsg('NOTE: SNI errors are not '
     c                              + 'usually fatal.')
     c                   endif
     c                   endif

     c                   eval      rc = gsk_secure_soc_init(wwSslh)
     c                   if        rc <> GSK_OK
     c                   if        rc = GSK_IBMI_ERROR_TIMED_OUT
     c                   callp     SetError(HTTP_SSTIMO: 'Time out during '+
     c                               'SSL handshake')
     c                   callp     gsk_secure_soc_close(wwsslh)
     c                   return    *OFF
     c                   endif
     c                   callp     SetError(HTTP_SSSNFD: 'SSL Handshake: ' +
     c                               ssl_error(rc))
     c                   return    *OFF
     c                   endif

     C*********************************************************
     C* Write certificate information to debugging log:
     C*********************************************************
     c                   callp     http_dmsg('---------------------------'+
     c                                       '---------------------------'+
     c                                       '---------------------------'+
     c                                       '----')

     c                   callp     http_dmsg('Dump of server-side certifi'+
     c                                       'cate information:')

     c                   callp     http_dmsg('---------------------------'+
     c                                       '---------------------------'+
     c                                       '---------------------------'+
     c                                       '----')

     c                   callp     gsk_attribute_get_numeric_value(
     c                               wwSSlh                          :
     c                               GSK_CERTIFICATE_VALIDATION_CODE :
     c                               wwValCode                       )

     c                   callp     http_dmsg('Cert Validation Code = '
     c                                      + %trim(%editc(wwValCode:'L')))

     c                   callp     SSL_debug_cert_info(wwSslh
     c                                           : GSK_PARTNER_CERT_INFO )

     c                   if        rc <> GSK_OK
     c                   callp     close(s)
     c                   callp     gsk_secure_soc_close(wwsslh)
     c                   return    *OFF
     c                   endif

     c                   callp     http_dmsg('Protocol Used: ' +
     c                                SSL_protocol(wwSSLh: *OMIT))


      *********************************************************
      * Validate SSL certificate against user-supplied
      * certificate verification routine
      *********************************************************
     c                   if        SSL_validate_cert(wwSSLh) <> 0
     c                   callp     close(s)
     c                   callp     gsk_secure_soc_close(wwsslh)
     c                   return    *OFF
     c                   endif

     C*********************************************************
     C* Since SSL is now active, use the SSL routines instead
     C* of the plain TCP ones.
     C*********************************************************
     c                   eval      p_Read      =%paddr('COMMSSL_READ')
     c                   eval      p_BlockRead =%paddr('COMMSSL_BLOCKREAD')
     c                   eval      p_BlockWrite=%paddr('COMMSSL_BLOCKWRITE')
     c                   eval      p_LineRead  =%paddr('COMMSSL_LINEREAD')
     c                   eval      p_LineWrite =%paddr('COMMSSL_LINEWRITE')
     c                   eval      p_Hangup    =%paddr('COMMSSL_HANGUP')
     c                   eval      sslh = wwSSLh

     c                   return    *ON
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Read data from socket w/a timeout
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommSSL_Read...
     P                 B                   export
     D CommSSL_Read...
     D                 PI            10I 0
     D   peHandle                      *   value
     D   peBuffer                      *   value
     D   peSize                      10I 0 value
     D   peTimeout                   10P 3 value

     D wwLen           S             10I 0

     c                   eval      p_CommSSL = pehandle

     c                   if        refill(peTimeout) = -1
     c                   return    -1
     c                   endif

     c                   eval      wwLen = peSize
     c                   if        wwLen > bufLen
     c                   eval      wwLen = bufLen
     c                   endif

     c                   callp     memcpy(peBuffer: bufCurr: wwLen)
     c                   eval      bufLen = bufLen - wwLen
     c                   if        bufLen > 0
     c                   eval      bufCurr = bufCurr + wwLen
     c                   endif

     c                   callp     http_dwrite(peBuffer: wwLen)
     c                   return    wwLen
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Read data from socket in a fixed-length block
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommSSL_BlockRead...
     P                 B                   export
     D CommSSL_BlockRead...
     D                 PI            10I 0
     D   peHandle                      *   value
     D   peBuffer                      *   value
     D   peSize                      10I 0 value
     D   peTimeout                   10P 3 value

     D wwLen           s             10I 0
     D wwRec           s             10I 0

     c                   eval      wwLen = 0

     c                   dow       peSize > 0

     c                   eval      wwRec = CommSSL_read( peHandle
     c                                                 : peBuffer
     c                                                 : peSize
     c                                                 : peTimeout )
     c                   if        wwRec < 1
     c                   if        wwLen = 0
     c                   return    -1
     c                   else
     c                   return    wwLen
     c                   endif
     c                   endif

     c                   eval      wwLen = wwLen + wwRec
     c                   eval      peBuffer = peBuffer + wwRec
     c                   eval      peSize = peSize - wwRec
     c                   enddo

     c                   return    wwLen
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Write data to socket in a fixed-length block
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommSSL_BlockWrite...
     P                 B                   export
     D CommSSL_BlockWrite...
     D                 PI            10I 0
     D   peHandle                      *   value
     D   peBuffer                      *   value
     D   peSize                      10I 0 value
     D   peTimeout                   10P 3 value

     D wwPos           S               *
     D wwDeref         S              1A   based(wwPos)
     D wwLeft          S             10I 0
     D rc              S             10I 0
     D wwSent          S             10I 0
     D wwLen           S             10I 0

      /if defined(USE_POLL)
     D pfd             ds                  likeds(pollfd_t) dim(1)
      /else
     D wwFds           S                   like(fdset)
     D wwTimeout       S              8A
      /endif

     c                   eval      wwPos = peBuffer
     c                   eval      wwLeft = peSize

     c                   dow       wwLeft > 0

     c                   if        HTTP_DEBUG_LEVEL > 1
     c                   callp     socket_status('CommSSL_BlockWrite'
     c                              : 'gsk_secure_soc_write'
     c                              : fd )
     c                   endif

     c                   eval      rc = gsk_secure_soc_write(sslh:
     c                                wwPos: wwLeft: wwLen )

     c                   if        HTTP_DEBUG_LEVEL > 1
     c                   callp     http_dmsg('CommSSL_BlockWrite(): +
     c                              gsk_secure_soc_write rc=' +
     c                              %char(rc) + ', len=' + %char(wwLen))
     c                   endif

     c                   if        rc <> GSK_OK

     c                   if        rc <> GSK_WOULD_BLOCK
     c                   callp     SetError(HTTP_BWSEND
     c                                     : 'CommSSL_BlockWrite: send: '
     c                                     +  ssl_error(rc) )
     c                   return    -1
     c                   endif

      /if defined(USE_POLL)
     c                   eval      pfd(1) = *ALLx'00'
     c                   eval      pfd(1).fd = fd
     c                   eval      pfd(1).events = POLLOUT

     c                   eval      rc = poll( pfd: 1: peTimeout * 1000)

     c                   if        rc < 0
     c                   callp     SetError(HTTP_BWSELE
     c                                     : 'CommSSL_BlockWrite: poll: '
     c                                     +  %str(strerror(errno)) )
     c                   return    -1
     c                   endif

     c                   if        rc = 0
     c                   callp     SetError(HTTP_BWTIMO
     c                                     : 'CommSSL_BlockWrite: '
     c                                     +  'timeout!')
     c                   return    -1
     c                   endif

      /else
     c                   eval      p_timeval = %addr(wwTimeout)
     c                   eval      tv_sec = peTimeout
     c                   eval      tv_usec = (peTimeout-tv_sec)*1000000

     c                   callp     CommTCP_FD_ZERO(wwfds)
     c                   callp     CommTCP_FD_SET(fd: wwfds)

     c                   if        HTTP_DEBUG_LEVEL > 1
     c                   callp     select_status( 'CommSSL_BlockWrite'
     c                                          : 'before select'
     c                                          : fd
     c                                          : *null
     c                                          : %addr(wwfds)
     c                                          : *null
     c                                          : %addr(wwTimeout))
     c                   endif


     c                   eval      rc = select(fd+1: *NULL: %addr(wwFds):
     c                               *NULL: %addr(wwTimeout))

     c                   if        HTTP_DEBUG_LEVEL > 1
     c                   callp     select_status( 'CommSSL_BlockWrite'
     c                                          : 'after select'
     c                                          : fd
     c                                          : *null
     c                                          : %addr(wwfds)
     c                                          : *null
     c                                          : %addr(wwTimeout)
     c                                          : rc )
     c                   endif

     c                   if        rc < 0
     c                   callp     SetError(HTTP_BWSELE
     c                                     : 'CommSSL_BlockWrite: select: '
     c                                     +  %str(strerror(errno)) )
     c                   return    -1
     c                   endif

     c                   if        CommTCP_FD_IsSet(fd: wwfds) = *Off
     c                   callp     SetError(HTTP_BWTIMO
     c                                     : 'CommSSL_BlockWrite: '
     c                                     +  'timeout!')
     c                   return    -1
     c                   endif
      /endif

     c                   iter
     c                   endif

     c                   callp     http_dwrite(wwPos: wwLen)

     c                   eval      wwLeft = wwLeft - wwLen
     c                   eval      wwSent = wwSent + wwLen

     c                   if        wwLeft > 0
     c                   eval      wwPos = wwPos + wwLen
     c                   endif

     c                   enddo

     c                   return    wwSent
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Read data from socket as a CR/LF terminated line
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommSSL_LineRead...
     P                 B                   export
     D CommSSL_LineRead...
     D                 PI            10I 0
     D   peHandle                      *   value
     D   peBuffer                      *   value
     D   peSize                      10I 0 value
     D   peTimeout                   10P 3 value

     d EOL             c                   const(x'0a')
     d len             s             10I 0
     D left            s             10i 0
     D bufPos          s               *
     D Pos             s               *

     c                   if        peSize <= 0
     c                   return    0
     c                   endif

     c                   eval      p_commSSL = peHandle
     c                   eval      len  = 0
     c                   eval      left = peSize
     c                   eval      bufPos = peBuffer

      *************************************************
      * keep receiving as long as there is space to
      * receive the data into.
      *************************************************
     c                   dow       left > 0

     c                   if        refill(peTimeout) = -1
     c                   return    -1
     c                   endif

     c                   eval      len = bufLen
     c                   if        len > left
     c                   eval      len = left
     c                   endif

      *************************************
      * if linefeed found, copy it and all
      * preceding characters to return buf
      *************************************
     c                   eval      pos = memchr(bufCurr: EOL: len)
     c                   if        pos <> *null
     c                   eval      len = (pos - bufCurr) + 1
     c                   callp     memcpy(bufPos: bufCurr: len)
     c                   eval      bufLen = bufLen - len
     c                   eval      left = left - len
     c                   if        bufLen > 0
     c                   eval      bufCurr = bufCurr + len
     c                   endif
     c                   leave
     c                   endif

      *************************************
      * linefeed not found in buffer, so
      * copy everything over to buffer and
      * refill from the socket
      *************************************
     c                   callp     memcpy(bufPos: bufCurr: len)
     c                   eval      bufLen  = bufLen - len
     c                   eval      bufPos = bufPos + len
     c                   eval      left = left - len
     c                   if        bufLen > 0
     c                   eval      bufCurr = bufCurr + len
     c                   endif

     c                   enddo

     c                   callp     http_dwrite(peBuffer: peSize - left)
     c                   return    peSize - left
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Write data to socket as a CR/LF terminated line
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommSSL_LineWrite...
     P                 B                   export
     D CommSSL_LineWrite...
     D                 PI            10I 0
     D   peHandle                      *   value
     D   peBuffer                      *   value
     D   peBufSize                   10I 0 value
     D   peTimeout                   10P 3 value

     D p_Buf           s               *
     D p_EOL           s               *
     D wwEOL           s              2A   based(p_EOL)
     D rc              s             10I 0

     c                   eval      p_Buf = xalloc(peBufSize+%size(wwEOL))
     c                   callp     memcpy(p_Buf: peBuffer: peBufSize)

     c                   eval      p_EOL = p_Buf + peBufSize
     c                   eval      wwEOL = x'0d0a'

     c                   eval      rc = CommSSL_BlockWrite( peHandle
     c                                            : p_buf
     c                                            : peBufSize+%size(wwEOL)
     c                                            : peTimeout )

     c                   callp     xdealloc(p_buf)
     c                   return    rc
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Disconnect session
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommSSL_Hangup...
     P                 B                   export
     D CommSSL_Hangup...
     D                 PI             1N
     D   peHandle                      *   value
     c                   eval      p_CommSSL = peHandle
     c                   callp     gsk_secure_soc_close(sslh)
     c                   callp     close(fd)
     c                   return    *ON
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Cleanup module
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommSSL_Cleanup...
     P                 B                   export
     D CommSSL_Cleanup...
     D                 PI             1N
     D   peHandle                      *   value
     c                   eval      p_CommSSL = peHandle
     c                   callp     xdealloc(bufBase)
     c
     c                   callp(e)  xdealloc(peHandle)
     c                   if        %error
     c                   return    *OFF
     c                   else
     c                   return    *ON
     c                   endif
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * https_certStore(): Access an alternate certificate store
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P https_certStore...
     P                 B                   export
     D                 PI
     D  KdbPath                    5000a   varying const
     D  KdbPassword                 256a   varying const
     D  KdbLabel                   5000a   varying const

     c                   if        wkEnvH <> *null
     c                   callp     https_cleanup
     c                   endif

     C                   if        KdbPath = '*CLEAR'
     c                   eval      Kdb = *ALLx'00'
     c                   eval      Kdb.Override = *off
     c                   else
     C                   eval      Kdb.Path     = KdbPath
     C                   eval      Kdb.Password = KdbPassword
     C                   eval      Kdb.Label    = KdbLabel
     C                   eval      Kdb.Override = *On
     c                   endif

     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * https_init():  Initialize https (HTTP over SSL/TLS) protocol
      *
      *     peAppID = application ID that you registered program as
      *        in the Digital Certificate Manager
      *         NOTE: You can pass *BLANKS for this parameter if you
      *               you do not wish to register your application
      *               with the digital certificate manager.
      *     peSSLv2 = (optional) Turn SSL version 2 *ON or *OFF
      *     peSSLv3 = (optional) Turn SSL version 3 *ON or *OFF
      *    peTLSv10 = (optional) Turn TLS version 1.0 *ON or *OFF
      *    peTLSv11 = (optional) Turn TLS version 1.1 *ON or *OFF
      *    peTLSv12 = (optional) Turn TLS version 1.2 *ON or *OFF
      *    peTLSv13 = (optional) Turn TLS version 1.3 *ON or *OFF
      *
      *   You must pass all of the SSL/TLS flags or none.  If you
      *   do not pass all three flags, they are ignored.
      *
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P https_init      B                   export
     D https_init      PI            10I 0
     D  peAppID                     100A   const
     D  peSSLv2                       1N   const options(*nopass)
     D  peSSLv3                       1N   const options(*nopass)
     D  peTLSv10                      1N   const options(*nopass)
     D  peTLSv11                      1N   const options(*nopass)
     D  peTLSv12                      1N   const options(*nopass)
     D  peTLSv13                      1N   const options(*nopass)

     D LastAppId       s            100A   static inz(*blanks)

     D FdBk            ds                  inz
     D    sev                         5u 0
     D    msgno                       5u 0
     D    flags                       1a
     D    facid                       3a
     D    isi                        10u 0

     D CEE4RAGE        PR
     D   procedure                     *   procptr const
     D   feedback                          like(fdbk) options(*omit)

     D CEESGL          PR
     D   cond_rep                          like(fdbk)
     D   q_data_token                10i 0 const options(*omit)
     D   feedback                          like(fdbk) options(*omit)

     D rc              S             10I 0
     D ssl_auth_type   s             10i 0

     D sslpcl          s             10a   dim(10)
     D p               s             10i 0
     D pclmsg          s            256a

     D mySSLV2         s              1n   inz(*off)
     D mySSLV3         s              1n   inz(*off)
     D myTLSV10        s              1n   inz(*on)
     D myTLSV11        s              1n   inz(*on)
     D myTLSV12        s              1n   inz(*on)
     D myTLSV13        s              1n   inz(*on)

     c                   if        %parms >= 2
     c                   eval      mySSLV2 = peSSLV2
     c                   endif

     c                   if        %parms >= 3
     c                   eval      mySSLV3 = peSSLV3
     c                   endif

     c                   if        %parms >= 4
     c                   eval      myTLSV10 = peTLSV10
     c                   endif

     c                   if        %parms >= 5
     c                   eval      myTLSV11 = peTLSV11
     c                   endif

     c                   if        %parms >= 6
     c                   eval      myTLSV12 = peTLSV12
     c                   endif

     c                   if        %parms >= 7
     c                   eval      myTLSV13 = peTLSV13
     c                   endif

     c                   callp     http_dmsg('https_init(): entered')

     c                   if        wkEnvH <> *NULL
     c                             and peAppID <> LastAppId
     c                   callp     https_cleanup
     c                   eval      wkEnvH = *null
     c                   endif

     c                   if        wkEnvH <> *NULL
     c                   callp     SetError(HTTP_GSKENVI: 'SSL environment'+
     c                             ' was already initialized!')
     c                   return    0
     c                   endif

     c                   eval      LastAppId = peAppId

     c                   eval      rc = gsk_environment_open(wkEnvh)
     c                   if        rc <> GSK_OK
     c                   callp     SetError(HTTP_GSKENVO: 'gsk_env_open: '+
     c                               ssl_error(rc))
     c                   return    -1
     c                   endif

     C* make sure that whatever happens, we clean up the GSKit environment
     C* since it uses a significant portion of memory.
     C                   callp     CEE4RAGE(%paddr('GSKIT_CLEANUP'): FdBk )
     c                   if        sev<>0
     c                   if        facid='CEE' and msgno=12545
     c                   callp     util_diag('HTTPAPI is running in ' +
     c                             'default activation group. ' +
     c                             'https_cleanup must be run explcitly.')
     c                   else
     C                   callp     CEESGL(fdbk: *omit: *omit)
     c                   endif
     c                   endif

      **************************************************************
      *  If https_certStore() was called, use those parameters
      **************************************************************
     c                   if        kdb.Override = *on

     c                   callp     http_dmsg('Overriding to alternate +
     c                               certificate store ' + kdb.Path )

     c                   eval      rc = gsk_attribute_set_buffer( wkEnvH
     c                                : GSK_KEYRING_FILE
     c                                : kdb.Path
     c                                : %len(kdb.Path) )
     c                   if        rc <> GSK_OK
     c                   callp     SetError(HTTP_GSKKEYF:'Attempt to use ' +
     c                               kdb.Path + ' cert store: ' +
     c                               ssl_error(rc))
     c                   callp     https_cleanup
     c                   return    -1
     c                   endif

     c                   if        kdb.Password <> ''
     c                   eval      rc = gsk_attribute_set_buffer( wkEnvH
     c                                : GSK_KEYRING_PW
     c                                : kdb.Password
     c                                : %len(kdb.Password) )
     c                   if        rc = GSK_OK
     c                   callp     http_dmsg('- Keyring password +
     c                             has been set.')
     c                   else
     c                   callp     SetError(HTTP_GSKKEYF:'Keyring PW: ' +
     c                               ssl_error(rc))
     c                   callp     https_cleanup
     c                   return    -1
     c                   endif
     c                   endif

     c                   if        kdb.Label <> ''
     c                   eval      rc = gsk_attribute_set_buffer( wkEnvH
     c                                : GSK_KEYRING_LABEL
     c                                : kdb.Label
     c                                : %len(kdb.Label) )
     c                   if        rc = GSK_OK
     c                   callp     http_dmsg('- Keyring certificate +
     c                             label has been set.')
     c                   else
     c                   callp     SetError(HTTP_GSKKEYF:'Keyring Label: '+
     c                               ssl_error(rc))
     c                   callp     https_cleanup
     c                   return    -1
     c                   endif
     c                   endif

      **************************************************************
      *  If https_certStore() was not used...
      **************************************************************
     c                   else

     C* If peAppId begins with a slash the assume it is the name of the keyring file
     c                   if        %subst(peAppId :1 :1) = '/'
     c                   eval      rc = gsk_attribute_set_buffer(
     c                              wkEnvh: GSK_KEYRING_FILE:
     c                              peAppId: %len(%trim(peAppId)))
     c                   if        rc <> GSK_OK
     c                   callp     SetError(HTTP_GSKKEYF:'Attempt to use ' +
     c                               %trim(peAppId) + ' cert store: ' +
     c                               ssl_error(rc))
     c                   callp     https_cleanup
     c                   return    -1
     c                   endif
     c                   endif

     C* If no application ID was given, use the *SYSTEM certificate
     C* store as our keyring:
     c                   if        peAppId = *blanks
     c                   eval      rc = gsk_attribute_set_buffer(
     c                              wkEnvh: GSK_KEYRING_FILE:
     c                              '*SYSTEM': 0)
     c                   if        rc <> GSK_OK
     c                   callp     SetError(HTTP_GSKKEYF:'Attempt to use ' +
     c                               '*SYSTEM cert store: ' +
     c                               ssl_error(rc))
     c                   callp     https_cleanup
     c                   return    -1
     c                   endif
     c                   endif

     C* If an application ID was given, use that to associate with the
     C* digital certificate manager:
     c                   if        peAppID <> *blanks
     c                             and %subst(peAppId :1 :1) <> '/'
     c                   eval      rc = gsk_attribute_set_buffer(
     c                              wkEnvh: GSK_IBMI_APPLICATION_ID:
     c                              %trimr(peAppID): 0)
     c                   if        rc <> GSK_OK
     c                   callp     SetError(HTTP_GSKAPPID:'Setting ID: ' +
     c                               ssl_error(rc))
     c                   callp     https_cleanup
     c                   return    -1
     c                   endif
     c                   endif

     c                   endif

     C* tell GSKit that we're a client app:
     c                   eval      rc = gsk_attribute_set_enum(wkEnvh:
     c                               GSK_SESSION_TYPE: GSK_CLIENT_SESSION)
     c                   if        rc <> GSK_OK
     c                   callp     SetError(HTTP_GSKSTYP: 'Setting ' +
     c                             'session type: ' + ssl_error(rc))
     c                   callp     https_cleanup
     c                   return    -1
     c                   endif

     C* How shall we validate the server's certificate?
     c                   if        wkFullAuth = *ON
     c                   eval      ssl_auth_type = GSK_SERVER_AUTH_FULL
     c                   else
     c                   eval      ssl_auth_type = GSK_SERVER_AUTH_PASSTHRU
     c                   endif

      * (Note: GSK_SERVER_AUTH_TYPE isn't available on V5R2 and
      *        earlier without a PTF.  See APAR SE07984 for more
      *        info.  If the current system doesn't support this
      *        option, GSK_ATTRIBUTE_INVALID_ID will be returned. )

     c                   eval      rc = gsk_attribute_set_enum(wkEnvh
     c                                : GSK_SERVER_AUTH_TYPE
     c                                : ssl_auth_type       )
     c                   if        rc <> GSK_OK
     c                               and rc <> GSK_ATTRIBUTE_INVALID_ID
     c                   callp     SetError(HTTP_GSKATYP: 'Setting ' +
     c                             'auth type: ' + ssl_error(rc))
     c                   callp     https_cleanup
     c                   return    -1
     c                   endif

     C* How shall we validate a client certificate?
     C* ( FIXME: does this do anything? We don't receive connects
     C*          from any clients...? )
     c*
     c                   if        wkFullAuth = *ON
     c                   eval      ssl_auth_type = GSK_CLIENT_AUTH_FULL
     c                   else
     c                   eval      ssl_auth_type = GSK_CLIENT_AUTH_PASSTHRU
     c                   endif

     c                   eval      rc = gsk_attribute_set_enum(wkEnvh
     c                                : GSK_CLIENT_AUTH_TYPE
     c                                : ssl_auth_type )

     c                   if        rc <> GSK_OK
     c                   callp     SetError(HTTP_GSKATYP: 'Setting ' +
     c                             'auth type: ' + ssl_error(rc))
     c                   callp     https_cleanup
     c                   return    -1
     c                   endif

      * Show the QSSLPCL (SSL Protocol) system value in log
     c                   eval      pclmsg = 'QSSLPCL ='
     c                   callp     SSL_get_proto( sslpcl )
     c                   for       p = 1 to %elem(sslpcl)
     c                   if        sslpcl(p) <> *blanks
     c                   eval      pclmsg = %trimr(pclmsg) + ' '
     c                                    + sslpcl(p)
     c                   endif
     c                   endfor

     c                   callp     http_dmsg(pclmsg)

      * Set the allowed SSL/TLS versions here
      *  note that since SSLv2 and SSLv3 are no longer considered secure,
      *  we turn them off unless the caller explicitly turns them on.
      *
     c                   if        SSL_force_protocol( wkEnvh
     c                                               : mySSLv2
     c                                               : mySSLv3
     c                                               : myTLSv10 ) = *OFF
     c                   callp     https_cleanup
     c                   return    -1
     c                   endif

      * we enable all TLS versions by default. (But they can be overridden
      * by the caller).  Note that IBM i 7.1 disables TLS v1.1 and v1.2
      * by default -- and since these are more secure than v1.0, we
      * ignore the OS defaults.
     c                   if        TLS_force_protocol( wkEnvh
     c                                               : myTLSv10
     c                                               : myTLSv11
     c                                               : myTLSv12
     c                                               : myTLSv13 ) = *OFF
     c                   callp     https_cleanup
     c                   return    -1
     c                   endif

     C* If requested, set up a certificate validation callback
      /if defined(V5R3_GSKIT)
     c                   if        wkGskValUsrDta <> *null
     c                   callp     gsk_attribute_set_callback( wkEnvh
     c                                : GSK_CERT_VALIDATION_CALLBACK
     c                                : wkGskValUsrDta )
     c                   endif
      /endif

     C* Initialize the SSL environment.  After this, secure sessions
     C*   can be created!
     c                   callp     http_dmsg('initializing GSK environment')

     c                   eval      rc = gsk_environment_init(wkEnvh)
     c                   if        rc <> GSK_OK
     c                   if        rc = GSK_IBMI_ERROR_NOT_REGISTERED
     c                   callp     SetError(HTTP_NOTREG: 'Application ' +
     c                             'is not registered with DCM!')
     c                   callp     https_cleanup
     c                   return    -1
     c                   else
     c                   callp     SetError(HTTP_GSKATYP: 'gsk_env_init: '+
     c                                         ssl_error(rc))
     c                   callp     https_cleanup
     c                   return    -1
     c                   endif
     c                   endif

     c                   callp     http_dmsg('GSK Environment now available')

     c                   callp     http_dmsg('---------------------------'+
     c                                       '---------------------------'+
     c                                       '---------------------------'+
     c                                       '----')

     c                   callp     http_dmsg('Dump of local-side certific'+
     c                                       'ate information:')

     c                   callp     http_dmsg('---------------------------'+
     c                                       '---------------------------'+
     c                                       '---------------------------'+
     c                                       '----')

     c                   callp     SSL_debug_cert_info(wkEnvh
     c                                           : GSK_LOCAL_CERT_INFO )

     c                   if        rc = GSK_OK
     c                   return    0
     c                   else
     c                   callp     https_cleanup
     c                   return    -1
     c                   endif
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Register your application with the Digital Certificate Manager
      *
      *    peAppID = application ID.  IBM recommends that you do
      *         something like:  COMPANY_COMPONENT_NAME
      *         (example:  QIBM_DIRSRV_REPLICATION)
      *
      *  peLimitCA = set to *On if you want to only want to allow the
      *         certificate authorities registered in D.C.M., or set to
      *         *Off if you'll manage that yourself.
      *
      *   returns 0 for success, or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P https_dcm_reg   B                   export
     D https_dcm_reg   PI            10I 0
     D  peAppID                     100A   const
     D  peLimitCA                     1N   const

      ****************************************************************
      *  Register Application for Certificate Use API
      *
      *  When the application is registered, registration information
      *  is stored in the OS/400 registration facility.  You can
      *  re-register using the appropriate control key.
      ****************************************************************
     D QSYRGAP         PR                  ExtPgm('QSYRGAP')
     D   ApplicID                   100A   options(*varsize)
     D   ApplicIDLen                 10I 0 const
     D   ApplicCtrls                256A   const
     D   ErrorCode                32766A   options(*varsize)

      ****************************************************************
      *  Format of Variable-Length Application Control Records
      *  used by the QSYRGAP (Register App For Cert Use) API.
      ****************************************************************
     D p_RGAP_DS1      S               *
     D RGAP_DS1        DS                  BASED(p_RGAP_DS1)
     D   RGAP_DS1_VarRecLen...
     D                               10I 0
     D   RGAP_DS1_AppCtrlKey...
     D                               10I 0
     D   RGAP_DS1_DataLen...
     D                               10I 0
     D   RGAP_DS1_Data...
     D                               50A

      ****************************************************************
      *  Application Control Key Values used by QSYRGAP API
      ****************************************************************
     D RGAP_QEXITPGM   C                   1
     D RGAP_APPTEXT    C                   2
     D RGAP_QMSGF      C                   3
     D RGAP_LIMITCA    C                   4
     D RGAP_REPLACE    C                   5
     D RGAP_THRSAFE    C                   6
     D RGAP_THRACTN    C                   7
     D RGAP_APPTYPE    C                   8

     D SERVER          C                   '1'
     D CLIENT          C                   '2'

     D wwAppID         S            100A
     D wwAppIDLen      S             10I 0
     D wwBuf           s            100A
     D p_NumKeys       S               *
     D wwNumKeys       S             10I 0 based(p_NumKeys)

     D dsEC            DS
     D  dsECBytesP             1      4I 0 INZ(256)
     D  dsECBytesA             5      8I 0 INZ(0)
     D  dsECMsgID              9     15
     D  dsECReserv            16     16
     D  dsECMsgDta            17    256
     c                   callp     http_dmsg('https_dcm_reg(): entered')

     C* Number of control keys:
     c                   eval      p_NumKeys = %addr(wwBuf)
     c                   eval      wwNumKeys = 0

     C* First key is "limit CA" which we set to '0'
     c                   eval      wwNumKeys = wwNumKeys + 1
     c                   eval      p_RGAP_DS1 = %addr(wwBuf) + 4
     c                   eval      RGAP_DS1_VarRecLen = 13
     c                   eval      RGAP_DS1_AppCtrlKey = RGAP_LIMITCA
     c                   eval      RGAP_DS1_DataLen = 1
     c                   eval      %subst(RGAP_DS1_Data:1:1) = peLimitCA

     C* Next key is "replace" which we set to '1' so we can
     C*    run this code each time the program runs without
     C*    getting an error.
     c                   eval      wwNumKeys = wwNumKeys + 1
     c                   eval      p_RGAP_DS1= %addr(wwBuf) + 17
     c                   eval      RGAP_DS1_VarRecLen = 13
     c                   eval      RGAP_DS1_AppCtrlKey = RGAP_REPLACE
     c                   eval      RGAP_DS1_DataLen = 1
     c                   eval      %subst(RGAP_DS1_Data:1:1) = '1'

     C* If this is V5R1 or later, we register as a client
     C*    application, since the DCM now distinguishes client & server
      /if not defined(V4R5_GSKIT)
     c                   eval      wwNumKeys = wwNumKeys + 1
     c                   eval      p_RGAP_DS1= %addr(wwBuf) + 30
     c                   eval      RGAP_DS1_VarRecLen = 13
     c                   eval      RGAP_DS1_AppCtrlKey = RGAP_APPTYPE
     c                   eval      RGAP_DS1_DataLen = 1
     c                   eval      %subst(RGAP_DS1_Data:1:1) = CLIENT
      /endif

     C* Call API, if theres an error, return the msg-id:
     c                   eval      wwAppId = %triml(peAppId)
     c                   eval      wwAppIdLen = %len(%trimr(wwAppId))
     c                   callp(e)  QSYRGAP(wwAppID: wwAppIdLen: wwBuf: dsEC)
     c                   if        %error
     c                   callp     SetError(HTTP_REGERR:'Failure trying ' +
     c                             'to register app.  See job log')
     c                   return    -1
     c                   endif
     c                   if        dsECBytesA > 0
     c                   callp     SetError(HTTP_REGERR:'Register App ' +
     c                             'failed with ' + dsECMsgID)
     c                   return    -1
     c                   endif

     c                   return    0
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  return an error message for a return code from a GSKit API
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ssl_error       B
     D ssl_error       PI           256A
     D   peErr                       10I 0 value

     D wwMsg           S            256A

     c                   select
     c                   when      peErr = GSK_OK
     c                   eval      wwMsg = 'No error'
     c                   when      peErr = GSK_ERROR_IO
     c                   eval      wwMsg = '(GSKit) I/O: ' +
     c                                     %str(strerror(errno))
     c                   callp     util_diag(wwMsg)
     c                   other
      /if defined(V4R5_GSKIT)
     c                   eval      wwMsg = 'GSKit error #' +
     c                                %trim(%editc(peErr:'P'))
     c                   callp     util_diag(wwMsg)
      /else
     c                   eval      wwMsg = '(GSKit) ' +
     c                                %str(gsk_strerror(peErr))
     c                   callp     util_diag(wwMsg)
      /endif
     c                   endsl

     c                   callp     http_dmsg('ssl_error(' +
     c                                        %trim(%editc(peErr:'P')) +
     c                                        '): ' + wwMsg)

     c                   return    wwMsg
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSL_protocol():  Get the SSL protocol version of the session
      *
      *       peHandle = (input) SSL Handle
      *      peVersion = (output) GSK_ENUM_ID of the protocol version
      *
      *  returns the human-readable protocol name or '' upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SSL_protocol    B
     D SSL_protocol    PI            20A   varying
     D    peHandle                         like(gsk_handle) value
     D    peVersion                        like(GSK_ENUM_ID)
     D                                     options(*omit)

     D wwName          s             20A   varying
     D wwVersion       s                   like(GSK_ENUM_VALUE)
     D rc              s             10I 0

     c                   eval      rc = gsk_attribute_get_enum( peHandle :
     c                                                 GSK_PROTOCOL_USED :
     c                                                 wwVersion         )
     c                   select
     c                   when      rc <> GSK_OK
     c                   callp     SetError(HTTP_SSPROT: 'SSL_protocol: '+
     c                                   ssl_error(rc))
     c                   return    ''
     c                   when      wwVersion = GSK_PROTOCOL_USED_SSLV2
     c                   eval      wwName = 'SSL Version 2'
     c                   when      wwVersion = GSK_PROTOCOL_USED_SSLV3
     c                   eval      wwName = 'SSL Version 3'
     c                   when      wwVersion = GSK_PROTOCOL_USED_TLSV1
     c                   eval      wwName = 'TLS Version 1.0'
     c                   when      wwVersion = GSK_PROTOCOL_USED_TLSV11
     c                   eval      wwName = 'TLS Version 1.1'
     c                   when      wwVersion = GSK_PROTOCOL_USED_TLSV12
     c                   eval      wwName = 'TLS Version 1.2'
     c                   when      wwVersion = GSK_PROTOCOL_USED_TLSV13
     c                   eval      wwName = 'TLS Version 1.3'
     c                   other
     c                   callp     SetError(HTTP_SSPUNK: 'SSL_protocol: '+
     c                                   'Unknown protocol ' +
     c                                    %trim(%editc(wwVersion:'Z')))
     c                   return    ''
     c                   endsl

     c                   if        %addr(peVersion) <> *NULL
     c                   eval      peVersion = wwVersion
     c                   endif

     c                   return    wwName
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSL_force_protocol():  Force a particular SSL protocol
      *
      * Note: for TLS v1.1 and higher, see TLS_force_protocol()
      *
      *       peHandle = (input) SSL Handle (to env or to session)
      *        peSSLv2 = (input) Turn SSLv2 *ON or *OFF
      *        peSSLv3 = (input) Turn SSLv3 *ON or *OFF
      *       peTLSv10 = (input) Turn TLSv1.0 *ON or *OFF
      *
      *  returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SSL_force_protocol...
     P                 B
     D SSL_force_protocol...
     D                 PI             1N
     D    peHandle                         like(gsk_handle) value
     D    peSSLv2                     1N   const
     D    peSSLv3                     1N   const
     D    peTLSv10                    1N   const

     D rc              s             10I 0
     D wwSSLv2         s                   like(GSK_ENUM_VALUE)
     D wwSSLv3         s                   like(GSK_ENUM_VALUE)
     D wwTLSv10        s                   like(GSK_ENUM_VALUE)
     D myAction        s              8a

      *************************************************
      * Set the SSLv2 protocol on or off
      *************************************************
     c                   if        peSSLv2 = *ON
     c                   eval      wwSSLv2 = GSK_PROTOCOL_SSLV2_ON
     c                   eval      myAction = 'enabled'
     c                   else
     c                   eval      wwSSLv2 = GSK_PROTOCOL_SSLV2_OFF
     c                   eval      myAction = 'disabled'
     c                   endif

     c                   eval      rc = gsk_attribute_set_enum( peHandle :
     c                                                GSK_PROTOCOL_SSLV2 :
     c                                                wwSSLv2            )
     c                   if        rc <> GSK_OK
     c                   callp     SetError(HTTP_SSPSET: SSL_error(rc))
     c                   return    *OFF
     c                   endif

     c                   callp     http_dmsg('SSL version 2'
     c                              + ' support '
     c                              + %trim(myAction))

      *************************************************
      * Set the SSLv3 protocol on or off
      *************************************************
     c                   if        peSSLv3 = *ON
     c                   eval      wwSSLv3 = GSK_PROTOCOL_SSLV3_ON
     c                   eval      myAction = 'enabled'
     c                   else
     c                   eval      wwSSLv3 = GSK_PROTOCOL_SSLV3_OFF
     c                   eval      myAction = 'disabled'
     c                   endif

     c                   eval      rc = gsk_attribute_set_enum( peHandle :
     c                                                GSK_PROTOCOL_SSLV3 :
     c                                                wwSSLv3            )
     c                   if        rc <> GSK_OK
     c                   callp     SetError(HTTP_SSPSET: SSL_error(rc))
     c                   return    *OFF
     c                   endif

     c                   callp     http_dmsg('SSL version 3'
     c                              + ' support '
     c                              + %trim(myAction))

      *************************************************
      * Set the TLS v1.0 protocol on or off
      *************************************************
     c                   if        peTLSv10 = *ON
     c                   eval      wwTLSv10 = GSK_PROTOCOL_TLSV1_ON
     c                   eval      myAction = 'enabled'
     c                   else
     c                   eval      wwTLSv10 = GSK_PROTOCOL_TLSV1_OFF
     c                   eval      myAction = 'disabled'
     c                   endif

     c                   eval      rc = gsk_attribute_set_enum( peHandle :
     c                                                GSK_PROTOCOL_TLSV1 :
     c                                                wwTLSv10           )
     c                   if        rc <> GSK_OK
     c                   callp     SetError(HTTP_SSPSET: SSL_error(rc))
     c                   return    *OFF
     c                   endif

     c                   callp     http_dmsg('Old interface to '
     c                              + 'TLS version 1.0 support '
     c                              + %trim(myAction))

     c                   return    *ON
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * TLS_force_protocol(): Force a particular TLS version
      *
      *  This requires V7R1 TR6 or newer, so will not give an
      *  error if the options aren't available...
      *
      *       peHandle = (input) SSL Handle (to env or to session)
      *       peTLSv10 = (input) Turn TLSv1.0 *ON or *OFF
      *       peTLSv11 = (input) Turn TLSv1.1 *ON or *OFF
      *       peTLSv12 = (input) Turn TLSv1.2 *ON or *OFF
      *       peTLSv13 = (input) Turn TLSv1.3 *ON or *OFF
      *
      *  returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P TLS_force_protocol...
     P                 B
     D                 PI             1N
     D    peHandle                         like(gsk_handle) value
     D    peTLSv10                    1N   const
     D    peTLSv11                    1N   const
     D    peTLSv12                    1N   const
     D    peTLSv13                    1N   const

     C                   if        TLS_set_version( peHandle
     C                                            : GSK_PROTOCOL_TLSV10
     c                                            : peTLSv10 ) = *OFF
     c                   return    *OFF
     c                   endif

     C                   if        TLS_set_version( peHandle
     C                                            : GSK_PROTOCOL_TLSV11
     c                                            : peTLSv11 ) = *OFF
     c                   return    *OFF
     c                   endif

     C                   if        TLS_set_version( peHandle
     C                                            : GSK_PROTOCOL_TLSV12
     c                                            : peTLSv12 ) = *OFF
     c                   return    *OFF
     c                   endif

     C                   if        TLS_set_version( peHandle
     C                                            : GSK_PROTOCOL_TLSV13
     c                                            : peTLSv13 ) = *OFF
     c                   return    *OFF
     c                   endif

     c                   return    *ON
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  TLS_set_version(): Enable/Disable support for TLS versions
      *
      *    peHandle = (input) environment handle
      *   peVersion = (input) GSKit enum for TLS version to set
      *     peValue = (input) *ON to enable, *OFF to disable.
      *
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P TLS_set_version...
     P                 B
     D                 PI             1N
     D    peHandle                         like(gsk_handle) value
     D    peVersion                        like(GSK_ENUM_ID) value
     D    peValue                     1N   const

     D rc              s             10I 0
     D myVersion       s              3a
     D myAction        s              8a
     D myValue         s                   like(GSK_ENUM_VALUE)

     c                   select
     c                   when      peVersion = GSK_PROTOCOL_TLSV10
     c                   eval      myVersion = '1.0'
     c                   when      peVersion = GSK_PROTOCOL_TLSV11
     c                   eval      myVersion = '1.1'
     c                   when      peVersion = GSK_PROTOCOL_TLSV12
     c                   eval      myVersion = '1.2'
     c                   when      peVersion = GSK_PROTOCOL_TLSV13
     c                   eval      myVersion = '1.3'
     c                   other
     c                   callp     SetError( HTTP_TLSSET
     c                                     : 'Unknown TLS version')
     c                   return    *OFF
     c                   endsl

     c                   if        peValue = *ON
     c                   eval      myValue = GSK_TRUE
     c                   eval      myAction = 'enabled'
     c                   else
     c                   eval      myValue = GSK_FALSE
     c                   eval      myAction = 'disabled'
     c                   endif

     c                   eval      rc = gsk_attribute_set_enum( peHandle
     c                                                        : peVersion
     c                                                        : myValue )

     c                   if        rc = GSK_ATTRIBUTE_INVALID_ID
     c                             or rc = GSK_ERROR_UNSUPPORTED
     c                   callp     http_dmsg('Support for TLS '
     c                             + %trim(myVersion)
     c                             + ' unavailable.')
     c                   return    *ON
     c                   endif

     c                   if        rc <> GSK_OK
     c                   callp     SetError(HTTP_TLSSET: SSL_error(rc))
     c                   return    *OFF
     c                   endif

     c                   callp     http_dmsg('TLS version '
     c                              + %trim(myVersion)
     c                              + ' support '
     c                              + %trim(myAction))

     c                   return    *ON
     p                 e

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * gskit_cleanup():  Clean up the GSKit SSL environment
      *
      *      peAgMark = Activation group mark (ignored)
      *      peReason = Reason for cleaning up (ignored)
      *      peResult = Result of cleanup 0=success, 20=fail
      *      peUserRC = User result code (ignored)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P gskit_cleanup   B                   export
     D gskit_cleanup   PI
     D   peAgMark                    10U 0
     D   peReason                    10U 0
     D   peResult                    10U 0
     D   peUserRc                    10U 0

     D rc              s             10I 0

     c                   if        wkEnvH = *NULL
     c                   eval      peResult = 0
     c                   return
     c                   endif

     c                   eval      rc = gsk_environment_close(wkEnvH)

     c                   if        rc = GSK_OK
     c                   eval      wkEnvH = *NULL
     c                   eval      peResult = 0
     c                   else
     c                   eval      peResult = 20
     c                   endif

     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * https_cleanup():  Clean up & free storage used by the SSL
      *   environment.
      *
      *  returns 0 if successful, -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P https_cleanup   B                   export
     D https_cleanup   PI            10I 0

     D wwAgMark        s             10U 0 inz(0)
     D wwReason        s             10U 0 inz(0)
     D wwResult        s             10U 0 inz(21)
     D wwUserRC        s             10U 0 inz(0)

     c                   if        wkEnvH = *NULL
     c                   return    0
     c                   endif

     c                   callp     gskit_cleanup( wwAgMark
     c                                          : wwReason
     c                                          : wwResult
     c                                          : wwUserRC)

     c                   if        wwReason = 0
     c                   return    0
     c                   else
     c                   return    -1
     c                   endif
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  https_connect():  connect to a HTTP server over TLS/SSL
      *
      *    peSockAddr = ptr to socket address structure for server
      *           (can be obtained by called http_build_sockaddr)
      *    peTimeout  = number of seconds before time-out when connecting
      *       peSSLh  = SSL connection handle
      *
      *  Returns -1 upon failure, or the socket descriptor of the
      *        connection upon success.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P https_connect   B                   export
     D https_connect   PI            10I 0
     D   peSockAddr                    *   value
     D   peTimeout                   10I 0 value
     D   peSSLh                        *
     c                   callp     SetError( HTTP_NOTSUPP
     c                                     : 'This procedure is no '
     c                                     + 'longer supported.')
     c                   return    -1
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Close HTTP connection
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P https_close     B                   export
     D https_close     PI            10I 0
     D  peSSLh                             like(gsk_handle) value
      *  This is now a No-Op
     c                   return    0
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * https_idname(): Returns a string that describes an SSL certificate
      *                  data element id (for printing/debugging)
      *
      *       peID = (input) data ID to get name of
      *
      * Returns the human-readable name
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P https_idname    B                   export
     D https_idname    PI            50A   varying
     D   peID                        10I 0 value
     c                   select
     c                   when      peID = CERT_BODY_DER
     c                   return    'Body (DER)'
     c                   when      peID = CERT_BODY_BASE64
     c                   return    'Body (base64)'
     c                   when      peID = CERT_SERIAL_NUMBER
     c                   return    'Serial Number'
     c                   when      peID = CERT_COMMON_NAME
     c                   return    'Common Name'
     c                   when      peID = CERT_LOCALITY
     c                   return    'Locality'
     c                   when      peID = CERT_STATE_OR_PROVINCE
     c                   return    'State/Province'
     c                   when      peID = CERT_COUNTRY
     c                   return    'Country'
     c                   when      peID = CERT_ORG
     c                   return    'Org Unit'
     c                   when      peID = CERT_ORG_UNIT
     c                   return    'Org'
     c                   when      peID = CERT_DN_PRINTABLE
     c                   return    'DN'
     c                   when      peID = CERT_DN_DER
     c                   return    'DN (DER)'
     c                   when      peID = CERT_POSTAL_CODE
     c                   return    'PostalCode'
     c                   when      peID = CERT_EMAIL
     c                   return    'E-Mail'
     c                   when      peID = CERT_ISSUER_COMMON_NAME
     c                   return    'Issuer CN'
     c                   when      peID = CERT_ISSUER_LOCALITY
     c                   return    'Issuer Locality'
     c                   when      peID = CERT_ISSUER_STATE_OR_PROVINCE
     c                   return    'Issuer State/Province'
     c                   when      peID = CERT_ISSUER_COUNTRY
     c                   return    'Issuer Country'
     c                   when      peID = CERT_ISSUER_ORG
     c                   return    'Issuer Org'
     c                   when      peID = CERT_ISSUER_ORG_UNIT
     c                   return    'Issuer Org Unit'
     c                   when      peID = CERT_ISSUER_DN_PRINTABLE
     c                   return    'Issuer DN'
     c                   when      peID = CERT_ISSUER_DN_DER
     c                   return    'Issuer DN (DER)'
     c                   when      peID = CERT_ISSUER_POSTAL_CODE
     c                   return    'Issuer Postal Code'
     c                   when      peID = CERT_ISSUER_EMAIL
     c                   return    'Issuer E-Mail'
     c                   when      peID = CERT_VERSION
     c                   return    'Version'
     c                   when      peID = CERT_SIGNATURE_ALGORITHM
     c                   return    'signature algorithm'
     c                   when      peID = CERT_VALID_FROM
     c                   return    'not before'
     c                   when      peID = CERT_VALID_TO
     c                   return    'not after'
     c                   when      peID = CERT_PUBLIC_KEY_ALGORITHM
     c                   return    'pub key alg'
     c                   when      peID = CERT_ISSUER_UNIQUEID
     c                   return    'issuer unique id'
     c                   when      peID = CERT_SUBJECT_UNIQUEID
     c                   return    'subject unique id'
     c                   other
     c                   return    'Unknown Field'
     c                   endsl
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSL_debug_cert_info(): Print certificate info into debug file
      *
      *      peSSLh = (input) SSL handle
      *    peInfoID = (input) either GSK_LOCAL_CERT_INFO
      *                           or GSK_PARTNER_CERT_INFO
      *
      * Returns the human-readable name
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SSL_debug_cert_info...
     P                 B
     D SSL_debug_cert_info...
     D                 PI
     D   peSSLh                            like(GSK_HANDLE) value
     D   peInfoID                    10I 0 value

     D p_start         s               *
     D rc              s             10I 0
     D wwCount         s             10I 0
     D wwSize          s             10I 0
     D wwEntry         s             10I 0

     c                   eval      rc = gsk_attribute_get_cert_info(
     c                                      peSSLh                 :
     c                                      peInfoID               :
     c                                      p_start                :
     c                                      wwCount                )

     c                   if        rc <> GSK_OK
     c                   callp     http_dmsg(SSL_error(rc))
     c                   return
     c                   endif

     c                   eval      wwCount = wwCount - 1
     c                   eval      wwSize = %size(gsk_cert_data_elem)

     c     0             do        wwCount       wwEntry

     c                   eval      p_gsk_cert_data_elem =
     c                                 p_start + (wwEntry * wwSize)

     c                   select
     c                   when      cert_data_id = CERT_BODY_BASE64
     c                   callp     ssl_debug_cert_body( cert_data_p
     c                                                : cert_data_l )

     c                   when      cert_data_id = CERT_DN_PRINTABLE
     c                             or cert_data_id = CERT_DN_DER
     c                             or cert_data_id = CERT_BODY_DER
     c                             or cert_data_id = CERT_ISSUER_DN_DER
     c                             or cert_data_id =
     c                                           CERT_ISSUER_DN_PRINTABLE

     c                   other
     c                   callp     ssl_debug_cert_elem( cert_data_id
     c                                                : cert_data_p
     c                                                : cert_data_l )
     c                   endsl

     c                   enddo
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Print certificate body into debug file
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SSL_debug_cert_body...
     P                 B
     D SSL_debug_cert_body...
     D                 PI
     d    peBody                       *   value
     D    peLen                      10I 0 value

     D CHUNK           C                   64
     D wwCRLF          s              2A   inz(x'0d25')

     c                   callp     http_xlate( %len(wwCRLF)
     c                                       : wwCRLF
     c                                       : TO_ASCII   )

     c                   callp     http_dmsg('-----BEGIN CERTIFICATE-----')

     c                   dow       peLen > CHUNK
     c                   callp     http_dwrite(peBody: CHUNK)
     c                   callp     http_dwrite(%addr(wwCRLF): %size(wwCRLF))
     c                   eval      peLen = peLen - CHUNK
     c                   eval      peBody = peBody + CHUNK
     c                   enddo

     c                   if        peLen > 0
     c                   callp     http_dwrite(peBody: peLen)
     c                   endif

     c                   callp     http_dmsg('-----END CERTIFICATE-----')
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Print certificate element into debug file
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SSL_debug_cert_elem...
     P                 B
     D SSL_debug_cert_elem...
     D                 PI
     D    peElemNo                   10I 0 value
     D    peData                       *   value
     D    peLen                      10I 0 value

     D wwName          s             52A   varying
     D p_data          s               *
     D wwCRLF          s              2A   inz(x'0d25')

     c                   callp     http_xlate( %len(wwCRLF)
     c                                       : wwCRLF
     c                                       : TO_ASCII   )

     c                   eval      wwName = https_IDname(peElemNo) + ': '

     c                   eval      p_data = %addr(wwName) + VARPREF
     c                   callp     http_xlatep( %len(wwName)
     c                                        : p_data
     c                                        : TO_ASCII )

     c                   callp     http_dwrite(p_data: %len(wwName))
     c                   callp     http_dwrite(peData: peLen)
     c                   callp     http_dwrite(%addr(wwCRLF): %len(wwCRLF))
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Called by HTTPAPIR4 to set any SSL-related exit points.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P commssl_setxproc...
     P                 B                   export
     D commssl_setxproc...
     D                 PI
     D    pePoint                    10I 0 value
     D    peProc                       *   procptr value
     D    peUsrDta                     *   value
     C                   select
     c                   when      pePoint = HTTP_POINT_CERT_VAL
     c                   eval      wkValProc   = peProc
     c                   eval      wkValUsrDta = peUsrDta
     c                   when      pePoint = HTTP_POINT_GSKIT_CERT_VAL
     c                   eval      wkGskValProc   = peProc
     c                   eval      wkGskValUsrDta = peUsrDta
     c                   endsl

     c                   callp     https_cleanup
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSL_validate_cert(): Verify the partner's certificate
      *
      *      peSSLh = (input) SSL handle
      *
      * Returns the human-readable name
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SSL_validate_cert...
     P                 B
     D SSL_validate_cert...
     D                 PI            10i 0
     D   peSSLh                            like(GSK_HANDLE) value

     D cert_val_callback...
     D                 PR            10i 0 extPRoc(wkValProc)
     D   usrdta                        *   value
     D   id                          10i 0 value
     D   data                     32767a   varying const
     D   errmsg                      80a

     D p_start         s               *
     D rc              s             10I 0
     D wwCount         s             10I 0
     D wwSize          s             10I 0
     D wwEntry         s             10I 0
     D wwCancel        s              1n
     D wwMsg           s             80a
     D Data            s          32767a   based(p_data)
     D wwParm          s          32767a   varying

     c                   if        wkValProc = *null
     c                   return    0
     c                   endif

      ****************************************************
      * Ask GSKit for certificate information
      ****************************************************
     c                   eval      rc = gsk_attribute_get_cert_info(
     c                                      peSSLh                 :
     c                                      GSK_PARTNER_CERT_INFO  :
     c                                      p_start                :
     c                                      wwCount                )

     c                   if        rc <> GSK_OK
     c                   callp     http_dmsg(SSL_error(rc))
     c                   callp     SetError( HTTP_SSLGCI
     c                             : 'gsk_attribute_get_cert_info:'
     c                             + SSL_error(rc) )
     c                   return    -1
     c                   endif

     c                   eval      wwCount = wwCount - 1
     c                   eval      wwSize = %size(gsk_cert_data_elem)

      ****************************************************
      *  Loop through the certificate elements
      ****************************************************
     c     0             do        wwCount       wwEntry

     c                   eval      p_gsk_cert_data_elem =
     c                                 p_start + (wwEntry * wwSize)

     c                   eval      p_data = cert_data_p
     c                   eval      wwParm = %subst(data:1:cert_data_l)

      *****************************
      * If text, convert to EBCDIC
      *****************************
     c                   if        cert_data_id <> CERT_DN_DER
     c                             and cert_data_id <> CERT_BODY_DER
     c                             and cert_data_id <> CERT_ISSUER_DN_DER
     c                             and cert_data_l > 0
     c                   eval      p_data = %addr(wwParm) + VARPREF
     c                   callp     http_xlatep( cert_data_l
     c                                        : p_data
     c                                        : TO_EBCDIC )
     c                   endif

      *****************************
      * Run the callback
      *****************************
     c                   eval      rc = cert_val_callback( wkValUsrDta
     c                                                   : cert_data_id
     c                                                   : wwParm
     c                                                   : wwMsg       )
     c                   if        rc <> 0
     c                   callp     SetError( HTTP_SSLVAL: wwMsg )
     c                   return    -1
     c                   endif

     c                   enddo

     c                   return    0
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * https_strict(): Force SSL to be strictly validated
      *
      *      peSetting = (input) *ON  = use full validation
      *                          *OFF = use passthru validation
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P https_strict    B                   export
     D https_strict    PI
     D   peSetting                    1n   const
     c                   if        peSetting <> wkFullAuth
     c                   eval      wkFullAuth = peSetting
     c                   callp     https_cleanup
     c                   endif
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * SSL_get_proto():  Gets the SSL protocol system value
      *
      *    peValue = (output) array of CHAR(10) containing values
      *
      * Returns -1 upon failure.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P SSL_get_proto   B                   export
     D                 PI
     D   peValue                     10a   dim(10)

     D QWCRSVAL        PR                  ExtPgm('QSYS/QWCRSVAL')
     D   RcvVar                   32767a   options(*varsize)
     D   RcvVarLen                   10i 0 const
     D   NbrSysVal                   10i 0 const
     D   SysValName                  10a   dim(1000) options(*varsize)
     D   ErrorCode                32767a   options(*varsize)

     D SysValBuf       DS         32767
     D    NbrRtn                     10i 0
     D    Offsets                    10i 0 dim(1000)

     D p_SysVal        s               *   inz(*null)
     D SysValDS        DS                  based(p_SysVal)
     D    SysVal                     10a
     D    Type                        1a
     D    Status                      1a
     D    DataLen                    10i 0
     D    Data                       10a   dim(10)

     D ErrorCode       DS
     D    BytesPrv                   10i 0 inz(%size(ErrorCode))
     D    BytesAvl                   10i 0 inz(0)

     D SysValName      s             10a   dim(1)

     c                   eval      SysValName(1) = 'QSSLPCL'
     c                   eval      peValue = *blanks

     c                   callp(e)  QWCRSVAL( SysValBuf
     c                                     : %size(SysValBuf)
     c                                     : 1
     c                                     : SysValName
     c                                     : ErrorCode )

     c                   if        %error = *off
     c                             and BytesAvl = 0
     c                             and NbrRtn >= 1
     c                             and Offsets(1) > 0

     c                   eval      p_SysVal = %addr(SysValBuf)
     c                                      + Offsets(1)

     c                   if        SysVal = SysValName(1)
     c                             and Type = 'C'
     c                             and Status = ' '
     c                             and DataLen = 100
     c                   eval      peValue = Data
     c                   endif

     c                   endif

     c                   return
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * refill(): Refill the internal receive buffer
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P refill          B
     D                 PI            10i 0
     D   peTimeout                   10P 3 value

     D len             S             10I 0
     D rc              s             10I 0
     D safetyNet       s             10i 0

      /if defined(USE_POLL)
     D pfd             ds                  likeds(pollfd_t) dim(1)
      /else
     D timeout         S                   like(timeval)
     D readSet         S                   like(fdset)
      /endif

     c                   if        bufLen > 0
     c                   return    0
     c                   endif

     c                   eval      bufCurr = bufBase

      *************************************************
      * loop until some data is received...
      *************************************************
     c                   dou       len > 0

     c                   eval      rc = gsk_secure_soc_read( sslh
     c                                                     : bufCurr
     c                                                     : bufSize
     c                                                     : len )

      ************************************
      *  len = 0 means the socket is
      *  closed, no more data will come
      ************************************
     c                   if        rc = GSK_OK and len = 0
     c                   callp     SetError(HTTP_BRRECV:'CommTCP_read: '+
     c                               'Socket has been shut down.')
     c                   return    -1
     c                   endif

      ************************************
      * GSK_IBMI_ERROR_TIMED_OUT will
      * happen if timeout is detected
      * within GSKit
      ************************************
     c                   if        rc = GSK_IBMI_ERROR_TIMED_OUT
     c                   callp     SetError(HTTP_BRTIME:'CommSSL_Read: '+
     c                               ' timeout!')
     c                   return    -1
     c                   endif

      ************************************
      *  If an error occurred
      *    - GSK_WOULD_BLOCK means to wait
      *         for more data
      *    - another error is an error
      ************************************
     c                   if        rc <> GSK_OK

     c                   if        rc <> GSK_WOULD_BLOCK
     c                   callp     SetError(HTTP_BRRECV:'CommSSL_read: '+
     c                               ' read:' + ssl_error(rc) )
     c                   return    -1
     c                   endif

     c                   eval      safetyNet = safetyNet + 1
     c                   if        safetyNet = 1000
     c                   callp     SetError(HTTP_BRRECV:'CommSSL_read: '+
     c                               ' safetyNet threshold exceeded' )
     c                   return    -1
     c                   endif

      /if defined(USE_POLL)
     c                   eval      pfd(1) = *allx'00'
     c                   eval      pfd(1).fd = fd
     c                   eval      pfd(1).events = POLLIN

     c                   eval      rc = poll( pfd: 1: peTimeout * 1000)
     c                   if        rc < 0
     c                   callp     SetError(HTTP_BRSELE:'CommSSL_read: '+
     c                               'poll: ' + %str(strerror(errno)) )
     c                   return    -1
     c                   endif

     c                   if        rc = 0
     c                   if        peTimeout >= 1
     c                   callp     SetError(HTTP_BRTIME:'CommSSL_read: '+
     c                               'timeout!')
     c                   else
     c                   callp     SetError(HTTP_BRTIME: 'CommSSL_read: '+
     c                               'No 100-Continue (error ignored)')
     c                   endif
     c                   return    -1
     c                   endif
      /else
     c                   eval      p_timeval = %addr(timeout)
     c                   eval      tv_sec = peTimeout
     c                   eval      tv_usec = (peTimeout-tv_sec) * 1000000

     c                   callp     CommTCP_FD_ZERO(readSet)
     c                   callp     CommTCP_FD_SET(fd: readSet)

     c                   eval      rc = select( fd+1
     c                                        : %addr(readSet)
     c                                        : *null
     c                                        : *null
     c                                        : %addr(timeout) )

     c                   if        rc < 0
     c                   callp     SetError(HTTP_BRSELE:'CommSSL_read: '+
     c                               'select: ' + %str(strerror(errno)) )
     c                   return    -1
     c                   endif

     c                   if        CommTCP_FD_ISSET(fd: readSet) = *Off
     c                   if        peTimeout >= 1
     c                   callp     SetError(HTTP_BRTIME:'CommSSL_read: '+
     c                               'time-out!')
     c                   else
     c                   callp     SetError(HTTP_BRTIME: 'CommSSL_read: '+
     c                               'No 100-Continue (error ignored)')
     c                   endif
     c                   return    -1
     c                   endif
      /endif

     c                   endif
      ************************************

     c                   enddo
      *************************************************

     C                   eval      bufLen = bufLen + len
     C                   return    len
     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy ERRNO_H
