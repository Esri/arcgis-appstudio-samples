DROP TABLE IF EXISTS Roads;

CREATE TABLE Roads
(
    RoadID   INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    RoadName TEXT,
    RoadType TEXT,
    CHECK (RoadType IN ('St', 'Rd', 'Way'))
);

INSERT INTO Roads (RoadName, RoadType) VALUES ('Coventry', 'St');
INSERT INTO Roads (RoadName, RoadType) VALUES ('Sturt', 'St');
INSERT INTO Roads (RoadName, RoadType) VALUES ('Kings', 'Way');

CRAP;

CREATE INDEX IX_Roads_001 ON Roads (RoadName);
CREATE INDEX IX_Roads_002 ON Roads (RoadType);

SELECT COUNT(*) as Count FROM Roads;

SELECT * FROM Roads;

