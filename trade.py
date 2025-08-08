import os
from binance.client import Client
from notifier import send_telegram

def buy_btc(client: Client, usdt_amount=10):
    try:
        ticker = client.get_symbol_ticker(symbol="BTCUSDT")
        price = float(ticker["price"])
        quantity = round(usdt_amount / price, 6)

        order = client.order_market_buy(
            symbol="BTCUSDT",
            quantity=quantity
        )
        msg = f"✅ Bought {quantity} BTC at ${price:.2f}"
        print(msg)
        send_telegram(msg)
        return order
    except Exception as e:
        err = f"❌ Error while buying BTC: {e}"
        print(err)
        send_telegram(err)
        return None
