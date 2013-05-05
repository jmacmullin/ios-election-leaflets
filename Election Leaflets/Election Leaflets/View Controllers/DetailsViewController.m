//
//  DetailsViewController.m
//  Election Leaflets
//
//  Created by Lachlan Wright on 4/05/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import "DetailsViewController.h"
#import "JMMLeaflet.h"

@interface DetailsViewController ()

//List of categories which require the user to select one or more options from a list
@property (nonatomic, strong) NSArray *pickListCategories;

//Default text for the text view items
@property (nonatomic, strong) NSString *defaultTranscriptTextViewText;
@property (nonatomic, strong) NSString *defaultTagsTextViewText;

//Keyboard state
@property (nonatomic) BOOL keyboardVisible;

@end

@implementation DetailsViewController

@synthesize defaultTranscriptTextViewText;
@synthesize defaultTagsTextViewText;
@synthesize keyboardVisible;

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
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.defaultTranscriptTextViewText = @"Enter a transcript of the main points/ first paragraph, note that this should be only what is actually on the leaflet, not your opinion of it...";
    self.defaultTagsTextViewText = @"Tags this leaflet (candidate name, town, policy name, etc)...";
    
    [self.leafletTranscript setDelegate:self];
    [self.leafletTags setDelegate:self];
    
    [self addLeftPaddingTo:self.leafletTitle];
    [self addLeftPaddingTo:self.leafletPostcode];
    [self addLeftPaddingTo:self.submitterName];
    [self addLeftPaddingTo:self.submitterEmail];

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
    return [self.pickListCategories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"LeafletListPickCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell prepareForReuse];
    
    // Configure the cell...
    cell.textLabel.text = [self.pickListCategories objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test" message:self.leafletTranscript.text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
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
    if ([textView.text isEqualToString:self.defaultTagsTextViewText] || [textView.text isEqualToString:self.defaultTranscriptTextViewText]) {
        [textView setSelectedRange:NSMakeRange(0, textView.text.length)];
        [textView setText:@""];
    }
    textView.textColor = [UIColor blackColor];
    CGRect scrollToFrame = textView.frame; //start with the text view frame
    scrollToFrame.origin.y += [textView superview].frame.origin.y - 30; //move up to include label
    scrollToFrame.size.height += 30; //move size up by the same amount
    [self.tableView scrollRectToVisible:scrollToFrame animated:YES]; //scroll to the new rect
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]){
        if (textView.frame.origin.y < [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]].frame.origin.y){
            textView.text = self.defaultTranscriptTextViewText;
        } else {
            textView.text = self.defaultTagsTextViewText;
        }
        [textView setTextColor:[UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0f]];
    }
}

#pragma mark - Text field view setup
- (void)addLeftPaddingTo:(UITextField *)textField
{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, textField.frame.size.height)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

#pragma mark - Keyboard handling
- (void)hideKeyboard
{
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (!self.keyboardVisible)
    {
        CGRect keyboardFrame = [self retrieveFrameFromNotification:notification];
        CGSize delta = CGSizeMake(0, keyboardFrame.size.height);
        [self notifySizeChanged:delta notification:notification];
        self.keyboardVisible = YES;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (self.keyboardVisible)
    {
        CGRect keyboardFrame = [self retrieveFrameFromNotification:notification];
        CGSize delta = CGSizeMake(0, -keyboardFrame.size.height);
        [self notifySizeChanged:delta notification:notification];
        self.keyboardVisible = NO;
    }
}

- (CGRect)retrieveFrameFromNotification:(NSNotification *)notification
{
    CGRect keyboardRect;
    [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardRect];
    return keyboardRect;
}

- (void)notifySizeChanged:(CGSize)delta notification:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    
    UIViewAnimationOptions curve;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
    
    NSTimeInterval duration;
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
    //duration not used, due to black box appearing at top of screen during keyboard hiding...
    
    void (^action)(void) = ^{
        CGRect updatedFrame = self.tableView.frame; //retrieve existing
        updatedFrame.size.height += delta.height; //change the height
        self.tableView.frame = updatedFrame; //change the frame size
    };
    
    [UIView animateWithDuration:0.0
                          delay:0.0
                        options:(curve)
                     animations:action
                     completion:nil];
}



@end
