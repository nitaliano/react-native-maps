//
//  AIRGMSPolyline.h
//  Created by Nick Italiano on 11/17/16.
//

#import <GoogleMaps/GoogleMaps.h>

@interface AIRGMSPolyline : GMSPolyline
  @property (nonatomic, copy) void (^onAdd)(GMSMapView *map);
  @property (nonatomic, copy) void (^onRemove)(GMSMapView *map);
@end
