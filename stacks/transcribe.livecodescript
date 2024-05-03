script "transcribe.lc"
getprop dep_StackNames
   return ""
end dep_StackNames

on index
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put transcribe_ConstructWavFile (pageSlug) into wavFile
   
   # Transcode audio
   if there is a file wavFile then
      -- put whisper_GetTranscript (wavFile) into sTranscript
      whisper_CreateTranscript wavFile
      put the result into sTranscript
      
      put pageArray_Construct ("Transcript", sTranscript, "markdown") into pageArray 
   else
      put pageArray_Construct ("Error", "Converted wav file does not exist!", "markdown") into pageArray 
   end if
   --
   transport_ReturnPageArray pageArray
end index

on ghost_AudioFolderPage
   transport_SetInfo wikiDomain, audioPageSlug, audioPageTitle
   put the result into valueArray
   put valueArray ["folderPageTitle"] into folderPageTitle
   
   # Construct pageArray
   put wikiPage_AudioFolder (folderPageTitle, wikiDomain) into pageArray
   transport_ReturnPageArray pageArray
end ghost_AudioFolderPage

on record_Audio
   transport_SetInfo wikiDomain, audioPageSlug, audioPageTitle
   put the result into valueArray
   put valueArray ["folderPageTitle"] into folderPageTitle
   
   put wikiFile_Construct (wikiDomain, folderPageTitle) into wikiFile
   if there is a file wikiFile then
      put _RecordingProgressPageArray (audioPageTitle, valueArray) into pageArray
   else
      put fedwiki_ConstructSlug (folderPageTitle) into folderPageSlug
      put _RecordingFolderPageArray (valueArray, wikiDomain, folderPageSlug, folderPageTitle) into pageArray
   end if
   
   # Start Recording Audio
   audio_RecordTranscriptWav audioPageTitle, folderPageTitle, wikiDomain
   
   transport_ReturnPageArray pageArray
end record_Audio

on stop_Recording
   transport_SetInfo wikiDomain, audioPageSlug, audioPageTitle
   put the result into valueArray
   --
   audio_StopRecordingAndCreate valueArray
   put the result into stoppedPageArray
   transport_ReturnPageArray stoppedPageArray
end stop_Recording

on tidy_Transcript  
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put transcribe_GetWavText (pageSlug, wikiDomain) into sTranscript   
   put wikiPage_CombinedTranscript (sTranscript, pageTitle, pageSlug, wikiDomian, pageTitle) into pageArray
   -- put _TidyPageArray (sTranscript) into pageArray
   --
   transport_ReturnPageArray pageArray
end tidy_Transcript

on create_Transcript
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put wikiFile_Construct (wikiDomain, pageSlug) into wikiFile
   if there is a file wikiFile then
      put "Page [[" & pageTitle & "]] already exists!" into someMarkdown
      put pageArray_Construct ("Eror", someMarkdown, "markdown") into pageArray
   else
      put transcribe_GetWavText (pageSlug, wikiDomain) into sTranscript
      put pageTitle into tShortTitles
      put wikiPage_CombinedTranscript (sTranscript, pageTitle, pageSlug, wikiDomian, tShortTitles) into pageArray
   end if
   
   transport_ReturnPageArray pageArray
end create_Transcript

on summarize
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put the result into valueArray
   --
   lcw_Notify "Transcribing the audio."
   put transcribe_GetWavText (pageSlug, wikiDomain) into sTranscript
   
   lcw_Notify "Using the 'graph-and-summary' prompt to replace the summary section. This may take some time."
   put openAI_GetText (sTranscript, "graph-and-summary", "gpt-4") into mdText
   --
   put pageArray_Get (wikiDomain, pageSlug) into pageArray
   wikiPage_ReplaceTranscriptSummary pageArray, mdText
   --
   curly_ReplacePageArray pageArray, "folderPageTitle", pageTitle
   --
   transport_ReturnPageArray pageArray  
end summarize

on convert_ToWav
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   --
   put transcribe_FindOggFile (pageSlug) into oggFile
   
   # Transcode audio
   transcribe_CreateWav oggFile, pageSlug, wikiDomain
   put the result into wavFile
   
   put pageArray_Construct ("Converted Audio", shellResult, "markdown") into pageArray
   --
   transport_ReturnPageArray pageArray
