script "mediawiki.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Curly,lib_Encoding,lib_Fedwiki,lib_FedWikiPedia,lib_Map,lib_MediaWiki,lib_PageArray,lib_PageSection,lib_WikiCommons,lib_WikiPageArray,lib_WikiRestBase,lib_WikiSandbox,lib_WikiVideo,lib_Xkcd,model_PageArray"
end dep_StackNames

on index
   put transport_DroppedUrl() into droppedURL
   put index_GetPageArray (droppedURL) into pageArray
   transport_ReturnPageArray pageArray
end index

on summary
   put transport_DroppedUrl() into droppedURL
   put transport_DroppedValue ("title") into searchString
   mediawiki_NormaliseTitle searchString, pageTitle, pageID
   --
   switch
      case droppedURL is not empty
         put index_GetPageArray (droppedURL) into pageArray
         break
      case pageID is a number
         put mediawiki_FetchSummaryPageArray (pageTitle) into pageArray
         -- put fedwikipedia_FetchSectionSummaryPageArray (pageTitle, 2) into pageArray
         -- put fedwiki_FetchWikipediaSummaryPageArray (pageTitle) into pageArray
         break
      default
         put "Cannot locate" && kwote (searchString) into sText
         put pageArray_Construct ("Wikipedia Search", sText) into pageArray
   end switch
   --
   transport_ReturnPageArray pageArray
end summary

on toc
   put transport_DroppedValue ("pageTitle") into pageTitle
   --
   put mediaWiki_ConstructSlug (pageTitle) into pageSlug
   put "Here is a table of contents for the Wikipedia Page" && kwote (pageTitle) into someMarkdown
   put pageArray_Construct ("Table of Contents", someMarkdown) into pageArray
   
   # Add TOC Section
   put mediawiki_FetchMarkdownTOC (pageSlug) into markdownTOC
   if markdownTOC is not empty then
      put "# See also" && CR&CR before markdownTOC
      pageArray_AddMarkdown pageArray, markdownTOC
   end if
   --
   transport_ReturnPageArray pageArray
end toc

on tocButtons
   put transport_DroppedValue ("pageTitle") into pageTitle
   --
   put wikiPage_TocButtons (pageTitle) into pageArray
   transport_ReturnPageArray pageArray
end tocButtons

on provenance
   put transport_GetDroppedArray() into postedArray
   put postedArray ["wikiDomain"] into wikiDomain
   put postedArray ["pageSlug"] into pageSlug
   --
   put postedArray ["mwTitle"] into mwTitle
   put mediaWiki_ConstructSlug (mwTitle) into mwSlug
   -- 
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   pageArray_AddWikipediaCred pageArray, mwTitle, mwSlug
   --
   transport_ReturnPageArray pageArray
end provenance

on form
   put transport_GetDroppedArray() into postedArray
   put postedArray ["title"] into pageTitle
   put postedArray ["url"] into postedURL
   --
   switch
      case postedURL is not empty
         put dropArray_WikiPage (postedURL) into pageArray
         break
      case pageTitle is not empty
         put mediawiki_FetchSummaryPageArray (pageTitle) into pageArray
         -- put mediawiki_FetchPageArray (droppedURL) into pageArray
         -- put mediawiki_GetPageArrayFromSlug (pageTitle) into pageArray
         break
      default
         put pageArray_Construct ("Error", "Failed to post a wikipedia url or title to form!") into pageArray
   end switch
   --
   transport_ReturnPageArray pageArray
end form

on gallery
   put transport_DroppedValue ("title") into searchTitle
   put wikiPage_GalleryPedia (searchTitle) into pageArray
   transport_ReturnPageArray pageArray
end gallery

on related
   put transport_DroppedValue ("title") into searchTitle
   put wikiPage_RelatedWikipedia (searchTitle, "Related Wikipedia Pages") into pageArray
   transport_ReturnPageArray pageArray
end related

on wikipage
   put transport_DroppedUrl() into droppedURL
   --
   put dropArray_WikiPage (droppedURL) into pageArray
   --
   transport_ReturnPageArray pageArray
