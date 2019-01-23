script "welcome.lc"
getprop dep_StackNames
    return ",,,rigOutputCache"
end dep_StackNames

command index
	# REMEMBER TO PUT ALL THE VARIABLES TO BE MERGED WITH VIEWS INTO THE ARRAY VARIABLE gData
	# SET PAGE TITLE
	put "Welcome to revIgniter" into gData["pageTitle"]
	
	put RIVERSION && RISTATE into gData["revIgniterVersion"]
	put the version into gData["serverVersion"]
	
	# LOAD THE VIEW FILE
	get rigLoadView("welcomeMessage")
end index




--| END OF welcome.lc
--| Location: ./system/application/controllers/welcome.lc
----------------------------------------------------------------------
