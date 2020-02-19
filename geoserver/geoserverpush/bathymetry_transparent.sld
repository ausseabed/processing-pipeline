<?xml version="1.0" ?>
<sld:StyledLayerDescriptor version="1.0.0" xmlns="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc" xmlns:sld="http://www.opengis.net/sld">
    <sld:UserLayer>
        <sld:LayerFeatureConstraints>
            <sld:FeatureTypeConstraint/>
        </sld:LayerFeatureConstraints>
        <sld:UserStyle>
            <sld:Name>bathymetry_transparent</sld:Name>
          	<sld:Title/>
            <sld:FeatureTypeStyle>
              	<sld:Name/>
                <sld:Rule>
                    <sld:RasterSymbolizer>
                        <sld:Geometry>
                            <ogc:PropertyName>grid</ogc:PropertyName>
                        </sld:Geometry>
                        <sld:Opacity>0.5</sld:Opacity>
                        <sld:ColorMap>
                            <sld:ColorMapEntry color="#000000" label="No Data" opacity="0" quantity="-99999"/>
                            <sld:ColorMapEntry color="#5c0361" label="-6500" opacity="1.0" quantity="-6500"/>
                            <sld:ColorMapEntry color="#480864" label="-6000" opacity="1.0" quantity="-6000"/>
                            <sld:ColorMapEntry color="#340d67" label="-5500" opacity="1.0" quantity="-5500"/>
                            <sld:ColorMapEntry color="#21136b" label="-5000" opacity="1.0" quantity="-5000"/>
                            <sld:ColorMapEntry color="#041c70" label="-4750" opacity="1.0" quantity="-4750"/>
                            <sld:ColorMapEntry color="#0c307f" label="-4500" opacity="1.0" quantity="-4500"/>
                            <sld:ColorMapEntry color="#14448e" label="-4250" opacity="1.0" quantity="-4250"/>
                            <sld:ColorMapEntry color="#1c589d" label="-4000" opacity="1.0" quantity="-4000"/>
                            <sld:ColorMapEntry color="#256dac" label="-3750" opacity="1.0" quantity="-3750"/>
                            <sld:ColorMapEntry color="#2d81bb" label="-3500" opacity="1.0" quantity="-3500"/>
                            <sld:ColorMapEntry color="#3595ca" label="-3250" opacity="1.0" quantity="-3250"/>
                            <sld:ColorMapEntry color="#3eaada" label="-3000" opacity="1.0" quantity="-3000"/>
                            <sld:ColorMapEntry color="#49b2c9" label="-2800" opacity="1.0" quantity="-2800"/>
                            <sld:ColorMapEntry color="#54bbb9" label="-2600" opacity="1.0" quantity="-2600"/>
                            <sld:ColorMapEntry color="#60c3a9" label="-2400" opacity="1.0" quantity="-2400"/>
                            <sld:ColorMapEntry color="#6bcc98" label="-2200" opacity="1.0" quantity="-2200"/>
                            <sld:ColorMapEntry color="#77d488" label="-2000" opacity="1.0" quantity="-2000"/>
                            <sld:ColorMapEntry color="#82dd78" label="-1750" opacity="1.0" quantity="-1750"/>
                            <sld:ColorMapEntry color="#8ee668" label="-1500" opacity="1.0" quantity="-1500"/>
                            <sld:ColorMapEntry color="#a8e94f" label="-1250" opacity="1.0" quantity="-1250"/>
                            <sld:ColorMapEntry color="#c3ed36" label="-1000" opacity="1.0" quantity="-1000"/>
                            <sld:ColorMapEntry color="#ddf01d" label="-750" opacity="1.0" quantity="-750"/>
                            <sld:ColorMapEntry color="#f8f404" label="-500" opacity="1.0" quantity="-500"/>
                            <sld:ColorMapEntry color="#f4d004" label="-250" opacity="1.0" quantity="-250"/>
                            <sld:ColorMapEntry color="#f1ac04" label="-200" opacity="1.0" quantity="-200"/>
                            <sld:ColorMapEntry color="#ee8804" label="-180" opacity="1.0" quantity="-180"/>
                            <sld:ColorMapEntry color="#eb6404" label="-160" opacity="1.0" quantity="-160"/>
                            <sld:ColorMapEntry color="#db5a03" label="-140" opacity="1.0" quantity="-140"/>
                            <sld:ColorMapEntry color="#cb5002" label="-120" opacity="1.0" quantity="-120"/>
                            <sld:ColorMapEntry color="#bb4601" label="-100" opacity="1.0" quantity="-100"/>
                            <sld:ColorMapEntry color="#ab3d00" label="-80" opacity="1.0" quantity="-80"/>
                            <sld:ColorMapEntry color="#b75d2a" label="-60" opacity="1.0" quantity="-60"/>
                            <sld:ColorMapEntry color="#c47e54" label="-40" opacity="1.0" quantity="-40"/>
                            <sld:ColorMapEntry color="#d19f7f" label="-20" opacity="1.0" quantity="-20"/>
                            <sld:ColorMapEntry color="#dec0a9" label="-10" opacity="1.0" quantity="-10"/>
                            <sld:ColorMapEntry color="#ebe1d4" label="-1" opacity="1.0" quantity="-1"/>
                            <sld:ColorMapEntry color="#ffffff" label="" opacity="0" quantity="0"/>
                        </sld:ColorMap>
                    </sld:RasterSymbolizer>
                </sld:Rule>
            </sld:FeatureTypeStyle>
        </sld:UserStyle>
    </sld:UserLayer>
</sld:StyledLayerDescriptor>