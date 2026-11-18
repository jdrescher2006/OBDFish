# OBDFish

OBDFish is a native Sailfish OS application for reading OBD-II data from cars through a **classic Bluetooth ELM327** diagnostic adapter. It can display supported live parameters and diagnostic trouble codes (DTCs).

This repository is maintained by [ExPLIT](https://github.com/explit28) and incorporates the work of [poetaster/OBDFish](https://github.com/poetaster/OBDFish), [deepbluev7/OBDFish](https://github.com/deepbluev7/OBDFish) and the [original OBDFish project by Jens Drescher](https://github.com/jdrescher2006/OBDFish).

## Sailfish OS 5.1 / 5.2 compatibility

The current code uses **BluezQt / BlueZ** to discover Bluetooth devices and register a Serial Port Profile (SPP) connection. This replaces the QtBluetooth-based transport in older OBDFish revisions.

| Area | Status |
| --- | --- |
| Source compatibility with Sailfish OS 5.x | Modernized BluezQt code present |
| RPM build for Sailfish OS 5.2 | Automated test build available in GitHub Actions |
| Sailfish OS 5.1 build | Needs explicit build verification |
| Jolla C2 and Jolla 2 (JP-2601) | On-device tests pending |
| Classic Bluetooth ELM327 with a vehicle | On-vehicle tests pending |
| Bluetooth Low Energy (BLE) and Wi-Fi OBD adapters | Not supported by the SPP transport |

A successful RPM build **does not establish** that Bluetooth discovery, SPP negotiation, OBD commands, or vehicle compatibility works on a particular device. See [TESTING.md](TESTING.md) for the community test procedure.

## Community test release (0.95-3)

**[Download OBDFish 0.95-3 test RPMs](https://github.com/explit28/OBDFish/releases/tag/0.95-3)**

This is a **pre-release for community testing**, not a production-stable or vehicle-verified version. RPMs are built against the Sailfish OS 5.2.0.15 SDK for **aarch64, armv7hl and i486**. Sailfish OS 5.1 builds and runtime behavior still require testing.

### Changes in 0.95-3

- Correct the yellow initialization indicator's invalid QML property expression (reported as `MainPage.qml:414 TypeError`).
- Guard device disconnects and saved-adapter lookups against a missing Bluetooth device reference (reported as `disconnectFromDevice of null`).
- Stop initialization timers and reset command state when the Bluetooth connection disappears.
- Ignore duplicate device-connect taps while a connection is pending.
- Reject an overlapping serial profile socket and guard reads/writes when the socket is unavailable.
- Add focused connection diagnostics. These changes **do not prove that the reported native crash is fixed**; further on-device and vehicle tests are required.

The fixes are based in part on reports by Sailfish community members in the [OBDFish forum discussion](https://forum.sailfishos.org/t/about-the-obdfish-app/11335?page=2).

### Earlier community test build

[OBDFish 0.95-2](https://github.com/explit28/OBDFish/releases/tag/v0.95-test1) remains available for comparing connection behavior. The original Poetaster `0.95` release is kept separately and has RPM filenames containing `0.94-1`; those files were mirrored unchanged.

Do not use the app while driving or erase vehicle trouble codes during testing. Report failures following [TESTING.md](TESTING.md).

## Installation

Download an RPM for your phone's architecture from [Releases](https://github.com/explit28/OBDFish/releases). For development snapshots, use a successful [GitHub Actions test build](https://github.com/explit28/OBDFish/actions) and extract the RPM from its artifact ZIP.

**Important:** The upstream `0.95` release assets retain RPM filenames containing `0.94-1`. This reflects upstream packaging; check the exact release page instead of relying only on the filename.

Pair the classic Bluetooth ELM327 adapter in Sailfish OS Bluetooth settings. Open OBDFish, allow the requested Bluetooth permission, scan for devices and select the adapter. Start the vehicle ignition if required for ECU data. Do not use the app while driving.

## Build from source

This project uses qmake, Sailfish Silica, Qt DBus and `KF5BluezQt`. It requires a Sailfish SDK build target providing `kf5bluezqt-bluez5-devel`.

```sh
sfdk tools list
sfdk config --push target SailfishOS-5.1.0.11-aarch64
sfdk build
```

Replace the example target with an installed target appropriate for your device. Output RPMs appear under `RPMS/`. For 5.2, select a 5.2 build target. The [test-build workflow](.github/workflows/test-build.yml) also runs a Sailfish OS 5.2 container build.

## Troubleshooting

- **No device listed:** Confirm the ELM327 adapter is powered, Bluetooth is enabled and the adapter is paired in Sailfish OS settings. Restart scanning. Some adapters advertise generic names.
- **Connection fails:** Verify it is a *classic Bluetooth* SPP adapter; BLE-only dongles cannot connect using this implementation. The current profile code sets an RFCOMM channel explicitly; compatibility may vary between adapters.
- **Connected but no OBD data:** Turn on ignition, check that the vehicle supports the requested PIDs and try reconnecting. A successful Bluetooth connection does not imply ECU communication.
- **Blank or inaccessible log:** The optional diagnostic log is written to the system Documents directory as `obd_log.txt`. The app requires Documents permission.

To capture startup diagnostics, run the app from a terminal:

```sh
harbour-obdfish 2>&1 | tee ~/obdfish-terminal.log
```

Note that direct terminal launches can differ from Sailjail-launched application behavior. Test normal launcher startup as well. Redact vehicle IDs, Bluetooth addresses and other personal data before sharing logs.

## Community testing

We particularly welcome reports from Sailfish OS 5.1 / 5.2 users with a vehicle and a classic ELM327 adapter. Report the device model, exact OS version, adapter, RPM filename and reproducible results in [GitHub Issues](https://github.com/explit28/OBDFish/issues). See [TESTING.md](TESTING.md).

## Credits

- Jens Drescher — original OBDFish author
- deepbluev7 — BluezQt port and dynamic-page work
- Mark Washeim (poetaster) — packaging, Sailjail and release maintenance
- Kimmo Lindholm — Messagebox component
- Thomas Kolb — Plotwidget component
- Richard Rondu — historical QtConnectivity backport

See the repository history for individual contributions.

## License

GNU General Public License v3 or later. See [LICENSE](LICENSE).

OBDFish is experimental diagnostic software. Do not clear vehicle error codes without the vehicle owner's consent and an understanding of the consequences.
