script "git.lc"
getprop dep_StackNames
   return ""
end dep_StackNames

on index
   -- put _GitFolder() into gitFolder
   put the git_RelativeFolder of stack "lcw_Controllers" into relGitFolder
   --
   put _StatusPageArray (relGitFolder) into pageArray
   --
   transport_ReturnPageArray pageArray
end index

on view_Untracked
   _DroppedFolders relGitFolder, gitFolder
   --
   --
   put wikiPage_CurlyDialogue (curlyData, "git-untracked-dialogue", "Git Untracked", "dialogue.livecode.world") into pageArray
   --
   transport_ReturnPageArray pageArray
end view_Untracked

on add_Untracked
   _DroppedFolders relGitFolder, gitFolder
   --
   git_AddEverything gitFolder  
   put the result into shellResult
   --
   put _StatusPageArray (relGitFolder) into pageArray
   --
   transport_ReturnPageArray pageArray
end add_Untracked

private function _GitFolder
   _DroppedFolders relGitFolder, gitFolder
   return gitFolder
end _GitFolder

private command _DroppedFolders @relGitFolder, @gitFolder
   put transport_DroppedValue ("relGitFolder") into relGitFolder
   put _GitFolderFromRelative (relGitFolder) into gitFolder
   return gitFolder
end _DroppedFolders

private function _GitFolderFromRelative relGitFolder
   put env_GetRepoFolder() into repoFolder
   put repoFolder & relGitFolder into gitFolder
   return gitFolder
end _GitFolderFromRelative

function _ConstructCurlyData relGitFolder, statusArray
   put relGitFolder into curlyData ["all"]["relGitFolder"]
   put statusArray ["Branch"] into branchText
   --
   put _SortedFiles (statusArray, "Untracked files:", "files") into unTrackedFiles
   put unTrackedFiles into curlyData ["all"]["unTrackedFiles"]
   put the number of lines of unTrackedFiles into curlyData ["all"]["unTrackNum"]
   --
   get _NumberOfLines (statusArray, "Changes not staged for commit:", "modified")
   put it into curlyData ["all"]["notStagedNum"]
   --
   get _NumberOfLines (statusArray, "Changes to be committed:", "modified")
   put it into curlyData ["all"]["modifiedNum"]
   --
   get _NumberOfLines (statusArray, "Changes to be committed:", "new file")
   put it into curlyData ["all"]["newFileNum"]
   --
   put the number of lines of untrackedFiles into unTrackNum
   put unTrackNum into curlyData ["all"]["numberOfFiles"]
   --
   return curlyData
end _ConstructCurlyData

private function _NumberOfLines statusArray, firstKey, secondKey
   put _SortedFiles (statusArray, firstKey, secondKey) into sFiles
   return the number of lines of sFiles
end _NumberOfLines

private function _SortedFiles statusArray, firstKey, secondKey
   get statusArray [firstKey][secondKey]
   put keys (it) into sFiles
   sort sFiles
   return sFiles
end _SortedFiles

private function _StatusPageArray relGitFolder
   put _GitFolderFromRelative (relGitFolder) into gitFolder
   put git_FetchStatusArray (gitFolder) into statusArray
   --
   put _ConstructCurlyData (relGitFolder, statusArray) into curlyData
   --
   put wikiPage_CurlyDialogue (curlyData, "git-status-dialogue", "Git Status", "dialogue.livecode.world") into pageArray
   return pageArray
end _StatusPageArray