end convert_ToWav

on join_Missing
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put the result into valueArray
   put valueArray ["tShortFolders"] into tShortFolders
   put _CombinedTranscript (tShortFolders, wikiDomain) into sTranscript
   
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
   put _CombinedTranscript (tShortFolders, wikiDomain) into sTranscript
   --
   put wikiPage_CombinedTranscript (sTranscript, pageTitle, pageSlug, wikiDomian, tShortFolders) into pageArray
   -- 
   transport_ReturnPageArray pageArray  
end summarize_Combined

on create_Missing
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put the result into valueArray
   put valueArray ["rawAudioFile"] into oggFile 
   
   # Check if page already exists!
   put wikiFile_Construct (wikiDomain, pageSlug) into pageJsonFile
   put pageArray_Get (wikiDomain, pageSlug) into pageArray
   
   # Create new pageArray
   if pageArray is an array then
      # Add Edit Tools
      _AddEditTools pageArray, valueArray
   else -- Create new pageArray
      # Notify
      lcw_Notify ("Creating ghost page for" && kwote (pageTitle))
      
      # Create wav
      put transcribe_ConstructWavFile (pageSlug, wikiDomain) into wavFile
      transcribe_CreateWav oggFile, pageSlug, wikiDomain
      put the result into wavFile
      
      # Transcode audio
      if there is a file wavFile then         
         # Transcribe wav file
         put transcribe_TextFile (pageSlug, wikiDomain) into transcriptFile
         if there is not a file transcriptFile then
            lcw_Notify "Transcribing file using Whisper..."
            
            set the cursor to watch
            whisper_CreateTranscript wavFile
            get the result
         end if
         
         put transcribe_ConstructGraphAndSummaryFile (pageSlug, wikiDomain) into chatGptFile
         if there is a file chatGptFile then
            put wikiPage_GetGraphAndSummary (pageSlug, wikiDomain) into pageArray
         else
            lcw_Notify "Creating ghost-page using 'Graph and Summary' prompt for ChatGPT. This can take some time..."
            
            transcribe_CreateGraphAndSummary pageSlug, wikiDomain
            put the result into graphAndSummaryText
            put wikiPage_GetGraphAndSummary (pageSlug, wikiDomain, graphAndSummaryText) into pageArray
         end if
         
         # Add Edit Tools
         _AddEditTools pageArray, valueArray
      else
         put pageArray_Construct ("Error", "Converted wav file does not exist!", "markdown") into pageArray 
      end if
   end if
   --
   put valueArray ["folderPageTitle"] into folderPageTitle 
   curly_ReplacePageArray pageArray, "folderPageTitle", folderPageTitle
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
   put pageArray_Get (wikiDomain, pageSlug) into pageArray
   pageArray_StripJournal pageArray
   pageArray_AddChatGptCred pageArray
   --
   transport_ReturnPageArray pageArray
end add_ChatGptCred

on display_Transcript
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put the result into valueArray
   --
   put transcribe_GetWavText (pageSlug, wikiDomain) into sTranscript
   put pageTitle && "Transcript" into dTitle
   put pageArray_Construct (dTitle, sTranscript) into pageArray
   --
   transport_ReturnPageArray pageArray
end display_Transcript

on add_TidiedTranscript
   transport_SetInfo wikiDomain, pageSlug, pageTitle
   put the result into valueArray
   --
   put transcribe_GetWavText (pageSlug, wikiDomain) into sTranscript
   if sTranscript is empty then
      put pageArray_Construct ("Error", "Transcript is empty?", "markdown") into pageArray 
   else
      put wikiPage_AddTidiedTranscript (pageSlug, wikiDomain) into pageArray
   end if
   --
   pageArray_StripJournal pageArray
   pageArray_AddChatGptCred pageArray
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
   put openAI_GetText (sTranscript, "tidy-hitchhikers", "gpt-4") into mdText
   
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

private function _CombinedTranscript tShortFolders, wikiDomain
   sort numeric items of tShortFolders by word -1 of each
   repeat for each item tShortFolder in tShortFolders
      put fedwiki_ConstructSlug (tShortFolder) into pageSlug
      put transcribe_GetWavText (pageSlug, wikiDomain) & CR after sTranscript
   end repeat
   delete char -1 of sTranscript
   return sTranscript
end _CombinedTranscript
