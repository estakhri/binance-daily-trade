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
    global TRADE_AMOUNT
    rsi_daily = get_rsi(client, interval="1d")
    rsi_weekly = get_rsi(client, interval="1w")

    msg = f"📊 RSI (1D): {rsi_daily:.2f}, RSI (1W): {rsi_weekly:.2f}"
    print(msg)
    send_telegram(msg)

    if rsi_daily < 70 and rsi_weekly < 70:
        trade_amount=TRADE_AMOUNT
        send_telegram("✅ RSI < 70 on both timeframes.")
        if rsi_daily < 30.0:
            trade_amount=trade_amount*2
            send_telegram("🔥 RSI daily < 30 !")
        send_telegram("💸 Buying BTC for $"+str(trade_amount)+"...")
        buy_btc(client, trade_amount)
    else:
        send_telegram("⛔ RSI condition not met. Skipping buy.")

if __name__ == "__main__":
    main()
