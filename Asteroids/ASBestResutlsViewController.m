//
//  ASBestResutlsViewController.m
//  Asteroids
//
//  Created by Irina Didkovskaya on 12/16/13.
//  Copyright (c) 2013 Irina. All rights reserved.
//

#import "ASBestResutlsViewController.h"
#import "ASResultsManager.h"
#import "Result.h"

@interface ASBestResutlsViewController ()
@property (nonatomic, strong) NSArray *resultList;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
- (IBAction)closeViewController:(id)sender;
@end

@implementation ASBestResutlsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.resultList = [[ASResultsManager sharedMaperManager] getResultsFromCoreData];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    Result *result = self.resultList[indexPath.row];
    cell.textLabel.text = result.playerName;
    cell.detailTextLabel.text = [result.score stringValue];
    
    
    return cell;
}

#pragma mark Actions
- (IBAction)closeViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
