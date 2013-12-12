//
//  TargetViewController.m
//  nRF Loader
//
//  Created by Ole Morten on 10/8/13.
//  Copyright (c) 2013 Nordic Semiconductor. All rights reserved.
//

#import "AppSelectionViewController.h"
#import "TargetSelectionViewController.h"

#import "AppInfoCell.h"

@interface AppSelectionViewController ()
@property NSArray *binaries;
@end

@implementation AppSelectionViewController
@synthesize dfuController = _dfuController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSError *e;
    NSData *jsonData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"binary_list" withExtension:@"json"]];
    NSDictionary *d = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&e];
    self.binaries = [d objectForKey:@"binaries"];

    self.binariesTableView.delegate = self;
    self.binariesTableView.dataSource = self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.binariesTableView deselectRowAtIndexPath:self.binariesTableView.indexPathForSelectedRow animated:NO];
    
    self.dfuController = [[DFUController alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showTargetSelection"])
    {
        NSDictionary *binary = [self.binaries objectAtIndex:self.binariesTableView.indexPathForSelectedRow.row];
        
        NSURL *firmwareURL = [[NSBundle mainBundle] URLForResource:[binary objectForKey:@"filename"] withExtension:[binary objectForKey:@"extension"]];
        [self.dfuController setFirmwareURL:firmwareURL];
        
        TargetSelectionViewController *vc = (TargetSelectionViewController *) segue.destinationViewController;
        [vc setDfuController:self.dfuController];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.binaries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppInfoCell"];
    
    NSDictionary *binary = [self.binaries objectAtIndex:indexPath.row];
    cell.nameLabel.text = [binary objectForKey:@"title"];
    cell.sizeLabel.text = [NSString stringWithFormat:@"%@ bytes", [binary objectForKey:@"size"]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0;
}
@end
