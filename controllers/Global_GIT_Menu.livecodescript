script "Global | GIT | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Menu
type: controller
version: 0.2

/*As the general git menu, this probably should not have a scriptObject as the menu_Target
becasue it will be displayed by the standard project menu interface.
Change to indexView or make it clever.*/


--> Menu | Init
-
local LocalArray

on menu_Init
   put scriptEditor_Object() into sObject
   put sObject into LocalArray ["sObject"]
end menu_Init

getprop menu_Target [tObject]
   -- not called on submenus :(
   put LocalArray ["sObject"] into sObject
   return sObject
end menu_Target

getprop disabled_Dev
   -- utility that displays "Dev | Menu" only when the optionKey is down
   if the optionKey is "Down" then
      return false
   else
      return "delete"
   end if
end disabled_Dev

getprop disabled_GitStatus [scriptObject]
   if project_IsActive ("lcw_GIT") is true then
      return false
   else
      return "delete"
   end if 
end disabled_GitStatus

getprop disabled_LoadGit
   if project_IsActive ("lcw_GIT") is true then
      return "delete"
   else
      return false
   end if 
end disabled_LoadGit


--> Global | GIT | Menu
-
on menu_DisplayGitStatus scriptObject
   put LocalArray ["sObject"] into scriptObject
   --
   display_GitStatus scriptObject
end menu_DisplayGitStatus

on menu_DisplayGistScripts
   display_Gists "Gist Scripts"
end menu_DisplayGistScripts

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_ShowStackLog scriptObject
   put LocalArray ["sObject"] into scriptObject
   --
   display_StackHistory scriptObject
end menu_ShowStackLog

on menu_StackHistory scriptObject
   put LocalArray ["sObject"] into scriptObject
   --
   display_StackHistory scriptObject
end menu_StackHistory

on _
end _

on menu_Search mTarget, menuChoice
   local pTreeMenuTitle, pTreeLineMenuTitle
   
   put the search_Term of me into searchTerm
   put lcw_Ask("Search log for string...", searchTerm) into searchTerm
   set the search_Term of me to searchTerm
   
   switch menuChoice
      case "Commit history"
         put git_SearchLog (searchTerm) into foundLog
         put git_LogLinkOutline (foundLog) into someOutline
         
         -- display_Lines foundLog
         put "git log --pretty=oneline -S:" && kwote(searchTerm) into someTitle
         display_Outline someOutline, someTitle, pTreeMenuTitle, pTreeLineMenuTitle
         put the result into treeView
         put the tree_Field of treeView into treeField
         set the menu_Controller ["Log | Menu"] of treeField to the long id of me
         break
      case "Search repository"
         put git_SearchRepository (searchTerm) into foundLog
         display_Lines foundLog
         put git_LogLinkOutline (foundLog) into someOutline
         put "git grep --text -i" && kwote(searchTerm) into someTitle
         display_Outline someOutline, someTitle, pTreeMenuTitle, pTreeLineMenuTitle
         put the result into treeView
         put the tree_Field of treeView into treeField
         set the menu_Controller ["Grep | Menu"] of treeField to the long id of me
         break
   end switch
end menu_Search


--> Dev | Menu | Props
-
/*
These no longer seem to be needed?

Global | Git | Line | Stack | Log | Menu | Props
*/

getprop back_Nums
   return "1,2,3,4,5,6"
end back_Nums

on menu_OtherStackLog scriptObject, someName
   put the name of stack someName into stackObject
   display_StackHistory stackObject
end menu_OtherStackLog

getprop some_Names
   return stack_ListNames()
end some_Names

getprop search_Term
   return the uOPN ["search_Term"] of me
end search_Term

setprop search_Term searchTerm
   set the uOPN ["search_Term"] of me to searchTerm
end search_Term

getprop stack_Hashs [mTarget]
   put the git_RelativeFile of mTarget into relativePath
   return git_ReverseFileHashes (relativePath)
end stack_Hashs

getprop back_Hashs [mTarget]
   put the script_RelativeFile of mTarget into relativePath
   return git_ReverseFileHashes (relativePath)
end back_Hashs

getprop back_Nums
   return "0,-,1,2,3,4,5,6,7,8,9"
end back_Nums
