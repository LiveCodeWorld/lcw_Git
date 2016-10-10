﻿script "lib_GitDisplay"
--> MetaData
-
license: GPLv3
name: lib_GitDisplay
type: library
version: 0.2

/*
A library for working with GIT.
It has not been tested on unix (should work fine), or Windows machines (beware of line ending issues).
*/


--> Working on
-
getprop git_StatusMenuTitle
   -- utility for customising git array display
   -- not needed to be in a library
   -- but useful to study how to make flexible menus
   
   put "Global | GIT |" into mTitle
   put the hilited_Element of the target into commaPath
   put the selected_Value of the target into sValue
   if sValue is no an array then
      -- delete item -1 of commaPath
      put "File" into item -1 of commaPath
   end if
   repeat for each item someItem in commaPath
      put toupper (char 1 of someItem) into char 1 of someItem
      if char -1 of someItem = ":" then delete char -1 of someItem
      put space & someItem && "|" after mTitle
   end repeat
   put space & "Menu" after mTitle
   
   switch
      case menu_Exists (mTitle)
         return mTitle
      default
         put mTitle
         put the line_Menu of the target into mTitle
         return mTitle
   end switch
end git_StatusMenuTitle

function menu_Exists mTitle
   put menu_GetGlobalController (mTitle) into mController
   return exists (mController)
end menu_Exists

on mDoubleUp_DisplayGitFile arrayView, shortFileOrFolder
   put the displayed_GitCheckoutFolder of arrayView into gitCheckoutFolder
   text_AddTrailing gitCheckoutFolder, slash
   put gitCheckoutFolder & shortFileOrFolder into fileOrFolder
   
   switch
      case there is a stack fileOrFolder
         if the scriptonly of stack fileOrFolder is true then
            edit the script of stack fileOrFolder
         else
            go to stack fileOrFolder
         end if
         break
      case there is a folder fileOrFolder
         finder_Reveal fileOrFolder
         break
      case there is a file fileOrFolder
         launch_Atom fileOrFolder
         break
   end switch
end mDoubleUp_DisplayGitFile

command git_RefreshDisplay pTreeTitle
   -- this is now handled locally in each display
   -- look at this to dig out older code for files and log.
   
   put the git_TreeField of me into gitTreeField
   if pTreeTitle is empty then put the title_Text of gitTreeField into pTreeTitle
   
   switch pTreeTitle
      case "Files in Repository"
         set the cursor to watch
         put git_ExecuteShellCommand ("git ls-files") into commitedFiles
         put file_IndexToOutline (commitedFiles, "outline") into someOutline
         set the tree_Display [pTreeTitle] of gitTreeField to someOutline
         break
      case "Log"
         put "git log --pretty=oneline" into someShell
         -- put space & "-n30" after someShell
         put git_ExecuteShellCommand(someShell) into simpleLog
         put git_LogLinkOutline(simpleLog) into someOutline
         set the tree_Display ["Log"] of gitTreeField to someOutline
         break
      default
         put git_FetchStatusTable() into gitStatusTable
         put git_ConstructStatusArray (gitStatusTable) into statusArray
         
         put statusArray ["gitStatusTable"] into gitStatusTable
         put statusArray ["gitTitle"] into gitTitle
         
         set the tree_Display [gitTitle] of gitTreeField to gitStatusTable
   end switch
   return someOutline
end git_RefreshDisplay


--> Display | GIT | Status
-
command display_GitStatus pScriptObject, pArrayView
   if pScriptObject is empty then put the long id of the target into pScriptObject
   put the git_CheckoutFolder of pScriptObject into gitCheckoutFolder
   
   display_GitFolderStatus gitCheckoutFolder, pArrayView
   put the result into arrayView
   return arrayView
end display_GitStatus

command display_GitProjectStatus projectName, pArrayView
   put project_GetFolder (projectName) into projectFolder
   if there is not a folder projectFolder then
      if projectFolder is not empty then put projectFolder
      answer warning merge ("Cannot locate a folder for project '[[projectName]]'!")
      breakpoint
      exit to top
   end if
   
   display_GitFolderStatus projectFolder, pArrayView
   put the result into displayView
   return displayView
end display_GitProjectStatus

command display_GitFolderStatus gitCheckoutFolder, pArrayView
   if there is not a folder gitCheckoutFolder then return empty
   put git_FetchStatusTable (gitCheckoutFolder) into gitStatusTable
   display_GitStatusTable gitStatusTable, gitCheckoutFolder, pArrayView
   put the result into arrayView
   return arrayView
end display_GitFolderStatus

