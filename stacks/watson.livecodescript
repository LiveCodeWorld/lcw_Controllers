script "watson.lc"
getprop dep_StackNames
   return "lib_Date,lib_Encoding,lib_Fedwiki,lib_Feed,lib_PageArray,lib_XML,model_PageArray"
end dep_StackNames

on index
   put "https://www.google.com/alerts/feeds/07925126973483736542/15837936957629622679" into rssURL
   put rss_GetPageArray (rssURL, empty, "Alzheimer's Feed", "cast.pod.club") into pageArray
   fedwiki_ReturnPageArray pageArray
end index
