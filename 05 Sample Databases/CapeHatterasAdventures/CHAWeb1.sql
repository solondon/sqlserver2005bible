EXECUTE sp_makewebtask 
	@outputfile = N'C:\CHA1.htm', 
	@query=N'SELECT [BaseCampName] FROM [BaseCamp]', 
	@fixedfont=0, 
	@HTMLheader=3, 
	@webpagetitle=N'Cape Hatteras Adventures', 
	@resultstitle=N'Base Camps', @dbname=N'CHA2', 
	@whentype=1, 
	@nrowsperpage=15,
	@procname=N'CHA2 Web Page',
	@codepage=65001,
	@charset=N'utf-8'