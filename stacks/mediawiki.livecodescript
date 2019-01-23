script "mediawiki.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_MediaWiki,lib_Fedwiki,lib_WikiSandbox,lib_FedWikiPedia,lib_WikiCommons,lib_WikiRestBase,lib_WikipediaSections,lib_Wikipedia,lib_FedwikiCreate"
end dep_StackNames

on index
   fedwiki_SetDroppedInfo $_POST_RAW, droppedURL, droppedHTML, droppedText
   put the result into dropArray
   put fedwiki_IsFaviconDrop() into isFavicon
   switch
      case isFavicon
         -- a fedwiki wikipedia form
         fedwiki_SetDroppedFaviconInfo fedwikiSlug, fedwikiDomain
         -- put the result into isFavicon
         put mediawiki_FetchPageArray (fedwikiSlug, true) into fedwikiPageArray
         fedwiki_ReturnPageArray fedwikiPageArray
         break
      case droppedText is empty and droppedHtml contains "https://upload.wikimedia.org/wikipedia/commons/thumb/"  -- a thumbnail
         thumbNail droppedHtml
         break
      case matchText (droppedURL, "https://(.+).wikipedia.org/wiki/File:(.+)", wikiLanguage, shortImageFile)  -- https://en.wikipedia.org/wiki/File:Lacan2.jpg -- but does not fetch an image?
      case matchText (droppedURL, "https://(.+).wikipedia.org/wiki/(.+)#/media/File:(.+)", wikiLanguage, wikiSlug, shortImageFile)  -- https://en.wikipedia.org/wiki/Ethical_regulator#/media/File:Ethical_Regulator_System.gif
         put wikicommons_FetchImagePageJson (shortImageFile) into pageJSON
         fedwiki_ReturnJSON pageJSON
         break
      case matchText (droppedURL, "^https:\/\/(..)\.wikipedia.org\/w\/index.php\?title=(.+)&action=edit&section=(.+)$", someLang, pageTitle, sectionNum)
         -- section droppedURL
         put wikicommons_ConstructSectionPageArray (pageTitle, sectionNum, droppedURL) into fedwikiPageArray
         fedwiki_ReturnPageArray fedwikiPageArray
         break
      case matchText (droppedURL, "http://wiki.p2pfoundation.net/(.+)", wikiSlug)
      case matchText (droppedURL, "https://rationalwiki.org/wiki/(.+)", wikiSlug)
      case matchText (droppedURL, "https://www.explainxkcd.com/wiki/index.php/(.+)", wikiSlug)
      case matchText (droppedURL, "https://(.+).bitcoin.it/wiki/(.+)", wikiLanguage, wikiSlug)
      case matchText (droppedText, "https://(.+).wikipedia.org/wiki/(.+)", wikiLanguage, wikiSlug)
      case matchText (droppedURL, "https://(.+).wikipedia.org/wiki/(.+)", wikiLanguage, wikiSlug)
         wikipage droppedURL
         break
      default
         fedwiki_ForwardAndReturn "https://rest.livecode.world/echo"
   end switch
end index

on search
   /*
   Following a favicon drop from a fedwiki page onto the imagine transport
   The value of the wikislug is posted to "https://rest.fedwiki.org/imagine/search"
   
   Dropped favicons do not contain all the information needed in the wiki page title - just the fedwiki-slug
   So we need to hack and search for a good match. There will be some wrong matches returned.
   
   We could search for existing pages - and get the realt title from there if such a page exists.
   but we often use ghost pages that are not yet saved on the server:
   -- put fedwiki_FindTitleFromSlug (siteMapArray) into pageTitle
   */
   
   put fedwiki_GetDroppedArray() into postArray
   put postArray ["text"] into fedwikiSlug
   put postArray ["lang"] into lang
   put postArray ["apiStem"] into apiStem
   --
   put mediawiki_FetchPageArray (fedwikiSlug, true, apiStem, lang) into fedwikiPageArray
   fedwiki_ReturnPageArray fedwikiPageArray
end search

