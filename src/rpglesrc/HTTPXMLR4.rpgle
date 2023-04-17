     /*-                                                                            +
      * Copyright (c) 2004-2023 Scott C. Klement                                    +
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
      * HTTPXMLR4 -- Parse XML responses from a host
      *
      *  This uses the Expat service program to parse the XML
      *  response and return it to a call-back procedure.
      *
      *>      CRTRPGMOD HTTPXMLR4 SRCFILE(LIBHTTP/QRPGLESRC) DBGVIEW(*LIST)
      *>      UPDSRVPGM SRVPGM(LIBHTTP/HTTPAPIR4) MODULE(HTTPXMLR4) -
      *>                EXPORT(*CURRENT)
      *
      */

      /copy VERSION

     H OPTION(*NOSHOWCPY: *SRCSTMT: *NODEBUGIO)
     H NOMAIN

      /define HTTP_ORIG_SHORTFIELD
      /copy httpapi_h
      /copy private_h
      /copy expat_h
      /copy ifsio_h
      /copy errno_h

     D InitParser      PR                  like(XML_Parser)
     D   peElemStack                       likeds(elemroot)
     D   peEncoding                 100C   const

     D startElement    Pr
     D   root                              likeds(elemroot)
     D   name                     16373C   options(*varsize)
     D   atts                          *   dim(32767) options(*varsize)
     D charData        Pr
     D   root                              likeds(elemroot)
     D   string                   16373C   options(*varsize)
     D   len                         10I 0 value
     D endElement      Pr
     D   root                              likeds(elemroot)
     D   name                          *   value

     D ParseXML        PR            10I 0
     D   peFD                        10I 0 value
     D   peData                    8192A   options(*varsize)
     D   peLength                    10I 0 value

     D copyAttrs       PR              *
     D   root                              likeds(elemroot)
     D   peAttr                        *   dim(32767) options(*varsize)
     D freeAttrs       PR
     D   peAttrs                       *   value

     D rootDepth       PR                         like(elemroot.depth)
     D   root                              value  likeds(elemroot)

     D elemPath        PR                         like(element.path)
     D   root                              value  likeds(elemroot)
     D   elem                              value  likeds(element)
     D Xreplace        pr
     D    string                   4096a   varying
     D    fromstr                    10a   varying const
     D    tostr                      10a   varying const

     D MAXDEPTH        C                   512

     D elemroot        ds                  qualified
     D   depth                       10I 0
     D   startcb                       *   procptr
     D   endcb                         *   procptr
     D   userdata                      *
     D   entry                         *   dim(MAXDEPTH)
     D   cbStack                       *   dim(MAXDEPTH)
     D   cbStackCnt                  10I 0
     D   cbHasChanged                 1n
     D   pathOfs                     10I 0
     D   depthOfs                    10I 0
     D   buf                       8192A   varying
     D   errcode                     10I 0
     D   line                        10I 0
     D   column                      10I 0
     D   namespace                    1N
     D   nschar                       1A
     D   xlate                       52a
     D   StripCRLF                    1N

     D p_cbStackE      s               *
     D cbStackE        ds                  qualified based(p_cbStackE)
     D   depth                             like(elemroot.depth)
     D   pathOfs                           like(elemroot.pathOfs)
     D   depthOfs                          like(elemroot.depthOfs)
     D   startcb                           like(elemroot.startcb)
     D   endcb                             like(elemroot.endcb)
     D   userdata                          like(elemroot.userdata)

     D p_element       s               *
     D element         ds                  qualified based(p_element)
     D   path                      8192A   varying
     D   ns                        1024A   varying
     D   name                      1024A   varying
     D   value                         *
     D   size                        10i 0
     D   allocsize                   10i 0
     D   attrs                         *

     D CHUNKSIZE       C                   const(65536)

     D wkParser        s                   like(XML_Parser)
     D wkElemRoot      ds                  likeds(elemroot)
     D wkNamespace     s              1N   inz(*OFF)
     D wkXmlReturnPtr  s              1N   inz(*OFF)
     D wkXmlReturnUCS  s              1N   inz(*OFF)
     D wkStripCRLF     S              1N   inz(*ON)
     D wkCBSwitched    S              1N   inz(*OFF)
     D wkInsideStartCB...
     D                 S              1N   inz(*OFF)

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_get_xml():
      * http_url_get_xml():  Send a GET request to an HTTP server and
      *     receive/parse an XML response.
      *
      *       peURL = (input) URL to perform GET request to
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *    peUsrDta = (input) user-defined data that will be passed to the
      *                    call-back routine
      *
      * (other parms are identical to those in HTTP_url_get())
      *
      *  Returns 1 if successful, -1 upon error, 0 if timeout
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_url_get_xml...
     P                 B                   export
     D http_url_get_xml...
     D                 PI            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)

     D wwRC            s             10I 0
     D wwEmptyBuf      s              1A

      /free

         wkElemRoot = *ALLx'00';
         wkElemRoot.userdata = peUsrDta;
         wkElemRoot.startcb = peStartProc;
         wkElemRoot.endcb = peEndProc;
         %len(wkElemRoot.buf) = 0;

         wkParser = InitParser(wkElemRoot: *blanks);

         select;
         when (%parms < 5);
             wwRC = http_url_get_raw( peURL
                                    : 3
                                    : %paddr(ParseXML));
         when (%parms < 6);
             wwRC = http_url_get_raw( peURL
                                    : 4
                                    : %paddr(ParseXML)
                                    : peTimeout );
         when (%parms < 7);
             wwRC = http_url_get_raw( peURL
                                    : 5
                                    : %paddr(ParseXML)
                                    : peTimeout
                                    : peUserAgent );
         when (%parms < 8);
             wwRC = http_url_get_raw( peURL
                                    : 6
                                    : %paddr(ParseXML)
                                    : peTimeout
                                    : peUserAgent
                                    : peModTime );
         when (%parms < 9);
             wwRC = http_url_get_raw( peURL
                                    : 7
                                    : %paddr(ParseXML)
                                    : peTimeout
                                    : peUserAgent
                                    : peModTime
                                    : peContentType );
         other;
             wwRC = http_url_get_raw( peURL
                                    : 8
                                    : %paddr(ParseXML)
                                    : peTimeout
                                    : peUserAgent
                                    : peModTime
                                    : peContentType
                                    : peSOAPAction );
         endsl;

         if (wkElemRoot.errcode = 0);
            ParseXML(0: wwEmptyBuf: 0);
         endif;

         if (wwRC=1 and wkElemRoot.errcode > 0);
            SetError(HTTP_XMLERR: 'XML parse failed at line '
                    + %char(wkElemRoot.line) + ', col '
                    + %char(wkElemRoot.column) + ': '
                    + %str(XML_ErrorString(wkElemRoot.errcode)));
            wwRC = -1;
         endif;

         close_iconv(wkElemRoot.xlate);
         XML_ParserFree(wkParser);

         return wwRC;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_post_xml():
      * http_url_post_xml(): Post data to HTTP server, and receive
      *        XML response.  Response is parsed as it's received
      *        off the wire (no temporary file is used.)
      *
      *          peURL = (input) URL to perform GET request to
      *     pePostData = (input) data to POST to the web server
      *  pePostDataLen = (input) length of pePostData
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *       peUsrDta = (input) user-defined data that will be passed
      *                          to the call-back routine
      *
      * (other parms are identical to those in HTTP_url_post())
      *
      *  Returns 1 if successful, -1 upon error, 0 if timeout
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_url_post_xml...
     P                 B                   export
     D http_url_post_xml...
     D                 PI            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)

     D wwRC            s             10I 0
     D wwEmptyBuf      s              1A

      /free

         wkElemRoot = *ALLx'00';
         wkElemRoot.userdata = peUsrDta;
         wkElemRoot.startcb = peStartProc;
         wkElemRoot.endcb = peEndProc;
         %len(wkElemRoot.buf) = 0;

         wkParser = InitParser(wkElemRoot :*blanks);

         select;
         when (%parms < 7);
             wwRC = http_url_post_raw( peURL
                                     : pePostData
                                     : pePostDataLen
                                     : 5
                                     : %paddr(ParseXML) );
         when (%parms < 8);
             wwRC = http_url_post_raw( peURL
                                     : pePostData
                                     : pePostDataLen
                                     : 6
                                     : %paddr(ParseXML)
                                     : peTimeout );
         when (%parms < 9);
             wwRC = http_url_post_raw( peURL
                                     : pePostData
                                     : pePostDataLen
                                     : 7
                                     : %paddr(ParseXML)
                                     : peTimeout
                                     : peUserAgent );
         when (%parms < 10);
             wwRC = http_url_post_raw( peURL
                                     : pePostData
                                     : pePostDataLen
                                     : 8
                                     : %paddr(ParseXML)
                                     : peTimeout
                                     : peUserAgent
                                     : peContentType );
         other;
             wwRC = http_url_post_raw( peURL
                                     : pePostData
                                     : pePostDataLen
                                     : 9
                                     : %paddr(ParseXML)
                                     : peTimeout
                                     : peUserAgent
                                     : peContentType
                                     : peSOAPAction ) ;
         endsl;

         if (wkElemRoot.errcode = 0);
            ParseXML(0: wwEmptyBuf: 0);
         endif;

         if (wwRC=1 and wkElemRoot.errcode > 0);
            SetError(HTTP_XMLERR: 'XML parse failed at line '
                    + %char(wkElemRoot.line) + ', col '
                    + %char(wkElemRoot.column) + ': '
                    + %str(XML_ErrorString(wkElemRoot.errcode)));
            %len(wkElemRoot.buf) = 0;
            wwRC = -1;
         endif;

         close_iconv(wkElemRoot.xlate);
         XML_ParserFree(wkParser);

         return wwRC;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_url_post_stmf_xml():
      *  http_post_stmf_xml(): Post data to HTTP server, and receive
      *        XML response.  Response is parsed as it's received
      *        off the wire (no temporary file is used.)
      *
      *       peURL = (input) URL to post to
      *  pePostFile = (input) File of stream file (in IFS) to post
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *    peUsrDta = (input) user-defined data that will be passed
      *                          to the call-back routine
      *  peTimeout  = (optional) give up if no data is received for
      *                       this many seconds.
      * peContentType = (optional) content type to supply (mainly
      *                       useful when talking to CGI scripts)
      *
      *  Returns  -1 upon failure, 0 upon timeout,
      *            1 for success, or an HTTP response code
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_url_post_stmf_xml...
     P                 B                   export
     D http_url_post_stmf_xml...
     D                 PI            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostFile                32767A   varying const options(*varsize)
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)

     D wwStat          ds                  likeds(statds)
     D wwPostFD        S             10I 0
     D wwRC            S             10I 0
     D wwEmptyBuf      s              1A

      /free

       // *********************************************************
       // * open file to be posted
       // *********************************************************

         if ( stat(%trimr(pePostFile) : %addr(wwStat)) < 0 );
             SetError(HTTP_FDSTAT
                     : 'stat(): ' + %str(strerror(errno)));
             return -1;
         endif;

         wwPostFD = open(%trimr(pePostFile) : O_RDONLY);
         if ( wwPostFD < 0 );
            SetError(HTTP_FDOPEN
                    : 'open(): ' + %str(strerror(errno)));
            return -1;
         endif;

       // *********************************************************
       //  Initialize the XML parser & our own data
       // *********************************************************

         wkElemRoot = *ALLx'00';
         wkElemRoot.userdata = peUsrDta;
         wkElemRoot.startcb = peStartProc;
         wkElemRoot.endcb = peEndProc;
         %len(wkElemRoot.buf) = 0;

         wkParser = InitParser(wkElemRoot: *blanks);


       // *********************************************************
       // * Call the 'raw' post procedure telling it to use the
       // * IFS API called 'read' to load data from the stream
       // * file -- and use our ParseXML routine for the data
       // * that's received.
       // *********************************************************

          select;
          when %parms < 6;
             wwRC = http_url_post_raw2( peURL
                                      : wwPostFD
                                      : %paddr(read)
                                      : wwStat.st_size
                                      : 5
                                      : %paddr(ParseXML) );
          when %parms < 7;
             wwRC = http_url_post_raw2( peURL
                                      : wwPostFD
                                      : %paddr(read)
                                      : wwStat.st_size
                                      : 6
                                      : %paddr(ParseXML)
                                      : peTimeout );
          when %parms < 8;
             wwRC = http_url_post_raw2( peURL
                                      : wwPostFD
                                      : %paddr(read)
                                      : wwStat.st_size
                                      : 7
                                      : %paddr(ParseXML)
                                      : peTimeout
                                      : peUserAgent );
          when %parms < 9;
             wwRC = http_url_post_raw2( peURL
                                      : wwPostFD
                                      : %paddr(read)
                                      : wwStat.st_size
                                      : 8
                                      : %paddr(ParseXML)
                                      : peTimeout
                                      : peUserAgent
                                      : peContentType );
          other;
             wwRC = http_url_post_raw2( peURL
                                      : wwPostFD
                                      : %paddr(read)
                                      : wwStat.st_size
                                      : 9
                                      : %paddr(ParseXML)
                                      : peTimeout
                                      : peUserAgent
                                      : peContentType
                                      : peSOAPAction );
          endsl;

          callp close(wwPostFD);

          if (wkElemRoot.errcode = 0);
             ParseXML(0: wwEmptyBuf: 0);
          endif;

          if (wwRC=1 and wkElemRoot.errcode > 0);
             SetError(HTTP_XMLERR: 'XML parse failed at line '
                    + %char(wkElemRoot.line) + ', col '
                     + %char(wkElemRoot.column) + ': '
                     + %str(XML_ErrorString(wkElemRoot.errcode)));
             %len(wkElemRoot.buf) = 0;
             wwRC = -1;
          endif;

          close_iconv(wkElemRoot.xlate);
          XML_ParserFree(wkParser);

          return wwRC;

      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_get_xmltf(): Request URL from server. Receive response
      *        to temporary file, then parse it.
      *
      *       peURL = (input) URL to perform GET request to
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *    peUsrDta = (input) user-defined data that will be passed to the
      *                    call-back routine
      *
      * (other parms are identical to those in HTTP_url_get())
      *
      *  Returns 1 if successful, -1 upon error, 0 if timeout
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_get_xmltf...
     P                 B                   export
     D http_get_xmltf...
     D                 PI            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)

     D wwRC            s             10I 0
     D wwFile          s             40a   varying

      /free

         // ********************************************
         // * Download HTTP file to temporary location
         // ********************************************

         wwFile = http_tempfile();

         select;
         when (%parms < 5);
             wwRC = http_url_get( peURL
                                : wwFile );
         when (%parms < 6);
             wwRC = http_url_get( peURL
                                : wwFile
                                : peTimeout );
         when (%parms < 7);
             wwRC = http_url_get( peURL
                                : wwFile
                                : peTimeout
                                : peUserAgent );
         when (%parms < 8);
             wwRC = http_url_get( peURL
                                : wwFile
                                : peTimeout
                                : peUserAgent
                                : peModTime );
         when (%parms < 9);
             wwRC = http_url_get( peURL
                                : wwFile
                                : peTimeout
                                : peUserAgent
                                : peModTime
                                : peContentType );
         other;
             wwRC = http_url_get( peURL
                                : wwFile
                                : peTimeout
                                : peUserAgent
                                : peModTime
                                : peContentType
                                : peSOAPAction );
         endsl;

         if (wwRC <> 1);
            unlink(wwFile);
            return wwRC;
         endif;

         // ********************************************
         // * Run temp file through XML parser.
         // ********************************************

         wwRC = http_parse_xml_stmf( wwFile
                                   : HTTP_XML_CALC
                                   : peStartProc
                                   : peEndProc
                                   : peUsrDta );
         unlink(wwFile);

         if (wwRC = 0);
            return 1;
         else;
            return -1;
         endif;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_post_xmltf(): Post data from memory. Receive
      *        response to temporary file, then parse it.
      *
      *          peURL = (input) URL to perform GET request to
      *     pePostData = (input) data to POST to the web server
      *  pePostDataLen = (input) length of pePostData
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *       peUsrDta = (input) user-defined data that will be passed
      *                          to the call-back routine
      *
      * (other parms are identical to those in HTTP_url_post())
      *
      *  Returns 1 if successful, -1 upon error, 0 if timeout
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_post_xmltf...
     P                 B                   export
     D http_post_xmltf...
     D                 PI            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostData                     *   value
     D  pePostDataLen                10I 0 value
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)

     D wwRC            s             10I 0
     D wwFile          s             40a   varying

      /free

         // ********************************************
         // * POST data and download results to temporary
         // * stream file.
         // ********************************************

         wwFile = http_tempfile();

         select;
         when (%parms < 7);
            wwRC = http_url_post( peURL
                                : pePostData
                                : pePostDataLen
                                : wwFile        );
         when (%parms < 8);
            wwRC = http_url_post( peURL
                                : pePostData
                                : pePostDataLen
                                : wwFile
                                : peTimeout     );
         when (%parms < 9);
            wwRC = http_url_post( peURL
                                : pePostData
                                : pePostDataLen
                                : wwFile
                                : peTimeout
                                : peUserAgent   );
         when (%parms < 10);
            wwRC = http_url_post( peURL
                                : pePostData
                                : pePostDataLen
                                : wwFile
                                : peTimeout
                                : peUserAgent
                                : peContentType );
         other;
            wwRC = http_url_post( peURL
                                : pePostData
                                : pePostDataLen
                                : wwFile
                                : peTimeout
                                : peUserAgent
                                : peContentType
                                : peSOAPAction  );
         endsl;

         if (wwRC <> 1);
            unlink(wwFile);
            return wwRC;
         endif;

         // ********************************************
         // * Run temporary file through XML parser.
         // ********************************************

         wwRC = http_parse_xml_stmf( wwFile
                                   : HTTP_XML_CALC
                                   : peStartProc
                                   : peEndProc
                                   : peUsrDta );
         unlink(wwFile);

         if (wwRC = 0);
            return 1;
         else;
            return -1;
         endif;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_post_stmf_xmltf(): Post data from stream file.  Receive
      *        response to temporary file, then parse it.
      *
      *       peURL = (input) URL to post to
      *  pePostFile = (input) File of stream file (in IFS) to post
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *    peUsrDta = (input) user-defined data that will be passed
      *                          to the call-back routine
      *  peTimeout  = (optional) give up if no data is received for
      *                       this many seconds.
      * peContentType = (optional) content type to supply (mainly
      *                       useful when talking to CGI scripts)
      *
      *  Returns  -1 upon failure, 0 upon timeout,
      *            1 for success, or an HTTP response code
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_post_stmf_xmltf...
     P                 B                   export
     D http_post_stmf_xmltf...
     D                 PI            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  pePostFile                32767A   varying const options(*varsize)
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     D  peTimeout                    10I 0 value options(*nopass)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)

     D wwRC            S             10I 0
     D wwFile          s             50a   varying

      /free


       // *********************************************************
       //   Send stream file to server, and download results
       //   to a temporary location.
       // *********************************************************

          wwFile = http_tempfile();

          select;
          when %parms < 6;
             wwRC = http_url_post_stmf( peURL
                                      : pePostFile
                                      : wwFile       );
          when %parms < 7;
             wwRC = http_url_post_stmf( peURL
                                      : pePostFile
                                      : wwFile
                                      : peTimeout    );
          when %parms < 8;
             wwRC = http_url_post_stmf( peURL
                                      : pePostFile
                                      : wwFile
                                      : peTimeout
                                      : peUserAgent  );
          when %parms < 9;
             wwRC = http_url_post_stmf( peURL
                                      : pePostFile
                                      : wwFile
                                      : peTimeout
                                      : peUserAgent
                                      : peContentType);
          other;
             wwRC = http_url_post_stmf( peURL
                                      : pePostFile
                                      : wwFile
                                      : peTimeout
                                      : peUserAgent
                                      : peContentType
                                      : peSOAPAction );
          endsl;

          if (wwRC <> 1);
             unlink(wwFile);
             return wwRC;
          endif;

       // *********************************************************
       //   Parse temporary XML results
       // *********************************************************

          wwRC = http_parse_xml_stmf( wwFile
                                    : HTTP_XML_CALC
                                    : peStartProc
                                    : peEndProc
                                    : peUsrDta );
          unlink(wwFile);

          if (wwRC = 0);
             return 1;
          else;
             return -1;
          endif;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * ParseXML(): (internal) routine called by HTTPAPI when any
      *             data is received.  We buffer it and pass it along
      *             to XML_Parse (part of Expat) as required.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ParseXML        B                   export
     D ParseXML        PI            10I 0
     D   peFD                        10I 0 value
     D   peData                    8192A   options(*varsize)
     D   peLength                    10I 0 value

     D done            s             10I 0 inz(0)

      /free
         if (peLength = 0);
            done = 1;
         endif;

         if (wkElemRoot.errcode > 0);
            return peLength;
         endif;

         if ( XML_Parse( wkParser: %addr(peData): peLength: done )
                 = XML_STATUS_ERROR );
             wkElemRoot.errcode = XML_GetErrorCode(wkParser);
             wkElemRoot.line    = XML_GetCurrentLineNumber(wkParser);
             wkElemRoot.column  = XML_GetCurrentColumnNumber(wkParser);
         endif;

        return peLength;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * InitParser():  Initialize the XML parser that will parse the
      *                data that we receive, and associate it with
      *                our element stack...
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P InitParser      B
     D InitParser      PI                  like(XML_Parser)
     D   peElemStack                       likeds(elemroot)
     D   peEncoding                 100C   const
     D wwParser        s                   like(XML_Parser)
      /free

          peElemStack.namespace = wkNamespace;
          peElemStack.nschar    = x'0c';
          peElemStack.StripCRLF = wkStripCRLF;

          peElemStack.xlate     = new_iconv(13488: 0);

          select;
          when wkNamespace=*off and peEncoding=*blanks;
             wwParser = XML_ParserCreate(*omit);
          when wkNamespace=*off;
             wwParser = XML_ParserCreate(peEncoding);
          when peEncoding=*blanks;
             wwParser = XML_ParserCreateNS(*omit: peElemStack.nschar);
          other;
             wwParser = XML_ParserCreateNS(peEncoding: peElemStack.nschar);
          endsl;

          XML_SetUserData(wwParser: %addr(peElemStack));

          XML_SetElementHandler( wwParser
                               : %paddr(startElement)
                               : %paddr(endElement) );

          XML_SetCharacterDataHandler( wwParser
                                     : %paddr(charData) );

          return wwParser;

      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_parser_switch_cb(): delegates element processing to another
      *     set of start and end element callback procedures for the
      *     current element and its children.
      *
      *    peUsrDta = (input) user-defined data that will be passed to
      *                       the call-back routine. usuallay only that
      *                       portion of the curent user data is forwarded
      *                       to the new callback procedures that they are
      *                       responsible for.
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *
      *  Returns  -1 upon failure, 0 upon success
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_parser_switch_cb...
     P                 B                   export
     D http_parser_switch_cb...
     D                 PI            10I 0
     D  peUsrDta                       *   value
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr options(*nopass)

     D p_newCBStackE   s               *
     D newCBStackE     ds                  likeds(cbStackE)
     D                                     based(p_newCBStackE)

     D p_root          s               *   inz(%addr(wkElemRoot))
     D root            ds                  likeds(elemroot)
     D                                     based(p_root)

     D endProc         s                   like(peEndProc) inz(*NULL)

      /free

          p_element = root.entry(root.depth);

          // get optional parameters

          if (%parms() >= 3);
             endProc = peEndProc;
          endif;

          // return to caller on illegal calls

          if (not wkInsideStartCB);
             SetError(HTTP_ILLSWC: 'Switching callback not allowed +
                                   from outside start element procedure.');
             HTTP_Crash();
             return -1;
          endif;

          if (wkCBSwitched);
             SetError(HTTP_ILLSWC: 'XML Callback already switched at +
                                    current level!');
             HTTP_Crash();
             return -1;
          endif;

          if (peStartProc = *NULL and endProc = *NULL);
             SetError(HTTP_ILLSWC: 'You must either specify a start or end +
                                    callback procedure to switch to!');
             return -1;
          endif;

          // make room for a new callback stack entry

          root.cbStackCnt = root.cbStackCnt + 1;
          root.cbStack(root.cbStackCnt) =xalloc(%size(newCBStackE));
          p_newCBStackE = root.cbStack(root.cbStackCnt);
          newCBStackE = *ALLX'00';

          // push existing root values on stack

          newCBStackE.depth    = root.depth;
          newCBStackE.pathOfs  = root.pathOfs;
          newCBStackE.depthOfs = root.depthOfs;
          newCBStackE.startcb  = root.startcb;
          newCBStackE.endcb    = root.endcb;
          newCBStackE.userData = root.userData;

          // activate new callback procedures

          root.startcb  = peStartProc;
          root.endcb    = endProc;
          root.userData = peUsrDta;
          root.pathOfs  = %len(element.path);
          root.depthOfs = root.depth - 1;

          root.cbHasChanged = *ON;

          http_dmsg('INFO: element processing has been delegated +
                           for element: <' + element.name + '>');

        return 0;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_parser_get_start_cb(): returns the procedure pointer of
      *     the currently active start callback procedure.
      *
      *  Returns procedure pointer of start callback procedure.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_parser_get_start_cb...
     P                 B                   export
     D http_parser_get_start_cb...
     D                 PI              *   procptr

     D p_root          s               *   inz(%addr(wkElemRoot))
     D root            ds                  likeds(elemroot)
     D                                     based(p_root)
      /free
        return root.startcb;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_parser_get_end_cb(): returns the procedure pointer of
      *     the currently active end callback procedure.
      *
      *  Returns procedure pointer of end callback procedure.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_parser_get_end_cb...
     P                 B                   export
     D http_parser_get_end_cb...
     D                 PI              *   procptr

     D p_root          s               *   inz(%addr(wkElemRoot))
     D root            ds                  likeds(elemroot)
     D                                     based(p_root)
      /free
        return root.endcb;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_parser_get_userdata(): returns the procedure pointer of
      *     the currently active user data.
      *
      *  Returns procedure pointer of user data.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_parser_get_userdata...
     P                 B                   export
     D http_parser_get_userdata...
     D                 PI              *

     D p_root          s               *   inz(%addr(wkElemRoot))
     D root            ds                  likeds(elemroot)
     D                                     based(p_root)
      /free
        return root.userdata;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Expat calls this when the start tag for an element appears
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P startElement    B                   export
     D startElement    PI
     D   root                              likeds(elemroot)
     D   localName                16373C   options(*varsize)
     D   atts                          *   dim(32767) options(*varsize)

     D p_oldElem       s               *
     D oldElem         ds                  likeds(element)
     D                                     based(p_oldElem)

     D p_newElem       s               *
     D newElem         ds                  likeds(element)
     D                                     based(p_newElem)

     D p_callback      s               *   procptr
     D Callback        PR                  extproc(p_callback)
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)
     D CallbackNS      PR                  extproc(p_callback)
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   namespace                 1024A   varying const
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D p_AttrAry       s               *
     D wwAttrAry       s               *   dim(32767) based(p_AttrAry)

     D len             s             10I 0
     D pos             s             10I 0
     D xlname          s           1024a   based(p_xlname)

      /free

          // set 'inside start element callback procedure' flag

          wkInsideStartCB = *ON;

          // reset 'callback switched' flag

          wkCBSwitched   = *OFF;

          // make room for a new element.

          root.depth = root.depth + 1;
          root.entry(root.depth) = xalloc(%size(newElem));
          p_newElem = root.entry(root.depth);
          newElem = *ALLX'00';

          // make room for data in the new element.

          newElem.size      = 0;
          newElem.AllocSize = CHUNKSIZE;
          newElem.value     = xalloc(CHUNKSIZE);

          // copy path from previous element.

          if (root.depth > 1);
             p_oldElem = root.entry(root.depth - 1);
             newElem.path = oldElem.path + '/' + oldElem.name;
          endif;

          // set new name & translate to EBCDIC.

          len = %scan(u'0000': localName) - 1;
          len = iconvdyn( len * 2
                        : %addr(localName)
                        : root.xlate
                        : p_xlname );
          newElem.name = %subst(xlname:1:len);

          // if namespaces are enabled, separate namespace...

          if (root.namespace);
              newElem.ns = '';
              pos = %scan(root.nschar: newElem.name);
              if (pos>1 and pos<len);
                  newElem.ns   = %subst(newElem.name:1:pos-1);
                  newElem.name = %subst(newElem.name:pos+1);
              endif;
          endif;

          newElem.attrs = copyAttrs(root:atts);

          // Stay in loop until callback procedure has not been changed
          // anymore. 'root.cbHasChanged' may be set on by the
          // http_parser_switch_cb() routine.

          dou (not root.cbHasChanged);

             root.cbHasChanged = *OFF;

             if (root.startcb <> *NULL);
                p_AttrAry = newElem.Attrs;
                p_callback = root.startcb;
                if (root.namespace);
                    CallbackNS( root.userdata
                              : rootDepth(root)
                              : newElem.ns
                              : newElem.name
                              : elemPath(root: newElem)
                              : wwAttrAry );
                else;
                    Callback( root.userdata
                            : rootDepth(root)
                            : newElem.name
                            : elemPath(root: newElem)
                            : wwAttrAry );
                endif;
             endif;

          enddo;

          // reset 'inside start element callback procedure' flag

          wkInsideStartCB = *OFF;

          return;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * charData(): Expat calls this when character data is found in
      *             between one element and another.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P charData        B                   export
     D charData        PI
     D   root                              likeds(elemroot)
     D   string                   16373C   options(*varsize)
     D   len                         10I 0 value
     D x               s             10I 0
     D y               s             10I 0
     D newsize         s             10u 0
     D newval          s                   like(string) based(p_newval)
      /free

          p_element = root.entry(root.depth);

          newsize = element.size + (len * 2);
          dow (newsize > element.allocsize);
               element.allocsize = element.allocsize + CHUNKSIZE;
               element.value = xrealloc( element.value
                                       : element.allocsize );
          enddo;

          p_newval = element.value + element.size;

          if (root.StripCRLF=*ON);
              y = 0;
              for x = 1 to len;
                  if (%subst(string: x: 1) <> u'000d'
                      and %subst(string: x: 1) <> u'000a');
                         y = y + 1;
                         %subst(newval:y:1) = %subst(string:x:1);
                  endif;
              endfor;
          else;
              y = len;
              %subst(newval:1:y) = %subst(string:1:y);
          endif;

          element.size = element.size + (y*2);
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Expat calls this when the close tag for an element appears
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P endElement      B                   export
     D endElement      PI
     D   root                              likeds(elemroot)
     D   name                          *   value

     D p_callback      s               *   procptr
     D Callback        PR                  extproc(p_callback)
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   retval                        *   value
     D   Attrs                         *   dim(32767)
     D                                     const options(*varsize)
     D CallbackNS      PR                  extproc(p_callback)
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   ns                        1024A   varying const
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   retval                        *   value
     D   Attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D p_AttrAry       s               *
     D wwAttrAry       s               *   dim(32767) based(p_AttrAry)

     D valDS           ds
     D   p_newval                      *   inz(*null)
     D   len                         10i 0 inz(0)

     D newval          s          65535a   based(p_newval)
     D newvalucs       s          16383c   based(p_newval)
     D value           s          65535a   varying
     D ucs2val         s          16383c   varying
     D p_retval        s               *

      /free

          p_element = root.entry(root.depth);

          if (root.endcb <> *NULL);

             p_AttrAry  = element.attrs;
             p_callback = root.endcb;
             p_newval   = *null;
             value      = '';
             len        = 0;

             // Translate to EBCDIC and copy into valDS

             if (element.size >= 1);
                if (wkXmlReturnUCS);
                   p_newval = element.value;
                   len      = element.size;
                else;
                   len = iconvdyn( element.size
                                 : element.value
                                 : root.xlate
                                 : p_newval );
                endif;
             endif;


             // Convert valDS into a string to pass to callback
             //  (unless user requested XmlReturnPtr)

             select;
             when wkXmlReturnPtr = *on;
                 p_retval = %addr(valDs);
             when (wkXmlReturnUCS);
                if (len > %div(%size(ucs2val):2) - VARPREF);
                  len = %div(%size(ucs2val):2) - VARPREF;
                endif;
                ucs2val = %subst(newvalucs:1:len);
                p_retval = %addr(ucs2val);
             other;
                if (len > %size(value)-VARPREF);
                   len = %size(value) - VARPREF;
                endif;
                value = %subst(newval:1:len);
                p_retval = %addr(value);
             endsl;

             if (root.namespace);
                 CallbackNS( root.userdata
                           : rootDepth(root)
                           : element.ns
                           : element.name
                           : elemPath(root: element)
                           : p_retval
                           : wwAttrAry
                         );
             else;
                 Callback( root.userdata
                         : rootDepth(root)
                         : element.name
                         : elemPath(root: element)
                         : p_retval
                         : wwAttrAry
                         );
             endif;
             if (p_newval <> *null and wkXmlReturnUcs=*off);
                xdealloc(p_newval);
             endif;
          endif;

          // restore previous callback procedures from stack

          if (root.cbStackCnt > 0);
             p_cbStackE = root.cbStack(root.cbStackCnt);
             if (cbStackE.depth = root.depth);
                root.startcb  = cbStackE.startcb;
                root.endcb    = cbStackE.endcb;
                root.userData = cbStackE.userData;
                root.pathOfs  = cbStackE.pathOfs;
                root.depthOfs = cbStackE.depthOfs;
                xdealloc(root.cbStack(root.cbStackCnt));
                p_cbStackE = *NULL;
                root.cbStackCnt = root.cbStackCnt - 1;
                http_dmsg('INFO: delegation of element processing has been +
                                 stopped for element: <' + element.name + '>');
             endif;
          endif;

          // free element data

          freeAttrs(element.attrs);
          xdealloc(element.value);
          xdealloc(root.entry(root.depth));
          p_element = *NULL;
          root.depth = root.depth - 1;

          return;
      /end-free
     P                 E


      ******************************************************************
      * copyAttrs():  Allocate space for tag attributes, copy them
      *               to the space, and translate them to EBCDIC
      ******************************************************************
     P copyAttrs       B
     D copyAttrs       PI              *
     D   root                              likeds(elemroot)
     D   peAttr                        *   dim(32767) options(*varsize)

     D x               s             10I 0
     D wwCount         s             10I 0
     D wwLen           s             10I 0

     D p_Array         s               *
     D wwArray         s               *   dim(32767) based(p_Array)

     D p_endnull       s               *
     D endnull         s              1A   based(p_endnull)
     D p_endnull2      s               *
     D endnull2        s              1C   based(p_endnull2)

     D attrdta         s          16383C   based(p_attrdta)
     D xlname          s           1024a   based(p_xlname)

      /free

         // figure out how many elements are in the peAttr array:

         x = 1;
         dow peAttr(x) <> *NULL;
            x = x + 1;
         enddo;
         wwCount = x;

         // allocate space for the array of pointers

         p_array = xalloc(%size(p_array) * wwCount);


         // allocate space for each attribute, copy it, and
         //  if needed, translate it to EBCDIC

         for x = 1 to (wwCount - 1);
            p_attrdta = peAttr(x);
            wwLen = %scan(u'0000': attrdta);
            if (wwLen = 0);
               wwLen = %len(attrdta);
            endif;
            if (wkXmlReturnUCS);
               if wwLen >= 1;
                  wwArray(x) = xalloc(wwLen * 2);
                  memcpy(wwArray(x): p_attrdta: wwLen * 2 );
               else;
                  wwArray(x) = xalloc(%size(endnull2));
                  p_endnull2 = wwArray(x);
                  endnull2 = u'0000';
               endif;
            else;
               wwLen = iconvdyn( wwLen * 2
                               : p_attrdta
                               : root.xlate
                               : wwArray(x) );
               if (wwLen < 1);
                  wwArray(x) = xalloc(%size(endnull));
                  p_endnull = wwArray(x);
                  endnull = x'00';
               endif;
            endif;
         endfor;

         wwArray(wwCount) = *NULL;

         return p_Array;
      /end-free
     P                 E


      ******************************************************************
      * rootDepth():  returns the depth of a given element
      ******************************************************************
     P rootDepth       B
     D rootDepth       PI                         like(elemroot.depth)
     D   root                              value  likeds(elemroot)

      /free

         return root.depth - root.depthOfs;

      /end-free
     P                 E


      ******************************************************************
      * elemPath():  returns the path of a given element
      ******************************************************************
     P elemPath        B
     D elemPath        PI                         like(element.path)
     D   root                              value  likeds(elemroot)
     D   elem                              value  likeds(element)

      /free

         if (rootDepth(root) = 1);
            return '';
         else;
            return %subst(elem.path: root.pathOfs + 1);
         endif;

      /end-free
     P                 E

      ******************************************************************
      * freeAttrs():  deallocate the memory allocaed by copyAttrs
      ******************************************************************
     P freeAttrs       B
     D freeAttrs       PI
     D   peAttrs                       *   value

     D x               s             10I 0
     D p_Array         s               *
     D wwArray         s               *   dim(32767) based(p_Array)

      /free

           p_Array = peAttrs;
           x = 1;

           dow wwArray(x) <> *NULL;
              xdealloc(wwArray(x));
              x = x + 1;
           enddo;

           xdealloc(peAttrs);

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  http_parse_xml_stmf(): Parse XML data directly from a stream file
      *                         (instead of downloading it from a server)
      *
      *      peFile = (input) Stream file (in IFS) to read data from
      *     peCCSID = (input) CCSID of stream file,
      *                    or HTTP_XML_CALC to attempt to calculate it
      *                       from the XML encoding
      *                    or HTTP_STMF_CALC to use the stream file's
      *                       CCSID attribute.
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *    peUsrDta = (input) user-defined data that will be passed
      *                          to the call-back routine
      *
      *  Returns  -1 upon failure, 0 upon success
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_parse_xml_stmf...
     P                 B                   export
     D http_parse_xml_stmf...
     D                 PI            10I 0
     D  peFile                    32767A   varying const options(*varsize)
     D  peCCSID                      10I 0 value
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value

     D wwFD            S             10I 0
     D wwRC            S             10I 0
     D wwLen           S             10I 0
     D wwBuf           S           8192a
     D wwXBuf          s           8192a   based(p_Buf)
     D wwEncoding      s            100C
     D wwManual        s              1N   inz(*OFF)

      /free

       // *********************************************************
       // * open file to be parsed
       // *********************************************************

         select;
         when peCCSID = HTTP_XML_CALC;
            wwEncoding = *blanks;
            wwFD = open(%trimr(peFile) : O_RDONLY );
         when peCCSID = HTTP_STMF_CALC;
            wwEncoding = XML_ENC_UTF8;
            wwFD = open( %trimr(peFile)
                       : O_RDONLY + O_TEXTDATA + O_CCSID
                       : 0
                       : 1208 );
         other;
            HTTP_xml_SetCCSIDs(peCCSID: 1208);
            wwFD = open(%trimr(peFile) : O_RDONLY);
            wwEncoding = XML_ENC_UTF8;
            wwManual = *ON;
         endsl;

         if ( wwFD < 0 );
            SetError(HTTP_FDOPEN
                    : 'open(): ' + %str(strerror(errno)));
            return -1;
         endif;


       // *********************************************************
       //  Initialize the XML parser & our own data
       // *********************************************************

         wkElemRoot = *ALLx'00';
         wkElemRoot.userdata = peUsrDta;
         wkElemRoot.startcb = peStartProc;
         wkElemRoot.endcb = peEndProc;
         %len(wkElemRoot.buf) = 0;

         wkParser = InitParser(wkElemRoot: wwEncoding);


       // *********************************************************
       //  Read the stream file data and pass it to the parser
       // *********************************************************

         wwRC = 0;
         dow '1';
             wwLen = read(wwFD: %addr(wwBuf): %size(wwBuf));
             if (wwLen < 1) ;
                 leave;
             endif;

             if (wwManual);
                 wwLen = xml_xlate( wwLen: %addr(wwBuf): p_buf );
                 wwLen = parsexml(0: wwXBuf: wwLen);
                 xdealloc(p_Buf);
             else;
                 wwLen = parsexml(0: wwBuf: wwLen);
             endif;

             if (wwLen < 0);
                 leave;
             endif;
         enddo;

         callp close(wwFD);

         if (wkElemRoot.errcode = 0);
            ParseXML(0: wwBuf: 0);
         endif;


       // *********************************************************
       //   Check for error.
       // *********************************************************

         if (wkElemRoot.errcode > 0);
            SetError(HTTP_XMLERR: 'XML parse failed at line '
                   + %char(wkElemRoot.line) + ', col '
                    + %char(wkElemRoot.column) + ': '
                    + %str(XML_ErrorString(wkElemRoot.errcode)));
            %len(wkElemRoot.buf) = 0;
            wwRC = -1;
         endif;

       // *********************************************************
       //  All done!
       // *********************************************************

         close_iconv(wkElemRoot.xlate);
         XML_ParserFree(wkParser);
         return wwRC;

      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
      * http_xmlns():  Enable XML Namespace processing
      *
      *     peEnable = (input) *ON to enable parsing, *OFF to disable.
      *                        (it is disabled by default)
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
     P http_xmlns      B                   export
     D http_xmlns      PI
     D   peEnable                     1N   const
      /free
         if (peEnable=*On or peEnable=*OFF);
            wkNamespace = peEnable;
         endif;
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
      * http_XmlReturnPtr(): XML End Element Handler should return a
      *                      pointer to the full element value instead of
      *                      returning a VARYING character string.
      *                      (VARYING is limited to 64k)
      *
      *     peEnable = (input) *ON to return a pointer, *OFF to return
      *                        a VARYING string (*OFF = default)
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
     P http_XmlReturnPtr...
     P                 B                   export
     D http_XmlReturnPtr...
     D                 PI
     D   peEnable                     1N   const
      /free
         if (peEnable=*On or peEnable=*OFF);
            wkXmlReturnPtr = peEnable;
         endif;
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
      * http_XmlStripCRLF(): Enable stripping of CRLF characters
      *
      *     peEnable = (input) *ON to strip, *OFF to leave them in.
      *                        (they are stripped by default)
      *
      * Note: To simplify your XML string manipulations, HTTPAPI
      *       strips CRLF characters from the response.  If you would
      *       prefer that they are left in the response, call this
      *       routine with a parameter of *OFF.
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
     P http_XmlStripCRLF...
     P                 B                   export
     D http_XmlStripCRLF...
     D                 PI
     D   peEnable                     1N   const
      /free
         if (peEnable=*On or peEnable=*OFF);
            wkStripCRLF = peEnable;
         endif;
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
      * http_parse_xml_string():  Parse XML from an input string.
      *                         (instead of downloading it from a server)
      *
      *    peString = (input) Pointer to string
      *       peLen = (input) Length of string to parse
      *     peCCSID = (input) CCSID of string to be parsed
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *    peUsrDta = (input) user-defined data that will be passed
      *                          to the call-back routine
      *
      *  Returns  -1 upon failure, 0 upon success
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_parse_xml_string...
     P                 B                   export
     D http_parse_xml_string...
     D                 PI            10i 0
     D  peString                       *   value
     D  peLen                        10I 0 value
     D  peCCSID                      10I 0 value
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value

     D wwRC            S             10I 0
     D wwLen           S             10I 0
     D wwBuf           S           8192a   based(peString)
     D wwXBuf          s           8192a   based(p_Buf)

      /free

       // *********************************************************
       //  Initialize the XML parser & our own data
       //
       //  Translate the data to UTF-8.
       //
       //  Parse the XML
       // *********************************************************

         HTTP_xml_SetCCSIDs(peCCSID: 1208);
         wkElemRoot = *ALLx'00';
         wkElemRoot.userdata = peUsrDta;
         wkElemRoot.startcb = peStartProc;
         wkElemRoot.endcb = peEndProc;
         %len(wkElemRoot.buf) = 0;

         wkParser = InitParser(wkElemRoot: XML_ENC_UTF8);

         wwLen = xml_xlate( peLen: peString: p_buf );
         wwLen = ParseXML(0: wwXBuf: wwLen);
         xdealloc(p_Buf);

         if (wkElemRoot.errcode = 0);
            ParseXML(0: wwBuf: 0);
         endif;


       // *********************************************************
       //   Check for error.
       // *********************************************************

         if (wkElemRoot.errcode > 0);
            SetError(HTTP_XMLERR: 'XML parse failed at line '
                   + %char(wkElemRoot.line) + ', col '
                    + %char(wkElemRoot.column) + ': '
                    + %str(XML_ErrorString(wkElemRoot.errcode)));
            %len(wkElemRoot.buf) = 0;
            wwRC = -1;
         endif;

       // *********************************************************
       //  All done!
       // *********************************************************

         close_iconv(wkElemRoot.xlate);
         XML_ParserFree(wkParser);
         return wwRC;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HTTP_nextXmlAttr():  Retrieve next XML attribute from attrs list
      *
      *      attrs = (input) attribute list to extract from
      *        num = (i/o)   position in attribute list.  On first
      *                      call, set this to 1.  HTTPAPI will
      *                      increment this as it moves through the list
      *       name = (output) XML attribute name (from list)
      *        val = (output) XML attribute value (from list)
      *
      * Returns *ON normally, *OFF if there's no more attributes to read
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P HTTP_nextXmlAttr...
     P                 B                   EXPORT
     D HTTP_nextXmlAttr...
     D                 PI             1N
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)
     D   num                         10i 0
     D   name                      1024a   varying
     D   val                      65535a   varying
     D x               s             10i 0
      /free
         x = num * 2;
         if attrs(x-1) = *null;
            return *OFF;
         else;
            name = %str(attrs(x-1));
         endif;

         if attrs(x) = *null;
            return *OFF;
         else;
            val = %str(attrs(x));
         endif;

         num = num + 1;
         return *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * HTTP_nextXmlAttrUCS(): Retrieve next XML attribute from attrs list
      *                     ONLY use this when using http_xmlReturnUCS(*ON)
      *
      *      attrs = (input) attribute list to extract from
      *        num = (i/o)   position in attribute list.  On first
      *                      call, set this to 1.  HTTPAPI will
      *                      increment this as it moves through the list
      *       name = (output) XML attribute name (from list)
      *        val = (output) XML attribute value (from list)
      *
      * Returns *ON normally, *OFF if there's no more attributes to read
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P HTTP_nextXmlAttrUCS...
     P                 B                   EXPORT
     D HTTP_nextXmlAttrUCS...
     D                 PI             1N
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)
     D   num                         10i 0
     D   name                      1024c   varying
     D   val                      65535c   varying

     D x               s             10i 0
     D p_nameData      s               *
     D nameData        s           1024c   based(p_nameData)
     D p_valData       s               *
     D valData         s          65535c   based(p_valData)
     D len             s             10i 0
      /free
         x = num * 2;
         if attrs(x-1) = *null;
            return *OFF;
         else;
            p_nameData = attrs(x-1);
            len = %scan(u'0000': nameData) - 1;
            select;
            when len = -1;
              name = nameData;
            when len = 0;
              name = '';
            other;
              name = %subst(nameData:1:len);
            endsl;
         endif;

         if attrs(x) = *null;
            return *OFF;
         else;
            val = %str(attrs(x));
            p_valData = attrs(x);
            len = %scan(u'0000': valData) - 1;
            select;
            when len = -1;
              val = valData;
            when len = 0;
              val = '';
            other;
              val = %subst(valData:1:len);
            endsl;
         endif;

         num = num + 1;
         return *ON;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_EscapeXml(): Escape any special characters used by XML
      *
      *     peString = (input) string to escape
      *
      * Returns escaped string.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_EscapeXml  B                   export
     D http_EscapeXml  PI          4096a   varying
     D  peString                   4096a   varying const
     D result          s                   like(peString)
      /free
         result = peString;
         Xreplace(result: '&': '&amp;');
         Xreplace(result: '<': '&lt;');
         Xreplace(result: '>': '&gt;');
         Xreplace(result: '''': '&apos;');
         Xreplace(result: '"': '&quot;');
         return result;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Xreplace(): Use the %scan/%replace BIFs to replace one string
      *            with another.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P Xreplace        b
     D Xreplace        pi
     D    string                   4096a   varying
     D    fromstr                    10a   varying const
     D    tostr                      10a   varying const

     D pos             s             10i 0
      /free
         pos = %scan(fromStr: string);
         dow pos > 0;
            string = %replace(toStr: string: pos: %len(fromStr));
            pos = pos + %len(toStr);
            if pos < %len(string);
               pos = %scan(fromStr: string: pos+1);
            else;
               pos = 0;
            endif;
         enddo;
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
      * http_XmlReturnUCS(): The XML End Handler should get it's data
      *                      in UCS-2 Unicode (RPG data type C) instead
      *                      of EBCDIC (RPG data type A)
      *
      *     peEnable = (input) *ON to return data in Unicode
      *                       *OFF to return data in EBCDIC (default)
      *
      * NOTE: This can be used in conjunction with http_XmlReturnPtr.
      *       When XmlReturnPtr is off, the data is returned as a
      *       UCS-2 VARYING parameter.  When XmlReturnPtr=on, the data
      *       is returned as a pointer to a DS containing UCS-2
      *       data (as opposed to alphanumeric)
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
     P http_XmlReturnUCS...
     P                 B                   export
     D http_XmlReturnUCS...
     D                 PI
     D   peEnable                     1N   const
      /free
         if (peEnable=*On or peEnable=*OFF);
            wkXmlReturnUCS = peEnable;
         endif;
      /end-free
     P                 E

      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
      * http_parser_init():   Initializes the XML parser.
      *                       Afterwards http_parser_parseChunk() can
      *                       can be used to parse a given XML stream.
      *
      *     peCCSID = (input) CCSID of string to be parsed
      * peStartProc = (input) call-back procedure to call at the start
      *                       of each XML element received.
      *   peEndProc = (input) call-back procedure to call at the end
      *                       of each XML element received.
      *    peUsrDta = (input) user-defined data that will be passed
      *                          to the call-back routine
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_parser_init...
     P                 B                   export
     D http_parser_init...
     D                 PI
     D  peCCSID                      10I 0 const options(*omit)
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value

      /free

       // *********************************************************
       //  Reset error status
       // *********************************************************

         SetError(0: *blanks);

       // *********************************************************
       //  Initialize the XML parser & our own data
       // *********************************************************

         if (%parms() >= 1 and %addr(peCCSID) <> *null);
            HTTP_xml_SetCCSIDs(peCCSID: 1208);
         endif;

         wkElemRoot = *ALLx'00';
         wkElemRoot.userdata = peUsrDta;
         wkElemRoot.startcb = peStartProc;
         wkElemRoot.endcb = peEndProc;
         %len(wkElemRoot.buf) = 0;

         wkParser = InitParser(wkElemRoot: XML_ENC_UTF8);

      /end-free
     P                 E

      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
      * http_parser_parseChunk():  Parses a given chunk of XML data.
      *                            Can be invoked multiple times in
      *                            between http_parser_init() and
      *                            http_parser_free.
      *
      *        peFD = (input) Open file descriptor. Not used here but
      *                       required for compatibility reasons.
      *      peData = (input) Pointer of the XML data.
      *    peLength = (input) Length of the XML data.
      *
      *  Returns the length of the parsed buffer on success, else -1.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_parser_parseChunk...
     P                 B                   export
     D http_parser_parseChunk...
     D                 PI            10I 0
     D   peFD                        10I 0 value
     D   peData                        *   value  options(*string)
     D   peLength                    10I 0 value

     D wwXBuf          s           8192a   based(p_Buf)
     D wwLen           s             10I 0
     D wwRC            S             10I 0

      /free

         wwLen = xml_xlate( peLength: peData: p_buf );
         wwLen = ParseXML(0: wwXBuf: wwLen);
         xdealloc(p_Buf);

         if (wkElemRoot.errcode > 0);
            SetError(HTTP_XMLERR: 'XML parse failed at line '
                   + %char(wkElemRoot.line) + ', col '
                    + %char(wkElemRoot.column) + ': '
                    + %str(XML_ErrorString(wkElemRoot.errcode)));
            %len(wkElemRoot.buf) = 0;
            wwLen = -1;
         endif;

         return wwLen;

      /end-free
     P                 E

      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
      * http_parser_free():  Frees a previously allocated parser.
      *
      *  peUpdError = (input) Update error information. Default: *ON.
      *
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_parser_free...
     P                 B                   export
     D http_parser_free...
     D                 PI            10I 0
     D   peUpdError                    N   const  options(*nopass: *omit)

     D wwRC            s             10I 0
     D wwEmptyBuf      s              1A
     D wwUpdError      s                   like(peUpdError)

      /free

         if (%parms() >= 1 and %addr(peUpdError) <> *NULL);
            wwUpdError = peUpdError;
         else;
            wwUpdError = *ON;
         endif;

       // *********************************************************
       //   Terminate parser.
       // *********************************************************

         if (wkElemRoot.errcode = 0);
            ParseXML(0: wwEmptyBuf: 0);
         endif;

       // *********************************************************
       //   Check for error.
       // *********************************************************

         if (wwUpdError and wkElemRoot.errcode > 0);
            SetError(HTTP_XMLERR: 'XML parse failed at line '
                   + %char(wkElemRoot.line) + ', col '
                    + %char(wkElemRoot.column) + ': '
                    + %str(XML_ErrorString(wkElemRoot.errcode)));
            %len(wkElemRoot.buf) = 0;
            wwRC = -1;
         endif;

       // *********************************************************
       //  All done!
       // *********************************************************

         close_iconv(wkElemRoot.xlate);
         XML_ParserFree(wkParser);
         return wwRC;

      /end-free
     P                 E


      /define ERRNO_LOAD_PROCEDURE
      /copy errno_h
