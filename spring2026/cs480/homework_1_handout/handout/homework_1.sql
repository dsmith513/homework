DROP TABLE IF EXISTS streams_daily;
DROP TABLE IF EXISTS songs;
DROP TABLE IF EXISTS platforms;
DROP TABLE IF EXISTS bands;


CREATE TABLE bands (
    id        INT PRIMARY KEY,
    name      VARCHAR(100) NOT NULL,
    label     VARCHAR(100) NOT NULL
);

INSERT INTO bands (id, name, label) VALUES
(1, 'Queen',        'EMI'),
(2, 'David Bowie',  'RCA'),
(3, 'Linkin Park',  'Warner'),
(4, 'Jay-Z',        'Roc-A-Fella');


CREATE TABLE songs (
    songid       INT PRIMARY KEY,
    title        VARCHAR(200) NOT NULL,
    genre        VARCHAR(50)  NOT NULL,
    duration     INT          NOT NULL,
    releasedate  DATE         NOT NULL,
    bandid       INT          NOT NULL,

    FOREIGN KEY (bandid)
        REFERENCES bands(id)
        ON DELETE CASCADE
);

INSERT INTO songs (songid, title, genre, duration, releasedate, bandid) VALUES
(101, 'Bohemian Rhapsody', 'Rock',    354, '1975-10-31', 1),
(102, 'Under Pressure',   'Rock',    248, '1981-10-26', 1),
(103, 'Under Pressure',   'Rock',    248, '1981-10-26', 2),
(104, 'Numb/Encore',      'Hip-Hop', 212, '2004-11-30', 3);


CREATE TABLE platforms (
    platformid    INT PRIMARY KEY,
    platformname  VARCHAR(100) NOT NULL,
    type          VARCHAR(50)  NOT NULL,
    unitrevenue   DECIMAL(10,2) NOT NULL
);

INSERT INTO platforms (platformid, platformname, type, unitrevenue) VALUES
(10, 'Spotify',     'audio', 1.00),
(20, 'YouTube',     'video', 1.00),
(30, 'Apple Music', 'audio', 2.00),
(40, 'SoundCloud',  'audio', 3.00);


CREATE TABLE streams_daily (
    songid       INT NOT NULL,
    bandid       INT NOT NULL,
    platformid   INT NOT NULL,
    streamdate   DATE NOT NULL,
    streamscount INT  NOT NULL,

    PRIMARY KEY (songid, bandid, platformid, streamdate),

    FOREIGN KEY (songid)
        REFERENCES songs(songid)
        ON DELETE CASCADE,

    FOREIGN KEY (bandid)
        REFERENCES bands(id)
        ON DELETE CASCADE,

    FOREIGN KEY (platformid)
        REFERENCES platforms(platformid)
        ON DELETE CASCADE
);

INSERT INTO streams_daily (songid, bandid, platformid, streamdate, streamscount) VALUES
(101, 1, 10, '2025-01-01', 1500),
(102, 1, 10, '2025-01-02', 1500),
(103, 2, 30, '2025-01-01', 1050),
(104, 3, 20, '2025-01-01', 1800);
