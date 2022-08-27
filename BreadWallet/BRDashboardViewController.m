//
//  BRDashboardViewController.m
//  WoodcoinWallet
//
//  Created by Renat Gafarov on 03/08/2022.
//  Copyright © 2022 Aaron Voisine. All rights reserved.
//

#import "BRDashboardViewController.h"
#import "BRNewTransactionCell.h"
#import "BRTransaction.h"
#import "BRWalletManager.h"
#import "BRPeerManager.h"
#import "BRWallet.h"
#import "BRRootViewController.h"
#import "BRTxDetailViewController.h"
#import "BRPINViewController.h"
#import "BRWalletManager.h"
#import "BRWallet.h"
#import "BRPeerManager.h"
#import "BRTransaction.h"
#import "BRCopyLabel.h"
#import "BRBubbleView.h"
#import "BRActionTableViewCell.h"
#import "BRRestoreViewController.h"

@import Foundation;

#define NoTransactionsCellID @"NewNoTransactionCell"
#define NewTransactionCellID @"NewTransactionCell"

@interface BRDashboardViewController ()

@property (nonatomic, strong) id balanceObserver;
@property (nonatomic, strong) NSArray *transactions;
@property (nonatomic, strong) NSMutableDictionary *txDates;

@property (nonatomic, strong) NSDateFormatter *txCellDateFormatter;

@end

@implementation BRDashboardViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    
    if (self) {
        _txCellDateFormatter = [NSDateFormatter new];
        _txCellDateFormatter.dateFormat = @"dd.MM.yyyy";
        _txDates = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _txCellDateFormatter = [NSDateFormatter new];
        _txCellDateFormatter.dateFormat = @"dd.MM.yyyy";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.transactionsTable.rowHeight = 80;
    self.transactionsTable.estimatedRowHeight = 80;
    
    if (!self.transactions || self.transactions.count == 0) {
        self.transactionsTable.scrollEnabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    BRWalletManager *m = [BRWalletManager sharedInstance];
    
    self.transactions = m.wallet.recentTransactions;
    
    self.cryptoBalanceLabel.text = [m stringForAmount:m.wallet.balance];
    self.fiatBalanceLabel.text = [m localCurrencyStringForAmount:m.wallet.balance];
    
    NSString *rawPriceText = [NSString stringWithFormat:@"Price: %lf", m.localCurrencyPrice];
    self.priceLabel.text = rawPriceText;
    
    if (! self.balanceObserver) {
        self.balanceObserver = [[NSNotificationCenter defaultCenter] addObserverForName:BRWalletBalanceChangedNotification
                                                                                 object:nil
                                                                                  queue:nil
                                                                             usingBlock:^(NSNotification *note) {
            BRTransaction *tx = self.transactions.firstObject;
            NSArray *recentTransactions = m.wallet.recentTransactions;
            
            NSString *rawPriceText = [NSString stringWithFormat:@"Price: %lf", m.localCurrencyPrice];
            self.priceLabel.text = rawPriceText;
            
            if (!m.wallet) return;
            self.transactions = [NSArray arrayWithArray:recentTransactions];
            
            self.cryptoBalanceLabel.text = [m stringForAmount:m.wallet.balance];
            self.fiatBalanceLabel.text = [m localCurrencyStringForAmount:m.wallet.balance];
            
            if (self.transactions.firstObject != tx) {
                [self.transactionsTable reloadSections:[NSIndexSet indexSetWithIndex:0]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else [self.transactionsTable reloadData];
        }];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (NSString *)trimZeroIfNeededForString:(NSString *)str {
    NSInteger lastIndex = str.length - 1;
    NSInteger prelastIndex = str.length - 2;
    
    if (lastIndex <= 0) {
        return str;
    }
    
    unichar lastChar = [str characterAtIndex:lastIndex];
    unichar prelastChar = [str characterAtIndex:prelastIndex];
    
    if (lastChar == '0' && prelastChar != '.') {
        NSString *trimmed = [str substringWithRange:NSMakeRange(0, lastIndex-1)];
        return [self trimZeroIfNeededForString:trimmed];
    } else {
        return str;
    }
}

- (NSString *)dateForTx:(BRTransaction *)tx {
    NSString *date = self.txDates[tx.txHash];
    if (date) return date;
    NSTimeInterval t = [[BRPeerManager sharedInstance] timestampForBlockHeight:tx.blockHeight];
    NSDate *timestamp = [NSDate dateWithTimeIntervalSinceReferenceDate:t - 5*60];
    date = [self.txCellDateFormatter stringFromDate:timestamp];
    self.txDates[tx.txHash] = date;
    return date;
}

- (NSString *)cryptoAmountFor:(BRTransaction *)tx {
    BRWalletManager *m = [BRWalletManager sharedInstance];
    
    uint64_t received = [m.wallet amountReceivedFromTransaction:tx],
    sent = [m.wallet amountSentByTransaction:tx];
    if (! [m.wallet addressForTransaction:tx] && sent > 0) {
        return [m stringForAmount:sent];
    } else if (sent > 0) {
        return [m stringForAmount:received - sent];
    } else {
        return [m stringForAmount:received ];
    }
}

- (NSString *)fiatAmountFor:(BRTransaction *)tx {
    BRWalletManager *m = [BRWalletManager sharedInstance];
    
    uint64_t received = [m.wallet amountReceivedFromTransaction:tx],
    sent = [m.wallet amountSentByTransaction:tx];
    
    if (! [m.wallet addressForTransaction:tx] && sent > 0) {
        return [m localCurrencyStringForAmount:sent];
    } else if (sent > 0) {
        return [m localCurrencyStringForAmount:received - sent];
    } else {
        return [m localCurrencyStringForAmount:received ];
    }
}

- (NSString *)addressFor:(BRTransaction *)tx {
    BRWalletManager *m = [BRWalletManager sharedInstance];
    return [m.wallet addressForTransaction:tx];
}

- (BOOL)isReceivedFor:(BRTransaction *)tx {
    BRWalletManager *m = [BRWalletManager sharedInstance];
    uint64_t sent = [m.wallet amountSentByTransaction:tx];
    return sent <= 0;
}

#pragma mark UITableView Delegate&Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.transactions.count > 0 ? self.transactions.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = self.transactions.count > 0 ? NewTransactionCellID : NoTransactionsCellID;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[BRNewTransactionCell class]]) {
        BRNewTransactionCell *newCell = (BRNewTransactionCell *)cell;
        BRTransaction *tx = self.transactions[indexPath.row];
        
        [newCell setDate: [self dateForTx:tx]];
        [newCell setCryptoAmount:[self cryptoAmountFor:tx]];
        [newCell setFiatAmount:[self fiatAmountFor:tx]];
        [newCell setAddress:[self addressFor:tx]];
        [newCell setIsReceivedIcon:[self isReceivedFor:tx]];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.transactions.count > 0) {
        return @"Transactions history";
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.transactions.count > 0) {
        UIViewController *c = [self.storyboard instantiateViewControllerWithIdentifier:@"TxDetailViewController"];
        [(id)c setTransaction:self.transactions[indexPath.row]];
        [(id)c setTxDateString:[self dateForTx:self.transactions[indexPath.row]]];
        [self.navigationController pushViewController:c animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView * headerView = (UITableViewHeaderFooterView *) view;
        headerView.textLabel.textColor  = [UIColor colorNamed:@"Pure White"];
        headerView.textLabel.font = [UIFont systemFontOfSize:16];
        headerView.backgroundColor = [UIColor colorNamed:@"Background"];
        headerView.tintColor = [UIColor colorNamed:@"Background"];
    }
}

@end
