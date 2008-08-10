;; @file       acorn.nu
;; @discussion Nu components of NuAcorn, the Nu Acorn plug-in
;;
;; @copyright  Copyright (c) 2008 Tim Burks, Neon Design Technology, Inc.
;;
;;   Licensed under the Apache License, Version 2.0 (the "License");
;;   you may not use this file except in compliance with the License.
;;   You may obtain a copy of the License at
;;
;;       http://www.apache.org/licenses/LICENSE-2.0
;;
;;   Unless required by applicable law or agreed to in writing, software
;;   distributed under the License is distributed on an "AS IS" BASIS,
;;   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;;   See the License for the specific language governing permissions and
;;   limitations under the License.

(load "console")
(set $console ((NuConsoleWindowController alloc) init))

;; -------- example 1 / start ----------

;; here's one way to register a plugin, using the
;; Flying Meat SimplePlugin as an example
(class SPGrayscalePlugin is NSObject
     
     (- (void) willRegister:(id) pluginManager is
        (pluginManager addFilterMenuTitle:"Grayscale"
             withSuperMenuTitle:"Nu"
             target:self
             action:"convert:userObject:"
             keyEquivalent:""
             keyEquivalentModifierMask:0
             userObject:nil))
     
     (- (void) didRegister is nil)
     
     (- (id) convert:(id) image userObject:(id) userObject is
        (set filter (CIFilter filterWithName:"CIColorMonochrome"))
        (filter setValue:image forKey:"inputImage")
        (set color (CIColor colorWithRed:0.5 green:0.5 blue:0.5))
        (filter setDefaults)
        (filter setValue:color forKey:"inputColor")
        (filter setValue:1 forKey:"inputIntensity")
        (filter valueForKey:"outputImage"))
     
     (- (id) worksOnShapeLayers:(id) userObject is NO))

;; register the plug-in
(set $s ((SPGrayscalePlugin alloc) init))
($s willRegister:pluginManager)
($s didRegister)

;; -------- example 1 / end ----------

;; -------- example 2 / start --------

;; but if we define this class and the following macro,
;; we can add plugins more concisely.
(class NuAcornPlugin is NSObject
     (ivars)
     
     (- (id) initWithFilterMenuTitle:(id) filterMenuTitle superMenuTitle:(id) superMenuTitle body:(id) body is
        (super init)
        (set @filterMenuTitle filterMenuTitle)
        (set @superMenuTitle superMenuTitle)
        (set @body body)
        self)
     
     (- (void) willRegister:(id) pluginManager is
        (pluginManager addFilterMenuTitle:@filterMenuTitle
             withSuperMenuTitle:@superMenuTitle
             target:self
             action:"processImage:withUserObject:"
             keyEquivalent:""
             keyEquivalentModifierMask:0
             userObject:nil))
     
     (- (id) processImage:(id) image withUserObject:(id) userObject is
        (eval (cons 'progn @body)))
     
     (- (id) worksOnShapeLayers:(id) userObject is NO))

(macro plugin
     (set __filterMenuTitle (margs car))
     (NSLog "menu title #{__filterMenuTitle}")
     
     (if (eq ((margs cdr) car) 'under)
         (then
              (NSLog "under")
              (set __superMenuTitle (((margs cdr) cdr) car))
              (set __body (((margs cdr) cdr) cdr) cdr))
         (else
              (set __superMenuTitle nil)
              (set __body (margs cdr))))
     
     (NSLog "menu title #{__superMenuTitle}")
     (NSLog "body: #{(__body stringValue)}")
     
     (set __plugin ((NuAcornPlugin alloc) initWithFilterMenuTitle:__filterMenuTitle superMenuTitle:__superMenuTitle body:__body))
     (unless $plugins (set $plugins (array)))
     ($plugins addObject:__plugin)
     (__plugin willRegister:pluginManager)
     (__plugin didRegister))

(plugin "Make Grayscale (Nu)" under "Color"
        (set filter (CIFilter filterWithName:"CIColorMonochrome"))
        (filter setValue:image forKey:"inputImage")
        (set color (CIColor colorWithRed:0.5 green:0.5 blue:0.5))
        (filter setDefaults)
        (filter setValue:color forKey:"inputColor")
        (filter setValue:1 forKey:"inputIntensity")
        (filter valueForKey:"outputImage"))

(plugin "Add Grey Border"
        (set nsimage (image NSImage))
        (nsimage lockFocus)
        ((NSColor grayColor) set)
        (set path (NSBezierPath bezierPathWithRect:(list 0.5 0.5 (- ((nsimage size) 0) 1) (- ((nsimage size) 1) 1))))
        (path setLineWidth:10)
        (path stroke)
        (nsimage unlockFocus)
        (CIImage imageWithData:(nsimage TIFFRepresentation)))

;; -------- example 2 / end ----------

;; you can use this function to load a plugin from the command line
(function open-file ()
     (set openDialog (NSOpenPanel openPanel))
     (openDialog setCanChooseFiles:YES)
     (openDialog setCanChooseDirectories:NO)
     (if (== (openDialog runModalForDirectory:nil file:nil types:(array "nu")) NSOKButton)
         ((openDialog filenames) each:
          (do (filename)
              (load filename)))))

;; but since mac users like to have GUIs for everything, here's a "load plugin" dialog

(class NuLoader is NSObject
     (- (void) openFile:(id) sender is (open-file)))

(load "menu")

(((NSApplication sharedApplication) mainMenu) addItem:
 (build-menu '(menu "Nu" ("Load Plugin from File..." action:"openFile:" target:(set $nuloader ((NuLoader alloc) init)))) "Nu"))



