<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor version="1.0.0" 
 xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd" 
 xmlns="http://www.opengis.net/sld" 
 xmlns:ogc="http://www.opengis.net/ogc" 
 xmlns:xlink="http://www.w3.org/1999/xlink" 
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <NamedLayer>
    <Name>bathymetry_hillshade</Name>
    <UserStyle>
      <Title>Bathymetry Hillshade</Title>
      <Abstract/>
      <FeatureTypeStyle>
        <Rule>
          <Name>Colors</Name>
          <Abstract>A raster with 100% opacity</Abstract>
          <RasterSymbolizer>
            <Opacity>1</Opacity>
            <ColorMap type="ramp">
              <ColorMapEntry color="#000000" quantity="0" label="No Data" opacity="0"/>
              <ColorMapEntry color="#000000" opacity="1" quantity="1"/>
              <ColorMapEntry color="#FFFFFF" opacity="1" quantity="255"/>
            </ColorMap>            
          </RasterSymbolizer>
        </Rule>
      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>