import tkinter as tk
from tkinter import ttk, filedialog, messagebox
from PIL import Image, ImageTk  # для обоев
from py_ios_device import list_devices

# -------------------
# GUI Setup
# -------------------
root = tk.Tk()
root.title("AllSync")
root.geometry("900x600")

# Вкладки
tab_control = ttk.Notebook(root)
books_tab = ttk.Frame(tab_control)
music_tab = ttk.Frame(tab_control)
photos_tab = ttk.Frame(tab_control)
apps_tab = ttk.Frame(tab_control)
cydia_tab = ttk.Frame(tab_control)
firmware_tab = ttk.Frame(tab_control)

tab_control.add(books_tab, text='Books')
tab_control.add(music_tab, text='Music')
tab_control.add(photos_tab, text='Photos')
tab_control.add(apps_tab, text='Apps')
tab_control.add(cydia_tab, text='Cydia')
tab_control.add(firmware_tab, text='Firmware')
tab_control.pack(expand=1, fill='both')

# Левая панель — устройства
device_frame = tk.Frame(root, width=200, bg="#e0e0e0")
device_frame.place(x=0, y=30, width=200, height=570)
tk.Label(device_frame, text="Connected Devices", bg="#e0e0e0", font=("Arial", 12, "bold")).pack(pady=10)
device_listbox = tk.Listbox(device_frame)
device_listbox.pack(fill="both", expand=True, padx=10, pady=10)

# Правая панель — информация устройства
info_frame = tk.Frame(root, bg="white")
info_frame.place(x=210, y=30, width=680, height=500)

# Заглушка для обоев
wallpaper_label = tk.Label(info_frame, bg="grey")
wallpaper_label.place(x=0, y=0, width=680, height=300)

# Информация о устройстве
battery_label = tk.Label(info_frame, text="Battery: --%", bg="white")
battery_label.place(x=10, y=310)
ios_label = tk.Label(info_frame, text="iOS: --", bg="white")
ios_label.place(x=10, y=340)
memory_label = tk.Label(info_frame, text="Memory: --", bg="white")
memory_label.place(x=10, y=370)

# -------------------
# Статус внизу
# -------------------
status_frame = tk.Frame(root, height=30, bg="#d0d0d0")
status_frame.pack(side="bottom", fill="x")
status_label = tk.Label(status_frame, text="No device selected", bg="#d0d0d0")
status_label.pack(side="left", padx=10)

# -------------------
# Функции работы с py-ios-device
# -------------------
connected_devices = []

def refresh_devices():
    global connected_devices
    device_listbox.delete(0, tk.END)
    connected_devices = list_devices()
    for dev in connected_devices:
        device_listbox.insert(tk.END, f"{dev.udid} - {dev.product_type}")

def show_device_info(event):
    selection = device_listbox.curselection()
    if not selection:
        return
    dev = connected_devices[selection[0]]
    status_label.config(text=f"Selected: {dev.udid}")
    
    # Информация
    battery_label.config(text=f"Battery: {dev.battery_level}%")
    ios_label.config(text=f"iOS: {dev.product_version}")
    memory_label.config(text=f"Memory: {dev.device_capacity}GB")
    
    # Копируем обои и показываем
    wallpaper_path = f"{dev.udid}_wallpaper.png"
    try:
        dev.transfer_file('/var/mobile/Library/SpringBoard/HomeScreenBackground.jpg', wallpaper_path)
        img = Image.open(wallpaper_path)
        img = img.resize((680, 300), Image.ANTIALIAS)
        img_tk = ImageTk.PhotoImage(img)
        wallpaper_label.config(image=img_tk)
        wallpaper_label.image = img_tk
    except Exception as e:
        print(f"Cannot load wallpaper: {e}")

# -------------------
# Кнопки
# -------------------
refresh_btn = tk.Button(device_frame, text="Refresh Devices", command=refresh_devices)
refresh_btn.pack(pady=5)

# -------------------
# Инициализация
# -------------------
refresh_devices()
device_listbox.bind("<<ListboxSelect>>", show_device_info)

root.mainloop()
