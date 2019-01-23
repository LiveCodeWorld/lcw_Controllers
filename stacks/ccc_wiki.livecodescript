script "ccc_wiki.lc"
command index
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   -- put mediwiki_ExtractPageTitleFromUrl(droppedURL) into pageTitle
   -- fedwiki_ReturnError pageTitle, "Not a Wikipedia page!"
   -- put fedwiki_FetchWikipediaPageJson (pageTitle) into someJSON
   
   -- put "http://p2pfoundation.net/Defining_P2P_as_the_relational_dynamic_of_distributed_networks" into droppedURL
   -- put "http://p2pfoundation.net/2.4_Property_and_Commons" into droppedURL
   -- put "http://p2pfoundation.net/Defining_P2P_as_the_relational_dynamic_of_distributed_networks" into droppedURL
   
   put mediawiki_ScrapeContent (droppedURL) into pageArray
   put json_FromArray (pageArray) into someJSON
   
   fedwiki_ReturnJSON someJSON
end index
   
function mediawiki_ScrapeContent droppedURL
   -- div[contains(@class, 'header')]
   -- //*[contains(concat(' ', @class, ' '), ' Test ')] -- http://stackoverflow.com/questions/1604471/how-can-i-find-an-element-by-css-class-with-xpath
   
   put url droppedURL into someHTML
   -- put html_FetchTidy (droppedURL) into someHTML
   put revXMLCreateTree (someHTML, false, true, false) into treeID
   put line 1 of revXMLDataFromXPathQuery (treeID, "//*[@id='firstHeading']", CR, CR) into pageTitle
   put revXMLDataFromXPathQuery (treeID, "//*[@id='mw-content-text']", CR, CR) into someContent
   revDeleteXMLTree treeID
   -- return someContent
   
   if pageTitle begins with "xmlerr" then
   put "Error" into pageTitle
   put pageTitle into someContent
end if
   put fedwiki_ConstructNewPageArray (pageTitle, someContent) into pageArray
   
   -- fedwiki_AddHtmlToPageArray pageArray, pageExtract
   return pageArray
end mediawiki_ScrapeContent
