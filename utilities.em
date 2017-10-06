/* Utility.em - a small collection of useful editing macros */

// Returns offset of target string in source string

// Return X if target string is not found

macro FindString( source, target )
{
	source_len = strlen( source )
	target_len = strlen( target )


	match = 0
	cp = 0


	while( cp < source_len )
	{
		while( cp < source_len )
		{
			if( source[cp] == target[0] )
				break
			else
				cp = cp + 1
		}

		if( cp == source_len )
		    break;
		
		k = cp
		j = 0
		while( j < target_len && source[k] == target[j] )
		{
			k = k + 1
			j = j + 1
		}
		
		if (j == target_len)
		{
			match = 1
			break
		}
		
		cp = cp + 1
	}

	if( match )
		return cp
	else
		return "X"
}

// Returns the index of the first non whitespace character
// Search starts at offset specified by 'first'
macro SkipWS( string, first )
{
    len = strlen( string )
    i = first
    
    while( i < len )
    {
        if( string[i] == " " || string[i] == "	" )
    		i = i + 1
		else
		    break
    }

	if( i == len )
		return "X"
	else
	    return i
}

macro CodeComments()
{
	hwnd=GetCurrentWnd()
	selection=GetWndSel(hwnd)
	LnFirst=GetWndSelLnFirst(hwnd)
	LnLast=GetWndSelLnLast(hwnd)
	hbuf=GetCurrentBuf()
	if(GetBufLine(hbuf,0)=="//magic-number:tph85666031")
	{
		stop
	}
	Ln=Lnfirst
	buf=GetBufLine(hbuf,Ln)
	len=strlen(buf)
	while(Ln<=Lnlast)
	{
		buf=GetBufLine(hbuf,Ln)
		if(buf==""){
			Ln=Ln+1
			continue
		}
		if(StrMid(buf,0,1)=="/")
		{
			if(StrMid(buf,1,2)=="/")
			{
				PutBufLine(hbuf,Ln,StrMid(buf,2,Strlen(buf)))
			}
		}
		if(StrMid(buf,0,1)!="/")
		{
			PutBufLine(hbuf,Ln,Cat("//",buf))
		}
		Ln=Ln+1
	}
	SetWndSel( hwnd, selection )
}


/* GetFileCreator()

   Get the file creator's name
*/
macro GetFileCreator()
{
	return ""
//	return getEnv(USERNAME)
}

/* GetFunctionCreator()

   Get the function creator's name
*/
macro GetFunctionCreator()
{
	return ""
//	return getEnv(USERNAME)
}

/* GetMonthName:

   Convert the number of month to the name of month.

   return the abbreviation of month if format is 0, otherwise full name.
*/
macro GetMonthName(month, format)
{
	if (month == "1")
		month = "January"
	else if (month == "2")
		month = "February"
	else if (month == "3")
		month = "March"
	else if (month == "4")
		month = "April"
	else if (month == "5")
		month = "May"
	else if (month == "6")
		month = "June"
	else if (month == "7")
		month = "July"
	else if (month == "8")
		month = "August"
	else if (month == "9")
		month = "September"
	else if (month == "10")
		month = "October"
	else if (month == "11")
		month = "November"
	else
		month = "December"

	if (format == "0")
		month = strmid(month, 0, 3)
	
	return month
}

