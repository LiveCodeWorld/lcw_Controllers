script "transcribe.lc"
getprop dep_StackNames
   return "lcw_Media"
end dep_StackNames


--> Transporter
-
on index
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put magic_CreateTranscript (pageSlug) into pageArray
   --
   transport_ReturnPageArray pageArray
end index

on process_Page
   local pPort
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put pageArray_FetchText (wikiDomain, pageSlug, pPort) into pageArray
   --
   transport_ReturnPageArray pageArray
end process_Page

on ghost_AudioFolderPage
   transport_SetInfo wikiDomain, audioPageSlug, audioPageTitle
   put the result into valueArray
   put valueArray ["folderPageTitle"] into folderPageTitle
   
   # Construct pageArray
   put wikiPage_AudioFolder (folderPageTitle, wikiDomain) into pageArray
   --
   transport_ReturnPageArray pageArray
end ghost_AudioFolderPage

on record_Audio
   transport_SetInfo wikiDomain, audioPageSlug, audioPageTitle
   put the result into valueArray
   put valueArray ["folderPageTitle"] into folderPageTitle
   --
   record_Start wikiDomain, folderPageTitle, valueArray
   put the result into pageArray
   --
   transport_ReturnPageArray pageArray
end record_Audio

on stop_Recording
   transport_SetInfo wikiDomain, audioPageSlug, audioPageTitle
   put the result into valueArray
   --
   audio_StopRecordingAndCreate valueArray
   put the result into pageArray
   
   transport_ReturnPageArray pageArray
end stop_Recording

on tidy_Transcript
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put magic_TidyTranscript (pageSlug, wikiDomain, pageTitle) into pageArray
   --
   transport_ReturnPageArray pageArray
end tidy_Transcript

on create_Transcript
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put magic_Tidy (wikiDomain, pageSlug, pageTitle)
   --
   transport_ReturnPageArray pageArray
end create_Transcript

on summarize
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put the result into valueArray
   --
   lcw_Notify "Transcribing the audio."
   lcw_Notify "Using the 'graph-and-summary' prompt to replace the summary section. This may take some time."
   --
   put magic_Summarize (pageSlug, wikiDomain) into pageArray
   --
   transport_ReturnPageArray pageArray  
end summarize

on convert_ToWav
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put magic_ConvertToWav
   --
   transport_ReturnPageArray pageArray
end convert_ToWav

on join_Missing
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put the result into valueArray
   put valueArray ["tShortFolders"] into tShortFolders
   put transcript_Combine (tShortFolders, wikiDomain) into sTranscript
   
   # Conscrutct Big Transcript
   put pageArray_Construct ("Big Transcript", "This is the combined raw transcript. Use this button to summarise and tidy:", "markdown") into pageArray
   put "http://rest.livecode.world/transcribe/summarize_Combined" into postURL
   pageArray_AddButton pageArray, "Summarize Combined", postURL, valueArray, "", "right"
   pageArray_AddMarkdown pageArray, sTranscript
   --
   transport_ReturnPageArray pageArray
end join_Missing

on summarize_Combined
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put the result into valueArray
   put valueArray ["tShortFolders"] into tShortFolders
   --
   put magic_SummarizeCombined (pageTitle, pageSlug, wikiDomian, tShortFolders) into pageArray
   -- 
   transport_ReturnPageArray pageArray  
end summarize_Combined

on create_Missing
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put the result into valueArray
   put valueArray ["rawAudioFile"] into oggFile 
   --
   put magic_CreateMissingPageArray (wikiDomain, pageSlug, pageTitle, valueArray) into pageArray
   --
   transport_ReturnPageArray pageArray
   wikiServer_Restart
end create_Missing

on create_IfMissing
   transport_SetInfo wikiDomain, folderPageSlug, folderPageTitle
   put the result into valueArray
   --
   put wikiPage_MissingPages (folderPageSlug, wikiDomain, folderPageTitle) into pageArray
   --
   transport_ReturnPageArray pageArray
   wikiServer_Restart
end create_IfMissing

on add_ChatGptCred
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put magic_AddCred (wikiDomain, pageSlug) into pageArray
   --
   transport_ReturnPageArray pageArray
end add_ChatGptCred

on display_Transcript
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put transcript_ConstructPageArray (pageSlug, wikiDomain, pageTitle) into pageArray
   --
   transport_ReturnPageArray pageArray
end display_Transcript

on add_TidiedTranscript
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put the result into valueArray
   --
   put magic_TidyTranscript (pageSlug, wikiDomain) into pageArray
   --
   transport_ReturnPageArray pageArray
   wikiServer_Restart
end add_TidiedTranscript


--> Private
-
private command _AddEditTools @pageArray, valueArray
   pageArray_AddMarkdown pageArray, "# Tools"
   pageArray_AddMarkdown pageArray, "The tools below will use generative AI to edit the contents of the page displayed above."
   
   put "http://rest.livecode.world/transcribe/summarize" into postURL -- create_IfMissing
   pageArray_AddButton pageArray, "Edit Summary", postURL, valueArray
   
   pageArray_AddMarkdown pageArray, "Tidy the raw transcript with generative AI:"
   pageArray_AddButton pageArray, "Tidy Transcript", "http://rest.livecode.world/transcribe/add_TidiedTranscript", valueArray
end _AddEditTools

private function _TidyPageArray sTranscript
   # Tidy using ChatGPT
   put prompt_Process (sTranscript, "tidy-hitchhikers", "gpt-4") into mdText
   
   # Create PageArray
   if mdText is empty then
      put "# Raw Transcript" & CR before mdText
      put pageArray_Construct ("Error, displaying raw transcript", sTranscript, "markdown") into pageArray 
   else
      put "# Tidied Transcript" & CR before mdText
      put pageArray_Construct ("Tidied Transcript", mdText, "markdown") into pageArray 
   end if
   return pageArray
end _TidyPageArray

private function _RecordingProgressPageArray pageTitle, valueArray
   # Create Page Dialogue
   put "Audio is currently being recorded to the [[page asset folder]] [[" & pageTitle & "]]." into sMarkDown
   put "Recording" && pageTitle into rTitle
   put pageArray_Construct (rTitle, sMarkDown, "markdown") into pageArray 
   
   # Add Stop Recording Button
   _AddStopRecordingButton pageArray
   
   return pageArray
end _RecordingProgressPageArray

private command _AddStopRecordingButton @pageArray
   pageArray_AddMarkdown pageArray, "Click on this button to stop recording, and transcribe the audio."
   pageArray_AddButton pageArray, "Stop Recording", "http://rest.livecode.world/transcribe/stop_Recording", valueArray
end _AddStopRecordingButton

private function _RecordingFolderPageArray valueArray, wikiDomain, audioPageSlug, audioPageTitle
   # Create Recording Folder Page
   put valueArray ["folderPageTitle"] into folderPageTitle
   put wikiPage_AudioFolder (folderPageTitle, wikiDomain, audioPageSlug, audioPageTitle) into pageArray
   
   # Add Stop Recording Button
   _AddStopRecordingButton pageArray
   
   return pageArray
end _RecordingFolderPageArray
