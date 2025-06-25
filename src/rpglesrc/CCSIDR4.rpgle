     /*-                                                                            +
      * Copyright (c) 2005-2025 Scott C. Klement                                    +
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
      * CCSIDR4 -- routines to ASCII/EBCDIC translation
      */

     H NOMAIN
      /if defined(HAVE_SRCSTMT_NODEBUGIO)
     H OPTION(*SRCSTMT)
      /endif

      /define HTTP_ORIG_SOAPACTION
      /copy httpapi_h
      /copy private_h
      /copy errno_h

     D ToASCII         DS
     D   ICORV_A                     10I 0
     D   ICOC_A                      10I 0 dim(12)

     D ToEBCDIC        DS
     D   ICORV_E                     10I 0
     D   ICOC_E                      10I 0 dim(12)

     D xmlEBCDIC       DS
     D   ICORV_X                     10I 0
     D   ICOC_X                      10I 0 dim(12)

     D pToASCII        DS
     D   ICORV_PA                    10I 0
     D   ICOC_PA                     10I 0 dim(12)

     D pToEBCDIC       DS
     D   ICORV_PE                    10I 0
     D   ICOC_PE                     10I 0 dim(12)

     D dsFROM          DS
     D   from_ccsid                  10I 0
     D   from_ca                     10I 0  INZ(0)
     D   from_sa                     10I 0  INZ(0)
     D   from_ss                     10I 0  INZ(0)
     D   from_il                     10I 0  INZ(0)
     D   from_eo                     10I 0  INZ(0)
     D   from_r                       8A    INZ(*allx'00')

     D dsTO            DS
     D   to_ccsid                    10I 0
     D   to_ca                       10I 0  INZ(0)
     D   to_sa                       10I 0  INZ(0)
     D   to_ss                       10I 0  INZ(0)
     D   to_il                       10I 0  INZ(0)
     D   to_eo                       10I 0  INZ(0)
     D   to_r                         8A    INZ(*allx'00')

     D iconv_open      PR                  ExtProc('QtqIconvOpen')
     D                                     like(ToASCII)
     D   ToCode                            like(dsFrom)
     D   FromCode                          like(dsTo)

     D iconv           PR            10U 0 ExtProc('iconv')
     D   Descriptor                        like(ToASCII) value
     D   p_inbuf                       *
     D   in_left                     10U 0
     D   p_outbuf                      *
     D   out_left                    10U 0

     D iconv_close     PR            10I 0 extproc('iconv_close')
     D   cd                                like(ToASCII) value

     D EBCDIC          s             10I 0 inz(-1)
     D ASCII           s             10I 0 inz(-1)

     D xml_EBCDIC      s             10I 0 inz(-1)
     D xml_ASCII       s             10I 0 inz(-1)

     D TblXlate        PR            10I 0
     D   peSize                      10I 0 value
     D   peData                        *   value
     D   peDirection                  1A   const
     D CCSIDxlate      PR            10I 0
     D   peSize                      10I 0 value
     D   peData                        *   value
     D   peDirection                  1A   const
     D TblXlateDyn     PR            10I 0
     D   peSize                      10I 0 value
     D   peData                        *   value
     D   peDirection                  1A   const
     D   peOutput                      *
     D CCSIDXlateDyn   PR            10I 0
     D   peSize                      10I 0 value
     D   peData                        *   value
     D   peDirection                  1A   const
     D   peOutbuf                      *
     D xlate_symbols   PR            25a
     D BinaryCopy      PR            10I 0
     D   peSize                      10I 0 value
     D   peData                        *   value
     D   peOutbuf                      *

     D CCSIDs_Set      s              1A   inz(*OFF)
     D Xml_CCSID_Set   s              1A   inz(*OFF)
     D BinaryData      s              1A   inz(*OFF)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HTTP_SetCCSIDs():  Set the CCSIDs used for ASCII/EBCDIC
      *                    translation
      *
      *     pePostRem = (input) Remote CCSID of POST data
      *     pePostLoc = (input) Local CCSID of POST data
      *     peProtRem = (input) Remote CCSID of Protocol data
      *     peProtLoc = (input) Local CCSID of Protocol data
      *
      * Returns 0 if successful, -1 otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P HTTP_SetCCSIDs  B                   export
     D HTTP_SetCCSIDs  PI            10I 0
     D   pePostRem                   10I 0 value
     D   pePostLoc                   10I 0 value
     D   peProtRem                   10I 0 value options(*nopass)
     D   peProtLoc                   10I 0 value options(*nopass)

     D wwProtRem       s             10I 0
     D wwProtLoc       s             10I 0

     c                   if        %parms >= 3
     c                   eval      wwProtRem = peProtRem
     c                   else
     c                   eval      wwProtRem = HTTP_ASCII
     c                   endif

     c                   if        %parms >= 4
     c                   eval      wwProtLoc = peProtLoc
     c                   else
     c                   eval      wwProtLoc = HTTP_EBCDIC
     c                   endif

     c                   eval      p_global = getGlobalPtr()
     c                   eval      global.net_ccsid = pePostRem
     c                   eval      global.local_ccsid = pePostLoc

     c                   if        CCSIDs_Set = *ON
     c                   callp     iconv_close(PToASCII)
     c                   callp     iconv_close(PToEBCDIC)
     c                   callp     iconv_close(ToEBCDIC)
     c                   callp     iconv_close(ToASCII)
     c                   endif

     c                   eval      BinaryData = *off
     c                   if        pePostRem = pePostLoc
     c                   eval      BinaryData = *on
     c                   endif

     c                   if        BinaryData = *Off
     c                   eval      from_ccsid = pePostRem
     c                   eval      to_ccsid   = pePostLoc
     c                   eval      pToEBCDIC = iconv_open(dsTo: dsFrom)
     c                   if        ICORV_PE < 0
     c                   return    -1
     c                   endif
     c                   endif

     c                   if        BinaryData = *off
     c                   eval      from_ccsid = pePostLoc
     c                   eval      to_ccsid   = pePostRem
     c                   eval      pToASCII  = iconv_open(dsTo: dsFrom)
     c                   if        ICORV_PA < 0
     c                   callp     iconv_close(pToEBCDIC)
     c                   return    -1
     c                   endif
     c                   endif

     c                   eval      from_ccsid = wwProtRem
     c                   eval      to_ccsid   = wwProtLoc
     c                   eval      toEBCDIC = iconv_open(dsTo: dsFrom)

     c                   if        ICORV_E < 0
     c                   if        BinaryData = *off
     c                   callp     iconv_close(pToEBCDIC)
     c                   callp     iconv_close(pToASCII)
     c                   endif
     c                   return    -1
     c                   endif

     c                   eval      from_ccsid = wwProtLoc
     c                   eval      to_ccsid   = wwProtRem
     c                   eval      toASCII  = iconv_open(dsTo: dsFrom)

     c                   if        ICORV_A < 0
     c                   if        BinaryData = *off
     c                   callp     iconv_close(pToEBCDIC)
     c                   callp     iconv_close(pToASCII)
     c                   endif
     c                   callp     iconv_close(toEBCDIC)
     c                   return    -1
     c                   endif

     c                   eval      CCSIDs_set = *ON

     c                   eval      EBCDIC = wwProtLoc
     c                   eval      ASCII  = wwProtRem

     c                   callp     http_dmsg('New iconv() objects set, '
     c                                  + 'PostRem='
     c                                  + %trim(%editc(pePostRem:'L'))
     c                                  + '. PostLoc='
     c                                  + %trim(%editc(pePostLoc:'L'))
     c                                  + '. ProtRem='
     c                                  + %trim(%editc(wwProtRem:'L'))
     c                                  + '. ProtLoc='
     c                                  + %trim(%editc(wwProtLoc:'L')))

     c                   return    0
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HTTP_SetFileCCSID(): Set the CCSID that downloaded stream
      *                      files get tagged with
      *
      *     peCCSID  = (input) New CCSID to assign
      *
      * NOTE: HTTPAPI does not do *any* translation of downloaded
      *       data. It only sets this number as part of the file's
      *       attributes.  You can change it with the CHGATR CL
      *       command.
      *
      * NOTE: The IFS did not support CCSIDs in V4R5 and earlier.
      *       On those releases, this API will be used to set the
      *       codepage rather than the CCSID.
      *
      * Returns 0 if successful, -1 otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P HTTP_SetfileCCSID...
     P                 B                   export
     D HTTP_SetfileCCSID...
     D                 PI
     D   peCCSID                     10I 0 value
     c                   eval      p_global = getGlobalPtr()
     c                   eval      global.file_ccsid = peCCSID
     c                   callp     http_dmsg('File CCSID changed to '
     c                                      + %trim(%editc(peCCSID:'L')))
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HTTP_xlate():  Translate data from ASCII <--> EBCDIC
      *
      *       peSize = (input) Size of data to translate
      *       peData = (i/o)   Data
      *  peDirection = (input) can be set to the TO_ASCII or
      *                         TO_EBCDIC constant.
      *
      * Returns 0 if successful, -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P HTTP_xlate      B                   export
     D HTTP_xlate      PI            10I 0
     D   peSize                      10I 0 value
     D   peData                   32766A   options(*varsize)
     D   peDirection                  1A   const

     c                   return    CCSIDxlate( peSize
     c                                       : %addr(peData)
     c                                       : peDirection)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HTTP_xlatep(): Translate data from ASCII <--> EBCDIC
      *                (using a pointer instead of a variable)
      *
      *       peSize = (input) Size of data to translate
      *       peData = (input) Data
      *  peDirection = (input) can be set to the TO_ASCII or
      *                         TO_EBCDIC constant.
      *
      * Returns 0 if successful, -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P HTTP_xlatep     B                   export
     D HTTP_xlatep     PI            10I 0
     D   peSize                      10I 0 value
     D   peData                        *   value
     D   peDirection                  1A   const

     c                   return    CCSIDxlate( peSize
     c                                       : peData
     c                                       : peDirection)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * CCSIDxlate():  Translate data from ASCII <--> EBCDIC
      *                using a pointer to the data.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CCSIDxlate      B
     D CCSIDxlate      PI            10I 0
     D   peSize                      10I 0 value
     D   peData                        *   value
     D   peDirection                  1A   const

     D Size            s             10U 0
     D OutSize         s             10U 0

     c                   if        CCSIDs_Set = *OFF
     c                   if        HTTP_SetCCSIDs( HTTP_ASCII
     c                                           : HTTP_EBCDIC ) < 0
     c                   return    -1
     c                   endif
     c                   endif

     c                   eval      Size = peSize
     c                   eval      OutSize = peSize

     c                   if        peDirection = TO_ASCII
     c                   callp     iconv( ToASCII
     c                                  : peData
     c                                  : Size
     c                                  : peData
     c                                  : OutSize )
     c                   else
     c                   callp     iconv( ToEBCDIC
     c                                  : peData
     c                                  : Size
     c                                  : peData
     c                                  : OutSize )
     c                   endif

     c                   return    0
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * FILE_CCSID(): Get the CCSID that stream files should be
      *               tagged with.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P FILE_CCSID      B                   export
     D FILE_CCSID      PI            10I 0
     c                   eval      p_global = getGlobalPtr()
     c                   return    global.file_ccsid
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HTTP_xml_SetCCSIDs():  Set the CCSIDs used for ASCII/EBCDIC
      *                    translation for XML documents
      *
      *     peRemote = (input) remote CCSID
      *     peLocal  = (input) local CCSID (can be 0 if you want
      *                 to use the CCSID of the current job)
      *
      * Returns 0 if successful, -1 otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P HTTP_xml_SetCCSIDs...
     P                 B                   export
     D HTTP_xml_SetCCSIDs...
     D                 PI            10I 0
     D   peRemote                    10I 0 value
     D   peLocal                     10I 0 value

     c                   if        Xml_CCSID_Set = *ON
     c                   callp     iconv_close(xmlEBCDIC)
     c                   endif

     c                   eval      from_ccsid = peRemote
     c                   eval      to_ccsid   = peLocal
     c                   eval      xmlEBCDIC = iconv_open(dsTo: dsFrom)

     c                   if        ICORV_X < 0
     c                   return    -1
     c                   endif

     c                   eval      Xml_CCSID_set = *ON

     c                   eval      xml_EBCDIC = peLocal
     c                   eval      xml_ASCII  = peRemote

     c                   callp     http_dmsg('New XML iconv() objects set, '
     c                                  + 'xml_Remote='
     c                                  + %trim(%editc(peRemote:'L'))
     c                                  + '. xml_Local='
     c                                  + %trim(%editc(peLocal:'L')))

     c                   return    0
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * xml_xlate():  Translate data from UTF-8 to EBCDIC for
      *               XML data conversations.
      *
      *    peSize = (input) size of data to translate
      *    peData = (input) pointer to data to translate
      *  peOutBuf = (output) pointer to dynamically allocated
      *                      buffer containing translated data
      *
      *  returns the length of the data after the translation
      *       or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P xml_xlate       B                   export
     D xml_xlate       PI            10I 0
     D   peSize                      10I 0 value
     D   peData                        *   value
     D   peOutBuf                      *

     c                   if        Xml_CCSID_Set = *OFF
     c                   if        HTTP_xml_SetCCSIDs( 819 : 1208 ) < 0
     c                   return    -1
     c                   endif
     c                   endif

     c                   return    iconvdyn( peSize
     c                                     : peData
     c                                     : xmlEBCDIC
     c                                     : peOutbuf )
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HTTP_xlatedyn: Translate data from ASCII <--> EBCDIC
      *                using a dynamically sized output buffer
      *
      *      peSize = (input) size of data to translate
      *      peData = (input) pointer to data to translate
      * peDirection = (input) TO_ASCII or TO_EBCDIC
      *    peOutput = (output) address of newly allocated memory
      *
      * returns the length of the translated data or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P HTTP_xlatedyn   B                   export
     D HTTP_xlatedyn   PI            10I 0
     D   peSize                      10I 0 value
     D   peData                        *   value
     D   peDirection                  1A   const
     D   peOutput                      *
     c                   if        BinaryData = *on
     c                   return    BinaryCopy( peSize
     c                                       : peData
     c                                       : peOutput )
     c                   else
     c                   return    CCSIDXLateDyn( peSize
     c                                          : peData
     c                                          : peDirection
     c                                          : peOutput )
     c                   endif
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * CCSIDXlateDyn(): Translate using CCSID. Translate input
      *                  to a dynamically allocated output buffer.
      *
      *      peSize = (input) size of data to translate
      *      peData = (input) pointer to data to translate
      * peDirection = (input) TO_ASCII or TO_EBCDIC
      *    peOutput = (output) address of newly allocated memory
      *
      * returns the length of the translated data or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P CCSIDXlateDyn   B
     D CCSIDXlateDyn   PI            10I 0
     D   peSize                      10I 0 value
     D   peData                        *   value
     D   peDirection                  1A   const
     D   peOutbuf                      *

     D desc            s                   like(ToAscii)

     c                   if        CCSIDs_Set = *OFF
     c                   if        HTTP_SetCCSIDs( HTTP_ASCII
     c                                           : HTTP_EBCDIC ) < 0
     c                   return    -1
     c                   endif
     c                   endif

     c                   if        peDirection = TO_ASCII
     c                   eval      desc = pToAscii
     c                   else
     c                   eval      desc = pToEbcdic
     c                   endif

     c                   return    iconvdyn( peSize
     c                                     : peData
     c                                     : desc
     c                                     : peOutBuf )

     c                   return    -1
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * new_iconv(): Create a new character converter
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P new_iconv       b                   export
     D new_iconv       PI            52a
     D   peFrom                      10i 0 value
     D   peTo                        10i 0 value

     D Result          DS
     D   RC                          10I 0
     D   Xlate                       10I 0 dim(12)

     c                   eval      from_ccsid = peFrom
     c                   eval      to_ccsid   = peTo

     c                   eval      Result = iconv_open(dsTo: dsFrom)

     c                   if        RC < 0
     c                   callp     SetError( HTTP_CONVERR
     c                                     : 'iconv_open failed: '
     c                                     + %str(strerror(errno)) )
     c                   callp     http_crash
     c                   return    *blanks
     c                   endif

     c                   return    Result
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * iconvdyn():  Run the iconv() API and output to a dynamic
      *              memory buffer
      *
      *  NOTE: Output buffer is increased dynamically as needed.
      *        FIX: Original formula was to start the output buffer
      *             double the input buffer, this was a problem
      *             because max input size was effectively 8MB,
      *             since the 16MB output couldn't be allocated.
      *        FIX: When running out of memory, this routine used
      *             to increase the buffer by (peSize*4).. this
      *             meant that a 4MB input could also run out of
      *             memory.
      *
      *        New algorithm is start with same size as input
      *        buffer. If it needs to be increased, increase
      *        in 64k chunks.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P iconvdyn        B                   export
     D iconvdyn        PI            10I 0
     D   peSize                      10I 0 value
     D   peData                        *   value
     D   peDesc                      52a
     D   peOutbuf                      *

     D len             s             10I 0

     D insize          s             10U 0
     D desc            s                   like(ToAscii)
     D p_outbuf        s               *
     D size            s             10U 0
     D spaceleft       s             10U 0
     D GROW_CHUNK      C                   const(65536)

     D                 ds
     D rcU                           10U 0
     D rcI                           10I 0 overlay(rcU)

     c                   eval      insize    = peSize
     c                   eval      size      = insize
     c                   eval      peOutbuf  = xalloc(size)
     c                   eval      p_outbuf  = peOutbuf
     c                   eval      spaceleft = size

     c                   dow       '1'

     c                   eval      rcU = iconv( peDesc
     c                                        : peData
     c                                        : insize
     c                                        : p_outbuf
     c                                        : spaceleft )

     c                   if        rcI >= 0
     c                   leave
     c                   endif

     c                   if        errno <> E2BIG
     c                   callp     SetError( HTTP_CONVERR
     c                                     : 'CCSID conversion failed: '
     c                                     + %str(strerror(errno)) )
     c                   callp     xdealloc(peOutbuf)
     c                   return    -1
     c                   endif

     c                   eval      size      = size + GROW_CHUNK
     c                   eval      len       = p_outbuf - peOutbuf
     c                   eval      peOutbuf  = xrealloc(peOutbuf:size)
     c                   eval      p_outbuf  = peOutbuf + len
     c                   eval      spaceleft = size - len

     c                   enddo

     c                   eval      len = size - spaceleft

     c                   return    len
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * close_iconv(): Close iconv converter
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P close_iconv     b                   export
     D close_iconv     PI
     D   This                        52a   value
     C                   callp     iconv_close(This)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * xlate_symbols(): Translates symbols to current job's CCSID
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P xlate_symbols   B
     D xlate_symbols   PI            25a

     D Ucs2Symbols     ds
     D  Slash                         2a   inz(x'002F')
     D  Lt                            2a   inz(x'003C')
     D  Gt                            2a   inz(x'003E')
     D  Amp                           2a   inz(x'0026')
     D  Question                      2a   inz(x'003F')
     D  Plus                          2a   inz(x'002B')
     D  Pct                           2a   inz(x'0025')
     D  Equal                         2a   inz(x'003D')
     D  At                            2a   inz(x'0040')
     D  DblQuote                      2a   inz(x'0022')
     D  SngQuote                      2a   inz(x'0027')
     D  Comma                         2a   inz(x'002C')
     D  SemiColon                     2a   inz(x'003B')
     D  Colon                         2a   inz(x'003A')
     D  Dollar                        2a   inz(x'0024')
     D  Pound                         2a   inz(x'0023')
     D  BackSlash                     2a   inz(x'005C')
     D  LSQB                          2a   inz(x'005B')
     D  RSQB                          2a   inz(x'005D')
     D  LBRACE                        2a   inz(x'007B')
     D  RBRACE                        2a   inz(x'007D')
     D  Caret                         2a   inz(x'005E')
     D  BackTick                      2a   inz(x'0060')
     D  Pipe                          2a   inz(x'007C')
     D  Tilde                         2a   inz(x'007E')

     D Table           DS
     D   RC                          10I 0
     D   Xlate                       10I 0 dim(12)

     D Result          s             25a   inz('/<>&?+%=@"'',;:$#\[]{}^`|~')
     D Temp            s             25a   based(p_Temp)
     D Len             s             10i 0

     c                   eval      from_ccsid = 13488
     c                   eval      to_ccsid   = 0

     c                   eval      Table = iconv_open(dsTo: dsFrom)
     c                   if        RC < 0
     c                   return    Result
     c                   endif

     C                   eval      Len   = iconvdyn( %size(Ucs2Symbols)
     C                                             : %addr(Ucs2Symbols)
     C                                             : Table
     C                                             : p_Temp )
     C                   eval      Result = Temp
     c                   callp     xdealloc(p_Temp)

     C                   callp     iconv_close(Table)

     C                   return    Result
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * get_symbols(): Gets special HTTP symbols in current job's
      *                CCSID.  (Translated from Unicode)
      *
      *    Returns the list of symbols
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P get_symbols     b                   export
     D get_symbols     PI            25a
     D done            s              1n   static inz(*OFF)
     D symbols         s             25a   static
     C                   if        not done
     c                   eval      symbols = xlate_symbols
     c                   eval      done = *on
     c                   endif
     c                   return    symbols
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * BinaryCopy(): Allocate an buffer containing a copy of the
      *               input buffer.
      *
      *      peSize = (input) size of data to copy
      *      peData = (input) pointer to data to copy
      *    peOutput = (output) address of newly allocated memory
      *
      * returns the length of the copied data or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P BinaryCopy      B
     D                 PI            10I 0
     D   peSize                      10I 0 value
     D   peData                        *   value
     D   peOutbuf                      *

     c                   if        peSize < 1
     c                   return    -1
     c                   endif

     c                   eval      peOutbuf = xalloc(peSize)
     c                   callp     memcpy(peOutBuf: peData: peSize)
     c                   return    peSize

     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy errno_h
