script "create_site.lc"
on index
   put transport_DroppedUrl ($_POST_RAW) into droppedURL
   put fedwiki_FetchLastLineUpArray (droppedURL) into pageArray
   -- checkSignature pageArray
   --
   put liveworld_FetchTemplate() into someTemplate
   put liveworld_MergeTemplate (someTemplate, pageArray) into someHTML
   liveworld_SaveHTML someHTML
   --
   put json_FromArray (pageArray) into pageJSON
   transport_ReturnJSON pageJSON
end index
   
command checkSignature pageArray
   put item 2 of the extents of urlArray into lastItemNum
   put lastItemNum - 1 into signatureHeaderItemNum
   
   put pageArray ["Story"][signatureHeaderItemNum]["text"] into signatureHeader
   if signatureHeader is not "Signature" then returnNoSignature
   
   put pageArray ["Story"][lastItemNum]["text"] into signatureBody
   if signatureBody is not "thisismagic" then returnWrongSignature
   return empty
end checkSignature
   
command returnNoSignature
   transport_ExitAndReturnError "This [[transporter]] authors content on the web site and [[requires a signature]].", "No Signature"
end returnNoSignature
   
command returnWrongSignature
   transport_ExitAndReturnError "The content for this [[transporter]] was not signed properly.", "Wrong Signature"
end returnWrongSignature
