#include <pybind11/pybind11.h>
#include <pybind11/embed.h>   // <- для встроенного Python
#include <libusb-1.0/libusb.h>
#include <iostream>
#include <stdexcept>
#include <string>
#include <fstream>

namespace py = pybind11;

class DeviceUSB {
public:
    libusb_context* ctx;
    libusb_device_handle* handle;

    DeviceUSB() : ctx(nullptr), handle(nullptr) {
        if (libusb_init(&ctx) < 0)
            throw std::runtime_error("Failed to init libusb");
    }

    ~DeviceUSB() {
        if (handle) libusb_close(handle);
        libusb_exit(ctx);
    }

    void connect() {
        libusb_device** devs;
        ssize_t cnt = libusb_get_device_list(ctx, &devs);
        for (ssize_t i = 0; i < cnt; i++) {
            libusb_device* dev = devs[i];
            libusb_device_descriptor desc;
            libusb_get_device_descriptor(dev, &desc);
            if (desc.idVendor == 0x05AC) { // Apple VID
                if (libusb_open(dev, &handle) == 0) {
                    std::cout << "Connected to Apple device!" << std::endl;
                    break;
                }
            }
        }
        libusb_free_device_list(devs, 1);
        if (!handle)
            throw std::runtime_error("No Apple device found.");
    }

    // Заглушки для UDID / model / iOS
    std::string get_udid() { return "FAKE-UDID-123456"; }
    std::string get_model() { return "iPhone 4"; }
    std::string get_ios_version() { return "6.1.6"; }
    int get_battery() { return 82; }
    int get_storage_used() { return 8; }
    int get_storage_free() { return 8; }

    // Mix code: file_send прямо через встроенный Python
    void file_send(const std::string& local_path) {
        py::gil_scoped_acquire gil; // обязательно

        // Встроенный Python код
        py::exec(R"(
import os
from pymobiledevice3.lockdown import LockdownClient
from pymobiledevice3.services.afc import AFCClient

def send_file(local_path):
    if not os.path.exists(local_path):
        raise FileNotFoundError(local_path)

    lockdown = LockdownClient()
    afc = AFCClient(lockdown)

    filename = os.path.basename(local_path)
    remote_path = f"/Documents/{filename}"

    with open(local_path, "rb") as f:
        afc.write_file(remote_path, f.read())

    print(f"✅ File sent to iOS: {remote_path}")
)");

        py::object main = py::module::import("__main__");
        py::object send_file = main.attr("send_file");
        send_file(local_path);
    }
};

PYBIND11_MODULE(allsync_core, m) {
    py::class_<DeviceUSB>(m, "DeviceUSB")
        .def(py::init<>())
        .def("connect", &DeviceUSB::connect)
        .def("get_udid", &DeviceUSB::get_udid)
        .def("get_model", &DeviceUSB::get_model)
        .def("get_ios_version", &DeviceUSB::get_ios_version)
        .def("get_battery", &DeviceUSB::get_battery)
        .def("get_storage_used", &DeviceUSB::get_storage_used)
        .def("get_storage_free", &DeviceUSB::get_storage_free)
        .def("file_send", &DeviceUSB::file_send); // встроенный Python backend
}