command display_GitStatusTable gitStatusTable, gitCheckoutFolder, pArrayView
   set the itemdelimiter to ":"
   if item 1 of gitStatusTable = "fatal" then
      -- fatal: Not a git repository (or any of the parent directories): .git
      answer warning gitStatusTable
      return empty
   end if
   
   put git_ConstructStatusArray (gitStatusTable) into statusArray
   array_StripEmptyKeys statusArray
   
   if exists (pArrayView) then
      set the displayed_Array of pArrayView to statusArray
   else
      set the itemdelimiter to slash
      put item -1 of gitCheckoutFolder into gitShortFolder
      put gitShortFolder && ",GIT Status" into someTitle
      
      put "mDoubleUp_DisplayGitFile" into mDoubleUpCommand
      
      display_Array statusArray, someTitle, "Global | GIT | Status | Menu", "Global | GIT | Line | File | Menu", empty, mDoubleUpCommand
      put the result into pArrayView   
      set the displayed_ScriptObject of pArrayView to scriptObject
      set the displayed_GitCheckoutFolder of pArrayView to gitCheckoutFolder
      
      put the script of pArrayView into oScript
      put git_ConstructDisplayStatusScript() into someScript
      put oScript & CR & CR & someScript into newScript
      set the script of pArrayView to newScript
   end if
   return pArrayView
end display_GitStatusTable

function git_ConstructDisplayStatusScript
   put "getprop menu_Title" into someScript
   put CR & "    if the kind of the target = 'com.livecode.widget.treeView' then return the git_StatusMenuTitle of the target" after someScript
   put CR & "    pass menu_Title" after someScript
   put CR & "end menu_Title" after someScript
   
   -- for some reason  = 'com.livecode.widget.treeView'  does nto work
   replace "'" with quote in someScript
   return someScript
end git_ConstructDisplayStatusScript

command git_DisplayStatusLines gitCheckoutFolder
   put git_FetchStatusTable (gitCheckoutFolder) into gitStatusTable
   set the itemdelimiter to slash
   put item -1 of gitCheckoutFolder into gitShortFolder
   put gitShortFolder & comma & "GIT Status" into someTitle
   display_Index gitStatusTable, someTitle, "Global | GIT | Status | Menu"
   return the result
end git_DisplayStatusLines


--> Display | GIT | Stack
-
command display_StackHistory someObject
   local logLinkArray
   
   put the stack_Object of someObject into stackObject
   put the filename of stackObject into stackPath
   
   -- put git_GetRootFolder() into oRoot
   -- git_SetRootFolder tempRootFolder -- should maybe do this built in with all git file related handlers?
   put the git_CheckoutFolder of someObject into tempRootFolder
   
   put git_FileLog (stackPath) into simpleLog
   -- put git_LogLinkArray (simpleLog) into logArray
   -- put keys (logArray) into logIndex
   git_ProcessSimpleLogLines simpleLog, logArray, orderedCommentLines
   
   put "Stack Log for:" && the name of stackObject into someTitle
   put comma & "GIT" after someTitle
   put empty into pExpandLevel
   
   -- display_Array logArray, someTitle, "Global | Git | Stack | History | Menu", "Global | Git | Line | Stack | Log | Menu"
   display_Index orderedCommentLines, someTitle, "Global | Git | Stack | History | Menu", "Global | Git | Line | Stack | Log | Menu"
   put the result into indexView
   
   set the log_Array of indexView to logArray
   set the displayed_Object of indexView to stackObject
   set the displayed_File of indexView to stackPath
   
   -- git_SetRootFolder oRoot
   return treeView
end display_StackHistory

function git_ConstructStatusArray gitStatusTable , pNoComments
   put line -1 of gitStatusTable into gitHint
   delete line -1 of gitStatusTable
   
   filter gitStatusTable without "#   *"
   filter gitStatusTable without "#"
   replace ("#" & tab & "modified:   ") with tab in gitStatusTable
   replace ("# ") with empty in gitStatusTable
   replace (CR & "#" & tab) with (CR & tab) in gitStatusTable
   
   put 1 into indexNum
   put empty into firstTitle
   put "Branch" into someHeader
   repeat for each line someLine in gitStatusTable
      put someHeader into gitArray [indexNum]["title"]
      put empty into gitArray [indexNum]["contents"][subTitle]
      put true into gitArray [indexNum]["isExpanded"]
      put empty into gitArray [indexNum]["contents"][gitHint]
      
      switch
         case char -1 of someLine = ":"
            -- a title
            put someLine into someHeader
            put empty into displayArray [someHeader]
            break
         case char 1 of someLine = tab
            -- a list of files
            delete char 1 of someLine
            set the itemdelimiter to ":"
            if the number of items of someLine = 2 then
               put item 1 of someLine into someAction
               put word 1 to -1 of item 2 of someLine into someFile
               put empty into displayArray [someHeader][someAction][someFile]
            else
               put empty into displayArray [someHeader]["files"][someLine]
            end if
            
            put empty into gitArray [indexNum]["contents"][someLine]
            break
         default
            -- a helpful comment line
            put word 1 to -1 of someLine into someComment
            if someComment is empty then next repeat
            
            put someComment into gitArray [indexNum]["title"]
            
            if pNoComments is false or someHeader is "Branch" then
               put empty into displayArray [someHeader][someComment]
            end if
      end switch
      
      add 1 to indexNum
   end repeat
   return displayArray
end git_ConstructStatusArray


--> GIT | Log | Array
-
-- function git_FileCommitHashArray someFile, pHowMany, pAllBranches
-- not used
put git_FileLog (someFile, pHowMany, pAllBranches) into simpleLog
put git_LogLinkArray (simpleLog) into commitHashArray
return commitHashArray
end git_FileCommitHashArray

