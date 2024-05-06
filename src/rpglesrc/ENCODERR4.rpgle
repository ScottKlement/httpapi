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

     /*
      * ENCODERR4 -- Encoding routines for HTTPAPI
      *
      */

     H NOMAIN
      /if defined(HAVE_SRCSTMT_NODEBUGIO)
     H OPTION(*SRCSTMT)
      /endif

      /define HTTP_ORIG_SOAPACTION
      /copy httpapi_h
      /copy private_h
      /copy ifsio_h
      /copy errno_h

      /if defined(HTTP_USE_CCSID)
     D CCSID_OR_CP     S             10I 0 inz(O_CCSID)
      /else
     D CCSID_OR_CP     S             10I 0 inz(O_CODEPAGE)
      /endif

     D memset          PR              *   ExtProc('memset')
     D   ptr                           *   value
     D   value                       10I 0 value
     D   length                      10U 0 value

     D p_Encoder       s               *
     D dsEncoder       DS                  based(p_Encoder)
     D   dsEnc_Len                   10I 0
     D   dsEnc_Size                  10I 0
     D   dsEnc_Data                    *
     D   dsEnc_Space                  1A
     D   dsEnc_Spec                  25A
     D   dsEnc_HexAll               512A
     D   dsEnc_Hex                    2A   dim(256) overlay(dsEnc_HexAll)

     D p_Mfd           s               *
     D dsMfd           ds                  based(p_Mfd)
     D   dsMfd_bound                 32A
     D   dsMfd_fd                    10I 0

     D p_Mpr           s               *
     D dsMpr           ds                  based(p_Mpr)
     D   dsMpr_bound                 32A
     D   dsMpr_fd                    10I 0

     D http_url_encoder_addvar_long...
     D                 PR             1N
     D    peEncoder                    *   value
     D    peVariable                   *   value options(*string)
     D    peData                       *   value options(*string)
     D    peDataSize                 10i 0 value
     D http_url_encoder_addvar_long_s...
     D                 PR             1N
     D    peEncoder                    *   value
     D    peVariable                   *   value options(*string)
     D    peValue                      *   value options(*string)

     P*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P* Initializes the base64 alphabet used by base64_encode
     P*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P base64_init     B                   export
     D base64_init     PI
     D   peBase64                      *   value
     D p_Base64        S               *
     D wwBase64        S             64A   based(p_Base64)
     c                   eval      p_Base64 = peBase64
     c                   eval      wwBase64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
     c                                        'abcdefghijklmnopqrstuvwxyz' +
     c                                        '0123456789+/'
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  base64_encode:  Encodes a data stream into BASE64 encoding
      *
      *       peInput = pointer to data to convert
      *    peInputLen = length of data to convert
      *      peOutput = pointer to memory to receive output
      *     peOutSize = size of area to store output in
      *
      *  Returns length of encoded data, or space needed to encode
      *      data.   If this value is greater than peOutSize, then
      *      output may have been truncated.
      *  Returns -1 upon error
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P base64_encode   B                   export
     D base64_encode   PI            10I 0
     D   peInput                       *   value
     D   peInputLen                  10I 0 value
     D   peOutput                      *   value
     D   peOutSize                   10I 0 value

     D base64          S              1A   dim(64) static
     D wwInit          S              1N   inz(*OFF) static

     D dsCvt           DS
     D   wwNumb                1      2U 0 inz(0)
     D   wwByte                2      2A

     D p_Data          S               *
     D dsData          DS                  based(p_Data)
     D   ds8B1                        1A
     D   ds8B2                        1A
     D   ds8B3                        1A

     D p_OutData       S               *
     D wwOutData       S              4A   based(p_OutData)
     D wwOut           S              4A
     D wwPos           S             10I 0
     D wwOutLen        S             10I 0

     c                   if        not wwInit
     c                   callp     base64_init(%addr(base64))
     c                   eval      wwInit = *On
     c                   endif

     c                   eval      p_Data = peInput
     c                   eval      p_OutData = peOutput

     c                   eval      wwPos = 1
     c                   dow       wwPos <= peInputLen

     C* First Output Byte = Leftmost 6 bits of the first input byte
     c                   move      ds8B1         wwByte
     c                   bitoff    x'03'         wwByte
     c                   div       4             wwNumb
     c                   eval      %subst(wwOut:1) = base64(wwNumb+1)

     C*
     C* Second Output Byte = rightmost 2 bits of the first input byte
     C*                   and leftmost 4 bits of 2nd input byte
     c                   move      ds8B1         wwByte
     c                   bitoff    x'FC'         wwByte
     c                   mult      16            wwNumb

     c                   if        wwPos+1 <= peInputLen
     c                   move      wwByte        wwSave            1
     c                   move      ds8B2         wwByte
     c                   bitoff    x'0F'         wwByte
     c                   div       16            wwNumb
     c                   biton     wwSave        wwByte
     c                   endif

     c                   eval      %subst(wwOut:2) = base64(wwNumb+1)


     C*
     C* Third Output Byte = rightmost 4 bits of the 2nd input byte
     C*                   and leftmost 2 bits of 3nd input byte
     C*  or '=' if there was only one input byte
     C*
     c                   if        wwPos+1 > peInputLen

     c                   eval      %subst(wwOut:3) = '='

     c                   else

     c                   move      ds8B2         wwByte
     c                   bitoff    x'F0'         wwByte
     c                   mult      4             wwNumb

     c                   if        wwPos+2 <= peInputLen
     c                   move      wwByte        wwSave
     c                   move      ds8B3         wwByte
     c                   bitoff    x'3F'         wwByte
     c                   div       64            wwNumb
     c                   biton     wwSave        wwByte
     c                   endif

     c                   eval      %subst(wwOut:3) = base64(wwNumb+1)

     c                   endif

     C*
     C* Fourth Output Byte = rightmost 6 bits of the 3nd input byte
     C*  or '=' if there were less than 3 input bytes
     C*
     c                   if        wwPos+2 > peInputLen
     c                   eval      %subst(wwOut:4:1) = '='
     c                   else
     c                   move      ds8B3         wwByte
     c                   bitoff    x'C0'         wwByte
     c                   eval      %subst(wwOut:4) = base64(wwNumb+1)
     c                   endif

     c                   eval      wwOutLen = wwOutLen + 4
     c                   if        wwOutLen <= peOutSize
     c                   eval      wwOutData = wwOut
     c                   eval      p_Outdata = p_Outdata + 4
     c                   endif

     c                   eval      p_Data = p_Data + 3
     c                   eval      wwPos = wwPos + 3

     c                   enddo

     c                   return    wwOutLen
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_url_encoder_new():  Create a URL encoder.
      *
      *   returns an (opaque) pointer to the new encoder
      *           or *NULL upon error.
      *
      * WARNING: To free the memory used by this routine, you MUST
      *          call http_url_encoder_free() after the data is sent.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_url_encoder_new...
     P                 B                   export
     D http_url_encoder_new...
     D                 PI              *

     D cvthc           PR                  EXTPROC('cvthc')
     D  output                      512A
     D  input                       256A
     D  output_len                   10I 0 value

     D                 ds
     D dsCh1                   1      1A
     D dsCh                    2      2A
     D dsBin                   1      2U 0 inz(0)

     D wwRetVal        s               *

     D wwSpace         s              1A   inz(' ')
      ****                                      12345678901 2345678901234
     D wwBuf           s            256A
     D x               s             10I 0

     c                   eval      wwRetVal = xalloc(%size(dsEncoder))

     c                   eval      p_Encoder = wwRetVal
     c                   eval      dsEnc_Len = 0
     c                   eval      dsEnc_Size = 0
     c                   eval      dsEnc_Data = *NULL
     c                   eval      dsEnc_Space = wwSpace
     c                   eval      dsEnc_Spec  = get_symbols

     c     1             do        256           x
     c                   eval      dsBin = x - 1
     c                   eval      %subst(wwBuf:x:1) = dsCh
     c                   enddo

     c                   callp     cvthc( dsEnc_HexAll
     c                                  : wwBuf
     c                                  : %size(dsEnc_HexAll))

     c                   callp     http_xlate( %size(dsEnc_Space)
     c                                       : dsEnc_Space
     c                                       : TO_ASCII )

     c                   callp     http_xlate( %size(dsEnc_Spec)
     c                                       : dsEnc_Spec
     c                                       : TO_ASCII  )

     c                   callp     http_xlate( %size(dsEnc_HexAll)
     c                                       : dsEnc_HexAll
     c                                       : TO_ASCII )

     c                   return    wwRetVal
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_url_encoder_free(): free resources allocated by both
      *        http_url_encoder_new() and http_url_encoder_addvar()
      *
      *     peEncoder = pointer to encoder to free
      *
      * Returns *ON if successful, *OFF otherwise.
      *
      * WARNING: After calling this, do not use the encoder or
      *          data returned by http_url_encoder_getptr() again.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_url_encoder_free...
     P                 B                   export
     D http_url_encoder_free...
     D                 PI             1N
     D    peEncoder                    *   value

     c                   eval      p_Encoder = peEncoder

     c                   callp(e)  xdealloc(dsEnc_Data)
     c                   if        %error
     c                   return    *OFF
     c                   endif

     c                   callp(e)  xdealloc(p_Encoder)
     c                   if        %error
     c                   return    *OFF
     c                   endif

     c                   eval      p_Encoder = *NULL
     c                   return    *ON
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  url_encode_pre():  (Internal) Prepare data for URL encoding.
      *
      *     peEncoder = encoder to use
      *       peInput = data to encode.  This will be converted to
      *                   ASCII...
      *      peInpLen = length of input data
      *
      *  Returns the length that is required for the output data
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P url_encode_pre  B                   export
     D url_encode_pre  PI            10I 0
     D    peEncoder                    *   value
     D    peInput                      *   value
     D    peInpLen                   10I 0 value

     D p_Deref         s               *
     D wwDeref         s              1A   based(p_Deref)

     D wwPos           s             10I 0
     D wwLen           s             10I 0
     D wwCheck         s             10I 0

     c                   eval      p_Encoder = peEncoder
     c                   eval      p_Deref = peInput

      ********************************************
      * Count the size of data needed
      ********************************************
     c     1             do        peInpLen      wwPos


     c     dsEnc_Spec    check     wwDeref       wwCheck
     c                   if        wwCheck = 0
     c                               or wwDeref<x'20'
     c                               or wwDeref>x'7F'
     c                   eval      wwLen = wwLen + 3
     c                   else
     c                   eval      wwLen = wwLen + 1
     c                   endif

     c                   eval      p_Deref = p_Deref + 1
     c                   enddo

     c                   return    wwLen
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  url_encode():  (Internal) URL encode data into output buffer
      *
      *     peEncoder = encoder to use
      *       peInput = data to encode.  Should be ASCII.  Will be
      *                    converted to EBCDIC.
      *      peInpLen = length of input data
      *         peLoc = location to store output data into
      *     peLocSize = size of output data (returned by _pre)
      *
      * Resulting output data will be EBCDIC data suitable for passing
      *    into http_url_post()
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P url_encode      B                   export
     D url_encode      PI
     D    peEncoder                    *   value
     D    peInput                      *   value
     D    peInpLen                   10I 0 value
     D    peLoc                        *   value
     D    peLocSize                  10I 0 value

     D cvthc           PR                  EXTPROC('cvthc')
     D  output                        2A
     D  input                         1A
     D  output_len                   10I 0 value

     D p_Deref         s               *
     D wwDeref         s              1A   based(p_Deref)

     D p_ResChar       s               *
     D wwResChar       s              2A   based(p_ResChar)

     D                 ds
     D   wwVal                 1      2U 0 inz(0)
     D   wwChar                2      2A

     D wwPos           s             10I 0
     D wwCheck         s             10I 0

     c                   eval      p_Encoder = peEncoder

      ********************************************
      **  Create urlencoded result
      ********************************************
     c                   eval      p_deref = peInput
     c                   eval      p_reschar = peLoc

     c     1             do        peInpLen      wwPos

     c                   if        wwPos <> 1
     c                   eval      p_deref = p_deref + 1
     c                   endif

     c     dsEnc_Spec    check     wwDeref       wwCheck

     c                   select
     c                   when      wwDeref = dsEnc_Space
     c                   eval      %subst(wwResChar:1:1) =
     c                                  %subst(dsEnc_Spec:6:1)
     c                   eval      p_reschar = p_reschar + 1

     c                   when      wwCheck = 0
     c                               or wwDeref<x'20'
     c                               or wwDeref>x'7F'

     c                   eval      %subst(wwResChar:1:1) =
     c                                %subst(dsEnc_Spec:7:1)
     c                   eval      p_ResChar = p_ResChar + 1

     c                   eval      wwChar = wwDeref
     c                   eval      wwResChar = dsEnc_Hex(wwVal+1)
     c                   eval      p_ResChar = p_ResChar + 2

     c                   other
     c                   eval      %subst(wwResChar:1:1) = wwDeref
     c                   eval      p_reschar = p_reschar + 1
     c                   endsl

     c                   enddo

      ********************************************
      *  convert result back to EBCDIC so that
      *  user can inspect it and SendProc() won't
      *  be confused.
      ********************************************
     c                   callp     http_xlatep( peLocSize
     c                                        : peLoc
     c                                        : TO_EBCDIC )

     c                   return
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_url_encoder_addvar_long(): Add a variable to what's stored
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
     P http_url_encoder_addvar_long...
     P                 B                   export
     D http_url_encoder_addvar_long...
     D                 PI             1N
     D    peEncoder                    *   value
     D    peVariable                   *   value options(*string)
     D    peData                       *   value options(*string)
     D    peDataSize                 10i 0 value

     D ENCBLOCK        C                   8192

     D p_Deref         s               *
     D wwDeref         s              1A   based(p_Deref)

     D wwLenVar        s             10I 0
     D wwLenData       s             10I 0
     D wwNewLen        s             10I 0
     D wwNewSize       s             10I 0

     D wwVarXLen       s             10i 0
     D wwDataXLen      s             10i 0
     D p_VarX          s               *
     D p_DataX         s               *

     c                   eval      p_Encoder = peEncoder

      ****************************************************************
      * Translate to destination CCSID (ASCII, Unicode whatever)
      ****************************************************************
     c                   if        %len(%str(peVariable)) = 0
     c                   return    *off
     c                   endif

     c                   eval      wwVarXLen =
     c                             http_xlatedyn( %len(%str(peVariable))
     c                                          : peVariable
     c                                          : TO_ASCII
     c                                          : p_VarX )

     c                   if        peDataSize = 0
     c                   eval      wwDataXLen = 0
     c                   eval      p_DataX    = *null
     c                   else
     c                   eval      wwDataXLen =
     c                             http_xlatedyn( peDataSize
     c                                          : peData
     c                                          : TO_ASCII
     c                                          : p_DataX )
     c                   endif


      ****************************************************************
      * Figure out how much space we'll need to encode the data:
      ****************************************************************
     c                   eval      wwLenVar =
     c                             url_encode_pre( peEncoder
     c                                           : p_VarX
     c                                           : wwVarXLen )

     c                   eval      wwLenData =
     c                             url_encode_pre( peEncoder
     c                                           : p_DataX
     c                                           : wwDataXLen )

     c                   eval      wwNewLen = dsEnc_Len +
     c                               wwLenVar + %len('=') + wwLenData

     c                   if        dsEnc_Len > 0
     c                   eval      wwNewLen = wwNewLen + %len('&')
     c                   endif

      ****************************************************************
      *  Allocate enough space to store newly encoded variable and
      *  it's data into the encoder.
      ****************************************************************
     c                   eval      wwNewSize = dsEnc_Size

     c                   if        wwNewSize < wwNewLen

     c                   dow       wwNewSize < wwNewLen
     c                   eval      wwNewSize = wwNewSize + ENCBLOCK
     c                   enddo

     c                   eval      dsEnc_Data = xrealloc( dsEnc_data
     c                                                  : wwNewSize )

     c                   if        dsEnc_Data = *null
     c                   callp     xdealloc(p_VarX)
     c                   callp     xdealloc(p_DataX)
     c                   return    *OFF
     c                   endif

     c                   callp     memset( dsEnc_Data + dsEnc_Size
     c                                   : 0
     c                                   : wwNewSize - dsEnc_Size )

     c                   eval      dsEnc_Size = wwNewSize
     c                   endif

      ****************************************************************
      *  Encode the variable and data
      ****************************************************************
     c                   if        dsEnc_Len > 0
     c                   eval      p_deref = dsEnc_Data + dsEnc_Len
     c                   eval      wwDeref = '&'
     c                   eval      dsEnc_Len = dsEnc_Len + %len('&')
     c                   endif

     c                   callp     url_encode( peEncoder
     c                                       : p_VarX
     c                                       : wwVarXLen
     c                                       : dsEnc_Data + dsEnc_Len
     c                                       : wwLenVar )
     c                   eval      dsEnc_Len = dsEnc_Len + wwLenVar
     c                   callp     xdealloc(p_VarX)

     c                   eval      p_deref = dsEnc_Data + dsEnc_Len
     c                   eval      wwDeref = '='
     c                   eval      dsEnc_Len = dsEnc_Len + %len('=')

     c                   if        wwDataXLen > 0
     c                   callp     url_encode( peEncoder
     c                                       : p_DataX
     c                                       : wwDataXLen
     c                                       : dsEnc_Data + dsEnc_Len
     c                                       : wwLenData )
     c                   eval      dsEnc_Len = dsEnc_Len + wwLenData
     c                   callp     xdealloc(p_DataX)
     c                   endif

     c                   return    *ON
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_urlEncode(): Encodes one component of a URL without
      *                   having to build a whole "form"
      *
      *   input = (input) string to encode
      *
      * Returns the encoded string, or '' upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_urlEncode  B                   export
     D                 PI         65535a   varying
     D    input                        *   value options(*string)

     D inputLen        s             10i 0
     D XLen            s             10i 0
     D p_inputX        s               *
     D myEnc           s               *
     D EncLen          s             10i 0
     D Output          s          65535a   varying

      /free

       if input = *null;
          return '';
       endif;

       inputLen = %len(%str(input));
       if inputLen < 1;
          return '';
       endif;

       XLen = http_xlatedyn( inputLen
                           : input
                           : TO_NETWORK
                           : p_inputX );

       if XLen=0 or p_InputX=*null;
          return '';
       endif;

       myEnc = http_url_encoder_new();
       if myEnc = *null;
          xdealloc(p_inputX);
          return '';
       endif;

       EncLen = url_encode_pre( myEnc
                              : p_inputX
                              : XLen );

       if EncLen < 1;
          xdealloc(p_InputX);
          http_url_encoder_free(myEnc);
          return '';
       endif;

       %len(Output) = EncLen;

       url_encode( myEnc
                 : p_inputX
                 : XLen
                 : %addr(Output) + VARPREF
                 : EncLen );

       http_url_encoder_free(myEnc);
       xdealloc(p_inputX);

       return Output;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_url_encoder_getptr(): Get a pointer to the encoded
      *        data stored in a URL encoder
      *
      *     peEncoder = (input) pointer to encoder
      *        peData = (output) pointer to encoded data
      *        peSize = (output) size of encoded data
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_url_encoder_getptr...
     P                 B                   export
     D http_url_encoder_getptr...
     D                 PI
     D    peEncoder                    *   value
     D    peData                       *
     D    peSize                     10I 0
     c                   eval      p_Encoder = peEncoder
     c                   eval      peData = dsEnc_data
     c                   eval      peSize = dsEnc_len
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_url_encoder_getstr(): Get encoded data he encoded
      *        data stored in a URL encoder as a string
      *
      *     peEncoder = (input) pointer to encoder
      *
      * NOTE: This routine is much slower than http_url_encoder_getptr()
      *       and is limited to a 32k return value.  It's suitable for
      *       use with data that's added to a URL, such as when
      *       performing a GET request to a web server, but you should
      *       use http_url_encoder_getptr() for POST requests.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_url_encoder_getstr...
     P                 B                   export
     D http_url_encoder_getstr...
     D                 PI         32767A   varying
     D    peEncoder                    *   value

     D len             s             10i 0
     D wwRet           s          32767A   varying

     c                   eval      p_Encoder = peEncoder
     c                   eval      len = %size(wwRet) - VARPREF

     c                   if        dsEnc_Len < len
     c                   eval      len = dsEnc_len
     c                   endif

     c                   eval      %len(wwRet) = len

     c                   callp     memcpy( %addr(wwRet)+VARPREF
     c                                   : dsEnc_Data
     c                                   : len )

     c                   return    wwRet
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_url_encoder_addvar_long_s():  Simplified interface to
      *      http_url_encoder_addvar().
      *
      *    peEncoder = (input) HTTP_url_encoder object
      *   peVariable = (input) variable name to set
      *      peValue = (input) value to set variable to
      *
      * Returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_url_encoder_addvar_long_s...
     P                 B                   export
     D http_url_encoder_addvar_long_s...
     D                 PI             1N
     D    peEncoder                    *   value
     D    peVariable                   *   value options(*string)
     D    peValue                      *   value options(*string)
     c                   return    http_url_encoder_addvar_long(
     c                                           peEncoder
     c                                         : peVariable
     c                                         : peValue
     c                                         : %len(%str(peValue))
     c                                         )
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mfd_encoder_open(): Create a multipart/form-data encoder
      *
      * A multipart/form-data encoder will encode the variables
      * and or stream files that you pass to it and store the results
      * in a stream file.  You can later POST those results with the
      * http_url_post_stmf() API.
      *
      *   peStmFile = (input) pathname to stream file to store
      *               encoded results.
      *
      *   returns an (opaque) pointer to the new encoder
      *           or *NULL upon error.
      *
      * WARNING: To free the memory used by this routine and close
      *          the stream file, you MUST call http_mfd_encoder_close()
      *          after the data is sent.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_mfd_encoder_open...
     P                 B                   export
     D http_mfd_encoder_open...
     D                 PI              *
     D  peStmFile                      *   value options(*string)
     D  peContType                   64A

     D wwFilename      s          32767a   varying
     D wwFD            s             10I 0
     D wwTS            s               Z
     D wwTsStr         s             26A
     D wwBoundary      s             32A
     D wwRetVal        s               *

      *************************************************
      *  Open a file to contain the results
      *************************************************
     c                   eval      wwFilename = %trimr(%str(peStmFile))
     c                   eval      wwFD = open( wwFilename
     c                                        : O_WRONLY  +
     c                                          O_CREAT   +
     c                                          O_TRUNC   +
     c                                          CCSID_OR_CP
     c                                        : HTTP_IFSMODE
     c                                        : FILE_CCSID )

     c                   if        wwFD < 0
     c                   callp     SetError( HTTP_IFOPEN
     c                                     : 'open(): '
     c                                     + %str(strerror(errno)))
     c                   return    *NULL
     c                   endif

      *************************************************
      * Save space for crap
      *************************************************
     c                   eval      wwRetVal = xalloc(%size(dsMfd))

      *************************************************
      * Create a boundary string
      *************************************************
     c                   time                    wwTS
     c                   move      wwTS          wwTsStr
     c                   eval      wwBoundary = '-httpapi-' + wwTsStr

      *************************************************
      * Set up MFD structure
      *************************************************
     c                   eval      p_Mfd = wwRetVal
     c                   eval      dsMfd_fd = wwFD
     c                   eval      dsMfd_bound = wwBoundary

     c                   eval      peContType = 'multipart/form-data; '
     c                                        + 'boundary=' + wwBoundary

     c                   return    wwRetVal
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mfd_encoder_addvar():  Add a variable to what's stored
      *          a multipart/form-data encoder.
      *
      *    peEncoder = pointer to encoder created by the
      *                  http_mfd_encoder_open() routine
      *   peVariable = variable name to add
      *       peData = pointer to data to store in variable
      *   peDataSize = size of data to store in variable
      *   peContType = (optional) Content-type of data in variable
      *                if this parameter is not given, the content
      *                type header will be omitted.
      *
      * Returns *ON if successful, *OFF otherwise.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_mfd_encoder_addvar...
     P                 B                   export
     D http_mfd_encoder_addvar...
     D                 PI             1N
     D    peEncoder                    *   value
     D    peVariable                 50A   varying value
     D    peData                       *   value
     D    peDataSize                 10I 0 value
     D    peContType              32767a   varying const
     D                                     options(*varsize: *nopass: *omit)

     D CRLF            c                   x'0d25'
     D p_LD            s               *
     D wwLD            s              1A   based(p_LD)
     D wwLine          s          33791A   varying

     c                   eval      p_Mfd = peEncoder
     c                   eval      p_LD = %addr(wwLine) + VARPREF

     c                   eval      wwLine = '--' + dsMfd_bound + CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMfd_fd : p_LD: %len(wwLine))

     c                   eval      wwLine = 'Content-Disposition: '
     c                                    + 'form-data; '
     c                                    + 'name="' + peVariable + '"'
     c                                    + CRLF
     c*
     c                   if        %parms>=5 and %addr(peContType)<>*null
     c                   eval      wwLine += 'Content-Type: ' + peContType
     c                                    +  CRLF
     c                   endif
     c*
     c                   eval      wwLine += CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMfd_fd : p_LD: %len(wwLine))

     c                   eval      p_LD = peData
     c                   callp     http_xlate(peDataSize: wwLD: TO_ASCII)
     c                   callp     write(dsMfd_fd : p_LD: peDataSize)
     c                   callp     http_xlate(peDataSize: wwLD: TO_EBCDIC)

     c                   eval      p_LD = %addr(wwLine) + VARPREF
     c                   eval      wwLine = CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMfd_fd : p_LD: %len(wwLine))

     c                   return    *ON
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mfd_encoder_addvar_s():  Simplified (but limited)
      *       interface to http_mfd_encoder_addvar().
      *
      *    peEncoder = (input) HTTP_mfd_encoder object
      *   peVariable = (input) variable name to set
      *      peValue = (input) value to set variable to
      *   peContType = (optional) Content-type of data in variable
      *                if this parameter is not given, the content
      *                type header will be omitted.
      *
      * Returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_mfd_encoder_addvar_s...
     P                 B                   export
     D http_mfd_encoder_addvar_s...
     D                 PI             1N
     D    peEncoder                    *   value
     D    peVariable                 50A   varying value
     D    peValue                   256A   varying value
     D    peContType              32767a   varying const
     D                                     options(*varsize: *nopass: *omit)
     c                   if        %parms>=4 and %addr(peContType)<>*null
     c                   return    http_mfd_encoder_addvar( peEncoder
     c                                          : peVariable
     c                                          : %addr(peValue)+VARPREF
     c                                          : %len(peValue)
     c                                          : peContType )
     c                   else
     c                   return    http_mfd_encoder_addvar( peEncoder
     c                                          : peVariable
     c                                          : %addr(peValue)+VARPREF
     c                                          : %len(peValue))
     c                   endif
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mfd_encoder_addstmf(): Add a stream file to what's stored
      *       in a multipart/form-data encoder.
      *
      *    peEncoder = pointer to encoder created by the
      *                  http_mfd_encoder_open() routine
      *   peVariable = variable name to add
      *   pePathName = Path name of stream file to add
      *   peContType = Content-type of stream file to add
      *
      * Returns *ON if successful, *OFF otherwise.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_mfd_encoder_addstmf...
     P                 B                   export
     D http_mfd_encoder_addstmf...
     D                 PI             1N
     D    peEncoder                    *   value
     D    peVariable                 50A   varying value
     D    pePathName                   *   value options(*string)
     D    peContType              32767a   varying const
     D                                     options(*varsize)

     D wwfilename      s          32767a   varying
     D CRLF            c                   x'0d25'
     D wwFd            s             10I 0
     D p_LD            s               *
     D wwLD            s              1A   based(p_LD)
     D wwLine          s          32791A   varying
     D wwBuffer        s          32767A
     D wwLen           s             10I 0

     c                   eval      p_Mfd = peEncoder

     c                   eval      wwFilename = %trimr(%str(pePathname))
     c                   eval      wwFD = open( wwFilename: O_RDONLY)
     c                   if        wwFD < 0
     c                   callp     SetError( HTTP_IFOPEN
     c                                     : 'open(): '
     c                                     + %str(strerror(errno)))
     c                   return    *OFF
     c                   endif

     c                   eval      p_LD = %addr(wwLine) + VARPREF
     c                   eval      wwLine = '--' + dsMfd_bound + CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMfd_fd : p_LD: %len(wwLine))

     c                   eval      wwLine = 'Content-Disposition: '
     c                                    + 'form-data; '
     c                                    + 'name="' + peVariable + '"; '
     c                                    + 'filename="'
     c                                    + %str(pePathName) + '"'
     c                                    + CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMfd_fd : p_LD: %len(wwLine))

     c                   eval      wwLine = 'Content-Type: '
     c                                    + peContType
     c                                    + CRLF
     c                                    + CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMfd_fd : p_LD: %len(wwLine))

     c                   eval      wwLen = read( wwFd
     c                                         : %addr(wwBuffer)
     c                                         : %size(wwBuffer) )
     c                   dow       wwLen > 0
     c                   callp     write( dsMfd_fd
     c                                  : %addr(wwBuffer)
     c                                  : wwLen )
     c                   eval      wwLen = read( wwFd
     c                                         : %addr(wwBuffer)
     c                                         : %size(wwBuffer) )
     c                   enddo

     c                   eval      wwLine = CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMfd_fd : p_LD: %len(wwLine))

     c                   callp     close(wwFD)

     c                   return    *ON
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mfd_encoder_close():  close an open multipart/form-data
      *                            encoder.
      *
      *     peEncoder = (input) encoder to close
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_mfd_encoder_close...
     P                 B                   export
     D http_mfd_encoder_close...
     D                 PI
     D  peEncoder                      *   value

     D CRLF            c                   x'0d25'
     D p_LD            s               *
     D wwLD            s              1A   based(p_LD)
     D wwLine          s           1024A   varying

     c                   eval      p_mfd = peEncoder

     c                   eval      p_LD = %addr(wwLine) + VARPREF
     c                   eval      wwLine = '--' + dsMfd_Bound + '--'
     c                                    + CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMfd_fd : p_LD: %len(wwLine))

     c                   callp     close(dsMfd_fd)

     c                   callp     xdealloc(p_mfd)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mpr_encoder_open(): Create a multipart/related encoder
      *
      * A multipart/related encoder will encode the parts that compose
      * a message and store the results in a stream file.
      * You can later POST those results with the http_url_post_stmf()
      * API.
      *
      *   peStmFile   = (input) pathname to stream file to store
      *                 encoded results.
      *
      *   peType      = (input) the type of content of the starting
      *                 part of the message.
      *
      *   peContType  = (output) the entire calculated content type
      *                 to pass to http_url_post_stmf.
      *
      *   peStartRef  = (input) the id used for the root part of
      *                 the message. Can be omitted, in this case
      *                 the first part of the message is the root.
      *
      *   peStartInfo = (input) the type of content of the root part
      *                 of the message. Can be omitted, in this case
      *                 the first part of the message is the root.
      *
      *   returns an (opaque) pointer to the new encoder
      *           or *NULL upon error.
      *
      * WARNING: To free the memory used by this routine and close
      *          the stream file, you MUST call http_mpr_encoder_close()
      *          after the data is sent.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_mpr_encoder_open...
     P                 B                   export
     D http_mpr_encoder_open...
     D                 PI              *
     D  peStmFile                      *   value options(*string)
     D  peType                       64A   varying const
     D  peContType                  256A
     D  peStartRef                   64A   varying const options(*nopass)
     D  peStartInfo                  64A   varying const options(*nopass)

     D wwFilename      s          32767a   varying
     D wwFD            s             10I 0
     D wwTS            s               Z
     D wwTsStr         s             26A
     D wwBoundary      s             32A
     D wwRetVal        s               *

      *************************************************
      *  Open a file to contain the results
      *************************************************
     c                   eval      wwFilename = %trimr(%str(peStmFile))
     c                   eval      wwFD = open( wwFilename
     c                                        : O_WRONLY  +
     c                                          O_CREAT   +
     c                                          O_TRUNC   +
     c                                          CCSID_OR_CP
     c                                        : HTTP_IFSMODE
     c                                        : FILE_CCSID )

     c                   if        wwFD < 0
     c                   callp     SetError( HTTP_IFOPEN
     c                                     : 'open(): '
     c                                     + %str(strerror(errno)))
     c                   return    *NULL
     c                   endif

      *************************************************
      * Save space for crap
      *************************************************
     c                   eval      wwRetVal = xalloc(%size(dsMpr))

      *************************************************
      * Create a boundary string
      *************************************************
     c                   time                    wwTS
     c                   move      wwTS          wwTsStr
     c                   eval      wwBoundary = '-httpapi-' + wwTsStr

      *************************************************
      * Set up MPR structure
      *************************************************
     c                   eval      p_Mpr = wwRetVal
     c                   eval      dsMpr_bound = wwBoundary
     c                   eval      dsMpr_fd = wwFD

     c                   eval      peContType = 'multipart/related; '
     c                                        + 'type="' + %trim(peType) + '"; '
     c                                        + 'boundary=' + wwBoundary
     c                   if        %parms > 3
     c                   eval      peContType = %trim(peContType) + '; '
     c                                        + 'start="' + %trim(peStartRef)
     c                                        + '"'
     c                   endif
     c                   if        %parms > 4
     c                   eval      peContType = %trim(peContType) + '; '
     c                                        + 'start-info="'
     c                                        + %trim(peStartInfo)
     c                                        + '"'
     c                   endif

     c                   return    wwRetVal
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mpr_encoder_addstr():  Add a part to what's stored
      *          a multipart/related encoder in the form of a string.
      *
      *    peEncoder = pointer to encoder created by the
      *                  http_mfd_encoder_open() routine
      *       peData = pointer to data to store in variable
      *   peDataSize = size of data to store in variable
      *   peContType = Content-type of string to add
      *     peContID = The ID of the part
      *
      * Returns *ON if successful, *OFF otherwise.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_mpr_encoder_addstr...
     P                 B                   export
     D http_mpr_encoder_addstr...
     D                 PI             1N
     D    peEncoder                    *   value
     D    peData                       *   value
     D    peDataSize                 10I 0 value
     D    peContType                256A   varying const
     D    peContID                   64A   varying const

     D CRLF            c                   x'0d25'
     D p_LD            s               *
     D wwLD            s              1A   based(p_LD)
     D wwLine          s           1024A   varying

     c                   eval      p_Mpr = peEncoder
     c                   eval      p_LD = %addr(wwLine) + VARPREF

     c                   eval      wwLine = '--' + dsMpr_bound + CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMpr_fd : p_LD: %len(wwLine))

     c                   eval      wwLine = 'Content-Type: '
     c                                    + peContType
     c                                    + CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMpr_fd : p_LD: %len(wwLine))

     c                   eval      wwLine = 'Content-Transfer-Encoding: '
     c                                    + '8bit'
     c                                    + CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMpr_fd : p_LD: %len(wwLine))

     c                   eval      wwLine = 'Content-Id: '
     c                                    + peContId
     c                                    + CRLF
     c                                    + CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMpr_fd : p_LD: %len(wwLine))

     c                   eval      p_LD = peData
     c                   callp     http_xlate(peDataSize: wwLD: TO_ASCII)
     c                   callp     write(dsMpr_fd : p_LD: peDataSize)
     c                   callp     http_xlate(peDataSize: wwLD: TO_EBCDIC)

     c                   eval      p_LD = %addr(wwLine) + VARPREF
     c                   eval      wwLine = CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMpr_fd : p_LD: %len(wwLine))

     c                   return    *ON
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mpr_encoder_addstr_s():  Simplified (but limited)
      *       interface to http_mpr_encoder_addvar().
      *
      *    peEncoder = (input) HTTP_mpr_encoder object
      *       peData = (input) string to write
      *   peContType = Content-type of string to add
      *     peContID = The ID of the part
      *
      * Returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_mpr_encoder_addstr_s...
     P                 B                   export
     D http_mpr_encoder_addstr_s...
     D                 PI             1N
     D    peEncoder                    *   value
     D    peData                  32767A   varying value
     D    peContType                256A   varying const
     D    peContID                   64A   varying const
     c                   return    http_mpr_encoder_addstr( peEncoder
     c                                          : %addr(peData)+VARPREF
     c                                          : %len(peData)
     c                                          : peContType
     c                                          : peContId )
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mpr_encoder_addstmf(): Add a stream file to what's stored
      *       in a multipart/related encoder.
      *
      *    peEncoder = pointer to encoder created by the
      *                  http_mfd_encoder_open() routine
      *   pePathName = Path name of stream file to add
      *   peContType = Content-type of stream file to add
      *     peContID = The ID of the part
      *
      * Returns *ON if successful, *OFF otherwise.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_mpr_encoder_addstmf...
     P                 B                   export
     D http_mpr_encoder_addstmf...
     D                 PI             1N
     D    peEncoder                    *   value
     D    pePathName                   *   value options(*string)
     D    peContType                256A   varying const
     D    peContID                   64A   varying const

     D wwfilename      s          32767a   varying
     D CRLF            c                   x'0d25'
     D wwFd            s             10I 0
     D p_LD            s               *
     D wwLD            s              1A   based(p_LD)
     D wwLine          s           1024A   varying
     D wwBuffer        s          32767A
     D wwLen           s             10I 0

     c                   eval      p_Mpr = peEncoder

     c                   eval      wwFilename = %trimr(%str(pePathname))
     c                   eval      wwFD = open( wwFilename: O_RDONLY)
     c                   if        wwFD < 0
     c                   callp     SetError( HTTP_IFOPEN
     c                                     : 'open(): '
     c                                     + %str(strerror(errno)))
     c                   return    *OFF
     c                   endif

     c                   eval      p_LD = %addr(wwLine) + VARPREF
     c                   eval      wwLine = '--' + dsMpr_bound + CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMpr_fd : p_LD: %len(wwLine))

     c                   eval      wwLine = 'Content-Type: '
     c                                    + %trim(peContType)
     c                                    + CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMpr_fd : p_LD: %len(wwLine))

     c                   eval      wwLine = 'Content-Transfer-Encoding: '
     c                                    + 'binary'
     c                                    + CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMpr_fd : p_LD: %len(wwLine))

     c                   eval      wwLine = 'Content-Id: '
     c                                    + %trim(peContId)
     c                                    + CRLF
     c                                    + CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMpr_fd : p_LD: %len(wwLine))

     c                   eval      wwLen = read( wwFd
     c                                         : %addr(wwBuffer)
     c                                         : %size(wwBuffer) )
     c                   dow       wwLen > 0
     c                   callp     write( dsMpr_fd
     c                                  : %addr(wwBuffer)
     c                                  : wwLen )
     c                   eval      wwLen = read( wwFd
     c                                         : %addr(wwBuffer)
     c                                         : %size(wwBuffer) )
     c                   enddo

     c                   eval      wwLine = CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMpr_fd : p_LD: %len(wwLine))

     c                   callp     close(wwFD)

     c                   return    *ON
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mpr_encoder_close():  close an open multipart/related
      *                            encoder.
      *
      *     peEncoder = (input) encoder to close
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_mpr_encoder_close...
     P                 B                   export
     D http_mpr_encoder_close...
     D                 PI
     D  peEncoder                      *   value

     D CRLF            c                   x'0d25'
     D p_LD            s               *
     D wwLD            s              1A   based(p_LD)
     D wwLine          s           1024A   varying

     c                   eval      p_mpr = peEncoder

     c                   eval      p_LD = %addr(wwLine) + VARPREF
     c                   eval      wwLine = '--' + dsMpr_Bound + '--'
     c                                    + CRLF
     c                   callp     http_xlate(%len(wwLine): wwLD: TO_ASCII)
     c                   callp     write(dsMpr_fd : p_LD: %len(wwLine))

     c                   callp     close(dsMpr_fd)

     c                   callp     xdealloc(p_mpr)
     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy errno_h

