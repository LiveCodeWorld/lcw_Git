script "Global | GIT | Changes to be committed | Modified | File | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Changes to be committed | Modified | File | Menu
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


--> Global | GIT | Changes to be committed | Modified | File | Menu
-
on menu_CommitFile arrayView
   -- do above
end menu_CommitFile

on _
end _

on menu_RevealInFinder arrayView
   put _getFile (arrayView) into someFile
   finder_Reveal someFile
end menu_RevealInFinder


--> Deps
-
