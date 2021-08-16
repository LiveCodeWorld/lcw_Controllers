script "hello_write.lc"
getprop dep_StackNames
    return "lib_Fedwiki,lib_PageArray,model_PageArray,model_Transport"
end dep_StackNames

command index
# MAKE SURE THAT THE CONTROLLER IS ONLY ACCESSIBLE VIA COMMAND LINE
if $_SERVER["PATH_TRANSLATED"] <> empty then
   put "This script can only be accessed via the command line."
   exit to top
end if

put the time into timeModel ["time"]
transport_SetModel "Clock Model", timeModel

put "Hello" && timeModel ["time"] & CR
end index
