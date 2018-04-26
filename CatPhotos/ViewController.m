//
//  ViewController.m
//  CatPhotos
//
//  Created by Mike Cameron on 2018-04-26.
//  Copyright © 2018 Mike Cameron. All rights reserved.
//

#import "ViewController.h"
#import "PhotoObject.h"

@interface ViewController ()
@property (nonatomic, strong) NSArray* dataObjects;
@property (nonatomic, strong) NSMutableArray<PhotoObject*>* photoObjects;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&api_key=671446b75c6c30cc03fd61ca2dc63cf1&tags=cat"];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error %@", error.localizedDescription);
            return;
        }
        [self parseResponseData:data];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // This will run on the main queue
            //            [self.tableView reloadData];
        }];
    }];
    [dataTask resume];
}

-(void)parseResponseData:(NSData*) data {
    NSError *jsonError = nil;
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    if (jsonError) {
        NSLog(@"jsonError: %@", jsonError.localizedDescription);
        return;
    }
    NSDictionary *secondResults = [NSDictionary dictionaryWithDictionary:results[@"photos"]];
    NSArray *photos = [NSArray arrayWithArray:secondResults[@"photo"]];
    self.dataObjects = photos;
    for (NSDictionary* dict in self.dataObjects) {
        PhotoObject *tempObj = [[PhotoObject alloc] init];
        tempObj.name = dict[@"title"];
        NSString *urlString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg", dict[@"farm"], dict[@"server"], dict[@"id"], dict[@"secret"]];
        NSURL *photoURL = [NSURL URLWithString:urlString];
        NSData *data = [NSData dataWithContentsOfURL:photoURL];
        UIImage *image = [UIImage imageWithData:data];
        tempObj.image = image;
        [self.photoObjects addObject:tempObj];
        NSLog(@"added");
        
    };
}
    
    
    
    
    @end
