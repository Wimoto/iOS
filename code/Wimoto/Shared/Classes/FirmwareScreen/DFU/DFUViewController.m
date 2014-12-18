//
//  DFUViewController.m
//  nRF Toolbox
//
//  Created by Aleksander Nowakowski on 10/01/14.
//  Copyright (c) 2014 Nordic Semiconductor. All rights reserved.
//

#import "DFUViewController.h"
#import "Utility.h"

@interface DFUViewController ()

@property (strong, nonatomic) Sensor *sensor;
@property (strong, nonatomic) Firmware *firmware;

/*!
 * This property is set when the device has been selected on the Scanner View Controller.
 */
@property (strong, nonatomic) CBPeripheral *selectedPeripheral;
@property DFUOperations *dfuOperations;
@property NSURL *selectedFileURL;
@property NSURL *softdeviceURL;
@property NSURL *bootloaderURL;
@property NSURL *applicationURL;
@property NSUInteger selectedFileSize;

@property (weak, nonatomic) IBOutlet UILabel *deviceName;

@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *fileSize;

@property (weak, nonatomic) IBOutlet UILabel *uploadStatus;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIView *uploadPane;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UILabel *fileType;

@property BOOL isTransferring;
@property BOOL isTransfered;
@property BOOL isTransferCancelled;
@property BOOL isConnected;
@property BOOL isErrorKnown;
@property BOOL isSelectedFileZipped;

- (IBAction)uploadPressed;

@end

@implementation DFUViewController

@synthesize deviceName;
@synthesize selectedPeripheral;
@synthesize fileName;
@synthesize fileSize;
@synthesize uploadStatus;
@synthesize progress;
@synthesize progressLabel;
@synthesize uploadButton;
@synthesize uploadPane;
@synthesize selectedFileURL;

- (id)initWithSensor:(Sensor *)sensor andFirmware:(Firmware *)firmware {
    self = [super init];
    if (self) {
        _sensor = sensor;
        _firmware = firmware;
        
        _dfuOperations = [[DFUOperations alloc] initWithDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [self onFileSelected:[NSURL URLWithString:_firmware.fileURL]];

    CBPeripheral *peripheral = _sensor.peripheral;
    selectedPeripheral = peripheral;
    deviceName.text = peripheral.name;
    [_dfuOperations connectDevice:peripheral];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)uploadPressed {
    if (self.isTransferring) {
        [_dfuOperations cancelDFU];
    }
    else {
        [self performDFU];
    }
}

- (void)performDFU {
    dispatch_async(dispatch_get_main_queue(), ^{
        uploadStatus.hidden = NO;
        progress.hidden = NO;
        progressLabel.hidden = NO;
        uploadButton.enabled = NO;
    });
    [_dfuOperations performDFUOnFile:selectedFileURL firmwareType:APPLICATION];
}

- (void)clearUI {
    selectedPeripheral = nil;
    deviceName.text = @"DEFAULT DFU";
    uploadStatus.text = @"waiting ...";
    uploadStatus.hidden = YES;
    progress.progress = 0.0f;
    progress.hidden = YES;
    progressLabel.hidden = YES;
    progressLabel.text = @"";
    [uploadButton setTitle:@"Upload" forState:UIControlStateNormal];
    uploadButton.enabled = NO;
}

- (void)enableUploadButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (selectedPeripheral && self.selectedFileSize > 0 && self.isConnected) {
            uploadButton.enabled = YES;
        }
        else {
            NSLog(@"cant enable Upload button");
        }

    });
}

#pragma mark File Selection Delegate

- (void)onFileSelected:(NSURL *)url {
    NSLog(@"onFileSelected");
    selectedFileURL = url;
    if (selectedFileURL) {
        NSLog(@"selectedFile URL %@",selectedFileURL);
        NSString *selectedFileName = [[url path]lastPathComponent];
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        self.selectedFileSize = fileData.length;
        NSLog(@"fileSelected %@",selectedFileName);
        
        //get last three characters for file extension
        NSString *extension = [selectedFileName substringFromIndex: [selectedFileName length] - 3];
        NSLog(@"selected file extension is %@",extension);
        if ([extension isEqualToString:@"zip"]) {
            NSLog(@"this is zip file");
            self.isSelectedFileZipped = YES;
        }
        else {
            self.isSelectedFileZipped = NO;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            fileName.text = selectedFileName;
            fileSize.text = [NSString stringWithFormat:@"%d bytes", self.selectedFileSize];
            [self enableUploadButton];
        });
    }
    else {
        [Utility showAlert:@"Selected file not exist!"];
    }
}


#pragma mark DFUOperations delegate methods

- (void)onDeviceConnected:(CBPeripheral *)peripheral {
    NSLog(@"onDeviceConnected %@",peripheral.name);
    self.isConnected = YES;
    [self enableUploadButton];
}

- (void)onDeviceDisconnected:(CBPeripheral *)peripheral {
    NSLog(@"device disconnected %@",peripheral.name);
    self.isTransferring = NO;
    self.isConnected = NO;
    
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        [self clearUI];
        if (!self.isTransfered && !self.isTransferCancelled && !self.isErrorKnown) {
            [Utility showAlert:@"The connection has been lost"];
        }
        self.isTransferCancelled = NO;
        self.isTransfered = NO;
        self.isErrorKnown = NO;
    });
}

- (void)onDFUStarted {
    NSLog(@"onDFUStarted");
    self.isTransferring = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        uploadButton.enabled = YES;
        [uploadButton setTitle:@"Cancel" forState:UIControlStateNormal];
        NSString *uploadStatusMessage = @"Uploading...";
        uploadStatus.text = uploadStatusMessage;
    });
}

- (void)onDFUCancelled {
    NSLog(@"onDFUCancelled");
    self.isTransferring = NO;
    self.isTransferCancelled = YES;
}

- (void)onSoftDeviceUploadStarted {
    NSLog(@"onSoftDeviceUploadStarted");
}

- (void)onSoftDeviceUploadCompleted {
    NSLog(@"onSoftDeviceUploadCompleted");
}

- (void)onBootloaderUploadStarted {
    NSLog(@"onBootloaderUploadStarted");
    dispatch_async(dispatch_get_main_queue(), ^{
        uploadStatus.text = @"uploading bootloader ...";
    });
    
}

- (void)onBootloaderUploadCompleted {
    NSLog(@"onBootloaderUploadCompleted");
}

- (void)onTransferPercentage:(int)percentage {
    NSLog(@"onTransferPercentage %d",percentage);
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        progressLabel.text = [NSString stringWithFormat:@"%d %%", percentage];
        [progress setProgress:((float)percentage/100.0) animated:YES];
    });    
}

- (void)onSuccessfulFileTranferred {
    NSLog(@"OnSuccessfulFileTransferred");
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isTransferring = NO;
        self.isTransfered = YES;
        NSString* message = [NSString stringWithFormat:@"%u bytes transfered in %u seconds", _dfuOperations.binFileSize, _dfuOperations.uploadTimeInSeconds];
        [Utility showAlert:message];
    });
}

- (void)onError:(NSString *)errorMessage {
    NSLog(@"OnError %@",errorMessage);
    self.isErrorKnown = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [Utility showAlert:errorMessage];
        [self clearUI];
    });
}

@end