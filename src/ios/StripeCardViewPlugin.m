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

@import Stripe;

@interface StripeCardPlugin () <NSXMLParserDelegate>
{
    NSString *stripePublishableKey;
}

@end

@implementation StripeCardPlugin : CDVPlugin

- (void)pluginInitialize {
    NSString *configXMLPath = [NSBundle.mainBundle pathForResource:@"config" ofType:@"xml"];
    NSData *configXMLContents = [NSData dataWithContentsOfFile:configXMLPath];
    NSXMLParser *configXMLParser = [[NSXMLParser alloc] initWithData:configXMLContents];
    configXMLParser.delegate = self;
    [configXMLParser parse];
}

//-(void) openCardView:(UIViewController *) presentingViewController withcallbackId:(NSString*) callbackId andPlugin:(CDVPlugin *) plugin andCompletion:(void (^)(NSArray *))completion {
//
//
//    CheckoutViewController *checkoutViewController = [[CheckoutViewController alloc] init];
////    checkoutViewController.callbackId = callbackId;
////    checkoutViewController.plugin = plugin;
//    checkoutViewController.completion = completion;
//    checkoutViewController.completion = ^(NSArray * _Nonnull response) {
//        <#code#>
//    };
//    [presentingViewController presentViewController: checkoutViewController animated:YES completion:nil];
//
//}

- (void) openCardViewCorodova:(CDVInvokedUrlCommand*) command {
    // enviar para view controller
    CheckoutViewController *checkoutViewController = [[CheckoutViewController alloc] init];
//    checkoutViewController.callbackId = callbackId;
//    checkoutViewController.plugin = plugin;
    //checkoutViewController.completion = completion;
    checkoutViewController.args = command.arguments;
    checkoutViewController.completion = ^(NSArray * _Nonnull response) {
        CDVPluginResult* pluginResult = nil;
        
        if (response != nil) {
            NSDictionary *responseDict = @{@"LAST4": response[1],
                                           @"ID": response[0],
                                           @"EXPIRYMONTH": response[2],
                                           @"EXPIRYYEAR": response[3]
            };
            
            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary:responseDict];
        } else {
            NSDictionary *responseDict = @{@"ERRORMESSAGE": @"Cancelled"};
            
            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary:responseDict];
        }
        
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };
    [self.viewController presentViewController: checkoutViewController animated:YES completion:nil];
//    [self openCardView:self.viewController withcallbackId: command.callbackId andPlugin:self andCompletion:^(NSArray *response)  {
//
//        CDVPluginResult* pluginResult = nil;
//
//        if (response != nil) {
//            NSDictionary *responseDict = @{@"LAST4": response[1],
//                                           @"ID": response[0],
//                                           @"EXPIRYMONTH": response[2],
//                                           @"EXPIRYYEAR": response[3]
//            };
//
//            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary:responseDict];
//        } else {
//            NSDictionary *responseDict = @{@"ERRORMESSAGE": @"Cancelled"};
//
//            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary:responseDict];
//        }
//
//
//        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//    }];
    
//    CDVPluginResult* pluginResult = nil;
//    NSString* myarg = [command.arguments objectAtIndex:0];

//    if (myarg != nil) {
        
//    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
//    [CDVPluginResult resultWithStatus:<#(CDVCommandStatus)#> messageAsMultipart:<#(NSArray *)#>]
//    } else {
//        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Must have first argument"];
//    }
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    if ([elementName isEqualToString:@"preference"]) {
        if ([attributeDict[@"name"] isEqualToString:@"STRIPE_PUBLISHABLE_KEY"]) {
            stripePublishableKey = attributeDict[@"value"];
        }
        
        if (![stripePublishableKey isEqualToString:@""] && stripePublishableKey != nil) {
            [parser abortParsing];
            
            [StripeAPI setDefaultPublishableKey:stripePublishableKey];
        }
    }
}

@end
