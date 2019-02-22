script "filtered.lc"
command filtered_activity
   start using stack (gAPPPATH & "stacks/lib_Fedwiki.livecode")
   start using stack (gAPPPATH & "stacks/lib_FedwikiRoster.livecodescript")
   start using stack (gAPPPATH & "stacks/lib_FedwikiCreate.livecodescript")
end filtered_activity


/* ==  CODE  ==
--
Here we put the public handlers the controller uses and exposes as urls.
--
*/

on index
   put fedwiki_FetchFilteredFederationActivity ("server.fedwiki.org", "atopia-domain-index", "741a0fcdd3ff76b2") into pageArray
   fedwiki_ReturnPageArray pageArray
end index
