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

--> Events
-
on saveStackRequest
   -- update the Git Status displays
   put the long id of the target into cardObject
   put the git_ShortFolder of cardObject into gitShortFolder
   if gitShortFolder is empty then pass saveStackRequest -- or the stack won't be saved
   --
   put display_FindView ("Git Status", gitShortFolder) into displayView
   if displayView is not empty then
      -- display_GitRefreshProjectName gitShortFolder
      send "display_GitRefreshProjectName gitShortFolder" to me in 20 ticks -- display after saving
   end if
   --
   pass saveStackRequest -- or the stack won't be saved
end saveStackRequest

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
         atom_DisplayFile fileOrFolder 
         break
   end switch
end mDoubleUp_DisplayGitFile


--> Props
-
getprop git_Tree
   return _GitTreeView()
end git_Tree

getprop git_TreeField
   put _GitTreeView() into gitTreeView
   return the tree_Field of gitTreeView
end git_TreeField

getprop git_StatusMenuTitle
   -- only used by "menu_Title" in the line_Menu of the dynamically created Git Status display_Array as set in arrayView script
   -- utility for customising git array display
   -- not needed to be in a library
   -- but useful to study how to make flexible menus
   
   put the long id of the target into tObject
   
   put "Global | GIT |" into mTitle
   put the hilited_Element of tObject into commaPath
   put the selected_Value of tObject into sValue
   if sValue is not an array then
      -- delete item -1 of commaPath
      put "File" into item -1 of commaPath
   end if
   repeat for each item someItem in commaPath
      put toupper (char 1 of someItem) into char 1 of someItem
      if char -1 of someItem = ":" then delete char -1 of someItem
      put space & someItem && "|" after mTitle
   end repeat
   put space & "Menu" after mTitle
   
   -- put menu_GlobalControllerExists (mTitle) into someBoolean
   put mArray_ActiveControllerExists (mTitle) into someBoolean
   switch
      case someBoolean
         return mTitle
      default
         put the line_Menu of tObject into mTitle
         return mTitle
   end switch
end git_StatusMenuTitle


--> Display | GIST
-
command display_Gists pHow
   set the cursor to watch
   switch pHow
      case "Gist Controllers"
         put gist_FetchFiles ("controller") into gistList
         break
      case "Gist Scripts"
         put gist_FetchFiles() into gistList
         filter gistList with "script,*"
         break
         put gist_FetchFiles() into gistList
      default
   end switch
   display_Index gistList, "gist_FetchFiles(),Gists", "Global | Gist | Menu", "Global | Gist | Line | Menu", "gistMouseUp", "gistMouseDoubleUp"
end display_Gists


--> Git | Display
-
command display_GitProjectStatus projectName, pRepoFolder
   put env_ConstructProjectFolder (projectName, pRepoFolder) into gitFolder
   if gitFolder is empty then
      display_DebugHistory "display_GitProjectStatus"
      --
      put merge ("Cannot find project '[[projectName]]'") into someQuestion
      lcw_AnswerWarning someQuestion
   end if
   --
   display_GitFolderStatus gitFolder
   put the result into arrayView
   return arrayView
end display_GitProjectStatus

command display_GitPushCurrentBranch gitFolder
   put git_CurrentBranchName (gitFolder) into currentBranchName
   put "git push origin" && kwote (currentBranchName) into someShell
   --
   put git_ExecuteShellCommand (someShell, gitFolder) into shellResult
   --
   switch
      case shellResult begins with "Broken pipe"
         break
      case token 1 of shellResult = "Error"
         /*
         ERROR: Your account is disabled. Please see https://github.com/account/billing
         fatal: Could not read from remote repository.
         
         Please make sure you have the correct access rights
         and the repository exists.
         */
         put "Check billing" into btnText
         answer shellResult with btnText or "Cancel"
         if it is btnText then
            launch url "https://github.com/account/billing"
         end if
         break
      default
         lcw_Notify shellResult
         --
         env_DeconstructProjectFolder gitFolder, projectName, repoFolder
         display_GitRefreshProjectName projectName
   end switch
