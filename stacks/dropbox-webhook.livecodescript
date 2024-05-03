script "dropbox-webhook.lc"
on index
   -- put "Hello" into testArray ["World"]
   -- put json_FromArray (testArray) into someJSON
   -- put $_SERVER ["DOCUMENT_ROOT"] into documentRoot
   
   -- put transport_DroppedUrl ($_POST_RAW) into someUrl
   
   -- put "http://rest.livecode.world/dropbox-webhook?challenge=abc123" into someUrl
   -- put  $_GET ["challenge"] into challengeResult
   
   put rigVarGet ("challenge") into challengeResult
   if challengeResult is not empty then
   put challengeResult
   -- put "Bye"
   else
   put "Hello"
end if
   
   /*
   put transport_ConstructErrorJSON ($_POST_RAW) into someJSON
   transport_ReturnJSON someJSON
   */
end index
