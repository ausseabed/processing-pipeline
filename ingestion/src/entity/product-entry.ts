import {Entity, PrimaryGeneratedColumn, Column} from "typeorm";

//"filename": "s3://bathymetry-survey-288871573946-beagle-grid0/GA-0364_BlueFin_MB/BlueFin_2018-172_1m_Overlay.tif",
//"l0-coverage": "s3://bathymetry-survey-288871573946/L0Coverage/coverage.shp",
//"l3-coverage": "s3://bathymetry-survey-288871573946-beagle-grid0/GA-0364_BlueFin_MB/BlueFin_2018-172_1m.shp",
//"hillshade": "s3://bathymetry-survey-288871573946-beagle-grid0/GA-0364_BlueFin_MB/BlueFin_2018-172_1m_HS.tif",
//"gazeteer-name":"Beagle Commonwealth Marine Reserve","year":2018,"resolution":"1m","UUID":"GA-0364","srs":"EPSG:32755"},
@Entity()
export class ProductEntry {

    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    gazeteerName: string; // Name of product for display purposes 

    @Column()
    year: string; // Year of product for display purposes 

    @Column()
    UUID: string; // Product Universally Unique Identifier

    @Column()
    srs: string; // Spatial Reference of product

    @Column()
    l3ProductTifLocation: string; // Location of final product 

    @Column()
    l0CoverageLocation: string; // Location of shapefile 

    @Column()
    l3CoverageLocation: string; // Location of shapefile 

    @Column()
    hillshadeLocation: string; // S3 location

}
