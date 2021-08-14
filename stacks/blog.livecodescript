script "blog.lc"
command index
rigLoadHelper "asset"

put "pics" into tArray["class"]
put "My Portrait" into tArray["alt"]
put rigImageAsset("david.jpg", tArray) into gData["myPic"]

	get rigLoadView("blogview")
end index
