import sys
import os

if sys.platform == "win32":
    import win32api
    import win32con

    drives = win32api.GetLogicalDriveStrings()
    drives = drives.split('\000')[:-1]

    cdrom_drives = [drive for drive in drives if win32api.GetDriveType(drive) == win32con.DRIVE_CDROM]

    if cdrom_drives:
        print("Deploying Cupholder", cdrom_drives[0])
        os.startfile(cdrom_drives[0])
    else:
        print("No cupholder found.")
else:
    # Assuming a Linux-based system
    if os.path.exists("/dev/cdrom"):
        print("cupholder found at /dev/cdrom")
        os.system("gnome-open /dev/cdrom")
        time.sleep(30)
    else:
        print("No cupholder found.")
        time.sleep(30)