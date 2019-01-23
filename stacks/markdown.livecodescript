script "markdown.lc"
getprop dep_StackNames
    return ""
end dep_StackNames

on index
-- put "Hello" into testArray ["World"]
-- put json_FromArray (testArray) into someJSON
-- put $_SERVER ["DOCUMENT_ROOT"] into documentRoot
 
-- put fedwiki_GetDroppedUrl ($_POST_RAW) into someUrl
put fedwiki_ConstructErrorJSON ($_POST_RAW) into someJSON
fedwiki_ReturnJSON someJSON
end index
