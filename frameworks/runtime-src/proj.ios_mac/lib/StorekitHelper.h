//
//  StorekitHelper.h
//  poker
//
//  Created by 罗昊 on 2017/6/7.
//
//

#ifndef StorekitHelper_h
#define StorekitHelper_h

#import <StoreKit/StoreKit.h>

@interface StorekitHelper : NSObject

    +(id)sharedHelper;
    +(void)buyProduct:(NSDictionary *) params;
@end

#endif /* StorekitHelper_h */
