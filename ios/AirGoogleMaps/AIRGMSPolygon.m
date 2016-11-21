//
//  AIRGMSPolygon.m
//  Created by Nick Italiano on 11/17/16.
//

#import "AIRGMSPolygon.h"

@implementation AIRGMSPolygon

- (void)setMap:(GMSMapView *)map
{
  [super setMap:map];
  
  if (_onAdd != nil && map != nil) {
    self.onAdd(map);
  } else if (_onRemove && map == nil) {
    self.onRemove(map);
  }
}

@end
