script "hello.lc"
getprop dep_StackNames
    return "lib_Fedwiki,lib_PageArray,model_PageArray,model_Transport"
end dep_StackNames

command index
   put "Clock Model" into modelName
   --
   put the time into clockData ["time"]
   transport_SetModel modelName, clockData
   
   put federation_FetchModel (modelName) into modelData
   put modelData ["time"] into sText
   put pageArray_Construct ("Last Time", sText) into pageArray
   --
   fedwiki_ReturnPageArray pageArray
end index

on writeTime
   /*
   # MAKE SURE THAT THE CONTROLLER IS ONLY ACCESSIBLE VIA COMMAND LINE
   if $_SERVER["PATH_TRANSLATED"] <> empty then
      put "This script can only be accessed via the command line."
      exit to top
   end if
   */
   
   put "Clock Model" into modelName
   put the time into timeModel ["time"]
   transport_SetModel modelName, timeModel
   
   put "Hello" && timeModel ["time"] & CR
end writeTime
