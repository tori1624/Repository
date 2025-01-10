import requests
import pandas as pd
from datetime import datetime

def get_markets():
    """
    Retrieve all market information listed on Upbit.

    Returns:
        list: List of market codes (e.g., ['KRW-BTC', 'KRW-ETH']).
    """
    url = "https://api.upbit.com/v1/market/all"
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        # Filter only KRW markets
        krw_markets = [market["market"] for market in data if market["market"].startswith("KRW-")]
        return krw_markets
    else:
        print(f"Error: {response.status_code} - {response.text}")
        return []

def get_total_volume(markets, count=1):
    """
    Calculate the total trading volume of all markets on Upbit.

    Args:
        markets (list): List of market codes.
        count (int): Number of days to retrieve (default is 1).

    Returns:
        pd.DataFrame: Upbit total trading volume data.
    """
    url = "https://api.upbit.com/v1/candles/months"
    total_data = []

    for market in markets:
        params = {
            "market": market,
            "count": count
        }
        response = requests.get(url, params=params)

        if response.status_code == 200:
            data = response.json()
            for item in data:
                total_data.append({
                    "market": market,
                    "date": item["candle_date_time_kst"],
                    "acc_volume": item["candle_acc_trade_volume"],
                    "acc_price": item["candle_acc_trade_price"]
                })
        else:
            print(f"Error fetching data for {market}: {response.status_code}")

    # Convert to DataFrame
    df = pd.DataFrame(total_data)
    df["date"] = pd.to_datetime(df["date"]).dt.strftime("%Y-%m")

    # Save raw data to CSV
    raw_filename = "upbit_raw_data.csv"
    df.to_csv(raw_filename, index=False)
    print(f"Raw data has been saved to '{raw_filename}'.")

    # Calculate total trading volume by date
    total_volume = df.groupby("date")["acc_price"].sum().reset_index()
    total_volume.columns = ["date", "total_acc_price"]
    total_volume["CEX"] = "Upbit"

    return total_volume

# Example execution
if __name__ == "__main__":
    print("Retrieving all market information...")
    markets = get_markets()

    if markets:
        print(f"A total of {len(markets)} markets were found.")
        print("Calculating total trading volume...")

        df_total_volume = get_total_volume(markets, count=13)  # Last 1 year of data

        if not df_total_volume.empty:
            print(df_total_volume)

            # Save to CSV
            filename = "upbit_total_volume.csv"
            df_total_volume.to_csv(filename, index=False)
            print(f"Upbit total trading volume data has been saved to '{filename}'.")
        else:
            print("Failed to retrieve data.")
    else:
        print("Failed to retrieve market information.")
