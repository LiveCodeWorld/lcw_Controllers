script "twitter.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
   return "lib_Fedwiki,lib_Twitter"
end dep_StackNames

on index
   put transport_DroppedUrl ($_POST_RAW) into droppedURL
   put twitter_FetchPageJson (droppedURL) into pageJSON
   transport_ReturnJSON pageJSON
end index
