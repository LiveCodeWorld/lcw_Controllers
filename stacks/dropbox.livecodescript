script "dropbox.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_DropBox"
end dep_StackNames

on index
   -- put "Hello" into testArray ["World"]
   -- put json_FromArray (testArray) into someJSON
   -- put $_SERVER ["DOCUMENT_ROOT"] into documentRoot
   
   -- put transport_DroppedUrl ($_POST_RAW) into someUrl
   put transport_ConstructErrorJSON ($_POST_RAW) into someJSON
   transport_ReturnJSON someJSON
end index
