script "Global | GIT | Changes not staged for commit | Modified | File | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Changes not staged for commit | Modified | File | Menu
type: controller
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Init
-


--> Global | GIT | Changes not staged for commit | Modified | File | Menu
-
on menu_ReloadStack arrayView
   -- we are not (yet) checking for backscript and frontscript use
   put _getFile (arrayView) into someFile
   put the short name of stack someFile into stackName
   put stackName is among the lines of thestacksinuse into isUsed
   revert stack stackName
   if isUsed is true then start using stack stackName
end menu_ReloadStack

getprop disabled_ReloadStack [arrayView]
   put _getFile (arrayView) into someFile
   if exists (stack someFile) then
      put stack_ListEditedNames() into editedStacks
      put the short name of stack someFile into stackName
      if stackName is among the lines of editedStacks then
         -- let's not reload stacks that need saving first
         return true
      else
         return false
      end if
   else
      return true
   end if
end disabled_ReloadStack

on menu_AddFile arrayView
   put _getFile (arrayView) into someFile
   git_AddFile someFile
   refresh
end menu_AddFile

on menu_AddThenCommitFile arrayView
   -- just for fun
   put _getFile (arrayView) into someFile
   git_AddFile someFile
   git_CommitFile someFile
   refresh
end menu_AddThenCommitFile


--> Deps
-
