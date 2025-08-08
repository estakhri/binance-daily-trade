# 📈 BTC Daily DCA Bot with RSI Filter (Dockerized + Telegram Alerts)

A fully Dockerized Python bot that buys Bitcoin (BTC) daily using a **Dollar Cost Averaging (DCA)** strategy — but only when **RSI (14) on daily and weekly timeframes is below 70**. Includes Telegram alerts for full transparency.

---

## 🚀 Features

- ✅ Automatically buys BTC using $10 USDT
- 📉 Uses RSI(14) on both 1D and 1W timeframes to filter overbought conditions
- 🔐 Reads all config from `.env` file
- 📬 Sends Telegram alerts on:
  - RSI values
  - Successful trades
  - Errors
- 🐳 Runs daily via `cron` inside Docker

---

## 🛠️ Tech Stack

- Python 3.10
- [python-binance](https://python-binance.readthedocs.io/en/latest/)
- [pandas_ta](https://github.com/twopirllc/pandas-ta)
- Docker + cron
- Telegram Bot API
- Makefile for build automation

---

## 📦 Quick Start with Makefile

**🎯 Easiest way to get started:**

1. Clone the repo:
   ```bash
   git clone https://github.com/estakhri/binance-daily-trade.git
   cd binance-daily-trade
   ```

2. Complete development setup:
   ```bash
   make dev-setup
   ```

3. Edit the generated `.env` file with your credentials:
   ```env
   BINANCE_API_KEY=your_binance_key
   BINANCE_API_SECRET=your_binance_secret
   TRADE_AMOUNT=10
   TELEGRAM_BOT_TOKEN=your_telegram_bot_token
   TELEGRAM_CHAT_ID=your_telegram_chat_id
   ```

4. Test the bot:
   ```bash
   make run
   ```

5. Deploy with Docker:
   ```bash
   make deploy
   ```

## 📦 Manual Installation (Alternative)

If you prefer manual setup:

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Create `.env` file manually with the credentials above

3. Test the bot:
   ```bash
   python bot.py
   ```

---

## 🤖 Telegram Setup

1. Create a bot at [@BotFather](https://t.me/BotFather)
2. Save your bot **token**
3. Start the bot by messaging it
4. Get your chat ID:
   - Visit:  
     `https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates`
   - Look for: `"chat": {"id": YOUR_CHAT_ID}`

5. Paste both values into `.env`

---

## 🐳 Docker Usage

### Build Image

```bash
docker build -t binance-daily-trade .
```

### Run Container

```bash
docker run -d \
  --name my-btc-dca-bot \
  --env-file .env \
  binance-daily-trade
```

### Logs

```bash
docker logs -f my-btc-dca-bot
```

### Test Run Inside Container

```bash
docker exec -it my-btc-dca-bot python3 /app/bot.py
```

---

## 🛠️ Makefile Commands

This project includes a comprehensive Makefile to simplify development and deployment. Run `make help` to see all available commands.

### **🚀 Quick Commands**
```bash
make help          # Show all available commands
make dev-setup     # Complete development environment setup
make run           # Run the bot locally
make deploy        # Deploy with Docker (build, stop, run)
make status        # Check if Docker container is running
```

### **📦 Development**
```bash
make install       # Install Python dependencies
make setup-env     # Create .env template file
make check-env     # Validate .env configuration
make test-run      # Test run the bot locally
make clean         # Clean up Python cache files
```

### **🐳 Docker Management**
```bash
make docker-build  # Build Docker image
make docker-run    # Build and run container
make docker-stop   # Stop and remove container
make docker-logs   # View container logs (follow mode)
make docker-exec   # Execute bash in running container
make docker-test   # Test run bot inside container
make docker-clean  # Clean up Docker resources
```

### **🔍 Code Quality**
```bash
make lint          # Run linting with flake8
make format        # Format code with black
make format-check  # Check if code is formatted correctly
make test          # Run tests (if any exist)
```

### **⚡ Workflow Examples**

**First time setup:**
```bash
make dev-setup     # Install deps + create .env template
# Edit .env with your credentials
make run           # Test locally
```

**Deploy to production:**
```bash
make deploy        # Stop, build, and run container
make docker-logs   # Monitor the bot
```

**Development workflow:**
```bash
make format        # Format your code
make lint          # Check code quality
make test-run      # Test changes
make docker-test   # Test in container environment
```

---

## 📁 Project Structure

```
binance-daily-trade/
├── bot.py               # Main runner script
├── trade.py             # Buys BTC at market price
├── indicators.py        # Calculates RSI using pandas_ta
├── notifier.py          # Sends Telegram alerts
├── .env                 # Secrets (ignored by Git)
├── requirements.txt     # Dependencies
├── Makefile             # Build automation and commands
├── Dockerfile           # Dockerized image with cron
├── crontab.txt          # Runs bot.py daily at 08:00 UTC
├── entrypoint.sh        # Entrypoint script to start cron
└── README.md            # This file
```

---

## 🔐 Security Notes

- Never share your `.env` file or API keys
- Binance API keys should have only `read` and `trade` permissions — **no withdrawals**
- Rotate keys regularly for safety

---

## 📬 Example Telegram Output

```
📊 RSI (1D): 49.8, RSI (1W): 58.7
✅ RSI < 70 on both timeframes. Buying BTC for $10...
✅ Bought 0.00022 BTC at $45,332.12
```

---

## 📌 TODO / Roadmap

- [ ] Log trades in CSV or SQLite
- [ ] Add FastAPI health endpoint
- [ ] Web dashboard to track DCA performance

---

## 🧠 Disclaimer

This project is for educational and personal use only. Use at your own risk. Crypto markets are volatile and unpredictable.

---

## 🐍 License

MIT © [Your Name]