function git_LogLinkArray simpleLog
   local logLinkArray
   git_ProcessSimpleLogLines simpleLog, logLinkArray, orderedCommentLines
   return logLinkArray
end git_LogLinkArray

command git_ProcessSimpleLogLines simpleLog, @logLinkArray, @orderedCommentLines
   put 0 into lineNum
   repeat for each line someLine in simpleLog
      add 1 to lineNum
      put word 1 of someLine into commitHash
      put word 2 to -1 of someLine into firstCommentLine
      put firstCommentLine & CR after orderedCommentLines
      put commitHash into logLinkArray [lineNum]["commitHash"]
      put firstCommentLine into logLinkArray [lineNum]["firstCommentLine"]
   end repeat
   delete char -1 of orderedCommentLines
end git_ProcessSimpleLogLines


--> GIT | Log | Outline
-
/*
Old way of doing it. Probably better to use arrays.
*/

function git_FileLogOutline someFile, pHowMany, pAllBranches
   put git_FileLog (someFile, pHowMany, pAllBranches) into simpleLog
   put git_LogLinkOutline (simpleLog) into someOutline
   return someOutline
end git_FileLogOutline

function git_LogLinkOutline simpleLog
   repeat for each line someLine in simpleLog
      put word 1 of someLine into someHash
      put word 2 to -1 of someLine into firstCommentLine
      put html_ConstructNameLink (firstCommentLine, someHash) & CR after someOutline
   end repeat
   delete char -1 of someOutline
   return someOutline
end git_LogLinkOutline


--> Objects
-
private function _GitTreeView
   put the module_View of stack "View|Tree|GIT" into gitTreeView
   return gitTreeView
end _GitTreeView

getprop git_Tree
   return _GitTreeView()
end git_Tree

getprop git_TreeField
   put _GitTreeView() into gitTreeView
   return the tree_Field of gitTreeView
end git_TreeField


--> Display
-
command display_GitHkeyLog hKey, pDoubleUpThing, pStackLabel
   put hkey_HandlerFile (hKey) into handlerFile
   
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put "History for" && kwote(handler_ConvertType (hType) && hName) into someTitle
   
   put handlerFile into gitRelativeFile
   git_SetRelativePath gitRelativeFile
   
   -- temp set gitRoot
   put git_GetRootFolder() into oRoot
   put git_GetCheckoutFolder (handlerFile) into tempRootFolder
   git_SetRootFolder tempRootFolder
   
   if pStackLabel is empty then put "Hkey Log" into pStackLabel
   put hKey into someTitle
   display_GitFileHistory gitRelativeFile, someTitle, pDoubleUpThing, pStackLabel
   
   put the result into treeView
   put the tree_Field of treeView into treeField
   
   lock messages
   set the displayed_Hkey of treeField to hKey
   set the displayed_Object of treeField to hObject
   set the displayed_File of treeField to handlerFile
   unlock messages
   
   -- reset git root
   git_SetRootFolder oRoot
   return treeView
end display_GitHkeyLog

command display_GitScriptLog someObject, pDoubleUpThing, pStackLabel
   put the script_File of someObject into someFile
   
   -- temp set gitRoot
   -- should maybe do this built in with all git file related handlers?
   put git_GetRootFolder() into oRoot
   put git_GetCheckoutFolder (someFile) into tempRootFolder
   git_SetRootFolder tempRootFolder
   
   if pStackLabel is empty then put "Script Log" into pStackLabel
   put the mobile_Name of someObject into someTitle
   
   git_SetRelativePath someFile
   display_GitFileHistory someFile, someTitle, pDoubleUpThing, pStackLabel
   put the result into treeView
   
   put the tree_Field of treeView into treeField
   set the displayed_Object of treeField to someObject
   
   -- reset git root
   git_SetRootFolder oRoot
   return tempRootFolder
end display_GitScriptLog

command display_GitFileHistory someFile, pTitle, pDoubleUpThing, pStackLabel
   put git_FileLogOutline (someFile) into someOutline
   display_LogOutline someOutline, someFile, pTitle, pDoubleUpThing, pStackLabel
   return the result
end display_GitFileHistory

command display_LogOutline someOutline, someFile, pTitle, pDoubleUpThing, pStackLabel
   put empty into pExpandLevel
   put false into pKeepHidden
   put "palette" into pStackStyle
   display_Outline someOutline, pTitle, "Global | Git | Log | Menu", "Global | Git | Line | Log | Menu", pExpandLevel, pKeepHidden, pStackStyle, pStackLabel
   
   put the result into treeView
   put the tree_Field of treeView into treeField
   
   set the displayed_File of treeField to someFile
   if exists (pDoubleUpThing) then 
      set the trigger_Object ["tree_MouseDoubleUp"] of treeField to pDoubleUpThing
   else if pDoubleUpThing is not empty then
      -- assume it is a trigger_Name
      set the trigger_Name ["mouseDoubleUp"] of treeField to pDoubleUpThing
   end if 
   return treeView
end display_LogOutline