import pandas as pd
import pandas_ta as ta
from binance.client import Client

def get_rsi(client: Client, symbol="BTCUSDT", interval="1d", limit=100, length=14):
    klines = client.get_klines(symbol=symbol, interval=interval, limit=limit)
    df = pd.DataFrame(klines, columns=[
        "open_time", "open", "high", "low", "close", "volume",
        "close_time", "quote_asset_volume", "number_of_trades",
        "taker_buy_base_volume", "taker_buy_quote_volume", "ignore"
    ])
    df["close"] = df["close"].astype(float)
    rsi = ta.rsi(df["close"], length=length)
    return rsi.iloc[-1]
