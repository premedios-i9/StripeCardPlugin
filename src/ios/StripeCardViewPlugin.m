//
//  StripeCardViewPlugin.m
//  Save Card Without Payment (ObjC)
//
//  Created by Pedro Alcobia on 22/04/2021.
//  Copyright © 2021 stripe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StripeCardViewPlugin.h"
#import "CheckoutViewController.h"

@implementation StripeCardViewPlugin : CDVPlugin

-(void) openCardView:(UIViewController *) presentingViewController {
    CheckoutViewController *checkoutViewController = [[CheckoutViewController alloc] init];
    [presentingViewController presentViewController: checkoutViewController animated:YES completion:nil];
}

- (void) openCardViewCorodova:(CDVInvokedUrlCommand*) command {
    CDVPluginResult* pluginResult = nil;
//    NSString* myarg = [command.arguments objectAtIndex:0];

//    if (myarg != nil) {
        // enviar para view controller
    [self openCardView:self.viewController ];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
//    } else {
//        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Must have first argument"];
//    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
