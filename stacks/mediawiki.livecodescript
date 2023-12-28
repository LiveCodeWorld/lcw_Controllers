script "mediawiki.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Curly,lib_Encoding,lib_Fedwiki,lib_FedWikiPedia,lib_Map,lib_MediaWiki,lib_PageArray,lib_PageSection,lib_WikiCommons,lib_WikiPageArray,lib_WikiRestBase,lib_WikiSandbox,lib_WikiVideo,lib_Xkcd,model_PageArray"
end dep_StackNames

on index
   fedwiki_SetDroppedInfo dropJSON, droppedURL, droppedHTML, droppedText
   put the result into dropArray
   put fedwiki_IsFaviconDrop (dropJSON) into isFavicon
   --
   put index_GetPageArray (droppedURL) into pageArray
   --
   fedwiki_ReturnPageArray pageArray
end index

function index_GetPageArray droppedURL
   switch
      case isFavicon
         favicon
         break
      case matchText (droppedURL, "https://(.+).wikipedia.org/wiki/File:(.+)", wikiLanguage, shortImageFile)
      case matchText (droppedURL, "https://(.+).wikipedia.org/wiki/(.+)#/media/File:(.+)", wikiLanguage, wikiSlug, shortImageFile)
         put wikicommons_FetchImagePageJson (shortImageFile) into pageJSON
         break
      case matchText (droppedURL, "^https:\/\/(..)\.wikipedia.org\/w\/index.php\?title=(.+)&action=edit&section=(.+)$", someLang, pageTitle, sectionNum)
         put wikicommons_ConstructSectionPageArray (pageTitle, sectionNum, droppedURL) into pageArray
         break
      case matchText (droppedURL, "https://www.gameb.wiki/index.php\?title=(.+)", wikiSlug)
      case matchText (droppedURL, "https://sterbalssundrystudies.miraheze.org/wiki/(.+)", wikiSlug)
      case matchText (droppedURL, "http://wiki.p2pfoundation.net/(.+)", wikiSlug)
      case matchText (droppedURL, "https://rationalwiki.org/wiki/(.+)", wikiSlug)
      case matchText (droppedURL, "https://www.explainxkcd.com/wiki/index.php/(.+)", wikiSlug)
      case matchText (droppedURL, "https://(.+).bitcoin.it/wiki/(.+)", wikiLanguage, wikiSlug)
      case matchText (droppedText, "https://(.+).wikipedia.org/wiki/(.+)", wikiLanguage, wikiSlug)
      case matchText (droppedURL, "https://(.+).wikipedia.org/wiki/(.+)", wikiLanguage, wikiSlug)
      case matchText (droppedURL, "https://meta.wikimedia.org/wiki/(.+)", wikiSlug)
         -- https://meta.wikimedia.org/wiki/Community_Wishlist_Survey_2021/Admins_and_patrollers/Discourage_External_Spam_that_Exploits_Wikipedia
         put dropArray_WikiPage (droppedURL) into pageArray
         break
      case matchText (droppedURL, "https://commons.wikimedia.org/wiki/(File:.+.ogg)", shortAudioFile)
         put "An audio from the commons..." into someText
         put wikicommons_ConstructAudioPageArray ("Wikimedia Audio", someText, droppedURL, shortAudioFile) into pageArray
         break
      case matchText (droppedURL, "https://commons.wikimedia.org/wiki/(File:.+.ogv)", shortVideoFile)
      case matchText (droppedURL, "https://commons.wikimedia.org/wiki/(File:.+.webm)", shortVideoFile)
         put "A video from the commons..." into someText
         put wikicommons_ConstructVideoPageArray ("Wikimedia Video", someText, droppedURL, shortVideoFile) into pageArray
         break
      case matchText (droppedURL, "https://commons.wikimedia.org/wiki/(File:.+)", shortImageFile)
         put "Wikimedia Image" into pageTitle
         put "Drag these images to your source page..." into someText
         put pageArray_Construct (pageTitle, someText) into pageArray   
         wikicommons_FetchAndAddTwoImages pageArray, shortImageFile
         pageArray_CleanJournal pageArray
         break
      case droppedText is empty and droppedHtml contains "https://upload.wikimedia.org/wikipedia/commons/thumb/"  -- a thumbnail
         thumbNail droppedHtml
         break
      default
         put pageArray_Construct ("Error", "Not a mediawiki site I recognise!") into pageArray
   end switch
   -- 
   return pageArray
end index_GetPageArray

on wikipage
   put fedwiki_GetDroppedUrl() into droppedURL
   --
   put dropArray_WikiPage (droppedURL) into pageArray
   --
   fedwiki_ReturnPageArray pageArray
end wikipage

