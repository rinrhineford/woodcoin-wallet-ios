//
//  BRInputAddressViewController.m
//  loughwallet
//
//  Created by Robert Gludo II on 5/10/22.
//  Copyright © 2022 Aaron Voisine. All rights reserved.
//

#import "BRInputAddressViewController.h"
#import "BRPaymentRequest.h"
#import "NSString+Base58.h"
#import "BRSendViewController.h"



@interface BRInputAddressViewController ()

@property (nonatomic, strong) BRPaymentRequest *request;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIView *textFieldContainer;

@end

@implementation BRInputAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"Input amount controller loaded.");
    self.woodCheckText.hidden = YES;
    self.addressLabel.hidden = YES;
    self.nextButton.enabled = NO;
    woodAddress = @"";
    self.addressField.text = @"";
    [self.toolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.toolbar setShadowImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny];
    
    self.addressField.borderStyle = UITextBorderStyleNone;
    NSString *placeholderStr = @"Woodcoin address ex W7hdsu...........";
    NSDictionary<NSAttributedStringKey, id> *attributes = @{
        NSForegroundColorAttributeName: [UIColor colorNamed:@"Pure White"]
    };
    NSAttributedString *placeholderText = [[NSAttributedString alloc] initWithString:placeholderStr
                                                                          attributes:attributes];
    [self.addressField setAttributedPlaceholder: placeholderText];
    
    self.textFieldContainer.layer.cornerRadius = 16;
    self.textFieldContainer.layer.borderWidth = 4;
    self.textFieldContainer.layer.borderColor = [UIColor colorNamed:@"DarkTileorButton"].CGColor;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"Brinput address view will appeare did called");
    self.addressField.text = @"";
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"input address viewDidDisapper has been called");
}


- (IBAction)done:(id)sender
{
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)next:(id)sender
{
//    BRSendViewController *send = [[BRSendViewController alloc] initWithNibName:@"BRSendViewController" bundle:nil];
//    NSString *add = @"bitcoin:";
//    NSString *address = [add stringByAppendingString:self.addressField.text];
////    BRPaymentRequest *request = [BRPaymentRequest requestWithString:address];
//    [send handleInput:address];
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    id<BRInputAddressViewControllerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(inputAddressViewController:didChooseValue:)]) {
        [strongDelegate inputAddressViewController:self didChooseValue:woodAddress];
    }
    
}
- (IBAction)dismiss:(id)sender
{
    
    [self resignFirstResponder];
    NSString *address = self.addressField.text;
    NSLog(@"woodcoin input address: %@", address);
    BRPaymentRequest *request = [BRPaymentRequest requestWithString:address];
    if (! [request isValid] && ! [address isValidBitcoinPrivateKey] && ! [address isValidBitcoinBIP38Key]) {
        NSLog(@"Not a valid address");
//        self.woodCheckText.text = @"Not a valid woodcoin address";
//        self.woodCheckText.hidden = NO;
        self.nextButton.enabled = NO;
        self.addressLabel.text = @"";
        self.addressLabel.hidden = YES;
        self.addressField.text = @"";
        UIAlertController* alertNotValid = [UIAlertController alertControllerWithTitle:@"not a valid woodcoin address" message:request.paymentAddress preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
        [alertNotValid addAction:cancelAction];
        [self presentViewController:alertNotValid animated:YES completion:nil];
    } else {
        self.nextButton.enabled = YES;
        self.woodCheckText.hidden = YES;
        woodAddress = self.addressField.text;
        self.addressLabel.text = woodAddress;
        self.addressLabel.hidden = NO;
        self.addressField.text = @"";
    };
}


@end
