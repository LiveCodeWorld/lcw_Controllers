script "wiki.lc"
on index
    put transport_DroppedUrl ($_POST_RAW) into droppedURL
    put mediwiki_ExtractPageTitleFromUrl (droppedURL) into pageTitle
    transport_ReturnError pageTitle, "Not a Wikipedia page!"
    
    put fedwiki_FetchWikipediaPageJson (pageTitle) into someJSON
    transport_ReturnJSON someJSON
 end index

 command startUsingLibraries
    start using stack (gAPPPATH & "stacks/" & lib_Fedwiki.livecode )
    start using stack (gAPPPATH & "stacks/" & lib_MediaWiki.livecode )
    start using stack (gAPPPATH & "stacks/" & lib_FedWikiPedia.livecode )
 end startUsingLibraries
