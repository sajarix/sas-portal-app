/*
 *  This macro will check the result of running XSL
 *  Unfortunately, proc xsl does not give any indication of XSL generation errors.
 *  Thus, we have to rely on the following conventions:
 *
 *     1. Success: XSL Generation that does not create an output file (ex. only generate deleteMetadata
 *        if the object already exists)
 *     2. Success: XSL Generation creates an output file
 *     3. Failure: XSL does not generate an output file (ex. the XSL has a syntax error)
 *     4. Failure: XSL does generate an output file, but the file has ERROR: messages in it (ex.
 *                 there is some piece of metadata that is required as input to the xsl but it's
 *                 not found.)
 *
 *    In #3, ther is no way to create a message that indicates the error.  Thus, we have 
 *    to rely on whether the output file exists or not.
 *
 *    In #4, the xsl code should do 2 things:
 *       - create an xml element with ERROR: <error descriptive text>, for example:
 *         <message>ERROR: an error was found</message>
 *
 *       NOTE: If the xsl code usese the
 *       	<xml:message terminate="yes"> to terminate the xsl processing, no output is written
 *          and #2 becomes like #1, ie. no way of knowing why it failed.
 *          Thus, the use of the terminate"yes" option is discouraged.
 *
 *  Parameters:
 *    xml = a fileref that should contain the output of the xsl process
 *    rc  = a macro variable name that should be set to the return code
 *          0 = success
 *         otherwise = failure
 *    msg = any informative message text to make diagnostics easier.
 */
%macro checkXSLresult(xml=,rc=,msg=,quiet=0);

%macro issueResultMessage;

       %if (&quiet.=0) %then %do;

	       endloc=find(_infile_,'</message>',stringloc);
	       
	       msglength=endloc-stringloc;
	       
	       length message $200;
	       
	       message=substr(_infile_,stringloc,msglength);
	
	       put message;           

           %end;
           
%mend;

%global &rc.;

%let &rc.=1;

/*
 *  If the input file doesn't exist, issue a message and stop processing.
 */
    
%if (%sysfunc(fexist(&xml.))) %then %do;
		
    %showFormattedXML(&xml.,&msg.);
			    
	/* Note: that the xml may be read as 1 big line, so make sure to check for ERROR: first */
	
	/* Note: typically, would not want to parse the file as it can be time consuming.  However, we 
	 *       don't expect the generated xml to be very large and it's critically important that we don't
	 *       submit bad metadata requests (especially those that update metadata), thus we are going to 
	 *       pay the cost.
	 */
	%if (&quiet.=0) %then %do;
    	%if (%length(msg)>0) %then %do;
		    %put --------------------------------------------------;
		    %put &msg.;
		    %put --------------------------------------------------;
	    %end;
	    %end;
	    
	data _null_;
	  infile &xml.;
	  input;
	     
	  stringloc=find(_infile_,'ERROR:');
	  if (stringloc>0) then do;
	    
	       /*
	        *  Get the message and print it to the log.
	        *
	        *  The comment will end with a --> 
	        */
	        
	       %issueResultMessage;
	       call symputx("&rc", 2, 'g');
	       stop;
	       
	      end;
	run;
	
	/*
	 *  If no ERROR messages were found, and the file exists, then assume it was successful.
	 */
	
	%if (&&&rc.=1) %then %do;
	
	    %let &rc.=0;
	
	    %end;
	
	%end;
%else %do;
    %if (&quiet.=0) %then %do;
        %put ERROR: XML File, &xml., does not exist.;
        %end;
    %end;

/*
 *  If the return code is not 0, then assume that the xsl processing failed.
 */

%if (&&&rc.>0) %then %do;

    %if (&quiet.=0) %then %do;

        %put ERROR: XSL processing failed, potential XSL syntax error.;
        
        %end;
    
    %end;
  
%mend;