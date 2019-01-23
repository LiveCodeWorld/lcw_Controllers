script "system.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki"
end dep_StackNames

on index
   put fedwiki_ConstructErrorJSON ($_POST_RAW) into someJSON
   fedwiki_ReturnJSON someJSON
end index

on sitemap
   put fedwiki_ConstructSitemapArray ("Roster") into sitemapArray
   put json_FromArray (sitemapArray) into sitemapJSON
   fedwiki_ReturnJSON sitemapJSON
end sitemap

function fedwiki_ConstructSitemapArray pageTitle
   local sitemapArray, pSlug, pDate, pSynopsis
   fedwiki_AddEntryToSitemapArray sitemapArray, pageTitle, pSlug, pDate, pSynopsis
   return sitemapArray
end fedwiki_ConstructSitemapArray

command fedwiki_AddEntryToSitemapArray @sitemapArray, pageTitle, pSlug, pDate, pSynopsis
   put item 2 of the extents of sitemapArray into indexNum
   add 1 to indexNum
   --
   if pSlug is empty then put fedwiki_ConstructSlug (pageTitle) into pSlug
   if pDate is empty then put the ticks into pDate
   if pSynopsis is empty then put "A synopsis" into pSynopsis
   --
   put pageTitle into sitemapArray [indexNum]["title"]
   put pSlug into sitemapArray [indexNum]["slug"]
   put pDate into sitemapArray [indexNum]["date"]
   put pSynopsis into sitemapArray [indexNum]["synopsis"]
end fedwiki_AddEntryToSitemapArray