end display_GitPushCurrentBranch


--> Display | GIT
-
command display_GitStatus sObject
   put the git_Folder of sObject into gitCheckoutFolder
   --
   display_GitFolderStatus gitCheckoutFolder
   put the result into arrayView
   return arrayView
end display_GitStatus

command display_GitRefreshProjectName projectName
   -- works even if project is not loaded based on standard file names
   put env_ConstructHomePath (projectName) into homeStackPath
   put display_FindView ("Git Status", projectName) into gitDisplayView
   --
   switch
      case exists (gitDisplayView) is false
         return "Error, there is no 'Git Staus' display for project '[[asdf]]'. Doing nothing."
      case there is a stack projectName
         put the git_Folder of stack projectName into gitCheckoutFolder
         display_GitFolderStatus gitCheckoutFolder
         put the result into displayView
         return displayView
      case there is a stack homeStackPath
         put git_GetCheckoutFolder (homeStackPath) into gitCheckoutFolder
         display_GitFolderStatus gitCheckoutFolder
         put the result into displayView
         return displayView
      default
         return "Error, project '[[projectName]]' does not exist."
   end switch
end display_GitRefreshProjectName

command display_GitProjectStatus projectName
   put project_GetFolder (projectName) into projectFolder
   if there is not a folder projectFolder then
      if projectFolder is not empty then put projectFolder
      answer warning merge ("Cannot locate a folder for project '[[projectName]]'!")
      breakpoint
      exit to top
   end if
   
   display_GitFolderStatus projectFolder
   put the result into displayView
   return displayView
end display_GitProjectStatus

command display_GitFolderStatus gitCheckoutFolder
   if there is not a folder gitCheckoutFolder then return empty
   put git_FetchStatusTable (gitCheckoutFolder) into gitStatusTable
   --
   _DisplayGitStatusTable gitStatusTable, gitCheckoutFolder
   put the result into arrayView
   return arrayView
end display_GitFolderStatus


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


--> Display | GIT | Stack
-
command display_StackHistory someObject
   local logLinkArray
   
   put the stack_Object of someObject into stackObject
   put the filename of stackObject into stackPath
   put the git_Folder of someObject into gitCheckoutFolder
   
   put git_GetFileLog (stackPath) into simpleLog
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
   set the displayed_GitCheckoutFolder of indexView to gitCheckoutFolder
   
   return treeView
end display_StackHistory


--> Git | Display | Old
-
command git_DisplayStatusLines gitCheckoutFolder
   put git_FetchStatusTable (gitCheckoutFolder) into gitStatusTable
   set the itemdelimiter to slash
   put item -1 of gitCheckoutFolder into gitShortFolder
   put gitShortFolder & comma & "GIT Status" into someTitle
   display_Index gitStatusTable, someTitle, "Global | GIT | Status | Menu"
   return the result
end git_DisplayStatusLines

command git_RefreshDisplay pTreeTitle
   -- this is now handled locally in each display
   -- look at this to dig out older code for files and log.
   breakpoint
   
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


--> Git | Display | Stack
-
command git_DisplayTempStackRevision someObject, commitHash
   put the stack_Object of someObject into stackObject
   put the effective filename of stackObject into thisFile
   
   put the short name of stack thisFile into oName
   
   if exists (stack thisFile) is false then
      answer warning "Stack does not exist!"
      breakpoint
      exit to top
   end if
   
   set lockmessages to true
   git_ExportFileRevision thisFile, commitHash
   put the result into toFile
   
   if exists (stack toFile) is false then
      answer warning "Revision Stack does not exist!"
      breakpoint
      
      put toFile into toFolder
      set the itemdelimiter to slash
      put empty into item -1 of toFolder
      finder_Reveal toFolder
      
      atom_DisplayFile toFile
      exit to top
   end if
   
   put "tempStackName" && oName into tempStackName
   put oName && commitHash into exportedRevisionName
   
   try
      set lockmessages to true
      set the name of stack thisFile to tempStackName -- not totally sure this is needed
      set the name of stack toFile to exportedRevisionName
      set the name of stack thisFile to oName -- not totally sure this is needed (maybe just keep it as it was). But tricky to debug.
      set lockmessages to false
      
      set the destroystack of stack toFile to true
      set the destroywindow of stack toFile to true     
   catch e
      set the name of stack thisFile to oName
      
      answer warning merge ("Problem opening versioned [[stackObject]]!")
      breakpoint
      put there is a file toFile into fileExists
      get url ("binfile:" & toFile)
      atom_DisplayFile toFile
      exit to top
   end try
   
   set the label of stack toFile to exportedRevisionName
   put the name of stack toFile into newStackObject
   go to stack toFile