macro ParseFunctionPrototype()
{
	funcInfo = nil

	// Get a handle to the current file buffer and the name
	// and location of the current symbol where the cursor is.
	hbuf = GetCurrentBuf()
	szFuncName = GetCurSymbol()

	hwnd = GetCurrentWnd()
	if (hwnd == 0)
		stop

	sel = GetWndSel(hwnd)
	ln = sel.lnFirst
	//ln = GetSymbolLine(szFuncName)
	
	// Stop macro execution if line number is -1
	if (ln == -1)
		stop

	// Get a handle to the current function prototype.
	szFuncProt = GetBufLine(hbuf, ln)

	pLen = strlen(szFuncProt)
	nLen = strlen(szFuncName)
	pIdx = 0
	lch = 0
	rch = 0
	szArg = ""

	// Remove white space
	while (szFuncProt[pIdx] == " ")
	{
		if (++pIdx == pLen)
			stop
	}

	// Resize string
	szFuncProt = strmid(szFuncProt, pIdx, pLen)
	pLen = pLen - pIdx
	pIdx = 0

	// Store function name
	funcInfo.Name = szFuncName
	
	// Search function string in function prototype string
	while ((pLen - pIdx) >= nLen)
	{
		nIdx = 0
		while (nIdx < nLen)
		{
			if (szFuncName[nIdx] != szFuncProt[pIdx+nIdx])
			{
				break
			}
			nIdx = nIdx + 1
		}
		if (nIdx == nLen)
		{
			break
		}
		pIdx = pIdx + 1
	}

	// argument out of range
	if ((pLen - pIdx) < (nLen + 2))
		stop

	// return type out of range
	if (pIdx < 4)
		stop
	
	// Start to parse return type string
	nIdx = pIdx - 1

	// Remove white space
	while (szFuncProt[nIdx] == " ")
	{
		if (--nIdx == 0)
			stop
	}

	// Store function return type
	funcInfo.Type = strmid(szFuncProt, 0, nIdx+1)
	if (funcInfo.Type == "void")
		funcInfo.Type = "none"

	// Start to parse argument string
	pIdx = pIdx + nLen

	// Remove white space
	while (szFuncProt[pIdx] == " ")
	{
		if (++pIdx == pLen)
			stop
	}

	// Find '('
	while (pIdx < pLen)
	{
		if (szFuncProt[pIdx] == "(")
		{
			lch = pIdx
			break
		}
		pIdx = pIdx + 1
	}

	// Find ')'
	pIdx = pLen - 1;
	while (pIdx > lch)
	{
		if (szFuncProt[pIdx] == ")")
		{
			rch = pIdx
			break
		}
		pIdx = pIdx - 1
	}

	if (lch >= rch)
		stop

	lch = lch + 1
	// Store function argument
	if (lch == rch)
		funcInfo.Argument = "void"
	else
		funcInfo.Argument = strmid(szFuncProt, lch, rch)
	if (funcInfo.Argument == "void")
		funcInfo.Argument = "none"
	
	return funcInfo
}

/*  ParseFileName

*/
macro ParseFileName()
{
	// Get a handle to the current file buffer.
	hbuf = GetCurrentBuf()
	szPath = GetBufName(hbuf)
	
	// Get the structure of current file property.
//	szFileProps = GetBufProps(hbuf)

	// Get the programming language, determinded by the file's document type.
//	szLang = szFileProps.Language

	// Get the current file path
//	szFileName = szFileProps.Name

	// Parse the file path and retrieve file name
	szLen = strlen(szPath)
	szIch = szLen-1

	soff = FindString(szPath, "\\")
	if (soff != "X")
	{	
		while (szPath[szIch] != "\\")
		{
			szIch--
		}
		return strmid(szPath, szIch+1, szLen)
	}
	else
		return szPath
	
}
/* InsertFuncHeader:

   Inserts a comment header block at the top of the current function. 
*/
macro GenerateFunctionHeader()
{
	funcInfo = ParseFunctionPrototype()
	type = funcInfo.Type
	name = funcInfo.Name
	argv = funcInfo.Argument

	abuf = NewBuf("argument")
	ahas = 1;

	while (ahas == 1)
	{
		aoff = FindString(argv, ",")
		if (aoff == "X")
		{
			aoff = strlen(argv)
			ahas = 0;
		}
		soff = FindString(argv, " ")
		if (soff == "X")
		{
			soff = -1
		}

		arg = strmid(argv, soff+1, aoff)

		if (ahas == 1)
		{
			argv = strmid(argv, aoff+1, strlen(argv))
			argv = strmid(argv, SkipWS(argv, 0), strlen(argv))
		}

		AppendBufLine(abuf, arg)

	}

	line = 0
	maxln = GetBufLineCount(abuf)


	// Get a handle to the current file buffer and the name
	// and location of the current symbol where the cursor is.
	hbuf = GetCurrentBuf()
//	szFuncName = GetCurSymbol()
//	ln = GetSymbolLine(szFuncName)

	hwnd = GetCurrentWnd()
	if (hwnd == 0)
		stop

	sel = GetWndSel(hwnd)
	ln = sel.lnFirst

	// Get the function creator's name
	szCreator = GetFunctionCreator()

	// put the insertion point inside the header comment
//	SetBufIns(hbuf, ln+3, 20)
	
	// Generate function header text

	InsBufLine(hbuf, ln++, "/**")
 	sz = " *****************************************************************************"
	InsBufLine(hbuf, ln++, sz)
	InsBufLine(hbuf, ln++, " * @@brief	Example showing how to document a function with Doxygen.")
	InsBufLine(hbuf, ln++, " * ")
	InsBufLine(hbuf, ln++, " * Description of what the function does. This part may refer to the ")
	InsBufLine(hbuf, ln++, " * parameters of the function, like @@b param1 or @@b param2.")
	InsBufLine(hbuf, ln++  " * ")
	while (line < maxln) {
		arg = GetBufLine(abuf, line++)
		InsBufLine(hbuf, ln++  " * @@param 	@arg@ description")
	}	
	InsBufLine(hbuf, ln++  " * @@return	@type@")
	InsBufLine(hbuf, ln++  " * ")	
	InsBufLine(hbuf, ln++  " * @@see 	@name@")
	InsBufLine(hbuf, ln++  " * @@see 	http://website/")
	InsBufLine(hbuf, ln++  " * @@note 	Something to note.")
	InsBufLine(hbuf, ln++  " * @@warning Warning.")	
	sz = " *****************************************************************************"
	InsBufLine(hbuf, ln++, sz)
	InsBufLine(hbuf, ln++, " */")
	
//	sz = "/*****************************************************************************"
//	InsBufLine(hbuf, ln++, sz)
//	InsBufLine(hbuf, ln++, " * Function:    @name@")
//	InsBufLine(hbuf, ln++, " * ")
//	InsBufLine(hbuf, ln++, " * Description: ")
//	InsBufLine(hbuf, ln++, " *              ")
//	InsBufLine(hbuf, ln++, " * Params:      @argv@")
//	InsBufLine(hbuf, ln++, " *              ")
//	InsBufLine(hbuf, ln++, " * Return:      @type@")
//	InsBufLine(hbuf, ln++, " *              ")
//	InsBufLine(hbuf, ln++ " * Creator:     @szCreator@")
//	sz = "*****************************************************************************/"
//	InsBufLine(hbuf, ln++ sz)

	closeBuf(abuf)
}


