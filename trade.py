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
    return float(f"{math.ceil(quantity / step_size) * step_size:.{precision}f}")

def send_account_value(client: Client):
    try:
        # Get balances
        btc_balance = float(client.get_asset_balance(asset="BTC")["free"])
        usdt_balance = float(client.get_asset_balance(asset="USDT")["free"])

        # Get BTC price
        btc_price = float(client.get_symbol_ticker(symbol="BTCUSDT")["price"])

        # Convert all balances
        total_in_usdt = usdt_balance + (btc_balance * btc_price)
        total_in_btc = btc_balance + (usdt_balance / btc_price)

        msg = (
            f"📊 Account Value\n"
            f"BTC Balance: {btc_balance:.6f} BTC\n"
            f"USDT Balance: {usdt_balance:.2f} USDT\n\n"
            f"💰 Total: {total_in_usdt:.2f} USDT (~{total_in_btc:.6f} BTC)"
        )

        print(msg)
        send_telegram(msg)

    except Exception as e:
        err = f"❌ Error while fetching account value: {e}"
        print(err)
        send_telegram(err)

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
    finally:
        send_account_value(client);