end git_DisplayTempStackRevision

command git_DisplayTempStackFromTreeish commitHash, pToFile
   breakpoint
   git_ExportFileRevision relativePath, commitHash
   put the result into toFile
   
   set lockmessages to true
   put the name of stack toFile into oName
   set the name of stack toFile to (oName && treeish)
   go to stack toFile
   set lockmessages to false
   
   set the destroystack of stack toFile to true
   set the destroywindow of stack toFile to true
end git_DisplayTempStackFromTreeish


--> Display | GIT | Handlers
-
function git_ConstructStatusArray gitStatusTable , pNoComments
   -- put line -1 of gitStatusTable into gitHint
   -- delete line -1 of gitStatusTable
   
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
put git_GetFileLog (someFile, pHowMany, pAllBranches) into simpleLog
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
   put git_GetFileLog (someFile, pHowMany, pAllBranches) into simpleLog
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


--> Private
-
private function _GitTreeView
   put the module_View of stack "View|Tree|GIT" into gitTreeView
   return gitTreeView
end _GitTreeView

command _DisplayGitStatusTable gitStatusTable, gitCheckoutFolder  
   -- put git_GetCheckoutFolder (gitCheckoutFolder) into gitCheckoutFolder -- can be called from anywhere inside a git repo 
   
   set the itemdelimiter to ":"
   if item 1 of gitStatusTable = "fatal" then
      -- fatal: Not a git repository (or any of the parent directories): .git
      answer warning gitStatusTable
      return empty
   end if
   
   -- let's find an existing displayView if it exists
   set the itemdelimiter to slash
   put item -1 of gitCheckoutFolder into gitShortFolder
   put display_FindView ("Git Status", gitShortFolder) into displayView
   set the itemdelimiter to comma
   
   -- see "git_GetStatusArray (gitCheckoutFolder)"
   put git_ConstructStatusArray (gitStatusTable) into statusArray
   array_StripEmptyKeys statusArray
   
   if exists (displayView) then
      set the displayed_Array of displayView to statusArray
   else
      display_Array statusArray, gitShortFolder, "GIT Status"
      put the result into displayView
      set the title_Menu of displayView to "Global | GIT | Status | Menu"
      set the line_Menu of displayView to "Global | GIT | Line | File | Menu"
      set the mouse_DoubleUp ["me"] of displayView to "mDoubleUp_DisplayGitFile"
      --
      set the displayed_GitCheckoutFolder of displayView to gitCheckoutFolder
      
      -- experimental here we set the script of the displayView's card
      put the script of displayView into oScript
      put _DisplayGitStatusScript() into someScript
      put oScript & CR & CR & someScript into newScript
      set the script of displayView to newScript
   end if
   return displayView
end _DisplayGitStatusTable

function _DisplayGitStatusScript
   put "getprop menu_Title" into someScript
   put CR & "    if the kind of the target = 'com.livecode.widget.treeView' then return the git_StatusMenuTitle of the target" after someScript
   put CR & "    pass menu_Title" after someScript
   put CR & "end menu_Title" after someScript
   
   -- for some reason  = 'com.livecode.widget.treeView'  does not work
   replace "'" with quote in someScript
   return someScript
end _DisplayGitStatusScript


