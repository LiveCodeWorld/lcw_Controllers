﻿script "ha_Controller.lc"
on index
    put transport_DroppedUrl ($_POST_RAW) into someUrl
    
    put rig_StackFolder() into someThing
    -- put rig_FetchStackFiles() into someThing
    put CR & the version after someThing
    
    put transport_ConstructErrorJSON (someThing) into someJSON
    transport_ReturnJSON someJSON
 end index
 
 function rig_StackFolder rigApplicationFolder
    if the environment = "server" then
       -- we don;t need to switch servers so revIgniter can handle this easily
       return gAPPPATH & "stacks/"
    else
       text_AddTrailing rigApplicationFolder, "/"
       put "stacks/" after rigApplicationFolder
       return rigApplicationFolder
    end if
 end rig_StackFolder

 command startUsingLibraries
    start using stack (gAPPPATH & "stacks/lib_Audioboom.livecode")
    start using stack (gAPPPATH & "stacks/lib_CCC.livecode")
    start using stack (gAPPPATH & "stacks/lib_Embedly.livecode")
    start using stack (gAPPPATH & "stacks/lib_Fedwiki.livecode")
    start using stack (gAPPPATH & "stacks/lib_FedWikiPedia.livecode")
    start using stack (gAPPPATH & "stacks/lib_Files.livecode")
    start using stack (gAPPPATH & "stacks/lib_Gist.livecode")
    start using stack (gAPPPATH & "stacks/lib_GitHub.livecode")
    start using stack (gAPPPATH & "stacks/lib_HAP.livecode")
    start using stack (gAPPPATH & "stacks/lib_HTML.livecode")
    start using stack (gAPPPATH & "stacks/lib_MediaWiki.livecode")
    start using stack (gAPPPATH & "stacks/lib_RevIgniter.livecode")
    start using stack (gAPPPATH & "stacks/lib_Scrape.livecode")
    start using stack (gAPPPATH & "stacks/lib_Sitemap.livecode")
    start using stack (gAPPPATH & "stacks/lib_Text.livecode")
    start using stack (gAPPPATH & "stacks/lib_XML.livecode")
    start using stack (gAPPPATH & "stacks/lib_Youtube.livecode")
 end startUsingLibraries
