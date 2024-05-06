     /*-                                                                            +
      * Copyright (c) 2012-2024 Thomas Raddatz                                      +
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
      *=====================================================================*
      *  NTLM: NTLM Authentication                                          *
      *=====================================================================*
      *  Author  :  Thomas Raddatz                                          *
      *  Date    :  28.02.2012                                              *
      *  E-mail  :  thomas.raddatz@Tools400.de                              *
      *  Homepage:  www.tools400.de                                         *
      *=====================================================================*
      *  History:                                                           *
      *                                                                     *
      *  Date        Name          Description                              *
      *  ----------  ------------  ---------------------------------------  *
      *  09.08.2012  Th.Raddatz    Fixed bug in performTranslation().       *
      *                            Translation fom 424 (Hebrew) to Unicode  *
      *                            failed.                                  *
      *                                                                     *
      *  09.08.2012  Th.Raddatz    Added procedure AuthPlugin_getRealm().   *
      *                                                                     *
      *  09.08.2012  Th.Raddatz    Changed the way the authentication       *
      *                            process is initialized. The dependancy   *
      *                            to the presence of a 'negotiate' header  *
      *                            has been removed.                        *
      *                                                                     *
      *  02.02.2016  Th.Raddatz    Fixed "index out of range" error in      *
      *                            procedure getToken().                    *
      *                            Removed duplicate procedure names from   *
      *                            the procedure interface and end procedure*
      *                            statements.                              *
      *                                                                     *
      *=====================================================================*
      /if defined(HAVE_SRCSTMT_NODEBUGIO)
     H OPTION(*NOSHOWCPY: *SRCSTMT: *NODEBUGIO)
      /endif
     H NOMAIN
      /COPY NTLM_C
      *=====================================================================*
      *
      * ------------------------------------
      *  Type Definitions
      * ------------------------------------
      *
     D type1_t         DS                  qualified               based(pDummy)
     D  flags                        10U 0
     D  domain                             like(ntlm_domain_t       )
     D  workstation                        like(ntlm_workstation_t  )
      *
     D type3_t         DS                  qualified               based(pDummy)
     D  flags                        10U 0
     D  domain                             like(ntlm_domain_t       )
     D  user                               like(ntlm_user_t         )
     D  workstation                        like(ntlm_workstation_t  )
     D  lmResponse                         like(ntlm_lmResponse_t   )
     D  ntResponse                         like(ntlm_ntlmResponse_t )
     D  sessionKey                         like(ntlm_sessionKey_t   )
      *
      *  Transcoder handle
     D transcoder_t...
     D                 DS                  qualified               based(pDummy)
     D  fromCcsid                    10U 0
     D  toCcsid                      10U 0
     D  hIconv                             likeds(iconv_t )
      *
      * ------------------------------------
      *  Exported prototypes
      * ------------------------------------
      /COPY NTLM_H
      /COPY NTLM_P
      *
      * ------------------------------------
      *  Imported prototypes
      * ------------------------------------
      /COPY HTTPAPI_H
      /COPY PRIVATE_H
      *
      * ------------------------------------
      *  Internal prototypes
      * ------------------------------------
      *
      *  Resets the NTLM authentication status.
     D resetAuthentication...
     D                 PR
     D                                     extproc('resetAuthentication')
     D  i_resetAll                     N   const
      *
      *  Appends a given buffer to the NULL device.
     D nullWrite...
     D                 PR            10I 0
     D                                     extproc('nullWrite')
     D  i_fd                         10I 0 value
     D  i_data                         *   value
     D  i_length                     10I 0 value
      *
      *  Calculate the 'ResponseKeyLM' as described in document
      *  'NT LAN Manager (NTLM) Authentication Protocol Specification'.
     D LMOWFv1...
     D                 PR            16A
     D                                     extproc('LMOWFv1')
     D  i_password                         const  like(ntlm_password_t )
     D                                            options(*varsize)
      *
      *  Encrypts an 8-byte data item D with the 16-byte key K using the
      *  Data Encryption Standard Long (DESL) algorithm.
      *  The result is 24 bytes in length.
     D desl...
     D                 PR            24A
     D                                     extproc('desl')
     D  i_key                        16A   const
     D  i_data                        8A   const
      *
      *  Creates a byte array of length N. Each byte
      *  in the array is initialized to the value zero.
     D z...
     D                 PR           128A          varying
     D                                     extproc('z')
     D  i_n                          10I 0 const
      *
      *  Parses a given URL.
     D parseUrl...
     D                 PR
     D                                     extproc('parseUrl')
     D   i_URL                    32767A   const  varying options(*varsize)
     D   o_service                   32A          varying
     D   o_host                     256A          varying
      *
      *  Returns an EBCDIC to ASCII transcoder.
     D getTranscoderToAscii...
     D                 PR                         like(hTranscoder_t )
     D                                     extproc('getTranscoderToAscii')
      *
      *  Returns an EBCDIC to UNICODE transcoder.
     D getTranscoderToUnicode...
     D                 PR                         like(hTranscoder_t )
     D                                     extproc('getTranscoderToUnicode')
      *
      *  Converts a given EBCDIC string to UNICODE or ASCII.
     D transcode...
     D                 PR          4096A          varying
     D                                     extproc('transcode')
     D  i_ebcdic                   2048A   const  varying
     D  i_isUnicode                    N   const
      *
      *  Returns the domain name of the i5 computer.
     D getDefaultDomain...
     D                 PR                         like(ntlm_domain_t )
     D                                     extproc('getDefaultDomain')
      *
      *  Returns the default workstation name.
     D getDefaultWorkstation...
     D                 PR                         like(ntlm_workstation_t )
     D                                     extproc('getDefaultWorkstation')
      *
      *  Returns the default flags for a all message types.
     D getDefaultFlags...
     D                 PR            10U 0
     D                                     extproc('getDefaultFlags')
      *
      *  Returns the default flags for a Type-1 message.
     D getDefaultFlagsType1...
     D                 PR            10U 0
     D                                     extproc('getDefaultFlagsType1')
      *
      *  Returns the default flags for a Type-3 message.
     D getDefaultFlagsType3...
     D                 PR            10U 0
     D                                     extproc('getDefaultFlagsType3')
     D  i_NtLmChallenge...
     D                                            likeds(NtLmChallenge_t)
     D                                            options(*varsize: *nopass)
      *
      *  Returns cTrue if the specified message matches a given type.
     D isMessageTypeOf...
     D                 PR              N
     D                                     extproc('isMessageTypeOf')
     D  i_message                          const  like(ntlm_message_t    )
     D                                            options(*varsize)
     D  i_type                             const  like(NtlmMessage_t.type)
      *
      *  Returns the specified target information block of a given
      *  Type-2 message.
     D getTargetInfo...
     D                 PR                         like(ntlm_targetName_t)
     D                                     extproc('getTargetInfo')
     D  i_NtLmChallenge...
     D                                            likeds(NtLmChallenge_t)
     D  i_type                        5I 0 const
      *
      *  Return the NTLM message signature.
     D NTLMSSP_SIGNATURE...
     D                 PR                         like(NtLmMessage_t.signature)
     D                                     extproc('NTLMSSP_SIGNATURE')
      *
      *  Serializes a type 1 message to a byte array.
     D Type1_toByteArray...
     D                 PR                         like(ntlm_message_t )
     D                                     extproc('Type1_toByteArray')
     D  i_type1                                   likeds(type1_t )
      *
      *  Serializes a type 3 message to a byte array.
     D Type3_toByteArray...
     D                 PR                         like(ntlm_message_t )
     D                                     extproc('Type3_toByteArray')
     D  i_type3                                   likeds(type3_t )
      *
      *  Write a security bufer.
     D writeSecurityBuffer...
     D                 PR                         likeds(ntlm_securityBuffer_t)
     D                                     extproc('writeSecurityBuffer')
     D  io_message                                like(ntlm_message_t )
     D                                            options(*varsize)
     D  io_offset                    10I 0
     D  i_data                     2048A   const  varying options(*varsize)
      *
      *  Returns the current time in milliseconds.
     D getCurrentTimeMillis...
     D                 PR            20U 0
     D                                     extproc('getCurrentTimeMillis')
      *
      *  base64_encode:  Encode binary data using Base64 encoding
     D NTLM_Base64_encode...
     D                 PR            10U 0 extproc('NTLM_Base64_encode')
     D   Input                         *   value
     D   InputLen                    10U 0 value
     D   Output                        *   value
     D   OutputSize                  10U 0 value
      *
      *  base64_decode: Decode base64 encoded data back to binary
     D NTLM_Base64_decode...
     D                 PR            10U 0 extproc('NTLM_Base64_decode')
     D   Input                         *   value
     D   InputLen                    10U 0 value
     D   Output                        *   value
     D   OutputSize                  10U 0 value
      *
     D invalidChar     PR                  extproc('invalidChar')
     D   CharPos                     10i 0 value
     D   Char                         3u 0 value
      *
      *  Initializes character translation.
     D Transcoder_new...
     D                 PR                         like(hTranscoder_t )
     D                                     extproc('Transcoder_new')
     D  i_toCcsid                    10U 0 const
     D  i_fromCcsid                  10U 0 const
      *
      *  Translate a given varying string.
     D Transcoder_xlateString...
     D                 PR         32767A   opdesc varying
     D                                     extproc('Transcoder_xlateString')
     D  i_hTranscoder                      const  like(hTranscoder_t )
     D  i_string                  32767A   const  varying options(*varsize)
      *
      *  Frees a given transcoder.
     D Transcoder_delete...
     D                 PR
     D                                     extproc('Transcoder_delete')
     D  io_hTranscoder...
     D                                            like(hTranscoder_t )
      *
      *  Returns a Transcoder NULL-handle.
     D Transcoder_null...
     D                 PR                         like(hTranscoder_t )
     D                                     extproc('Transcoder_null')
      *
      *  Returns cTrue if a given Transcoder handle is NULL.
     D Transcoder_isNull...
     D                 PR              N
     D                                     extproc('Transcoder_isNull')
     D  i_hTranscoder                      const  like(hTranscoder_t )
      *
      *  Performs charcater translation.
     D performTranslation...
     D                 PR            10U 0
     D                                     extproc('performTranslation')
     D  i_hTranscoder                      const  like(hTranscoder_t )
     D  i_pInBuf                       *   value
     D  i_length                     10I 0 const
     D  o_pTo                          *
     D  i_maxSize                    10I 0 const
      *
      *  Sets the C runtime error number to ZERO (no error).
     D c_clearErrno...
     D                 PR
     D                                     extproc('c_clearErrno')
      *
      *  Sets the C runtime error number to a given error code.
     D c_errno...
     D                 PR            10I 0
     D                                     extproc('c_errno')
     D  i_errno                      10I 0 const  options(*nopass)
      *
      *  Returns the message text of a C runtime error number.
     D c_strerror...
     D                 PR           128A          varying
     D                                     extproc('c_strerror')
     D  i_errno                      10I 0 const
      *
      *  Kills utility with an ESCAPE message.
     D kill...
     D                 PR
     D                                     extproc('kill')
     D  i_text                      128A   const  varying
      *
      *  Get String Information (CEEGSI) API
     D CEEGSI...
     D                 PR
     D                                            extproc('CEEGSI')
     D  i_posn                       10I 0 const
     D  o_datatype                   10I 0
     D  o_curlen                     10I 0
     D  o_maxlen                     10I 0
     D  o_fb                         12A          options(*omit   )
      *
      *  Reference fields for CEEGSI API
     D strInf_t        DS                  based(pDummy)   qualified
     D  datatype                     10I 0
     D  curlen                       10I 0
     D  maxlen                       10I 0
      *
      *  erno--Set Pointer to Runtime Error Code
     D errno           PR              *                     extproc('__errno')
      *
      *  strerror -- Set Pointer to Runtime Error Message
     D strerror        PR              *                     extproc('strerror')
     D  errno                        10I 0 value
      *
      *  QtqIconvOpen()--Code Conversion Allocation API
     D QtqIconv_open...
     D                 PR                  extproc('QtqIconvOpen')
     D                                     likeds(iconv_t )
     D  i_toCode                           const  likeds(QtqCode_t)
     D  i_fromCode                         const  likeds(QtqCode_t)
      *
     D iconv_t         DS                  qualified   based(pDummy)   align
     D  return_value                 10I 0
     D  cd                           10I 0 dim(12)
      *
     D QtqCode_t...
     D                 DS                  qualified   based(pDummy)
     D  ccsid                        10I 0
     D  conversionA                  10I 0
     D  substitutionA                10I 0
     D  shiftStateA                  10I 0
     D  inpLenOpt                    10I 0
     D  errOptMxdDta                 10I 0
     D  reserved                     12A
      *
      *  iconv()--Code Conversion API
     D iconv...
     D                 PR            10U 0        extproc('iconv')
     D  i_cd                               value likeds(iconv_t  )
     D  i_pInBuf                       *
     D  i_inBytLeft                  10U 0
     D  i_pOutBuf                      *
     D  i_outBytLeft                 10U 0
      *
     D ICONV_ERROR     C                   const(4294967295)
     D E2BIG_C         C                   const(3491)                          Argument list
      *
      *  iconv_close()--Code Conversion Deallocation API
     D iconv_close...
     D                 PR            10I 0        extproc('iconv_close')
     D  i_cd                               value likeds(iconv_t  )
      *
      *  memcpy -- Copy Bytes
      *     The behavior is undefined if copying takes place
      *     between objects that overlap.
      *     The memcpy() function returns a pointer to dest.
     D memcpy2         PR              *          extproc('memcpy')
     D  i_pDest                        *   value
     D  i_pSrc                         *   value
     D  i_count                      10U 0 value
      *
      *  rand -- Generate Random Number                x = rand()
     D rand            PR            10I 0        extproc('rand')
      *
     D RAND_MAX        C                   const(32767)
      *
      *  srand -- Set Seed for rand Function   e.g.:   srand(getSeed(*null))
     D srand           PR                         extproc('srand')
     D  i_seed                       10U 0 value
      *
      *  time -- Determine Current Time
      *     The time() function returns the current calendar time.
      *     The return value is also stored in the location that
      *     is given by timeptr.
     D time...
     D                 PR            10i 0 extproc('time')
     D  timeptr                        *   value
      *
      *  AND String (ANDSTR)
      *     MI function that Returns the bit-wise ANDing
      *     of the arguments.
     D ANDSTR...
     D                 PR                  extproc('_ANDSTR')
     D  i_pReceiver                    *   value
     D  i_pFirstSrc                    *   value
     D  i_pSecondSrc                   *   value
     D  i_length                     10U 0 value
      *
      *  OR String (ORSTR)
      *     MI function that Returns the bit-wise ORing
      *     of the arguments.
     D ORSTR...
     D                 PR                  extproc('_ORSTR')
     D  i_pReceiver                    *   value
     D  i_pFirstSrc                    *   value
     D  i_pSecondSrc                   *   value
     D  i_length                     10U 0 value
      *
      *  Retrieve Network Attributes (QWCRNETA) API
     D QWCRNETA...
     D                 PR                  extpgm('QWCRNETA')
     D  o_rcvVar                  32767A          options(*varsize)
     D  i_lenRcv                     10I 0 const
     D  i_numAttr                    10I 0 const
     D  i_attrNames                  10A   const  dim(50) options(*varsize)
     D  io_errorCode              32767A          options(*varsize)
      *
     D QWCRNETA_returned...
     D                 DS                  qualified               based(pDummy)
     D  numE                         10I 0
     D  offsAttr                     10I 0
      *  Network attribute information table   CHAR(*)
      *
     D QWCRNETA_attr...
     D                 DS                  qualified               based(pDummy)
     D  name                         10A
     D  type                          1A
     D  status                        1A
     D  length                       10I 0
     D  data_char                   256A
     D  data_bin                     10I 0 overlay(data_char)
      *
     D QWCRNETA_STATUS_OK...
     D                 C                       ' '
     D QWCRNETA_STATUS_LOCKED...
     D                 C                       'L'
      *
     D QWCRNETA_DATA_NONE...
     D                 C                       ' '
     D QWCRNETA_DATA_CHAR...
     D                 C                       'C'
     D QWCRNETA_DATA_BIN...
     D                 C                       'B'
      *
      *  Convert Case (QLGCNVCS, QlgConvertCase) API
     D QlgConvertCase...
     D                 PR                  extproc('QlgConvertCase')
     D  i_reqCtrlBlk              32767A   const  options(*varsize)
     D  i_inData                  32767A   const  options(*varsize)
     D  o_outData                 32767A          options(*varsize)
     D  i_length                     10I 0 const
     D  io_ErrCode                32767A          options(*nopass: *varsize)
      *
     D QLGCNVCS_reqCtrlBlk_t...
     D                 DS                  qualified
     D  type                         10I 0
     D  CCSID                        10I 0
     D  case                         10I 0
     D  reserved                     10A
      *
     D CVTCASE_TYPE_CCSID...
     D                 C                   const(1)
     D CVTCASE_TYPE_TABLE...
     D                 C                   const(2)
     D CVTCASE_TYPE_USER_DEF...
     D                 C                   const(3)
     D CVTCASE_TO_UPPER...
     D                 C                   const(0)
     D CVTCASE_TO_LOWER...
     D                 C                   const(1)
     D CVTCASE_CCSID_Job...
     D                 C                   const(0)
      *
      * ------------------------------------
      *  Global fields
      * ------------------------------------
     D CRLF            C                   CONST(x'0D25')
      *
     D g_preferUnicode...
     D                 S               N   inz(cTrue )
     D g_LMCompatibility...
     D                 S             10I 0 inz(DEFAULT_LM_COMPATIBILITY_MODE)
     D g_hToAscii      S                   like(hTranscoder_t ) inz
     D g_hToUnicode    S                   like(hTranscoder_t ) inz
      *
     D g_saveProc      DS                  qualified
     D  procPtr                        *   procptr inz
     D  fd                           10I 0 inz
      *
     D g_isTestMode    S               N   inz(cFalse)
      *
     D b64_alphabet    DS
     D   alphabet                    64A   inz('-
     D                                     ABCDEFGHIJKLMNOPQRSTUVWXYZ-
     D                                     abcdefghijklmnopqrstuvwxyz-
     D                                     0123456789+/')
     D   base64f                      1A   dim(64)
     D                                     overlay(alphabet)
      *
     D b64_reverse     DS
     D   revalphabet                256A   inz(x'-
     D                                     FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF-
     D                                     FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF-
     D                                     FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF-
     D                                     FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF-
     D                                     FFFFFFFFFFFFFFFFFFFFFFFFFFFF3eFF-
     D                                     FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF-
     D                                     FF3fFFFFFFFFFFFFFFFFFFFFFFFFFFFF-
     D                                     FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF-
     D                                     FF1a1b1c1d1e1f202122FFFFFFFFFFFF-
     D                                     FF232425262728292a2bFFFFFFFFFFFF-
     D                                     FFFF2c2d2e2f30313233FFFFFFFFFFFF-
     D                                     FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF-
     D                                     FF000102030405060708FFFFFFFFFFFF-
     D                                     FF090a0b0c0d0e0f1011FFFFFFFFFFFF-
     D                                     FFFF1213141516171819FFFFFFFFFFFF-
     D                                     3435363738393a3b3c3dFFFFFFFFFFFF-
     D                                     ')
     D   base64r                      3U 0 dim(255)
     D                                     overlay(revalphabet:2)
      *
     D dsAuth          DS                  qualified
     D   isRequired                   1N   inz(cFalse)
     D   type                         1A   inz(HTTP_AUTH_NONE)
     D   rcvErrPage                   1N   inz(cFalse)
     D   ntlmStatus                  10I 0 inz(NTLM_NONE)
     D   ntlmType2Msg              1024A   varying inz
     D   header                    1476A   varying inz
     D   user                              like(ntlm_user_t     ) inz
     D   passwd                            like(ntlm_password_t ) inz
     D   realm                      124A   varying inz
     D   host                       256A   varying inz
      *
      * Fix encryption value (ASCII)
      * See: The LM Response
      *      http://davenport.sourceforge.net/ntlm.html#type3MessageExample
     D ASCII_STRING    C                   x'4B47532140232425'
      *
      * ------------------------------------
      *  Program Status Information DS
      * ------------------------------------
     D sds            SDS                  qualified
     D  job                  244    253A                                        Job Name
      *
      *=====================================================================*
    R *  *** Official API procedure ***
      *  Interprets a given authentication header.
      *  Called by procedure interpret_auth() of module HTTPAPIR4.
      * -------------------------------------------------------------------
      *  This procedure is called from interpret_auth() for each
      *  "www-authenticate" HTTP header. It resets the negotiate status
      *  when it encounters a 'NTLM' header without a message and it retrieves
      *  the Type-2 message from a given 'Challenge' header.
      * -------------------------------------------------------------------
      *  i_header    = Authentication header that must be interpreted.
      *=====================================================================*
     P AuthPlugin_interpretAuthenticationHeader...
     P                 B                   export
      *
     D AuthPlugin_interpretAuthenticationHeader...
     D                 PI
     D  i_header                   2048A   const
      *
      *  Local fields
     D word            S           2048A   varying inz
      *
     D TAB             C                   x'05'
     D LF              C                   x'25'
     D CR              C                   x'0D'
     D NULL            C                   x'00'
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         word = toLower(getToken(i_header: ' =,'+TAB+CR+LF+NULL));

         dow (word <> '');

            select;
            when (word = 'ntlm');
               dsAuth.rcvErrPage = cTrue;
               dsAuth.realm = dsAuth.host;
               word = getToken(*omit: ' '+TAB+CR+LF+NULL);
               if (word <> '');
                  dsAuth.ntlmType2Msg = word;
               else;
                  dsAuth.ntlmType2Msg = '';
                  // An empty 'NTLM' header indicates that the
                  // server requires NTLM authentication and
                  // that we need to start the authentication
                  // process.
                  dsAuth.ntlmStatus = NTLM_NONE;
                  dsAuth.isRequired = cTrue;
               endif;

            when (word = 'realm');
               word = getToken(*omit: '"');
               if (word <> '');
                  dsAuth.realm = word;
               endif;

            endsl;

            word = toLower(getToken(*omit: ' =,'+TAB+CR+LF+NULL));
         enddo;

         return;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Official API procedure ***
      *  Returns *ON if, HTTPAPI should receive the the 401 error page and
      *  returns the procedure that is called to receive the error page.
      *  Called by procedure do_oper() of module HTTPAPIR4.
      * -------------------------------------------------------------------
      *  In contrast to BASIC and DIGEST authentication the 401 error page
      *  must be received by HTTPAPI, because NTLM uses a persistent
      *  HTTP connection when negotiating the NTLM parameters with the
      *  server. If the 401 error page is not received, it stays on the
      *  wire and eventually is received, when HTTPAPI attempts to get the
      *  actual data from the server. For BASIC and DIGEST authentication
      *  the connection is closed after having received a 401 error code
      *  and hence the 401 error page is being dropped automatically.
      * -------------------------------------------------------------------
      *  io_saveProc = Procedure pointer of the procedure that is called
      *                to receive the error page.
      *  io_saveFD   = File descriptor that is passed to io_saveProc.
      *=====================================================================*
     P AuthPlugin_mustReceiceAuthErrorPage...
     P                 B                   export
     D                 PI              N
     D  io_saveProc                    *          procptr
     D  io_saveFD                    10I 0
      *
      *  Return value
     D ignoreError     S               N   inz(*OFF)
      *
      *  Local fields
     D errorNo         S             10I 0
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         http_dmsg('AuthPlugin_mustReceiceAuthErrorPage(): entered');

         // Ignore 401 error for NTLM authentication, if
         // we did not yet sent the type-3 message because we
         // need to receive the 401 error page. Otherwise we will
         // get it with the actual response when sending the type-3
         // message.
         ignoreError = *OFF;

         if (dsAuth.rcvErrPage);
            http_error(errorNo);
            if (errorNo = HTTP_NDAUTH and
               dsAuth.ntlmStatus = NTLM_AUTHENTICATE);
               // keep error status for NTLM authentication
               // and type-3 message
            else;
               // for type-1 and type-2 messages ignore the
               // 401 error and receive the html error page
               ignoreError = *ON;
               g_saveProc.procPtr = io_saveProc;
               g_saveProc.fd = io_saveFD;
               io_saveProc = %paddr('nullWrite');
               io_saveFD = 0;
            endif;
         endif;

         return ignoreError;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Official API procedure ***
      *  Negotiates the NTLM authentication parameters with the server and
      *  produces the NTLM authentication header value (type-3) message.
      *  Called by procedure http_persist_req() of module HTTPAPIR4.
      * -------------------------------------------------------------------
      *  First the Type-1 message is produced and sent to the server. Then
      *  the procedure receices the Type-2 messages and produces the
      *  Type-3 messages which is used later on to complete the
      *  authentication process.
      * -------------------------------------------------------------------
      *  i_comm      = Pointer to persistent HTTP comm session.
      *  i_URL       = URL to GET from or POST with persistent HTTP comm.
      *  i_timeout   = Timeout is seconds when no data is received.
      *=====================================================================*
     P AuthPlugin_negotiateAuthentication...
     P                 B                   export
     D                 PI            10I 0
     D  i_comm                         *   const
     D  i_URL                     32767A   const  varying options(*varsize)
     D  i_timeout                    10I 0 const
      *
      *  Return value
     D rc              S             10I 0 inz
      *
      *  Local fields
     D authUser        S                   like(dsAuth.user    ) inz
     D authDomain      S                   like(dsAuth.passwd  ) inz
     D pos             S             10I 0 inz
     D URL             S                   like(i_URL          ) inz
      *
     D type1Msg        S                   like(ntlm_message_t ) inz
     D type2Msg        S                   like(ntlm_message_t ) inz
     D type3Msg        S                   like(ntlm_message_t ) inz
      *
     D errorNo         S             10I 0 inz
     D negotiating     S               N   inz(cFalse) static
      *
     D service         S             32A   varying inz
     D host            S            256A   varying inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         parseUrl(i_URL: service: host);
         dsAuth.host = host;

         if (dsAuth.ntlmStatus <> NTLM_NEGOTIATE);
            return 0;
         endif;

         if (negotiating);
            return 0;
         endif;

         http_dmsg('NTLM_negotiateAuthentication(): entered');

         negotiating = cTrue;

         // *********************************************************
         //   Splitt user into user & passowrd
         // *********************************************************
         //   scan for a backslash:
         //   possible domain/name formats are:
         //      Format              Type 3 Field Content
         //      DOMAIN\user         User Name = "user",
         //                          Domain    = "DOMAIN"
         //      domain.com\user     User Name = "user"
         //                          Domain    = "domain.com"
         //      user@DOMAIN         User Name = "user@DOMAIN"
         //                          Domain is empty
         //      user@domain.com     User Name = "user@domain.com"
         //                          Domain is empty
         // *********************************************************

         // pos = %scan(%char(u'005C'): i_user);
         pos = %scan(%char(u'005C'): dsAuth.user);
         if (pos = 0);
            authDomain = '';
            // authUser = i_user;
            authUser = dsAuth.user;
         else;
            // authDomain = %subst(i_user: 1: pos-1);
            // authUser = %subst(i_user: pos+1);
            authDomain = %subst(dsAuth.user: 1: pos-1);
            authUser = %subst(dsAuth.user: pos+1);
         endif;

         // *********************************************************
         //   Produce Type-1 message and send it to the server
         // *********************************************************

         dou ('1');

            type1Msg = Message_newType1();

            dsAuth.header = Message_encodeBase64(type1Msg);

            URL = removeAuthFromUrl(i_URL);
            rc = http_persist_get(
                       i_comm: URL: 0: %paddr('nullWrite'): i_timeout);

            if (rc = -1);
               http_error(errorNo);
               if (errorNo <> HTTP_NDAUTH);
                  dsAuth.ntlmStatus = NTLM_NONE;
                  SetError(HTTP_NDAUTH: ' failed sending type-1 message');
                  rc = -1;
                  leave;
               endif;
            endif;

            // *********************************************************
            //   Validate the Type-2 message.
            // *********************************************************

            type2Msg = Message_decodeBase64(dsAuth.ntlmType2Msg);

            if (not Message_isType2(type2Msg));
               dsAuth.ntlmStatus = NTLM_NONE;
               SetError(HTTP_NDAUTH: ' failed validating type-2 message');
               rc = -1;
               leave;
            endif;

            if (not Message_validateType2(type1Msg: type2Msg));
               http_dmsg('NTLM_negotiateAuthentication(): +
                          Invalid Type-2 message');
               dsAuth.ntlmStatus = NTLM_NONE;
               SetError(HTTP_NDAUTH: ' failed validating type-2 message');
               rc = -1;
               leave;
            endif;

            // *********************************************************
            //   Produce Type-3 message
            // *********************************************************

            type3Msg = Message_newType3(type2Msg
                                        : %trim(authUser)
                                        : %trim(dsAuth.passwd)
                                        : %trim(authDomain));

            dsAuth.header = Message_encodeBase64(type3Msg);
            dsAuth.ntlmStatus = NTLM_AUTHENTICATE;

            rc = 0;
         enddo;

         negotiating = cFalse;

         return rc;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Official API procedure ***
      *  Produces the NTLM authentication header when negotiating
      *  the NTLM authentication parameters with the server.
      *  Called by procedure do_oper() of module HTTPAPIR4.
      * -------------------------------------------------------------------
      *  Depending on the status of the authentication process either
      *  a Type-1 or a Type-3 authentication header is being produced
      *  and added to the HTTP request chain.
      * -------------------------------------------------------------------
      *  io_reqChain = HTTP request chain that is send to the server.
      *=====================================================================*
     P AuthPlugin_produceAuthenticationHeader...
     P                 B                   export
     D                 PI
     D  io_reqChain               32767A   varying
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (dsAuth.ntlmStatus <> NTLM_NEGOTIATE and
             dsAuth.ntlmStatus <> NTLM_AUTHENTICATE);
            return;
         endif;

         http_dmsg('AuthPlugin_produceAuthenticationHeader(): entered');

         // Add NTLM authentication header for type-1
         // and type-3 messages.
         io_reqChain = io_reqChain +
                       'Authorization: NTLM ' +
                        dsAuth.header + CRLF;
         if (dsAuth.ntlmStatus = NTLM_NEGOTIATE);
            dsAuth.ntlmStatus = NTLM_AUTHENTICATE;
         else;
            // Finish the NTLM authentication process
            dsAuth.ntlmStatus = NTLM_NONE;
         endif;

         return;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Official API procedure ***
      *  Returns cTrue if the server requires authentication.
      *  Called by procedure http_getauth() of module HTTPAPIR4.
      * -------------------------------------------------------------------
      *  no parameters
      *=====================================================================*
     P AuthPlugin_isAuthenticationRequired...
     P                 B                   export
     D                 PI              N
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         return dsAuth.isRequired;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Official API procedure ***
      *  Returns the realm of the server.
      *  Called by procedure http_getauth() of module HTTPAPIR4.
      * -------------------------------------------------------------------
      *  no parameters
      *=====================================================================*
     P AuthPlugin_getRealm...
     P                 B                   export
     D                 PI           124A   varying
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         return dsAuth.realm;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Official API procedure ***
      *  Sets the NTLM authentication credentials
      *  Called by procedure http_setAuth() of module HTTPAPIR4.
      * -------------------------------------------------------------------
      *  i_authType  = Authentication type used to specify login credentials.
      *  i_username  = User name to use.
      *  i_passwd    = Password to use.
      *=====================================================================*
     P AuthPlugin_setAuthentication...
     P                 B                   export
     D                 PI              N
     D  i_authType                    1A   const
     D  i_username                   80A   const
     D  i_passwd                   1024A   const
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (i_authType <> HTTP_AUTH_NTLM);
            resetAuthentication(cTrue);
            return cFalse;
         endif;

         http_dmsg('NTLM_setCredentials(): entered');

         dsAuth.ntlmStatus = NTLM_NEGOTIATE;
         dsAuth.header = '';
         dsAuth.user = i_username;
         dsAuth.passwd = i_passwd;

         return cTrue;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Official API procedure ***
      *  Resets authentication parameters.
      *  Called by procedure interpret_auth() of module HTTPAPIR4.
      * -------------------------------------------------------------------
      *  no parameters
      *=====================================================================*
     P AuthPlugin_resetAuthentication...
     P                 B                   export
     D                 PI
      *
      * Parameter positions
     D p_resetAll      C                   1
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         resetAuthentication(cFalse);

         return;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Resets authentication parameters.
      *=====================================================================*
     P resetAuthentication...
     P                 B
     D                 PI
     D  i_resetAll                     N   const
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         dsAuth.isRequired = cFalse;
         dsAuth.rcvErrPage = cFalse;
         dsAuth.ntlmStatus = NTLM_NONE;
         dsAuth.ntlmType2Msg = '';
         dsAuth.header = '';

         if (i_resetAll);
            dsAuth.user = '';
            dsAuth.passwd = '';
            dsAuth.realm = '';
            dsAuth.host = '';
         endif;

         return;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Removes user and password from a given URL.
      *=====================================================================*
     P removeAuthFromUrl...
     P                 B                   export
     D                 PI         32767A          varying
     D   i_URL                    32767A   const  varying options(*varsize)
      *
      *  Return value
     D URL             S                   like(i_URL) inz
      *
      *  Local fields
     D service         S             32A
     D user            S             32A
     D passwd          S             32A
     D host            S            256A
     D port            S             10I 0
     D path            S          32767A   varying
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         http_long_ParseURL(i_URL: service: user: passwd: host: port: path);
         URL = %trim(service) + '://' +
               %trim(host);

         if (port <> 0);
            URL = URL + ':' + %char(port);
         endif;

         URL = URL + path;

         return URL;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Enables Test Mode for RPGUnit Test Cases
      *=====================================================================*
     P NTLM_enableTestMode...
     P                 B                   export
     D                 PI
     D  i_mode                         N   const
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         g_isTestMode = i_mode;

         return;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Sets the LM compatibility mode.
      *    0 -- Sends NTLMv1 response. That may also include the weak
      *         LM response.
      *    1 -- Sends only the NTLM response. This is more secure than
      *         Levels 0, because it eliminates the cryptographically-weak
      *         LM response.
      *    2 -- Sends only the NTLM2 response.
      *    3 -- Sends LMv2 and NTLMv2 data.
      *         Session security is not yet supported.
      *         This is the default mode.
      *=====================================================================*
      *  Corresponds to JCIFS property:   jcifs.smb.lmCompatibility
      *=====================================================================*
     P NTLM_setLMCompatibility...
     P                 B                   export
     D                 PI
     D  i_mode                       10I 0 const  options(*nopass)
      *
      *  Parameter positions
     D p_mode          C                   1
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (%parms() >= p_mode);
            if (i_mode >= 0 and i_mode <= 3);
               g_LMCompatibility = i_mode;
            else;
               g_LMCompatibility = DEFAULT_LM_COMPATIBILITY_MODE;
            endif;
         else;
            g_LMCompatibility = DEFAULT_LM_COMPATIBILITY_MODE;
         endif;

         return;
      /end-free
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Produces a Type-1 message:   NtLmNegotiate
      * -------------------------------------------------------------------
      *  i_flags          Message flags. 0=use default flags.
      *  i_workstation    Workstation name of the client.
      *  i_domain         Name of the domain in which the workstation has
      *                   membership.
      *=====================================================================*
      *  Corresponds to JCIFS class:   Type1Message
      *=====================================================================*
     P Message_newType1...
     P                 B                   export
     D                 PI                         like(ntlm_message_t )
     D  i_flags                      10U 0 const  options(*nopass: *omit)
     D  i_workstation                      const  like(ntlm_workstation_t )
     D                                            options(*varsize:
     D                                                    *nopass: *omit)
     D  i_domain                           const  like(ntlm_domain_t  )
     D                                            options(*varsize:
     D                                                    *nopass: *omit)
      *
      *  Return value
     D message         S                   like(ntlm_message_t ) inz
      *
      *  Parameter positions
     D p_flags         C                   1
     D p_workstation   C                   2
     D p_domain        C                   3
      *
      *  Fields for optional parameters
     D workstation     S                   like(i_workstation ) inz
     D domain          S                   like(i_domain      ) inz
      *
      *  Local fields
     D offs            S             10I 0 inz
      *
     D tmpMessage      S           2048A   inz
      *
     D type1           DS                  likeds(type1_t ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         clear type1;

         if (%parms() >= p_flags and %addr(i_flags) <> *NULL);
            type1.flags = %bitor(i_flags: getDefaultFlagsType1());
         else;
            type1.flags = getDefaultFlagsType1();
         endif;

         if (%parms() >= p_domain and %addr(i_domain) <> *NULL);
            type1.domain = i_domain;
         else;
            type1.domain = '';
         endif;

         if (%parms() >= p_workstation and %addr(i_workstation) <> *NULL);
            type1.workstation = i_workstation;
         else;
            type1.workstation = getDefaultWorkstation();
         endif;

         if (type1.domain <> '');
            type1.flags =
               %bitor(type1.flags: NTLMSSP_NEGOTIATE_OEM_DOMAIN_SUPPLIED);
         endif;

         if (type1.workstation <> '');
            type1.flags =
               %bitor(type1.flags: NTLMSSP_NEGOTIATE_OEM_WORKSTATION_SUPPLIED);
         endif;

         message = Type1_toByteArray(type1);

         return message;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used ***
      *  Validates a Type-2 message.
      * -------------------------------------------------------------------
      *  i_type1Msg       Type-1 message that was sent to the server.
      *  i_type2Msg       Type-2 message responded by the server.
      *=====================================================================*
     P Message_validateType2...
     P                 B
     D                 PI              N
     D  i_type1Msg                                like(ntlm_message_t )
     D                                            options(*varsize)
     D  i_type2Msg                                like(ntlm_message_t )
     D                                            options(*varsize)
     D  o_rc                         10I 0        options(*nopass)
      *
      *  Fields for optional parameters
     D rc              S                   like(o_rc ) inz(0)
      *
      *  Parameter positions
     D p_rc            C                   3
      *
      *  Local fields
     D NtlmNegotiate   DS                  likeds(NtLmNegotiate_t)
     D                                     based(pNtlmNegotiate)
     D NtLmChallenge   DS                  likeds(NtLmChallenge_t)
     D                                     based(pNtLmChallenge)
      *
     D type1Flags      S             10U 0 inz
     D type2Flags      S             10U 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         pNtlmNegotiate = %addr(i_type1Msg)+2;
         pNtLmChallenge = %addr(i_type2Msg)+2;

         dou '1';

            // Validate types
            if (not Message_isType1(i_type1Msg));
               rc = NTLM_EINV_TYPE1_MSG;
               leave;
            endif;

            if (not Message_isType2(i_type2Msg));
               rc = NTLM_EINV_TYPE2_MSG;
               leave;
            endif;

            type1Flags = uint32LE(NtlmNegotiate.flags);
            type2Flags = uint32LE(NtLmChallenge.flags);

            // Validate encoding
            // The encoding must either be set to NTLMSSP_NEGOTIATE_UNICODE or
            // NTLMSSP_NEGOTIATE_OEM.
            if (not (isBit(type2Flags: NTLMSSP_NEGOTIATE_UNICODE) or
                     isBit(type2Flags: NTLMSSP_NEGOTIATE_OEM)));
               rc = NTLM_EINV_ENCODING;
               leave;
            endif;

            // Validate encoding
            // Either NTLMSSP_NEGOTIATE_UNICODE or NTLMSSP_NEGOTIATE_OEM must
            // be set but not both.
            if (isBit(type2Flags: NTLMSSP_NEGOTIATE_UNICODE) and
                isBit(type2Flags: NTLMSSP_NEGOTIATE_OEM));
               rc = NTLM_EINV_ENCODING;
               leave;
            endif;

            // Validate encoding
            // Encoding of Type-1 message must match the encoding of the
            // Type-2 message.
            if (isBit(type2Flags:NTLMSSP_NEGOTIATE_UNICODE) and
                not isBit(type1Flags:NTLMSSP_NEGOTIATE_UNICODE));
               rc = NTLM_ENSUP_ENCODING;
               leave;
            endif;

            if (isBit(type2Flags:NTLMSSP_NEGOTIATE_OEM) and
                not isBit(type1Flags:NTLMSSP_NEGOTIATE_OEM));
               rc = NTLM_ENSUP_ENCODING;
               leave;
            endif;

         enddo;

         if (%parms() >= p_rc and %addr(o_rc) <> *NULL);
            o_rc = rc;
         endif;

         if (rc = 0);
            return cTrue;
         endif;

         return cFalse;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Produces a Type-3 message:   NtLmAuthenticate
      * -------------------------------------------------------------------
      *  i_type2Msg       Type-2 message responded by the server.
      *  i_user           The username for the authenticating user.
      *  i_password       The password to use when constructing the response.
      *  i_domain         The domain in which the user has an account.
      *=====================================================================*
      *  Corresponds to JCIFS class:   Type3Message
      *=====================================================================*
     P Message_newType3...
     P                 B                   export
     D                 PI                         like(ntlm_message_t )
     D  i_type2Msg                                like(ntlm_message_t )
     D                                            options(*varsize)
     D  i_user                             const  like(ntlm_user_t     )
     D                                            options(*varsize)
     D  i_password                         const  like(ntlm_password_t )
     D                                            options(*varsize)
     D  i_domain                           const  like(ntlm_domain_t   )
     D                                            options(*varsize
     D                                                    : *omit: *nopass)
      *
      *  Return value
     D message         S                   like(ntlm_message_t ) inz
      *
      *  Parameter positions
     D p_domain        C                   4
      *
      *  Optional parameter fields
      *
      *  Local fields
     D tmpMessage      S           2048A   inz
     D NtLmChallenge   DS                  likeds(NtLmChallenge_t )
     D                                     based(pNtLmChallenge)
      *
     D responseKeyNT   S                   like(MD5_digest_t      ) inz
     D clientChallenge...
     D                 S                   like(ntlm_challenge_t  ) inz
      *
     D userSessionKey  S                   like(MD5_digest_t      ) inz
     D masterKey       S             16A   inz
     D exchangedKey    S             16A   inz
     D nt              S                   like(ntlm_ntResponse_t ) inz
      *
     D type3           DS                  likeds(type3_t ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         pNtLmChallenge = %addr(i_type2Msg)+2;

         clear type3;

         type3.flags = %bitor(0: getDefaultFlagsType3(NtLmChallenge));

         if (%parms() >= p_domain and %addr(i_domain) <> *NULL);
            type3.domain = i_domain;
         else;
            type3.domain = '';
         endif;

         type3.user = i_user;
         type3.workstation = getDefaultWorkstation();

         select;
         // 0 -- Sends NTLMv1 response
         // 1 -- Sends only the NTLM response.
         //      This is more secure than Levels 0, because it
         //      eliminates the cryptographically-weak LM response.
         // 2 -- Sends only the NTLM2 response.
         when (g_LMCompatibility = LM_MODE_NTLM_V1 or
               g_LMCompatibility = LM_MODE_NTLM_V1_NO_LM or
               g_LMCompatibility = LM_MODE_NTLM_V1_NTLM2_ONLY);

            if (g_LMCompatibility = LM_MODE_NTLM_V1_NTLM2_ONLY or
                isBit(type3.flags: NTLMSSP_NEGOTIATE_NTLM2));
               random(clientChallenge);
               type3.ntResponse =
                  getNTLM2Response(
                     i_password: NtlmChallenge.challenge: clientChallenge);
               type3.lmResponse = clientChallenge + z(16);
            else;
               type3.ntResponse =
                  getNTResponse(NtlmChallenge: i_password);
               if (g_LMCompatibility = LM_MODE_NTLM_V1_NO_LM or
                   isBit(type3.flags: NTLMSSP_NEGOTIATE_NT_ONLY));
                  type3.lmResponse = type3.ntResponse;
               else;
                  type3.lmResponse =
                     getLMResponse(NtlmChallenge: i_password);
               endif;
            endif;

            if (isBit(type3.flags: NTLMSSP_NEGOTIATE_SIGN));
               kill('Unsupported Flag: NTLMSSP_NEGOTIATE_SIGN');
            endif;

         // 3 -- Sends LMv2 and NTLMv2 data.
         //      NTLMv2 session security is also negotiated if the server supports it.
         //      This is the default behavior (in 1.3.0 or later).
         when (g_LMCompatibility = LM_MODE_NTLM_V2);
            responseKeyNT = NTOWFv2(i_password: i_user: type3.domain);

            random(clientChallenge: g_isTestMode);
            type3.lmResponse =
               getLMv2Response(
                  NtLmChallenge: type3.domain
                  : i_user: i_password: clientChallenge);

            random(clientChallenge: g_isTestMode);
            type3.ntResponse =
               getNTLMv2Response(
                  NtLmChallenge: responseKeyNT: clientChallenge);

            if (isBit(type3.flags: NTLMSSP_NEGOTIATE_SIGN));
               kill('Unsupported Flag: NTLMSSP_NEGOTIATE_SIGN');

               // only first 16 bytes of ntResponse
               userSessionKey =
                  MD5Hmac(responseKeyNT: %subst(type3.ntResponse: 1:16));

               if (isBit(type3.flags: NTLMSSP_NEGOTIATE_KEY_EXCH));
                  random(masterKey: g_isTestMode);
                  exchangedKey = RC4(userSessionKey: masterKey);
                  type3.sessionKey = exchangedKey;
               else;
                  masterKey = userSessionKey;
                  type3.sessionKey = masterKey;
               endif;

            endif;

         other;
            type3.lmResponse =
               getLMResponse(NtlmChallenge: i_password);
            type3.ntResponse =
               getNTResponse(NtlmChallenge: i_password);
         endsl;

         message = Type3_toByteArray(type3);

         return message;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Returns cTrue if the specified message is a Type 1 message.
      *---------------------------------------------------------------------*
      *  i_message        Message, that is tested for a Type-1 message.
      *=====================================================================*
     P Message_isType1...
     P                 B                   export
     D                 PI              N
     D  i_message                          const  like(ntlm_message_t )
     D                                            options(*varsize)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         return isMessageTypeOf(i_message: NEGOTIATE_MESSAGE);

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used ***
      *  Returns cTrue if the specified message is a Type 2 message.
      *---------------------------------------------------------------------*
      *  i_message        Message, that is tested for a Type-2 message.
      *=====================================================================*
     P Message_isType2...
     P                 B
     D                 PI              N
     D  i_message                          const  like(ntlm_message_t )
     D                                            options(*varsize)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         return isMessageTypeOf(i_message: CHALLENGE_MESSAGE);

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used ***
      *  Returns cTrue if the specified message is a Type 3 message.
      *---------------------------------------------------------------------*
      *  i_message        Message, that is tested for a Type-3 message.
      *=====================================================================*
     P Message_isType3...
     P                 B
     D                 PI              N
     D  i_message                          const  like(ntlm_message_t )
     D                                            options(*varsize)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         return isMessageTypeOf(i_message: AUTHENTICATE_MESSAGE);

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Returns the challenge for a given Type-2 message.
      *---------------------------------------------------------------------*
      *  i_type2Msg       Message, whose challenge is returned.
      *=====================================================================*
      *  Corresponds to JCIFS method:   Type2Message.getChallenge
      *=====================================================================*
     P Message_getChallenge...
     P                 B                   export
     D                 PI                         like(ntlm_challenge_t)
     D  i_type2Msg                                like(ntlm_message_t  )
     D                                            options(*varsize)
      *
      *  Return value
     D challenge       S                   like(ntlm_challenge_t ) inz
      *
      *  Local fields
     D NtLmChallenge   DS                  likeds(NtLmChallenge_t)
     D                                     based(pNtLmChallenge)
      *
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (not Message_isType2(i_type2Msg));
            kill('The specified message is not a Type-2 message');
         endif;

         pNtLmChallenge = %addr(i_type2Msg)+2;
         challenge = NtLmChallenge.challenge;

         return challenge;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Returns cTrue if the specified flag is set in a given message.
      *---------------------------------------------------------------------*
      *  i_message        Message, that is tested for a given flag.
      *  i_flag           Flag, the message is tested for.
      *=====================================================================*
     P Message_hasFlag...
     P                 B                   export
     D                 PI              N
     D  i_message                          const  like(ntlm_message_t )
     D                                            options(*varsize)
     D  i_flag                       10U 0 const
      *
      *  Return value
     D hasFlag         S               N   inz(cFalse)
      *
      *  Local fields
     D flags           S                   like(NtLmNegotiate_t.flags) inz
     D NtlmNegotiate   DS                  likeds(NtLmNegotiate_t    ) inz
     D NtLmChallenge   DS                  likeds(NtLmChallenge_t    ) inz
     D NtlmAuthenticate...
     D                 DS                  likeds(NtLmAuthenticate_t ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         select;
         when (Message_isType1(i_message));
            NtlmNegotiate = %subst(i_message: 1: %len(i_message));
            flags = uint32LE(NtlmNegotiate.flags);
         when (Message_isType2(i_message));
            NtLmChallenge = %subst(i_message: 1: %len(i_message));
            flags = uint32LE(NtlmChallenge.flags);
         when (Message_isType3(i_message));
            NtlmAuthenticate = %subst(i_message: 1: %len(i_message));
            flags = uint32LE(NtlmAuthenticate.flags);
         other;
            kill('The specified message is not a known message.');
         endsl;

         hasFlag = isBit(flags: i_flag);

         return hasFlag;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests, only ***
      *  Returns the server's NetBIOS computer name.
      *---------------------------------------------------------------------*
      *  i_type2Msg       Message, the NetBIOS computer name is
      *                   retrieved from.
      *=====================================================================*
     P Message_getTargetNBComputerName...
     P                 B                   export
     D                 PI                         like(ntlm_targetName_t)
     D  i_type2Msg                                like(ntlm_message_t   )
     D                                            options(*varsize)
      *
      *  Local fields
     D NtLmChallenge   DS                  likeds(NtLmChallenge_t)
     D                                     based(pNtLmChallenge)
      *
     D length          S              5I 0 inz
      *
     D tmpTargetInfo   DS                  likeds(targetInfo_t )
     D                                     based(pTmpTargetInfo)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (not Message_isType2(i_type2Msg));
            kill('The specified message is not a Type-2 message');
         endif;

         pNtLmChallenge = %addr(i_type2Msg)+2;

         return getTargetInfo(NtLmChallenge
                              : NTLM_TARGET_TYPE_NB_COMPUTER_NAME);

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests, only ***
      *  Returns the server's NetBIOS domain name.
      *---------------------------------------------------------------------*
      *  i_type2Msg       Message, the NetBIOS domain name is
      *                   retrieved from.
      *=====================================================================*
     P Message_getTargetNBDomainName...
     P                 B                   export
     D                 PI                         like(ntlm_targetName_t)
     D  i_type2Msg                                like(ntlm_message_t   )
     D                                            options(*varsize)
      *
      *  Local fields
     D NtLmChallenge   DS                  likeds(NtLmChallenge_t)
     D                                     based(pNtLmChallenge)
      *
     D length          S              5I 0 inz
      *
     D tmpTargetInfo   DS                  likeds(targetInfo_t )
     D                                     based(pTmpTargetInfo)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (not Message_isType2(i_type2Msg));
            kill('The specified message is not a Type-2 message');
         endif;

         pNtLmChallenge = %addr(i_type2Msg)+2;

         return getTargetInfo(NtLmChallenge
                              : NTLM_TARGET_TYPE_NB_DOMAIN_NAME);

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests, only ***
      *  Returns the server's Active Directory DNS computer name.
      *---------------------------------------------------------------------*
      *  i_type2Msg       Message, the Active Directory DNS computer name
      *                   retrieved from.
      *=====================================================================*
     P Message_getTargetDNSComputerName...
     P                 B                   export
     D                 PI                         like(ntlm_targetName_t)
     D  i_type2Msg                                like(ntlm_message_t   )
     D                                            options(*varsize)
      *
      *  Local fields
     D NtLmChallenge   DS                  likeds(NtLmChallenge_t)
     D                                     based(pNtLmChallenge)
      *
     D length          S              5I 0 inz
      *
     D tmpTargetInfo   DS                  likeds(targetInfo_t )
     D                                     based(pTmpTargetInfo)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (not Message_isType2(i_type2Msg));
            kill('The specified message is not a Type-2 message');
         endif;

         pNtLmChallenge = %addr(i_type2Msg)+2;

         return getTargetInfo(NtLmChallenge
                              : NTLM_TARGET_TYPE_DNS_COMPUTER_NAME);

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests, only ***
      *  Returns the server's Active Directory DNS domain name.
      *---------------------------------------------------------------------*
      *  i_type2Msg       Message, the Active Directory DNS domain name
      *                   retrieved from.
      *=====================================================================*
     P Message_getTargetDNSDomainName...
     P                 B                   export
     D                 PI                         like(ntlm_targetName_t)
     D  i_type2Msg                                like(ntlm_message_t   )
     D                                            options(*varsize)
      *
      *  Local fields
     D NtLmChallenge   DS                  likeds(NtLmChallenge_t)
     D                                     based(pNtLmChallenge)
      *
     D length          S              5I 0 inz
      *
     D tmpTargetInfo   DS                  likeds(targetInfo_t )
     D                                     based(pTmpTargetInfo)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (not Message_isType2(i_type2Msg));
            kill('The specified message is not a Type-2 message');
         endif;

         pNtLmChallenge = %addr(i_type2Msg)+2;

         return getTargetInfo(NtLmChallenge
                              : NTLM_TARGET_TYPE_DNS_DOMAIN_NAME);

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Not yet in use ***
      *  Returns server's Active Directory (AD) DNS forest tree name.
      *---------------------------------------------------------------------*
      *  i_type2Msg       Message, the Active Directory DNS forest tree name
      *                   retrieved from.
      *=====================================================================*
     P Message_getTargetDNSTreeName...
     P                 B
     D                 PI                         like(ntlm_targetName_t)
     D  i_type2Msg                                like(ntlm_message_t   )
     D                                            options(*varsize)
      *
      *  Local fields
     D NtLmChallenge   DS                  likeds(NtLmChallenge_t)
     D                                     based(pNtLmChallenge)
      *
     D length          S              5I 0 inz
      *
     D tmpTargetInfo   DS                  likeds(targetInfo_t )
     D                                     based(pTmpTargetInfo)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (not Message_isType2(i_type2Msg));
            kill('The specified message is not a Type-2 message');
         endif;

         pNtLmChallenge = %addr(i_type2Msg)+2;

         return getTargetInfo(NtLmChallenge
                              : NTLM_TARGET_TYPE_DNS_TREE_NAME);

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Encodes a given message to Base64.
      *---------------------------------------------------------------------*
      *  i_message        Message material that is encoded to Base64.
      *=====================================================================*
     P Message_encodeBase64...
     P                 B                   export
     D                 PI                         like(ntlm_message_t )
     D  i_message                          const  like(ntlm_message_t )
     D                                            options(*varsize)
      *
      *  Return value
     D rtn             DS                  qualified
     D  base64                             like(ntlm_message_t ) inz
     D  size                   1      2I 0
     D  data                   3   2050A
      *
      *  Local fields
     D tmpMessage      S           2048A   inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (%len(i_message) = 0);
            return '';
         endif;

         tmpMessage = %subst(i_message: 1: %len(i_message));

         rtn.size = NTLM_Base64_encode(%addr(tmpMessage): %len(i_message)
                                       : %addr(rtn.data): %size(rtn.data));
         return rtn.base64;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Decodes a given message from Base64.
      *---------------------------------------------------------------------*
      *  i_message        Base64 encoded message that is decoded to
      *                   its binary form.
      *=====================================================================*
     P Message_decodeBase64...
     P                 B                   export
     D                 PI                         like(ntlm_message_t )
     D  i_message                          const  like(ntlm_message_t )
     D                                            options(*varsize)
      *
      *  Return value
     D rtn             DS                  qualified
     D  message                            like(ntlm_message_t ) inz
     D  size                   1      2I 0
     D  data                   3   2050A
      *
      *  Local fields
     D tmpMessage      S           2048A   inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (%len(i_message) = 0);
            return '';
         endif;

         tmpMessage = %subst(i_message: 1: %len(i_message));

         rtn.size = NTLM_Base64_decode(%addr(tmpMessage): %len(i_message)
                                       : %addr(rtn.data): %size(rtn.data));
         return rtn.message;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Constructs the 'LMChallengeResponse' as  described in document
      *  'NT LAN Manager (NTLM) Authentication Protocol Specification'.
      *=====================================================================*
     P getLMResponse...
     P                 B                   export
     D                 PI                         like(ntlm_lmResponse_t)
     D  i_NtLmChallenge...
     D                                     const  likeds(NtLmChallenge_t)
     D  i_password                         const  like(ntlm_password_t  )
      *
      *  Return value
     D LMResponse      S                   like(ntlm_lmResponse_t ) inz
      *
      *  Local fields
     D responseKeyLM   S             16A   inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         responseKeyLM = LMOWFv1(i_password);

         LMResponse = desl(responseKeyLM: i_NtLmChallenge.challenge);

         return LMResponse;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Constructs the 'NTChallengeResponse' as  described in document
      *  'NT LAN Manager (NTLM) Authentication Protocol Specification'.
      *=====================================================================*
     P getNTResponse...
     P                 B                   export
     D                 PI                         like(ntlm_ntResponse_t)
     D  i_NtLmChallenge...
     D                                     const  likeds(NtLmChallenge_t)
     D  i_password                         const  like(ntlm_password_t  )
      *
      *  Return value
     D NTResponse      S                   like(ntlm_ntResponse_t ) inz
      *
      *  Local fields
     D responseKeyNT   S                   like(MD4_digest_t      ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         responseKeyNT = NTOWFv1(i_password);

         NTResponse = desl(responseKeyNT: i_NtLmChallenge.challenge);

         return NTResponse;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Constructs the 'NTChallengeResponse' as  described in document
      *  'NT LAN Manager (NTLM) Authentication Protocol Specification'.
      *  This procedure is called when the 'NTLMSSP_NEGOTIATE_NTLM2' flag
      *  is set.
      *=====================================================================*
     P getNTLM2Response...
     P                 B                   export
     D                 PI                         like(ntlm_ntResponse_t)
     D  i_password                         const  like(ntlm_password_t  )
     D                                            options(*varsize)
     D  i_serverChallenge...
     D                                     const  like(ntlm_challenge_t )
     D  i_clientChallenge...
     D                                     const  like(ntlm_challenge_t )
      *
      *  Return value
     D NTLM2Response   S                   like(ntlm_ntResponse_t ) inz
      *
      *  Local fields
     D responseKeyNT   S                   like(MD4_digest_t      ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         responseKeyNT = NTOWFv1(i_password);

         NTLM2Response = desl(responseKeyNT
                            : MD5Digest(i_serverChallenge + i_clientChallenge));

         return NTLM2Response;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Constructs the LMv2 response to the given Type-2 message
      *  using the supplied information.
      *=====================================================================*
      *  Corresponds to JCIFS method:   Type3Message.getLMv2Response
      *=====================================================================*
     P getLMv2Response...
     P                 B                   export
     D                 PI                         like(ntlm_lmResponse_t)
     D  i_NtLmChallenge...
     D                                            likeds(NtLmChallenge_t)
     D  i_domain                           const  like(ntlm_domain_t    )
     D  i_user                             const  like(ntlm_user_t      )
     D  i_password                         const  like(ntlm_password_t  )
     D  i_clientChallenge...
     D                                     const  like(ntlm_challenge_t )
      *
      *  Return value
     D LMResponse      DS                  qualified
     D  value                              like(ntlm_lmResponse_t) inz
     D  hmac                               like(MD5_digest_t     )
     D                                     overlay(value)
     D  clientChallenge...
     D                                     like(ntlm_challenge_t )
     D                                     overlay(value: *next)
      *
      *  Local fields
     D password        S                   like(i_password    ) inz
     D user            S                   like(i_user        ) inz
     D domain          S                   like(i_domain      ) inz
     D md4_digest      S                   like(MD4_digest_t  ) inz
     D hmac            S                   like(MD5_digest_t  ) inz
     D type2Msg        S                   like(ntlm_message_t)
     D                                     based(pType2Msg)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         password = varstringLE(toUnicode(i_password));
         user = varstringLE(toUnicode(toUpper(i_user)));
         domain = varstringLE(toUnicode(toUpper(i_domain)));

         md4_digest = md4(password);
         hmac = MD5Hmac(md4_digest: user + domain);

         hmac = MD5Hmac(hmac: i_NtLmChallenge.challenge + i_clientChallenge);

         LMResponse.hmac = hmac;
         LMResponse.clientChallenge = i_clientChallenge;

         return LMResponse;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Constructs the NTLMv2 response to the given Type-2 message
      *  using the supplied information.
      *=====================================================================*
      *  Corresponds to JCIFS method:   Type3Message.getNTLMv2Response
      *=====================================================================*
     P getNTLMv2Response...
     P                 B                   export
     D                 PI                         like(ntlm_ntlmResponse_t)
     D  i_NtLmChallenge...
     D                                            likeds(NtLmChallenge_t)
     D  i_respKeyNT                        const  like(MD5_digest_t     )
     D  i_clientChallenge...
     D                                     const  like(ntlm_challenge_t )
      *
      *  Return value
     D NTLMResponse    S                   like(ntlm_ntlmResponse_t) inz
      *
      *  Local fields
     D timestamp       S             20U 0 inz
     D timeInMillis    S             20U 0 inz
     D length          S              5I 0 inz
     D offset          S             10I 0 inz
     D pNtLmChallenge  S               *   inz
      *
     D targetInfo      S           2048A   based(pTargetInfo)
     D serverChallenge...
     D                 S                   like(ntlm_challenge_t ) inz
      *
     D tempLength      S             10I 0 inz
      *
      *  NTLMv2_CLIENT_CHALLENGE:
     D tempBuffer      S           2048A   based(pTemp)
     D temp            DS                  qualified based(pTemp)
     D  respType                      1A
     D  hiRespType                    1A
     D  reserved_1                    2A
     D  reserved_2                    4A
     D  timestamp                    20U 0
     D  clientChallenge...
     D                                8A
     D  reserved_3                    4A
      *
     D temp_targetInfo...
     D                 S           2020A   based(pTemp_TargetInfo)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (g_isTestMode);
            timeInMillis = 1334670690000;
         else;
            timeInMillis = getCurrentTimeMillis(); // time in nano seconds
         endif;

         timestamp = (timeInMillis + MILLISECONFS_BETWEEN_1970_AND_1601) *10000;

         // Get length and offset of target name
         length = uint16LE(i_NtLmChallenge.targetInfo.length);
         offset = uint32LE(i_NtLmChallenge.targetInfo.offset);

         // Go to the first target information block
         pNtLmChallenge = %addr(i_NtLmChallenge);
         pTargetInfo = pNtLmChallenge + offset;

         tempLength = %size(temp) + length + 4;
         pTemp = %alloc(tempLength);

         temp = *ALLx'00';
         temp.respType = x'01';
         temp.hiRespType = x'01';
         temp.reserved_1 = *ALLx'00';
         temp.reserved_2 = *ALLx'00';
         temp.timestamp = uint64LE(timestamp);
         temp.clientChallenge = i_clientChallenge;
         temp.reserved_3 = *ALLx'00';

         pTemp_TargetInfo = %addr(temp) + %size(temp);
         %subst(temp_targetInfo: 1: length) = %subst(targetInfo: 1: length);

         serverChallenge = i_NtLmChallenge.challenge;
         NTLMResponse =
            computeResponse(
               i_respKeyNT: serverChallenge: tempBuffer: tempLength);

         dealloc(N) pTemp;

         return NTLMResponse;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Creates the NTLMv2 response for the supplied information.
      *=====================================================================*
      *  Corresponds to JCIFS method:   NtlmPasswordAuthentication.computeResponse
      *=====================================================================*
     P computeResponse...
     P                 B                   export
     D                 PI                         like(ntlm_ntlmResponse_t)
     D  i_respKeyNT                        const  like(MD5_digest_t     )
     D  i_serverChallenge...
     D                                     const  like(ntlm_challenge_t )
     D  i_clientData               2048A   const
     D  i_length                     10I 0 const
      *
      *  Return value
     D NTLMResponse    S                   like(ntlm_ntlmResponse_t) inz
      *
      *  Local fields
     D hmac            S                   like(MD5_digest_t ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         hmac = MD5Hmac(i_respKeyNT: i_serverChallenge +
                                     %subst(i_clientData: 1: i_length));

         NTLMResponse = hmac + %subst(i_clientData: 1: i_length);

         return %subst(NTLMResponse: 1: %len(hmac) + i_length);

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Calculate the 'ResponseKeyLM' as described in document
      *  'NT LAN Manager (NTLM) Authentication Protocol Specification'.
      *=====================================================================*
     P LMOWFv1...
     P                 B
     D                 PI            16A
     D  i_password                         const  like(ntlm_password_t )
     D                                            options(*varsize)
      *
      *  Return value
     D responseKeyLM   DS            16    qualified
     D  first                         8A   inz(*ALLx'00')
     D  second                        8A   inz(*ALLx'00')
      *
      *  Local fields
     D password        S                   like(i_password  ) inz
      *
     D tmpKey          DS            21    qualified
     D  first                         7A   inz(*ALLx'00')
     D  second                        7A   inz(*ALLx'00')
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         responseKeyLM = *ALLx'00';

         if (%len(i_password) = 0);
            return responseKeyLM;
         endif;

         password = toAscii(toUpper(i_password));

         tmpKey = *ALLx'00';
         if (password <> '');
            %subst(tmpKey: 1: %len(password)) =
                  %subst(password: 1: %len(password));
         endif;

         responseKeyLM.first = des(ASCII_STRING: DES_produceKey(tmpKey.first ));
         responseKeyLM.second= des(ASCII_STRING: DES_produceKey(tmpKey.second));

         return responseKeyLM;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Calculate the 'ResponseKeyNT' as described in document
      *  'NT LAN Manager (NTLM) Authentication Protocol Specification'.
      *=====================================================================*
     P NTOWFv1...
     P                 B                   export
     D                 PI                         like(MD4_digest_t    )
     D  i_password                         const  like(ntlm_password_t )
     D                                            options(*varsize)
      *
      *  Return value
     D digest          S                   like(MD4_digest_t ) inz(*ALLx'00')
      *
      *  Local fields
     D password        S                   like(i_password  ) inz
     D md4_digest      S                   like(MD4_digest_t) inz
     D hmac            S                   like(MD5_digest_t) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (%len(i_password) = 0);
            return digest;
         endif;

         password = varstringLE(toUnicode(i_password));

         md4_digest = md4(password);

         digest = md4_digest;

         return digest;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Calculate the key used in NTLM v2 authentication.
      *=====================================================================*
      *  Corresponds to JCIFS method:   NtlmPasswordAuthentication.NTOWFv2
      *=====================================================================*
     P NTOWFv2...
     P                 B                   export
     D                 PI                         like(MD5_digest_t    )
     D  i_password                         const  like(ntlm_password_t )
     D                                            options(*varsize)
     D  i_user                             const  like(ntlm_user_t     )
     D                                            options(*varsize)
     D  i_domain                           const  like(ntlm_domain_t   )
     D                                            options(*varsize)
      *
      *  Return value
     D digest          S                   like(MD5_digest_t ) inz(*ALLx'00')
      *
      *  Local fields
     D password        S                   like(i_password  ) inz
     D user            S                   like(i_user      ) inz
     D domain          S                   like(i_domain    ) inz
     D md4_digest      S                   like(MD4_digest_t) inz
     D hmac            S                   like(MD5_digest_t) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (%len(i_password) = 0);
            return digest;
         endif;

         password = varstringLE(toUnicode(i_password));
         user = varstringLE(toUnicode(toUpper(i_user)));
         domain = varstringLE(toUnicode(i_domain));

         md4_digest = md4(password);
         hmac = MD5Hmac(md4_digest: user + domain);

         digest = hmac;

         return digest;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Parses a given URL.
      *=====================================================================*
     P parseUrl...
     P                 B
     D                 PI
     D   i_URL                    32767A   const  varying options(*varsize)
     D   o_service                   32A          varying
     D   o_host                     256A          varying
      *
      *  Return value
     D URL             S                   like(i_URL) inz
      *
      *  Local fields
     D service         S             32A
     D user            S             32A
     D passwd          S             32A
     D host            S            256A
     D port            S             10I 0
     D path            S          32767A   varying
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         http_long_ParseURL(i_URL: service: user: passwd: host: port: path);

         o_service = service;
         o_host = host;

         return;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Returns cTrue if the specified message matches a given type.
      *=====================================================================*
     P isMessageTypeOf...
     P                 B
     D                 PI              N
     D  i_message                          const  like(ntlm_message_t    )
     D                                            options(*varsize)
     D  i_type                             const  like(NtlmMessage_t.type)
      *
      *  Local fields
     D type            S                   like(NtlmMessage_t.type) inz
     D tmpMessage      DS                  likeds(NtLmMessage_t   ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (%len(i_message) < %len(NtLmMessage_t));
            return cFalse;
         endif;

         tmpMessage = %subst(i_message: 1: %len(i_message));

         type = uint32LE(tmpMessage.type);

         if (type <> i_type);
            return cFalse;
         endif;

         return cTrue;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Returns the specified target information of a given Type-2 message.
      *=====================================================================*
     P getTargetInfo...
     P                 B
     D                 PI                         like(ntlm_targetName_t)
     D  i_NtLmChallenge...
     D                                            likeds(NtLmChallenge_t)
     D  i_type                        5I 0 const
      *
      *  Return value
     D targetInfo      DS                  likeds(targetNameChars_t)
      *
      *  Local fields
     D type            S              5I 0 inz
     D length          S              5I 0 inz
     D offset          S             10I 0 inz
     D pNtLmChallenge  S               *   inz
      *
     D tmpTargetInfo   DS                  likeds(targetInfo_t )
     D                                     based(pTmpTargetInfo)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE
                                                                                           //R
         // Get length and offset of target info
         length = uint16LE(i_NtLmChallenge.targetInfo.length);
         offset = uint32LE(i_NtLmChallenge.targetInfo.offset);

         if (length = 0);
            return u'';
         endif;

         // Go to the first target information block
         pNtLmChallenge = %addr(i_NtLmChallenge);
         pTmpTargetInfo = pNtLmChallenge + offset;

         // Spin through the target information blocks
         type = uint16LE(tmpTargetInfo.type);
         dow (type <> 0);
            length = uint16LE(tmptargetInfo.length);
            if (type <> i_type);
               pTmpTargetInfo = pTmpTargetInfo + length +                                   //RADDAT
                                %size(tmpTargetInfo.type) +                                 //RADDAT
                                %size(tmpTargetInfo.length);
               type = uint16LE(tmptargetInfo.type);
            else;
               targetInfo = stringLE(tmpTargetInfo.value: length);
               return %subst(targetInfo.unicode: 1: %int(length/2));
            endif;
         enddo;

         return u'';

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Serializes a type 1 message to a byte array.
      *=====================================================================*
      *  Corresponds to JCIFS method:   Type1Message.toByteArray
      *=====================================================================*
     P Type1_toByteArray...
     P                 B
     D                 PI                         like(ntlm_message_t )
     D  i_type1                                   likeds(type1_t )
      *
      *  Return value
     D message         S                   like(ntlm_message_t ) inz(*ALLx'00')
      *
      *  Local fields
     D isUnicode       S               N   inz(cTrue)
     D isHostInfo      S               N   inz(cFalse)
     D domain          S                   like(i_type1.domain      ) inz
     D workstation     S                   like(i_type1.workstation ) inz
     D length          S             10I 0 inz
     D NtLmNegotiate...
     D                 DS                  likeds(NtLmNegotiate_t)
     D                                     based(pNtLmNegotiate)
     D offset          S             10I 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         isUnicode = isBit(i_type1.flags: NTLMSSP_NEGOTIATE_UNICODE);

         if (%len(i_type1.domain) > 0);
            domain = toAscii(i_type1.domain);
            isHostInfo = cTrue;
         endif;

         if (%len(i_type1.workstation) > 0);
            workstation = toAscii(i_type1.workstation);
            isHostInfo = cTrue;
         endif;

         if (isHostInfo);
            length = 32 + %len(domain) + %len(workstation);
         else;
            length = 16;
         endif;

         pNtLmNegotiate = %addr(message)+2;

         NtLmNegotiate.signature = NTLMSSP_SIGNATURE;
         NtLmNegotiate.type      = uint32LE(NEGOTIATE_MESSAGE);

         if (isHostInfo);
            offset = 32;
            NtLmNegotiate.domain = writeSecurityBuffer(message: offset: domain);
            NtLmNegotiate.workstation = writeSecurityBuffer(
                                           message: offset: workstation);
         endif;

         NtLmNegotiate.flags = uint32LE(i_type1.flags);

         return %subst(message: 1: length);

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Serializes a type 3 message to a byte array.
      *=====================================================================*
      *  Corresponds to JCIFS method:   Type3Message.toByteArray
      *=====================================================================*
     P Type3_toByteArray...
     P                 B
     D                 PI                         like(ntlm_message_t )
     D  i_type3                                   likeds(type3_t )
      *
      *  Return value
     D message         S                   like(ntlm_message_t ) inz(*ALLx'00')
      *
      *  Local fields
     D isUnicode       S               N   inz(cTrue)
     D domain          S                   like(i_type3.domain      ) inz
     D user            S                   like(i_type3.user        ) inz
     D workstation     S                   like(i_type3.workstation ) inz
     D length          S             10I 0 inz
     D NtLmAuthenticate...
     D                 DS                  likeds(NtLmAuthenticate_t)
     D                                     based(pNtLmAuthenticate)
     D offset          S             10I 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         isUnicode = isBit(i_type3.flags: NTLMSSP_NEGOTIATE_UNICODE);

         if (%len(i_type3.domain) > 0);
            domain = transcode(i_type3.domain: isUnicode);
         endif;

         if (%len(i_type3.user) > 0);
            if (isUnicode);
               user = transcode(i_type3.user: isUnicode);
            else;
               user = transcode(toUpper(i_type3.user): isUnicode);
            endif;
         endif;

         if (%len(i_type3.workstation) > 0);
            if (isUnicode);
               workstation = transcode(i_type3.workstation: isUnicode);
            else;
               workstation = transcode(toUpper(i_type3.workstation): isUnicode);
            endif;
         endif;

         if (isUnicode);
            domain = varstringLE(domain);
            user = varstringLE(user);
            workstation = varstringLE(workstation);
         endif;

         length = 64 + %len(domain) + %len(user) + %len(workstation) +
                  %len(i_type3.lmResponse) + %len(i_type3.ntResponse) +
                  %len(i_type3.sessionKey);

         pNtLmAuthenticate = %addr(message)+2;

         NtLmAuthenticate.signature   = NTLMSSP_SIGNATURE;
         NtLmAuthenticate.type        = uint32LE(AUTHENTICATE_MESSAGE);

         offset = 64;
         NtLmAuthenticate.LM_resp     = writeSecurityBuffer(
                                           message: offset: i_type3.lmResponse);
         NtLmAuthenticate.NTLM_resp   = writeSecurityBuffer(
                                           message: offset: i_type3.ntResponse);
         NtLmAuthenticate.targetName  = writeSecurityBuffer(
                                           message: offset: domain);
         NtLmAuthenticate.userName    = writeSecurityBuffer(
                                           message: offset: user);
         NtLmAuthenticate.workstation = writeSecurityBuffer(
                                           message: offset: workstation);
         NtLmAuthenticate.sessionKey  = writeSecurityBuffer(
                                           message: offset: i_type3.sessionKey);
         NtLmAuthenticate.flags       = uint32LE(i_type3.flags);

         return %subst(message: 1: length);

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Return the NTLM message signature.
      *=====================================================================*
     P NTLMSSP_SIGNATURE...
     P                 B
     D                 PI                         like(NtLmMessage_t.signature)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         return toAscii('NTLMSSP' + x'00');

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Writes a security buffer.
      *=====================================================================*
      *  Corresponds to JCIFS method:   NtlmMessage.writeSecurityBuffer
      *=====================================================================*
     P writeSecurityBuffer...
     P                 B
     D                 PI                         likeds(ntlm_securityBuffer_t)
     D  io_message                                like(ntlm_message_t )
     D                                            options(*varsize)
     D  io_offset                    10I 0
     D  i_data                     2048A   const  varying options(*varsize)
      *
      *  Return value
     D securityBuffer  DS                  likeds(ntlm_securityBuffer_t ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (%len(i_data) = 0);
            return securityBuffer;
         endif;

         securityBuffer.length = uint16LE(%len(i_data));
         securityBuffer.maxLen = uint16LE(%len(i_data));
         securityBuffer.offset = uint32LE(io_offset);

         %subst(io_message: io_offset+1: %len(i_data)) = i_data;

         io_offset = io_offset + %len(i_data);

         return securityBuffer;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Converts a given EBCDIC string to UNICODE or ASCII.
      *=====================================================================*
     P transcode...
     P                 B
     D                 PI          4096A          varying
     D  i_ebcdic                   2048A   const  varying
     D  i_isUnicode                    N   const
      *
      *  Return value
     D transcoded      S           4096A   varying inz
      *
      *  Local fields
     D hTranscoder     S                   like(hTranscoder_t ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (%len(i_ebcdic) = 0);
            return '';
         endif;

         if (i_isUnicode);
            transcoded = toUnicode(i_ebcdic);
         else;
            transcoded = toAscii(i_ebcdic);
         endif;

         return transcoded;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Returns the default domain name of the i5 computer.
      *=====================================================================*
      *  Corresponds to JCIFS method:   Type3Message.getDefaultDomain
      *                     property:   jcifs.smb.client.domain
      *=====================================================================*
     P getDefaultDomain...
     P                 B
     D                 PI                         like(ntlm_domain_t )
      *
      *  Return value
     D domain          S                   like(ntlm_domain_t ) inz
      *
      *  Local fields
     D rcvVar          S            256A   inz
     D attributes      DS                  likeds(QWCRNETA_returned)
     D                                     based(pAttributes)
     D attr            DS                  likeds(QWCRNETA_attr)
     D                                     based(pAttr)
     D errCode         DS                  likeds(errCode_t) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         pAttributes = %addr(rcvVar);
         clear errCode;

         QWCRNETA(rcvVar: %size(rcvVar): 1: 'NWSDOMAIN': errCode);

         pAttr = pAttributes + attributes.offsAttr;
         domain = %subst(attr.data_char: 1: attr.length);

         return domain;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Returns the default workstation name of the i5 computer.
      *=====================================================================*
      *  Corresponds to JCIFS method:   Type3Message.getDefaultWorkstation
      *  Instead of returning the host name, this method returns the name
      *  of the current job.
      *=====================================================================*
     P getDefaultWorkstation...
     P                 B
     D                 PI                         like(ntlm_workstation_t )
      *
      *  Return value
     D workstation     S                   like(ntlm_workstation_t ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (g_isTestMode);
            return 'WORKSTATION';
         endif;

         workstation = sds.job;

         return workstation;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Returns the default flags for a all messages.
      *=====================================================================*
     P getDefaultFlags...
     P                 B
     D                 PI            10U 0
      *
      *  Return value
     D flags           S             10U 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         // Default flags as used by Firefox
         // See: http://mxr.mozilla.org/mozilla/source/
         //      security/manager/ssl/src/nsNTLMAuthModule.cpp
         // Note: We do not yet support NTLMSSP_NEGOTIATE_ALWAYS_SIGN
         flags = NTLMSSP_NEGOTIATE_UNICODE   +
                 NTLMSSP_NEGOTIATE_OEM       +
                 NTLMSSP_REQUEST_TARGET      +
                 NTLMSSP_NEGOTIATE_NTLM;

         select;
         when (g_LMCompatibility = LM_MODE_NTLM_V1);            // NTLMv1
            flags = flags + NTLMSSP_NEGOTIATE_NT_ONLY                                       //RADDAT
                          + NTLMSSP_NEGOTIATE_NTLM2;

         when (g_LMCompatibility = LM_MODE_NTLM_V1_NO_LM);      // NTLMv1 (no LM response)
            flags = flags + NTLMSSP_NEGOTIATE_NT_ONLY
                          + NTLMSSP_NEGOTIATE_NTLM2;

         when (g_LMCompatibility = LM_MODE_NTLM_V1_NTLM2_ONLY); // NTLMv1 (NTLM2 only)
            flags = flags + NTLMSSP_NEGOTIATE_NTLM2;

         when (g_LMCompatibility = LM_MODE_NTLM_V2);            // NTLMv2

         endsl;

         // Set flags to match the flags at:
         // http://davenport.sourceforge.net/ntlm.html#type3MessageExample
         if (g_isTestMode);
            flags = NTLMSSP_NEGOTIATE_UNICODE   +
                    NTLMSSP_NEGOTIATE_NTLM;
         endif;

         return flags;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Returns the default flags for a Type-1 message.
      *=====================================================================*
      *  Corresponds to JCIFS method:   Type1Message.getDefaultFlags
      *  This method has been changed to emulate the way Firefox
      *  does NTLM authentication.
      *=====================================================================*
     P getDefaultFlagsType1...
     P                 B
     D                 PI            10U 0
      *
      *  Return value
     D flags           S             10U 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         flags = getDefaultFlags();

         return flags;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Returns the default flags for a Type-3 message.
      *=====================================================================*
      *  Corresponds to JCIFS method:   Type3Message.getDefaultFlags
      *  This method has been changed to emulate the way Firefox
      *  does NTLM authentication.
      *=====================================================================*
     P getDefaultFlagsType3...
     P                 B
     D                 PI            10U 0
     D  i_NtLmChallenge...
     D                                            likeds(NtLmChallenge_t)
     D                                            options(*varsize: *nopass)
      *
      *  Return value
     D flags           S             10U 0 inz
      *
      *  Parameter positions
     D p_NtLmChallenge...
     D                 C                   1
      *
      *  Local fields
     D type2Flags      S             10U 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         flags = getDefaultFlags();

         if (%parms() < p_NtLmChallenge);
            if (g_preferUnicode);
               return %bitor(flags: NTLMSSP_NEGOTIATE_UNICODE);
            else;
               return %bitor(flags: NTLMSSP_NEGOTIATE_OEM);
            endif;
         endif;

         type2Flags = uint32LE(i_NtLmChallenge.flags);

         flags = bitand(type2Flags: getDefaultFlagsType1());

         return flags;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Returns an EBCDIC to ASCII transcoder.
      *=====================================================================*
     P getTranscoderToAscii...
     P                 B
     D                 PI                         like(hTranscoder_t )
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (Transcoder_isNull(g_htoAscii));
            g_hToAscii = Transcoder_new(850: 0);
         endif;

         return g_hToAscii;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Returns an EBCDIC to UNICODE transcoder.
      *=====================================================================*
     P getTranscoderToUnicode...
     P                 B
     D                 PI                         like(hTranscoder_t )
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (Transcoder_isNull(g_htoUnicode));
            g_hToUnicode = Transcoder_new(1200: 0);
         endif;

         return g_hToUnicode;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Converts a given EBCDIC string to ASCII.
      *=====================================================================*
     P toAscii...
     P                 B                   export
     D                 PI          2048A          varying
     D  i_ebcdic                   2048A   const  varying
      *
      *  Return value
     D ascii           S           2048A   varying inz
      *
      *  Local fields
     D hToAscii        S                   like(hTranscoder_t ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (%len(i_ebcdic) = 0);
            return '';
         endif;

         hToAscii = getTranscoderToAscii();
         ascii = Transcoder_xlateString(hToAscii: i_ebcdic);

         return ascii;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Not yet in use ***
      *  Frees the resources allocated by the ASCII transcoder.
      *=====================================================================*
     P freeAsciiTranscoder...
     P                 B
     D                 PI
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (not Transcoder_isNull(g_htoAscii));
            Transcoder_delete(g_hToAscii);
         endif;

         return;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Converts a given EBCDIC string to UNICODE.
      *=====================================================================*
     P toUnicode...
     P                 B                   export
     D                 PI          4096A          varying
     D  i_ebcdic                   2048A   const  varying
      *
      *  Return value
     D unicode         S           4096A   varying inz
      *
      *  Local fields
     D hToUnicode      S                   like(hTranscoder_t ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (%len(i_ebcdic) = 0);
            return '';
         endif;

         hToUnicode = getTranscoderToUnicode();
         unicode = Transcoder_xlateString(hToUnicode: i_ebcdic);

         return unicode;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Frees the resources allocated by the UNICODE transcoder.
      *=====================================================================*
     P freeUnicodeTranscoder...
     P                 B                   export
     D                 PI
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (not Transcoder_isNull(g_htoUnicode));
            Transcoder_delete(g_hToUnicode);
         endif;

         return;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Sets the C runtime error number to ZERO (no error).
      *=====================================================================*
     P c_clearErrno...
     P                 B
     D                 PI
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         c_errno(0);

         return;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Sets and returns the C runtime error number.
      *=====================================================================*
     P c_errno...
     P                 B
     D                 PI            10I 0
     D  i_errno                      10I 0 const  options(*nopass)
      *
      *  Parameter positions
     D p_errno         C                   1
      *
      *  Local fields
     D runTimeError    S             10I 0 based(pRunTimeError)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         pRunTimeError = errno();

         if (%parms() >= p_errno);
            runTimeError = i_errno;
         endif;

         return runTimeError;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Returns the message text of a C runtime error number.
      *=====================================================================*
     P c_strerror...
     P                 B
     D                 PI           128A          varying
     D  i_errno                      10I 0 const
      *
      *  Return value
     D errText         S            128A   inz  varying
      *
      *  Local fields
     D pErrText        S               *   inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         pErrText = strerror(i_errno);
         if   pErrText = *NULL;
            errText = '';
         else;
            errText = %str(pErrText);
         endif;

         return   errText;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Returns cTrue if the specified bit is set.
      *=====================================================================*
     P isBit...
     P                 B                   export
     D                 PI              N
     D  i_value                      20U 0 const
     D  i_bit                        20U 0 const
      *
      *  Return value
     D isSet           S               N   inz(cFalse)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (i_value = 0);
            isSet = cFalse;
         else;
            isSet = (bitand(i_value: i_bit) = i_bit);
         endif;

         return isSet;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by ENCRYPTR4, RPGUNIT tests ***
    R *  Backward compatibility to V5R1.
      *  Returns the bit-wise ANDing of the bits of all the arguments.
      *=====================================================================*
     P bitand...
     P                 B                   export
     D                 PI            20U 0
     D  i_source1                    20U 0 value
     D  i_source2                    20U 0 value
      *
      *  Return value
     D result          S             20U 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         ANDSTR(%addr(result)
                : %addr(i_source1): %addr(i_source2): %size(i_source2));

         return result;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by ENCRYPTR4, RPGUNIT tests ***
    R *  Backward compatibility to V5R1.
      *  Returns the bit-wise ANDing of the bits of all the arguments.
      *=====================================================================*
     P byteand...
     P                 B                   export
     D                 PI             1A
     D  i_source1                     1A   value
     D  i_source2                     1A   value
      *
      *  Return value
     D result          S              1A   inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         ANDSTR(%addr(result)
                : %addr(i_source1): %addr(i_source2): %size(i_source2));

         return result;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
    R *  Backward compatibility to V5R1.
      *  Returns the bit-wise ORing of the bits of all the arguments.
      *=====================================================================*
     P bitor...
     P                 B                   export
     D                 PI            20U 0
     D  i_source1                    20U 0 value
     D  i_source2                    20U 0 value
      *
      *  Return value
     D result          S             20U 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         ORSTR(%addr(result)
               : %addr(i_source1): %addr(i_source2): %size(i_source2));

         return result;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by ENCRYPTR4, RPGUNIT tests ***
    R *  Backward compatibility to V5R1.
      *  Returns the bit-wise ANDing of the bits of all the arguments.
      *=====================================================================*
     P byteor...
     P                 B                   export
     D                 PI             1A
     D  i_source1                     1A   value
     D  i_source2                     1A   value
      *
      *  Return value
     D result          S              1A   inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         ORSTR(%addr(result)
               : %addr(i_source1): %addr(i_source2): %size(i_source2));

         return result;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Sends an ESCAPE message to kill the application.
      *=====================================================================*
     P kill...
     P                 B
     D                 PI
     D  i_text                      128A   const  varying
      *
      *  Local fields
     D msgKey          S              4A                        inz
      *
     D qMsgF           DS                  qualified            inz
     D  name                         10A
     D  lib                          10A
      *
     D errCode         DS                  qualified            inz
     D  bytPrv                       10I 0
     D  bytAvl                       10I 0
      *
      *  Send Program Message (QMHSNDPM) API
     D QMHSNDPM        PR                         extpgm('QMHSNDPM')
     D   i_msgID                      7A   const
     D   i_qMsgF                     20A   const
     D   i_msgData                32767A   const  options(*varsize )
     D   i_length                    10I 0 const
     D   i_msgType                   10A   const
     D   i_callStkE               32767A   const  options(*varsize )
     D   i_callStkC                  10I 0 const
     D   o_msgKey                     4A
     D   io_ErrCode               32767A          options(*varsize )
     D   i_lenStkE                   10I 0 const  options(*nopass  )
     D   i_callStkEQ                 20A   const  options(*nopass  )
     D   i_wait                      10I 0 const  options(*nopass  )
     D   i_callStkEDT                10A   const  options(*nopass  )
     D   i_ccsid                     10I 0 const  options(*nopass  )
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         clear qMsgF;
         qMsgF.name = 'QCPFMSG';
         qMsgF.lib  = '*LIBL';

         clear errCode;
         errCode.bytPrv = %size(errCode);

         QMHSNDPM('CPF9898': qMsgF: i_text: %len(i_text): '*ESCAPE'
                  : '*': 1: msgKey: errCode);

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Converts a 2-byte integer to little-endian format.
      *=====================================================================*
     P uint16LE...
     P                 B                   export
     D                 PI             5U 0
     D  i_int2                        5U 0 const
      *
      *  Return value
     D rtn             DS                  qualified
     D  int2                          5U 0
     D  byte1                  1      1U 0
     D  byte2                  2      2U 0
      *
      *  Local fields
     D input           DS                  qualified
     D  int2                          5U 0
     D  byte1                  1      1U 0
     D  byte2                  2      2U 0
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         input.int2 = i_int2;

         rtn.byte1 = input.byte2;
         rtn.byte2 = input.byte1;

         return rtn.int2;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Converts a 4-byte integer to little-endian format.
      *=====================================================================*
     P uint32LE...
     P                 B                   export
     D                 PI            10U 0
     D  i_int4                       10U 0 const
      *
      *  Return value
     D rtn             DS                  qualified
     D  int4                         10U 0
     D  byte1                  1      1U 0
     D  byte2                  2      2U 0
     D  byte3                  3      3U 0
     D  byte4                  4      4U 0
      *
      *  Local fields
     D input           DS                  qualified
     D  int4                         10U 0
     D  byte1                  1      1U 0
     D  byte2                  2      2U 0
     D  byte3                  3      3U 0
     D  byte4                  4      4U 0
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         input.int4 = i_int4;

         rtn.byte1 = input.byte4;
         rtn.byte2 = input.byte3;
         rtn.byte3 = input.byte2;
         rtn.byte4 = input.byte1;

         return rtn.int4;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Converts a 8-byte integer to little-endian format.
      *=====================================================================*
     P uint64LE...
     P                 B                   export
     D                 PI            20U 0
     D  i_int8                       20U 0 const
      *
      *  Return value
     D rtn             DS                  qualified
     D  int8                         20U 0
     D  byte1                  1      1U 0
     D  byte2                  2      2U 0
     D  byte3                  3      3U 0
     D  byte4                  4      4U 0
     D  byte5                  5      5U 0
     D  byte6                  6      6U 0
     D  byte7                  7      7U 0
     D  byte8                  8      8U 0
      *
      *  Local fields
     D input           DS                  qualified
     D  int8                         20U 0
     D  byte1                  1      1U 0
     D  byte2                  2      2U 0
     D  byte3                  3      3U 0
     D  byte4                  4      4U 0
     D  byte5                  5      5U 0
     D  byte6                  6      6U 0
     D  byte7                  7      7U 0
     D  byte8                  8      8U 0
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         input.int8 = i_int8;

         rtn.byte1 = input.byte8;
         rtn.byte2 = input.byte7;
         rtn.byte3 = input.byte6;
         rtn.byte4 = input.byte5;
         rtn.byte5 = input.byte4;
         rtn.byte6 = input.byte3;
         rtn.byte7 = input.byte2;
         rtn.byte8 = input.byte1;

         return rtn.int8;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Converts a string value to little-endian format.
      *=====================================================================*
     P stringLE...
     P                 B                   export
     D                 PI          1024A          varying
     D  i_string                   1024A          options(*varsize)
     D  i_length                     10I 0 const
      *
      *  Return value
     D rtn             S           1024A   varying inz
      *
      *  Local fields
     D x               S             10I 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         %len(rtn) = i_length;

         for x = 2 to i_length by 2;
            %subst(rtn: x-1: 1) = %subst(i_string:x   : 1);
            %subst(rtn: x  : 1) = %subst(i_string:x-1 : 1);
         endfor;

         return rtn;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Converts a string value to little-endian format.
      *=====================================================================*
     P varstringLE...
     P                 B                   export
     D                 PI          1024A          varying
     D  i_string                   1024A   const  varying options(*varsize)
      *
      *  Return value
     D rtn             S           1024A   varying inz
      *
      *  Local fields
     D x               S             10I 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         %len(rtn) = %len(i_string);

         for x = 2 to %len(i_string) by 2;
            %subst(rtn: x-1: 1) = %subst(i_string:x   : 1);
            %subst(rtn: x  : 1) = %subst(i_string:x-1 : 1);
         endfor;

         return rtn;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Returns a random 8-byte challenge.
      *=====================================================================*
     P random...
     P                 B                   export
     D                 PI                  opdesc
     D  o_random                    128A          options(*varsize)
     D  i_isTestMode                   N   const  options(*nopass)
      *
      *  Parameter positions
     D p_random        C                   1
     D p_isTestMode    C                   2
      *
      *  Optional parameter fields
     D isTestMode      S                   like(i_isTestMode) inz
      *
      *  Local fields
     D isInit          S               N   inz(cFalse) static
     D randInf         DS                  likeds(strInf_t ) inz
     D offs            S             10I 0 inz
     D i               S              3U 0 inz
     D p               S              3U 0 inz
      *
     D randNum         DS                  qualified
     D  int4                   1      4U 0
     D  chars                  3      4A
     D  int1                   3      4U 0 dim(2)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (%parms() >= p_isTestMode);
            isTestMode = i_isTestMode;
         else;
            isTestMode = cFalse;
         endif;

         if (not isInit);
            srand(time(*null));
            isInit = cTrue;
         endif;

         CEEGSI(p_random: randInf.dataType
                : randInf.curlen: randInf.maxLen: *omit);

         // rand() returns a number between 0 and RAND_MAX (qsysinc/h.stdlib)
         // where RAND_MAX is 32767.
         offs = 0;
         i = 1;
         dow (offs < randInf.curlen);
            if (not isTestMode);
               randNum.int4 = rand();
            else;
               for p = 1 to %size(randNum.chars);
                  randNum.int1(p) = i;
                  i = i + 1;
               endfor;
            endif;

            if (offs + %size(randNum.chars) <= randInf.curlen);
               %subst(o_random: offs+1: %size(randNum.chars))= randNum.chars;
            else;
               %subst(o_random: offs+1) = randNum.chars;
            endif;
            offs = offs + %size(randNum.chars);
         enddo;

         return;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Converts a given string to upper case.
      *=====================================================================*
     P toUpper...
     P                 B                   export
     D                 PI          1024A          varying
     D  i_string                   1024A   const  varying
      *
      *  Return value
     D upper           S           1024A   varying inz
      *
      *  Fields for QlgConvertCase API
     D tmpBuffer       S           1024A   inz
     D reqCtrlBlk      DS                  likeds(QLGCNVCS_reqCtrlBlk_t) inz
     D errCode         DS                  likeds(errCode_t ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (i_string = '');
            return i_string;
         endif;

         reqCtrlBlk.type  = CVTCASE_TYPE_CCSID;
         reqCtrlBlk.CCSID = CVTCASE_CCSID_JOB;
         reqCtrlBlk.case  = CVTCASE_TO_UPPER;
         reqCtrlBlk.reserved = *ALLx'00';
         clear errCode;
         QlgConvertCase(reqCtrlBlk:
                        i_string: tmpBuffer: %len(i_string): errCode);
         upper = %subst(tmpBuffer: 1: %len(i_string));

         return upper;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Converts a given string to lower case.
      *=====================================================================*
     P toLower...
     P                 B                   export
     D                 PI          1024A          varying
     D  i_string                   1024A   const  varying
      *
      *  Return value
     D lower           S           1024A   varying inz
      *
      *  Fields for QlgConvertCase API
     D tmpBuffer       S           1024A   inz
     D reqCtrlBlk      DS                  likeds(QLGCNVCS_reqCtrlBlk_t) inz
     D errCode         DS                  likeds(errCode_t ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (i_string = '');
            return i_string;
         endif;

         reqCtrlBlk.type  = CVTCASE_TYPE_CCSID;
         reqCtrlBlk.CCSID = CVTCASE_CCSID_JOB;
         reqCtrlBlk.case  = CVTCASE_TO_LOWER;
         reqCtrlBlk.reserved = *ALLx'00';
         clear errCode;
         QlgConvertCase(reqCtrlBlk:
                        i_string: tmpBuffer: %len(i_string): errCode);
         lower = %subst(tmpBuffer: 1: %len(i_string));

         return lower;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Encrypts an 8-byte data item D with the 16-byte key K using the
      *  Data Encryption Standard Long (DESL) algorithm.
      *  The result is 24 bytes in length.
      *=====================================================================*
     P desl...
     P                 B
     D                 PI            24A
     D  i_key                        16A   const
     D  i_data                        8A   const
      *
      *  Return value
     D digest          DS            24    qualified
     D  first                         8A   inz(*ALLx'00')
     D  second                        8A   inz(*ALLx'00')
     D  third                         8A   inz(*ALLx'00')
      *
      *  Local fields
     D tmpKey          DS            21    qualified
     D  first                         7A   inz(*ALLx'00')
     D  second                        7A   inz(*ALLx'00')
     D  third                         7A   inz(*ALLx'00')
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         %subst(tmpKey: 1: %len(i_key)) = i_key;
         digest.first  = des(i_data: DES_produceKey(tmpKey.first));
         digest.second = des(i_data: DES_produceKey(tmpKey.second));
         digest.third  = des(i_data: DES_produceKey(tmpKey.third));

         return digest;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Creates a byte array of length N. Each byte
      *  in the array is initialized to the value zero.
      *=====================================================================*
     P z...
     P                 B
     D                 PI           128A          varying
     D  i_n                          10I 0 const
      *
      *  Return value
     D zeroBytes       S            128A   varying inz(*ALLx'00')
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         %len(zeroBytes) = i_n;

         return zeroBytes;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Returns the current time in milliseconds.
      *=====================================================================*
     P getCurrentTimeMillis...
     P                 B
     D                 PI            20U 0
      *
      *  Return value
     D timeInMillis    S             20U 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         timeInMillis = time(*null) * 10000;

         return timeInMillis;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  Returns the next token from a list of tokens.
      *=====================================================================*
     P getToken...
     P                 B                   export
     D                 PI          2048A          varying
     D  i_tokens                   2048A   const  varying options(*omit)
     D  i_delimiters                 16A   const  varying
      *
      *  Return value
     D token           S           2048A   varying inz
      *
      *  Parameter positions
     D p_tokens        C                   1
      *
      *  Local fields
     D start           S             10I 0 inz
      *
      *  Local static fields
     D tokens          S                   like(i_tokens) inz  static
     D offs            S             10I 0 inz                 static
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (%parms() >= p_tokens and %addr(i_tokens) <> *NULL);
            tokens = i_tokens;
            offs = 0;
         endif;

         token = '';

         // Skip leading delimiters
         dow (offs < %len(tokens) and
              %scan(%subst(tokens: offs+1: 1): i_delimiters) > 0);
            offs = offs + 1;
         enddo;

         start = offs;

         // Get next token
         dow (offs < %len(tokens) and
              %scan(%subst(tokens: offs+1: 1): i_delimiters) = 0);
            offs = offs + 1;
         enddo;

         if (offs-start > 0);
            token = %subst(tokens: start+1: offs-start);
         endif;

         return token;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Appends a given buffer to the NULL device.
      *=====================================================================*
     P nullWrite...
     P                 B
     D                 PI            10I 0
     D  i_fd                         10I 0 value
     D  i_data                         *   value
     D  i_length                     10I 0 value
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         return i_length;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  base64_encode:  Encode binary data using Base64 encoding
      *
      *       Input = (input) pointer to data to convert
      *    InputLen = (input) length of data to convert
      *      Output = (output) pointer to memory to receive output
      *     OutSize = (input) size of area to store output in
      *
      *  Returns length of encoded data, or space needed to encode
      *      data. If this value is greater than OutSize, then
      *      output may have been truncated.
      *=====================================================================*
     P NTLM_Base64_encode...
     P                 B
     D                 PI            10U 0
     D   Input                         *   value
     D   InputLen                    10U 0 value
     D   Output                        *   value
     D   OutputSize                  10U 0 value

     D                 DS
     D   Numb                  1      2U 0 inz(0)
     D   Byte                  2      2A

     D data            DS                  based(Input)
     D   B1                           1A
     D   B2                           1A
     D   B3                           1A

     D OutData         S              4A   based(Output)
     D Temp            S              4A
     D Pos             S             10I 0
     D OutLen          S             10I 0
     D Save            s              1A

      /free

          Pos = 1;

          dow (Pos <= InputLen);

             // -------------------------------------------------
             // First output byte comes from bits 1-6 of input
             // -------------------------------------------------

             Byte = byteand(B1: x'FC');
             Numb /= 4;
             %subst(Temp:1) = base64f(Numb+1);

             // -------------------------------------------------
             // Second output byte comes from bits 7-8 of byte 1
             //                           and bits 1-4 of byte 2
             // -------------------------------------------------
             Byte = byteand(B1: x'03');
             Numb *= 16;

             if (Pos+1 <= InputLen);
                Save = Byte;
                Byte = byteand(B2: x'F0');
                Numb /= 16;
                Byte = %bitor(Save: Byte);
             endif;

             %subst(Temp: 2) = base64f(Numb+1);

             // -------------------------------------------------
             // Third output byte comes from bits 5-8 of byte 2
             //                          and bits 1-2 of byte 3
             // (or is set to '=' if there was only one byte)
             // -------------------------------------------------

             if (Pos+1 > InputLen);
                 %subst(Temp: 3) = '=';
             else;
                 Byte = byteand(B2: x'0F');
                 Numb *= 4;

                 if (Pos+2 <= InputLen);
                     Save = Byte;
                     Byte = byteand(B3: x'C0');
                     Numb /= 64;
                     Byte = %bitor(Save: Byte);
                 endif;

                 %subst(Temp:3) = base64f(Numb+1);
             endif;

             // -------------------------------------------------
             // Fourth output byte comes from bits 3-8 of byte 3
             // (or is set to '=' if there was only one/two bytes)
             // -------------------------------------------------

             if (Pos+2 > InputLen);
                 %subst(Temp:4:1) = '=';
             else;
                 Byte = byteand(B3: x'3F');
                 %subst(Temp:4) = base64f(Numb+1);
             endif;

             // -------------------------------------------------
             //   Advance to next chunk of data.
             // -------------------------------------------------

             Input += %size(data);
             Pos += %size(data);
             OutLen += %size(Temp);

             if (OutLen <= OutputSize);
                OutData = Temp;
                Output += %size(Temp);
             endif;

          enddo;

          return OutLen;

      /end-free
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  base64_decode: Decode base64 encoded data back to binary
      *
      *       Input = (input) pointer to base64 data to decode
      *    InputLen = (input) length of base64 data
      *      Output = (output) pointer to memory to receive output
      *     OutSize = (input) size of area to store output in
      *
      *  Returns length of decoded data, or space needed to decode
      *      data. If this value is greater than OutSize, then
      *      output may have been truncated.
      *=====================================================================*
     P NTLM_Base64_decode...
     P                 B
     D                 PI            10U 0
     D   Input                         *   value
     D   InputLen                    10U 0 value
     D   Output                        *   value
     D   OutputSize                  10U 0 value

     D                 DS
     D   Numb                  1      2U 0 inz(0)
     D   Byte                  2      2A

     D data            DS                  based(Input)
     D   B1                           3U 0
     D   B2                           3U 0
     D   B3                           3U 0
     D   B4                           3U 0

     D OutData         S              3A   based(Output)
     D temp            S              3A   varying
     D Pos             S             10I 0
     D OutLen          S             10I 0

      /free

          Pos = 1;

          dow (Pos <= InputLen);

             if (base64r(B1)=x'FF');
                 invalidChar(Pos:B1);
             endif;
             if (base64r(B2)=x'FF');
                 invalidChar(Pos+1:B2);
             endif;
             if (base64r(B3)=x'FF' and B3<>126);
                 invalidChar(Pos+2:B3);
             endif;
             if (base64r(B4)=x'FF' and B4<>126);
                 invalidChar(Pos+3:B4);
             endif;

             // -------------------------------------------------
             // First output byte comes from bits 3-8 of byte 1
             //                          and bits 3-4 of byte 2
             // -------------------------------------------------

             Numb = base64r(B1) * 4
                  + base64r(B2) / 16;
             Temp = Byte;

             // -------------------------------------------------
             // Second output byte comes from bits 5-8 of byte 2
             //                           and bits 3-6 of byte 3
             // -------------------------------------------------
             if %subst(data: 3: 1) <> '=';
                  numb = bitand(base64r(B2):x'0f') * 16
                       + base64r(B3) / 4;
                  Temp += Byte;
             endif;

             // -------------------------------------------------
             // Third output byte comes from bits 7-8 of byte 3
             //                          and bits 3-8 of byte 4
             // (or is set to '=' if there was only one byte)
             // -------------------------------------------------
             if %subst(data: 4: 1) <> '=';
                  numb = bitand(base64r(B3):x'03') * 64
                       + base64r(B4);
                  Temp += Byte;
             endif;

             // -------------------------------------------------
             //   Advance to next chunk of data.
             // -------------------------------------------------

             Input += %size(data);
             Pos += %size(data);
             OutLen += %len(Temp);

             if (OutLen <= OutputSize);
                OutData = Temp;
                Output += %len(Temp);
             endif;

          enddo;

          return OutLen;

      /end-free
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      * invalidChar(): Report an invalid input character
      *                in a fashion dramatic enough that people
      *                won't blame me when they provide invalid
      *                input characters|
      *=====================================================================*
     P invalidChar...
     P                 B
     D                 PI
     D   CharPos                     10i 0 value
     D   Char                         3u 0 value

     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                  32767a   Const options(*varsize)
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                 8192A   options(*varsize)

     D ErrorCode       DS                  qualified
     D  BytesProv              1      4I 0 inz(0)
     D  BytesAvail             5      8I 0 inz(0)

     D cvthc           PR                  ExtProc('cvthc')
     D   target                       2A   options(*varsize)
     D   src_bits                     3u 0 const
     D   tgt_length                  10I 0 value

     D Hex             s              2a
     D MsgKey          S              4A
     D MsgDta          s            100a   varying

      /free

         cvthc(hex:char:%size(hex));

         MsgDta = 'Unable to decode character at position '
                + %char(CharPos) + '. (Char=x''' + hex + ''')';

         QMHSNDPM( 'CPF9897'
                 : 'QCPFMSG   *LIBL'
                 : MsgDta
                 : %len(MsgDta)
                 : '*ESCAPE'
                 : '*PGMBDY'
                 : 2
                 : MsgKey
                 : ErrorCode         );

      /end-free
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Initializes character translation.
      *=====================================================================*
     P Transcoder_new...
     P                 B
     D                 PI                         like(hTranscoder_t )
     D  i_toCcsid                    10U 0 const
     D  i_fromCcsid                  10U 0 const
      *
      *  Return value
     D hTranscoder     S                   like(hTranscoder_t ) inz
      *
      *  Helper fields
     D toCode          DS                  likeds(QtqCode_t   ) inz
     D fromCode        DS                  likeds(QtqCode_t   ) inz
     D hIconv          DS                  likeds(iconv_t     ) inz
      *
      *  Transcoder handle
     D transcoder      DS                  likeds(transcoder_t )
     D                                     based(pTranscoder)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         clear fromCode;
         fromCode.ccsid         = i_fromCcsid;
         fromCode.conversionA   = 0;
         fromCode.substitutionA = 0;
         fromCode.shiftStateA   = 0;
         fromCode.inpLenOpt     = 0;
         fromCode.errOptMxdDta  = 1;
         fromCode.reserved      = *ALLx'00';

         clear toCode;
         toCode.ccsid         = i_toCcsid;
         toCode.conversionA   = 0;
         toCode.substitutionA = 0;
         toCode.shiftStateA   = 0;
         toCode.inpLenOpt     = 0;
         toCode.errOptMxdDta  = 0;
         toCode.reserved      =   *ALLx'00';

         hIconv = QtqIconv_open(toCode: fromCode);
         if (hIconv.return_value = -1);
            kill('Failed to initialize character: ' +
                  c_strerror(c_errno()));
         endif;

         pTranscoder = %alloc(%size(transcoder));

         clear transcoder;
         transcoder.fromCcsid = i_fromCcsid;
         transcoder.toCcsid   = i_toCcsid;
         transcoder.hIconv    = hIconv;

         hTranscoder = pTranscoder;

         return hTranscoder;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Translates a given varying string.
      *=========================================================================
      *  Parameters:
      *   i_hTranscoder - Handle of the character transcoder.
      *   i_string      - Varying field containing the input data.
      *   o_msg         - Optional. Error message.
      *
      *  Returns:
      *   string        - Varying field containing the translated data on
      *                   success, else an empty string.
      *=====================================================================*
     P Transcoder_xlateString...
     P                 B
     D                 PI         32767A   opdesc varying
     D  i_hTranscoder                      const  like(hTranscoder_t )
     D  i_string                  32767A   const  varying options(*varsize)
      *
      *  Return value
     D rtn             DS                  qualified
     D  string                    32767A   varying
     D  len                    1      2I 0
     D  data                   3  32767A
      *
      *  Helper fields
     D tRc             S             10U 0 inz
     D pInBuf          S               *   inz
     D pOutBuf         S               *   inz
      *
      *  Transcoder handle
     D transcoder      DS                  likeds(transcoder_t )
     D                                     based(i_hTranscoder)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         rtn.string = i_string;

         pInBuf  = %addr(rtn.data);
         pOutBuf = *NULL;

         tRc = performTranslation(i_hTranscoder
                                  : pInBuf
                                  : %len(i_string)
                                  : pOutBuf
                                  : %size(rtn.data));

         if (tRc = ICONV_ERROR);
            rtn.len = 0;
         else;
            rtn.len = tRc;
            memcpy2(%addr(rtn.data): pOutBuf: rtn.len);
         endif;

         if (pOutBuf <> *NULL);
            dealloc(N) pOutBuf;
         endif;

         return rtn.string;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Frees a given transcoder.
      *=========================================================================
      *  Parameters:
      *   io_hTranscoder - Handle of the character transcoder.
      *
      *  Returns:
      *   void
      *=====================================================================*
     P Transcoder_delete...
     P                 B
     D                 PI
     D  io_hTranscoder...
     D                                            like(hTranscoder_t )
      *
      *  Transcoder handle
     D transcoder      DS                  likeds(transcoder_t )
     D                                     based(io_hTranscoder)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         iconv_close(transcoder.hIconv);
         io_hTranscoder = Transcoder_null();

         return;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Returns cTrue if a given Transcoder handle is NULL.
      *=====================================================================*
     P Transcoder_isNull...
     P                 B
     D                 PI              N
     D  i_hTranscoder                      const  like(hTranscoder_t )
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (i_hTranscoder = Transcoder_null());
            return cTrue;
         else;
            return cFalse;
         endif;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Returns a Transcoder NULL-handle.
      *=====================================================================*
     P Transcoder_null...
     P                 B
     D                 PI                         like(hTranscoder_t )
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         return *NULL;

      /END-FREE
     P                 E
      *
      *=====================================================================*
    R *  *** private ***
      *  Performs charcater translation. Returns the length of the
      *  transcoded buffer.
      *=====================================================================*
     P performTranslation...
     P                 B
     D                 PI            10U 0
     D  i_hTranscoder                      const  like(hTranscoder_t )
     D  i_pInBuf                       *   value
     D  i_length                     10I 0 const
     D  o_pOutBuf                      *
     D  i_maxSize                    10I 0 const
      *
      *  Return value
     D length          S             10U 0 inz
      *
      *  Helper fields
     D rc              S             10U 0 inz
     D bytPrv          S             10U 0 inz
     D bytLeft         S             10U 0 inz
     D bufSize         S             10I 0 inz
     D pInBuf          S               *   inz
     D pOutBuf         S               *   inz
     D inpBuf          S          32767A   based(i_pInBuf)
     D extendSize      S             10I 0 inz
     D isMaxSize       S               N   inz(cFalse)
      *
      * No restriction of maximum buffer size
     D MAX_SIZE        C                   -1
      *
      *  Transcoder handle
     D transcoder      DS                  likeds(transcoder_t )
     D                                     based(i_hTranscoder)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         bytPrv    = i_length;
         bytLeft   = i_length;
         bufSize   = i_length;
         pInBuf    = i_pInBuf;
         length    = 0;

         if (o_pOutBuf = *NULL);
            o_pOutBuf = %alloc(bufSize);
         else;
            kill('o_pOutBuf must be *NULL');
         endif;

         if (i_maxSize = -1);
            isMaxSize = cFalse;
         else;
            isMaxSize = cTrue;
         endif;

         c_clearErrno();
         dou (rc <> ICONV_ERROR) or (c_errno() <> E2BIG_C or
              (isMaxSize and bufSize >= i_maxSize));

            if (c_errno() = E2BIG_C);
               if (isMaxSize and bufSize >= i_maxSize);
                  leave;
               endif;
               if (pInBuf = i_pInBuf);
                  // No bytes have been transcoded. Reset values.
                  bytPrv  = i_length;
                  bytLeft = bufSize;
                  length  = 0;
               endif;
               extendSize = bytPrv * 2;
               if (MAX_SIZE > 0 and extendSize > MAX_SIZE);
                  extendSize = MAX_SIZE - bufSize;
               endif;
               if (isMaxSize and (bufSize + extendSize) > i_maxSize);
                  extendSize = i_maxSize - bufSize;
               endif;
               bufSize   = bufSize + extendSize;
               bytLeft   = bytLeft + extendSize;
               o_pOutBuf = %realloc(o_pOutBuf: bufSize);
            endif;

            pOutBuf = o_pOutBuf + length;
            length = length + bytLeft;
            rc = iconv(transcoder.hIconv: pInBuf: bytPrv: pOutBuf: bytLeft);
            length = length - bytLeft;

         enddo;

         if (rc = ICONV_ERROR);
            length = rc;
            if (c_errno() = E2BIG_C);
               kill('Target buffer too small to hold result.');
            else;
               kill('Failed to transcode characters: ' +
                    c_strerror(c_errno()));
            endif;
         endif;

         return length;

      /END-FREE
     P                 E
      *
