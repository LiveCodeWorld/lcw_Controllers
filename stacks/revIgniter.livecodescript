script "revIgniter.lc"
on index
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   put url droppedURL into someHTML
   
   rig_ScrapeHeadings someHtml, pageTitle, handlerNames, longPaths
   put the result into headerPageArray
   
   put rig_ConstructFedwikiPageArray (headerPageArray) into fedwikiPageArray
   
   fedwiki_ReturnPageArray fedwikiPageArray
end index
   
on transportAgain
   /*
   {"title":"Joseph Stalin","create":{"type":"create","item":{"story":"","title":"Assassination"},"date":1459264331300,"source":{"url":"https://en.wikipedia.org/wiki/Leon_trotsky#Assassination","repo":"https://github.com/LiveCodeWorld/lib_MediaWiki","transport":"https://livecode.world/mediawiki/transportAgain","rev":712216007,"date":1459264331300,"link_dictionary":{"wiki_links":{"Legacy":{"section_number":31,"section_level":3,"dot_number":1}},"default":{"transport":"https://livecode.world/mediawiki/importSection"}}}}}
   */
   -- put script_GetCommentAboveMe() into someJSON
   
   put $_POST_RAW into someJSON
   -- put json_Lint (someJSON) into someJSON
   put fedwiki_ConstructErrorJSON (someJSON, "JSON") into errorJSON
   fedwiki_ReturnJSON errorJSON
   return false
   
   put json_ToArray (someJSON) into createArray
   fedwiki_DeconstructCreateArray createArray, parentTitle, sectionTitle, transportURL, sourceURL, pageTitle, linkDictionary
   if linkDictionary is not an array then
   put fedwiki_ConstructErrorJSON ("This is not create JSON", "Error") into errorJSON
   fedwiki_ReturnJSON errorJSON
   return false
end if
end transportAgain
