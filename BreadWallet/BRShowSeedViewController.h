//
//  BRShowSeedViewController.h
//  loughwallet
//
//  Created by Robert Gludo II on 5/20/22.
//  Copyright © 2022 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRShowSeedViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *seedOutlet;

- (IBAction)doneAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
