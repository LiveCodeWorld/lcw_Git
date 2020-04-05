script "Global_Github_Menu"
--> MetaData
-
license: GPLv3
name: Global_Github_Menu
type: controller
version: 0.1


--> Global | Github | Menu
-
on menu_LaunchGithub displayView, lcwRepo
   -- put LocalArray ["shortFolder"] into lcwRepo -- lazy
   github_Launch lcwRepo
end menu_LaunchGithub

on menu_DisplayGithubRepoArray
   put LocalArray ["projectName"] into repoName
   put github_FetchRepoArray (repoName) into repoArray
   --
   display_Array repoArray, repoName
end menu_DisplayGithubRepoArray

on menu_DisplayGithubOrgArray
   put github_FetchOrgRepoAray() into reposArray
   --
   display_Array reposArray, "github_FetchOrgRepoAray()"
end menu_DisplayGithubOrgArray

on _
end _

on menu_AddProjectWiki projectName
   put projectName & ".wiki" into wikiProjectName
   
   answer folder "Select a folder containing a project..."
   put it into projectFolder
   if it is empty then exit to top
   if projectFolder ends with ".wiki" is false then
      answer warning "Not a GitHub wiki project"
      exit to top
   end if
   
   put projectFolder into projectArray ["projectFolder"]
   put "wiki" into projectArray ["projectType"]
   library_StoreProjectArray wikiProjectName, projectArray
   
   display_LcwProjectList
end menu_AddProjectWiki

on menu_CreateLibraryPages projectName
   -- put projectName & ".wiki" into wikiProjectName
   -- put library_FetchProjectFolder (wikiProjectName) into wikiFolder
   put LocalArray ["wikiFolder"] into wikiFolder
   put LocalArray ["displayView"] into displayView
   put the view_Index of displayView into stackNames
   repeat for each line stackName in stackNames
      put wikiFolder & stackName & ".md" into wikiPageFile
      if there is a file wikiPageFile then
         breakpoint
      else
         put the github_WikiPage of stack stackName into wikiMarkdown
         put "file:" & wikiPageFile into someURL
         put wikiMarkdown into url someURL
      end if
   end repeat
end menu_CreateLibraryPages

