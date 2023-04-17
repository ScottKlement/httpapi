      *
      * EXAMPLE15:
      * ----------
      *  This program does the same thing as EXAMPLE4, but uses the
      *  older, pointer-based http_url_post() routine. There are some
      *  advantages to this approach:
      *
      *   - Pointers allow up to 16mb of data to be stored/returned
      *   - the WEBFORM_xxx APIs allow you to encode an entire form
      *       all at once.
      *   - This works on older releases of IBM i (prior to v6r1)
      *
      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO) ACTGRP(*NEW)
      /endif
     H BNDDIR('HTTPAPI')

      *
      * When form data is sent to a web browser, it often has to be
      * 'encoded'. HTTPAPI contains some routines called 'WEBFORM'
      * routines to help you with that encoding.
      *
      * This demonstrates using HTTPAPI's WEBFORM functions
      * to submit a web form.
      *
      * Note that this program performs the same function that your
      * web browser would if you pointed it to:
      *     http://www.scottklement.com/comment/

      /define WEBFORMS
     D/copy httpapi_h

     D cmd             pr                  extpgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

     D CRLF            C                   CONST(x'0D25')
     D rc              s             10I 0
     D msg             s             52A

     D Form            s                   like(WEBFORM)
     D fromAddr        s            100A   varying
     D Subject         s            100A   varying
     D Message         s           1000A   varying
     D myPointer       s               *
     D dataSize        s             10I 0

      /free

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
                  EXAMPLE15 program in HTTPAPI. If you receive this, it +
                  must work!' + CRLF;


        //
        // When a program emulates a form on an HTML page, it's called
        // a 'webform' in HTTPAPI.  You must first open a new web
        // form, and then set variables in it:
        //
        Form = WEBFORM_open();

        WEBFORM_SetVar(Form: 'from': fromAddr );
        WEBFORM_SetVar(Form: 'subject': subject);
        WEBFORM_SetVar(Form: 'Comment': message);

        //
        // The WEBFORM_postData() routine retrieves data suitable for
        // the http_url_post() API.  (there's also a WEBFORM_getData()
        // if you need to call HTTP_url_get).
        //
        WEBFORM_postData( Form : myPointer: dataSize );

        //
        //  The http_url_post() function does an HTTP POST operation
        //  sending any data at the pointer you specify.
        //
        //  The results, in this case, are saved to the IFS in a file
        //  called '/tmp/testpost.html'
        //
        rc = http_url_post( 'http://www.scottklement.com/cgi-bin/' +
                            'email_comment.cgi'
                          : myPointer
                          : dataSize
                          : '/tmp/testpost.html'
                          : HTTP_TIMEOUT
                          : HTTP_USERAGENT
                          : 'application/x-www-form-urlencoded' );

        //
        // This particular web page doesn't give a direct response
        // but instead asks you to visit another page.  This is done
        // by sending back a 302 ("Page Moved") response.  You can
        // call the http_redir_loc() routine in HTTPAPI to get the
        // URL that the redirection points to, and then the http_url_get()
        // routine to ask HTTPAPI to retrieve that page.
        //

        if rc=302;
           rc = http_url_get( http_redir_loc
                            : '/tmp/testpost.html');
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

        //
        // When done, make sure you call this function to free up
        // the memory that the web form used
        //
        WEBFORM_close(Form);

        *inlr = *on;
      /end-free
