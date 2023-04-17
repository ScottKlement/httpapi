      * THE STORY SO FAR:
      * -----------------
      *  EXAMPLE1 showed the basics of downloading a file with HTTP
      *  EXAMPLE2 showed how to use some of the more advanced
      *            parameters related to downloading a file.
      *  EXAMPLE3 showed how you can use SSL/TLS to protect your
      *            HTTP data transferred with HTTPAPI
      *
      * EXAMPLE4:
      * ----------
      *  HTTPAPI is not limited to simply downloading a document from
      *  an HTTP server. It's also capable of performing other operations
      *  including POST, PUT, DELETE, etc.
      *
      *  With POST, you specify a program on the HTTP server to call
      *  and you upload data to that program.
      *
      *  Then you get back a download from the program. (And the down
      *  load part works just like it did in a GET request)
      *
      *  This example attempts to:
      *    - Show how to encode data the way a browser would when you
      *       fill in a form in a browser window.
      *    - Show how to use the HTTP POST method to send that data
      *       to an HTTP server.
      *    - Show how to handle "redirects".  i.e. when a web page
      *       returns a code that asks you to visit another web
      *       page, how to view that page.
      *
      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO) ACTGRP(*NEW)
      /endif
     H BNDDIR('HTTPAPI')

      *
      * Note that this program performs the same function that your
      * web browser would if you pointed it to:
      *     http://www.scottklement.com/comment/
      *
      * There is also a more advanced example that does the same
      * thing using pointers. The advantage is that it isn't limited
      * in data size.  See EXAMPLE15.
      *

      /define WEBFORMS
     D/copy httpapi_h

     D cmd             pr                  extpgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

     D CRLF            C                   CONST(x'0D25')
     D rc              s             10I 0
     D msg             s             52A
     D fromAddr        s            100A   varying
     D Subject         s            100A   varying
     D Message         s           1000A   varying
     D myPointer       s               *
     D dataSize        s             10I 0
     D formData        s          32767a   varying

      /free
        http_debug(*on);

        //
        // CHANGE THIS TO YOUR E-MAIL ADDRESS:
        //
        FromAddr = 'example4@scottklement.com';

        //
        // CHANGE THIS TO THE SUBJECT YOU'D LIKE SENT TO ME:
        //
        Subject = 'EXAMPLE4 from HTTPAPI.';

        //
        // CHANGE THIS TO THE MESSAGE YOU'D LIKE SENT TO ME:
        //
        Message = 'Hi Scott!' + CRLF +
                  '  Just a note to tell you that I''m testing out the +
                  EXAMPLE4 program in HTTPAPI. If you receive this, it +
                  must work!' + CRLF;

        //
        // Encode the data as it would appear on a web form
        //

        formData = 'from=' + http_urlEncode(FromAddr)
                 + '&subject=' + http_urlEncode(Subject)
                 + '&Comment=' + http_urlEncode(message);

        //
        // When sending data, the server will want to know what
        // type of data we're sending. This is done by specifying
        // a "content-type".  In this case, "x-www-form-urlencoded"
        // is the Internet name for a web form.
        //

        http_setOption( 'content-type'
                      : 'application/x-www-form-urlencoded' );

        //
        // This example uses http_req(), which is similar to
        // http_stmf() from the previous examples, except:
        //   - data can be sent from either a stmf or a string
        //   - data can be received into either a stmf or a string
        //   - no error message is sent, instead there's a "return code"
        //       (or 'rc' as I like to abbreviate it)
        //
        // There are two parameters each for the data to receive and
        // the data to send, but you can only use one of each.
        //
        // this example
        //    - passes /tmp/testpost.html for the file to receive into
        //       and *OMIT for the string to receive into.
        //    - passes *OMIT for the file to send data from,
        //       and a variable (with our form data) for a string to send
        //

        rc = http_req( 'POST'
                     : 'http://www.scottklement.com/cgi-bin' +
                       '/email_comment.cgi'
                     : '/tmp/testpost.html'       // File to receive
                     : *omit                      // String to receive
                     : *omit                      // File to send
                     : formData );                // String to send

        //
        // This particular web page doesn't give a direct response
        // but instead asks you to visit another page.  This is done
        // by sending back a 302 ("Page Moved") response.  You can
        // call the http_redir_loc() routine in HTTPAPI to get the
        // URL that the redirection points to, and then the http_url_get()
        // routine to ask HTTPAPI to retrieve that page.
        //

        if rc=302;
           rc = http_req( 'GET'
                        : http_redir_loc()
                        : '/tmp/testpost.html' );
        endif;

        //
        // If there's an error, use the DSPLY opcode to show it on the
        // screen.   If not, use the DSPF command from OS/400 to display
        // the data that was returned onto the screen.
        //
        if rc <> 1;
           msg = http_error();
           dsply msg;
        else;
           cmd('DSPF ''/tmp/testpost.html''': 200);
        endif;

        *inlr = *on;
