# etl
Scripts to extract, transform and load blockchain data into databases 

parse-tokens.py - creates tokens.csv file from .json files in ./eth (not in source)
Current issues:
        1) Found duplicate addresses, added auto increment id field for now
        2) Single quote vs double quote - unclear how has to be stored in db

load-db.sql - creates the table and loads tokens.csv into db
