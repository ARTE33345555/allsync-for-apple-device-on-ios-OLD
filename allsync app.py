import tkinter as tk
from tkinter import messagebox, filedialog
from allsync_core import DeviceUSB


# ================= AUTH DIALOG =================
def auth_dialog(parent):
    win = tk.Toplevel(parent)
    win.title("AllSync wants to make changes")
    win.geometry("420x260")
    win.resizable(False, False)
    win.configure(bg="#5b5b5b")
    win.grab_set()

    tk.Label(
        win, text="🔒", font=("Helvetica Neue", 42),
        bg="#5b5b5b"
    ).pack(pady=(20, 5))

    tk.Label(
        win, text="AllSync",
        font=("Helvetica Neue", 16, "bold"),
        fg="white", bg="#5b5b5b"
    ).pack()

    tk.Label(
        win,
        text=(
            "AllSync requires authorization to access\n"
            "this device.\n\n"
            "Enter your password to allow this."
        ),
        font=("Helvetica Neue", 12),
        fg="#e0e0e0", bg="#5b5b5b",
        justify="center"
    ).pack(pady=10)

    pwd = tk.Entry(win, show="•", width=28)
    pwd.pack(pady=6)
    pwd.focus()

    result = {"ok": False}

    def confirm():
        # ТВОЯ логика пароля
        if pwd.get() == "1234":
            result["ok"] = True
            win.destroy()
        else:
            messagebox.showerror("Authorization Failed", "Incorrect password")

    btns = tk.Frame(win, bg="#5b5b5b")
    btns.pack(pady=10)

    tk.Button(btns, text="Cancel", width=10, command=win.destroy).pack(side="left", padx=6)
    tk.Button(btns, text="OK", width=10, command=confirm).pack(side="left", padx=6)

    win.wait_window()
    return result["ok"]


# ================= MAIN APP =================
root = tk.Tk()
root.withdraw()

# ---- AUTH FIRST ----
if not auth_dialog(root):
    root.destroy()
    exit()

# ---- DEVICE CONNECT ----
try:
    device = DeviceUSB()
    device.connect()
except Exception as e:
    messagebox.showerror("Device Error", str(e))
    root.destroy()
    exit()

root.deiconify()
root.title("AllSync")
root.geometry("960x600")
root.configure(bg="#f6f6f6")


# ================= UI =================
sidebar = tk.Frame(root, bg="#e9e9e9", width=200)
sidebar.pack(side="left", fill="y")

main = tk.Frame(root, bg="#f6f6f6")
main.pack(side="left", fill="both", expand=True, padx=20, pady=20)

info_label = tk.Label(
    main, font=("Helvetica Neue", 12),
    bg="#f6f6f6", justify="left"
)
info_label.pack(anchor="nw")

def show_info():
    info_label.config(text=f"""
Model: {device.get_model()}
iOS: {device.get_ios_version()}
Battery: {device.get_battery()}%
Used: {device.get_storage_used()} GB
Free: {device.get_storage_free()} GB
""")

def show_stub(name):
    info_label.config(text=f"{name} section (ready)")

sections = [
    ("Apps", lambda: show_stub("Apps")),
    ("Cydia", lambda: show_stub("Cydia")),
    ("Flash device", lambda: show_stub("Flash device")),
    ("Info", show_info),
    ("Music", lambda: show_stub("Music")),
    ("Video/Movie", lambda: show_stub("Video")),
    ("Photo", lambda: show_stub("Photo")),
]

for name, cmd in sections:
    tk.Button(
        sidebar, text=name, anchor="w",
        bg="#e9e9e9", relief="flat",
        padx=10, command=cmd
    ).pack(fill="x", pady=2)


# ---- Drag & Drop area (mock, file dialog) ----
drop = tk.Label(
    main, text="Drag & Drop files here",
    bg="#e0e0e0", width=50, height=10, relief="ridge"
)
drop.pack(anchor="nw", pady=20)

def add_files(e):
    files = filedialog.askopenfilenames()
    if files:
        messagebox.showinfo("Files", f"{len(files)} files added")

drop.bind("<Button-1>", add_files)

show_info()
root.mainloop()
