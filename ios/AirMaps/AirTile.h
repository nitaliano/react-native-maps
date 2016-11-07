//
//  AirTile.h
//  Created by Nick Italiano on 11/6/16.
//

#import <MapKit/MapKit.h>

@interface AirTile : MKTileOverlay

@property (nonatomic, assign) NSString *urlTemplate;
@property (nonatomic, strong) NSArray *subdomains;

@end
