//
//  BRTabBarController.m
//  WoodcoinWallet
//
//  Created by Renat Gafarov on 07/08/2022.
//  Copyright © 2022 Aaron Voisine. All rights reserved.
//

#import "BRTabBarController.h"

@interface BRTabBarController ()

@end

@implementation BRTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"BRTabBarSetDefaultTab"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        [self setSelectedIndex:1];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setSelectedIndex:1];
}

@end
