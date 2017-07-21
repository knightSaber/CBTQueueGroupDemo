//
//  ViewController.m
//  CBTQueueGroupDemo
//
//  Created by 陈波涛 on 2017/7/20.
//  Copyright © 2017年 microfastup. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self func5];
    
}

#pragma mark - 使用错误的队列组
- (void)func1{
    
    // 创建一个队列组!
    dispatch_group_t group = dispatch_group_create();
    
    __block UIImage *image1 ,*image2;
    
    // 下载第一张图片
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        
        image1 = [self downloadImageWithUrlString:@"http://g.hiphotos.baidu.com/image/pic/item/95eef01f3a292df54e0e7e08be315c6035a873da.jpg"];
    });
    
    // 下载第二张图片
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        
        image2 = [self downloadImageWithUrlString:@"http://e.hiphotos.baidu.com/image/pic/item/cc11728b4710b912d4bb69ffc1fdfc03924522bc.jpg"];
    });
    
    // 合并图片并且显示
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        // NSLog(@"显示图片! %@",[NSThread currentThread]);
        
        // 合并图片
        UIImage *image = [self bingImageWithImage1:image1 Image2:image2];
        
        // 显示合并之后的图片!
        self.imageView.image = image;
        
    });
}

#pragma mark - 不使用队列组
- (void)func2{
    
    UIImage *image1 ,*image2;
    
    // 下载第一张图片
    image1 = [self downloadImageWithUrlString:@"http://g.hiphotos.baidu.com/image/pic/item/95eef01f3a292df54e0e7e08be315c6035a873da.jpg"];
    
    // 下载第二张图片
    image2 = [self downloadImageWithUrlString:@"http://e.hiphotos.baidu.com/image/pic/item/cc11728b4710b912d4bb69ffc1fdfc03924522bc.jpg"];
    
    UIImage *image = [self bingImageWithImage1:image1 Image2:image2];
    
    // 显示合并之后的图片!
    self.imageView.image = image;
}

#pragma mark - 使用enter，leave的做法
- (void)func3{
    
    // 创建一个队列组!
    dispatch_group_t group = dispatch_group_create();
    
    __block UIImage *image1 ,*image2;
    
    // 下载第一张图片
    dispatch_group_enter(group);
    [self downloadImageWithUrlString:@"http://g.hiphotos.baidu.com/image/pic/item/95eef01f3a292df54e0e7e08be315c6035a873da.jpg" SuccessBlock:^(UIImage *image) {
        
        image1 = image;
        dispatch_group_leave(group);
        
    } failBlock:^(id error) {
        
    }];
    
    
    // 下载第二张图片
    dispatch_group_enter(group);
    [self downloadImageWithUrlString:@"http://e.hiphotos.baidu.com/image/pic/item/cc11728b4710b912d4bb69ffc1fdfc03924522bc.jpg" SuccessBlock:^(UIImage *image) {
        
        image2 = image;
        dispatch_group_leave(group);
        
    } failBlock:^(id error) {
        
    }];
    
    // 合并图片并且显示
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        // NSLog(@"显示图片! %@",[NSThread currentThread]);
        
        // 合并图片
        UIImage *image = [self bingImageWithImage1:image1 Image2:image2];
        
        // 显示合并之后的图片!
        self.imageView.image = image;
        
    });
}

#pragma mark - 异步+错误的队列组，图片下载不了
- (void)func4{
    
    // 创建一个队列组!
    dispatch_group_t group = dispatch_group_create();
    
    __block UIImage *image1 ,*image2;
    
    // 下载第一张图片
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        [self downloadImageWithUrlString:@"http://g.hiphotos.baidu.com/image/pic/item/95eef01f3a292df54e0e7e08be315c6035a873da.jpg" SuccessBlock:^(UIImage *image) {
            
            image1 = image;
            
        } failBlock:^(id error) {
            
        }];
    });
    
    
    // 下载第二张图片
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        [self downloadImageWithUrlString:@"http://e.hiphotos.baidu.com/image/pic/item/cc11728b4710b912d4bb69ffc1fdfc03924522bc.jpg" SuccessBlock:^(UIImage *image) {
            
            image2 = image;
            
        } failBlock:^(id error) {
            
        }];
    });
    
    // 合并图片并且显示
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 合并图片
        UIImage *image = [self bingImageWithImage1:image1 Image2:image2];
        
        // 显示合并之后的图片!
        self.imageView.image = image;
        
    });
    
}

