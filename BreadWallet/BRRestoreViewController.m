//
//  BRRestoreViewController.m
//  BreadWallet
//
//  Created by Aaron Voisine on 6/13/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "BRRestoreViewController.h"
#import "BRPINViewController.h"
#import "BRWalletManager.h"
#import "BRKeySequence.h"
#import "BRBIP39Mnemonic.h"
#import "NSString+Base58.h"

#define PHRASE_LENGTH 12
#define WORDS         @"BIP39EnglishWords"

@interface BRRestoreViewController ()

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *textViewYBottom;
@property (weak, nonatomic) IBOutlet UIView *textViewContainer;
@property (nonatomic, strong) NSArray *words;
@property (nonatomic, strong) id keyboardShowObserver;
@property (nonatomic, strong) id keyboardDismissObserver;
@property (weak, nonatomic) CALayer *textViewContainerBorderLayer;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLable;
@property (weak, nonatomic) IBOutlet UILabel *infoText;

@end

static NSString *normalize_phrase(NSString *phrase)
{
    NSMutableString *s = CFBridgingRelease(CFStringCreateMutableCopy(SecureAllocator(), 0, (CFStringRef)phrase));

    [s replaceOccurrencesOfString:@"." withString:@" " options:0 range:NSMakeRange(0, s.length)];
    [s replaceOccurrencesOfString:@"," withString:@" " options:0 range:NSMakeRange(0, s.length)];
    CFStringTrimWhitespace((CFMutableStringRef)s);
    CFStringLowercase((CFMutableStringRef)s, CFLocaleGetSystem());

    while ([s rangeOfString:@"  "].location != NSNotFound) {
        [s replaceOccurrencesOfString:@"  " withString:@" " options:0 range:NSMakeRange(0, s.length)];
    }

    return s;
}

@implementation BRRestoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

     self.words = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WORDS ofType:@"plist"]];
     
    // TODO: create secure versions of keyboard and UILabel and use in place of UITextView
    // TODO: autocomplete based on 4 letter prefixes of mnemonic words
    
    self.keyboardShowObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
            CGFloat keyboardHeight = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
            [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue]
                                  delay:0.0
                                options:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]
                             animations:^{
                self.view.frame = CGRectOffset(self.view.frame, 0, -keyboardHeight);
            } completion:nil];
        }];
    
    self.keyboardDismissObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
            CGFloat keyboardHeight = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
            [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue]
                                  delay:0.0
                                options:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]
                             animations:^{
                self.view.frame = CGRectOffset(self.view.frame, 0, keyboardHeight);
            } completion:nil];
        }];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(didTapAnywhere)];
    
    [self.view addGestureRecognizer:self.tapRecognizer];
    
    if (self.navigationController.viewControllers.firstObject != self) return;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self configureTextViewContainerIfNeeded];
}

- (void)dealloc
{
    if (self.keyboardShowObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.keyboardShowObserver];
}

- (void)didTapAnywhere {
    [self.textView resignFirstResponder];
}

- (void)configureTextViewContainerIfNeeded {
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    CGSize frameSize = self.textViewContainer.frame.size;
    CGRect shapeRect = CGRectMake(0, 0, frameSize.width, frameSize.height);
    
    shapeLayer.bounds = shapeRect;
    shapeLayer.position = CGPointMake(frameSize.width / 2, frameSize.height / 2);
    shapeLayer.fillColor = UIColor.clearColor.CGColor;
    shapeLayer.strokeColor = [UIColor colorNamed:@"Pure White"].CGColor;
    shapeLayer.lineWidth = 2;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineDashPattern = @[@10, @10];
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:shapeRect cornerRadius:16].CGPath;
    
    CALayer *oldShapeLayer = self.textViewContainerBorderLayer;
    if (oldShapeLayer) {
        for (CALayer *layer in self.textViewContainer.layer.sublayers) {
            if ([layer isEqual:oldShapeLayer]) {
                [layer removeFromSuperlayer];
            }
        }
    }
    
    [self.textViewContainer.layer addSublayer:shapeLayer];
    self.textViewContainerBorderLayer = shapeLayer;
}

