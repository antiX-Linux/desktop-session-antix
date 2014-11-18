disp=${DISPLAY#:}
disp=${disp%.[0-9]}

#Desktop-session Directories
main_dts_dir="/etc/desktop-session";
user_dts_dir="$HOME/.desktop-session";
lib_dir="/usr/local/lib/desktop-session";
share_dir="/usr/share/desktop-session";

#Log File
log_file="$user_dts_dir/log";

#Desktop - Session Configuration
main_config="$main_dts_dir/desktop-session.conf";
user_config="$user_dts_dir/desktop-session.conf";
default_desktop_file="$user_dts_dir/default-desktop";

#Desktop-session scripts
first_run_script="$lib_dir/first-run-script"
desktop_session_logout="$lib_dir/desktop-session-logout";
desktop_session_restart="$lib_dir/desktop-session-restart";
desktop_session_exit_gui="$lib_dir/desktop-session-exit.py";
desktop_session_update_wm_menus="$lib_dir/desktop-session-update-wm-menus";

#Desktop-session startup scripts
main_startup_file="$main_dts_dir/startup";
user_startup_file="$user_dts_dir/startup";

#Conky Files
conky_dir="$HOME/.conky";

#Startup File Comparison 
main_compare_file="$main_dts_dir/file_compare";
user_compare_file="$user_dts_dir/file_compare";

#Process files
ppid_file="$user_dts_dir/ppid.$disp";
gpid_file="$user_dts_dir/startup-gpid.$disp";
icon_pid_file="$user_dts_dir/icon-pid.$disp";

#Trigger files
cycle_file="$user_dts_dir/cycle-wm.$disp";
desktop_file="$user_dts_dir/desktop-code.$disp";
restart_file="$user_dts_dir/restart.$disp";

#Resources
xmodmap_config="$HOME/.xmodmap";
xresources_config="$HOME/.Xresources";
user_xdg_autostart="$HOME/.config/autostart";
main_xdg_autostart="/etc/xdg/autostart";

#Xsessions
xs_dir="/usr/share/xsessions";

#Slim Config
slim_conf="/etc/slim.conf";
