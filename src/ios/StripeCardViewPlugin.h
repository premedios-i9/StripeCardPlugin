//
//  StripeCardViewPlugin.h
//  Save Card Without Payment (ObjC)
//
//  Created by Pedro Alcobia on 22/04/2021.
//  Copyright © 2021 stripe. All rights reserved.
//

#ifndef StripeCardViewPlugin_h
#define StripeCardViewPlugin_h

#import <Cordova/CDV.h>
#import <UIKit/UIKit.h>
@interface StripeCardViewPlugin : CDVPlugin
-(void) openCardView:(UIViewController *) presentingViewController withcallbackId:(NSString*) callbackId andPlugin:(CDVPlugin *) plugin andCompletion:(void (^)(NSArray *))completion;
@end

#endif /* StripeCardViewPlugin_h */

