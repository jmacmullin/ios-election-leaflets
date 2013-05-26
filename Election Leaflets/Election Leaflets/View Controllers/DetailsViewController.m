//
//  DetailsViewController.m
//  Election Leaflets
//
//  Created by Lachlan Wright on 4/05/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import <AFNetworking/AFHTTPClient.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <hpple/TFHpple.h>
#import <hpple/XPathQuery.h>
#import "DetailsViewController.h"
#import "JMMLeaflet.h"
#import "PickListViewController.h"

@interface DetailsViewController ()

//List of categories which require the user to select one or more options from a list
@property (nonatomic, strong) NSArray *pickListKeys;
@property (nonatomic, strong) NSMutableDictionary *pickListSelectedValues;
@property (nonatomic, strong) NSMutableDictionary *pickListSelectedKeys;

//Default text for the text view items
@property (nonatomic, strong) NSString *defaultTranscriptTextViewText;
@property (nonatomic, strong) NSString *defaultTagsTextViewText;

//Keyboard state
@property (nonatomic) BOOL keyboardVisible;
@property (nonatomic, strong) UIView *scrollToView;

//Electorates
@property (nonatomic, strong) NSDictionary *electorates;
@property (nonatomic, strong) NSArray *electoratesOrderedKeys;

//Delivery times
@property (nonatomic, strong) NSDictionary *deliveryTimes;
@property (nonatomic, strong) NSArray *deliveryTimesOrderedKeys;

//Political parties
@property (nonatomic, strong) NSDictionary *parties;
@property (nonatomic, strong) NSArray *partiesOrderedKeys;

//Categories
@property (nonatomic, strong) NSDictionary *categories;
@property (nonatomic, strong) NSArray *categoriesOrderedKeys;

//Uploading
@property (nonatomic, strong) UIAlertView *uploadingInProgressView;
@property (nonatomic, strong) NSString *successfulSaveTitle;

@end

@implementation DetailsViewController

@synthesize defaultTranscriptTextViewText;
@synthesize defaultTagsTextViewText;
@synthesize keyboardVisible;
@synthesize scrollToView;
@synthesize uploadKey;
@synthesize htmlData;
@synthesize electorates;
@synthesize electoratesOrderedKeys;
@synthesize deliveryTimes;
@synthesize deliveryTimesOrderedKeys;
@synthesize parties;
@synthesize partiesOrderedKeys;
@synthesize categories;
@synthesize categoriesOrderedKeys; 
@synthesize pickListSelectedKeys;
@synthesize uploadingInProgressView;
@synthesize successfulSaveTitle;

- (NSArray *) pickListKeys
{
    //The pick list categories and the choices associated with them will need to be extracted from the HTML
    //returned to the upload view controller after uploading the images, temp hard-coded below
    if (!_pickListKeys){
        _pickListKeys = @[PL_ELECTORATES,
                          PL_DELIVERY,
                          PL_PARTY,
                          PL_ATTACKEDPARTIES,
                          PL_CATEGORIES
                          ];
    }
    return _pickListKeys;
}

- (NSMutableDictionary *)pickListSelectedValues
{
    if (!_pickListSelectedValues) {
        _pickListSelectedValues = [[NSMutableDictionary alloc] init];
        NSArray *initialValues = @[@"Which electorate was the leaflet delivered to?",
                                   @"When was the leaflet delivered?",
                                   @"Which party is responsible for the leaflet?",
                                   @"Which parties (if any) does the leaflet criticise?",
                                   @"Which categories (if any) best describe this leaflet?"
                                   ];
        for (NSString *value in initialValues) {
            [_pickListSelectedValues setObject:[NSArray arrayWithObject:value] forKey:[self.pickListKeys objectAtIndex:[initialValues indexOfObjectIdenticalTo:value]]];
        }
    }
    return _pickListSelectedValues;
}

