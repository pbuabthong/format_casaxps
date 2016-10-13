#pragma rtGlobals=1		// Use modern global access method.


// Fuction to read the raw data from Excel Sheets and concatenate all 
// columns in the same worksheet into a 2D wave (matrix)
// It reads the wave names from the first row and uses them as dimension labels

Function ExcelTo2DWave()

// select the excel file
do
	getfilefolderinfo/Q
	if (V_Flag<0)
		return -1 				//User cacelled
	elseif (V_isFolder==1) 		//User selectes folder instead of file
		DoAlert/T="Message" 0, "Please choose a file not a folder"
	elseif (V_Flag==0 && V_isFile==1) 			// make sure a file is selected
		if (stringmatch(S_Path, "*.xls*"))		// make sure it is an Excel file
		String filePath = S_Path				// full file path
		else
		V_isFile = 0
		DoAlert/T="Message" 0, "The selected file is not an Excel file. Please select an Excel file."
		endif
	endif
while (V_isFile !=1)


XLLoadWave/Q/J=1 filePath			//use XLLoadWave/J=1 to get info (the worksheets) in the Excel file
String wkShList = S_value				// a : sepearted list of sheets in the Excel file

// each excel file loads its worksheets in a seperate data folder
// this is useful when loading multiple excel files that may contain repeated worksheet names
// comment out the lines with dataFolder if not needed
String savedDataFolder = GetDataFolder(1)		
String fileName = ParseFilePath(0,filePath,":",1,0) 		// get file name from full file path
String extension = "." + ParseFilePath(4, fileName, ":", 0, 0)		// e.g., ".xls"
String dfName = RemoveEnding(fileName, extension)
//NewDataFolder/O/S :$dfName

// loop for each worksheet in the excel file to load all columns in to a 2D wave
Variable i, numWkSh
i=0
numWkSh = ItemsInList(wkShList)     // the number of worksheets
String wkShLoad
do 		
wkShLoad =StringFromList(i,wkShList) 		//pick a worksheet to load wave from
LoadTo2Dwave(filePath, wkShLoad)			//pass the full file path and worksheet name to load waves
i += 1
while (i<numWkSh)
//SetDataFolder savedDataFolder
End

// the function loads the columns in to 1D wave and then
//uses concatenate to merge them into a 2D wave

Function LoadTo2DWave(fName, wkShLoad)
String fName, wkShLoad

//Loads each column in "wkShLoad" to a 1D Wave
// dtermine wave type from row 10 - change as appropriate
// takes row 1 as wave names - change as appropriate
XLLoadWave/Q/S=wkShLoad/C=10/W=1/O fName 	

//create a list of wave to concatenate exclude 2D waves and Text wave
String conList = WaveList("*",";","DIMS:1,Text:0")
// get row and columns
Variable rows =numpnts($StringFromList(1,conList))
Variable cols = ItemsInlist(conList)
Make/O/N=(rows, cols) wname

//concatenate into wanme and kill source waves
Concatenate/O/KILL/DL conList, wname

// rename 2D wave as the worksheet name
Rename wname $wkShLoad

//kill remaining waves (text waves)
String kList = WaveList("*",";","Text:1")
Variable j
do 
String kWave =StringFromList(j,kList)
KillWaves $kWave
j += 1
while (j<ItemsInList(kList))

End

Function KillAllGraphs()
	string fulllist = WinList("*", ";","WIN:1")
	string name, cmd
	variable i
 
	for(i=0; i<itemsinlist(fulllist); i +=1)
		name= stringfromlist(i, fulllist)
		sprintf  cmd, "Dowindow/K %s", name
		execute cmd		
	endfor
end

Function MultiLoad()
	Variable refNum
	String message = "Select one or more files"
	String outputPaths
	String fileFilters = "Data Files (*.txt,*.dat,*.csv):.txt,.dat,.csv;"
	fileFilters += "All Files:.*;"
 
	Open /D /R /MULT=1 /F=fileFilters /M=message refNum
	outputPaths = S_fileName
	
	if (strlen(outputPaths) == 0)
		Print "Cancelled"
	else
		Variable numFilesSelected = ItemsInList(outputPaths, "\r")
		Variable i
		for(i=0; i<numFilesSelected; i+=1)
			String path = StringFromList(i, outputPaths, "\r")
			Printf "%d: %s\r", i, path
			// Add commands here to load the actual waves.  An example command
			// is included below but you will need to modify it depending on how
			// the data you are loading is organized.
			//LoadWave/A/D/J/W/K=0/V={" "," $",0,0}/L={0,2,0,0,0} path
		endfor
	endif
 
	// return outputPaths
