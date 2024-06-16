script "augmented.lc"
getprop dep_StackNames
   return ""
end dep_StackNames

on index
   extract_Keywords
end index

on create_Image
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put the result into valueArray
   put valueArray ["imagePrompt"] into imagePrompt
   --
   prompt_CreateImage imagePrompt, pageSlug, wikiDomain
   put the result into pageArray
   --
   transport_ReturnPageArray pageArray  
end create_Image

command prompt_CreateImage imagePrompt, pageSlug, wikiDomain
   # Generate image
   put openAI_GenerateImageArray (imagePrompt) into imageArray
   --
   openAI_DeconstructImageArray imageArray, sImage, revisedPrompt
   put md5_Hash (sImage) & ".jpg" into shortFile
   
   # Construct imageFile
   put wikiFolder_ConstructPageAssets (pageSlug, wikiDomain) into pageFolder
   put pageFolder & shortFile into imageFile
   
   put pageSlug & slash & shortFile into relAssetPath
   put wikiUrl_Asset (relAssetPath, wikiDomain) into imageURL
   
   # Construct Image Ghost Page
   put pageArray_Construct ("Image Ghost Page", "Drag items off this [[ghost page]].") into pageArray
   pageArray_AddMarkdown pageArray, "# Assets"
   pageArray_AddAssets pageArray, pageSlug
   pageArray_AddMarkdown pageArray, "# Image"
   pageArray_AddMarkdown pageArray, revisedPrompt
   --
   pageArray_AddImage pageArray, imageURL, revisedPrompt
   
   # Save image
   folder_CreateNested pageFolder
   put sImage into url ("binfile:/" & imageFile)
   --
   return pageArray
end prompt_CreateImage

-- command wiki_CreateImage sImage, fExt
put md5_Hash (sImage) & "." & fExt into shortImageFile
put wikiFile_ConstructImageAsset (shortImageFile, wikiDomain) into imageFile
-- hardlink_Create imageFile, commonsFile

put itemArray ["id"] into sID
--
put itemArray_Construct ("image", sID, imageCaption) into imageArray
put imageURL into imageArray ["url"]
put "wide" into imageArray ["size"]
put imageLink into imageArray ["source"]
/*
put sWidth into imageArray ["width"]
put sHeight into imageArray ["height"]
*/

put pageArray_Construct ("Converted Image", "here is an image...") into pageArray
itemArray_Add imageArray, pageArray
end wiki_CreateImage

on extract_ConceptGraph
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   if pageTitle is empty then
      put fedwiki_ConstructTitle (pageSlug) into pageTitle
   end if
   --
   put openAI_GetChatResponse ("extract-concept-graph", wikiDomain, pageSlug, "gpt-4") into dotText
   put "  layout=fdp" & CR before line 2 of dotText
   --
   put pageTitle && "Concept Graph" into kTitle
   put pageArray_Construct (kTitle, dotText) into pageArray
   --
   pageArray_AddGraphviz pageArray, dotText, dotText
   --
   transport_ReturnPageArray pageArray  
end extract_ConceptGraph

on list_Concepts
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   if pageTitle is empty then put fedwiki_ConstructTitle (pageSlug) into pageTitle
   --
   put openAI_GetChatResponse ("five-concepts", wikiDomain, pageSlug, "gpt-4") into someMD
   --
   put "Five Concepts of" && pageTitle into kTitle
   put pageArray_Construct (kTitle, someMD) into pageArray
   --
   transport_ReturnPageArray pageArray  
end list_Concepts

on summary_Graph
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   if pageTitle is empty then put fedwiki_ConstructTitle (pageSlug) into pageTitle
   --
   put openAI_GetChatResponse ("graph-and-summary", wikiDomain, pageSlug, "gpt-4") into someMD
   --
   put pageTitle && "Concept Graph" into kTitle
   put pageArray_Construct (kTitle, someMD, "markdown") into pageArray
   --
   put graph_Extract (someMD) into dotText
   pageArray_AddGraphviz pageArray, dotText, dotText
   --
   transport_ReturnPageArray pageArray  
end summary_Graph

on add_Audio
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put the result into hiddenArray
   
   put hiddenArray ["sLang"] into sLang
   get hiddenArray ["translatedTitle"]
   put urldecode (it) into translatedTitle
   put hiddenArray ["voice"] into whisperVoice
   put hiddenArray ["useHD"] into useHD
   
   get hiddenArray ["eTranslation"]
   put urldecode (it) into sTranslation
   
   _CreateAndGhost whisperVoice, pageSlug, sLang, wikiDomain, translatedTitle, sTranslation, pageTitle, useHD
end add_Audio

on add_PageAudio
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put the result into hiddenArray
   
   put hiddenArray ["sLang"] into sLang
   put hiddenArray ["voice"] into whisperVoice
   put hiddenArray ["useHD"] into useHD
   
   get hiddenArray ["translatedTitle"]
   put urldecode (it) into translatedTitle
   replace "?" with empty in translatedTitle
   put fedwiki_ConstructSlug (translatedTitle) into translatedSlug
   put pageArray_Get (wikiDomain, translatedSlug) into pageArray
   
   put pageArray ["story"][3] into tItemArray
   put tItemArray ["text"] into sTranslation
   
   if sTranslation is empty then
      put pageArray_Construct ("Error", "Translated text seems empty?", "markdown") into pageArray
      transport_ReturnPageArray pageArray
   else
      put pageArray ["title"] into translatedTitle
      _CreateAndGhost whisperVoice, pageSlug, sLang, wikiDomain, translatedTitle, sTranslation, translatedTitle, useHD
   end if
end add_PageAudio

private command _CreateAndGhost whisperVoice, pageSlug, sLang, wikiDomain, translatedTitle, sTranslation, pageTitle, useHD
   if pageTitle is empty then put fedwiki_ConstructTitle (pageSlug) into pageTitle
   --
   put pageSlug & "-" & sLang & ".mp3" into relAssetPath
   put wikiFile_ConstructAsset (relAssetPath, wikiDomain) into audioFile
   put wikiUrl_Asset (relAssetPath, wikiDomain) into audioUrl
   --
   put pageArray_Construct (translatedTitle, sTranslation, "markdown") into pageArray
   
   # Add Audio Player
   put "#" && sLang && "Translation" into sTitle
   pageArray_AddMarkdown pageArray, sTitle
   put "[[" & pageTitle & "]]" && "translated into" && sLang into aText
   pageArray_AddAudio pageArray, audioUrl, aText
   --
   openAI_TextToSpeech sTranslation, audioFile, whisperVoice, useHD
   --
   pageArray_StripJournal pageArray
   pageArray_AddChatGptCred pageArray
   transport_ReturnPageArray pageArray
end _CreateAndGhost

on translate_Welsh
   -- a test
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put openAI_GetChatResponse ("welsh-prompt", wikiDomain, pageSlug) into welshTranslation
   put pageTitle && "Welsh Translation" into sTitle
   put pageArray_Construct (sTitle, welshTranslation, "markdown") into pageArray
   --
   transport_ReturnPageArray pageArray
end translate_Welsh

on extract_Keywords
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put openAI_GetChatResponse ("extract-keywords", wikiDomain, pageSlug) into kWords
   put pageTitle && "Keywords" into kTitle
   put pageArray_Construct (kTitle, kWords, "markdown") into pageArray
   --
   transport_ReturnPageArray pageArray
end extract_Keywords

on translate
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put the result into postArray
   put postArray ["language"] into sLang
   --
   put wikiPage_Translation (wikiDomain, pageSlug, sLang) into pageArray
   transport_ReturnPageArray pageArray
end translate
