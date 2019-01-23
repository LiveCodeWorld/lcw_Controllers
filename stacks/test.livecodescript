script "test.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
    return "lib_Fedwiki"
end dep_StackNames

on index  
   -- put test_Server() into testArray
   -- fedwiki_ReturnPageArray testArray
   put dig_GetIP ("cyberciti.biz")
end index

function dig_GetIP someDomain
   put merge ("dig [[someDomain]] +short") into someShell
   put shell (someShell) into someIP
   return word 1 to -1 of someIP
end dig_GetIP

function dig_GetDomain someIP
   /*
   dig +noall +answer +short cyberciti.biz
   */
   url_MakeTLD someDomain
   put "dig -x" && someIP into someShell
   put shell (someShell) into someDomain
   return word 1 to -1 of someDomain
end dig_GetDomain

function test_Server
   -- https://serverfault.com/questions/125865/finding-out-what-user-apache-is-running-as
   put shell ("ps aux | egrep '(apache|httpd)'") into testArray ["apacheUserStuff"]
   -- put $USER into testArray ["$USER"] -- no access to environmental variables with server
   put shell ("whoami") into testArray ["whoami"]
   
   put $_SERVER ["DOCUMENT_ROOT"] into documentRoot
   put documentRoot & slash into webRootFolder
   put webRootFolder into testArray ["webRootFolder"]
   
   put webRootFolder into feastFolder
   set the itemdelimiter to slash
   put "feast.fm" into item -1 of feastFolder
   put feastFolder into testArray ["feastFolder"]
   set the defaultfolder to feastFolder
   put the files into testArray ["feast files"]
   put shell ("git status") into testArray ["git status"]
   
   /*
   createAssetFolders webRootFolder
   
   test_CreateFile webRootFolder
   put the result into helloString
   put helloString into testArray ["helloString"]
   */
   
   put webRootFolder & "index.html" into fullFilePath
   put url ("file:" & fullFilePath) into someHTML
   put someHTML into testArray ["someHTML"]
   
   set the defaultfolder to webRootFolder
   put the files into documentRootFiles
   put documentRootFiles into testArray ["documentRootFiles"]
   
   put "/var/www/html/note/" into noteFolder
   set the defaultfolder to noteFolder
   put the files into noteFolderFiles
   put noteFolderFiles into testArray ["noteFolderFiles"]
   
   -- put rigGetDirFileInfo(noteFolder) into testArray ["note folder info"]
   
   put the globalNames into testArray ["globalNames"]
   put gApplicationFolder into testArray ["gApplicationFolder"]
   put gSystemFolder into testArray ["gSystemFolder"]
   
   put gController into testArray ["gController"]
   put gAPPPATH into testArray ["gAPPPATH"]
   put gSELF into testArray ["gSELF"]
   put gBASEPATH into testArray ["gBASEPATH"]
   put gFCPATH into testArray ["gFCPATH"]
   
   put $_SERVER into testArray ["$_SERVER"]
   put $_GET into testArray ["$_GET"]
   put gSELF into testArray ["gSELF"]
   return testArray
end test_Server
