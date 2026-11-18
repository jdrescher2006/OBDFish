# OBDFish community test checklist

This build is intended for volunteer testing with **classic Bluetooth ELM327 (RFCOMM/SPP)** adapters on Sailfish OS 5.1 and 5.2. Testing does not require modifying vehicle settings or clearing any diagnostic codes.

## Before testing

- Park the vehicle safely; do not operate the phone while driving.
- Note the exact Sailfish OS version, phone model and adapter name/model.
- Pair the adapter in system Bluetooth settings. Enable the ignition when necessary.
- Download the correct architecture RPM from [Releases](https://github.com/explit28/OBDFish/releases) or a successful [Actions build](https://github.com/explit28/OBDFish/actions).
- Make sure the RPM is from the intended GitHub release or run. Upstream 0.95 RPMs still have `0.94-1` in their filenames.

## Tests

1. Launch the app from its icon. Note permission prompts or startup failures.
2. Scan for devices. Does the adapter appear? Does cancelling and restarting a scan work?
3. Connect. Does OBDFish show the adapter / ELM327 version?
4. Check whether supported PIDs are discovered.
5. Verify at least one live parameter, such as engine RPM or coolant temperature (if supported).
6. Open the error-code page; verify it opens and displays current status. **Do not erase codes.**
7. Disconnect and reconnect. Quit and reopen the app; check whether settings remain.
8. Optionally enable diagnostics and inspect `Documents/obd_log.txt`. Sharing this file is voluntary.

## Regression checks for 0.95-3

These tests cover failures discussed in the Sailfish OS [OBDFish thread](https://forum.sailfishos.org/t/about-the-obdfish-app/11335?page=2).

1. Connect an adapter and watch the yellow initialization indicator. Check that the terminal no longer reports `MainPage.qml:414: TypeError`.
2. Disconnect or switch off the adapter during initialization and wait for the command timeout. Check that the UI returns to the disconnected state without `disconnectFromDevice of null` or a crash.
3. Tap an adapter entry repeatedly during connection. Confirm that the app does not initiate overlapping connections or show `Operation already in progress`.
4. Connect, disconnect, and reconnect several times. Watch for native crashes, memory allocator errors or stuck progress bars.
5. If possible, repeat with [0.95-2](https://github.com/explit28/OBDFish/releases/tag/v0.95-test1) to compare behavior. Record exactly which version and adapter were used.

These checks are not proof of crash resolution until repeated successfully on real devices.

## Report results

Create a [new issue](https://github.com/explit28/OBDFish/issues/new) containing:

- Phone model:
- Sailfish OS version:
- CPU architecture (`uname -m`):
- RPM source (release tag or Actions run URL):
- Classic Bluetooth ELM327 adapter model:
- Pairing / discovery / connection:
- ELM initialization / live PIDs / DTC page:
- Disconnect and reconnect:
- Error messages (redacted):
- Expected vs. actual result:

Please remove VINs, Bluetooth MAC addresses, and other identifiable vehicle information before attaching logs.

## Terminal diagnostics

With the app closed, launch:

```sh
harbour-obdfish 2>&1 | tee ~/obdfish-terminal.log
```

This saves terminal output while displaying it. The in-app diagnostic log is separate. Normal icon launches use Sailjail and may behave differently from terminal launches.
