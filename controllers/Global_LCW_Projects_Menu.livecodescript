script "Global | LCW | Projects | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | LCW | Projects | Menu
type: controller
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.

display_Data localProjects, "Local Projects", "LCW"
put the result into displayView
--
repeat for each line projectName in localProjects
   display_Spin projectName, displayView
   put the result into lineNum
   --
   if git_ProjectIsClean (projectName) is true then
      set the line_Colour [lineNum] of displayView to "green"
   else
      set the line_Colour [lineNum] of displayView to "red"
   end if
end repeat
*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- called first
   pass menu_Target
end menu_Target

getprop menu_CheckTarget [displayView]
   -- use to do initialisation
   put the title_Text of displayView into LocalArray ["titleText"]
   return true
end menu_CheckTarget

getprop checked_GithubProjects
   return _CheckBoolean (the params)
end checked_GithubProjects

getprop checked_NotOnGithub
   return LocalArray ["titleText"] = "Not On Github"
end checked_NotOnGithub

getprop checked_MissingLocalRepos
   return LocalArray ["titleText"] = "Missing Local Repos"
end checked_MissingLocalRepos

getprop checked_LocalProjects
   return _CheckBoolean (the params)
end checked_LocalProjects

private function _CheckBoolean theParams
   put _GetParamTitle (theParams) into someTitle
   put LocalArray ["titleText"] = someTitle into isChecked
   return isChecked
end _CheckBoolean

private command _SetIndex someIndex, theParams, displayView
   put _GetParamTitle (theParams) into someTitle -- "Not on Github"
   set the displayed_Index [someTitle] of displayView to someIndex
end _SetIndex

private function _GetParamTitle theParams
   set the itemdelimiter to "_"
   get item 2 of (word 1 of theParams)
   put text_SplitCaps (it) into paramTitle
   return paramTitle
end _GetParamTitle


--> Global | LCW | Projects | Menu
-
on menu_CreateNewProject
   project_AskCreate
end menu_CreateNewProject

on _
end _

on menu_LocalProjects displayView
   display_LcwProjectList
end menu_LocalProjects

on menu_GithubProjects displayView
   put github_ListOrgRepos() into someIndex
   --
   _SetIndex someIndex, the params, displayView
end menu_GithubProjects

on _
end _

on menu_NotOnGithub displayView
   put github_ListNotOnGithub() into someIndex
   --
   _SetIndex someIndex, the params, displayView
end menu_NotOnGithub

on menu_MissingLocalRepos displayView
   put github_ListMissingLocalRepos() into someIndex
   --
   _SetIndex someIndex, the params, displayView
end menu_MissingLocalRepos

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_LocalProjects displayView
   put env_ListLocalProjects() into someIndex
   --
   _SetIndex someIndex, the params, displayView
end menu_LocalProjects



--> Deps
-
