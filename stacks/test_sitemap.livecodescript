script "test_sitemap.lc"
getprop dep_StackNames
    return "lib_Audioboom.livecode,lib_CCC,lib_Embedly,lib_Fedwiki,lib_FedWikiPedia,lib_Files.livecode,lib_Gist,lib_GitHub,lib_HAP.livecode,lib_HTML,lib_MediaWiki,lib_RevIgniter,lib_Scrape,lib_Sitemap.livecode,lib_Text.livecode,lib_XML,lib_Youtube"
end dep_StackNames

on index
   hap_ListMediaTypes
end index
      
on hap_ListImageFileIDs
   put sitemap_ListFileIDs ("Image") into fileIDs
   put fileIDs
end hap_ListImageFileIDs