#pragma mark - IBAction

- (IBAction)cancel:(id)sender
{
    if (self.shouldPopDismissStyle) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)import:(UIButton *)sender {
    [self checkInput:YES];
}

- (IBAction)pasteFromClipboard:(UIButton *)sender {
    self.textView.text = [[UIPasteboard generalPasteboard] string];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self checkInput:NO];
}

- (void)checkInput:(BOOL)forceImport {
    static NSCharacterSet *charset = nil;
    static dispatch_once_t onceToken = 0;
    
    UITextView *textView = self.textView;
    
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *set = [NSMutableCharacterSet letterCharacterSet];

        [set addCharactersInString:@"., "];
        charset = [set invertedSet];
    });

    @autoreleasepool {  // @autoreleasepool ensures sensitive data will be dealocated immediately
        BRWalletManager *m = [BRWalletManager sharedInstance];
        NSRange selected = textView.selectedRange;
        NSMutableString *s = CFBridgingRelease(CFStringCreateMutableCopy(SecureAllocator(), 0,
                                                                         (CFStringRef)textView.text));
        BOOL done = ([s rangeOfString:@"\n"].location != NSNotFound) || forceImport;
    
        while ([s rangeOfCharacterFromSet:charset].location != NSNotFound) {
            [s deleteCharactersInRange:[s rangeOfCharacterFromSet:charset]];
        }

        while ([s rangeOfString:@"  "].location != NSNotFound) {
            NSRange r = [s rangeOfString:@".  "];
    
            if (r.location != NSNotFound) {
                if (r.location + 2 == selected.location) selected.location++;
                [s deleteCharactersInRange:NSMakeRange(r.location + 1, 1)];
            }
            else [s replaceOccurrencesOfString:@"  " withString:@". " options:0 range:NSMakeRange(0, s.length)];
        }
    
        if ([s hasPrefix:@" "]) [s deleteCharactersInRange:NSMakeRange(0, 1)];

        selected.location -= textView.text.length - s.length;
        textView.text = s;
        textView.selectedRange = selected;
    
        if (! done) return;

        NSString *phrase = normalize_phrase(s), *incorrect = nil;
        NSArray *a = CFBridgingRelease(CFStringCreateArrayBySeparatingStrings(SecureAllocator(), (CFStringRef)phrase,
                                                                              CFSTR(" ")));

        for (NSString *word in a) {
            if ([self.words containsObject:word]) continue;
            incorrect = word;
            break;
        }
        
        NSLog(@"s letter value: %@", s);

        if ([s isEqual:@"wipe"])
        {
            UIAlertController *walletController = [UIAlertController alertControllerWithTitle:nil
                                                                                      message:nil
                                                                               preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction * wipe = [UIAlertAction actionWithTitle:@"wipe"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                [[BRWalletManager sharedInstance] setSeed:nil];
                self.textView.text = nil;
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:WALLET_NEEDS_BACKUP_KEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                UIViewController *p = self.navigationController.presentingViewController.presentingViewController;
                
                [p dismissViewControllerAnimated:NO completion:^{
                    UIViewController *c = [self.storyboard instantiateViewControllerWithIdentifier:@"PINNav"];
                    
                    [[(id)c viewControllers].firstObject setAppeared:YES];
                    
                    [p presentViewController:c animated:NO completion:^{
                        c.transitioningDelegate = [(id)p viewControllers].firstObject;
                        [c presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"NewWalletNav"]
                                        animated:NO completion:nil];
                    }];
                }];
            }];
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];
            [walletController addAction:wipe];
            [walletController addAction:cancelAction];
        }
        else if (incorrect)
        {
            textView.selectedRange = [[textView.text lowercaseString] rangeOfString:incorrect];
        
            /*[[[UIAlertView alloc] initWithTitle:nil
              message:[NSString stringWithFormat:NSLocalizedString(@"\"%@\" is not a backup phrase word", nil),
                       incorrect] delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil]
             show];*/
            NSString *backStr = @" is not a backup phrase word";
            NSString *strIncorrect = incorrect;
            NSString *str = [strIncorrect stringByAppendingString:backStr];
            UIAlertController *alertIncorrect = [UIAlertController alertControllerWithTitle:nil
                                                                                    message:str
                                                                             preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"ok"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:nil];
            [alertIncorrect addAction:cancelAction];
            [self presentViewController:alertIncorrect animated:YES completion:nil];
        }
        else if (a.count != PHRASE_LENGTH)
        {
            /*[[[UIAlertView alloc] initWithTitle:nil
              message:[NSString stringWithFormat:NSLocalizedString(@"backup phrase must have %d words", nil),
                       PHRASE_LENGTH] delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil)
              otherButtonTitles:nil] show];*/
            NSMutableString *phraseL = [NSMutableString stringWithFormat:@"backup phrase must have %d words", PHRASE_LENGTH];
            UIAlertController *alertPhrase = [UIAlertController alertControllerWithTitle:nil message:phraseL preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
            [alertPhrase addAction:cancelAction];
            [self presentViewController:alertPhrase animated:YES completion:nil];
        }
        else if (! [[BRBIP39Mnemonic sharedInstance] phraseIsValid:phrase])
        {
            /*[[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"bad backup phrase", nil) delegate:nil
              cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil] show];*/
            UIAlertController *alertInvalidPhrase = [UIAlertController alertControllerWithTitle:nil message:@"bad backup phrase" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
            [alertInvalidPhrase addAction:cancelAction];
            [self presentViewController:alertInvalidPhrase animated:YES completion:nil];
        }
        else if (m.wallet) {
            NSLog(@"Wallet m.wallet else if has been called");
            if ([phrase isEqual:normalize_phrase(m.seedPhrase)]) {
                NSLog(@"Wallet m if has been called");
                if (self.navigationController.viewControllers.firstObject != self) { // reset pin
                    NSLog(@"reset pin has been called");
                    m.pin = nil;
                    m.pinFailCount = 0;
                    m.pinFailHeight = 0;
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                else {
                    NSLog(@"wallet controller alert");
                    /*[[[UIActionSheet alloc] initWithTitle:nil delegate:self
                      cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                      destructiveButtonTitle:NSLocalizedString(@"wipe", nil) otherButtonTitles:nil]
                     showInView:[[UIApplication sharedApplication] delegate].window];*/
                    UIAlertController *walletController = [UIAlertController alertControllerWithTitle:nil message:@"This action will wipe your wallet." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * wipe = [UIAlertAction actionWithTitle:@"wipe" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                            [[BRWalletManager sharedInstance] setSeed:nil];
                            self.textView.text = nil;
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:WALLET_NEEDS_BACKUP_KEY];
                            [[NSUserDefaults standardUserDefaults] synchronize];

                            UIViewController *p = self.navigationController.presentingViewController.presentingViewController;
                            
                            [p dismissViewControllerAnimated:NO completion:^{
                                UIViewController *c = [self.storyboard instantiateViewControllerWithIdentifier:@"PINNav"];

                                [[(id)c viewControllers].firstObject setAppeared:YES];

                                [p presentViewController:c animated:NO completion:^{
                                    c.transitioningDelegate = [(id)p viewControllers].firstObject;
                                    [c presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"NewWalletNav"]
                                     animated:NO completion:nil];
                                }];
                            }];
                        }];
                    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];
                    [walletController addAction:wipe];
                    [walletController addAction:cancelAction];
                    [self presentViewController:walletController animated:YES completion:nil];
                }
            } else {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"backup phrase doesn't match", nil) preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancelAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        else
        {
            //TODO: offer the user an option to move funds to a new seed if their wallet device was lost or stolen
            NSLog(@"wallet backup has been called");
            m.seedPhrase = textView.text;
            textView.text = nil;
            
            [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

@end