/* InsertFileHeader:

   Inserts a comment header block at the top of the current file. 
*/
macro GenerateFileHeader()
{	
	// Get a handle to the current file buffer.
	hbuf = GetCurrentBuf()

	// Get the structure of current file property.
	szFileProps = GetBufProps(hbuf)

	// Get the programming language, determinded by the file's document type.
	szLang = szFileProps.Language

	// Get the current file path
	szFilePath = szFileProps.Name

	szFileName = ParseFileName()
	
	// Get the current system time
	szTime = GetSysTime(1)
	szYear = szTime.Year
	szMonth = GetMonthName(szTime.Month, 0)
	szDay = szTime.Day

	// Get the file creator's name
	szCreator = GetFileCreator()
	
	// Generate file header text
	ln = 0

	
	InsBufLine(hbuf, ln++, "/**")
 	sz = " *****************************************************************************"
	InsBufLine(hbuf, ln++, sz)
	InsBufLine(hbuf, ln++, " * @@brief 	File containing example of doxygen usage for quick reference.")
	InsBufLine(hbuf, ln++, " * ")
	InsBufLine(hbuf, ln++, " * Here typically goes a more extensive explanation of what the header")
	InsBufLine(hbuf, ln++, " * defines. Doxygens tags are words preceeded by either a backslash @@\\")
	InsBufLine(hbuf, ln++, " * or by an at symbol @@@@.")	
	InsBufLine(hbuf, ln++, " * ")
	InsBufLine(hbuf, ln++, " * @@file 	@szFileName@")
	InsBufLine(hbuf, ln++, " * @@author	@szCreator@")
	InsBufLine(hbuf, ln++, " * @@date 	@szDay@/@szMonth@/@szYear@")
	InsBufLine(hbuf, ln++, " * @@see		http://www.stack.nl/~dimitri/doxygen/docblocks.html")
	InsBufLine(hbuf, ln++, " * @@see		http://www.stack.nl/~dimitri/doxygen/commands.html")
	sz = " *****************************************************************************"
	InsBufLine(hbuf, ln++, sz)
	InsBufLine(hbuf, ln++, " * ")	
	InsBufLine(hbuf, ln++, " * THE PRESENT FIRMWARE WHICH IS FOR GUIDANCE ONLY AIMS AT PROVIDING CUSTOMERS")
	InsBufLine(hbuf, ln++, " * WITH CODING INFORMATION REGARDING THEIR PRODUCTS IN ORDER FOR THEM TO SAVE")	
	InsBufLine(hbuf, ln++, " * TIME. AS A RESULT, STMICROELECTRONICS SHALL NOT BE HELD LIABLE FOR ANY")
	InsBufLine(hbuf, ln++, " * DIRECT, INDIRECT OR CONSEQUENTIAL DAMAGES WITH RESPECT TO ANY CLAIMS ARISING")
	InsBufLine(hbuf, ln++, " * FROM THE CONTENT OF SUCH FIRMWARE AND/OR THE USE MADE BY CUSTOMERS OF THE")
	InsBufLine(hbuf, ln++, " * CODING INFORMATION CONTAINED HEREIN IN CONNECTION WITH THEIR PRODUCTS.")
	InsBufLine(hbuf, ln++, " * ")
	InsBufLine(hbuf, ln++, " * <b>&copy; COPYRIGHT @szYear@ COMPANY NAME</b>")
	InsBufLine(hbuf, ln++, " * ")	
	sz = " *****************************************************************************"
	InsBufLine(hbuf, ln++, sz)
	InsBufLine(hbuf, ln++, " */")

// 	sz = "/*****************************************************************************"
//	InsBufLine(hbuf, ln++, sz)
//	InsBufLine(hbuf, ln++, " * (C) Copyright @szYear@ COMPANY NAME")
//	InsBufLine(hbuf, ln++, " * FILE NAME:    @szFileName@")
//	InsBufLine(hbuf, ln++, " * DESCRIPTION:  ")
//	InsBufLine(hbuf, ln++, " * PRODUCT NAME: ")
//	InsBufLine(hbuf, ln++, " * APPLICATION:  ")
//	InsBufLine(hbuf, ln++, " * TARGET H/W:   ")
//	InsBufLine(hbuf, ln++, " * TARGET S/W:   @szLang@")
//	InsBufLine(hbuf, ln++, " * ")	
//	InsBufLine(hbuf, ln++, " * CREATED BY:   @szCreator@")	
//	InsBufLine(hbuf, ln++, " * DATE:         @szDay@/@szMonth@/@szYear@")
//	InsBufLine(hbuf, ln++, " * DOC REF:      ")
//	sz = "******************************************************************************"
//	InsBufLine(hbuf, ln++, sz)
//	InsBufLine(hbuf, ln++, " */")

	return ln
}

