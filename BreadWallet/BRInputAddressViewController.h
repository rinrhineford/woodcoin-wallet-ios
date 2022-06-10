//
//  BRInputAddressViewController.h
//  loughwallet
//
//  Created by Robert Gludo II on 5/10/22.
//  Copyright © 2022 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol BRInputAddressViewControllerDelegate;

@interface BRInputAddressViewController : UIViewController {
    NSString *woodAddress;
}
    

@property (nonatomic, assign) id<BRInputAddressViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *addressField;
@property (strong, nonatomic) IBOutlet UILabel *woodCheckText;


@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@end

@protocol BRInputAddressViewControllerDelegate <NSObject>

- (void)inputAddressViewController:(BRInputAddressViewController*)viewController
             didChooseValue:(NSString*)value;

@end

