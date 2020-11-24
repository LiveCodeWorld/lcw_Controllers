script "commons.lc"
getprop dep_StackNames
   return roster_DepStackNames()
end dep_StackNames

on index
   roster_ReturnPageArray "commons.world", true
end index
