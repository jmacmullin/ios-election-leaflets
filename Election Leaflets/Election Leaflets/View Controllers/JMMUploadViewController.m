//
//  JMMUploadViewController.m
//  Election Leaflets
//
//  Created by Jake MacMullin on 24/04/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking/AFHTTPClient.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "JMMUploadViewController.h"
#import "UploadPictureCell.h"
#import "DetailsViewController.h"

@interface JMMUploadViewController ()
//Images
@property (nonatomic, strong) NSMutableArray *capturedImages;

//Toolbar actions
- (IBAction)photoLibraryAction:(id)sender;
- (IBAction)cameraAction:(id)sender;
- (IBAction)uploadImagesAction:(id)sender;

//Upload Button
@property (weak, nonatomic) IBOutlet UIButton *uploadImagesButton;

//Uploading In Progress View
@property (strong, nonatomic) UIAlertView *uploadingInProgressView;

@end

@implementation JMMUploadViewController

@synthesize imagePickerController;
@synthesize capturedImages;
@synthesize delegate;
@synthesize uploadingInProgressView;
@synthesize uploadedImagesKey;

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
    [[self.uploadImagesButton superview] setHidden:YES]; //hide the upload button until pictures are selected
}

- (void)showUploadButton
{
    
    // Set the button Text Color
    [self.uploadImagesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.uploadImagesButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    // Set default backgrond color
    [self.uploadImagesButton setBackgroundColor:[UIColor blackColor]];
    
    // Draw a custom gradient
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = self.uploadImagesButton.bounds;
    btnGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f] CGColor],
                          nil];
    [self.uploadImagesButton.layer insertSublayer:btnGradient atIndex:0];
    
    // Round button corners
    CALayer *btnLayer = [self.uploadImagesButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    // Apply a 1 pixel, black border around button
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.uploadImagesButton superview] setHidden:NO];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Actions

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

- (IBAction)uploadImagesAction:(id)sender {
    //For testing only
    //[self performSegueWithIdentifier:@"imagesUploadedSegue" sender:self];
    [self displayUploadingInProgressMessage];
    [self startImageUploadRequests];
}

#pragma mark Netowrking for Upload of Images

-(void) startImageUploadRequests
{
    NSURL *url = [NSURL URLWithString:@"http://www.electionleaflets.org.au/"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:@"addupload" parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //Extract the view state and call uploadImagesToUrlwithViewStateMethod
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSRange extractionRange = [htmlString rangeOfString:@"\"_viewstate\" value=\""];
        extractionRange.location = extractionRange.location + extractionRange.length; //start from the end of the search string
        extractionRange.length = 88; //assume view state is always 88 characters long
        NSString *viewState = [htmlString substringWithRange:extractionRange];
        [self uploadImagesToUrl:url withViewState:viewState];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error occured whilst making initial HTTP request");
        [self.uploadingInProgressView dismissWithClickedButtonIndex:0 animated:YES];
        [self displayUploadErrorMessage];
    }];
    [httpClient enqueueHTTPRequestOperation:operation];
}

-(void) uploadImagesToUrl:(NSURL *)imageUploadURL withViewState:(NSString *)viewState
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:imageUploadURL];
    NSDictionary *params = @{@"_is_postback": @"1",
                             @"_viewstate": viewState,
                             @"_postback_command": @"",
                             @"_postback_arguement":@"",
                             @"MAX_FILE_SIZE": @"10000000000"
                             };
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"addupload" parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        for (UIImage *image in self.capturedImages){
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            NSString *imageNumberString = [NSString stringWithFormat:@"%d", [self.capturedImages indexOfObject:image]+1];
            NSString *imageName = [@"uplFile_" stringByAppendingString:imageNumberString];
            NSString *imageFilename = [[@"image" stringByAppendingString:imageNumberString] stringByAppendingString:@".jpg"];
            [formData appendPartWithFileData:imageData name:imageName fileName:imageFilename mimeType:@"image/jpeg"];
        }
    }];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.uploadedImagesResponse = responseObject;
        NSString *locationString = [[operation.response allHeaderFields] objectForKey:@"x-url"];
        NSRange keyRange = [locationString rangeOfString:@"key="];
        keyRange.location = keyRange.location + keyRange.length;
        keyRange.length = [locationString length] - keyRange.location;
        self.uploadedImagesKey = [locationString substringWithRange:keyRange];
        NSLog(@"Sucess Occurred");
        [self.uploadingInProgressView dismissWithClickedButtonIndex:0 animated:YES];
        [self performSegueWithIdentifier:@"imagesUploadedSegue" sender:self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure occured on POST request");
        [self.uploadingInProgressView dismissWithClickedButtonIndex:0 animated:YES];
        [self displayUploadErrorMessage];
    }];
    [httpClient enqueueHTTPRequestOperation:operation];
}

#pragma mark Networking Messages to User

-(void) displayUploadErrorMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Error"
                                                    message:@"An error occured, please try again."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void) displayUploadingInProgressMessage
{
    self.uploadingInProgressView = [[UIAlertView alloc] initWithTitle:@"\nUploading Images\nPlease Wait..."
                                                message:nil
                                               delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles: nil];
    [self.uploadingInProgressView show];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(self.uploadingInProgressView.bounds.size.width / 2, self.uploadingInProgressView.bounds.size.height - 50);
    [indicator startAnimating];
    [self.uploadingInProgressView addSubview:indicator];
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
        [[self.uploadImagesButton superview] setHidden:YES]; //no images selected therefore hide upload button
        return 1; //the instructions cell will be displayed
    } else {
        [self showUploadButton]; //images selected therefore show upload button
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
    if ([self.capturedImages count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.capturedImages removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
    }
}

#pragma mark - Prepare for Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"imagesUploadedSegue"]) {
        DetailsViewController *destinationVC = (DetailsViewController *)[segue destinationViewController];
        destinationVC.uploadKey = self.uploadedImagesKey;
        destinationVC.htmlData = self.uploadedImagesResponse;
    }
}

@end