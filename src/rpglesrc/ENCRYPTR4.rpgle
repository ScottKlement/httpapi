     /*-                                                                            +
      * Copyright (c) 2012-2023 Thomas Raddatz                                      +
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
      *  NTLM: Data encryption and digest services                          *
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
      *                                                                     *
      *=====================================================================*
      /if defined(HAVE_SRCSTMT_NODEBUGIO)
     H OPTION(*NOSHOWCPY: *SRCSTMT: *NODEBUGIO)
      /endif
     H NOMAIN
      *=====================================================================*
      *
      * ------------------------------------
      *  Type Definitions
      * ------------------------------------
      *
      * ------------------------------------
      *  Exported prototypes
      * ------------------------------------
      /DEFINE RC4_INTERNAL_USE
      /DEFINE MD4_INTERNAL_USE
      /DEFINE MD5_INTERNAL_USE
      *
      /COPY NTLM_H
      /COPY NTLM_P
      /COPY MD4_H
      *
      * ------------------------------------
      *  Imported prototypes
      * ------------------------------------
      *
      * ------------------------------------
      *  Internal prototypes
      * ------------------------------------
      *
      *  Calculates the odd parity bit for each byte
      *  of a given value.
     D setParityBit...
     D                 PR             1A
     D                                     extproc('setParityBit')
     D  i_char                        1A   const
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
      *  Cipher (CIPHER)
     D cipher...
     D                 PR                  extproc('_CIPHER')
     D                                 *   const
     D                                 *   value
     D                                 *   const
      *
     D cipherCtrls_0005_t...
     D                 DS                  qualified  based(pDummy)  align
     D  function               1      2A
     D  hashAlg                3      3A
     D  sequence               4      4A
     D  dataLength             5      8U 0
     D  output                 9      9A
     D  reserved_1            10     16A
     D  hashContext           17     32*
     D  HMACKey               33     48*
     D  HMACKeyLength         49     52U 0
     D  reserved_2            53     96A
      *
     D cipherCtrls_0013_t...
     D                 DS                  qualified  based(pDummy)  align
     D  function               1      2A
     D  dataLength             3      4U 0
     D  operation              5      5A
     D  reserved               6     16A
     D  keyCtxPtr             17     32*
      *
     D cCIPHER_ENCRYPT...
     D                 C                   const(x'00')
     D cCIPHER_DECRYPT...
     D                 C                   const(x'01')
      *
     D cCIPHER_MD5...
     D                 C                   const(x'00')
     D cCIPHER_HASH...
     D                 C                   const(x'00')
     D cCIPHER_HMAC...
     D                 C                   const(x'01')
     D cCIPHER_ONLY...
     D                 C                   const(x'00')
      *
     D MD5_CTX_t       DS                  qualified               based(pDummy)
     D  key                          16A
     D  context                     160A
     D  state                         1A
     D  digest                       16A
      *
     D rc4_ctx_t       ds                  qualified  based(pDummy)
     D   stream                     256A
     D   length                       5U 0
     D   reserved                     6A
      *
      *  Encrypt Data (QC3ENCDT, Qc3EncryptData) API
      /if defined(NTLM_SUPPORT)
     D Qc3EncryptData...
     D                 PR                  extproc('Qc3EncryptData')
     D  i_clearData               65535A   const  options(*varsize)
     D  i_length                     10I 0 const
     D  i_dataFormat                  8A   const
     D  i_algDesc                 65535A   const  options(*varsize)
     D  i_algFormat                   8A   const
     D  i_keyDesc                 65535A   const  options(*varsize)
     D  i_keyFormat                   8A   const
     D  i_cyptSrvPrv                  1A   const
     D  i_cyptDevNme                 10A   const
     D  o_encypted                65535A          options(*varsize)
     D  i_encLenPrv                  10I 0 const
     D  o_encLenRet                  10I 0
     D  io_ErrCode                32767A          options(*nopass: *varsize)
      /endif

     D algd0200_t      DS                  qualified               based(pDummy)
     D  algorithm                    10I 0
     D  blockLen                     10I 0
     D  mode                          1A
     D  padOption                     1A
     D  padChar                       1A
     D  reserved_1                    1A
     D  macLen                       10I 0
     D  keySize                      10I 0
     D  initVector                   32A
      *
     D keyd0200_t      DS                  qualified               based(pDummy)
     D  type                         10I 0
     D  length                       10I 0
     D  format                        1A
     D  reserved_1                    3A
     D  value                         8A
      *
      * ------------------------------------
      *  Global fields
      * ------------------------------------
      *
      *=====================================================================*
    R *  *** Exported, because internally used by NTLMR4, RPGUNIT tests ***
      *  Encrypts a given string using the RC4 algorithm
      *=====================================================================*
     P RC4...
     P                 B                   export
      *
     D RC4...
     D                 PI          4096A          varying
     D  i_key                              const  like(RC4_key_t   )
     D  i_string                   4096A          varying options(*varsize)
      *
      *  Return value
     D digest          S           4096A   varying inz
      *
      *  Local fields
     D controls        DS                  likeds(cipherCtrls_0013_t) inz
     D rc4_ctx         DS                  likeds(rc4_ctx_t         ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (i_string = '');
            return '';
         endif;

         rc4_ctx = *ALLx'00';
         %subst(rc4_ctx.stream: 1: %len(i_key)) = i_key;
         rc4_ctx.length = %len(i_key);
         rc4_ctx.reserved = *ALLx'00';

         controls = *ALLx'00';

         controls.function   = x'0013';          // RC4
         controls.dataLength = %len(i_string);
         controls.operation  = cCIPHER_ENCRYPT;  // Hex 00 = Encrypt
                                                 // Hex 01 = Decrypt
         controls.reserved   = *ALLx'00';
         controls.keyCtxPtr  = %addr(rc4_ctx);

         %len(digest) = %len(i_string);
         cipher(%addr(digest)+2: %addr(controls): %addr(i_string)+2);

         return digest;

      /END-FREE
      *
     P RC4...
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by NTLMR4, RPGUNIT tests ***
      *  Encrypts a given string using the DES algorithm
      *=====================================================================*
     P DES...
     P                 B                   export
      *
     D DES...
     D                 PI          4096A          varying
     D  i_string                   4096A   const  varying options(*varsize)
     D  i_challenge                        const  like(ntlm_challenge_t )
      *
      *  Return value
     D encrypted       S           4096A   varying inz
      *
      *  Local fields
     D tmpEncrypted    S           4096A   inz
     D encryptedLen    S             10I 0 inz
      *
     D algd0200        DS                  likeds(algd0200_t ) inz
     D keyd0200        DS                  likeds(keyd0200_t ) inz
     D errCode         DS                  likeds(errCode_t  ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (i_string = '');
            return i_string;
         endif;

         algd0200 = *ALLx'00';
         algd0200.algorithm  = 20;
         algd0200.blockLen   = 8;
         algd0200.mode       = '0';
         algd0200.padOption  = '1';
         algd0200.padChar    = x'00';
         algd0200.reserved_1 = *ALLx'00';
         algd0200.macLen     = 0;
         algd0200.keySize    = 0;
         algd0200.initVector = *ALLx'00';

         keyd0200 = *ALLx'00';
         keyd0200.type       = 20;
         keyd0200.length     = 8;
         keyd0200.format     = '0';
         keyd0200.reserved_1 = *ALLx'00';
         keyd0200.value      = i_challenge;

         clear errCode;
      /if defined(NTLM_SUPPORT)
         Qc3EncryptData(i_string              // Clear data
                        : %len(i_string)      // Length of clear data
                        : 'DATA0100'          // Clear data format name
                        : algd0200            // Algorithm description
                        : 'ALGD0200'          // Algorithm description format name
                        : keyd0200            // Key description
                        : 'KEYD0200'          // Key description format name
                        : '0'                 // Cryptographic service provider
                        : ''                  // Cryptographic device name
                        : tmpEncrypted        // Encrypted data
                        : %size(tmpEncrypted) // Length of area provided for encrypted data
                        : encryptedLen        // Length of encrypted data returned
                        : errCode);           // Error code
      /endif
         encrypted = %subst(tmpEncrypted: 1: encryptedLen);

         return encrypted;

      /END-FREE
      *
     P DES...
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by NTLMR4, RPGUNIT tests ***
      *  Calculates a DES key from a given key value.
      *=====================================================================*
     P DES_produceKey...
     P                 B                   export
      *
     D DES_produceKey...
     D                 PI                         like(DES_key_t )
     D  i_value                       7A   const
      *
      *  Return value
     D desKey          S                   like(DES_key_t ) inz(x'00')
      *
      *  Local fields
     D x               S             10I 0 inz
     D i               S             10I 0 inz
     D char            S              1A   inz(x'00')
      *
     D inp             DS                  qualified
     D  lm_byte                1      1A
     D  lm_int4                1      4U 0
     D  lm_int4_4              4      4A
     D  rm_int4_1              5      5A
     D  rm_int4                5      8U 0
     D  value                  1      7A
     D  rm_byte                8      8A   inz(x'00')
      *
     D tmp             DS                  qualified
     D  int4                   1      4I 0 inz
     D  byte                   4      4    inz(x'00')
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         inp = *ALLx'00';
         inp.value = i_value;

         for x = 1 to 8;

            // get the 7 left most bits of the left most byte
            char = byteand(inp.lm_byte: x'FE');

            // set parity bit
            char = setParityBit(char);

            // put result into the DES key value
            i = i + 1;
            %subst(desKey: i: 1) = char;

            // shift the 4 left most bytes 7 bits to the left
            inp.lm_int4 = bitand(inp.lm_int4: x'01FFFFFF');
            inp.lm_int4 = inp.lm_int4 * 128;

            // shift the 7 left most bits of byte 5 to byte 4
            tmp.byte = byteand(inp.rm_int4_1: x'FE');
            tmp.int4 = tmp.int4 / 2;
            inp.lm_int4_4 = byteor(inp.lm_int4_4: tmp.byte);

            // shift the 4 right most bytes 7 bits to the left
            inp.rm_int4 = bitand(inp.rm_int4: x'01FFFFFF');
            inp.rm_int4 = inp.rm_int4 * 128;

         endfor;

         return desKey;

      /END-FREE
      *
     P DES_produceKey...
     P                 E
      *
      *=====================================================================*
    R *  *** Private ***
      *  Calculates the odd parity bit for each byte
      *  of a given value.
      *=====================================================================*
     P setParityBit...
     P                 B
      *
     D setParityBit...
     D                 PI             1A
     D  i_char                        1A   const
      *
      *  Return value
     D char            S              1A   inz
      *
      *  Local fields
     D x               S             10I 0 inz
     D num1Bits        S             10I 0 inz
      *
     D bit             S              1A   dim(7)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         bit(7) = byteand(i_char: x'80') = x'80';
         bit(6) = byteand(i_char: x'40') = x'40';
         bit(5) = byteand(i_char: x'20') = x'20';
         bit(4) = byteand(i_char: x'10') = x'10';
         bit(3) = byteand(i_char: x'08') = x'08';
         bit(2) = byteand(i_char: x'04') = x'04';
         bit(1) = byteand(i_char: x'02') = x'02';

         for x = 1 to %elem(bit);
            if (bit(x)) = '1';
               num1Bits = num1Bits + 1;
            endif;
         endfor;

         if (%rem(num1Bits: 2) = 0);
            char = byteor(i_char: x'01');
         else;
            char = byteand(i_char: x'FE');
         endif;

         return char;

      /END-FREE
      *
     P setParityBit...
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by NTLMR4, RPGUNIT tests ***
      *  MD4 operation.
      *=====================================================================*
     P MD4...
     P                 B                   export
      *
     D MD4...
     D                 PI                         like(MD4_digest_t )
     D  i_string                   4096A          varying options(*varsize)
      *
      *  Return value
     D digest          S                   like(MD4_digest_t ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         MD4Only_r(digest: %addr(i_string)+2: %len(i_string));

         return digest;

      /END-FREE
      *
     P MD4...
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by NTLMR4, RPGUNIT tests ***
      *  Returns the MD5 digest of a given string.
      *=====================================================================*
     P MD5Hmac...
     P                 B                   export
      *
     D MD5Hmac...
     D                 PI                         like(MD5_digest_t)
     D  i_hmacKey                          const  like(MD5_digest_t)
     D  i_string                   4096A          varying options(*varsize)
      *
      *  Return value
     D digest          S                   like(MD5_digest_t   )
      *
      *  Local fields
     D controls        DS                  likeds(cipherCtrls_0005_t) inz
     D MD5_CTX         DS                  likeds(MD5_CTX_t         ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (i_string = '');
            return '';
         endif;

         MD5_CTX.key = i_hmacKey;
         MD5_CTX.context = *ALLx'00';
         MD5_CTX.state = cCIPHER_ONLY;
         MD5_CTX.digest = *ALLx'00';

         controls = *ALLx'00';

         controls.function      = x'0005';       // MD5 or SHA-1
         controls.hashAlg       = cCIPHER_MD5;   // Hex 00 = MD5
                                                 // Hex 01 = SHA-1
         controls.sequence      = MD5_CTX.state; // Hex 00 = Only
                                                 // Hex 01 = First
                                                 // Hex 02 = Middle
                                                 // Hex 03 = Final
         controls.dataLength    = %len(i_string);
         controls.output        = cCIPHER_HMAC;  // Hex 00 =  Hash
                                                 // Hex 01 =  HMAC
         controls.hashContext   = %addr(MD5_CTX.context);
         controls.HMACKey       = %addr(MD5_CTX.key);
         controls.HMACKeyLength = %size(MD5_CTX.key);

         cipher(%addr(MD5_CTX.digest): %addr(controls): %addr(i_string)+2);

         digest = MD5_CTX.digest;

         return digest;

      /END-FREE
      *
     P MD5Hmac...
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by NTLMR4, RPGUNIT tests ***
      *  Returns the MD5 digest of a given string.
      *=====================================================================*
     P MD5Digest...
     P                 B                   export
      *
     D MD5Digest...
     D                 PI                         like(MD5_digest_t)
     D  i_string                   4096A          varying options(*varsize)
      *
      *  Return value
     D digest          S                   like(MD5_digest_t   )
      *
      *  Local fields
     D controls        DS                  likeds(cipherCtrls_0005_t) inz
     D MD5_CTX         DS                  likeds(MD5_CTX_t         ) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (i_string = '');
            return '';
         endif;

         MD5_CTX.key = *ALLx'00';
         MD5_CTX.context = *ALLx'00';
         MD5_CTX.state = cCIPHER_ONLY;
         MD5_CTX.digest = *ALLx'00';

         controls = *ALLx'00';

         controls.function      = x'0005';       // MD5 or SHA-1
         controls.hashAlg       = cCIPHER_MD5;   // Hex 00 = MD5
                                                 // Hex 01 = SHA-1
         controls.sequence      = MD5_CTX.state; // Hex 00 = Only
                                                 // Hex 01 = First
                                                 // Hex 02 = Middle
                                                 // Hex 03 = Final
         controls.dataLength    = %len(i_string);
         controls.output        = cCIPHER_HASH;  // Hex 00 =  Hash
                                                 // Hex 01 =  HMAC
         controls.hashContext   = %addr(MD5_CTX.context);
         controls.HMACKey       = *NULL;
         controls.HMACKeyLength = 0;

         cipher(%addr(MD5_CTX.digest): %addr(controls): %addr(i_string)+2);

         digest = MD5_CTX.digest;

         return digest;

      /END-FREE
      *
     P MD5Digest...
     P                 E
      *
