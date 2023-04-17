     /*-                                                                            +
      * Copyright (c) 2006-2023 Scott C. Klement                                    +
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

      *  This member is to contain routines for parsing HTTP headers
      *  and for working with cookies.
      *-
      *
      *  Cookie Information is found in RFC 2109
      *    http://www.ietf.org/rfc/rfc2109.txt
      *  Also, the original Netscape specification can be found here:
      *    http://wp.netscape.com/newsref/std/cookie_spec.html
      *
      *  FIXME:  The cookie standard was changed in April 2011
      *          this code should be updated accordingly.
      *           http://tools.ietf.org/html/rfc6265
      *
      *>  chgcurlib curlib(libhttp)
      *>  crtrpgmod headerr4 srcfile(libhttp/qrpglesrc) dbgview(*list)
      *>  updsrvpgm httpapir4 module(headerr4)
      *-
     H NOMAIN

      /define HTTP_ORIG_SOAPACTION
      /define HTTP_WSDL2RPG_STUFF
      /copy header_h
      /copy private_h
      /copy ifsio_h
      /copy httpapi_h
      /copy errno_h

     D upper           C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D lower           C                   'abcdefghijklmnopqrstuvwxyz'

     D header_clean    PR
     D header_find     PR            10I 0
     D   name                       256A   varying const
     D   pos                         10I 0 value
     D skipWhiteSpaces...
     D                 PR            10I 0
     D   buffer                   32500A   const  options(*varsize)
     D   len                         10I 0 value
     D   pos                         10I 0 value
     D isWhiteSpace    PR              N
     D   char                         1A   const
     D skipToSubType...
     D                 PR            10I 0
     D   buffer                   32500A   const  options(*varsize)
     D   len                         10I 0 value
     D   pos                         10I 0 value
     D removeQuotes...
     D                 PR         32500A   varying
     D   string                   32500A   const  options(*varsize)
     D   len                         10I 0 const
     D   quote                        1A   const  options(*nopass)
     D cookie_parse    PR
     D   dft_path                   256A   varying const
     D   dft_domain                 256A   varying const
     D   cookie                   32500A   varying const
     D   data                              like(cookie_data)
     D cookie_reset    PR
     D   data                              like(cookie_data)
     D cookie_attr     PR
     D   count                       10I 0
     D   name                              like(cd_name)
     D   value                             like(cd_value)
     D cookie_match    PR             1N
     D   domain                            like(cd_domain) const
     D   path                              like(cd_path) const
     D   exact                        1N   const
     D cookie_reject   PR             1N
     D   cookie                            like(cookie_data)
     D   req_domain                 256A   varying const
     D   req_path                   256A   varying const
     D cookie2ts       PR              Z
     D   cookie                      50A   varying value
     D cookie_alloc    PR              *
     D cookie_find     PR              *
     D   name                              like(cd_name) const
     D   domain                            like(cd_domain) const
     D   path                              like(cd_path) const
     D   secure                       1N   const
     D   exact                        1N   const
     D cookie_set      PR
     D    cookie                           like(cookie_data)
     D cookie_dump     PR             1N
     D   filename                   256A   varying const
     D cookie_write    PR            10I 0
     D   fd                          10I 0 value
     D cookie_read     PR            10I 0
     D   filename                   256A   varying const
     D cookie_readfld  PR
     D   fieldno                     10I 0 value
     D   data                     32767A   varying const

     D hdrs            s             10I 0 inz(0)

     D hdr             ds                  occurs(4000)
     D  hdr_name                    256A   varying
     D  hdr_idx                      10I 0
     D  hdr_len                      10I 0
     D  hdr_fill                      8A
     D  hdr_ptr                        *

     D header          s          32500A   based(p_header)

     D cookie_data     ds                  based(p_cookie_data)
     D   cd_name                    256A   varying
     D   cd_lcname                  256A   varying
     D   cd_value                  8192A   varying
     D   cd_domain                  256A   varying
     D   cd_path                    256A   varying
     D   cd_expires                    Z
     D   cd_recv                       Z
     D   cd_version                   1A
     D   cd_secure                    1N
     D   cd_gotdom                    1N
     D   cd_gotpath                   1N
     D   cd_temp                      1N

     D cookie_file     s            256A   varying inz('')
     D cookie_count    s             10I 0
     D cookie_list     s               *   dim(1024)
     D dump_session    s              1n   inz(*OFF)
     D UCS2_DOLLAR     c                   const(u'0024')


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Parse HTTP header & protocol information
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P header_parse    B                   export
     D header_parse    PI
     D   resp                     32767A   varying const
     D   userdata                      *   value

     D name            s            256A   varying
     D val             s          32500A   varying
     D CRLF            c                   x'0d25'
     D next            s             10I 0 inz(1)
     D eoh             s             10I 0
     D eok             s             10I 0
     D len             s             10I 0

     c                   callp     header_clean

      ***********************************************
      * Break response chain into individual headers
      *   and call header_process for each
      ***********************************************
     c                   dow       next < %len(resp)

      * Find end of HTTP header
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
     c     upper:lower   xlate     name          name
     c                   eval      len = (eoh - eok) - 1

     c                   if        len = 0
     c                   eval      %len(val) = 0
     c                   else
     c                   eval      val = %subst(resp:eok+1:len)
     c                   endif

      * process them
     c                   if        hdrs < %elem(hdr)

     c                   if        len = 0
     c                   eval      p_Header = *null
     c                   else
     c                   eval      p_Header = xalloc(len)
     c                   eval      %subst(header:1:len) = val
     c                   endif

     c                   eval      hdrs = hdrs + 1
     C     hdrs          occur     hdr
     c                   eval      hdr_name = name
     c                   eval      hdr_idx = hdrs
     c                   eval      hdr_len = len
     c                   eval      hdr_ptr = p_header

     c                   endif

      * look for next header
     c                   eval      next = eoh + 2
     c                   enddo

      /if defined(MEMCOUNT)
     c                   callp     http_dmsg( 'saved '
     c                                      + %char(hdrs)
     c                                      + ' to actgrp')
     c                   callp     http_dmsg( 'NOTE: headers +
     c                             saved to actgrp are cleaned +
     c                             up in the next request')
      /endif
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * header_clean(): free up all header data
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P header_clean    B
     D header_clean    PI
     D i               s             10I 0
     c     1             do        hdrs          i
     c     i             occur     hdr
     c                   eval      hdr_idx = 0
     c                   eval      hdr_len = 0
     c                   if        hdr_ptr <> *null
     c                   callp     xdealloc(hdr_ptr)
     c                   endif
     c                   enddo
     c                   eval      hdrs = 0
     c                   eval      p_header = *NULL
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * header_find():  returns the position of a given header
      *                in the header list
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P header_find     B
     D header_find     PI            10I 0
     D   name                       256A   varying const
     D   pos                         10I 0 value

     D x               s             10I 0
     D count           s             10I 0
     D found           s             10I 0

     c                   eval      count = 0
     c                   eval      found = 0

     c     1             do        hdrs          x
     c     x             occur     hdr

     c                   if        hdr_name = name
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
      * skipWhiteSpaces: skips whhite spaces starting at a given
      *                  position
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P skipWhiteSpaces...
     P                 B
     D skipWhiteSpaces...
     D                 PI            10I 0
     D   buffer                   32500A   const  options(*varsize)
     D   len                         10I 0 value
     D   pos                         10I 0 value

     D p               s             10I 0

     c                   eval      p = pos

     c                   dow       (p <= len and
     c                              isWhiteSpace(%subst(buffer: p: 1)))
     c                   eval      p = p + 1
     c                   enddo

     c                   return    p
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * isWhiteSpace: returns true if a given character is a
      *               white space character, else false.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P isWhiteSpace    B
     D isWhiteSpace    PI              N
     D   char                         1A   const

      * SPACE, HTAB, VTAB, FF, CR, LF, IFS, IGS, IRS, IUS
     D whiteSpaces     c                   const(x'40050B0C0D251C1D1E1F')

     c                   if        (%scan(char: whiteSpaces) = 0)
     c                   return    *OFF
     c                   endif

     c                   return    *ON
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * skipToSubType: skips to the sub type of a given header
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P skipToSubType...
     P                 B
     D skipToSubType...
     D                 PI            10I 0
     D   buffer                   32500A   const  options(*varsize)
     D   len                         10I 0 value
     D   pos                         10I 0 value

     D p               s             10I 0

     c                   eval      p = pos
     c                   dow       (p < len and
     c                              %subst(buffer: p: 1) <> '/' and
     c                              %subst(buffer: p: 1) <> ';')
     c                   eval      p = p + 1
     c                   enddo

     c                   return    p
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * removeQuotes: removes the quotes from a quoted string
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P removeQuotes...
     P                 B
     D removeQuotes...
     D                 PI         32500A   varying
     D   string                   32500A   const  options(*varsize)
     D   len                         10I 0 const
     D   quote                        1A   const  options(*nopass)

     D q               s              1A   inz('"')

     c                   if        (%parms() >= 3)
     c                   eval      q = quote
     c                   endif

     c                   if        (len < 2)
     c                   return    ''
     c                   endif

     c                   if        (%subst(string:1:1) <> q or
     c                              %subst(string: len: 1) <> q)
     c                   return    string
     c                   endif

     c                   if        (len = 2)
     c                   return    ''
     c                   endif

     c                   return    %subst(string: 2: len-2)
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_header():  retrieve the value of an HTTP header
      *
      *      name = (input) name of header to look for
      *       pos = (input/optional) position of header if there's
      *                 more than one with the same name
      *
      * returns the value of the HTTP header, or '' if not found
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_header     B                   export
     D http_header     PI         32500A   varying
     D   name                       256A   varying const
     D   pos                         10I 0 value options(*nopass)

     D lname           s            256a   varying
     D p               s             10I 0 inz(1)
     D found           s             10I 0

     c                   if        %parms >= 2
     c                   eval      p = pos
     c                   endif

     c                   eval      lname = name
     c     upper:lower   xlate     lname         lname

     c                   eval      found = header_find(lname: p)
     c                   if        found < 1
     c                   return    ''
     c                   endif

     c     found         occur     hdr
     c                   if        hdr_len = 0
     c                   return    ''
     c                   else
     c                   eval      p_header = hdr_ptr
     c                   return    %subst(header:1:hdr_len)
     c                   endif
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_getContentType():  returns the content type of the
      *                         HTTP response stream
      *
      * returns the content type of the HTTP stream, or '' if not found
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_getContentType...
     P                 B                   export
     D http_getContentType...
     D                 PI         32500A   varying

     D found           s             10I 0
     D s               s             10I 0
     D i               s             10I 0

     c                   eval      found = header_find('content-type': 1)
     c                   if        found < 1
     c                   return    ''
     c                   endif

     c     found         occur     hdr
     c                   if        hdr_len = 0
     c                   return    ''
     c                   endif

     c                   eval      p_header = hdr_ptr

      *  skip white spaces
     c                   eval      i = skipWhiteSpaces(header: hdr_len: 1)
     c                   if        (i > hdr_len)
     c                   return    ''
     c                   endif

      *  skip to subtype
     c                   eval      s = i
     c                   eval      i = skipToSubType(header: hdr_len: i)

     c                   if        (i - s <= 0)
     c                   return    ''
     c                   endif

      *  return content type
     c                   return    %xlate(upper:lower:%subst(header:s:i-s))
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_getContentSubType():  returns the content sub type of the
      *                            HTTP response stream
      *
      * returns the content sub type of the HTTP stream, or '' if not found
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_getContentSubType...
     P                 B                   export
     D http_getContentSubType...
     D                 PI         32500A   varying

     D found           s             10I 0
     D s               s             10I 0
     D i               s             10I 0

     c                   eval      found = header_find('content-type': 1)
     c                   if        found < 1
     c                   return    ''
     c                   endif

     c     found         occur     hdr
     c                   if        hdr_len = 0
     c                   return    ''
     c                   endif
     c                   eval      p_header = hdr_ptr

      *  skip white spaces
     c                   eval      i = skipWhiteSpaces(header: hdr_len: 1)
     c                   if        (i > hdr_len)
     c                   return    ''
     c                   endif

      *  skip to subtype
     c                   eval      i = skipToSubType(header: hdr_len: i) + 1
     c                   if        (i > hdr_len)
     c                   return    ''
     c                   endif

      *  skip to end of sub type
     c                   eval      s = i
     c                   dow       (i < hdr_len and
     c                              %subst(header: i: 1) <> ';' and
     c                              %subst(header: i: 1) <> ',')
     c                   eval      i = i + 1
     c                   enddo

     c                   if        (i > hdr_len)
     c                   return    ''
     c                   endif

      *  return content sub type
     c                   return    %xlate(upper:lower:%subst(header:s:i-s))
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_getContentAttr(): returns the value of the specified
      *                        attribute of the content type header
      *                        of the HTTP response stream
      *
      *      attr = (input) name of content-type header attribute to look for
      *
      * returns the value of the content-type header attribute, or '' if not found
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_getContentTypeAttr...
     P                 B                   export
     D http_getContentTypeAttr...
     D                 PI         32500A   varying
     D   attr                       256A   varying const

     D strtok          PR              *          extproc('strtok')
     D  i_string                       *   value  options(*string)
     D  i_delimiters                   *   value  options(*string)

     D strlen...
     D                 PR            10U 0 extproc('strlen')
     D  i_string                       *   value

     D found           s             10I 0
     D pToken          s               *
     D token           s          32500A   based(pToken)
     D i               s             10I 0
     D s               s             10I 0
     D len             s             10I 0
     D attr_name       s                   like(attr)

     c                   eval      found = header_find('content-type': 1)
     c                   if        found < 1
     c                   return    ''
     c                   endif

     c     found         occur     hdr
     c                   if        hdr_len = 0
     c                   return    ''
     c                   endif
     c                   eval      p_header = hdr_ptr

      *  spin through all parts of the header, start with 2. token
      *  (first token is content type and content sub type)
     c                   eval      pToken =
     c                                strtok(%subst(header: 1: hdr_len): ';')
     c                   eval      pToken = strtok(*NULL: ';')

     c                   dow       (pToken <> *NULL)
     c                   eval      attr_name = ''
     c                   eval      len = strlen(pToken)
      *  skip white spaces
     c                   eval      i = skipWhiteSpaces(token: len: 1)
     c                   dow       (i <= len and %subst(token: i: 1) <> '=')
     c                   eval      attr_name = attr_name + %subst(token: i: 1)
     c                   eval      i = i + 1
     c                   enddo

     c                   if        (%xlate(upper: lower: attr_name) = attr)
     c                   eval      i = i + 1
     c                   eval      s = i
      *  skip to end of value or white spaces
     c                   dow       (i <= len and (
     c                              %subst(token: i: 1) <> ';') and
     c                              not isWhiteSpace(%subst(token: i: 1)))
     c                   eval      i = i + 1
     c                   enddo
     c                   if        (i-s <= 0)
     c                   return    ''
     c                   else
     c                   return    removeQuotes(%subst(token: s: i-s): i-s)
     c                   endif
     c                   endif

     c                   eval      pToken = strtok(*NULL: ';')
     c                   enddo

     c                   return    ''
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Parse the cookies in the HTTP headers and load them into
      * the cookie list.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P header_load_cookies...
     P                 B                   export
     D header_load_cookies...
     D                 PI
     D   req_domain                 256A   varying const
     D   req_path                   256A   varying const

     D fd              s             10I 0

     D x               s             10I 0
     D rawCookie       s          32750A   varying
     D cookie          s                   like(cookie_data)
     D temp_domain     s            256a   varying

     c                   eval      temp_domain = '.' + req_domain
     c                   callp     http_dmsg('header_load_cookies() entered')

     c                   if        cookie_file <> ''
     c                   callp     cookie_read(cookie_file)
     c                   endif

     c                   eval      x = 1
     c                   eval      rawCookie = http_header('set-cookie':x)

     c                   dow       rawCookie <> ''

     c                   callp     cookie_parse( req_path
     c                                         : temp_domain
     c                                         : rawCookie
     c                                         : cookie )

     c                   if        cookie_reject( cookie
     c                                          : temp_domain
     c                                          : req_path ) = *OFF
     c                   callp     cookie_set( cookie )
     c                   endif

     c                   eval      x = x + 1
     c                   eval      rawCookie = http_header('set-cookie':x)
     c                   enddo

     c                   if        cookie_file <> ''
     c                   callp     cookie_dump(cookie_file)
     c                   endif
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This parses a cookie into a cookie data structure.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cookie_parse    B
     D cookie_parse    PI
     D   dft_path                   256A   varying const
     D   dft_domain                 256A   varying const
     D   cookie                   32500A   varying const
     D   data                              like(cookie_data)

     D p_save          s               *
     D state           s             10I 0
     D count           s             10I 0
     D name            s                   like(cd_name)
     D value           s                   like(cd_value)
     D pos             s             10I 0
     D ch              s              1A
     D len             s             10I 0

     c                   callp     http_dmsg('cookie_parse() entered')
     c                   callp     http_dmsg('cookie = ' + cookie)

     c                   eval      p_save = p_cookie_data
     c                   eval      p_cookie_data = %addr(data)
     c                   eval      state      = 0
     c                   eval      count      = 0
     c                   eval      name       = ''
     c                   eval      value      = ''
     c                   callp     cookie_reset(data)
     c                   eval      cd_domain  = dft_domain
     c                   eval      cd_path    = dft_path
     c                   time                    cd_recv

     c                   eval      len = %len(cookie)
     c     1             do        len           pos

     c                   eval      ch = %subst(cookie:pos:1)

      *************************************************
      * State 0: skipping whitespace until the
      * start of the attribute name.
      *************************************************
     c                   select
     c                   when      state = 0
     c                   if        ch <> ' '
     c                   eval      name = ch
     c                   eval      value = ''
     c                   eval      state = 1
     c                   endif

      *************************************************
      * State 1: Reading the attribute name
      *************************************************
     c                   when      state = 1

     c                   select
     c                   when      ch = '='
     c                   eval      state = 2
     c                   when      ch = ';' or ch = ','
     c                   callp     cookie_attr(count: name: value)
     c                   eval      state = 0
     c                   other
     c                   eval      name = name + ch
     c                   endsl

      *************************************************
      * State 2: Reading the start of the attribute
      *          and checking for a quoted value
      *************************************************
     c                   when      state = 2

     c                   select
     c                   when      ch = '"'
     c                   eval      state = 4
     c                   when      ch = ';'
     c                   callp     cookie_attr(count: name: value)
     c                   eval      state = 0
     c                   other
     c                   eval      value = ch
     c                   eval      state = 3
     c                   endsl

      *************************************************
      *  state 3: reading the remainder of the
      *           attribute value
      *************************************************
     c                   when      state = 3

     c                   select
     c                   when      ch = ';'
     c                   callp     cookie_attr(count: name: value)
     c                   eval      state = 0
     c                   other
     c                   eval      value = value + ch
     c                   endsl

      *************************************************
      *  state 4: reading until next quote found
      *************************************************
     c                   when      state = 4

     c                   select
     c                   when      ch = '"'
     c                   eval      state = 3
     c                   other
     c                   eval      value = value + ch
     c                   endsl

     c                   endsl

     c                   enddo

     c                   callp     cookie_attr(count: name: value)

     c                   eval      p_cookie_data = p_save
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Reset all fields in cookie to their default values.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cookie_reset    B
     D cookie_reset    PI
     D   data                              like(cookie_data)

     D p_save          s               *

     c                   eval      p_save = p_cookie_data
     c                   eval      p_cookie_data = %addr(data)

     c                   eval      cd_version = '0'
     c                   eval      cd_name    = ''
     c                   eval      cd_lcname  = ''
     c                   eval      cd_value   = ''
     c                   eval      cd_expires = *loval
     c                   eval      cd_domain  = ''
     c                   eval      cd_path    = ''
     c                   eval      cd_secure  = *off
     c                   eval      cd_gotpath = *off
     c                   eval      cd_gotdom  = *off
     c                   eval      cd_temp    = *on
     c                   eval      cd_recv    = *loval

     c                   eval      p_cookie_data = p_save
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Set cookie attribute
      *  This is only intended to be called by cookie_parse()
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cookie_attr     B
     D cookie_attr     PI
     D   count                       10I 0
     D   name                              like(cd_name)
     D   value                             like(cd_value)

     D offset          s             10I 0
     D lcname          s                   like(cd_name) static

     c                   eval      count = count + 1
     c                   eval      lcname = name
     c     upper:lower   xlate     lcname        lcname

     c                   callp     http_dmsg('cookie attr ' + name
     c                                               + '=' + value )
      *****************************
      * cookie's name & value
      *****************************
     c                   select
     c                   when      count = 1
     c                   eval      cd_name   = name
     c                   eval      cd_lcname = lcname
     c                   eval      cd_value  = value

      ****************************
      * cookie spec version number
      ****************************
     c                   when      lcname = 'version'
     c                   eval      cd_version = value

      ****************************
      * is this a secure cookie?
      ****************************
     c                   when      lcname = 'secure'
     c                   eval      cd_secure = *on

      ****************************
      * domain specified
      ****************************
     c                   when      lcname = 'domain'
     c                   eval      cd_domain = value
     c                   eval      cd_gotdom = *on

      ****************************
      * path specified
      ****************************
     c                   when      lcname = 'path'
     c                   eval      cd_path = value
     c                   eval      cd_gotpath = *on

      ****************************
      * expiration age (version 1)
      ****************************
     c                   when      lcname = 'max-age'

     c                   eval      offset = atoi(value)
     c                   if        offset < 1
     c                   eval      cd_expires = *loval
     c                   else
     c                   time                    cd_expires
     c                   adddur    offset:*S     cd_expires
     c                   endif
     c                   eval      cd_temp  = *off

      ****************************
      * expiration timestamp
      ****************************
     c                   when      lcname = 'expires'
     c                   eval      cd_expires = cookie2ts(value)
     c                   eval      cd_temp  = *off

      ****************************
      * comment about cookie
      ****************************
     c                   when      lcname = 'comment'
     C**                 IGNORED FOR NOW...

     c                   endsl

      /if defined(DEBUG_COOKIES)
     c                   eval      cd_temp = *OFF
     c                   eval      cd_expires = *hival
      /endif

     c                   eval      name = ' '
     c                   eval      value = ' '
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Convert a cookie timestamp to an RPG timestamp
      *   and convert it to the current time zone
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cookie2ts       B
     D cookie2ts       PI              Z
     D   cookie                      50A   varying value

     D CEEUTCO         PR                  ExtProc('CEEUTCO')
     D   hours                       10I 0
     D   minutes                     10I 0
     D   seconds                      8F
     D   feedback                    12A   options(*omit)

     D junk1           s             10I 0
     D junk2           s             10I 0
     D junk3           s              8F
     D utc_offset      s             10I 0 static inz(*hival)

     D day             s             10A   varying
     D mon             s             15A   varying
     D year            s             10A   varying
     D hour            s             10A   varying
     D min             s             10A   varying
     D sec             s             10A   varying
     D tz              s             10A   varying

     D result          s               Z

     D parsed          ds
     D  yyyy                          4S 0
     D  sep1                          1A   inz('-')
     D  mm                            2S 0
     D  sep2                          1A   inz('-')
     D  dd                            2S 0
     D  sep3                          1A   inz('-')
     D  hh                            2S 0
     D  sep4                          1A   inz('.')
     D  mi                            2S 0
     D  sep5                          1A   inz('.')
     D  ss                            2S 0
     D  sep6                          1A   inz('.')
     D  milli                         6S 0 inz(0)

     D len             s             10I 0
     D state           s             10I 0
     D pos             s             10I 0
     D found           s             10I 0
     D ch              s              1A
     D NUMBERS         c                   '0123456789'

     c     lower:upper   xlate     cookie        cookie

      *********************************************************
      * Loop through the timestamp character by character, and
      * save the results of everything we find
      *********************************************************
     c                   eval      len = %len(cookie)
     c     1             do        len           pos

     c                   eval      ch = %subst(cookie:pos:1)

      *******************************************
      * State 0:  Skipping over the (irrelevant)
      *           day of week
      *******************************************
     c                   select
     c                   when      state = 0

     c                   if        ch = ','
     c                   eval      state = 1
     c                   endif

     C     NUMBERS       check     ch            Found
     c                   if        found = 0
     c                   eval      day = ch
     c                   eval      state = 1
     c                   endif

      *******************************************
      * State 1: Reading the "day of month"
      *          (2-digit number)
      *******************************************
     c                   when      state = 1

     c                   if        ch = ' ' and day = *blanks
     c                   iter
     c                   endif

     C     NUMBERS       check     ch            Found
     c                   if        found = 0
     c                   eval      day = day + ch
     c                   else
     c                   eval      state = 2
     c                   endif

      *******************************************
      * State 2: Reading the month name
      *          (3-char abbreviation)
      *******************************************
     c                   when      state = 2

     c                   if        ch = ' ' and mon = *blanks
     c                   iter
     c                   endif

     C     UPPER         check     ch            Found
     c                   if        found = 0
     c                   eval      mon = mon + ch
     c                   else
     c                   eval      state = 3
     c                   endif

      *******************************************
      * State 3: Reading the year
      *          (2 or 4 digit number)
      *******************************************
     c                   when      state = 3

     C     NUMBERS       check     ch            Found
     c                   if        found = 0
     c                   eval      year = year + ch
     c                   else
     c                   eval      state = 4
     c                   endif

      *******************************************
      * State 4: reading the hour
      *******************************************
     c                   when      state = 4

     C     NUMBERS       check     ch            Found
     c                   if        found = 0
     c                   eval      hour = hour + ch
     c                   else
     c                   eval      state = 5
     c                   endif

      *******************************************
      * State 5: reading the minutes
      *******************************************
     c                   when      state = 5

     C     NUMBERS       check     ch            Found
     c                   if        found = 0
     c                   eval      min = min + ch
     c                   else
     c                   eval      state = 6
     c                   endif

      *******************************************
      * State 6: reading the seconds
      *******************************************
     c                   when      state = 6

     C     NUMBERS       check     ch            Found
     c                   if        found = 0
     c                   eval      sec = sec + ch
     c                   else
     c                   eval      state = 7
     c                   endif

      *******************************************
      * State 7: reading the time zone
      *******************************************
     c                   when      state = 7
     c                   eval      tz = tz + ch
     c                   endsl

     c                   enddo

      *********************************************************
      *  Check it out... make sure everything is legal
      *********************************************************
     c                   eval      result = *loval

     c                   select
     c                   when      mon = 'JAN' or mon = 'JANUARY'
     c                   eval      mm = 1
     c                   when      mon = 'FEB' or mon = 'FEBRUARY'
     c                   eval      mm = 2
     c                   when      mon = 'MAR' or mon = 'MARCH'
     c                   eval      mm = 3
     c                   when      mon = 'APR' or mon = 'APRIL'
     c                   eval      mm = 4
     c                   when      mon = 'MAY' or mon = 'MAI'
     c                   eval      mm = 5
     c                   when      mon = 'JUN' or mon = 'JUNE'
     c                   eval      mm = 6
     c                   when      mon = 'JUL' or mon = 'JULY'
     c                   eval      mm = 7
     c                   when      mon = 'AUG' or mon = 'AUGUST'
     c                   eval      mm = 8
     c                   when      mon = 'SEP' or mon = 'SEPTEMBER'
     c                   eval      mm = 9
     c                   when      mon = 'OCT' or mon = 'OCTOBER'
     c                   eval      mm = 10
     c                   when      mon = 'NOV' or mon = 'NOVEMBER'
     c                   eval      mm = 11
     c                   when      mon = 'DEC' or mon = 'DECEMBER'
     c                   eval      mm = 12
     c                   other
     c                   return    result
     c                   endsl

     c                   eval      dd = atoi(day)
     c                   if        dd < 1 or dd > 31
     c                   return    result
     c                   endif

     c                   eval      yyyy = atoi(year)
     c                   if        yyyy < 0
     c                   return    result
     c                   endif

     c                   if        yyyy < 100
     c                   if        yyyy < 70
     c                   eval      yyyy = 2000 + yyyy
     c                   else
     c                   eval      yyyy = 1900 + yyyy
     c                   endif
     c                   endif

     c                   eval      hh = atoi(hour)
     c                   if        hh < 0 or hh > 24
     c                   return    result
     c                   endif

     c                   eval      mi = atoi(min)
     c                   if        mi < 0 or mi > 59
     c                   return    result
     c                   endif

     c                   eval      ss = atoi(sec)
     c                   if        ss < 0 or ss > 59
     c                   return    result
     c                   endif

     c                   if        %trim(tz) <> 'GMT'
     c                   return    result
     c                   endif

     c                   test(ez)                parsed
     c                   if        %error
     c                   return    result
     c                   endif

      *********************************************************
      *  Get current timezone
      *********************************************************
     c                   if        utc_offset = *hival
     c                   callp     CEEUTCO(junk1: junk2: junk3: *omit)
     c                   eval      utc_offset = junk3
     c                   endif

      *********************************************************
      *  If everything is good, return it.
      *********************************************************
     c     *ISO          move      parsed        result
     c                   adddur    utc_offset:*S result
     c                   return    result
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * This checks to see if a cookie should be rejected
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cookie_reject   B
     D cookie_reject   PI             1N
     D   cookie                            like(cookie_data)
     D   req_domain                 256A   varying const
     D   req_path                   256A   varying const

     c                   eval      p_cookie_data = %addr(cookie)

     c                   if        cookie_match(req_domain:req_path:*OFF)
     c                               = *OFF
     c                   callp     http_dmsg('cookie rejected, path/dom ' +
     c                                       'doesn''t match request.')
     c                   return    *ON
     c                   endif

     c                   if        cd_gotdom = *On
     c                             and %scan('.':cd_domain) = 0
     c                   callp     http_dmsg('cookie rejected, dotless domain')
     c                   return    *ON
     c                   endif

     c                   if        %len(cd_value) > 8191
     c                   callp     http_dmsg('cookie rejected, too long')
     c                   return    *ON
     c                   endif

     c                   return    *OFF
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Check to see if the domain & path match the currently
      *  loaded cookie
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cookie_match    B
     D cookie_match    PI             1N
     D   domain                            like(cd_domain) const
     D   path                              like(cd_path) const
     D   exact                        1N   const

     D start           s             10I 0
     D len             s             10I 0

     c                   eval      len = %len(cd_path)
     c                   if        len > %len(path)
     c                   return    *OFF
     c                   endif

     c                   if        %subst(path:1:len) <> cd_path
     c                   return    *OFF
     c                   endif

     c                   if        exact = *ON
     c                             and path <> cd_path
     c                   return    *OFF
     c                   endif

     c                   eval      len = %len(cd_domain)
     c                   eval      start = (%len(domain) - len) + 1

     c                   if        start<1 or start>%len(domain)
     c                   return    *OFF
     c                   endif

     c                   if        %subst(domain:start:len)
     c                               <> cd_domain
     c                   return    *OFF
     c                   endif

     c                   return    *ON
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Find a cookie in the cookie cache
      *
      *        name = name of cookie to find
      *      domain = domain that cookie belongs to
      *        path = path of URLs in domain that cookie matches
      *      secure = Turn *ON if secure cookies should be returned
      *       exact = path has to be exactly the same (*ON or *OFF)
      *
      * returns a pointer to the cookie record, or *NULL if not found
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cookie_find     B                   export
     D cookie_find     PI              *
     D   name                              like(cd_name) const
     D   domain                            like(cd_domain) const
     D   path                              like(cd_path) const
     D   secure                       1N   const
     D   exact                        1N   const

     D x               s             10I 0
     D p_save          s               *
     D current         s               Z
     D retval          s               *

     c                   time                    current
     c                   eval      p_save = p_cookie_data
     c                   eval      retval = *NULL

     c     1             do        cookie_count  x

     c                   eval      p_cookie_data = cookie_list(x)

     c                   if        cd_temp=*OFF and cd_expires<current
     c                   iter
     c                   endif

     c                   if        cd_secure = *ON
     c                             and secure = *OFF
     c                   iter
     c                   endif

     c                   if        cd_lcname = name
     c                             and cookie_match(domain:path:exact)=*ON
     c                   eval      retval = cookie_list(x)
     c                   endif

     c                   enddo

     c                   eval      p_cookie_data = p_save
     c                   return    retval
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cookie_set():  Set the value of a cookie in the cookie cache
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cookie_set      B                   export
     D cookie_set      PI
     D    cookie                           like(cookie_data)

     D name            s                   like(cd_name)
     D dom             s                   like(cd_domain)
     D path            s                   like(cd_path)
     D x               s             10I 0
     D p_save          s               *

     D newcookie       s                   like(cookie_data)
     D                                     based(match)

      **
      **  Extract the name, domain, and path from the cookie
      **
     c                   eval      p_save = p_cookie_data
     c                   eval      p_cookie_data = %addr(cookie)

     c                   eval      name = cd_lcname
     c                   eval      dom  = cd_domain
     c                   eval      path = cd_path

      **
      **  If this cookie already exists, replace it.
      **  otherwise, allocate a new one.
      **
     c                   eval      match = cookie_find( name
     c                                                : dom
     c                                                : path
     c                                                : *ON
     c                                                : *ON )

     c                   if        match = *NULL
     c                   eval      match = cookie_alloc
     c                   endif

     c                   if        match <> *NULL
     c                   eval      newcookie = cookie
     c                   endif

     c                   eval      p_cookie_data = p_save
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cookie_alloc(): Allocate a new cookie in the cookie cache
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cookie_alloc    B                   export
     D cookie_alloc    PI              *

     D x               s             10I 0
     D p_save          s               *
     D current         s               Z
     D oldest          s               Z   inz(*hival)
     D p_oldest        s               *   inz(*NULL)
     D retval          s               *
     D size            s             10I 0

      **
      ** Check for an expired cookie to re-use
      **
     c                   time                    current

     c     1             do        cookie_count  x

     c                   eval      p_cookie_data = cookie_list(x)
     c                   if        cd_temp=*OFF and cd_expires<current
     c                   eval      retval = cookie_list(x)
     c                   leave
     c                   endif

     c                   if        cd_recv < oldest
     c                   eval      oldest = cd_recv
     c                   eval      p_oldest = cookie_list(x)
     c                   endif

     c                   enddo

      **
      ** Check if there's room for a new cookie in the cache
      **
     c                   if        retval = *NULL
     c                   if        cookie_count < %elem(cookie_list)
     c                   eval      size = %size(cookie_data)
     c                   eval      retval = xalloc(size)
     c                   eval      cookie_count = cookie_count + 1
     c                   eval      cookie_list(cookie_count) = retval
     c                   endif
     c                   endif

      **
      ** If the cache is full _and_ there's no expired cookies
      ** then re-use the oldest one.
      **
     c                   if        retval = *NULL
     c                   eval      retval = p_oldest
     c                   endif

     c                   return    retval
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cookie_dunp(): Dump the cookie cache to disk
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cookie_dump     B                   export
     D cookie_dump     PI             1N
     D   filename                   256A   varying const
     D fd              s             10I 0
     D x               s             10I 0
     D current         s               Z
     D p_save          s               *

     c                   callp     http_dmsg('cookie_dump() entered.')
     c                   callp     http_dmsg('cookie file is ' + filename)

     c                   eval      fd = open( %trimr(filename)
     c                                      : O_CREAT+O_TRUNC+O_WRONLY
     c                                      : S_IRUSR+S_IWUSR )
     c                   if        fd < 0
     c                   callp     SetError(HTTP_CKDUMP
     c                                     : %str(strerror(errno)))
     c                   return    *OFF
     c                   endif

     c                   time                    current
     c                   eval      p_save = p_cookie_data

     C     1             do        cookie_count  x

     c                   eval      p_cookie_data = cookie_list(x)

     c                   if        cd_temp = *ON
     c                             and dump_session = *OFF
     c                   iter
     c                   endif

     c                   if        cd_temp = *off
     c                             and cd_expires<current
     c                   iter
     c                   endif

     c                   callp     cookie_write(fd)
     c                   enddo

     c                   callp     close(fd)
     c                   eval      p_cookie_data = p_save
     c                   return    *ON
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * header_get_req_cookies(): Get the cookies to be sent back in
      *      a given request header
      *
      *    Host = (input) host that request is being made to
      *    Path = (input) URL path of the request
      *  Secure = (input) is this a secure request?
      *
      * Returns the Cookie: request header, or '' if there are none
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P header_get_req_cookies...
     P                 B                   export
     D header_get_req_cookies...
     D                 PI         32767A   varying
     D   host                       256A   varying const
     D   path                     32767A   varying const
     D   Secure                       1N   const

     D myPath          s            256A   varying
     D pos             s             10I 0
     D x               s             10I 0
     D p_save          s               *
     D retval          s          32767A   varying
     D count           s             10I 0
     D current         s               Z
     D CRLF            c                   x'0d25'
     D temp_host       s            256a   varying

     c                   if        cookie_file <> ''
     c                   callp     cookie_read(cookie_file)
     c                   endif

     c                   eval      temp_host = '.' + host
     c                   eval      pos = %scan('?': path)
     c                   eval      pos = pos - 1
     c                   if        pos>0 and pos<%len(path)
     c                   eval      myPath = %subst(path:1:pos)
     c                   else
     c                   eval      myPath = path
     c                   endif

     c                   eval      p_save = p_cookie_data
     c                   eval      retval = 'Cookie:'
     c                   eval      count = 0
     c                   time                    current

     c                   callp     http_dmsg('There are '
     c                             + %trim(%editc(cookie_count:'P'))
     c                             + ' cookies in the cache')

     C     1             do        cookie_count  x

     c                   eval      p_cookie_data = cookie_list(x)

      * skip expired cookies
     c                   if        cd_temp=*OFF and cd_expires<current
     c                   callp     http_dmsg('cookie=' + cd_name
     c                                      + ' not sent (expired)')
     c                   iter
     c                   endif

      * skip secure cookies unless the connection
      * is also secure
     c                   if        cd_secure=*ON and secure=*OFF
     c                   callp     http_dmsg('cookie=' + cd_name
     c                                      + ' not sent (insecure)')
     c                   iter
     c                   endif

      * skip cookies for other domains/paths
     c                   if        cookie_match( temp_host
     c                                         : myPath
     c                                         : *OFF   ) = *OFF
     c                   callp     http_dmsg('cookie=' + cd_name
     c                                      + ' not sent (wrong path'
     c                                      + ' or domain)')
     c                   iter
     c                   endif

      *
      * Cookie string should look like this:
      *   Cookie: $Version='1'; MyCookie=Foo; $Path=/;
      *   with all cookies listed in the same string.
      *
     c                   eval      count = count + 1
     c                   eval      retval = retval + ' '
     c                                    + %char(UCS2_DOLLAR)
     c                                    + 'Version='
     c                                    + cd_version + ';'

     c                   eval      retval = retval + ' '
     c                                    + cd_name
     c                                    + '='
     c                                    + cd_value + ';'

     c                   if        cd_gotpath = *on
     c                   eval      retval = retval + ' '
     c                                    + %char(UCS2_DOLLAR)
     c                                    + 'Path='
     c                                    + cd_path + ';'
     c                   endif

     c                   if        cd_gotdom = *on
     c                   eval      retval = retval + ' '
     c                                    + %char(UCS2_DOLLAR)
     c                                    + 'Domain='
     c                                    + cd_domain + ';'
     c                   endif

     c                   enddo

     c                   if        count = 0
     c                   eval      retval = ''
     c                   else
     c                   eval      retval = retval + CRLF
     c                   endif

     c                   eval      p_cookie_data = p_save
     c                   return    retval
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Write the current cookie record to disk
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cookie_write    B
     D cookie_write    PI            10I 0
     D   fd                          10I 0 value

     D TAB             C                   x'05'
     D CRLF            c                   x'0d25'

     D dpass           s              5A   varying
     D ppass           s              5A   varying

     D expires         ds
     D   exp                           Z
     D recvd           ds
     D   rec                           Z

     D rcd             s          32767A   varying

     c                   if        cd_gotdom = *ON
     c                   eval      dpass = 'TRUE'
     c                   else
     c                   eval      dpass = 'FALSE'
     c                   endif

     c                   if        cd_gotpath = *ON
     c                   eval      ppass = 'TRUE'
     c                   else
     c                   eval      ppass = 'FALSE'
     c                   endif

     c                   eval      exp = cd_expires
     c                   eval      rec = cd_recv

     c                   eval      rcd = cd_domain  + TAB
     c                                 + dpass      + TAB
     c                                 + cd_path    + TAB
     c                                 + ppass      + TAB
     c                                 + expires    + TAB
     c                                 + recvd      + TAB
     c                                 + cd_version + TAB
     c                                 + cd_secure  + TAB
     c                                 + cd_name    + TAB
     c                                 + cd_value

     c                   if        cd_temp = *on
     c                   eval      rcd = rcd + TAB + 'SESSION' + CRLF
     c                   else
     c                   eval      rcd = rcd + CRLF
     c                   endif

     c                   return    write(fd
     c                                  : %addr(rcd) + VARPREF
     c                                  : %len(rcd) )
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Read the cookie file into memory
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cookie_read     B
     D cookie_read     PI            10I 0
     D   filename                   256A   varying const

     D TAB             C                   x'05'
     D CR              c                   x'0d'
     D LF              c                   x'25'

     D fd              s             10I 0
     D statbuf         s                   like(statds)
     D char            s              1A   based(p_char)
     D size            s             10I 0
     D p_cookies       s               *
     D offset          s             10I 0
     D fieldno         s             10I 0
     D count           s             10I 0
     D field           s          32767A   varying
     D data            s                   like(cookie_data)
     D p_save          s               *

     c                   callp     http_dmsg('cookie_read(): read cookies +
     c                                         from ' + filename)

      *************************************************
      * Load the entire cookie file into memory
      *************************************************
     c                   eval      fd = open( %trimr(filename)
     c                                      : O_RDONLY )
     c                   if        fd = -1
     c                   if        errno = ENOENT
     c                   callp     http_dmsg('No cookie file found. ' +
     c                             '(This may mean that no cookies have ' +
     c                             'been received yet.)')
     c                   return    0
     c                   else
     c                   callp     SetError(HTTP_CKSTAT: 'cookie open(): '
     c                              + %str(strerror(errno)))
     c                   return    -1
     c                   endif
     c                   endif

     c                   if        fstat(fd: %addr(statbuf)) = -1
     c                   callp     SetError(HTTP_CKSTAT: 'cookie stat(): '
     c                              + %str(strerror(errno)))
     c                   return    -1
     c                   endif

     c                   eval      p_statds = %addr(statbuf)
     c                   eval      size = st_size

     c                   if        size < 2
     c                   callp     close(fd)
     c                   return    0
     c                   endif

     C                   eval      p_cookies = xalloc(size)
     c                   callp     read(fd: p_cookies: size)
     c                   callp     close(fd)

      *************************************************
      * Loop through the cookie file, loading each one
      * into the cookie cache
      *************************************************
     c                   eval      p_save = p_cookie_data
     c                   eval      p_cookie_data = %addr(data)

     c                   eval      offset = 0
     c                   eval      fieldno = 0
     c                   eval      count = 0
     c                   callp     cookie_reset(data)
     c                   eval      cd_temp = *off

     c                   dow       offset < size

     c                   eval      p_char = p_cookies + offset

      ** LF means "end of record".  At this point, add the
      ** cookie to the cookie cache
     c                   select
     c                   when      char = LF
     c                   callp     cookie_set(data)
     c                   eval      count = count + 1
     c                   eval      fieldno = 0
     c                   callp     cookie_reset(data)
     c                   eval      cd_temp = *off

      ** CR and TAB end a field.  At this point, add the field
      ** to the data structure.
     c                   when      char = CR or char = TAB
     c                   eval      fieldno = fieldno + 1
     c                   callp     cookie_readfld(fieldno: field)
     c                   eval      field = ''

      ** any other characters are part of the cookie data, and should
      ** be added to the current field.
     c                   other
     c                   eval      field = field + char
     c                   endsl

     c                   eval      offset = offset + 1
     c                   enddo

      *************************************************
      * when done, free up the memory.
      *************************************************
     C                   callp     xdealloc(p_cookies)
     C                   eval      p_cookie_data = p_save
     c                   return                  count
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cookie_readfld(): One cookie field has been read.  Add it
      *                   to the current cookie_data DS.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cookie_readfld  B
     D cookie_readfld  PI
     D   fieldno                     10I 0 value
     D   data                     32767A   varying const

     D expires         ds
     D   exp                           Z
     D recvd           ds
     D   rec                           Z

     c                   select
     c                   when      fieldno = 1
     c                   eval      cd_domain = data

     c                   when      fieldno = 2
     c                   if        data = 'TRUE'
     c                   eval      cd_gotdom = *ON
     c                   else
     c                   eval      cd_gotdom = *OFF
     c                   endif

     c                   when      fieldno = 3
     c                   eval      cd_path = data

     c                   when      fieldno = 4
     c                   if        data = 'TRUE'
     c                   eval      cd_gotpath = *ON
     c                   else
     c                   eval      cd_gotpath = *OFF
     c                   endif

     c                   when      fieldno = 5
     c                   eval      expires = data
     c                   eval      cd_expires = exp

     c                   when      fieldno = 6
     c                   eval      recvd = data
     c                   eval      cd_recv = rec

     c                   when      fieldno = 7
     c                   eval      cd_version = data

     c                   when      fieldno = 8
     c                   eval      cd_secure = data

     c                   when      fieldno = 9
     c                   eval      cd_name = data
     c                   eval      cd_lcname = %xlate(upper:lower:cd_name)

     c                   when      fieldno = 10
     c                   eval      cd_value = data

     c                   when      fieldno = 11
     c                   if        data = 'SESSION'
     c                   eval      cd_temp = *on
     c                   endif

     c                   endsl
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_cookie_file():  Set the name of the file that HTTPAPI
      *          will use to store cookies.
      *
      *    peFilename = (input) Filename (IFS path) to store cookie
      *                  data into.
      *     peSession = (input) include session cookies (temp cookies)
      *                  in cookie file?  Default = *OFF
      *
      *  If the filename is set to '', or if you do not call this API,
      *  cookies will only be saved until the activation group is
      *  reclaimed.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_cookie_file...
     P                 B                   export
     D http_cookie_file...
     D                 PI
     D   peFilename                 256A   varying const
     D   peSession                    1n   const options(*nopass:*omit)
     c                   eval      cookie_file  = %trim(peFilename)
     c                   eval      dump_session = *OFF
     c                   if        %parms >= 2 and %addr(peSession)<>*null
     c                   eval      dump_session = peSession
     c                   endif
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * http_header_count(): Returns the number of headers saved to
      *                      the activation group
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P http_header_count...
     P                 B                   export
     D                 PI            10i 0
     c                   return    hdrs
     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy ERRNO_H
