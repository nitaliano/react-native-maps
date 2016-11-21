//
//  AIRGMSPolyline.m
//  AirMapsExplorer
//
//  Created by Nick Italiano on 11/17/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "AIRGMSPolyline.h"

@implementation AIRGMSPolyline

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
