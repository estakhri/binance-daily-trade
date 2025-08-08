from binance.client import Client
from dotenv import load_dotenv
import os
from indicators import get_rsi
from trade import buy_btc
from notifier import send_telegram

load_dotenv()

API_KEY = os.getenv("BINANCE_API_KEY")
API_SECRET = os.getenv("BINANCE_API_SECRET")
TRADE_AMOUNT = float(os.getenv("TRADE_AMOUNT", 10))

client = Client(API_KEY, API_SECRET)

def main():
    rsi_daily = get_rsi(client, interval="1d")
    rsi_weekly = get_rsi(client, interval="1w")

    msg = f"📊 RSI (1D): {rsi_daily:.2f}, RSI (1W): {rsi_weekly:.2f}"
    print(msg)
    send_telegram(msg)

    if rsi_daily < 70 and rsi_weekly < 70:
        send_telegram("✅ RSI < 70 on both timeframes. Buying BTC for $10...")
        buy_btc(client, TRADE_AMOUNT)
    else:
        send_telegram("⛔ RSI condition not met. Skipping buy.")

if __name__ == "__main__":
    main()