#pragma mark - 使用信号量
- (void)func5{
    
    // 创建一个队列组!
    dispatch_group_t group = dispatch_group_create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block UIImage *image1 ,*image2;
    
    /*
     需要将dispatch_semaphore_wait放在后面的原因是，程序先执行了下载图片代码,进行wait--，然后下载完成的回调signal++，这时候程序可以继续
     */
    
    dispatch_group_async(group, dispatch_queue_create("1111", DISPATCH_QUEUE_CONCURRENT), ^{
       
        // 下载第一张图片
        [self downloadImageWithUrlString:@"http://g.hiphotos.baidu.com/image/pic/item/95eef01f3a292df54e0e7e08be315c6035a873da.jpg" SuccessBlock:^(UIImage *image) {
            
            image1 = image;
            
            dispatch_semaphore_signal(semaphore);//信号量++，继续
            
        } failBlock:^(id error) {
            
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//信号量--，阻塞
        
    });
    
    
    dispatch_group_async(group, dispatch_queue_create("22222", DISPATCH_QUEUE_CONCURRENT), ^{
        
        // 下载第二张图片
        [self downloadImageWithUrlString:@"http://e.hiphotos.baidu.com/image/pic/item/cc11728b4710b912d4bb69ffc1fdfc03924522bc.jpg" SuccessBlock:^(UIImage *image) {
            
            image2 = image;
            
            dispatch_semaphore_signal(semaphore);//信号量++，继续
            
        } failBlock:^(id error) {
            
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//信号量--，阻塞
        
    });
    
    
    // 合并图片并且显示
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        // 合并图片
        UIImage *image = [self bingImageWithImage1:image1 Image2:image2];
        
        NSLog(@"%@",[NSThread currentThread]);
        
        // 显示合并之后的图片!
        self.imageView.image = image;
    });
    
    
}

#pragma mark - 信号量的阻塞玩法
- (void)func6{
    
    //这样的话就可以让你想要执行的方法在异步请求之后去执行
    
    dispatch_semaphore_t semaphore =  dispatch_semaphore_create(0);
    
    [self downloadImageWithUrlString:@"http://g.hiphotos.baidu.com/image/pic/item/95eef01f3a292df54e0e7e08be315c6035a873da.jpg" SuccessBlock:^(UIImage *image) {
        
        NSLog(@"下载图片完毕");
        dispatch_semaphore_signal(semaphore);//信号量++，继续
        
    } failBlock:^(id error) {
        
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER));
    
    NSLog(@"我想放在最后再执行");
    
}

#pragma mark -  合并图片
-(UIImage *)bingImageWithImage1:(UIImage *)image1 Image2:(UIImage *)image2
{
    // 1.开启图形上下文
    UIGraphicsBeginImageContext(self.imageView.bounds.size);
    
    // 2.绘制第一张图片
    [image1 drawInRect:self.imageView.bounds];
    
    // 3.绘制第二张图片
    [image2 drawInRect:CGRectMake(0, self.imageView.bounds.size.height - 80, self.imageView.bounds.size.width, 80)];
    
    // 4.获取绘制好的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 5.关闭图形上下文
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - 下载图片
//同步下载图片
-(UIImage *)downloadImageWithUrlString:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    UIImage *image = [UIImage imageWithData:data];
    
    return image;
}



// 异步下载图片
-(void )downloadImageWithUrlString:(NSString *)urlString SuccessBlock:(void(^)(UIImage *))successBlock failBlock:(void(^)(id))failBlock
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *reque = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:reque completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        successBlock([UIImage imageWithData:[NSData dataWithContentsOfURL:location]]);
        
    }];
    [task resume];
}



@end
