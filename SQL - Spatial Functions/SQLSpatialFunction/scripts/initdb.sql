CREATE TABLE Locations
(
    ID      INTEGER NOT NULL,
    Title   TEXT    NOT NULL,
    Address TEXT    NOT NULL,
    Shape   POINT,
    CONSTRAINT PK_Locations PRIMARY KEY (ID)
);

INSERT INTO Locations (Title, Address, Shape) VALUES ('Melbourne Office', '111 Coventry St', ST_Point(144.965819, -37.830658, 4326));
INSERT INTO Locations (Title, Address, Shape) VALUES ('Markets', 'Cecil St', ST_Point(144.9544383, -37.832262, 4326));