on wikipage
   put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
   --
   switch
      case matchText (droppedURL, "http://wiki.p2pfoundation.net/(.+)", wikiSlug)
         -- http://wiki.p2pfoundation.net/api.php?action=query&format=json&prop=images&titles=Cooperatives
         put mediawiki_FetchPageArrayWithParse (wikiSlug, empty, "http://wiki.p2pfoundation.net/api.php?", droppedURL) into fedwikiPageArray
         fedwiki_ReturnPageArray fedwikiPageArray
         break  
      case matchText (droppedURL, "https://www.explainxkcd.com/wiki/index.php/(.+)", wikiSlug)
         put xkcd_FetchPageArray (droppedURL) into fedwikiPageArray
         fedwiki_ReturnPageArray fedwikiPageArray
         break
      case matchText (droppedURL, "https://rationalwiki.org/wiki/(.+)", wikiSlug)
         -- https://rationalwiki.org/wiki/Lead-crime_hypothesis
         put mediawiki_FetchPageArrayWithParse (wikiSlug, empty, "https://rationalwiki.org/w/api.php?", droppedURL) into fedwikiPageArray
         fedwiki_ReturnPageArray fedwikiPageArray
         break
      case matchText (droppedURL, "https://(.+).bitcoin.it/wiki/(.+)", wikiLanguage, wikiSlug)
         put mediawiki_FetchPageArrayWithParse (wikiSlug, empty, "https://en.bitcoin.it/w/api.php?", droppedURL) into fedwikiPageArray
         fedwiki_ReturnPageArray fedwikiPageArray
         break
      case matchText (droppedURL, "https://(.+).wikipedia.org/wiki/(.+)", wikiLanguage, wikiSlug)
         put mediawiki_FetchPageArray (wikiSlug, true) into fedwikiPageArray
         fedwiki_ReturnPageArray fedwikiPageArray
         break
      default
         put fedwiki_ConstructErrorJSON ("Not a Wikipedia page!" && droppedURL) into pageJSON
         fedwiki_ReturnJSON pageJSON
   end switch
end wikipage

on importSection
   -- section droppedURL or a section form
   
   fedwiki_SetDroppedInfo $_POST_RAW, droppedURL, droppedHTML, droppedText
   put the result into dropArray
   put dropArray ["section_title"] into newPageTitle
   
   put "^https:\/\/(..)\.wikipedia.org\/w\/index.php\?title=(.+)&action=edit&section=(.+)$" into someReg
   if matchText (droppedURL, someReg, someLang, pageSlug, sectionNum) is true then
      -- put fedwikipedia_FetchSectionSummaryPageArray (pageSlug, sectionNum) into fedwikiPageArray
      put wikicommons_ConstructSectionPageArray (pageSlug, sectionNum, droppedURL) into fedwikiPageArray
      if newPageTitle is not empty then
         put newPageTitle into fedwikiPageArray ["title"]
      end if
      fedwiki_ReturnPageArray fedwikiPageArray
   else
      put fedwiki_ConstructErrorJSON ("Not a Wikipedia edit link!" && droppedURL) into pageJSON
      fedwiki_ReturnJSON pageJSON
   end if
end importSection

on section
   -- imports multiple subsections
   put fedwiki_GetDroppedUrl() into droppedURL
   switch
      case matchText (droppedURL, "^https:\/\/(..)\.wikipedia.org\/w\/index.php\?title=(.+)&action=edit&section=(.+)$", someLang, pageTitle, sectionNum)
         -- uses restbase api's
         put wikicommons_ConstructSectionPageArray (pageTitle, sectionNum, droppedURL) into fedwikiPageArray
         fedwiki_ReturnPageArray fedwikiPageArray
         break
      default
         put fedwiki_ConstructErrorJSON ("Not a Wikipedia edit link!" && droppedURL) into pageJSON
         fedwiki_ReturnJSON pageJSON
   end switch
end section

command thumbNail droppedHTML
   -- <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"><img alt="" src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Bruce_Sterling_at_ARE_2010.jpg/220px-Bruce_Sterling_at_ARE_2010.jpg" width="220" height="147" class="thumbimage" srcset="//upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Bruce_Sterling_at_ARE_2010.jpg/330px-Bruce_Sterling_at_ARE_2010.jpg 1.5x, //upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Bruce_Sterling_at_ARE_2010.jpg/440px-Bruce_Sterling_at_ARE_2010.jpg 2x" data-file-width="3888" data-file-height="2592">
   -- put script_GetCommentAboveMe() into droppedHTML
   --
   put fedwikipedia_ExtractShortImageFile (droppedHTML) into shortImageFile
   put wikicommons_FetchBasicTwoImagePageArray (shortImageFile) into pageArray
   put json_FromArray (pageArray) into pageJSON
   --
   fedwiki_ReturnJSON pageJSON
