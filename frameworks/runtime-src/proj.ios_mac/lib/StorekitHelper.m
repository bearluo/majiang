//
//  StorekitHelper.m
//  poker
//
//  Created by 罗昊 on 2017/6/7.
//
//

#import <Foundation/Foundation.h>
#import "StorekitHelper.h"
#import "SVProgressHUD.h"
#import "LuaEventProxy.h"
extern NSString *payCallback;
@implementation StorekitHelper{
    NSString* mProductID;
    NSString* pid;
    NSString* orderid;
    NSString* pmode;
}
    
    static StorekitHelper* instance = nil;

    +(id)sharedHelper{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        
            instance = [[self alloc] init];
        });
    
        return instance;
    }
    
    +(void)buyProduct:(NSDictionary *) params{
        [[StorekitHelper sharedHelper] buyProduct:params];
    }
    
    -(id)init{
        if(self=[super init]) {
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        }
        return self;
    }
    
    - (void)dealloc
    {
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
        [super dealloc];
    }
    
    -(void)buyProduct:(NSDictionary *) params{
        if([SKPaymentQueue canMakePayments]) {
            mProductID = [[NSString alloc] initWithString:[params objectForKey:@"productID"]];
            pid = [[NSString alloc] initWithString:[params objectForKey:@"pid"]];
            orderid = [[NSString alloc] initWithString:[params objectForKey:@"orderid"]];
            pmode = [[NSString alloc] initWithString:[params objectForKey:@"pmode"]];
            [self requestProductData:mProductID];
        }else{
            NSLog(@"不允許程序內付費購買");
            UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"提示",nil) message:@"您的手機沒有打開程序內付費購買" delegate:nil cancelButtonTitle:NSLocalizedString(@"關閉",nil) otherButtonTitles:nil];
            [alerView show];
        }
    }
    
    -(void)requestProductData:(NSString *) productID{
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showWithStatus:@"正在請求商品信息" ];
        
        NSSet *nsset = [NSSet setWithObject:productID];
        SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
        request.delegate = self;
        [request start];
    }

    -(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
        NSLog(@"--------收到產品反饋信息----------");
        NSArray *myProduct = response.products;
        if(myProduct.count == 0) {
            NSLog(@"無法獲取產品信息，購買失敗。");
            [self sendPayFailMsg];
            return;
        }
        NSLog(@"產品Product ID:%@",response.invalidProductIdentifiers);
        NSLog(@"產品付費數量: %ld",[myProduct count]);
        
        SKProduct *p = nil;
        
        for(SKProduct *product in myProduct){
            NSLog(@"product info");
            NSLog(@"SKProduct 描述信息%@", [product description]);
            NSLog(@"产品标题 %@" , product.localizedTitle);
            NSLog(@"产品描述信息: %@" , product.localizedDescription);
            NSLog(@"价格: %@" , product.price);
            NSLog(@"Product id: %@" , product.productIdentifier);
            if( [product.productIdentifier isEqualToString:mProductID]) {
                p = product;
            }
        }
        SKPayment * payment = [SKPayment paymentWithProduct:p];
        NSLog(@"---------发送购买请求------------");
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showWithStatus:@"正在發送購買請求"];
        
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    //弹出错误信息
    - (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
        NSLog(@"-------弹出错误信息----------");
//        [SVProgressHUD showErrorWithStatus:[error localizedDescription] maskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD dismiss];
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示",NULL) message:[error localizedDescription]
                                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"關閉",nil) otherButtonTitles:nil];
        [alerView show];
        
        
        [self sendPayFailMsg];
    }

    -(void) requestDidFinish:(SKRequest *)request
    {
        NSLog(@"----------反馈信息结束--------------");
        [SVProgressHUD dismiss];
        
    }
    #pragma mark - SKPaymentTransactionObserver
        // 处理交易结果
    - (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
        for (SKPaymentTransaction *transaction in transactions)
        {
            switch (transaction.transactionState)
            {
                case SKPaymentTransactionStatePurchased://交易完成
                    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
                    [SVProgressHUD showSuccessWithStatus:@"交易完成"];
                    NSLog(@"transactionIdentifier = %@", transaction.transactionIdentifier);
                    [self completeTransaction:transaction];
                    break;
                case SKPaymentTransactionStateFailed://交易失败
                    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
                    [SVProgressHUD showErrorWithStatus:@"交易失敗，請重試"];
                    [self failedTransaction:transaction];
                    break;
                case SKPaymentTransactionStateRestored://已经购买过该商品
                    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
                    [SVProgressHUD showErrorWithStatus:@"已經購買過商品"];
                    [self restoreTransaction:transaction];
                    break;
                case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                    NSLog(@"商品添加进列表");
                    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                    [SVProgressHUD showWithStatus:@"正在請求付費信息" ];
                    break;
                default:
                    [SVProgressHUD dismiss];
                    break;
            }
        }
        
    }
    
    // 交易完成
    - (void)completeTransaction:(SKPaymentTransaction *)transaction {
        [SVProgressHUD dismiss];
        NSString * productIdentifier = transaction.payment.productIdentifier;
        NSString * transactionIdentifier = transaction.transactionIdentifier;
        NSString * receipt = [transaction.transactionReceipt base64Encoding];
        if ([productIdentifier length] > 0) {
            // 向自己的服务器验证购买凭证
            NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
            [dict setValue:receipt forKey:@"receipt"];
            [dict setValue:transactionIdentifier forKey:@"transid"];
            [dict setValue:orderid forKey:@"orderid"];
            [dict setValue:pid forKey:@"pid"];
            [dict setValue:pmode forKey:@"pmode"];
            [dict setValue:@(1) forKey:@"ret"];
            NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
            NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [[LuaEventProxy sharedProxy] dispatchEvent:payCallback params:ret];
        }
        
        // Remove the transaction from the payment queue.
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
        
    }
        
        // 交易失败
    - (void)failedTransaction:(SKPaymentTransaction *)transaction {
        if(transaction.error.code != SKErrorPaymentCancelled) {
            NSLog(@"购买失败");
            [self sendPayFailMsg];
        } else {
            NSLog(@"用户取消交易");
            NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
            [dict setValue:pmode forKey:@"pmode"];
            [dict setValue:@(2) forKey:@"ret"];
            NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
            NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [[LuaEventProxy sharedProxy] dispatchEvent:payCallback params:ret];
        }
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    }
        
        // 已购商品
    - (void)restoreTransaction:(SKPaymentTransaction *)transaction {
        // 对于已购商品，处理恢复购买的逻辑
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
        [self sendPayFailMsg];
    }

    - (void)sendPayFailMsg{
        NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
        [dict setValue:pmode forKey:@"pmode"];
        [dict setValue:@(3) forKey:@"ret"];
        NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
        NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        [[LuaEventProxy sharedProxy] dispatchEvent:payCallback params:ret];
    }
@end
