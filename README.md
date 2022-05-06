
Install Guide
====
<br><br>
Install Git
* https://git-scm.com/
  * Install

Install Make *[will be automatically added to Path]*
  * https://sourceforge.net/projects/ezwinports/files/make-4.3-without-guile-w32-bin.zip/download
    *  merge into "Git/mingw64/" (no replace / skip duplicates)

Install Python *[will be automatically added to Path]*
  * https://www.python.org/
    *  Install
  
Install Pillow
  * Run in Command Line: `py -m pip install Pillow`

Install cc65 (+ add to Path)
  * http://cc65.github.io/cc65/
    * Windows Snapshot (you only need cc65.exe &
ld65.exe) [to Dir]

Install BizHawk (+ add to Path)
  * https://github.com/TASEmulators/BizHawk/releases/download/2.6.1/BizHawk-2.6.1-win-x64.zip
    * All Files [to Dir]

Install Zip and Unzip (+ add to Path)
  * https://fossies.org/windows/misc/zip300xn.zip/ 
    * zip.exe [to Dir]
  * https://fossies.org/windows/misc/unz600xn.exe/ 
    * unzip.exe [to Dir]

Install Atom Portable
  * https://github.com/atom/atom/tree/v1.60.0
    * All Files [to Dir]
  
    * clone repository
    * close Atom<br><br>
    * copy .atom Folder from atom-preset.zip [to Dir]
  
    * duplicate "atom-build-make.lnk" as "atom-build-make-p.lnk" in same folder [in repo Dir]
    * change "Start in" Path of "atom-build-make-p.lnk" to Project Directory
  
    * start Atom
  
\<Optional\> Install Jetbrains Mono
  * https://www.jetbrains.com/de-de/lp/mono/
    * Extract and Install "/fonts/ttf/JetBrainsMono-Thin.ttf"




---
How to add a Folder to Path in Windows 10
====

https://stackoverflow.com/questions/44272416/how-to-add-a-folder-to-path-environment-variable-in-windows-10-with-screensho

add the Folders to your User Path on the top (NOT the System Path on the bottom) 

---
Folder Structure 
====
[IMPORTANT: no spaces in any path]
<br><br><br>
SNESProgramming (root)

  * atom
    * portable
      * atom.exe, ...               <download>
    * .atom
      * config.cson, ...            <copy from Repo>
    
    
  * cc65 [!]
    * cc65.exe                      <download>
    * ld65.exe                      <download>
    
    
  * emulators
    * BizHawk [!]
      * EmuHawk.exe, ...            <download>
      
      
  * projects
    * SNES-Test-Project-1
      * makefile, ...               <full repo>
    
    
  * zip [!]
    * unzip.exe                     <download>
    * zip.exe                       <download>


<br><br>
*[!] Folder in "Path"

---
MORE INFO: "https://github.com/pinobatch/nrom-template/"