- (NSMutableDictionary *)pickListSelectedKeys
{
    if (!pickListSelectedKeys) {
        pickListSelectedKeys = [[NSMutableDictionary alloc] init];
    }
    return pickListSelectedKeys;
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
    
    self.successfulSaveTitle = @"Leaflet Saved!";

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
    self.electoratesOrderedKeys = [[NSArray alloc] initWithArray:[self.electorates.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
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
    self.deliveryTimesOrderedKeys = [[NSArray alloc] init];
    self.deliveryTimesOrderedKeys = [self.deliveryTimes.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString* str1, NSString* str2) {
        return [str1 compare:str2 options:(NSNumericSearch)];
    }];
}

- (void)setupParties
{
    NSMutableDictionary *mutableParties = [[NSMutableDictionary alloc] init];
    TFHpple *htmlDoc = [[TFHpple alloc] initWithHTMLData:self.htmlData];
    TFHppleElement *listOfParties = [htmlDoc searchWithXPathQuery:@"//select[@id='ddlPartyBy']"][0];
    NSArray *elements = listOfParties.children;
    for (TFHppleElement *element in elements){
        if (element.firstChild.content) {
            NSString *partyName = [element.firstChild.content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            partyName = [partyName stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            [mutableParties setObject:partyName forKey:[element.attributes objectForKey:@"value"]];
        }
    }
    self.parties = [[NSDictionary alloc] initWithDictionary:mutableParties];
    NSArray *orderValues = [[NSArray alloc] initWithArray:[self.parties.allValues sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    NSMutableArray *orderKeys = [[NSMutableArray alloc] init];
    for (NSString *value in orderValues) {
        [orderKeys addObject:[[self.parties allKeysForObject:value] objectAtIndex:0]];
    }
    self.partiesOrderedKeys = [[NSArray alloc] initWithArray:orderKeys];
}

- (void)setupCategories
{
    NSMutableDictionary *mutableCategories = [[NSMutableDictionary alloc] init];
    TFHpple *htmlDoc = [[TFHpple alloc] initWithHTMLData:self.htmlData];
    NSArray *listOfInputElements = [htmlDoc searchWithXPathQuery:@"//input[contains(@name,'chkCategory')]"];
    for (TFHppleElement *inputElement in listOfInputElements) {
        //NSLog(@"%@",[inputElement.attributes objectForKey:@"value"]);
        NSString *queryString = [NSString stringWithFormat:@"//label[@for='chkCategory_%@']",[inputElement.attributes objectForKey:@"value"]];
        TFHppleElement *labelElement = [htmlDoc searchWithXPathQuery:queryString][0];
        //NSLog(@"%@", labelElement.firstChild.content);
        [mutableCategories setObject:labelElement.firstChild.content forKey:[inputElement.attributes objectForKey:@"value"]];
    }
    self.categories = [[NSDictionary alloc] initWithDictionary:mutableCategories];
    NSArray *orderValues = [[NSArray alloc] initWithArray:[self.categories.allValues sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    NSMutableArray *orderKeys = [[NSMutableArray alloc] init];
    for (NSString *value in orderValues) {
        [orderKeys addObject:[[self.categories allKeysForObject:value] objectAtIndex:0]];
    }
    self.categoriesOrderedKeys = [[NSArray alloc] initWithArray:orderKeys];
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
    return [self.pickListKeys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"LeafletListPickCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell prepareForReuse];
    
    // Configure the cell...
    cell.textLabel.text = [self stringFromPickListValuesAtIndex:indexPath.row];
    
    return cell;
}

- (NSString *)stringFromPickListValuesAtIndex:(NSInteger)index
{
    NSArray *selectedValueStrings = [self.pickListSelectedValues objectForKey:[self.pickListKeys objectAtIndex:index]];
    NSString *selectedValueString = [selectedValueStrings objectAtIndex:0];
    for (int i = 1; i < [selectedValueStrings count]; i++) {
        selectedValueString = [selectedValueString stringByAppendingFormat:@", %@", [selectedValueStrings objectAtIndex:i]];
    }
    return selectedValueString;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
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
    [self scrollToViewFollowingKeyboardChange];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    [self scrollToViewFollowingKeyboardChange];
}

- (void)scrollToViewFollowingKeyboardChange
{
    if (self.scrollToView) {
        [self scrollToTextInput:self.scrollToView];
        self.scrollToView = nil;
    }
}

#pragma mark - Scroll to text field/view

- (void)scrollToTextInput:(UIView *)view
{
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

#pragma mark - Prepare for segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pickListSegue"] ) {
        PickListViewController *destinationVC = (PickListViewController *)[segue destinationViewController];
        UITableViewCell *senderCell = (UITableViewCell *)sender;
        NSString *senderText = senderCell.textLabel.text;
        if ([senderText isEqualToString:[self stringFromPickListValuesAtIndex:0]]) {
            destinationVC.title = self.pickListKeys[0];
            destinationVC.pickList = self.electorates;
            destinationVC.orderedKeys = self.electoratesOrderedKeys;
            destinationVC.multipleSelectionMode = NO;
        } else if ([senderText isEqualToString:[self stringFromPickListValuesAtIndex:1]]) {
            destinationVC.title = self.pickListKeys[1];
            destinationVC.pickList = self.deliveryTimes;
            destinationVC.orderedKeys = self.deliveryTimesOrderedKeys;
            destinationVC.multipleSelectionMode = NO;
        } else if ([senderText isEqualToString:[self stringFromPickListValuesAtIndex:2]]) {
            destinationVC.title = self.pickListKeys[2];
            destinationVC.pickList = self.parties;
            destinationVC.orderedKeys = self.partiesOrderedKeys;
            destinationVC.multipleSelectionMode = NO;
        } else if ([senderText isEqualToString:[self stringFromPickListValuesAtIndex:3]]){
            destinationVC.title = self.pickListKeys[3];
            destinationVC.pickList = self.parties;
            destinationVC.orderedKeys = self.partiesOrderedKeys;
            destinationVC.multipleSelectionMode = YES;
        } else if ([senderText isEqualToString:[self stringFromPickListValuesAtIndex:4]]){
            destinationVC.title = self.pickListKeys[4];
            destinationVC.pickList = self.categories;
            destinationVC.orderedKeys = self.categoriesOrderedKeys;
            destinationVC.multipleSelectionMode = YES;
        }
    }
}

#pragma mark - Selected Values
- (void) selectedPickListKeys:(NSArray *)selectedKeys forPickListType:(NSString *)pickListType;
{
    //First store the selected keys, these will be uploaded to the server
    [self.pickListSelectedKeys setValue:selectedKeys forKey:pickListType];
    //Also need the values associated with the selected keys to update the table view to show selections
    //First get all the values associated with the pick list type
    NSDictionary *allValues;
    if ([pickListType isEqualToString:PL_ELECTORATES]) {
        allValues = self.electorates;
    } else if ([pickListType isEqualToString:PL_DELIVERY]){
        allValues = self.deliveryTimes;
    } else if ([pickListType isEqualToString:PL_PARTY]){
        allValues = self.parties;
    } else if ([pickListType isEqualToString:PL_ATTACKEDPARTIES]){
        allValues = self.parties;
    } else if ([pickListType isEqualToString:PL_CATEGORIES]){
        allValues = self.categories;
    }
    NSArray *selectedValues = [allValues objectsForKeys:selectedKeys notFoundMarker:@"Not found"]; //Extract only the selected values
    [self.pickListSelectedValues setObject:selectedValues forKey:pickListType]; //Store
    [self.tableView reloadData]; //Update display
}

#pragma mark - Saving Leaflet

- (IBAction)saveLeafletButton:(id)sender {
    //Perform some validation
    NSString *saveLeafletPath = [@"addinfo.php?key=" stringByAppendingString:uploadKey];
    NSURL *url = [NSURL URLWithString:@"http://dev.electionleaflets.local:8080"]; //for development only
    //NSURL *url = [NSURL URLWithString:@"http://www.electionleaflets.org.au/"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = @{
                             @"_is_postback": @"1",
                             @"_viewstate:": @"",
                             @"_postback_command": @"",
                             @"_postback_arguement": @"",
                             @"txtTitle": self.leafletTitle.text,
                             @"txtDescription": [self getTranscriptText],
                             @"txtPostcode": self.leafletPostcode.text,
                             @"ddlConstituency": [self getStringOfSelectedKeyForPickListType:PL_ELECTORATES],
                             @"ddlDelivered": [self getStringOfSelectedKeyForPickListType:PL_DELIVERY],
                             @"ddlPartyBy": [self getStringOfSelectedKeyForPickListType:PL_PARTY],
                             @"txtTags": [self getTagsText],
                             @"txtName": self.submitterName.text,
                             @"txtEmail": self.submitterEmail.text,
                             };
    params = [self addMultipleSelectedKeysToDictionary:params forPickListType:PL_ATTACKEDPARTIES];
    params = [self addMultipleSelectedKeysToDictionary:params forPickListType:PL_CATEGORIES];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:saveLeafletPath parameters:params];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"%@", @"Success");
        //NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self handleLeafletSaveHTTPSuccess:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"%@", @"Failure");
        [self handleLeafletSaveHTTPFailure];
    }];
    [httpClient enqueueHTTPRequestOperation:operation];
    [self displayUploadingInProgressMessage];
}

- (NSString *)getTranscriptText
{
    if ([self.leafletTranscript.text isEqualToString:self.defaultTranscriptTextViewText]) {
        return @"";
    } else {
        return self.leafletTranscript.text;
    }
}

- (NSString *)getTagsText
{
    if ([self.leafletTags.text isEqualToString:self.defaultTagsTextViewText]) {
        return @"";
    } else {
        return self.leafletTags.text;
    }
}

- (NSString *)getStringOfSelectedKeyForPickListType:(NSString *)pickListType
{
    //This method is only for pick list types with only 1 key expected
    if ([pickListType isEqualToString:PL_PARTY] || [pickListType isEqualToString:PL_ELECTORATES] || [pickListType isEqualToString:PL_DELIVERY]) {
        NSArray *selectedKey = [self.pickListSelectedKeys valueForKey:pickListType];
        NSString *selectedKeyString = @"";
        if (selectedKey != nil && [selectedKey count] != 0) {
            selectedKeyString = [selectedKey objectAtIndex:0];
        }
        return selectedKeyString;
    } else {
        return @""; //probably should make this error more obvious
    }
}

- (NSDictionary *)addMultipleSelectedKeysToDictionary:(NSDictionary *)oldParams forPickListType:(NSString *)pickListType
{
    NSDictionary *newParams;
    if ([pickListType isEqualToString:PL_ATTACKEDPARTIES] || [pickListType isEqualToString:PL_CATEGORIES]) {
        NSString *uploadKeyBaseString;
        if ([pickListType isEqualToString:PL_ATTACKEDPARTIES]) {
            uploadKeyBaseString = @"chkPartyAttack_";
        } else {
            uploadKeyBaseString = @"chkCategory_";
        }
        NSMutableDictionary *mutableDictionary = [oldParams mutableCopy];
        NSArray *selectedKeys = [self.pickListSelectedKeys valueForKey:pickListType];
        for (NSString *key in selectedKeys) {
            NSString *uploadKeyString = [uploadKeyBaseString stringByAppendingString:key];
            [mutableDictionary setValue:key forKey:uploadKeyString];
        }
        newParams = [mutableDictionary copy];
    } else {
        newParams = oldParams;
    }
    return newParams;
}

- (void) handleLeafletSaveHTTPSuccess:(NSData *)response
{
    //handle HTTP success could be either successful upload or form validation response
    [self.uploadingInProgressView dismissWithClickedButtonIndex:0 animated:YES];
    TFHpple *responseDoc = [[TFHpple alloc] initWithHTMLData:response];
    TFHppleElement *warnings = [responseDoc searchWithXPathQuery:@"//div[@id='divWarning']"][0];
    //NSLog(@"%@", [warnings description]);
    if ([warnings.children count] > 1) {
        //Invalid form
        //NSLog(@"%@", @"Invalid Form Submitted");
        TFHppleElement *warningsList = warnings.children[1];
        NSString *firstWarningContent = warningsList.firstChild.firstChild.content;
        //NSLog(@"%@", firstWarningContent);
        UIAlertView *warning = [[UIAlertView alloc] initWithTitle:firstWarningContent
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [warning show];
    } else {
        //Valid form successfully saved
        //NSLog(@"%@", @"Successfully saved leaflet");
        UIAlertView *saveSuccess = [[UIAlertView alloc] initWithTitle:self.successfulSaveTitle
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
        [saveSuccess show];
    }
}

- (void) handleLeafletSaveHTTPFailure
{
    [self.uploadingInProgressView dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *errorMsg = [[UIAlertView alloc] initWithTitle:@"A network error occured,\nplease try again..."
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [errorMsg show];
}

-(void) displayUploadingInProgressMessage
{
    self.uploadingInProgressView = [[UIAlertView alloc] initWithTitle:@"\nSaving Leaflet\nPlease Wait..."
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


-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:self.successfulSaveTitle]) {
        UIViewController *leafletView = [self.tabBarController.viewControllers objectAtIndex:0];//get the leaflet view controller
        self.tabBarController.selectedViewController = leafletView;
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

@end
