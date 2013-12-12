nRF Loader for iOS
==================

nRF Loader is an app that uploads new firmware to a device running Nordic
Semiconductor's DFU service. A number of binary files are embedded in this app
which can be written to any device advertising the appropriate service. 

By default, the app starts with the binary selection screen, where you can
select one of the embedded binaries. After having done this, you can choose a
target device, which will list all BLE devices nearby advertising Nordic
Semiconductor's DFU service. Having selected a device, you can press the Upload
button as soon as the device is Ready, which will start the actual upload
process. 

If you open a binary file with nRF Loader, you will be brought directly to the
TargetSelection view. 

The app only works with binary files, but converting for example a hex-file to
the needed binary file should be trivial, using external tools. 


Code structure
--------------
There are a total of 4 view controllers in this app, 3 for controlling upload
and 1 for viewing the built-in help text. The help view controller embeds a
WebView that shows help.html. 

The 3 that control the upload are: 
- one for app selection
- one for target device selection, 
- one for initiating the upload and showing progress

These 3 pass an instance of DFUController among them, setting properties of it
and finally starting the transfer by calling startTransfer on it. 

It is the TargetSelectionViewController that interfaces with CBCentralManager
and scans for and connects to the target device. The DFUController object does
its own service discovery, and is mostly self-contained except for its firmware
URL and CBPeripheral object. 

The DFUController is a state machine, and all actions towards the DFUTarget are
done through the DFUTargetAdapter class.


Embedded binaries
-----------------
The app embeds the Heart Rate application and the Runner's Speed and Cadence
applications from the nRF51 SDK, version 4.4.2, in binary format. Both are
built for the Development Kit. To add other binaries, you should include the
binary file in your build, and list it in the JSON-file. Doing so, the
AppSelectionViewController will pick it up automatically. 


Integrating DFU in a custom app
-------------------------------
To integrate DFU functionality in a custom app, the only components you'll need
are the DFUController and the DFUTargetAdapter. You'll have to supply a NSURL
to the new application in a binary format. You will also have to discover the
wanted device yourself, and set the peripheral property of the DFUController
appropriately, connect to it and then call the didConnect method. After this,
you can call startTransfer to actually do the upload. By implementing a
DFUControllerDelegate, you can get progress and error information.


Support
-------
Support for this app should go through the regular channels, either Nordic's
Developer Zone at https://devzone.nordicsemi.com or in the support portal at
https://www.nordicsemi.com/support/. 

