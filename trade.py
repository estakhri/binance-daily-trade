import os
import math
from binance.client import Client
from notifier import send_telegram

def get_lot_size(client, symbol):
    info = client.get_symbol_info(symbol)
    for f in info['filters']:
        if f['filterType'] == 'LOT_SIZE':
            return float(f['minQty']), float(f['stepSize'])
    return None, None

def adjust_quantity(quantity, step_size):
    precision = int(round(-math.log(step_size, 10), 0))
    return float(f"{math.floor(quantity / step_size) * step_size:.{precision}f}")

def buy_btc(client: Client, usdt_amount=10):
    try:
        ticker = client.get_symbol_ticker(symbol="BTCUSDT")
        min_qty, step_size = get_lot_size(client, "BTCUSDT")
        price = float(ticker["price"])
        quantity = round(usdt_amount / price, 7)
        adjusted_quantity = adjust_quantity(quantity, step_size)
        quantity_str = "{:.7f}".format(adjusted_quantity).rstrip('0').rstrip('.')

        if adjusted_quantity < min_qty:
            raise ValueError(f"Quantity {adjusted_quantity} is less than minQty {min_qty}")

        order = client.order_market_buy(
            symbol="BTCUSDT",
            quantity=quantity_str
        )
        msg = f"✅ Bought {quantity_str} BTC at ${price:.2f}"
        print(msg)
        send_telegram(msg)
        return order
    except Exception as e:
        err = f"❌ Error while buying BTC: {e}"
        print(err)
        send_telegram(err)
        return None
