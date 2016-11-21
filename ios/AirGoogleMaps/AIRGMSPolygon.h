//
//  AIRGMSPolygon.h
//  Created by Nick Italiano on 11/17/16.
//
#import <GoogleMaps/GoogleMaps.h>

@interface AIRGMSPolygon : GMSPolygon
  @property (nonatomic, strong) void (^onAdd)(GMSMapView *map);
  @property (nonatomic, strong) void (^onRemove)(GMSMapView *map);
@end
