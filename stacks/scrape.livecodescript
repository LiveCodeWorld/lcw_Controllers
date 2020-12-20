script "scrape.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_PageArray,model_PageArray"
end dep_StackNames

on index
   -- put scrape_ConstructFedwikiPageArray (droppedURL, true, true, true) into pageArray
   
   put fedwiki_GetDroppedArray() into postArray
   put postArray ["date"] into lastUpdatedSeconds
   convert lastUpdatedSeconds to internet date
   --
   put "Scrape Report" into pageTitle
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   --
   put postArray ["index"]["scan"] into scanNum
   put postArray ["index"]["sites"] into siteNum
   put postArray ["index"]["slugs"] into slugNum
   --
   put postArray ["scan"]["pages"] into scanPageNum
   put postArray ["scan"]["sites"] into scanSiteNum
   --
   put merge ("Thanks for update [[scanNum]] on [[lastUpdatedSeconds]]. That makes [[siteNum]] sites indexed to date. I will return something useful here in the future") into someMarkdown
   --
   put pageArray_Construct (pageTitle, someMarkdown) into pageArray
   --
   fedwiki_ReturnPageArray pageArray
end index

on test
   rigLoadHelper "file"
   put rigReadFile("./report.json") into pageJSON
   -- fedwiki_ReturnJSON pageJSON
   --
   if rigWriteFile ("./json/test.json", pageJSON) is FALSE then
      put pageArray_Construct ("Bad", "Unable to write the file") into pageArray
   else
      put rigGetFileNames("./json/") into someMarkDown
      put pageArray_Construct ("Good", someMarkDown) into pageArray
   end if
   --
   fedwiki_ReturnPageArray pageArray
end test
