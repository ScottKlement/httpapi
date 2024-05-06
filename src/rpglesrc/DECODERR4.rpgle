     /*-                                                                            +
      * Copyright (c) 2019-2024 Scott C. Klement                               +
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
      * DECODERR4 -- Decoding routines for HTTPAPI
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

     D p_Mpr           s               *
     D dsMpr           ds                  based(p_Mpr)
     D   dsMpr_root                  64A   varying
     D   dsMpr_bound                 64A   varying
     D   dsMpr_fd                    10I 0
     D   dsMpr_Data                    *
     D   dsMpr_StrPrc                  *   procptr
     D   dsMpr_PrtPrc                  *   procptr
     D   dsMpr_EndPrc                  *   procptr

     D upper           C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D lower           C                   'abcdefghijklmnopqrstuvwxyz'

     D part_header_parse...
     D                 PR
     D   resp                     65535A   varying const

     D part_header_clean...
     D                 PR

     D part_header_find...
     D                 PR            10I 0
     D   name                       256A   varying const
     D   pos                         10I 0 value

     D toUppercase     PR         65535A   varying
     D   peString                 65535A   varying const

     D phdrs           s             10I 0 inz(0)

     D phdr            ds                  occurs(4000)
     D  phdr_name                   256A   varying
     D  phdr_idx                     10I 0
     D  phdr_len                     10I 0
     D  phdr_fill                     8A
     D  phdr_ptr                       *

     D pheader         s          32500A   based(p_pheader)

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mpr_decoder_open(): Create a multipart/related decoder
      *
      * The procedure initalize the parser of a multipart/related
      * response message.
      *
      *   peStmFile   = (input) pathname to stream file from which
      *                 to read the parts to be decoded.
      *
      *   peContType  = (input) the entire content type as from
      *                 received by httpapi.
      *
      *   peUserData  = (input) the pointer to the memory address
      *                 where custom data are stored.
      *
      *   peStartProc = (input) the procedure to launch when a
      *                 new part is starting to be processed.
      *                 The procedure has this interface:
      * D StartPrc        PR
      * D   userdata                      *   value
      * D   isRoot                        N   const
      *                 userdata = the same pointer passed with peUserdata.
      *                 isRoot   = *ON if the part is the starting point
      *                            of the multipart/related message.
      *
      *   pePartProc  = (input) the procedure to launch when a
      *                 new batch of part info is processed.
      *                 The procedure has this interface:
      * D PartPrc         PR
      * D   userdata                      *   value
      * D   data                          *   value
      * D   datalen                     10I 0 const
      *                 userdata = the same pointer passed with peUserdata.
      *                 data     = pointer to the next chunck of data to write.
      *                 dataLen  = lenght of the chunck.
      *
      *   peEndProc   = (input) the procedure to launch at the
      *                 end of a part processing.
      *                 The procedure has this interface:
      *
      * D EndPrc          PR
      * D   userdata                      *   value
      *                 userdata = the same pointer passed with peUserdata.
      *
      *   Note: all the passed procedures can use part_header() to
      *         retrieve a header specific for that part
      *         (example: part_header("Content-ID")).
      *
      *   returns an (opaque) pointer to the new decoder
      *           or *NULL upon error.
      *
      * WARNING: To free the memory used by this routine and close
      *          the stream file, you MUST call http_mpr_decoder_close()
      *          after the data is parsed.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_mpr_decoder_open...
     P                 B                   export
     D http_mpr_decoder_open...
     D                 PI              *
     D  peStmFile                      *   value options(*string)
     D  peContType                  256A   const varying
     D  peUserData                     *   value
     D  peStartProc                    *   procptr value
     D  pePartProc                     *   procptr value
     D  peEndProc                      *   procptr value

     D wwFilename      s          32767a   varying
     D wwFD            s             10I 0
     D wwBoundary      s             64A   varying
     D wwStartId       s             64A   varying
     D wwRetVal        s               *
     D pos1            s             10I 0
     D pos2            s             10I 0
     D isRoot          s               n

      *************************************************
      *  Open the file that contain the results
      *************************************************
     c                   eval      wwFilename = %trimr(%str(peStmFile))
     c                   eval      wwFD = open( wwFilename : O_RDONLY )

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
      * Parse the content to get the boundary and
      * eventually the id of the starting part
      *************************************************
     c                   eval      pos1 = %scan('BOUNDARY="'
     c                                         : toUppercase(peContType))
     c                   eval      pos1 = pos1 + %len('BOUNDARY="')
     c                   eval      pos2 = %scan('"':peContType:pos1)
     c                   eval      wwBoundary = %subst( peContType
     c                                                : pos1
     c                                                : pos2-pos1)

     c                   eval      pos1 = %scan('START="'
     c                                         : toUppercase(peContType))
     c                   if        pos1 > 0
     c                   eval      pos1 = pos1 + %len('START="')
     c                   eval      pos2 = %scan('"':peContType:pos1)
     c                   eval      wwStartId = %subst( peContType
     c                                                : pos1
     c                                                : pos2-pos1)
     c                   endif

      *************************************************
      * Set up MPR structure
      *************************************************
     c                   eval      p_Mpr = wwRetVal
     c                   eval      dsMpr_root = wwStartId
     c                   eval      dsMpr_bound = wwBoundary
     c                   eval      dsMpr_fd = wwFD
     c                   eval      dsMpr_Data = peUserData
     c                   eval      dsMpr_StrPrc = peStartProc
     c                   eval      dsMpr_PrtPrc = pePartProc
     c                   eval      dsMpr_EndPrc = peEndProc

     c                   return    wwRetVal
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mpr_decoder_parse(): Start the parsing process calling
      *          the given procedures at each step.
      *
      *    peDecoder = pointer to decoder created by the
      *                  http_mpr_decoder_open() routine
      *
      * Returns *ON if successful, *OFF otherwise.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_mpr_decoder_parse...
     P                 B                   export
     D http_mpr_decoder_parse...
     D                 PI             1N
     D    peDecoder                    *   value

     D CRLFA           c                   x'0d0a'
     D CR              c                   x'0d'
     D p_buffer        s               *
     D buffer          s           1025A   based(p_buffer)

     D line            s                   like(buffer)
     D lineLen         s             10I 0
     D tbw             s                   like(buffer)
     D tbwLen          s             10I 0

     D rd              s             10I 0
     D bytesr          s             10I 0
     D left            s             10I 0

     D wwBound         s             68A   varying
     D wwBoundEnd      s             70A   varying

     D isRoot          s               N
     D subHdrs         s             10I 0 inz(0)
     D subHdr          ds                  occurs(4000)
     D  subHdr_name                 256A   varying
     D  subHdr_idx                   10I 0
     D  subHdr_len                   10I 0
     D  subHdr_fill                   8A
     D  subHdr_ptr                     *

     D Status          s             10I 0
     D STS_START       c                   0
     D STS_PARTHEADER  c                   10
     D STS_PARTLOAD    c                   20
     D STS_END         c                   30

     D wwHeader        s          65535A   varying

     D p_startPrc      s               *   procptr
     D StartPrc        PR                  extproc(p_startPrc)
     D   userdata                      *   value
     D   isRoot                        N   const

     D p_partPrc       s               *   procptr
     D PartPrc         PR                  extproc(p_partPrc)
     D   userdata                      *   value
     D   data                          *   value
     D   datalen                     10I 0 const

     D p_endPrc        s               *   procptr
     D EndPrc          PR                  extproc(p_endPrc)
     D   userdata                      *   value

      /free
        wwBound = '--' + dsMpr_bound;
        http_xlatep(%len(wwBound) : %addr(wwBound) + 2 : TO_ASCII);
        wwBoundEnd = '--' + dsMpr_bound + '--';
        http_xlatep(%len(wwBoundEnd) : %addr(wwBoundEnd) + 2 : TO_ASCII);
        p_startPrc = dsMpr_StrPrc;
        p_partPrc = dsMpr_PrtPrc;
        p_endPrc = dsMpr_EndPrc;

        Status = STS_START;
        p_buffer = xalloc(%size(buffer));

        exsr ReadLine;

        dow bytesr <> 0;

          select;
          when Status = STS_START;
            if line = CRLFA;
              exsr ReadLine;
              iter;
            endif;
            if %subst(line : 1 : %len(wwBound)) = wwBound;
              isRoot = *off;
              if (dsMpr_root = *blanks);
                isRoot = *on;
              endif;
              Status = STS_PARTHEADER;
              clear wwHeader;
            endif;


          when Status = STS_PARTHEADER;
            isRoot = *off;

            if line <> CRLFA;
              http_xlatep(lineLen : %addr(line) : TO_EBCDIC);
              wwHeader = %trim(wwHeader) + %subst(line : 1 : lineLen);
            else;
              part_header_parse(wwHeader);
              wwHeader = %trim(http_mpr_part_header('content-id'));
              if ((wwHeader = dsMpr_root) and (dsMpr_root <> *blanks));
                isRoot = *on;
              endif;
              if (p_startPrc <> *null);
                StartPrc(dsMpr_data : isRoot);
              endif;
              Status = STS_PARTLOAD;
            endif;


          when Status = STS_PARTLOAD;
            tbw = line;
            tbwLen = lineLen;
            exsr ReadLine;
            if %subst(line : 1 : %len(wwBoundEnd)) = wwBoundEnd;
              if (p_partPrc <> *null);
                PartPrc(dsMpr_data : %addr(tbw) : tbwLen-2);
              endif;
              if (p_endPrc <> *null);
                EndPrc(dsMpr_data);
              endif;
              eval Status = STS_END;
              iter;
            endif;
            if %subst(line : 1 : %len(wwBound)) = wwBound;
              if (p_partPrc <> *null);
                PartPrc(dsMpr_data : %addr(tbw) : tbwLen-2);
              endif;
              if (p_endPrc <> *null);
                EndPrc(dsMpr_data);
              endif;
              eval Status = STS_PARTHEADER;
              iter;
            endif;
            if (p_partPrc <> *null);
              PartPrc(dsMpr_data : %addr(tbw) : tbwLen);
              iter;
            endif;

          endsl;

          exsr ReadLine;
        enddo;

        return *ON;

        //*************************************************
        //* Read a new line
        //*************************************************
        begsr ReadLine;
          clear line;
          lineLen = 0;

          //* Read the file a little more
          rd = read(dsMpr_fd :
                   p_buffer + left :
                   %size(buffer) - left - 1);
          bytesr = rd + left;

          //* If nothing more left, leave
          if bytesr = 0;
            leavesr;
          endif;

          //* If the last byte is a CR, read one more byte
          if %subst(buffer : bytesr : 1) = CR ;
            rd = read(dsMpr_fd : p_buffer + bytesr : 1);
            bytesr = bytesr + rd;
          endif;

          //* Search for the first CRLF, if not present, take it all
          lineLen = %scan(CRLFA : %subst(buffer : 1 : bytesr));
          if lineLen <= 0;
            lineLen = bytesr;
          else;
            lineLen = lineLen + 1;
          endif;
          line = %subst(buffer : 1 : lineLen);

          //* Remember what's left to read and update the buffer
          left = bytesr - lineLen;
          if left > 0;
            memcpy(p_buffer: p_buffer + lineLen: left);
          endif;
        endsr;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mpr_decoder_close():  close an open multipart/related
      *                            decoder.
      *
      *     peDecoder = (input) decoder to close
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_mpr_decoder_close...
     P                 B                   export
     D http_mpr_decoder_close...
     D                 PI
     D  peDecoder                      *   value

     c                   callp     close(dsMpr_fd)
     c                   callp     xdealloc(peDecoder)

     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Parse part header
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P part_header_parse...
     P                 B
     D part_header_parse...
     D                 PI
     D   resp                     65535A   varying const

     D name            s            256A   varying
     D val             s          32500A   varying
     D CRLF            c                   x'0d25'
     D next            s             10I 0 inz(1)
     D eoh             s             10I 0
     D eok             s             10I 0
     D len             s             10I 0

     c                   callp     part_header_clean

      ***********************************************
      * Break response chain into individual headers
      ***********************************************
     c                   dow       next < %len(resp)

      * Find end of header
     c                   eval      eoh = %scan(CRLF:resp:next)
     c                   if        eoh  = 0
     c                   leave
     c                   endif

      * Find end of keyword, start of value
     c                   eval      eok = %scan(':':resp:next)
     c                   if        eok=0 or eok=next or eok>eoh
     c                   eval      next = eoh + 2
     c                   iter
     c                   endif

      * get name of header & value
     c                   eval      len = eok - next
     c                   eval      name = %subst(resp:next:len)
     c                   eval      name = ToUppercase(name)
     c                   eval      len = (eoh - eok) - 1

     c                   if        len = 0
     c                   eval      %len(val) = 0
     c                   else
     c                   eval      val = %subst(resp:eok+1:len)
     c                   endif

      * process them
     c                   if        phdrs < %elem(phdr)

     c                   if        len = 0
     c                   eval      p_pHeader = *null
     c                   else
     c                   eval      p_pHeader = xalloc(len)
     c                   eval      %subst(pheader:1:len) = val
     c                   endif

     c                   eval      phdrs = phdrs + 1
     C     phdrs         occur     phdr
     c                   eval      phdr_name = name
     c                   eval      phdr_idx = phdrs
     c                   eval      phdr_len = len
     c                   eval      phdr_ptr = p_pheader

     c                   endif

      * look for next header
     c                   eval      next = eoh + 2
     c                   enddo

     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * part_header_clean(): free up all part header data
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P part_header_clean...
     P                 B
     D part_header_clean...
     D                 PI
     D i               s             10I 0
     c     1             do        phdrs         i
     c     i             occur     phdr
     c                   eval      phdr_idx = 0
     c                   eval      phdr_len = 0
     c                   if        phdr_ptr <> *null
     c                   callp     xdealloc(phdr_ptr)
     c                   endif
     c                   enddo
     c                   eval      phdrs = 0
     c                   eval      p_pheader = *NULL
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * part_header_find():  returns the position of a given part header
      *                      in the part header list
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P part_header_find...
     P                 B
     D part_header_find...
     D                 PI            10I 0
     D   name                       256A   varying const
     D   pos                         10I 0 value

     D x               s             10I 0
     D count           s             10I 0
     D found           s             10I 0

     c                   eval      count = 0
     c                   eval      found = 0

     c     1             do        phdrs         x
     c     x             occur     phdr

     c                   if        phdr_name = name
     c                   eval      count = count + 1
     c                   if        count = pos
     c                   eval      found = x
     c                   leave
     c                   endif
     c                   endif

     c                   enddo

     c                   return    found
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_mpr_part_header():  retrieve the value of a part header
      *
      *      name = (input) name of header to look for
      *       pos = (input/optional) position of header if there's
      *                 more than one with the same name
      *
      * returns the value of the part header, or '' if not found
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_mpr_part_header...
     P                 B                   export
     D                 PI         32500A   varying
     D   name                       256A   varying const
     D   pos                         10I 0 value options(*nopass)

     D lname           s            256a   varying
     D p               s             10I 0 inz(1)
     D found           s             10I 0

     c                   if        %parms >= 2
     c                   eval      p = pos
     c                   endif

     c                   eval      lname = name
     c                   eval      lname = ToUppercase(lname)

     c                   eval      found = part_header_find(lname: p)
     c                   if        found < 1
     c                   return    ''
     c                   endif

     c     found         occur     phdr
     c                   if        phdr_len = 0
     c                   return    ''
     c                   else
     c                   eval      p_pheader = phdr_ptr
     c                   return    %subst(pheader:1:phdr_len)
     c                   endif
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * toUppercase: convert a string to uppercase
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P toUppercase     B
     D toUppercase     PI         65535A   varying
     D   peString                 65535A   varying const
     c                   return    %xlate(lower:upper:peString)
     P                 E


      /define ERRNO_LOAD_PROCEDURE
      /copy errno_h

