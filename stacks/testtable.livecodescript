script "testtable.lc"
command index
 rigLoaderLoadLibrary "Table"

 put "Test" into gData["title"]

 rigSetTableHeading "Name,Color,Size"

 rigAddTableRow "Fred,Blue,Small"
 rigAddTableRow "Mary,Red,Large"
 rigAddTableRow "John,Green,Medium"

 put rigGenerateTable() into gData["testTable"]		

 get rigLoadView("testtable")	
end index
