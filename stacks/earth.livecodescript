﻿script "earth.lc" with behavior "behavior_RigLocalOveride"
getprop dep_StackNames
    return "lib_Fedray,lib_Fedwiki,lib_FedwikiRoster,lib_FedwikiSitemap,lib_PageArray,model_Atopia,model_Fedwiki,model_PageArray"
end dep_StackNames

on index
   roster_ReturnAtopiaPageArray "platform.earth"
end index
