import { ProductEntry } from './entity/product-entry';
export function addExampleObject() {
    const productEntry = new ProductEntry();
    productEntry.id = 1;
    productEntry.gazeteerName = "Beagle Commonwealth Marine Reserve";
    productEntry.year = "2018";
    productEntry.UUID = "GA-0364";
    productEntry.srs = "EPSG:32755";
    productEntry.l3ProductTifLocation = "s3://bathymetry-survey-288871573946-beagle-grid0/GA-0364_BlueFin_MB/BlueFin_2018-172_1m_Overlay.tif";
    productEntry.l0CoverageLocation = "s3://bathymetry-survey-288871573946/L0Coverage/coverage.shp";
    productEntry.l3CoverageLocation = "s3://bathymetry-survey-288871573946-beagle-grid0/GA-0364_BlueFin_MB/BlueFin_2018-172_1m.shp";
    productEntry.hillshadeLocation = "s3://bathymetry-survey-288871573946-beagle-grid0/GA-0364_BlueFin_MB/BlueFin_2018-172_1m_HS.tif";
    return (productEntry);
}
