script "mediawiki.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Curly,lib_Fedwiki,lib_FedWikiPedia,lib_MediaWiki,lib_PageArray,lib_WikiCommons,lib_WikiPageArray,lib_WikiRestBase,lib_WikiSandbox,lib_WikiVideo,lib_Xkcd,model_PageArray"
end dep_StackNames

on index
   fedwiki_SetDroppedInfo dropJSON, droppedURL, droppedHTML, droppedText
   put the result into dropArray
   put fedwiki_IsFaviconDrop (dropJSON) into isFavicon
   switch
      case isFavicon
         favicon
         break
      case matchText (droppedURL, "https://(.+).wikipedia.org/wiki/File:(.+)", wikiLanguage, shortImageFile)
      case matchText (droppedURL, "https://(.+).wikipedia.org/wiki/(.+)#/media/File:(.+)", wikiLanguage, wikiSlug, shortImageFile)
         put wikicommons_FetchImagePageJson (shortImageFile) into pageJSON
         fedwiki_ReturnJSON pageJSON
         break
      case matchText (droppedURL, "^https:\/\/(..)\.wikipedia.org\/w\/index.php\?title=(.+)&action=edit&section=(.+)$", someLang, pageTitle, sectionNum)
         put wikicommons_ConstructSectionPageArray (pageTitle, sectionNum, droppedURL) into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      case matchText (droppedURL, "https://sterbalssundrystudies.miraheze.org/wiki/(.+)", wikiSlug)
      case matchText (droppedURL, "http://wiki.p2pfoundation.net/(.+)", wikiSlug)
      case matchText (droppedURL, "https://rationalwiki.org/wiki/(.+)", wikiSlug)
      case matchText (droppedURL, "https://www.explainxkcd.com/wiki/index.php/(.+)", wikiSlug)
      case matchText (droppedURL, "https://(.+).bitcoin.it/wiki/(.+)", wikiLanguage, wikiSlug)
      case matchText (droppedText, "https://(.+).wikipedia.org/wiki/(.+)", wikiLanguage, wikiSlug)
      case matchText (droppedURL, "https://(.+).wikipedia.org/wiki/(.+)", wikiLanguage, wikiSlug)
         wikipage droppedURL
         break
      case matchText (droppedURL, "https://commons.wikimedia.org/wiki/(File:.+.ogg)", shortAudioFile)
         put "An audio from the commons..." into someText
         put wikicommons_ConstructAudioPageArray ("Wikimedia Audio", someText, droppedURL, shortAudioFile) into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      case matchText (droppedURL, "https://commons.wikimedia.org/wiki/(File:.+.ogv)", shortVideoFile)
      case matchText (droppedURL, "https://commons.wikimedia.org/wiki/(File:.+.webm)", shortVideoFile)
         put "A video from the commons..." into someText
         put wikicommons_ConstructVideoPageArray ("Wikimedia Video", someText, droppedURL, shortVideoFile) into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      case matchText (droppedURL, "https://commons.wikimedia.org/wiki/(File:.+)", shortImageFile)
         -- put wikicommons_FetchBasicTwoImagePageArray (shortImageFile, pPageTitle, pSomeText, droppedURL) into pageArray
         put "Wikimedia Image" into pageTitle
         put "Drag these images to your source page..." into someText
         put fedwiki_ConstructPageArray (pageTitle, someText) into pageArray   
         wikicommons_FetchAndAddTwoImages pageArray, shortImageFile
         fedwiki_CleanJournal pageArray
         fedwiki_ReturnPageArray pageArray
         break
      case droppedText is empty and droppedHtml contains "https://upload.wikimedia.org/wikipedia/commons/thumb/"  -- a thumbnail
         thumbNail droppedHtml
         break
      default
         fedwiki_ForwardAndReturn "https://rest.livecode.world/echo"
   end switch
end index

command fedwiki_TestJsonUrl jsonURL, @pageTitle, @storyArray, @journalArray
   -- http://openscience.cc/maven-science.json
   put "http://(.+)/(.+).json" into someReg
   if matchtext (jsonURL, someReg, wikiDomain, pageSlug) is false then
      -- if not (jsonURL ends with ".json") then
      put empty into pageTitle
      put empty into storyArray
      put empty into journalArray
      return false
   end if
   --
   put url jsonURL into pageJSON
   put json_ToArray (pageJSON) into pageArray
   --
   put pageArray ["title"] into pageTitle
   put pageArray ["story"] into storyArray
   put pageArray ["journal"] into journalArray
   --
   if pageTitle is empty or storyArray is not an array or journalArray is not an array then
      return false
   else
      return true
   end if
