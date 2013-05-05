//
//  DetailsViewController.m
//  Election Leaflets
//
//  Created by Lachlan Wright on 4/05/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import <hpple/TFHpple.h>
#import <hpple/XPathQuery.h>
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
@property (nonatomic, strong) UIView *scrollToView;

//Electorates
@property (nonatomic, strong) NSDictionary *electorates;

//Delivery times
@property (nonatomic, strong) NSDictionary *deliveryTimes;

//Political parties
@property (nonatomic, strong) NSDictionary *parties;

//Categores
@property (nonatomic, strong) NSDictionary *categories;

@end

@implementation DetailsViewController

@synthesize defaultTranscriptTextViewText;
@synthesize defaultTagsTextViewText;
@synthesize keyboardVisible;
@synthesize scrollToView;
@synthesize uploadKey;
@synthesize htmlData;
@synthesize electorates;
@synthesize deliveryTimes;
@synthesize parties;
@synthesize categories;

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    self.defaultTranscriptTextViewText = @"Enter a transcript of the main points/ first paragraph, note that this should be only what is actually on the leaflet, not your opinion of it...";
    self.defaultTagsTextViewText = @"Tags this leaflet (candidate name, town, policy name, etc)...";
    
    [self.leafletTitle setDelegate:self];
    [self.leafletTranscript setDelegate:self];
    [self.leafletPostcode setDelegate:self];
    [self.leafletTags setDelegate:self];
    [self.submitterName setDelegate:self];
    //[self.submitterEmail setDelegate:self];
    
    [self addLeftPaddingTo:self.leafletTitle];
    [self addLeftPaddingTo:self.leafletPostcode];
    [self addLeftPaddingTo:self.submitterName];
    [self addLeftPaddingTo:self.submitterEmail];
    
    [self setupElectorates];
    [self setupDeliveryTimes];
    [self setupParties];
    [self setupCategories];

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

- (void)setupElectorates
{
    NSMutableDictionary *mutableElectorates = [[NSMutableDictionary alloc] init];
    TFHpple *htmlDoc = [[TFHpple alloc] initWithHTMLData:self.htmlData];
    TFHppleElement *listOfElectorates = [htmlDoc searchWithXPathQuery:@"//select[@id='ddlConstituency']"][0];
    NSArray *elements = listOfElectorates.children;
    for (TFHppleElement *element in elements) {
        if (element.firstChild.content) {
            [mutableElectorates setObject:element.firstChild.content forKey:element.firstChild.content];
        }
    }
    self.electorates = [[NSDictionary alloc] initWithDictionary:mutableElectorates];
}

- (void)setupDeliveryTimes
{
    NSMutableDictionary *mutableDeliveryTimes = [[NSMutableDictionary alloc] init];
    TFHpple *htmlDoc = [[TFHpple alloc] initWithHTMLData:self.htmlData];
    TFHppleElement *listOfDeliveryTimes = [htmlDoc searchWithXPathQuery:@"//select[@id='ddlDelivered']"][0];
    NSArray *elements = listOfDeliveryTimes.children;
    for (TFHppleElement *element in elements) {
        if (element.firstChild.content) {
            [mutableDeliveryTimes setObject:element.firstChild.content forKey:[element.attributes objectForKey:@"value"]];
        }
    }
    self.deliveryTimes = [[NSDictionary alloc] initWithDictionary:mutableDeliveryTimes];
}

- (void)setupParties
{
    NSMutableDictionary *mutableParties = [[NSMutableDictionary alloc] init];
    TFHpple *htmlDoc = [[TFHpple alloc] initWithHTMLData:self.htmlData];
    TFHppleElement *listOfParties = [htmlDoc searchWithXPathQuery:@"//select[@id='ddlPartyBy']"][0];
    NSArray *elements = listOfParties.children;
    for (TFHppleElement *element in elements){
        if (element.firstChild.content) {
            [mutableParties setObject:element.firstChild.content forKey:[element.attributes objectForKey:@"value"]];
        }
    }
    self.parties = [[NSDictionary alloc] initWithDictionary:mutableParties];
}

- (void)setupCategories
{
    NSMutableDictionary *mutableCategories = [[NSMutableDictionary alloc] init];
    TFHpple *htmlDoc = [[TFHpple alloc] initWithHTMLData:self.htmlData];
    NSArray *listOfInputElements = [htmlDoc searchWithXPathQuery:@"//input[contains(@name,'chkCategory')]"];
    for (TFHppleElement *inputElement in listOfInputElements) {
        NSLog(@"%@",[inputElement.attributes objectForKey:@"value"]);
        NSString *queryString = [NSString stringWithFormat:@"//label[@for='chkCategory_%@']",[inputElement.attributes objectForKey:@"value"]];
        TFHppleElement *labelElement = [htmlDoc searchWithXPathQuery:queryString][0];
        NSLog(@"%@", labelElement.firstChild.content);
    }
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
    if (keyboardVisible) {
        [self scrollToTextInput:textView];
    } else {
        self.scrollToView = textView;
    }
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

#pragma mark - Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (keyboardVisible) {
        [self scrollToTextInput:textField];
    } else {
        self.scrollToView = textField;
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

- (void)keyboardDidShow:(NSNotification *)notification
{
    [self scrollToViewFollowingKeyboardChnage];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    [self scrollToViewFollowingKeyboardChnage];
}

- (void)scrollToViewFollowingKeyboardChnage
{
    if (self.scrollToView) {
        [self scrollToTextInput:self.scrollToView];
        self.scrollToView = nil;
    }
}

#pragma mark - Scroll to text field/view

- (void)scrollToTextInput:(UIView *)view
{
    
    //CGRect scrollToFrame = CGRectZero; //start with the bonds of the table view
    //scrollToFrame.size = [self.tableView contentSize];
    //scrollToFrame.origin = view.frame.origin; //set the origin to that of the first responder
    //scrollToFrame.origin.y -=30; //move up slightly to view the label associated with the field
    //[self.tableView scrollRectToVisible:scrollToFrame animated:YES]; //scroll to the new rect
    void (^action)(void) = ^{
        CGPoint newPoint = view.frame.origin;
        newPoint = [[view superview] convertPoint:newPoint toView:self.tableView];
        newPoint.x = 0;
        newPoint.y -= 30;
        self.tableView.contentOffset = newPoint;
    };
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:action
                     completion:nil];
    
}



@end
