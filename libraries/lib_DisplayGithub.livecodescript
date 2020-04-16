script "lib_DisplayGithub"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_DisplayGithub
type: library
version: 0.1

/*Some help*/


--> Working on
-


--> Display | Events
-
on mouseDoubleUp_GitHub displayView, sdaf
   put the params
end mouseDoubleUp_GitHub


--> Display | GitHub
-
command display_GithubProjects pOrgName
   put "Github Repos" into displayStackLabel
   if pOrgName is empty then
      put "LiveCodeWorld" into pOrgName
   end if
   --
   put "mouseDoubleUp_GitHub" into mDoubleUp
   put "Global | Github | Menu" into titleMenu
   put "Global | Github | Line | Menu" into lineMenu
   
   -- same as github_ListOrgRepos (pOrgName) but we can now store githubOrgRepoAray
   put github_FetchOrgRepoAray (pOrgName) into githubOrgRepoAray
   repeat for each key repoNum in githubOrgRepoAray
      put githubOrgRepoAray [repoNum]["name"] into repoName
      put repoName & CR after orgRepoNames
   end repeat
   delete char -1 of orgRepoNames
   sort orgRepoNames
   --
   put display_FindView (displayStackLabel, pOrgName) into displayView
   --
   if exists (displayView) is true then
      set the view_Index of displayView to orgRepoNames
   else
      display_Lines orgRepoNames, pOrgName, mDoubleUp, displayStackLabel, true
      put the result into displayView
      --
      set the title_Menu of displayView to titleMenu
      set the line_Menu of displayView to lineMenu
   end if
   --
   set the github_OrgRepoAray of displayView to githubOrgRepoAray
   --
   return displayView
end display_GithubProjects

command display_GitHubInfo repoName
   put github_FetchRepoArray (repoName) into repoArray
   display_Array repoArray
end display_GitHubInfo



--> Deps
-
