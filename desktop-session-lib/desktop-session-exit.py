#!/usr/bin/env python

import gtk
import gettext
import os
import sys
#Variables
ButtonWidth = 150
ButtonHeight = 120
ICONS = "/usr/share/icons/antiX-1"
#End

class mainWindow():
    def build_button_box(self,image,text):
       #Taken from lagopus's antixcc.py script from START marker line to END marker line,
       #slightly modified to meet needs of this script
       # START #######################################
        self.button_box = gtk.HBox(False, 2)
        self.button_box.set_spacing(8)
        button_label = gtk.Label(_(text))

        pixbuf = gtk.gdk.pixbuf_new_from_file(image)
        button_icon = gtk.Image()
        button_icon.set_from_pixbuf(pixbuf)
                
        button_icon.set_size_request(-1, 60)
        self.button_box.pack_start(button_icon, False)
        self.button_box.pack_start(button_label, False)

        # needed, otherwise even calling show_all on the notebook won't
        # make the hbox contents appear.
        self.button_box.show_all()
        # END #######################################
    
    def button_clicked(self, widget, command):
        os.system(command)
        sys.exit()
    
    def build_button(self,image,text,command,side):
        self.build_button_box(image,text)
        Button = gtk.Button()
        Button.add(self.button_box)
        Button.connect("clicked", self.button_clicked, command)
        #Button.set_size_request(ButtonWidth, ButtonHeight)
        if side == "left":
            self.leftbox.pack_start(Button,  expand=True, fill=True, padding=0)
        elif side == "right":
            self.rightbox.pack_start(Button,  expand=True, fill=True, padding=0)
        else:
            self.mainbox.pack_start(Button,  expand=True, fill=True, padding=0)
        Button.show()

    def __init__(self):
        window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        window.set_title("Exit Session")
        window.connect("destroy", lambda w: gtk.main_quit())
        window.set_position(gtk.WIN_POS_CENTER)
        window.set_default_size(400,0)
        
        self.mainbox = gtk.VBox()
        window.add(self.mainbox)
        self.mainbox.show()
        
        self.packbox = gtk.HBox()
        self.mainbox.pack_start(self.packbox)
        self.packbox.show()
        
        self.leftbox = gtk.VBox()
        self.packbox.pack_start(self.leftbox)
        self.leftbox.show()
        
        self.rightbox = gtk.VBox()
        self.packbox.pack_start(self.rightbox)
        self.rightbox.show()

        self.build_button(ICONS+"/lock.svg","Lock Screen","desktop-session-exit -L","left")
        self.build_button(ICONS+"/upgrade.svg","Restart Session","desktop-session-exit -R","left") 
        self.build_button(ICONS+"/reboot.svg","Reboot","desktop-session-exit -r","left")
        
        self.build_button(ICONS+"/logout.svg","Log Out","desktop-session-exit -l","right")
        self.build_button(ICONS+"/suspend.svg","Suspend","desktop-session-exit -S","right")
        self.build_button(ICONS+"/shutdown.svg","Shutdown","desktop-session-exit -s","right")
        
        window.show()

gettext.install(domain = "desktop-session-exit", unicode   = False, codeset   = 'utf-8')
mainWindow()
gtk.main()
