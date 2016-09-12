script "lib_GitDisplay"
--> MetaData
-
license: GPLv3
name: lib_GitDisplay
type: library
version: 0.1

/*
A library for working with GIT.
It has not been tested on unix (should work fine), or Windows machines (beware of line ending issues).
*/

--> Working on
-
command display_GitStatus projectName
   --   git_RefreshDisplay "Git Status"
   put "View|Tree|Git" into moduleViewName
   if exists (stack moduleViewName) is false then
      answer merge ("Cannot locate stack '[[moduleViewName]]'!")
      exit to top
   end if
   
   put project_GetFolder (projectName) into checkoutFolder
   put git_FetchStatusTable (checkoutFolder) into gitShellResult
   
   put git_ConstructStatusArray (gitShellResult) into statusArray
   put statusArray ["gitTable"] into someOutline
   -- fatal: Not a git repository (or any of the parent directories): .git
   set the itemdelimiter to ":"
   if item 1 of someOutline = "fatal" then
      answer warning someOutline
      exit to top
   end if
   put statusArray ["gitTitle"] into gitTitle
   
   put the module_View of stack moduleViewName into gitTreeView
   --
   set the tree_Display [gitTitle] of gitTreeView to someOutline
   set the displayed_File of gitTreeView to empty
   set the displayed_Object of gitTreeView to empty
   --
   go to stack moduleViewName
   return gitTreeView
end display_GitStatus

function git_ConstructStatusOutline gitShellResult
   put git_ConstructStatusArray (gitShellResult) into statusArray
   return statusArray ["gitTable"]
end git_ConstructStatusOutline

function git_ConstructStatusArray gitShellResult
   filter gitShellResult without "#   *"
   filter gitShellResult without "#"
   
   replace ("#" & tab & "modified:   ") with tab in gitShellResult
   replace ("# ") with empty in gitShellResult
   replace (CR & "#" & tab) with (CR & tab) in gitShellResult
   
   put gitShellResult into statusArray ["gitTable"]
   put line 1 of gitShellResult into statusArray ["gitTitle"]
   
   if word 1 to 2 of gitTitle = "On branch" then
      delete line 1 of gitShellResult
      put line -1 of gitShellResult into statusArray ["gitHelp"]
   end if
   
   return statusArray
end git_ConstructStatusArray


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
command git_RefreshDisplay pTreeTitle
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
         put git_FetchStatusTable() into gitTable
         put git_ConstructStatusArray (gitTable) into statusArray
         
         put statusArray ["gitTable"] into gitTable
         put statusArray ["gitTitle"] into gitTitle
         
         set the tree_Display [gitTitle] of gitTreeField to gitTable
   end switch
   return someOutline
end git_RefreshDisplay

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

command display_StackHistory someObject
   put the stack_Object of someObject into stackObject
   put the filename of stackObject into stackFile
   
   -- should maybe do this built in with all git file related handlers?
   put git_GetRootFolder() into oRoot
   put the git_CheckoutFolder of someObject into tempRootFolder
   git_SetRootFolder tempRootFolder
   
   put git_FileLogOutline (stackFile) into someOutline
   
   lock screen
   put "Stack Log for:" && the name of stackObject into someTitle
   put empty into pExpandLevel
   
   display_Outline someOutline, someTitle, "Global | Git | Stack | History | Menu", "Global | Git | Line | Stack | Log | Menu", pExpandLevel, false --, "toplevel"
   put the result into treeView
   put the tree_Field of treeView into treeField
   
   set the displayed_Object of treeField to stackObject
   set the displayed_File of treeField to someFile
   unlock screen
   
   git_SetRootFolder oRoot
   return treeView
end display_StackHistory
