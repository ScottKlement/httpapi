     /*-                                                                            +
      * Copyright (c) 2001-2023 Scott C. Klement                                    +
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
      *  This member contains routines that are deprecated or no longer
      *  supported, and are only included to maintain backward compatibility
      *  with old releases of HTTPAPI
      */

      /copy VERSION

      /if defined(HAVE_SRCSTMT_NODEBUGIO)
     H OPTION(*NOSHOWCPY: *SRCSTMT: *NODEBUGIO)
      /endif
     H NOMAIN

      /define HTTP_ORIG_SOAPACTION
      /copy PRIVATE_H

     D HTTP_NOTSUPP    C                   CONST(61)

     D http_DEPRECATED_url_get...
     D                 PR            10I 0
     D  peURL                       256A   const
     D  peFileName                  256A   const
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass)
     D  peModTime                      Z   const options(*nopass)
     D  peContentType                64A   const options(*nopass)
     D  peSOAPAction                 64A   const options(*nopass)

     D http_DEPRECATED_url_post...
     D                 PR            10I 0
     D  peURL                       256A   const
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peFilename                  256A   const
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass)
     D  peContentType                64A   const options(*nopass)
     D  peSOAPAction                 64A   const options(*nopass)

     D http_DEPRECATED_url_get_raw...
     D                 PR            10I 0
     D  peURL                       256A   const
     D  peFD                         10I 0 value
     D  peProc                         *   value procptr
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass)
     D  peModTime                      Z   const options(*nopass)
     D  peContentType                64A   const options(*nopass)
     D  peSOAPAction                 64A   const options(*nopass)

     D http_DEPRECATED_url_post_raw...
     D                 PR            10I 0
     D  peURL                       256A   const
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peFD                         10I 0 value
     D  peProc                         *   value procptr
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass)
     D  peContentType                64A   const options(*nopass)
     D  peSOAPAction                 64A   const options(*nopass)

     D http_getraw...
     D                 PR            10I 0
     D  peSock                       10I 0 value
     D  peProcedure                    *   value procptr
     D  peFile                       10I 0 value
     D  peTimeout                    10I 0 value
     D  peAbsPath                   256A   const
     D  peHost                      256A   const
     D  peModTime                      Z   options(*omit)
     D  peUserAgent                  64A   options(*omit)
     D  peContentType                64A   options(*omit)
     D  peSOAPAction                 64A   options(*omit)

     D http_postraw...
     D                 PR            10I 0
     D  peSock                       10I 0 value
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peProcedure                    *   value procptr
     D  peFile                       10I 0 value
     D  peTimeout                    10I 0 value
     D  peAbsPath                   256A   const
     D  peHost                      256A   const
     D  peUserAgent                  64A   options(*omit)
     D  peContentType                64A   options(*omit)
     D  peSOAPAction                 64A   options(*omit)

     D https_getraw...
     D                 PR            10I 0
     D  peSock                         *   value
     D  peProcedure                    *   value procptr
     D  peFile                       10I 0 value
     D  peTimeout                    10I 0 value
     D  peAbsPath                   256A   const
     D  peHost                      256A   const
     D  peModTime                      Z   options(*omit)
     D  peUserAgent                  64A   options(*omit)
     D  peContentType                64A   options(*omit)
     D  peSOAPAction                 64A   options(*omit)

     D https_postraw...
     D                 PR            10I 0
     D  peSock                         *   value
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peProcedure                    *   value procptr
     D  peFile                       10I 0 value
     D  peTimeout                    10I 0 value
     D  peAbsPath                   256A   const
     D  peHost                      256A   const
     D  peUserAgent                  64A   options(*omit)
     D  peContentType                64A   options(*omit)
     D  peSOAPAction                 64A   options(*omit)

     D http_connect    PR            10I 0
     D   peSockAddr                    *   value
     D   peTimeout                   10I 0 value

     D http_url_encoder_addvar...
     D                 PR             1N
     D    peEncoder                    *   value
     D    peVariable                 50A   varying value
     D    peData                       *   value
     D    peDataSize                 10I 0 value

     D http_url_encoder_addvar_s...
     D                 PR             1N
     D    peEncoder                    *   value
     D    peVariable                 50A   varying value
     D    peValue                   256A   varying value

     D HTTP_SetTables  PR            10I 0
     D   peASCII                     10A   const
     D   peEBCDIC                    10A   const

     D http_build_sockaddr...
     D                 PR            10I 0
     D   peHost                     256A   const
     D   peService                   32A   const
     D   peForcePort                 10I 0 value
     D   peSockAddr                    *

     D http_ParseURL   PR            10I 0
     D  peURL                       256A   const
     D  peService                    32A
     D  peUserName                   32A
     D  pePassword                   32A
     D  peHost                      256A
     D  pePort                       10I 0
     D  pePath                      256A


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * DEPRECATED:  All new code should call http_url_get_raw().
      *              No features should be added to this procedure.
      *              This is for backward-compatibility only.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_DEPRECATED_url_get...
     P                 B                   export
     D http_DEPRECATED_url_get...
     D                 PI            10I 0
     D  peURL                       256A   const
     D  peFileName                  256A   const
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass)
     D  peModTime                      Z   const options(*nopass)
     D  peContentType                64A   const options(*nopass)
     D  peSOAPAction                 64A   const options(*nopass)

     D http_url_get    PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  peFilename                32767A   varying const options(*varsize)
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)

     c                   select
     c                   when      %parms = 2
     c                   return    http_url_get( %trimr(peURL)
     c                                         : %trimr(peFileName)
     c                                         )
     c                   when      %parms = 3
     c                   return    http_url_get( %trimr(peURL)
     c                                         : %trimr(peFileName)
     c                                         : peTimeout
     c                                         )
     c                   when      %parms = 4
     c                   return    http_url_get( %trimr(peURL)
     c                                         : %trimr(peFileName)
     c                                         : peTimeout
     c                                         : peUserAgent
     c                                         )
     c                   when      %parms = 5
     c                   return    http_url_get( %trimr(peURL)
     c                                         : %trimr(peFileName)
     c                                         : peTimeout
     c                                         : peUserAgent
     c                                         : peModTime
     c                                         )
     c                   when      %parms = 6
     c                   return    http_url_get( %trimr(peURL)
     c                                         : %trimr(peFileName)
     c                                         : peTimeout
     c                                         : peUserAgent
     c                                         : peModTime
     c                                         : peContentType
     c                                         )
     c                   when      %parms = 7
     c                   return    http_url_get( %trimr(peURL)
     c                                         : %trimr(peFileName)
     c                                         : peTimeout
     c                                         : peUserAgent
     c                                         : peModTime
     c                                         : peContentType
     c                                         : peSoapAction
     c                                         )
     c                   endsl
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * DEPRECATED:  All new code should call http_url_get_raw().
      *              No features should be added to this procedure.
      *              This is for backward-compatibility only.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_DEPRECATED_url_post...
     P                 B                   export
     D http_DEPRECATED_url_post...
     D                 PI            10I 0
     D  peURL                       256A   const
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peFilename                  256A   const
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass)
     D  peContentType                64A   const options(*nopass)
     D  peSOAPAction                 64A   const options(*nopass)

     D http_url_post   PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peFilename                32767A   varying const options(*varsize)
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)

     c                   select
     c                   when      %parms = 4
     c                   return    http_url_post( %trimr(peURL)
     c                                          : pePostData
     c                                          : pePostDataLen
     c                                          : %trimr(peFileName)
     c                                          )
     c                   when      %parms = 5
     c                   return    http_url_post( %trimr(peURL)
     c                                          : pePostData
     c                                          : pePostDataLen
     c                                          : %trimr(peFileName)
     c                                          : peTimeout
     c                                          )
     c                   when      %parms = 6
     c                   return    http_url_post( %trimr(peURL)
     c                                          : pePostData
     c                                          : pePostDataLen
     c                                          : %trimr(peFileName)
     c                                          : peTimeout
     c                                          : peUserAgent
     c                                          )
     c                   when      %parms = 7
     c                   return    http_url_post( %trimr(peURL)
     c                                          : pePostData
     c                                          : pePostDataLen
     c                                          : %trimr(peFileName)
     c                                          : peTimeout
     c                                          : peUserAgent
     c                                          : peContentType
     c                                          )
     c                   when      %parms = 8
     c                   return    http_url_post( %trimr(peURL)
     c                                          : pePostData
     c                                          : pePostDataLen
     c                                          : %trimr(peFileName)
     c                                          : peTimeout
     c                                          : peUserAgent
     c                                          : peContentType
     c                                          : peSoapAction
     c                                          )
     c                   endsl
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * DEPRECATED:  All new code should call http_url_get_raw().
      *              No features should be added to this procedure.
      *              This is for backward-compatibility only.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_DEPRECATED_url_get_raw...
     P                 B                   export
     D http_DEPRECATED_url_get_raw...
     D                 PI            10I 0
     D  peURL                       256A   const
     D  peFD                         10I 0 value
     D  peProc                         *   value procptr
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass)
     D  peModTime                      Z   const options(*nopass)
     D  peContentType                64A   const options(*nopass)
     D  peSOAPAction                 64A   const options(*nopass)
     D http_url_get_raw...
     D                 PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  peFD                         10I 0 value
     D  peProc                         *   value procptr
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)
     c                   select
     c                   when      %parms = 3
     c                   return    http_url_get_raw( %trimr(peURL)
     c                                             : peFD
     c                                             : peProc
     c                                             )
     c                   when      %parms = 4
     c                   return    http_url_get_raw( %trimr(peURL)
     c                                             : peFD
     c                                             : peProc
     c                                             : peTimeout
     c                                             )
     c                   when      %parms = 5
     c                   return    http_url_get_raw( %trimr(peURL)
     c                                             : peFD
     c                                             : peProc
     c                                             : peTimeout
     c                                             : peUserAgent
     c                                             )
     c                   when      %parms = 6
     c                   return    http_url_get_raw( %trimr(peURL)
     c                                             : peFD
     c                                             : peProc
     c                                             : peTimeout
     c                                             : peUserAgent
     c                                             : peModTime
     c                                             )
     c                   when      %parms = 7
     c                   return    http_url_get_raw( %trimr(peURL)
     c                                             : peFD
     c                                             : peProc
     c                                             : peTimeout
     c                                             : peUserAgent
     c                                             : peModTime
     c                                             : peContentType
     c                                             )
     c                   when      %parms = 8
     c                   return    http_url_get_raw( %trimr(peURL)
     c                                             : peFD
     c                                             : peProc
     c                                             : peTimeout
     c                                             : peUserAgent
     c                                             : peModTime
     c                                             : peContentType
     c                                             : peSOAPAction
     c                                             )
     c                   endsl
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * DEPRECATED:  All new code should call http_url_get_raw().
      *              No features should be added to this procedure.
      *              This is for backward-compatibility only.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_DEPRECATED_url_post_raw...
     P                 B                   export
     D http_DEPRECATED_url_post_raw...
     D                 PI            10I 0
     D  peURL                       256A   const
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peFD                         10I 0 value
     D  peProc                         *   value procptr
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass)
     D  peContentType                64A   const options(*nopass)
     D  peSOAPAction                 64A   const options(*nopass)
     D http_url_post_raw...
     D                 PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peFD                         10I 0 value
     D  peProc                         *   value procptr
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)
     c                   select
     c                   when      %parms = 5
     c                   return    http_url_post_raw( %trimr(peURL)
     c                                              : pePostData
     c                                              : pePostDataLen
     c                                              : peFD
     c                                              : peProc
     c                                              )
     c                   when      %parms = 6
     c                   return    http_url_post_raw( %trimr(peURL)
     c                                              : pePostData
     c                                              : pePostDataLen
     c                                              : peFD
     c                                              : peProc
     c                                              : peTimeout
     c                                              )
     c                   when      %parms = 7
     c                   return    http_url_post_raw( %trimr(peURL)
     c                                              : pePostData
     c                                              : pePostDataLen
     c                                              : peFD
     c                                              : peProc
     c                                              : peTimeout
     c                                              : peUserAgent
     c                                              )
     c                   when      %parms = 8
     c                   return    http_url_post_raw( %trimr(peURL)
     c                                              : pePostData
     c                                              : pePostDataLen
     c                                              : peFD
     c                                              : peProc
     c                                              : peTimeout
     c                                              : peUserAgent
     c                                              : peContentType
     c                                              )
     c                   when      %parms = 9
     c                   return    http_url_post_raw( %trimr(peURL)
     c                                              : pePostData
     c                                              : pePostDataLen
     c                                              : peFD
     c                                              : peProc
     c                                              : peTimeout
     c                                              : peUserAgent
     c                                              : peContentType
     c                                              : peSoapAction
     c                                              )
     c                   endsl
     P                 E




      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_ParseURL(): Parse URL into it's component parts
      *
      *  Breaks a uniform resource locator (URL) into it's component
      *  pieces for use with the http: or https: protocols.  (would also
      *  work for FTP with minor tweaks)
      *
      *  peURL = URL that needs to be parsed.
      *  peService = service name from URL (i.e. http or https)
      *  peUserName = user name given, or *blanks
      *  pePassword = password given, or *blanks
      *  peHost = hostname given in URL. (could be domain name or IP)
      *  pePort = port number to connect to, if specified, otherwise 0.
      *  pePath = remaining path/request for server.
      *
      *  returns -1 upon failure, or 0 upon success
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_ParseURL   B                   export
     D http_ParseURL   PI            10I 0
     D  peURL                       256A   const
     D  peService                    32A
     D  peUserName                   32A
     D  pePassword                   32A
     D  peHost                      256A
     D  pePort                       10I 0
     D  pePath                      256A

     D wwHost          s           1024A   varying
     D wwPath          s          32767A   varying
     D rc              s             10I 0

     d http_long_ParseURL...
     D                 PR            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  peService                    32A
     D  peUserName                   32A
     D  pePassword                   32A
     D  peHost                      256A
     D  pePort                       10I 0
     D  pePath                    32767A   varying

     c                   eval      rc = http_long_ParseURL( %trimr(peURL)
     c                                                    : peService
     c                                                    : peUserName
     c                                                    : pePassword
     c                                                    : peHost
     c                                                    : pePort
     c                                                    : wwPath )

     c                   eval       pePath = wwPath

     c                   return     rc
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_build_sockaddr():  Build a socket address structure for a host
      *
      *        peHost = hostname to build sockaddr_in for
      *     peService = service name (or port) to build sockaddr_in for
      *   peForcePort = numeric port to force entry to, overrides peService
      *    peSockAddr = pointer to a location to place a sockaddr_in into.
      *
      *   returns -1 upon failure, 0 upon success
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_build_sockaddr...
     P                 B                   export
     D http_build_sockaddr...
     D                 PI            10I 0
     D   peHost                     256A   const
     D   peService                   32A   const
     D   peForcePort                 10I 0 value
     D   peSockAddr                    *

     c                   callp     SetError(HTTP_NOTSUPP
     c                                     : 'This function is no longer '
     c                                     + 'supported!')

     c                   return    -1
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_connect():  connect to an HTTP server
      *
      *    peSockAddr = ptr to socket address structure for server
      *           (can be obtained by called http_build_sockaddr)
      *    peTimeout  = number of seconds before time-out when connecting
      *
      *  Returns -1 upon failure, or the socket descriptor of the
      *        connection upon success.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_connect    B                   export
     D http_connect    PI            10I 0
     D   peSockAddr                    *   value
     D   peTimeout                   10I 0 value

     c                   callp     SetError(HTTP_NOTSUPP
     c                                     : 'This function is no longer '
     c                                     + 'supported!')

     c                   return    -1
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_getraw():  a blast from the past.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_getraw...
     P                 B                   export
     D http_getraw...
     D                 PI            10I 0
     D  peSock                       10I 0 value
     D  peProcedure                    *   value procptr
     D  peFile                       10I 0 value
     D  peTimeout                    10I 0 value
     D  peAbsPath                   256A   const
     D  peHost                      256A   const
     D  peModTime                      Z   options(*omit)
     D  peUserAgent                  64A   options(*omit)
     D  peContentType                64A   options(*omit)
     D  peSOAPAction                 64A   options(*omit)
     c                   callp     SetError(HTTP_NOTSUPP
     c                                     : 'This function is no longer '
     c                                     + 'supported!')
     c                   return    -1
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_postraw():  I think not.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_postraw...
     P                 B                   export
     d http_postraw...
     D                 PI            10I 0
     D  peSock                       10I 0 value
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peProcedure                    *   value procptr
     D  peFile                       10I 0 value
     D  peTimeout                    10I 0 value
     D  peAbsPath                   256A   const
     D  peHost                      256A   const
     D  peUserAgent                  64A   options(*omit)
     D  peContentType                64A   options(*omit)
     D  peSOAPAction                 64A   options(*omit)
     c                   callp     SetError(HTTP_NOTSUPP
     c                                     : 'This function is no longer '
     c                                     + 'supported!')
     c                   return    -1
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  https_getraw():  Receive an http document
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P https_getraw...
     P                 B                   export
     D https_getraw...
     D                 PI            10I 0
     D  peSock                         *   value
     D  peProcedure                    *   value procptr
     D  peFile                       10I 0 value
     D  peTimeout                    10I 0 value
     D  peAbsPath                   256A   const
     D  peHost                      256A   const
     D  peModTime                      Z   options(*omit)
     D  peUserAgent                  64A   options(*omit)
     D  peContentType                64A   options(*omit)
     D  peSOAPAction                 64A   options(*omit)
     c                   callp     SetError(HTTP_NOTSUPP
     c                                     : 'This function is no longer '
     c                                     + 'supported!')
     c                   return    -1
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  https_postraw:  Post data to a CGI script or server function
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P https_postraw...
     P                 B                   export
     D https_postraw...
     D                 PI            10I 0
     D  peSock                         *   value
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peProcedure                    *   value procptr
     D  peFile                       10I 0 value
     D  peTimeout                    10I 0 value
     D  peAbsPath                   256A   const
     D  peHost                      256A   const
     D  peUserAgent                  64A   options(*omit)
     D  peContentType                64A   options(*omit)
     D  peSOAPAction                 64A   options(*omit)
     c                   callp     SetError(HTTP_NOTSUPP
     c                                     : 'This function is no longer '
     c                                     + 'supported!')
     c                   return    -1
     P                 E




      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_url_encoder_addvar():  Add a variable to what's stored
      *          a URL encoder.
      *
      *    peEncoder = pointer to encoder created by the
      *                  http_url_encoder_new() routine
      *   peVariable = variable name to add
      *       peData = pointer to data to store in variable
      *   peDataSize = size of data to store in variable
      *
      * Returns *ON if successful, *OFF otherwise.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_url_encoder_addvar...
     P                 B                   export
     D http_url_encoder_addvar...
     D                 PI             1N
     D    peEncoder                    *   value
     D    peVariable                 50A   varying value
     D    peData                       *   value
     D    peDataSize                 10I 0 value
     D http_url_encoder_addvar_long...
     D                 PR             1N
     D    peEncoder                    *   value
     D    peVariable                   *   value options(*string)
     D    peData                       *   value options(*string)
     D    peDataSize                 10i 0 value
     C                   return    http_url_encoder_addvar_long(
     C                                           peEncoder
     C                                         : peVariable
     C                                         : peData
     C                                         : peDataSize)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_url_encoder_addvar_s():  Simplified (but limited)
      *       interface to http_url_encoder_addvar().
      *
      *    peEncoder = (input) HTTP_url_encoder object
      *   peVariable = (input) variable name to set
      *      peValue = (input) value to set variable to
      *
      * Returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_url_encoder_addvar_s...
     P                 B                   export
     D http_url_encoder_addvar_s...
     D                 PI             1N
     D    peEncoder                    *   value
     D    peVariable                 50A   varying value
     D    peValue                   256A   varying value
     c                   return    http_url_encoder_addvar( peEncoder
     c                                         : peVariable
     c                                         : %addr(peValue)+VARPREF
     c                                         : %len(peValue))
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * OBSOLETE:  There is no good reason to use tables instead
      *            of CCSIDs anymore. HTTPAPI will only use CCSID
      *            support going forward.
      *
      * HTTP_SetTables():  Set the translation tables used for
      *                    ASCII/EBCDIC translation
      *
      *     peASCII  = (input) Table for converting to ASCII
      *     peEBCDIC = (input) Table for converting to EBCDIC
      *
      * Returns 0 if successful, -1 otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P HTTP_SetTables  B                   export
     D HTTP_SetTables  PI            10I 0
     D   peASCII                     10A   const
     D   peEBCDIC                    10A   const
     D HTTP_MUTABLE    C                   CONST(69)
     c                   callp     SetError(HTTP_MUTABLE: 'HTTPAPI was '
     c                                     + 'compiled to use CCSIDs '
     c                                     + 'rather than Tables')
     c                   return    -1
     P                 E
