;;
;; Nukefile for NuAcorn, the Nu plug-in for the Acorn image-editing tool.
;;  for more on Acorn, see: http://flyingmeat.com/acorn
;;
;; tasks:
;;  * nuke		- builds the plugin
;;  * nuke install	- builds and installs the plugin in a user's local Application Support directory
;;  * nuke uninstall	- removes the plugin from a user's local Application Support directory
;;  * nuke clean	- removes build files
;;  * nuke clobber	- removes build files and the NuAcorn.acplugin bundle
;;

;; source files
(set @m_files     (filelist "^objc/.*\.m$"))
(set @nu_files 	  (filelist "^nu/.*nu$"))
(set @frameworks  '("Cocoa" "Nu"))

;; bundle descriptors
(set @bundle "NuAcorn")
(set @bundle_identifier "nu.programming.acorn")

(compilation-tasks)
(bundle-tasks)

(task "clobber" => "clean" is
      (system "rm -rf #{@bundle}.bundle #{@bundle}.acplugin"))

(task "default" => "bundle")

(set INSTALLDIR ("~/Library/Application Support/Acorn/Plug-Ins" stringByExpandingTildeInPath))

(task "install" => "bundle" is
      (SH "rm -rf #{@bundle}.acplugin")
      (SH "mv #{@bundle}.bundle #{@bundle}.acplugin")
      (SH "rm -rf '#{INSTALLDIR}/#{@bundle}.acplugin'")
      (SH "cp -r #{@bundle}.acplugin '#{INSTALLDIR}'"))

(task "uninstall" is
      (SH "rm -rf '#{INSTALLDIR}/#{@bundle}.acplugin'"))
