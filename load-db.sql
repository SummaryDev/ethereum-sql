drop table tokens;

CREATE TABLE IF NOT EXISTS tokens (
    id SERIAL PRIMARY KEY,
	symbol VARCHAR(128),
    name VARCHAR(256),
    type VARCHAR(128),
    address VARCHAR(44),
    ens_address VARCHAR(128),
    decimals INT,
    website VARCHAR(256),
    logo TEXT,
    support TEXT,
    social TEXT
);

\COPY tokens(symbol,name,type,address,ens_address,decimals,website,logo,support,social) FROM 'tokens.csv' DELIMITER '^' CSV HEADER;
