-- Using SQLite to evaluate SQL expressions.
-- Expected output: 6

SELECT 1 + 2 + 3 as total;

-- Retrieve SQLite's version number
-- Expected output: 6

SELECT sqlite_version() as sqliteVersion;

-- First 3 characters of a GeoPackage Binary is "GP with a NUL character
-- Expected output: "GP"

SELECT ST_Point(144.965819, -37.830658, 4326) as shape;

-- Returns the size of a GeoPackage Binary for a 2D point
-- Expected output: 61 (bytes)

SELECT length(ST_Point(144.965819, -37.830658, 4326)) as dataLength;

-- Returns a hexadecimal representation of a GeoPackage Binary point
-- Expected output: "47500003E6100000605B3FFDE71E6240605B3FFDE71E62409414580053EA42C09414580053EA42C00101000000605B3FFDE71E62409414580053EA42C0"

SELECT hex(ST_Point(144.965819, -37.830658, 4326)) as shapeHex;

-- Converts a GeoPackage Binary into Well Known Text representation for Geometry
-- Expected output: ST_POINT(144.965819 -37.830658)

SELECT ST_AsText(X'47500003E6100000605B3FFDE71E6240605B3FFDE71E62409414580053EA42C09414580053EA42C00101000000605B3FFDE71E62409414580053EA42C0') as wkt;

-- Demonstrates ST_IsEmpty spatial function
-- Expected output: 0

SELECT ST_IsEmpty(ST_Point(144.965819, -37.830658, 4326)) as isEmpty;

-- Demonstrates ST_GeometryType spatial function
-- Expected output: "ST_POINT"

SELECT ST_GeometryType(ST_Point(144.965819, -37.830658, 4326)) as geometryType;

-- Demonstrates ST_X spatial function
-- Expected output: 144.965819

SELECT ST_X(ST_Point(144.965819, -37.830658, 4326)) as x;

-- Demonstrates ST_Y spatial function
-- Expected output: -37.830658

SELECT ST_Y(ST_Point(144.965819, -37.830658, 4326)) as y;

-- Demonstrates ST_Srid spatial function
-- Expected output: 4326

SELECT ST_Srid(ST_Point(144.965819, -37.830658, 4326)) as srid;

-- Demonstrates ST_MinX spatial function
-- Expected output: 144.965819

SELECT ST_MinX(ST_Point(144.965819, -37.830658, 4326)) as minx;

-- Demonstrates ST_MinY spatial function
-- Expected output: -37.830658

SELECT ST_MinY(ST_Point(144.965819, -37.830658, 4326)) as miny;

-- Demonstrates ST_MaxX spatial function
-- Expected output: 144.965819

SELECT ST_MaxX(ST_Point(144.965819, -37.830658, 4326)) as maxx;

-- Demonstrates ST_MinY spatial function
-- Expected output: -37.830658

SELECT ST_MaxY(ST_Point(144.965819, -37.830658, 4326)) as maxy;

-- Computes the distance between Redlands Office and Melbourne Office
-- Expected output: 12858514.476722037 (i.e. 12858 kms)

SELECT ST_Distance(ST_Point(144.965819, -37.830658, 4326),
                   ST_Point(-117.1963487,34.0562292, 4326))
                   as distance;

-- Computes the distance between South Melbourne Markets to Melbourne Office
-- Expected output: 1015.7444936798523 (i.e. 1 km)

SELECT ST_Distance(ST_Point(144.965819, -37.830658, 4326),
                   ST_Point(144.954433, -37.832262, 4326)) as distance;

-- Computes the bearing (in radianis) South Melbourne Markets relative to Melbourne Office
-- Expected output: 4.535820702776582 (radians)

SELECT ST_Azimuth(ST_Point(144.965819, -37.830658, 4326),
                  ST_Point(144.954433, -37.832262, 4326)) as radians;

-- Computes the bearing (in degrees) South Melbourne Markets relative to Melbourne Office
-- Expected output: 259.88338289716114 (degrees)

SELECT toDegrees(ST_Azimuth(ST_Point(144.965819, -37.830658, 4326),
                 ST_Point(144.954433, -37.832262, 4326))) as degrees;

-- Displays a point in Well Known Text format
-- Expected output: "POINT(144.965819 -37.830658)"

SELECT ST_AsText(ST_Point(144.965819, -37.830658, 4326)) as wkt;

-- Displays a point in PostGIS's Extended WKT format
-- Expected output: "SRID=4326;POINT(144.965819 -37.830658)"

SELECT ST_AsEWKT(ST_Point(144.965819, -37.830658, 4326)) as ewkt;

-- Shows the Locations table containing Melbourne Office and South Melbourne Markets

SELECT *,
       ST_X(Shape) as x,
       ST_Y(Shape) as y,
       ST_AsText(Shape) as wkt,
       ST_AsEWKT(Shape) as ewkt
From   Locations;

-- Perform a near me search against all Locations
-- Expected output: "Melbourne Office"

SELECT   *,
         ST_Distance(Shape, ST_Point(144.965819, -37.830658, 4326)) distance
FROM     Locations
ORDER BY distance
LIMIT    1;

-- Determine the midpoint between Melbourne Office and South Melbourne Markets
-- Expected result: POINT(144.960129 -37.831460)

SELECT average(ST_X(Shape)) as midx,
       average(ST_Y(Shape)) as midy,
       ST_Point(average(ST_X(Shape)), average(ST_Y(Shape)), 4326) as midpoint,
       ST_AsText(ST_Point(average(ST_X(Shape)), average(ST_Y(Shape)), 4326)) as wkt,
       ST_AsEWKT(ST_Point(average(ST_X(Shape)), average(ST_Y(Shape)), 4326)) as ewkt
From   Locations;
