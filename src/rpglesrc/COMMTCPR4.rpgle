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
      * COMMTCPR4: Comm driver for TCP (Transmission Control Protocol)
      *
      *
      *> ign: DLTMOD &O/&ON
      *>      CRTRPGMOD MODULE(&O/&ON) SRCFILE(&L/&F) DBGVIEW(&DV)
      *>      UPDSRVPGM SRVPGM(&O/HTTPAPIR4) MODULE((&O/&ON))
      *> ign: DLTMOD &O/&ON

      /if defined(HAVE_SRCSTMT_NODEBUGIO)
     H OPTION(*SRCSTMT: *NOSHOWCPY)
      /endif
     H NOMAIN

      /define HTTP_ORIG_SOAPACTION
      /copy socket_h
      /copy errno_h
      /copy httpapi_h
      /copy private_h

     D p_CommTcp       s               *
     D CommTcp         ds                  based(p_CommTcp)
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
     D                                4a
     D    bufBase                      *
     D    bufCurr                      *


     D CommTcp_New     PR              *

     D CommTcp_Connect...
     D                 PR             1N
     D   peHandle                      *   value
     D   peSockaddr                    *   value
     D   peTimeout                   10P 3 value

     D CommTcp_Upgrade...
     D                 PR             1N
     D   peHandle                      *   value
     D   peTimeout                   10P 3 value
     D   peEndHost                     *   value options(*string)

     D CommTcp_Read...
     D                 PR            10I 0
     D   peHandle                      *   value
     D   peBuffer                      *   value
     D   peSize                      10I 0 value
     D   peTimeout                   10P 3 value

     D CommTcp_BlockRead...
     D                 PR            10I 0
     D   peHandle                      *   value
     D   peBuffer                      *   value
     D   peSize                      10I 0 value
     D   peTimeout                   10P 3 value

     D CommTcp_BlockWrite...
     D                 PR            10I 0
     D   peHandle                      *   value
     D   peBuffer                      *   value
     D   peSize                      10I 0 value
     D   peTimeout                   10P 3 value

     D CommTcp_LineRead...
     D                 PR            10I 0
     D   handle                        *   value
     D   buffer                        *   value
     D   bufsize                     10I 0 value
     D   peTimeout                   10P 3 value

     D CommTcp_LineWrite...
     D                 PR            10I 0
     D   peHandle                      *   value
     D   peBuffer                      *   value
     D   peBufSize                   10I 0 value
     D   peTimeout                   10P 3 value

     D CommTcp_Hangup...
     D                 PR             1N
     D   peHandle                      *   value

     D CommTcp_Cleanup...
     D                 PR             1N
     D   peHandle                      *   value

     D Resolve         PR            10i 0
     D   peHost                        *   value options(*string)
     D   peService                     *   value options(*string)
     D   pePort                      10I 0 value
     D   peSockaddr                    *   value

     D CalcBitPos      PR
     D    peDescr                    10I 0
     D    peByteNo                    5I 0
     D    peBitMask                   1A

     D refill          PR            10i 0
     D   peTimeout                   10P 3 value

     D MAXNS           C                   3
     D MAXRESOLVSORT   C                   10

     D res             ds                  IMPORT('_res')
     D   retrans                     10i 0
     D   retry                       10i 0
     D   options                      4a
     D   nscount                     10i 0
     D   nsaddr                      16a   dim(MAXNS)
     D   id                           5u 0
     D   defdname                   256a
     D   reserved0                    1a
     D   reserved1                   13a
     D   dnsrch                        *   dim(7)
     D   sort_list                    8a   dim(MAXRESOLVSORT)
     D   res_h_errno                 10i 0
     D   extended_err                10i 0
     D   ndotssort                    1a
     D   state_data                  27a
     D   internal_use                10i 0 dim(4)
     D   reserved                   444a

     D DNS_Info        PR
     D HTTP_DEBUG_LEVEL...
     D                 s             10i 0 inz(1)

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Build a new TCP communications driver
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommTcp_New     B                   export
     D CommTcp_New     PI              *

     C                   eval      p_CommTcp = xalloc(%size(CommTcp))

     c                   eval      CommTcp     =*ALLx'00'
     c                   eval      p_Resolve   =%paddr('COMMTCP_RESOLVE')
     c                   eval      p_Connect   =%paddr('COMMTCP_CONNECT')
     c                   eval      p_Upgrade   =%paddr('COMMTCP_UPGRADE')
     c                   eval      p_Read      =%paddr('COMMTCP_READ')
     c                   eval      p_BlockRead =%paddr('COMMTCP_BLOCKREAD')
     c                   eval      p_BlockWrite=%paddr('COMMTCP_BLOCKWRITE')
     c                   eval      p_LineRead  =%paddr('COMMTCP_LINEREAD')
     c                   eval      p_LineWrite =%paddr('COMMTCP_LINEWRITE')
     c                   eval      p_Hangup    =%paddr('COMMTCP_HANGUP')
     c                   eval      p_Cleanup   =%paddr('COMMTCP_CLEANUP')
     c                   eval      fd = -1

     c                   eval      bufSize = 131072
     c                   eval      bufBase = xalloc(bufSize)
     c                   eval      bufLen  = 0
     c                   eval      bufCurr = bufBase

     c                   eval      HTTP_DEBUG_LEVEL = getDebugLevel()

     c                   return    p_CommTcp
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Resolve a hostname to an IP address
      *
      *    peHandle = handle to this module's data
      *      peHost = hostname to resolve
      *   peService = service name to resolve
      *      pePort = fixed port number to use
      *    peForced = (obsolete??)
      *
      * Returns a pointer to a static sockaddr_in structure.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P commTcp_Resolve...
     P                 B                   export
     D commTcp_Resolve...
     D                 PI              *
     D   peHandle                      *   value
     D   peHost                        *   value options(*string)
     D   peService                     *   value options(*string)
     D   pePort                      10I 0 value
     D   peForced                     1N   const

     D wwAddrBuf       s                   like(sockaddr_in) static

     c                   callp     DNS_Info
     c                   eval      p_CommTcp = peHandle
     c                   if        Resolve( peHost
     c                                    : peService
     c                                    : pePort
     c                                    : %addr(wwAddrBuf) ) = 0
     c                   return    %addr(wwAddrBuf)
     c                   else
     c                   return    *null
     c                   endif
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Resolve():  Look up IP address & port number.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P Resolve         B
     D Resolve         PI            10i 0
     D   peHost                        *   value options(*string)
     D   peService                     *   value options(*string)
     D   pePort                      10I 0 value
     D   peSockaddr                    *   value

     c                   eval      p_Sockaddr = peSockaddr
     c                   eval      sockaddr_in = *ALLx'00'
     c                   eval      sin_family = AF_INET
     c                   eval      sin_addr = 0

     c                   eval      HTTP_DEBUG_LEVEL = getDebugLevel()

     c                   if        HTTP_DEBUG_LEVEL >= 2
     c                   callp     http_dmsg('Resolving host '
     c                                      + %str(peHost))
     c                   endif

      *****************************************************
      * R E S O L V E   H O S T   T O   A D D R E S S
      *****************************************************

      * Check if host is specified as a raw IP address
      * such as http://323223677/path/to/file.html
      *
     c                   if        %scan('.':%str(peHost)) = 0
     c                             and atoll(peHost) > 167772156
     c                   eval      sin_addr = atoll(peHost)

     c                   if        HTTP_DEBUG_LEVEL >= 2
     c                   callp     http_dmsg('Host appears to be a raw'
     c                                      +' IP address. atoll='
     c                                      + %char(sin_addr) )
     c                   endif

     c                   endif

      * Check if host is specified as a "dotted" IP address
      * such as http://192.168.5.1/path/to/file.html
      *
     c                   if        sin_addr = 0
     c                   eval      sin_addr = inet_addr(peHost)

     c                   if        HTTP_DEBUG_LEVEL >= 2
     c                   callp     http_dmsg('inet_addr return value '
     c                                      +'for this host is '
     c                                      + %char(sin_addr) )
     c                   endif

     c                   if        sin_addr = INADDR_NONE
     c                   eval      sin_addr = 0
     c                   endif
     c                   endif

      * Try looking up host as a domain name
      * such as http://www.example.com/path/to/file.html
      *
     c                   if        sin_addr = 0
     c                   eval      p_hostent = gethostbyname(peHost)

     c                   if        HTTP_DEBUG_LEVEL >= 2
     c                   if        p_hostent = *null
     c                   callp     http_dmsg('gethostbyname() returned'
     c                                      + ' *NULL')
     c                   else
     c                   callp     http_dmsg('gethostbyname() returned'
     c                                      + ' ' + %char(h_addr))
     c                   endif
     c                   endif

     c                   if        p_hostent <> *NULL
     c                   eval      sin_addr = h_addr
     c                   endif
     c                   endif

     c                   if        sin_addr = 0
     c                   callp     SetError( HTTP_HOSTNF
     c                                     : 'Host name look up failed.')
     c                   return    -1
     c                   endif

      *****************************************************
      * R E S O L V E   S E R V I C E   T O   P O R T
      *****************************************************

      * If port number was part of URL, use it directly.
      *

     c                   if        HTTP_DEBUG_LEVEL >= 2 and pePort > 0
     c                   callp     http_dmsg('Port specified as number '
     c                                      + %char(pePort))
     c                   endif

     c                   if        pePort > 0
     c                   eval      sin_port = pePort
     c                   return    0
     c                   endif

      * If port number specified as the service name (somehow?)
      * FIXME: I don't think this is possible in v1.10 and up.
      *
     c                   if        atoi(peService) <> 0

     c                   if        HTTP_DEBUG_LEVEL >= 2
     c                   callp     http_dmsg('Service specified as number'
     c                                      + ' ' + %str(peService))
     c                   endif

     c                   eval      sin_port = atoi(peService)
     c                   return    0
     c                   endif

      * Otherwise, look it up in the system's services table
      *

     c                   if        HTTP_DEBUG_LEVEL >= 2
     c                   callp     http_dmsg('Looking up service'
     c                                      + ' ' + %str(peService))
     c                   endif

     c                   eval      p_servent = getservbyname( peService
     c                                                      : 'tcp')

      * Or, if all else fails, fall back to a default.
     c                   if        p_servent = *NULL
     c                   if        %str(peService) = 'https'
     c                   eval      sin_port = 443
     c                   else
     c                   eval      sin_port = 80
     c                   endif
     c                   else
     c                   eval      sin_port = s_port
     c                   endif

     c                   if        HTTP_DEBUG_LEVEL >= 2
     c                   if        p_servent = *null
     c                   callp     http_dmsg('Service not found in'
     c                                      + ' service table. Using '
     c                                      + %char(sin_port))
     c                   else
     c                   callp     http_dmsg('Service table returns'
     c                                      + ' port ' + %char(sin_port))
     c                   endif
     c                   endif

     c                   return    0
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * connect to a server w/blocking socket
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommTcp_Connect...
     P                 B                   export
     D CommTcp_Connect...
     D                 PI             1N
     D   peHandle                      *   value
     D   peSockaddr                    *   value
     D   peTimeout                   10P 3 value

     c                   eval      p_commTCP = peHandle
     c                   eval      fd = CommTCP_ConnectNonBlock( peSockAddr
     c                                                         : peTimeout )
     c                   if        fd = -1
     c                   return    *OFF
     c                   else
     c                   return    *ON
     c                   endif
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Upgrade connection.
      * (This is a no-op in the TCP driver)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommTcp_Upgrade...
     P                 B                   export
     D CommTcp_Upgrade...
     D                 PI             1N
     D   peHandle                      *   value
     D   peTimeout                   10P 3 value
     D   peEndHost                     *   value options(*string)
     C                   return    *ON
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  CommTCP_ConnectNonBlock():  Connect to server.
      *
      *  Connection is made while socket is in non-blocking mode.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommTcp_ConnectNonBlock...
     P                 B                   export
     D CommTcp_ConnectNonBlock...
     D                 PI            10I 0
     D   peSockaddr                    *   value
     D   peTimeout                   10P 3 value
     D   peTTL                       10i 0 const options(*nopass)

     D s               S             10I 0
     D rc              S             10I 0
     D wwFlags         S             10U 0
     D wwBufSize       s             10I 0
     D wwSize          s             10i 0
     D wwConnErr       s             10i 0
     D wwTTL           s             10i 0
     D wwOpt           s             10i 0
      /if defined(USE_POLL)
     D pfd             ds                  likeds(pollfd_t) dim(1)
      /else
     D wwfds           S                   like(fdset)
     D wwTV            s                   like(timeval)
      /endif

      *********************************************************
      *  Create a socket, and set it's options
      *********************************************************
     c*  Create socket
     c                   eval      s = socket( AF_INET
     c                                       : SOCK_STREAM
     c                                       : IPPROTO_IP  )
     c                   if        s < 0
     c                   callp     SetError(HTTP_SOCERR:'socket(): ' +
     c                                %str(strerror(errno)) )
     c                   return    -1
     c                   endif

      * Force buffer sizes to 128k.
     c                   eval      wwBufSize = 128*1024
     c                   callp     setsockopt(s: SOL_SOCKET: SO_RCVBUF:
     c                                %addr(wwBufSize): %size(wwBufSize))
     c                   callp     setsockopt(s: SOL_SOCKET: SO_SNDBUF:
     c                                %addr(wwBufSize): %size(wwBufSize))

     c*  Put socket in nonblocking mode so
     c*   we can do timeouts, etc.
      /if not defined(ENABLE_BLOCKING)
     c                   eval      wwFlags = fcntl(s: F_GETFL)
     c                   eval      wwFlags = wwFlags + O_NONBLOCK
     c                   callp     fcntl(s: F_SETFL: wwFlags)
      /endif

      * Modify TTL if parameter passed
     c                   if        %parms >= 3
     c                             and peTTL > 0
     c                   eval      wwTTL = peTTL
     c                   callp     setsockopt( s
     c                                       : IPPROTO_IP
     c                                       : IP_TTL
     c                                       : %addr(wwTTL)
     c                                       : %size(wwTTL) )
     c                   endif

      * Disable Nagle's Algorithm
     c                   eval      wwOpt = 1
     c                   eval      rc = setsockopt( s
     c                                            : IPPROTO_TCP
     c                                            : TCP_NODELAY
     c                                            : %addr(wwOpt)
     C                                            : %size(wwOpt) )
     c                   if        rc = 0
     c                   callp     http_dmsg( 'Nagle''s algorithm'
     c                             + ' (TCP_NODELAY) disabled.')
     c                   else
     c                   callp     http_dmsg( 'Error disabling Nagle''s'
     c                             + ' (TCP_NODELAY) algorithm.')
     c                   endif

      *********************************************************
      *  Begin the connection process
      *********************************************************
     c                   if        connect(s: peSockAddr: %size(sockaddr))
     c                               < 0
     c                   if        errno <> EINPROGRESS
     c                   callp     SetError(HTTP_BADCNN: 'connect(1): ' +
     c                                %str(strerror(errno)) )
     c                   callp     close(s)
     c                   return    -1
     c                   endif
     c                   endif

     C*********************************************************
     C* Wait for connect to complete:
     C*   because these are non-blocking sockets, the API's
     C*   above will almost always complete before the
     C*   connection is finished.   This code waits for it:
     C*
     C* NOTE: This is old-school. IBM recommends replacing
     C*       the select() API with poll(). See below for
     C*       the poll() replacement.
     C*********************************************************
      /if not defined(USE_POLL)
     c                   eval      p_timeval = %addr(wwTV)
     c                   eval      tv_sec = peTimeout
     c                   eval      tv_usec = (peTimeout-tv_sec)*1000000

     C                   callp     CommTCP_FD_ZERO(wwfds)
     c                   callp     CommTCP_FD_SET(s: wwfds)

     c                   eval      rc = select( s+1
     c                                        : *NULL
     c                                        : %addr(wwfds)
     c                                        : *NULL
     c                                        : p_timeval )
     c                   select
     c                   when      rc = 0
     c                   callp     close(s)
     c                   callp     SetError(HTTP_CNNTIMO:'Timeout occurred '+
     c                             'while trying to connect to server!')
     c                   return    -1

     c                   when      rc = -1
     c                   callp     close(s)
     c                   callp     SetError(HTTP_BADCNN: 'select(2): ' +
     c                                %str(strerror(errno)) )
     c                   return    -1
     c                   endsl

     c                   if        CommTCP_FD_ISSET(s: wwfds) = *Off
     c                   callp     close(s)
     c                   callp     SetError(HTTP_CNNTIMO:'Timeout occurred '+
     c                             'while trying to connect to server!')
     c                   return    -1
     c                   endif
      /endif

     C*********************************************************
     C* Wait for connect to complete:
     C*   because these are non-blocking sockets, the API's
     C*   above will almost always complete before the
     C*   connection is finished.   This code waits for it:
     C*********************************************************
      /if defined(USE_POLL)
     c                   eval      pfd(1) = *ALLx'00'
     c                   eval      pfd(1).fd = s
     c                   eval      pfd(1).events = POLLOUT

     c                   eval      rc = poll( pfd: 1: peTimeout * 1000)

     c                   select
     c                   when      rc = 0
     c                   callp     close(s)
     c                   callp     SetError(HTTP_CNNTIMO:'Timeout occurred '+
     c                             'while trying to connect to server!')
     c                   return    -1

     c                   when      rc = -1
     c                   callp     close(s)
     c                   callp     SetError(HTTP_BADCNN: 'poll(1): ' +
     c                                %str(strerror(errno)) )
     c                   return    -1
     c                   endsl

     c                   if        %bitand( pfd(1).revents: POLLOUT ) = 0
     c                   callp     close(s)
     c                   callp     SetError(HTTP_CNNTIMO:'Timeout occurred '+
     c                             'while trying to connect to server!')
     c                   return    -1
     c                   endif
      /endif

     C*********************************************************
     C* Was connection successful?
     C*********************************************************
     c                   eval      wwSize = %size(wwConnErr)
     c                   callp     getsockopt( s
     c                                       : SOL_SOCKET
     c                                       : SO_ERROR
     c                                       : %addr(wwConnErr)
     c                                       : wwSize )
     c                   if        wwConnErr <> 0
     c                   callp     SetError(HTTP_BADCNN: 'connect(2): ' +
     c                                %str(strerror(wwConnErr)) )
     c                   callp     close(s)
     c                   return    -1
     c                   endif

     c                   return    s
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Read data from socket w/a timeout
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommTcp_Read...
     P                 B                   export
     D CommTcp_Read...
     D                 PI            10I 0
     D   peHandle                      *   value
     D   peBuffer                      *   value
     D   peSize                      10I 0 value
     D   peTimeout                   10P 3 value

     D wwLen           S             10I 0

     c                   eval      p_commTcp = pehandle

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
     P CommTcp_BlockRead...
     P                 B                   export
     D CommTcp_BlockRead...
     D                 PI            10I 0
     D   peHandle                      *   value
     D   peBuffer                      *   value
     D   peSize                      10I 0 value
     D   peTimeout                   10P 3 value

     D wwTimeout       S                   like(timeval)
     D wwLen           S             10I 0
     D wwFds           S                   like(fdset)
     D wwLeft          S             10I 0

     c                   eval      wwLeft = peSize

     c                   dow       wwLeft > 0

     c                   eval      wwLen = commTcp_Read( peHandle
     c                                                 : peBuffer
     c                                                 : wwLeft
     c                                                 : peTimeout )
     c                   callp     http_dmsg('got ' + %char(wwLen))
     c                   if        wwLen < 1
     c                   if        wwLeft = peSize
     c                   return    -1
     c                   else
     c                   return    peSize - wwLeft
     c                   endif
     c                   endif

     c                   eval      wwLeft = wwLeft - wwLen
     c                   eval      peBuffer = peBuffer + wwLen
     c                   enddo

     c                   return    peSize
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Write data to socket in a fixed-length block
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommTcp_BlockWrite...
     P                 B                   export
     D CommTcp_BlockWrite...
     D                 PI            10I 0
     D   peHandle                      *   value
     D   peBuffer                      *   value
     D   peSize                      10I 0 value
     D   peTimeout                   10P 3 value

     D wwLen           S             10I 0
     D wwSent          s             10I 0

      /if defined(USE_POLL)
     D pfd             ds                  likeds(pollfd_t) dim(1)
     D rc              s             10i 0
      /else
     D wwTimeout       S                   like(timeval)
     D wwFds           S                   like(fdset)
      /endif

     c                   eval      p_CommTcp = peHandle

     c                   dou       peSize = 0

     c                   eval      wwLen = send(fd: peBuffer: peSize: 0)

     c                   if        wwLen<1 and errno<>EAGAIN
     c                   callp     SetError(HTTP_BWSEND:'blockwrite: '+
     c                               'send: ' + %str(strerror(errno)) )
     c                   return    -1
     c                   endif

      /if defined(USE_POLL)
     c                   if        wwLen < 1

     c                   eval      pfd(1).fd = fd
     c                   eval      pfd(1).events = POLLOUT
     c                   eval      pfd(1).revents = 0

     c                   eval      rc = poll( pfd
     c                                      : %elem(pfd)
     c                                      : peTimeout * 1000 )
     c                   if        rc < 0
     c                   callp     SetError(HTTP_BWSELE:'blockwrite: '+
     c                               'poll: ' + %str(strerror(errno)) )
     c                   return    -1
     c                   endif

     c                   if        rc = 0
     c                   callp     SetError(HTTP_BWTIME:'blockwrite: '+
     c                               ' timeout!')
     c                   return    -1
     c                   endif

     c                   iter
     c                   endif
      /else
     c                   if        wwLen < 1

     c                   eval      p_timeval = %addr(wwTimeout)
     c                   eval      tv_sec = peTimeout
     c                   eval      tv_usec = (peTimeout-tv_sec)*1000000

     c                   callp     CommTCP_FD_ZERO(wwfds)
     c                   callp     CommTCP_FD_SET(fd: wwfds)

     c                   if        select(fd+1:*NULL:%addr(wwfds):*NULL:
     c                               %addr(wwTimeout) ) < 0
     c                   callp     SetError(HTTP_BWSELE:'blockwrite: '+
     c                               'select: ' + %str(strerror(errno)) )
     c                   return    -1
     c                   endif

     c                   if        CommTCP_FD_ISSET(fd: wwfds) = *Off
     c                   callp     SetError(HTTP_BWTIME:'blockwrite: '+
     c                               ' time-out!')
     c                   return    -1
     c                   endif

     c                   iter
     c                   endif
      /endif

     c                   callp     http_dwrite(peBuffer: wwLen)

     c                   eval      wwSent = wwSent + wwLen
     c                   eval      peSize = peSize - wwLen

     c                   if        peSize > 0
     c                   eval      peBuffer = peBuffer + wwLen
     c                   endif

     c                   enddo

     c                   return    wwSent
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Read data from socket as a CR/LF terminated line
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommTcp_LineRead...
     P                 B                   export
     D CommTcp_LineRead...
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

     c                   eval      p_commTcp = peHandle
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
     c                   eval      bufLen = bufLen - len
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
     P CommTcp_LineWrite...
     P                 B                   export
     D CommTcp_LineWrite...
     D                 PI            10I 0
     D   peHandle                      *   value
     D   peBuffer                      *   value
     D   peBufSize                   10I 0 value
     D   peTimeout                   10P 3 value

     D p_Buf           s               *
     D p_EOL           s               *
     D wwEOL           s              2A   based(p_EOL)
     D rc              s             10I 0

     c                   eval      p_Buf = xalloc(peBufSize + %size(wwEOL))
     c                   callp     memcpy(p_Buf: peBuffer: peBufSize)

     c                   eval      p_EOL = p_Buf + peBufSize
     c                   eval      wwEOL = x'0d0a'

     c                   eval      rc = CommTcp_BlockWrite( peHandle
     c                                                    : p_buf
     c                                                    : peBufSize
     c                                                      + %size(wwEOL)
     c                                                    : peTimeout )

     c                   callp     xdealloc(p_buf)
     c                   return    rc
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Disconnect session
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommTcp_Hangup...
     P                 B                   export
     D CommTcp_Hangup...
     D                 PI             1N
     D   peHandle                      *   value
     c                   eval      p_CommTcp = peHandle
     c                   if        close(fd) = 0
     c                   return    *ON
     c                   else
     c                   return    *OFF
     c                   endif
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Cleanup module
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommTcp_Cleanup...
     P                 B                   export
     D CommTcp_Cleanup...
     D                 PI             1N
     D   peHandle                      *   value
     c                   eval      p_CommTcp = peHandle
     c                   callp     xdealloc(bufBase)

     c                   callp(e)  xdealloc(peHandle)

     c                   if        %error
     c                   return    *OFF
     c                   else
     c                   return    *ON
     c                   endif
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Set a File Descriptor in a set ON...  for use w/Select()
      *
      *      peFD = descriptor to set on
      *      peFDSet = descriptor set
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommTCP_FD_SET...
     P                 B                   EXPORT
     D CommTCP_FD_SET...
     D                 PI
     D   peFD                        10I 0
     D   peFDSet                           like(fdset)
     D wkByteNo        S              5I 0
     D wkMask          S              1A
     D wkByte          S              1A
     C                   callp     CalcBitPos(peFD:wkByteNo:wkMask)
     c                   eval      wkByte = %subst(peFDSet:wkByteNo:1)
     c                   biton     wkMask        wkByte
     c                   eval      %subst(peFDSet:wkByteNo:1) = wkByte
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Determine if a file desriptor is on or off...
      *
      *      peFD = descriptor to set off
      *      peFDSet = descriptor set
      *
      *   Returns *ON if its on, or *OFF if its off.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommTCP_FD_ISSET...
     P                 B                   EXPORT
     D CommTCP_FD_ISSET...
     D                 PI             1N
     D   peFD                        10I 0
     D   peFDSet                           like(fdset)
     D wkByteNo        S              5I 0
     D wkMask          S              1A
     D wkByte          S              1A
     C                   callp     CalcBitPos(peFD:wkByteNo:wkMask)
     c                   eval      wkByte = %subst(peFDSet:wkByteNo:1)
     c                   testb     wkMask        wkByte                   88
     c                   return    *IN88
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Clear All descriptors in a set.  (also initializes at start)
      *
      *      peFDSet = descriptor set
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CommTCP_FD_ZERO...
     P                 B                   EXPORT
     D CommTCP_FD_ZERO...
     D                 PI
     D   peFDSet                           like(fdset)
     C                   eval      peFDSet = *ALLx'00'
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This is used by the CommTCP_FD_SET/CommTCP_FD_ISSET procs to
      *  determine which byte in the 28-char string to check,
      *  and a bitmask to check the individual bit...
      *
      *  peDescr = descriptor to check in the set.
      *  peByteNo = byte number (returned)
      *  peBitMask = bitmask to set on/off or test
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CalcBitPos      B
     D CalcBitPos      PI
     D    peDescr                    10I 0
     D    peByteNo                    5I 0
     D    peBitMask                   1A
     D dsMakeMask      DS
     D   dsZeroByte            1      1A
     D   dsMask                2      2A
     D   dsBitMult             1      2U 0 INZ(0)
     C     peDescr       div       32            wkGroup           5 0
     C                   mvr                     wkByteNo          2 0
     C                   div       8             wkByteNo          2 0
     C                   mvr                     wkBitNo           2 0
     C                   eval      wkByteNo = 4 - wkByteNo
     c                   eval      peByteNo = (wkGroup * 4) + wkByteNo
     c                   eval      dsBitMult = 2 ** wkBitNo
     c                   eval      dsZeroByte = x'00'
     c                   eval      peBitMask = dsMask
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * DNS_Info(): Display DNS Resolver information
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P DNS_Info        B
     D DNS_Info        PI

     D cvthc           PR                  EXTPROC('cvthc')
     D  output                        8A
     D  input                         4A
     D  output_len                   10I 0 value

     D opt             s              1a
     D hexopt          s              8a
     D res_init        PR                  extproc('res_init')
     D rc              s             10i 0
     D msg             s            256a
     D x               s             10i 0

      *************************************************
      * Initialize DNS resolver, if not already done
      *************************************************
     C                   callp     res_init

     c                   eval      opt = %subst(options:4:1)
     C                   testb     x'10'         opt                      99
     c                   if        *in99 = *OFF
     c                   callp     http_dmsg('DNS Resolver doesnt init, '
     c                                      + 'errno='
     c                                      + %trim(%editc(errno:'P')) )
     c                   return
     c                   endif

      *************************************************
      * Log a bunch of various DNS options
      *************************************************
     C                   callp     http_dmsg( 'DNS resolver retrans: '
     C                               + %trim(%editc(retrans:'P')) )

     C                   callp     http_dmsg( 'DNS resolver retry  : '
     C                               + %trim(%editc(retry:'P')) )

     C                   callp     cvthc(hexopt: options: %size(hexopt))
     C                   callp     http_dmsg( 'DNS resolver options: '
     C                               + 'x''' + hexopt + '''' )

     C                   callp     http_dmsg( 'DNS default domain: '
     C                               + %str(%addr(defdname)) )

      *************************************************
      *  List name servers referenced by resolver
      *************************************************
     c                   if        nscount = 0
     c                   eval      msg = 'WARNING: No name servers '
     c                                    + 'are configured for DNS '
     c                                    + 'resolution! You will not '
     c                                    + 'be able to contact '
     c                                    + 'Internet hosts! '
     c                                    + 'See http://www.scottklement'
     c                                    + '.com/httpapi/dns.html for '
     c                                    + 'more information.'
     c                   callp     http_dmsg(msg)
     c                   callp     http_diag(msg)
     c                   return
     c                   endif

     c                   do        nscount       x
     c                   eval      p_sockaddr = %addr(nsaddr(x))
     c                   callp     http_dmsg('DNS server found: '
     c                                      + %str(inet_ntoa(sin_addr)) )
     c                   enddo
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

     c                   eval      len = recv(fd: bufCurr: bufsize: 0)

      ************************************
      *  len = 0 means the socket is
      *  closed, no more data will come
      ************************************
     c                   if        len = 0
     c                   callp     SetError(HTTP_BRRECV:'CommTCP_read: '+
     c                               'Socket has been shut down.')
     c                   return    -1
     c                   endif

      ************************************
      *  If an error occurred
      *    - EWOULDBLOCK means to wait
      *         for more data
      *    - another error is an error
      ************************************
     c                   if        len < 0

     c                   if        errno <> EWOULDBLOCK
     c                   callp     SetError(HTTP_BRRECV:'CommTCP_read: '+
     c                               'recv: ' + %str(strerror(errno)))
     c                   return    -1
     c                   endif

     c                   eval      safetyNet = safetyNet + 1
     c                   if        safetyNet = 1000
     c                   callp     SetError(HTTP_BRRECV:'CommTCP_read: '+
     c                               ' safetyNet threshold exceeded' )
     c                   return    -1
     c                   endif

      /if defined(USE_POLL)
     c                   eval      pfd(1) = *ALLx'00'
     c                   eval      pfd(1).fd = fd
     c                   eval      pfd(1).events = POLLIN

     c                   eval      rc = poll( pfd: 1: peTimeout * 1000)

     c                   if        rc < 0
     c                   callp     SetError(HTTP_BRSELE:'CommTCP_read: '+
     c                               'poll: ' + %str(strerror(errno)) )
     c                   return    -1
     c                   endif

     c                   if        rc = 0
     c                   if        peTimeout >= 1
     c                   callp     SetError(HTTP_BRTIME:'CommTCP_read: '+
     c                               'timeout!')
     c                   else
     c                   callp     SetError(HTTP_BRTIME: 'CommTCP_read: '+
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
     c                   callp     SetError(HTTP_BRSELE:'CommTCP_read: '+
     c                               'select: ' + %str(strerror(errno)) )
     c                   return    -1
     c                   endif

     c                   if        CommTCP_FD_ISSET(fd: readSet) = *Off
     c                   if        peTimeout >= 1
     c                   callp     SetError(HTTP_BRTIME:'CommTCP_read: '+
     c                               'time-out!')
     c                   else
     c                   callp     SetError(HTTP_BRTIME: 'CommTCP_read: '+
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
