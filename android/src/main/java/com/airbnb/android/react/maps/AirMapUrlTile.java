package com.airbnb.android.react.maps;

import android.content.Context;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.TileOverlay;
import com.google.android.gms.maps.model.TileOverlayOptions;
import com.google.android.gms.maps.model.UrlTileProvider;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;

public class AirMapUrlTile extends AirMapFeature {

    class AIRMapUrlTileProvider extends UrlTileProvider
    {
        private String urlTemplate;
        private List<String> subdomains;

        public AIRMapUrlTileProvider(int width, int height, String urlTemplate, List<String> subdomains) {
            super(width, height);
            this.urlTemplate = urlTemplate;
            this.subdomains = subdomains;
        }
        @Override
        public synchronized URL getTileUrl(int x, int y, int zoom) {

            String s = this.urlTemplate
              .replace("{s}", getSubdomain(x, y))
              .replace("{x}", Integer.toString(x))
              .replace("{y}", Integer.toString(y))
              .replace("{z}", Integer.toString(zoom));
            URL url = null;
            try {
                url = new URL(s);
            } catch (MalformedURLException e) {
                throw new AssertionError(e);
            }
            return url;
        }

        public void setUrlTemplate(String urlTemplate) {
            this.urlTemplate = urlTemplate;
        }

        private String getSubdomain(int x, int y) {
            if (subdomains == null || subdomains.size() == 0) {
              return "";
            }
            int subdomainIndex = Math.abs(x + y) % subdomains.size();
            return subdomains.get(subdomainIndex);
        }
    }

    private TileOverlayOptions tileOverlayOptions;
    private TileOverlay tileOverlay;
    private AIRMapUrlTileProvider tileProvider;

    private List<String> subdomains;
    private String urlTemplate;
    private float zIndex;

    public AirMapUrlTile(Context context) {
        super(context);
    }

    public void setUrlTemplate(String urlTemplate) {
        this.urlTemplate = urlTemplate;
        if (tileProvider != null) {
            tileProvider.setUrlTemplate(urlTemplate);
        }
        if (tileOverlay != null) {
            tileOverlay.clearTileCache();
        }
    }

    public void setZIndex(float zIndex) {
        this.zIndex = zIndex;
        if (tileOverlay != null) {
            tileOverlay.setZIndex(zIndex);
        }
    }

    public void setSubdomains(List<String> subdomains) {
        this.subdomains = subdomains;
    }

    public TileOverlayOptions getTileOverlayOptions() {
        if (tileOverlayOptions == null) {
            tileOverlayOptions = createTileOverlayOptions();
        }
        return tileOverlayOptions;
    }

    private TileOverlayOptions createTileOverlayOptions() {
        TileOverlayOptions options = new TileOverlayOptions();
        options.zIndex(zIndex);
        this.tileProvider = new AIRMapUrlTileProvider(256, 256, this.urlTemplate, subdomains);
        options.tileProvider(this.tileProvider);
        return options;
    }

    @Override
    public Object getFeature() {
        return tileOverlay;
    }

    @Override
    public void addToMap(GoogleMap map) {
        this.tileOverlay = map.addTileOverlay(getTileOverlayOptions());
    }

    @Override
    public void removeFromMap(GoogleMap map) {
        tileOverlay.remove();
    }
}
