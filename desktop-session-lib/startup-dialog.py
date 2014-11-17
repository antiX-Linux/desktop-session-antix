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
    
    def button_clicked(self, widget, command, internal):
        if internal == 0 :
            internal
        else:
            os.system(command)
        sys.exit()
    
    def build_button(self,image,text,command,internal):
        self.build_button_box(image,text)
        Button = gtk.Button()
        Button.add(self.button_box)
        Button.connect("clicked", self.button_clicked, command, internal)
        #Button.set_size_request(ButtonWidth, ButtonHeight)
        self.mainbox.pack_start(Button,  expand=True, fill=True, padding=0)
        Button.show()

    def __init__(self):
        window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        window.set_resizable(False)
        window.stick()
        window.set_keep_below(True)
        window.set_decorated(False)
        window.set_skip_taskbar_hint(True)
        window.set_skip_pager_hint(False)
        window.set_accept_focus(False)
        window.connect("destroy", lambda w: gtk.main_quit())
        window.set_position(gtk.WIN_POS_CENTER)
        window.set_default_size(400,0)
        
        self.mainbox = gtk.HBox()
        window.add(self.mainbox)
        self.mainbox.show()
        
        self.build_button(ICONS+"/upgrade.svg","View Docs","desktop-defaults-run -b file:///usr/local/share/docs/antiX/index.html",1) 
        self.build_button(ICONS+"/shutdown.svg","Close Docs",lambda w: gtk.main_quit(),0) 
        
        window.show()

gettext.install(domain = "desktop-session-startup-window", unicode   = False, codeset   = 'utf-8')
mainWindow()
gtk.main()
