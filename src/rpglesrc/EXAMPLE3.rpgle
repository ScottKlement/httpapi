      * THE STORY SO FAR:
      * -----------------
      *  EXAMPLE1 showed the basics of downloading a file with HTTP
      *  EXAMPLE2 showed how to use some of the more advanced
      *            parameters related to downloading a file.
      *
      * EXAMPLE3:
      * ----------
      *  HTTPAPI supports SSL (TLS) encryption, like a browser would.
      *  To do that, it uses the operating system's built-in
      *  support for SSL.
      *
      *   Note: The term "SSL" is actually outdated, but most people
      *         are familiar with it. Today's term is "TLS" which
      *         stands for Transport Layer Security. TLS is, really,
      *         the same thing as SSL -- it's just a newer revision
      *         of the protocol.  Think of TLS 1.0 as "SSL 4.0" --
      *         it's just a newer version of SSL, with a new name.
      *         Whenever I mention SSL in comments, you can assume
      *         that I mean "either SSL or TLS".
      *
      *  Since HTTPAPI uses the operating system's support for SSL
      *  you have to make sure the operating system has SSL support
      *  installed and configured.  There is a README member included
      *  in the QRPGLESRC file of HTTPAPI that explains that setup.
      *
      *  The comments & code below will explain:
      *    - How to associate your application with a profile in the
      *        Digital Certificate Manager (optional)
      *
      *
      *
      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO) ACTGRP('HTTPAPI')
      /endif
     H BNDDIR('HTTPAPI')

      /copy httpapi_h

     D cmd             pr                  extpgm('QCMDEXC')
     D   cmd                        200a   const
     D   len                         15p 5 const

     D rc              s             10i 0
     D app_id          s            100a

      /free

        http_debug(*on);

        //**************************************************************
        // BASIC USAGE:
        //   Assuming the operating system has SSL installed and
        //   configured the only requirement to use SSL with HTTPAPI is
        //   that your URL must start with https: instead of http:
        //**************************************************************

        http_stmf( 'GET'
                 : 'https://scottklement.com/ssl.php'
                 : '/tmp/httptest.html' );

        // Use the IBM-provided 'DSPF' command to display the output
        //  it should show that SSL works...

        cmd('DSPF ''/tmp/httptest.html''': 200);


        //***************************************************************
        // Also notice that these examples are now using free-format
        // calcs. HTTPAPI can be used from any of the formats supported
        // by your RPG compiler, fixed-format, free-format, or "all-free".
        //
        // Parameters defined as "const" in the HTTPAPI_H member can either
        // accept variables (as in EXAMPLE1 and 2) or they can receive
        // literals, as I coded, above.
        //*****************************************************************


        //*****************************************************************
        // ADVANCED USAGE:
        //   You can optionally associate HTTPAPI with a profile in the
        //   digital certificate manager.  This is useful when you want
        //   to do something more advanced, such as:
        //      - Use client-side certificates
        //      - Control which SSL certificates you trust separately
        //         for one application vs. another.
        //
        //   To configure a profile in the Digital Certificate Manager,
        //   you should:
        //      - Start the DCM if it's not already running
        //          STRTCPSVR *HTTP HTTPSVR(*ADMIN)
        //      - Using the browser on your PC, go to
        //          http://your.system.example:2001
        //      - Sign-in
        //      - Click Digital Certificate Manager
        //      - Click "Select a Certificate Store".
        //      - Select the *SYSTEM store, and then enter it's password
        //      - On the left, click "Manage Applications"
        //      - then click "Add Application"
        //      - make sure you add a "Client Application"
        //      - The application ID should start with your company
        //         name, then an underscore, then your application name,
        //         and finally the particular component of your application
        //         for example:
        //            ACMEINC_HTTPAPI_EXAMPLE3
        //         Remember this value, because you'll have to tell HTTPAPI
        //         this string.  This is how HTTPAPI knows which profile
        //         to use.
        //      - The "Application description" field should describe your
        //         application.
        //      - The other fields can stay at their default values unless
        //         you have a particular need to customize your application
        //         settings (such as defining a trust list)
        //      - Once you've added your application, you can use "update
        //         certificate assignment" to add a client-side certificate
        //         if desired.
        //
        //   Now that you have your profile in the Digital Certificate
        //   manager, you need to tell HTTPAPI the application-id.  This
        //   is how HTTPAPI knows to use your advanced settings.
        //   This is done with the https_init() API call
        //
        //   After you've done that, future SSL connections will use
        //   the DCM profile
        //*****************************************************************

        app_id = 'ACMEINC_HTTPAPI_EXAMPLE3';
        rc = https_init(app_id);
        if rc = -1;
           http_comp(http_error());
           https_cleanup();
           return;
        endif;

        http_stmf( 'GET'
                 : 'https://scottklement.com/ssl.php'
                 : '/tmp/httptest.html' );

        cmd('DSPF ''/tmp/httptest.html''': 200);


        //*****************************************************************
        // By default, HTTPAPI will remember the DCM settings that you
        // configure until one of three things happens:
        //    - you call https_init() again with new settings.
        //    - you call https_cleanup() to tell HTTPAPI to forget its
        //       settings.
        //    - the activation group ends.
        //
        //  Therefore, the following is completely optional, since it'll
        //  be cleaned up with the activation group ends, anyway...
        //
        // However, if your program will use the same DCM profile each
        // time, and will be called repeatedly, omitting the https_cleanup
        // will improve performance.
        //*****************************************************************

        https_cleanup();
        *inlr = *on;

      /end-free
