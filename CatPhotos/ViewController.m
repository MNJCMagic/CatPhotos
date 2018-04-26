//
//  ViewController.m
//  CatPhotos
//
//  Created by Mike Cameron on 2018-04-26.
//  Copyright © 2018 Mike Cameron. All rights reserved.
//

#import "ViewController.h"
#import "PhotoObject.h"
#import "CatCollectionViewCell.h"
#import "DetailViewController.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSArray* dataObjects;
@property (nonatomic, strong) NSMutableArray<PhotoObject*>* photoObjects;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //setup
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    NSMutableArray<PhotoObject*>* photoObjects = [[NSMutableArray alloc] init];
    self.photoObjects = photoObjects;
    
//    //tap
//    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wasTapped:)];
//    self.tapRecognizer = tapRecognizer;
//    [self.collectionView addGestureRecognizer:tapRecognizer];
    
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
            [self.collectionView reloadData];
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
        tempObj.photoID = dict[@"id"];
        tempObj.secret = dict[@"secret"];
        NSString *urlString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg", dict[@"farm"], dict[@"server"], dict[@"id"], dict[@"secret"]];
        NSURL *photoURL = [NSURL URLWithString:urlString];
        NSData *data = [NSData dataWithContentsOfURL:photoURL];
        UIImage *image = [UIImage imageWithData:data];
        tempObj.image = image;
        [self.photoObjects addObject:tempObj];
//        NSLog(@"added");
        
    };
    NSLog(@"%lu", (unsigned long)self.photoObjects.count);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoObjects.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CatCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"catCell" forIndexPath:indexPath];
    PhotoObject *tempObj = self.photoObjects[indexPath.item];
    cell.imageView.image = tempObj.image;
    cell.title.text = tempObj.name;
//    ceimageView.image = tempObj.image;
//    cell.imageView = imageView;
    return cell;
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"detailSegue"]) {
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = indexPaths[0];
        DetailViewController *detailViewController = (DetailViewController*)segue.destinationViewController;
        
        NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&format=json&nojsoncallback=1&api_key=671446b75c6c30cc03fd61ca2dc63cf1&photo_id=%@&secret=%@", self.photoObjects[indexPath.item].photoID, self.photoObjects[indexPath.item].secret];
        NSLog(@"%@", urlString);
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSLog(@"error %@", error.localizedDescription);
                return;
            };
            NSError *jsonError = nil;
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                NSLog(@"jsonError: %@", jsonError.localizedDescription);
                return;
            };
            NSString* realName = results[@"photo"][@"owner"][@"realname"];
            NSString* location = results[@"photo"][@"owner"][@"location"];

            
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                detailViewController.photoNameLabel.text = location;
                detailViewController.artistNameLabel.text = realName;
                detailViewController.photo.image = self.photoObjects[indexPath.item].image;
            }];
        }];
        [dataTask resume];
        
    }
}

    @end
//UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 180, 180)];
//
//cell.imageView.clipsToBounds = YES;
//cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
//[cell addSubview:cell.imageView];
//// put image in imageview

