script "josie.lc"
command index
   # REMEMBER TO PUT ALL THE VARIABLES TO BE MERGED WITH VIEWS INTO THE ARRAY VARIABLE gData
   # SET PAGE TITLE
   put "Josie" into gData["pageTitle"]
   
   put "A wonderful serenity has taken possession of my entire soul, like these<br/> sweet mornings of spring which I enjoy with my whole heart" into gData["meme"]
   
   put RIVERSION && RISTATE into gData["revIgniterVersion"]
   put the version into gData["serverVersion"]
   
   # LOAD THE VIEW FILE
   get rigLoadView("josieHome")
end index
   
   
   
   
   --| END OF welcome.lc
   --| Location: ./system/application/controllers/welcome.lc
