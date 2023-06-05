# DROP TABLE IF EXISTS stocks;

CREATE TABLE IF NOT EXISTS stocks
(
    symbol String,
    date Date,
    open Decimal64(8),
    high Decimal64(8),
    low Decimal64(8),
    close Decimal64(8),
    close_adj Decimal64(8),
    volume UInt32
)
ENGINE = ReplacingMergeTree
PARTITION BY symbol
PRIMARY KEY(symbol, date)
ORDER BY (symbol, date);

describe stocks;