end thumbNail

on transportAgain
   /*
   {"title":"Joseph Stalin","create":{"type":"create","item":{"story":"","title":"Assassination"},"date":1459264331300,"source":{"url":"https://en.wikipedia.org/wiki/Leon_trotsky#Assassination","repo":"https://github.com/LiveCodeWorld/lib_MediaWiki","transport":"https://livecode.world/mediawiki/transportAgain","rev":712216007,"date":1459264331300,"link_dictionary":{"wiki_links":{"Legacy":{"section_number":31,"section_level":3,"dot_number":1}},"default":{"transport":"https://livecode.world/mediawiki/importSection"}}}}}
   */
   -- put script_GetCommentAboveMe() into someJSON
   put $_POST_RAW into someJSON
   
   /*
   -- put json_Lint (someJSON) into someJSON
   put fedwiki_ConstructErrorJSON ("Testing Wikipedia transportAgain link!") into errorJSON
   -- put fedwiki_ConstructErrorJSON (someJSON, "JSON") into errorJSON
   fedwiki_ReturnJSON errorJSON
   return false
   */
   
   put json_ToArray (someJSON) into createArray
   put createArray ["title"] into sectionTitle
   put createArray ["create"]["source"] into sourceArray
   if sourceArray is not an array then
      put fedwiki_ConstructErrorJSON ("This is not create JSON", "Error") into errorJSON
      fedwiki_ReturnJSON errorJSON
      return false
   end if
   
   put sourceArray ["transport"] into againTransportURL
   put sourceArray ["url"] into wikipediaURL
   
   put createArray ["create"]["item"]["title"] into parentTitle
   -- if we are 2 or more generations down this is not the pageTitle
   put sourceArray ["pageSlug"] into pageSlug
   put sourceArray ["pageTitle"] into pageTitle
   
   put sourceArray ["link_Dictionary"] into linkDictionary
   put linkDictionary ["wiki_links"][sectionTitle]["section_number"] into sectionNum
   if sectionNum is not a number then
      /*
      put "Can't find section number for" && sectionTitle & CR & CR & sectionNum into errorJSON
      put fedwiki_ConstructErrorJSON (errorJSON, "Not a defined section link") into errorJSON
      fedwiki_ReturnJSON errorJSON
      return false
      */
      
      put fedwiki_FetchWikipediaSummaryPageJson (sectionTitle) into pageJSON
      fedwiki_ReturnJSON pageJSON
      return false
   end if
   
   put linkDictionary ["default"]["transport"] into linkDefaultTransport
   put linkDictionary ["wiki_links"][sectionTitle]["transport"] into linkSpecificTransport
   
   switch linkDefaultTransport
      case "https://rest.livecode.world/mediawiki/importSection"
         /*
         put linkDictionary ["wiki_links"][sectionTitle] into errorArray
         put json_FromArray (errorArray) into dictJSON
         put "Found section number" && sectionNum && "for page" && kwote (pageSlug) & CR & CR & dictJSON into errorJSON
         
         put fedwiki_ConstructErrorJSON (errorJSON, "A defined section link") into errorJSON
         fedwiki_ReturnJSON errorJSON
         return false
         */
         
         put fedwikipedia_FetchSectionSummaryPageJson (pageSlug, sectionNum) into pageJSON
         fedwiki_ReturnJSON pageJSON
         return true
      default
         put linkDictionary ["wiki_links"][sectionTitle] into errorArray
         put json_FromArray (errorArray) into dictJSON
         put "Not a defined section link for" && pageSlug && sectionNum & CR & CR & dictJSON into errorJSON
         put fedwiki_ConstructErrorJSON (errorJSON, "Not a defined section link") into errorJSON
         
         fedwiki_ReturnJSON errorJSON
         return false
   end switch
end transportAgain
