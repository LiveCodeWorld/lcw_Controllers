script "mw_page.lc"
command index
    put mediwiki_ExtractPageTitleFromUrl (droppedURL) into pageTitle
   if pageTitle is empty then
      put "Error, this was not an mediawiki page url" into errorText
      put transport_ConstructErrorJSON (errorText) into someJSON
   else
      put fedwiki_FetchWikipediaPageJson (pageTitle) into someJSON
   end if
   
   put new header "Content-Type: application/json; charset=utf-8"
   put new header "Access-Control-Allow-Origin: *"
   put new header "Access-Control-Allow-Headers: Accept, Authorization, Content-Type"
   put new header "Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE OPTIONS, LINK, UNLINK"
   put someJSON
end index
