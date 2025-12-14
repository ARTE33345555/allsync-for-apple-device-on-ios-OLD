#include <pybind11/pybind11.h>
#include <libusb-1.0/libusb.h>
#include <iostream>
#include <stdexcept>
#include <string>

namespace py = pybind11;

class DeviceUSB {
public:
    libusb_context* ctx;
    libusb_device_handle* handle;

    DeviceUSB() : ctx(nullptr), handle(nullptr) {
        if (libusb_init(&ctx) < 0) throw std::runtime_error("Failed to init libusb");
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

        if (!handle) throw std::runtime_error("No Apple device found.");
    }

    std::string get_udid() { return "FAKE-UDID-123456"; } // пока заглушка
    std::string get_model() { return "iPhone 4"; }
    std::string get_ios_version() { return "6.1.6"; }
    int get_battery() { return 82; }
    int get_storage_used() { return 8; }
    int get_storage_free() { return 8; }
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
        .def("get_storage_free", &DeviceUSB::get_storage_free);
}