macro GenerateTemplate_C_File()
{
	// Get a handle to the current file buffer.
	hbuf = GetCurrentBuf()

	szFileName = toupper(ParseFileName())
	soff = FindString(szFileName, ".")
	if (soff != "X")
	{
		szFileName = strtrunc(szFileName, soff)
	}
	
	// Insert file header comment block
	ln = GenerateFileHeader() + 1

	// Insert header guard
	insBufLine(hbuf, ln++, "#define @szFileName@_C")
	InsBufLine(hbuf, ln++, "")	
	insBufLine(hbuf, ln++, "/* #include */")
	InsBufLine(hbuf, ln++, "")
	insBufLine(hbuf, ln++, "/* #define */")
	InsBufLine(hbuf, ln++, "")
	insBufLine(hbuf, ln++, "/* typedef */")
	InsBufLine(hbuf, ln++, "")
	insBufLine(hbuf, ln++, "/* static variables */")
	InsBufLine(hbuf, ln++, "")
	insBufLine(hbuf, ln++, "/* static constants */")	
	InsBufLine(hbuf, ln++, "")	
	insBufLine(hbuf, ln++, "/* static function prototypes */")
	InsBufLine(hbuf, ln++, "")
}

macro GenerateTemplate_H_File()
{
	// Get a handle to the current file buffer.
	hbuf = GetCurrentBuf()

	szFileName = toupper(ParseFileName())
	soff = FindString(szFileName, ".")
	if (soff != "X")
	{
		szFileName = strtrunc(szFileName, soff)
	}

	// Insert file header comment block
	ln = GenerateFileHeader() + 1

	// Insert header guard
	insBufLine(hbuf, ln++, "#ifndef @szFileName@_H")
	insBufLine(hbuf, ln++, "#define @szFileName@_H")
	InsBufLine(hbuf, ln++, "")
	insBufLine(hbuf, ln++, "/* #include */")
	InsBufLine(hbuf, ln++, "")
	insBufLine(hbuf, ln++, "/* #define */")
	InsBufLine(hbuf, ln++, "")
	insBufLine(hbuf, ln++, "/* typedef */")
	InsBufLine(hbuf, ln++, "")
	insBufLine(hbuf, ln++, "/* variables */")
	InsBufLine(hbuf, ln++, "")
	insBufLine(hbuf, ln++, "#ifdef @szFileName@_C")
	InsBufLine(hbuf, ln++, "")
	insBufLine(hbuf, ln++, "#else")
	InsBufLine(hbuf, ln++, "")
	insBufLine(hbuf, ln++, "#endif")
	InsBufLine(hbuf, ln++, "")
	insBufLine(hbuf, ln++, "/* constants */")	
	InsBufLine(hbuf, ln++, "")
	insBufLine(hbuf, ln++, "/* function prototypes */")
	InsBufLine(hbuf, ln++, "")
	insBufLine(hbuf, ln++, "#endif")
}