end fedwiki_TestJsonUrl

on wikipage
   put fedwiki_GetDroppedUrl() into droppedURL
   switch
      case matchText (droppedURL, "http://wiki.p2pfoundation.net/(.+)", wikiSlug)
         put mediawiki_FetchPageArrayWithParse (wikiSlug, empty, "http://wiki.p2pfoundation.net/api.php?", droppedURL) into pageArray
         fedwiki_ReturnPageArray pageArray
         break  
      case matchText (droppedURL, "https://www.explainxkcd.com/wiki/index.php/(.+)", wikiSlug)
         put xkcd_FetchPageArray (droppedURL) into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      case matchText (droppedURL, "https://rationalwiki.org/wiki/(.+)", wikiSlug)
         put mediawiki_FetchPageArrayWithParse (wikiSlug, empty, "https://rationalwiki.org/w/api.php?", droppedURL) into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      case matchText (droppedURL, "https://(.+).bitcoin.it/wiki/(.+)", wikiLanguage, wikiSlug)
         put mediawiki_FetchPageArrayWithParse (wikiSlug, empty, "https://en.bitcoin.it/w/api.php?", droppedURL) into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      case matchText (droppedURL, "https://sterbalssundrystudies.miraheze.org/wiki/(.+)", wikiSlug)
         put mediawiki_FetchPageArrayWithParse (wikiSlug, empty, "https://sterbalssundrystudies.miraheze.org/w/api.php?", droppedURL) into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      case matchText (droppedURL, "https://(.+).wikipedia.org/wiki/(.+)", wikiLanguage, wikiSlug)
         put mediawiki_FetchPageArray (droppedURL) into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      default
         put pageArray_Construct ("Not a Wikipedia page!", "Not a Wikipedia page!" && droppedURL) into pageArray
         fedwiki_ReturnPageArray pageArray
   end switch
end wikipage

on favicon
   fedwiki_SetDroppedFaviconInfo fedwikiSlug, fedwikiDomain
   mediawiki_NormaliseTitle fedwikiSlug, pageTitle, pageID
   -- put wikipedia_ConstructURL (pageTitle) into wikipediaURL
   -- replace space with "_" in pageSlug
   put "https://en.wikipedia.org/wiki/" & pageTitle into wikipediaUrl
   -- put fedwiki_ConstructPageArray ("Test", wikipediaURL) into pageArray
   put the result into batchArray
   put mediawiki_FetchPageArray (wikipediaURL) into pageArray
   fedwiki_ReturnPageArray pageArray
end favicon

on importSection
   -- section droppedURL or a section form
   fedwiki_SetDroppedInfo dropJSON, droppedURL, droppedHTML, droppedText
   put the result into dropArray
   put dropArray ["section_title"] into newPageTitle
   
   put "^https:\/\/(..)\.wikipedia.org\/w\/index.php\?title=(.+)&action=edit&section=(.+)$" into someReg
   if matchText (droppedURL, someReg, someLang, pageSlug, sectionNum) is true then
      -- put fedwikipedia_FetchSectionSummaryPageArray (pageSlug, sectionNum) into pageArray
      put wikicommons_ConstructSectionPageArray (pageSlug, sectionNum, droppedURL) into pageArray
      if newPageTitle is not empty then
         pageArray_Rename pageArray, newPageTitle
      end if
      fedwiki_ReturnPageArray pageArray
   else
      put pageArray_Construct ("Not a Wikipedia edit link!", "Not a Wikipedia edit link!" && droppedURL) into pageArray
      fedwiki_ReturnPageArray pageArray
   end if
end importSection

on section
   -- imports multiple subsections
   put fedwiki_GetDroppedUrl() into droppedURL
   switch
      case matchText (droppedURL, "^https:\/\/(..)\.wikipedia.org\/w\/index.php\?title=(.+)&action=edit&section=(.+)$", someLang, pageTitle, sectionNum)
         -- uses restbase api's
         put wikicommons_ConstructSectionPageArray (pageTitle, sectionNum, droppedURL) into pageArray
         fedwiki_ReturnPageArray pageArray
         break
      default
         put pageArray_Construct ("Not a Wikipedia edit link!", "Not a Wikipedia edit link!" && droppedURL) into pageArray
         fedwiki_ReturnPageArray pageArray
   end switch
end section

command thumbNail droppedHTML
   put fedwikipedia_ExtractShortImageFile (droppedHTML) into shortImageFile
   put wikicommons_FetchBasicTwoImagePageArray (shortImageFile) into pageArray
   put json_FromArray (pageArray) into pageJSON
   --
   fedwiki_ReturnJSON pageJSON
end thumbNail
