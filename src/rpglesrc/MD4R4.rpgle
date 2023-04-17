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
      *  NTLM: MD4 message-digest algorithm                                 *
      *=====================================================================*
      *  Author  :  Thomas Raddatz                                          *
      *  Date    :  22.05.2012                                              *
      *  E-mail  :  thomas.raddatz@Tools400.de                              *
      *  Homepage:  www.tools400.de                                         *
      *=====================================================================*
      *  History:                                                           *
      *                                                                     *
      *  Date        Name          Description                              *
      *  ----------  ------------  ---------------------------------------  *
      *                                                                     *
      *=====================================================================*
     H OPTION(*SRCSTMT: *NODEBUGIO)
     H NOMAIN
      *=====================================================================*
      *
      * ------------------------------------
      *  Type Definitions
      * ------------------------------------
     D UINT2           S              5U 0                         based(pDummy)
     D UINT4           S             10U 0                         based(pDummy)
      *
     D S11             C                   3
     D S12             C                   7
     D S13             C                   11
     D S14             C                   19
     D S21             C                   3
     D S22             C                   5
     D S23             C                   9
     D S24             C                   13
     D S31             C                   3
     D S32             C                   9
     D S33             C                   11
     D S34             C                   15
      *
      * ------------------------------------
      *  Exported prototypes
      * ------------------------------------
      /COPY MD4_H
      *
      * ------------------------------------
      *  Imported prototypes
      * ------------------------------------
      *
      *  memcpy -- Copy Bytes
      *     The behavior is undefined if copying takes place
      *     between objects that overlap.
      *     The memcpy() function returns a pointer to dest.
     D memcpy          PR              *          extproc('memcpy')
     D  i_pDest                        *   value
     D  i_pSrc                         *   value
     D  i_count                      10U 0 value
      *
      * ------------------------------------
      *  Internal prototypes
      * ------------------------------------
      *
      *  MD4 basic transformation. Transforms state based on block.
     D MD4Transform...
     D                 PR
     D                                     extproc('MD4Transform')
     D  io_state                                  like(UINT4) dim(4)
     D  i_input                        *   value
      *
      *  Decodes input (unsigned char) into output (UINT4).
     D Decode...
     D                 PR
     D                                     extproc('Decode')
     D  o_output                                  like(UINT4) dim(16)
     D  i_input                       1A   const  dim(64)
      *
      *  Encodes input (UINT4) into output (unsigned char). Assumes
      *  len is a multiple of 4.
     D Encode...
     D                 PR
     D                                     extproc('Encode')
     D  o_output                      1A          dim(64) options(*varsize)
     D  i_input                       1A          dim(64) options(*varsize)
     D  i_len                        10U 0 value
      *
      *  Shift left.
     D shiftL...
     D                 PR            10U 0
     D                                     extproc('shiftL')
     D  i_value                      10U 0 value
     D  i_bits                       10U 0 value
      *
      *  Shift right.
     D shiftR...
     D                 PR            10U 0
     D                                     extproc('shiftR')
     D  i_value                      10U 0 value
     D  i_bits                       10U 0 value
      *
      *  F, G and H are basic MD4 functions.
     D F...
     D                 PR            10U 0
     D                                     extproc('F')
     D  x                            10U 0 const
     D  y                            10U 0 const
     D  z                            10U 0 const
      *
     D G...
     D                 PR            10U 0
     D                                     extproc('G')
     D  x                            10U 0 const
     D  y                            10U 0 const
     D  z                            10U 0 const
      *
     D H...
     D                 PR            10U 0
     D                                     extproc('H')
     D  x                            10U 0 const
     D  y                            10U 0 const
     D  z                            10U 0 const
      *
      *  Rotates x left n bits.
     D ROTATE_LEFT...
     D                 PR            10U 0
     D                                     extproc('ROTATE_LEFT')
     D  x                            10U 0 const
     D  n                            10U 0 const
      *
      *  FF, GG and HH are transformations for rounds 1, 2 and 3 */
     D FF...
     D                 PR
     D                                     extproc('FF')
     D  a                            10U 0
     D  b                            10U 0 const
     D  c                            10U 0 const
     D  d                            10U 0 const
     D  x                            10U 0 const
     D  s                            10U 0 const
      *
     D GG...
     D                 PR
     D                                     extproc('GG')
     D  a                            10U 0
     D  b                            10U 0 const
     D  c                            10U 0 const
     D  d                            10U 0 const
     D  x                            10U 0 const
     D  s                            10U 0 const
      *
     D HH...
     D                 PR
     D                                     extproc('HH')
     D  a                            10U 0
     D  b                            10U 0 const
     D  c                            10U 0 const
     D  d                            10U 0 const
     D  x                            10U 0 const
     D  s                            10U 0 const
      *
      *  Truncates a given value to a 4-byte unsigned integer value.
     D truncate...
     D                 PR            10U 0
     D                                     extproc('truncate')
     D  i_value                      20U 0 value
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  MD4 initialization. Begins an MD4 operation, writing a new context.
      *=====================================================================*
     P MD4Init_r...
     P                 B                   export
      *
     D MD4Init_r...
     D                 PI
     D  context                                   likeds(MD4_CTX_t)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         context.count(1) = 0;
         context.count(2) = 0;

         context.state(1) = x'67452301';
         context.state(2) = x'efcdab89';
         context.state(3) = x'98badcfe';
         context.state(4) = x'10325476';

         return;

      /END-FREE
      *
     P MD4Init_r...
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  MD4 block update operation. Continues an MD4 message-digest
      *  operation, processing another message block, and updating the
      *  context.
      *=====================================================================*
     P MD4Update_r...
     P                 B                   export
      *
     D MD4Update_r...
     D                 PI
     D  context                                   likeds(MD4_CTX_t)
     D  input                          *   value
     D  inputLen                     10U 0 value
      *
      *  Local fields
     D i               S             10U 0 inz
     D index           S             10U 0 inz
     D partLen         S             10U 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         // Compute number of bytes mod 64
         index = %bitand(shiftR(context.count(1): 3): x'3F');

         // Update number of bits
         context.count(1) = context.count(1) + shiftL(inputLen: 3);
         if (context.count(1) < shiftL(inputLen: 3));
            context.count(2) = context.count(2) + 1;
         endif;
         context.count(2) = context.count(2) + shiftR(inputLen: 29);

         partLen = 64 - index;

         // Transform as many times as possible.
         if (inputLen >= partLen);
            memcpy(%addr(context.buffer) + index: input: partLen);

            MD4Transform(context.state: %addr(context.buffer));

            i = partLen;
            dow (i + 63 < inputLen);
               MD4Transform(context.state: input + i - 1);
               i = i + 64;
            enddo;

            index = 0;
         else;
            i = 0;
         endif;

         // Buffer remaining input
         memcpy(%addr(context.buffer) + index: input + i: inputLen - i);

         return;

      /END-FREE
      *
     P MD4Update_r...
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by RPGUNIT tests ***
      *  MD4 finalization. Ends an MD4 message-digest operation, writing
      *  the message digest and zeroizing the context.
      *=====================================================================*
     P MD4Final_r...
     P                 B                   export
      *
     D MD4Final_r...
     D                 PI
     D  digest                       16A
     D  context                                   likeds(MD4_CTX_t)
      *
      *  Local fields
     D bits            S              8A   inz(*ALLx'00')
     D index           S             10U 0 inz
     D padLen          S             10U 0 inz
      *
     D PADDING         S             64A   inz(
     D                                     x'80000000000000000000000000000000+
     D                                       00000000000000000000000000000000+
     D                                       00000000000000000000000000000000+
     D                                       00000000000000000000000000000000')
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         // Save number of bits
         Encode(bits: context.countA: 8);

         // Pad out to 56 mod 64.
         index = %bitand(shiftR(context.count(1): 3): x'3f');
         if (index < 56);
            padLen = 56 - index;
         else;
            padLen = 120 - index;
         endif;

         MD4Update_r(context: %addr(PADDING): padLen);

         // Append length (before padding)
         MD4Update_r(context: %addr(bits): 8);

         // Store state in digest
         Encode(digest: context.stateA: 16);

         // Zeroize sensitive information.
         clear context;

         return;

      /END-FREE
      *
     P MD4Final_r...
     P                 E
      *
      *=====================================================================*
    R *  *** Exported because, internally used by ENCRYPTR4, RPGUNIT tests ***
      *  MD4 operation.
      *=====================================================================*
     P MD4Only_r...
     P                 B                   export
      *
     D MD4Only_r...
     D                 PI
     D  digest                                  like(MD4_digest_t)
     D  input                          *   value
     D  inputLen                     10U 0 value
      *
      *  Local fields
     D context         DS                  likeds(MD4_CTX_t) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         MD4Init_r(context);
         MD4Update_r(context: input: inputLen);
         MD4Final_r(digest: context);

         return;

      /END-FREE
      *
     P MD4Only_r...
     P                 E
      *
      *=====================================================================*
      *  MD4 basic transformation. Transforms state based on block.
      *=====================================================================*
     P MD4Transform...
     P                 B
      *
     D MD4Transform...
     D                 PI
     D  io_state                                  like(UINT4) dim(4)
     D  i_input                        *   value
      *
     D a               S                   like(UINT4)
     D b               S                   like(UINT4)
     D c               S                   like(UINT4)
     D d               S                   like(UINT4)
     D x               S                   like(UINT4) dim(16)
      *
     D block           S              1A   based(i_input) dim(64)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         a = io_state(1);
         b = io_state(2);
         c = io_state(3);
         d = io_state(4);

         Decode(x: block);

         // Round 1
         FF (a: b: c: d: x( 0+1): S11); //* 1 */
         FF (d: a: b: c: x( 1+1): S12); //* 2 */
         FF (c: d: a: b: x( 2+1): S13); //* 3 */
         FF (b: c: d: a: x( 3+1): S14); //* 4 */
         FF (a: b: c: d: x( 4+1): S11); //* 5 */
         FF (d: a: b: c: x( 5+1): S12); //* 6 */
         FF (c: d: a: b: x( 6+1): S13); //* 7 */
         FF (b: c: d: a: x( 7+1): S14); //* 8 */
         FF (a: b: c: d: x( 8+1): S11); //* 9 */
         FF (d: a: b: c: x( 9+1): S12); //* 10 */
         FF (c: d: a: b: x(10+1): S13); //* 11 */
         FF (b: c: d: a: x(11+1): S14); //* 12 */
         FF (a: b: c: d: x(12+1): S11); //* 13 */
         FF (d: a: b: c: x(13+1): S12); //* 14 */
         FF (c: d: a: b: x(14+1): S13); //* 15 */
         FF (b: c: d: a: x(15+1): S14); //* 16 */

         // Round 2
         GG (a: b: c: d: x( 0+1): S21);
         GG (d: a: b: c: x( 4+1): S22); //* 18 */
         GG (c: d: a: b: x( 8+1): S23); //* 19 */
         GG (b: c: d: a: x(12+1): S24); //* 20 */
         GG (a: b: c: d: x( 1+1): S21); //* 21 */
         GG (d: a: b: c: x( 5+1): S22); //* 22 */
         GG (c: d: a: b: x( 9+1): S23); //* 23 */
         GG (b: c: d: a: x(13+1): S24); //* 24 */
         GG (a: b: c: d: x( 2+1): S21); //* 25 */
         GG (d: a: b: c: x( 6+1): S22); //* 26 */
         GG (c: d: a: b: x(10+1): S23); //* 27 */
         GG (b: c: d: a: x(14+1): S24); //* 28 */
         GG (a: b: c: d: x( 3+1): S21); //* 29 */
         GG (d: a: b: c: x( 7+1): S22); //* 30 */
         GG (c: d: a: b: x(11+1): S23); //* 31 */
         GG (b: c: d: a: x(15+1): S24); //* 32 */

         // Round 3
         HH (a: b: c: d: x( 0+1): S31); //* 33 */
         HH (d: a: b: c: x( 8+1): S32); //* 34 */
         HH (c: d: a: b: x( 4+1): S33); //* 35 */
         HH (b: c: d: a: x(12+1): S34); //* 36 */
         HH (a: b: c: d: x( 2+1): S31); //* 37 */
         HH (d: a: b: c: x(10+1): S32); //* 38 */
         HH (c: d: a: b: x( 6+1): S33); //* 39 */
         HH (b: c: d: a: x(14+1): S34); //* 40 */
         HH (a: b: c: d: x( 1+1): S31); //* 41 */
         HH (d: a: b: c: x( 9+1): S32); //* 42 */
         HH (c: d: a: b: x( 5+1): S33); //* 43 */
         HH (b: c: d: a: x(13+1): S34); //* 44 */
         HH (a: b: c: d: x( 3+1): S31); //* 45 */
         HH (d: a: b: c: x(11+1): S32); //* 46 */
         HH (c: d: a: b: x( 7+1): S33); //* 47 */
         HH (b: c: d: a: x(15+1): S34); //* 48 */

         io_state(1) = truncate(io_state(1) + a);
         io_state(2) = truncate(io_state(2) + b);
         io_state(3) = truncate(io_state(3) + c);
         io_state(4) = truncate(io_state(4) + d);

         // Zeroize sensitive information.
         clear x;

         return;

      /END-FREE
      *
     P MD4Transform...
     P                 E
      *
      *=====================================================================*
      *  Decodes input (unsigned char) into output (UINT4).
      *=====================================================================*
     P Decode...
     P                 B
      *
     D Decode...
     D                 PI
     D  o_output                                  like(UINT4) dim(16)
     D  i_input                       1A   const  dim(64)
      *
     D output          S              1A   dim(64) based(pOutput)
      *
     D i               S             10U 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         pOutput = %addr(o_output);

         for i = 1 to %elem(i_input) by 4;
            output(i) = i_input(i+3);
            output(i+1) = i_input(i+2);
            output(i+2) = i_input(i+1);
            output(i+3) = i_input(i);
         endfor;

         return;

      /END-FREE
      *
     P Decode...
     P                 E
      *
      *=====================================================================*
      *  Encodes input (UINT4) into output (unsigned char). Assumes
      *  len is a multiple of 4.
      *=====================================================================*
     P Encode...
     P                 B
      *
     D Encode...
     D                 PI
     D  o_output                      1A          dim(64) options(*varsize)
     D  i_input                       1A          dim(64) options(*varsize)
     D  i_len                        10U 0 value
      *
     D i               S             10U 0 inz
     D j               S             10U 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         j = 1;

         dow (j <= i_len);
            o_output(j) = i_input(j+3);
            o_output(j+1) = i_input(j+2);
            o_output(j+2) = i_input(j+1);
            o_output(j+3) = i_input(j);
            j = j + 4;
         enddo;

         return;

      /END-FREE
      *
     P Encode...
     P                 E
      *
      *=====================================================================*
      *  Shift left.
      *=====================================================================*
     P shiftL...
     P                 B
      *
     D shiftL...
     D                 PI            10U 0
     D  i_value                      10U 0 value
     D  i_bits                       10U 0 value
      *
      *  Required to avoid overflow.
     D result          DS                  qualified
     D  highUint               1      4U 0 inz
     D  lowUInt                5      8U 0 inz
     D  ULong                  1      8U 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         result.lowUInt = i_value;

         dow (i_bits > 0);
            result.ULong = result.lowUInt * 2;
            i_bits = i_bits - 1;
         enddo;

         return result.lowUInt;

      /END-FREE
      *
     P shiftL...
     P                 E
      *
      *=====================================================================*
      *  Shift right.
      *=====================================================================*
     P shiftR...
     P                 B
      *
     D shiftR...
     D                 PI            10U 0
     D  i_value                      10U 0 value
     D  i_bits                       10U 0 value
      *
      *  Required to avoid overflow.
     D result          DS                  qualified
     D  highUint               1      4U 0 inz
     D  lowUInt                5      8U 0 inz
     D  ULong                  1      8U 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         result.lowUInt = i_value;

         dow (i_bits > 0);
            result.ULong = result.lowUInt / 2;
            i_bits = i_bits - 1;
         enddo;

         return result.lowUInt;

      /END-FREE
      *
     P shiftR...
     P                 E
      *
      *=====================================================================*
      *  Basic MD4 function.
      *=====================================================================*
     P F...
     P                 B
      *
     D F...
     D                 PI            10U 0
     D  x                            10U 0 const
     D  y                            10U 0 const
     D  z                            10U 0 const
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         // (((x) & (y)) ] ((ßx) & (z)))
         return %bitor(%bitand(x: y): %bitand(%bitnot(x): z));

      /END-FREE
      *
     P F...
     P                 E
      *
      *=====================================================================*
      *  Basic MD4 function.
      *=====================================================================*
     P G...
     P                 B
      *
     D G...
     D                 PI            10U 0
     D  x                            10U 0 const
     D  y                            10U 0 const
     D  z                            10U 0 const
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         // (((x) & (y)) ] ((x) & (z)) ] ((y) & (z)))
         return %bitor(%bitand(x: y): %bitand(x: z): %bitand(y: z));

      /END-FREE
      *
     P G...
     P                 E
      *
      *=====================================================================*
      *  Basic MD4 function.
      *=====================================================================*
     P H...
     P                 B
      *
     D H...
     D                 PI            10U 0
     D  x                            10U 0 const
     D  y                            10U 0 const
     D  z                            10U 0 const
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         // ((x) ¬ (y) ¬ (z))
         return %bitxor(%bitxor(x: y): z);

      /END-FREE
      *
     P H...
     P                 E
      *
      *=====================================================================*
      *  Rotates x left n bits.
      *=====================================================================*
     P ROTATE_LEFT...
     P                 B
      *
     D ROTATE_LEFT...
     D                 PI            10U 0
     D  x                            10U 0 const
     D  n                            10U 0 const
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         return %bitor(shiftL(x: n): shiftR(x: 32-n));

      /END-FREE
      *
     P ROTATE_LEFT...
     P                 E
      *
      *=====================================================================*
      *  FF, GG and HH are transformations for rounds 1, 2 and 3 */
      *=====================================================================*
     P FF...
     P                 B
      *
     D FF...
     D                 PI
     D  a                            10U 0
     D  b                            10U 0 const
     D  c                            10U 0 const
     D  d                            10U 0 const
     D  x                            10U 0 const
     D  s                            10U 0 const
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         // (a) += F ((b), (c), (d)) + (x);
         a = truncate(a + F(b: c: d) + x);

         // (a) = ROTATE_LEFT ((a), (s));
         a = ROTATE_LEFT(a: s);

         return;

      /END-FREE
      *
     P FF...
     P                 E
      *
      *=====================================================================*
      *  FF, GG and HH are transformations for rounds 1, 2 and 3 */
      *=====================================================================*
     P GG...
     P                 B
      *
     D GG...
     D                 PI
     D  a                            10U 0
     D  b                            10U 0 const
     D  c                            10U 0 const
     D  d                            10U 0 const
     D  x                            10U 0 const
     D  s                            10U 0 const
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         // (a) += G ((b), (c), (d)) + (x) + (UINT4)0x5a827999;
         a = truncate(a + G(b: c: d) + x + x'5a827999');

         // (a) = ROTATE_LEFT ((a), (s));
         a = ROTATE_LEFT(a: s);

         return;

      /END-FREE
      *
     P GG...
     P                 E
      *
      *=====================================================================*
      *  FF, GG and HH are transformations for rounds 1, 2 and 3 */
      *=====================================================================*
     P HH...
     P                 B
      *
     D HH...
     D                 PI
     D  a                            10U 0
     D  b                            10U 0 const
     D  c                            10U 0 const
     D  d                            10U 0 const
     D  x                            10U 0 const
     D  s                            10U 0 const
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         // (a) += H ((b), (c), (d)) + (x) + (UINT4)0x6ed9eba1; Ö
         a = truncate(a + H(b: c: d) + x + x'6ed9eba1');

         // (a) = ROTATE_LEFT ((a), (s));
         a = ROTATE_LEFT(a: s);

         return;

      /END-FREE
      *
     P HH...
     P                 E
      *
      *=====================================================================*
      *  Truncates a given value to a 4-byte unsigned integer value.
      *=====================================================================*
     P truncate...
     P                 B
      *
     D truncate...
     D                 PI            10U 0
     D  i_value                      20U 0 value
      *
      *  Required to avoid overflow.
     D result          DS                  qualified
     D  highUint               1      4U 0 inz
     D  lowUInt                5      8U 0 inz
     D  ULong                  1      8U 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         result.ULong = i_value;

         return result.lowUInt;

      /END-FREE
      *
     P truncate...
     P                 E
      *
