//
//  DetailsViewController.m
//  Election Leaflets
//
//  Created by Lachlan Wright on 4/05/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import "DetailsViewController.h"
#import "LeafletDetailsCell.h"
#import "LeafletTagAndSubmitCell.h"
#import "JMMLeaflet.h"

@interface DetailsViewController ()

//List of categories which require the user to select one or more options from a list
@property (nonatomic, strong) NSArray *pickListCategories;

//Storage of the leaflet details that the user enters
@property (nonatomic, strong) JMMLeaflet *leafletDetails;

//Storage of the leaflet submitter's details
@property (nonatomic, strong) NSString *submitterName;
@property (nonatomic, strong) NSString *submitterEmail;

//Convienence properties for cell index paths
@property (nonatomic, strong) NSIndexPath *detailsCellIndexPath;
@property (nonatomic, strong) NSIndexPath *tagsAndSubmitterCellIndexPath;

@end

@implementation DetailsViewController

#pragma mark - Properties

- (JMMLeaflet *)leafletDetails
{
    if (!_leafletDetails) {
        _leafletDetails = [[JMMLeaflet alloc] init];
    }
    //Get the latest leaflet details
    LeafletDetailsCell *detailsCell = (LeafletDetailsCell *)[self.tableView cellForRowAtIndexPath:self.detailsCellIndexPath];
    _leafletDetails.title = detailsCell.leafletTitle.text;
    _leafletDetails.transcript = detailsCell.leafletTranscript.text;
    _leafletDetails.postcode = detailsCell.leafletPostcode.text;
    LeafletTagAndSubmitCell *tagAndSumbitCell = (LeafletTagAndSubmitCell *)[self.tableView cellForRowAtIndexPath:self.tagsAndSubmitterCellIndexPath];
    _leafletDetails.tags = tagAndSumbitCell.leafletTags.text;
    return _leafletDetails;
}

- (NSString *) submitterName
{
    LeafletTagAndSubmitCell *tagAndSumbitCell = (LeafletTagAndSubmitCell *)[self.tableView cellForRowAtIndexPath:self.tagsAndSubmitterCellIndexPath];
    _submitterName = tagAndSumbitCell.leafletSubmitterName.text;
    return _submitterName;
}

- (NSString *) submitterEmail
{
    LeafletTagAndSubmitCell *tagAndSumbitCell = (LeafletTagAndSubmitCell *)[self.tableView cellForRowAtIndexPath:self.tagsAndSubmitterCellIndexPath];
    _submitterEmail = tagAndSumbitCell.leafletSubmitterEmail.text;
    return _submitterEmail;
}

- (NSArray *) pickListCategories
{
    //The pick list categories and the choices associated with them will need to be extracted from the HTML
    //returned to the upload view controller after uploading the images, temp hard-coded below
    if (!_pickListCategories){
        _pickListCategories = @[@"Which electorate was the leaflet delivered to?",
                                @"When was the leaflet delivered?",
                                @"Which party is responsible for the leaflet?",
                                @"Which parties (if any) does the leaflet criticise?",
                                @"Which categories (if any) best describe this leaflet?"
                                ];
    }
    return _pickListCategories;
}

- (NSIndexPath *)detailsCellIndexPath
{
    if (!_detailsCellIndexPath){
        _detailsCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return _detailsCellIndexPath;
}

- (NSIndexPath *)tagsAndSubmitterCellIndexPath
{
    if (!_tagsAndSubmitterCellIndexPath) {
        _tagsAndSubmitterCellIndexPath = [NSIndexPath indexPathForRow:[self.pickListCategories count] + 1 inSection:0];
    }
    return _tagsAndSubmitterCellIndexPath;
}

#pragma mark - Initialisation

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.pickListCategories count] + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    NSString *pickListCellIdentifier = @"LeafletListPickCell";
    NSString *detailsCellIdentifier = @"LeafletDetailsCell";
    NSString *tagAndSubmitCellIdentifier = @"LeafletTagAndSubmit";
    if (indexPath.row == self.detailsCellIndexPath.row) {
        cellIdentifier = detailsCellIdentifier;
    } else if (indexPath.row == self.tagsAndSubmitterCellIndexPath.row){
        cellIdentifier = tagAndSubmitCellIdentifier;
    } else {
        cellIdentifier = pickListCellIdentifier;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell prepareForReuse];
    
    // Configure the cell...
    if (cellIdentifier == pickListCellIdentifier) {
        cell.textLabel.text = [self.pickListCategories objectAtIndex:indexPath.row - 1];
    } else if (cellIdentifier == detailsCellIdentifier) {
        ((LeafletDetailsCell *)cell).leafletTranscript.delegate = self;
    } else if (cellIdentifier == tagAndSubmitCellIdentifier) {
        ((LeafletTagAndSubmitCell *)cell).leafletTags.delegate = self;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.detailsCellIndexPath.row  || indexPath.row == self.tagsAndSubmitterCellIndexPath.row) {
        return 320.0f;
    } else {
        return 44.0f;
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView setSelectedRange:NSMakeRange(0, textView.text.length)];
    [textView setText:@""];
    textView.textColor = [UIColor blackColor];
//    CGRect scrollToFrame = textView.frame; //start with the text view frame
//    scrollToFrame.origin.y = scrollToFrame.origin.y - 30; //move up to include label
//    scrollToFrame.size.height = scrollToFrame.size.height - 30; //move size up by the same amount
//    [self.tableView scrollRectToVisible:scrollToFrame animated:YES]; //scroll to the new rect
//    Scroll methods above are overridden by the table auto scrolling from the UITableViewController's viewWillAppear method
}

@end