end wikipage

on favicon
   transport_SetDroppedFaviconInfo fedwikiSlug, fedwikiDomain
   mediawiki_NormaliseTitle fedwikiSlug, pageTitle, pageID
   put "https://en.wikipedia.org/wiki/" & pageTitle into wikipediaUrl
   put the result into batchArray
   put mediawiki_FetchPageArray (wikipediaURL) into pageArray
   transport_ReturnPageArray pageArray
end favicon

on importSection
   put transport_GetDroppedArray() into dropArray
   put dropArray ["url"] into droppedURL
   -- launch url formURL
   --
   put "^https:\/\/(..)\.wikipedia.org\/w\/index.php\?title=(.+)&action=edit&section=(.+)$" into someReg
   switch
      case matchText (droppedURL, someReg, someLang, pageSlug, sectionNum)
         put dropArray ["section_title"] into newPageTitle
         set the itemdelimiter to slash
         put item 1 to 3 of droppedURL into apiStem -- https://en.wikipedia.org
         --
         put wikicommons_ConstructSectionPageArray (pageSlug, sectionNum, apiStem, newPageTitle) into pageArray
         --
         if newPageTitle is not empty then pageArray_Rename pageArray, newPageTitle
         break
      default
         put pageArray_Construct ("Not a Wikipedia edit link!", "Not a Wikipedia edit link!" && droppedURL) into pageArray
   end switch
   --
   transport_ReturnPageArray pageArray
end importSection

on section
   -- imports multiple subsections
   put transport_DroppedUrl() into droppedURL
   switch
      case matchText (droppedURL, "^https:\/\/(..)\.wikipedia.org\/w\/index.php\?title=(.+)&action=edit&section=(.+)$", someLang, pageTitle, sectionNum)
         set the itemdelimiter to slash
         put item 1 to 3 of droppedURL into apiStem -- https://en.wikipedia.org
         put wikicommons_ConstructSectionPageArray (pageTitle, sectionNum, droppedURL) into pageArray
         transport_ReturnPageArray pageArray
         break
      default
         put pageArray_Construct ("Not a Wikipedia edit link!", "Not a Wikipedia edit link!" && droppedURL) into pageArray
         transport_ReturnPageArray pageArray
   end switch
end section

command thumbNail droppedHTML
   put fedwikipedia_ExtractShortImageFile (droppedHTML) into shortImageFile
   put wikicommons_FetchBasicTwoImagePageArray (shortImageFile) into pageArray
   put json_FromArray (pageArray) into pageJSON
   --
   transport_ReturnJSON pageJSON
end thumbNail

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
         set the itemdelimiter to slash
         put item 1 to 3 of droppedURL into apiStem -- https://en.wikipedia.org
         put wikicommons_ConstructSectionPageArray (pageTitle, sectionNum, apiStem) into pageArray
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
      case matchText (droppedURL, "https://wiki.creativecommons.org/wiki/(.*)", wikiSlug)
         -- /api.php?action=help&format=json
         -- https://wiki.creativecommons.org/api.php?action=query&format=json
         put mediawiki_FetchPageArrayWithParse (wikiSlug, empty, "https://wiki.creativecommons.org/api.php?", droppedURL) into pageArray
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
      case matchText (droppedURL, "https://wiki.creativecommons.org/wiki/(.*)", wikiSlug)
         -- /api.php?action=help&format=json
         put mediawiki_FetchPageArrayWithParse (wikiSlug, empty, "https://wiki.creativecommons.org/w/api.php?", droppedURL) into pageArray
         break
      case matchText (droppedURL, "https://(.+).wikipedia.org/wiki/(.+)", wikiLanguage, wikiSlug)
         put mediawiki_FetchPageArray (droppedURL) into pageArray
         break
      default
         put pageArray_Construct ("Not a Wikipedia page!", "Not a Wikipedia page!" && droppedURL) into pageArray
   end switch
   return pageArray
end dropArray_WikiPage