on form
   put fedwiki_GetDroppedArray() into postedArray
   put postedArray ["title"] into pageTitle
   put postedArray ["url"] into postedURL
   --
   switch
      case postedURL is not empty
         put dropArray_WikiPage (postedURL) into pageArray
         break
      case pageTitle is not empty
         put mediawiki_GetPageArrayFromSlug (pageTitle) into pageArray
         break
      default
         put pageArray_Construct ("Error", "Failed to post a wikipedia url or title to form!") into pageArray
   end switch
   --
   fedwiki_ReturnPageArray pageArray
end form

on favicon
   fedwiki_SetDroppedFaviconInfo fedwikiSlug, fedwikiDomain
   mediawiki_NormaliseTitle fedwikiSlug, pageTitle, pageID
   put "https://en.wikipedia.org/wiki/" & pageTitle into wikipediaUrl
   put the result into batchArray
   put mediawiki_FetchPageArray (wikipediaURL) into pageArray
   fedwiki_ReturnPageArray pageArray
end favicon

on importSection
   -- put fedwiki_GetDroppedArray() into dropArray
   fedwiki_SetDroppedInfo dropJSON, droppedURL, droppedHTML, droppedText
   put the result into dropArray
   put dropArray ["section_title"] into newPageTitle
   put dropArray ["url"] into formURL
   if formURL is not empty then put formURL into droppedURL
   
   put "^https:\/\/(..)\.wikipedia.org\/w\/index.php\?title=(.+)&action=edit&section=(.+)$" into someReg
   switch
      case matchText (droppedURL, someReg, someLang, pageSlug, sectionNum)
         -- put fedwikipedia_FetchSectionSummaryPageArray (pageSlug, sectionNum) into pageArray
         put wikicommons_ConstructSectionPageArray (pageSlug, sectionNum, droppedURL) into pageArray
         if newPageTitle is not empty then pageArray_Rename pageArray, newPageTitle
         fedwiki_ReturnPageArray pageArray
         break
      default
         put pageArray_Construct ("Not a Wikipedia edit link!", "Not a Wikipedia edit link!" && droppedURL) into pageArray
         fedwiki_ReturnPageArray pageArray
   end switch
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

function dropArray_WikiPage droppedURL
   switch
      case matchText (droppedURL, "https://meta.wikimedia.org/wiki/(.+)", wikiSlug)
         -- https://meta.wikimedia.org/wiki/Community_Wishlist_Survey_2021/Admins_and_patrollers/Discourage_External_Spam_that_Exploits_Wikipedia
         put mediawiki_FetchPageArrayWithParse (wikiSlug, empty, "https://meta.wikimedia.org/w/api.php?", droppedURL) into pageArray
         break
      case matchText (droppedURL, "https://www.gameb.wiki/index.php\?title=(.+)", wikiSlug)
         put mediawiki_FetchPageArrayWithParse (wikiSlug, empty, "http://www.gameb.wiki/api.php?", droppedURL) into pageArray
         break
      case matchText (droppedURL, "http://wiki.p2pfoundation.net/(.+)", wikiSlug)
         put mediawiki_FetchPageArrayWithParse (wikiSlug, empty, "http://wiki.p2pfoundation.net/api.php?", droppedURL) into pageArray
         break  
      case matchText (droppedURL, "https://www.explainxkcd.com/wiki/index.php/(.+)", wikiSlug)
         put xkcd_FetchPageArray (droppedURL) into pageArray
         break
      case matchText (droppedURL, "https://rationalwiki.org/wiki/(.+)", wikiSlug)
         put mediawiki_FetchPageArrayWithParse (wikiSlug, empty, "https://rationalwiki.org/w/api.php?", droppedURL) into pageArray
         break
      case matchText (droppedURL, "https://(.+).bitcoin.it/wiki/(.+)", wikiLanguage, wikiSlug)
         put mediawiki_FetchPageArrayWithParse (wikiSlug, empty, "https://en.bitcoin.it/w/api.php?", droppedURL) into pageArray
         break
      case matchText (droppedURL, "https://sterbalssundrystudies.miraheze.org/wiki/(.+)", wikiSlug)
         put mediawiki_FetchPageArrayWithParse (wikiSlug, empty, "https://sterbalssundrystudies.miraheze.org/w/api.php?", droppedURL) into pageArray
         break
      case matchText (droppedURL, "https://(.+).wikipedia.org/wiki/(.+)", wikiLanguage, wikiSlug)
         put mediawiki_FetchPageArray (droppedURL) into pageArray
         break
      default
         put pageArray_Construct ("Not a Wikipedia page!", "Not a Wikipedia page!" && droppedURL) into pageArray
   end switch
   return pageArray
end dropArray_WikiPage
