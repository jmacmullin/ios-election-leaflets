//
//  JMMUploadViewController.m
//  Election Leaflets
//
//  Created by Jake MacMullin on 24/04/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import "JMMUploadViewController.h"
#import "UploadPictureCell.h"

@interface JMMUploadViewController ()
//Images
@property (nonatomic, strong) NSMutableArray *capturedImages;

//Toolbar actions
- (IBAction)photoLibraryAction:(id)sender;
- (IBAction)cameraAction:(id)sender;

//Table View
@property (nonatomic, strong) UITableView *originalTableView;

@end

@implementation JMMUploadViewController

@synthesize imagePickerController;
@synthesize capturedImages;
@synthesize delegate;
@synthesize originalTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self!=nil) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self!=nil) {
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"upload_icon_selected"]
                      withFinishedUnselectedImage:[UIImage imageNamed:@"upload_icon"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // if camera is not on this device, don't show the camera button
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.capturedImages = [NSMutableArray array];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Toolbar Actions

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    if ([self.capturedImages count] >= 8)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Maximum Images"
                                                        message:@"You have reached the maximum number (8) of images."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        self.imagePickerController.sourceType = sourceType;
        [self presentModalViewController:self.imagePickerController animated:YES];
    }
}

- (IBAction)photoLibraryAction:(id)sender
{
	[self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)cameraAction:(id)sender
{
    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
}

#pragma mark UIImagePickerController Delegate

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.capturedImages addObject:[info valueForKey:UIImagePickerControllerOriginalImage]]; //add new image to list of images
    [self dismissViewControllerAnimated:YES completion:^(void){}]; //dismiss the view controller
    [self.tableView reloadData];
    //[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:^(void){}]; //dismiss the view controller
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    if (self.capturedImages!=nil) {
        count = [self.capturedImages count];
    }
    if (count == 0) {
        return 1; //the instructions cell will be displayed
    } else {
        return count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Add the instructions if required
    if ([self.capturedImages count] == 0) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"InstructionsCell"];
        UIView *cellContentView = [cell viewWithTag:0];
        UIImageView *instructionsView;
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            //instructions view image if no camera is available
            instructionsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instructions_nocamera.png"]];
        } else {
            //instructions view image if camera is available
            instructionsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instructions.png"]];
        }
        [instructionsView setContentMode:UIViewContentModeTopLeft]; //no scaling image bottom is blank
        CGRect newFrame = instructionsView.frame; //get the old frame
        newFrame.size = cellContentView.frame.size; //set the frame size
        instructionsView.frame = newFrame; //set the frame back
        [cellContentView addSubview:instructionsView]; //add the instructions image view
        return cell;
    }
    
    //Cell by identifier
    static NSString *CellIdentifier = @"UploadPictureCell";
    UploadPictureCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    [cell prepareForReuse];
    
    //Set the image view
    UIImage *uploadedPicture = [self.capturedImages objectAtIndex:indexPath.row];
    [cell updateImage:uploadedPicture];
    
    //Set the label text
    UILabel *uploadedPictureLabel = cell.uploadedPictureLabel;
    uploadedPictureLabel.text = [@"Image #" stringByAppendingString:[NSString stringWithFormat:@"%d", indexPath.row+1]];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.capturedImages removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
    }
}

@end