End Function 

Function FD(w,E) : FitFunc
	Wave w
	Variable E

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(E) = B+A/(exp((E0-E)/(T*8.617e-5))+1)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ E
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = E0
	//CurveFitDialog/ w[1] = T
	//CurveFitDialog/ w[2] = A
	//CurveFitDialog/ w[3] = B

	return w[3]+w[2]/(exp((w[0]-E)/(w[1]*8.617e-5))+1)
End

Function DispPlot(ww)
	wave ww
	Display ww[][1] vs ww[][0] 
	Label left "Counts per Second"; DelayUpdate
	Label bottom "Binding energy (eV)"; DelayUpdate
	ModifyGraph rgb=(0,0,0)
	ModifyGraph mirror=1, mirror(left)=1, tick=2, tick(left)=2, notation(left)=1
	Variable ymax=wavemax(ww)
	Variable ymin=wavemin(ww)
	ymax+=(ymax-ymin)*0.15
	SetAxis left *, ymax
	SetAxis/A/R bottom
end

Function EditPlot()
	Label left "Counts per Second"; DelayUpdate
	Label bottom "Binding energy (eV)"; DelayUpdate
	ModifyGraph rgb=(0,0,0)
	ModifyGraph mirror=1, mirror(left)=1, tick=2, tick(left)=2, notation(left)=1
	SetAxis/A/R bottom
End

Function TagPeak(ww)
	string ww
	//execute "Tag/C/N=newpeak NbVB, 10, \"newpeak\""
	Tag/C/N=newpeak $(ww), 10, "newpeak"
End

Function DispCPS()
	variable ic, nt
	string theList, waveinlist
	theList = WaveList("*",";","")
	nt = ItemsInList(theList)
 	// iterate through the list
 	for(ic=0;ic<nt;ic+=1)
 		// get the next name that fits the rule
		waveinlist = StringFromList(ic,theList)
		// convert the string name to a wave reference
		wave wwave = $waveinlist
		DispPlot(wwave)
     endfor
     execute "TileWindows/O=1/C"
End

Function CPSBinning(w)
	Wave w
	Variable bin
 	//Duplicate $w, $(w+"_bin")
	//Variable count = 0
	Variable numPoints = DimSize(w,0)
	Variable maxCol = DimSize(w,1)
	Variable newDim = Ceil(numPoints/2)
	print numPoints
	Variable i
	Make/N=((newDim),2) binning
	for(i=0; i<newDim; i+=1)
		binning[i][1]=(w[2*i][1]+w[2*i+1][1])/2
		binning[i][0]=(w[2*i][0]+w[2*i+1][0])/2
	endfor
End

Function FitNow(ffx, ffy)
	Wave ffx, ffy
	Make/D/N=4/O W_coef
	W_coef[0] = {0,300,500,0}
	FuncFit/NTHR=0 FD W_coef  ffy[pcsr(A),pcsr(B)] /X=ffx /D
	String fitwname = "fit_"+NameofWave(ffy)
	ModifyGraph rgb=(0,0,0),lsize($(fitwname))=3
	ModifyGraph rgb[0]=(48059,48059,48059)
End

Function CreateFitPair(ww_str)
	String ww_str
	String xwname = ww_str + "x"
	String ywname = ww_str + "y"
	Variable ww_len = DimSize($(ww_str), 0)
	Wave ww = $(ww_str)
	Make/N=(ww_len)/D x_tmp
	x_tmp[]=ww[p][0]
	Rename x_tmp $xwname
	Make/N=(ww_len)/D y_tmp
	y_tmp[]=ww[p][1]
	Rename y_tmp $ywname
	Display $ywname vs $xwname
End

Function SavePDF(filename)
	String filename
	String fullfilename = filename + ".pdf"
	SavePICT/EF=1/P=home/E=-8/I/W=(0,0,6,5) as (fullfilename)
End

Function NewLabel(ltext)
	String  ltext
	TextBox/F=0/A=MC ltext
End