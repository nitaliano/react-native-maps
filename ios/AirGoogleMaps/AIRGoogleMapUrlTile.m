//
//  AIRGoogleMapURLTile.m
//  Created by Nick Italiano on 11/5/16.
//

#import "AIRGoogleMapUrlTile.h"

@implementation AIRGoogleMapUrlTile


- (void)setZIndex:(int)zIndex
{
  _zIndex = zIndex;
  _tileLayer.zIndex = zIndex;
}

- (void)setUrlTemplate:(NSString *)urlTemplate
{
  _urlTemplate = urlTemplate;
  _tileLayer = [GMSURLTileLayer tileLayerWithURLConstructor:[self _getTileURLConstructor]];
}

- (GMSTileURLConstructor)_getTileURLConstructor
{
  NSString *urlTemplate = self.urlTemplate;
  GMSTileURLConstructor urls = ^(NSUInteger x, NSUInteger y, NSUInteger zoom) {
    NSString *url = urlTemplate;
    
    // subdomains
    if ([self _hasSubdomains]) {
      CGPoint coord = CGPointMake(x, y);
      url = [url stringByReplacingOccurrencesOfString:@"{s}" withString:[NSString stringWithFormat: @"%@", [self _getSubdomain:coord]]];
    }
    
    // xyz
    url = [url stringByReplacingOccurrencesOfString:@"{x}" withString:[NSString stringWithFormat: @"%ld", (long)x]];
    url = [url stringByReplacingOccurrencesOfString:@"{y}" withString:[NSString stringWithFormat: @"%ld", (long)y]];
    url = [url stringByReplacingOccurrencesOfString:@"{z}" withString:[NSString stringWithFormat: @"%ld", (long)zoom]];
    
    return [NSURL URLWithString:url];
  };
  return urls;
}

- (BOOL)_hasSubdomains
{
  return !(_subdomains == nil || _subdomains.count == 0);
}

- (NSString*)_getSubdomain:(CGPoint)point
{
  int subdomainIndex = (int)ABS(point.x + point.y) % _subdomains.count;
  return _subdomains[subdomainIndex];
}

@end
