     H NOMAIN

      /define HTTP_ORIG_SOAPACTION
      /copy httpapi_h
      /copy private_h

     D setErrorNotSupported...
     D                 PR            10i 0

     P http_url_get_xml...
     P                 B                   export
     D http_url_get_xml...
     D                 PI            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     D  peTimeout                    10I 0 value options(*nopass)
      /if defined(HTTP_ORIG_SHORTFIELD)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)
      /else
     D  peUserAgent               16384A   varying const
     D                                     options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peContentType             16384A   varying const
     D                                     options(*nopass:*omit)
     D  peSOAPAction              16384A   varying const
     D                                     options(*nopass:*omit)
      /endif
     c                   return    setErrorNotSupported()
     P                 E


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
      /if defined(HTTP_ORIG_SHORTFIELD)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)
      /else
     D  peUserAgent               16384A   varying const
     D                                     options(*nopass:*omit)
     D  peContentType             16384A   varying const
     D                                     options(*nopass:*omit)
     D  peSOAPAction              16384A   varying const
     D                                     options(*nopass:*omit)
      /endif
     c                   return    setErrorNotSupported()
     P                 E

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
      /if defined(HTTP_ORIG_SHORTFIELD)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)
      /else
     D  peUserAgent               16384A   varying const
     D                                     options(*nopass:*omit)
     D  peContentType             16384A   varying const
     D                                     options(*nopass:*omit)
     D  peSOAPAction              16384A   varying const
     D                                     options(*nopass:*omit)
      /endif
     c                   return    setErrorNotSupported()
     P                 E


     P http_parse_xml_stmf...
     P                 B                   export
     D http_parse_xml_stmf...
     D                 PI            10I 0
     D  peFile                    32767A   varying const options(*varsize)
     D  peCCSID                      10I 0 value
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     c                   return    setErrorNotSupported()
     P                 E


     P http_get_xmltf...
     P                 B                   export
     D http_get_xmltf...
     D                 PI            10I 0
     D  peURL                     32767A   varying const options(*varsize)
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     D  peTimeout                    10I 0 value options(*nopass)
      /if defined(HTTP_ORIG_SHORTFIELD)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)
      /else
     D  peUserAgent               16384A   varying const
     D                                     options(*nopass:*omit)
     D  peModTime                      Z   const options(*nopass:*omit)
     D  peContentType             16384A   varying const
     D                                     options(*nopass:*omit)
     D  peSOAPAction              16384A   varying const
     D                                     options(*nopass:*omit)
      /endif
     c                   return    setErrorNotSupported()
     P                 E


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
      /if defined(HTTP_ORIG_SHORTFIELD)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)
      /else
     D  peUserAgent               16384A   varying const
     D                                     options(*nopass:*omit)
     D  peContentType             16384A   varying const
     D                                     options(*nopass:*omit)
     D  peSOAPAction              16384A   varying const
     D                                     options(*nopass:*omit)
      /endif
     c                   return    setErrorNotSupported()
     P                 E


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
      /if defined(HTTP_ORIG_SHORTFIELD)
     D  peUserAgent                  64A   const options(*nopass:*omit)
     D  peContentType                64A   const options(*nopass:*omit)
     D  peSOAPAction                 64A   const options(*nopass:*omit)
      /else
     D  peUserAgent               16384A   varying const
     D                                     options(*nopass:*omit)
     D  peContentType             16384A   varying const
     D                                     options(*nopass:*omit)
     D  peSOAPAction              16384A   varying const
     D                                     options(*nopass:*omit)
      /endif
     c                   return    setErrorNotSupported()
     P                 E


     P http_xmlns      B                   export
     D http_xmlns      PI
     D   peEnable                     1N   const
     c                   callp     setErrorNotSupported()
     P                 E


     P http_XmlReturnPtr...
     P                 B                   export
     D http_XmlReturnPtr...
     D                 PI
     D   peEnable                     1N   const
     c                   callp     setErrorNotSupported()
     P                 E


     P http_XmlStripCRLF...
     P                 B                   export
     D http_XmlStripCRLF...
     D                 PI
     D   peEnable                     1N   const
     c                   callp     setErrorNotSupported()
     P                 E


     P http_parser_switch_cb...
     P                 B                   export
     D http_parser_switch_cb...
     D                 PI            10I 0
     D  peUsrDta                       *   value
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr options(*nopass)
     c                   return    setErrorNotSupported()
     P                 E


     P http_parser_get_start_cb...
     P                 B                   export
     D http_parser_get_start_cb...
     D                 PI              *   procptr
     c                   callp     setErrorNotSupported()
     c                   return    *null
     P                 E


     P http_parser_get_end_cb...
     P                 B                   export
     D http_parser_get_end_cb...
     D                 PI              *   procptr
     c                   callp     setErrorNotSupported()
     c                   return    *null
     P                 E


     P http_parser_get_userdata...
     P                 B                   export
     D http_parser_get_userdata...
     D                 PI              *
     c                   callp     setErrorNotSupported()
     c                   return    *null
     P                 E


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
     c                   return    setErrorNotSupported()
     P                 E


     P HTTP_nextXmlAttr...
     P                 B                   EXPORT
     D HTTP_nextXmlAttr...
     D                 PI             1N
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)
     D   num                         10i 0
     D   name                      1024a   varying
     D   val                      65535a   varying
     c                   callp     setErrorNotSupported()
     c                   return    *OFF
     P                 E


     P http_EscapeXml  B                   export
     D http_EscapeXml  PI          4096a   varying
     D  peString                   4096a   varying const
     c                   callp     setErrorNotSupported()
     c                   return    peString
     P                 E


     P http_XmlReturnUCS...
     P                 B                   export
     D http_XmlReturnUCS...
     D                 PI
     D   peEnable                     1N   const
     c                   callp     setErrorNotSupported()
     P                 E


     P http_parser_init...
     P                 B                   export
     D http_parser_init...
     D                 PI
     D  peCCSID                      10I 0 const options(*omit)
     D  peStartProc                    *   value procptr
     D  peEndProc                      *   value procptr
     D  peUsrDta                       *   value
     c                   callp     setErrorNotSupported()
     P                 E


     P http_parser_parseChunk...
     P                 B                   export
     D http_parser_parseChunk...
     D                 PI            10I 0
     D   peFD                        10I 0 value
     D   peData                        *   value  options(*string)
     D   peLength                    10I 0 value
     c                   return    setErrorNotSupported()
     P                 E


     P http_parser_free...
     P                 B                   export
     D http_parser_free...
     D                 PI            10I 0
     D   peUpdError                    N   const  options(*nopass: *omit)
     c                   return    setErrorNotSupported()
     P                 E


     P HTTP_nextXmlAttrUCS...
     P                 B                   EXPORT
     D HTTP_nextXmlAttrUCS...
     D                 PI             1N
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)
     D   num                         10i 0
     D   name                      1024c   varying
     D   val                      65535c   varying
     c                   callp     setErrorNotSupported()
     c                   return    *off
     P                 E


     P setErrorNotSupported...
     P                 B
     D                 pi            10i 0
     c                   callp     seterror(HTTP_NOTSUPP
     c                                     : 'HTTPAPI was not built '
     c                                     + 'with XML support.')
     c                   return    -1
     P                 E
