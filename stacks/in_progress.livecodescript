script "in_progress.lc"
on index
    fedwiki_ParseDropUrl $_POST_RAW
 end index
 
 on thumbNail
    -- <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"><img alt="" src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Bruce_Sterling_at_ARE_2010.jpg/220px-Bruce_Sterling_at_ARE_2010.jpg" width="220" height="147" class="thumbimage" srcset="//upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Bruce_Sterling_at_ARE_2010.jpg/330px-Bruce_Sterling_at_ARE_2010.jpg 1.5x, //upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Bruce_Sterling_at_ARE_2010.jpg/440px-Bruce_Sterling_at_ARE_2010.jpg 2x" data-file-width="3888" data-file-height="2592">
    put script_GetCommentAboveMe() into droppedHTML
    
    -- put json_ToArray ($_POST_RAW) into dropArray
    -- put dropArray ["html"] into droppedHtml
    fedwiki_ParseWikipediaThumbNail droppedHtml
 end thumbNail
 
 on fedwikiLink
    put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
    fedwiki_ParseFedwikiLink droppedURL, $_POST_RAW
 end fedwikiLink
 
 on editLink
    put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
    if matchText (droppedURL, "^https:\/\/(..)\.wikipedia.org\/w\/index.php\?title=(.+)&action=edit&section=(.+)$", someLang, sectionTitle, sectionNum) is true then
       set the itemdelimiter to "&"
       put item 1 of sectionNum into sectionNum
       fedwiki_ParseWikipediaEditLink sectionTitle, sectionNum, droppedURL, someLang
    else
       put fedwiki_ConstructErrorJSON ("Not a Wikipedia edit link!") into pageJSON
       fedwiki_ReturnJSON pageJSON
    end if
 end editLink
    
 on summaryPage
    put fedwiki_GetDroppedUrl ($_POST_RAW) into wikipediaUrl
    put mediwiki_ExtractPageSlugFromUrl (wikipediaUrl) into pageSlug
    put fedwiki_FetchWikipediaSummaryPageJson (pageSlug) into pageJSON
    fedwiki_ReturnJSON pageJSON
 end summaryPage
 
 on importPage
    put fedwiki_GetDroppedUrl ($_POST_RAW) into wikipediaUrl
    put fedwiki_FetchCoolWikipediaPageJson (wikipediaUrl) into someJSON
    fedwiki_ReturnJSON someJSON
 end importPage
    
 on importImage
    put fedwiki_GetDroppedUrl ($_POST_RAW) into droppedURL
    put mediwiki_ExtractImageFileFromUrl (droppedURL) into shortImageFile
    put fedwiki_FetchWikipediaImagePageJson (shortImageFile) into someJSON
    fedwiki_ReturnJSON someJSON
 end importImage
    
 on importImages
    put fedwikipedia_GetPageSlug ($_POST_RAW) into pageTitle
    
    -- put fedwiki_FetchWikipediaImagesPageArray (pageTitle, 6) into fedwikiPageArray
    put "Here is a selection of images from Wikipedia ready to import." into pSomeText
    put fedwiki_ConstructNewPageArray ("Test Wikpedia Image Import", pSomeText) into fedwikiPageArray
    wikicommons_AddAllImages fedwikiPageArray, pageTitle
    
    put json_FromArray (fedwikiPageArray) into pageJSON
    fedwiki_ReturnJSON pageJSON
 end importImages
    
 on listImages
    -- put mediwiki_ExtractImageFileFromUrl (droppedURL) into shortImageFile
    put fedwikipedia_GetPageSlug ($_POST_RAW) into pageTitle
    put mediawiki_ListPageImages (pageTitle) into pageImages
    put pageTitle && "Images" into imagePageTitle
    
    put imagePageTitle into pageArray ["title"] 
    put fedwiki_ConstructStoryItemArray (pageImages, "markdown") into itemArray
    fedwiki_PageArrayAddToEnd itemArray, pageArray
    put json_FromArray (pageArray) into pageJSON
    
    fedwiki_ReturnJSON pageJSON
 end listImages

 command startUsingLibraries
    start using stack (gAPPPATH & "stacks/" & lib_Fedwiki.livecode )
    start using stack (gAPPPATH & "stacks/" & lib_MediaWiki.livecode )
    start using stack (gAPPPATH & "stacks/" & lib_FedWikiPedia.livecode )
    start using stack (gAPPPATH & "stacks/" & lib_LiveWorld.livecode )
 end startUsingLibraries
