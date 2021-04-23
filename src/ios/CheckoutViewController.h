//
//  CheckoutViewController.h
//  app
//
//  Created by Ben Guo on 9/29/19.
//  Copyright © 2019 stripe-samples. All rights reserved.
//

#import <Cordova/CDV.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CheckoutViewController : UIViewController
    @property (nonatomic, copy) NSString *BackendUrl;
    @property (nonatomic, copy) void (^completion)(NSArray *);

@end

NS_ASSUME_NONNULL_END
