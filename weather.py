import streamlit as st

# Disable PyplotGlobalUseWarning
st.set_option('deprecation.showPyplotGlobalUse', False)

import pandas as pd
# Import necessary libraries
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
import streamlit as st

# Load the dataset
df = pd.read_csv("weather_history_bangladesh.csv")

# Set up the web app
st.set_page_config(page_title="Weather Analysis and Classification Web App", page_icon=":partly_sunny:", layout="wide")

# Title and description
st.title("Weather Analysis and Classification App")
st.markdown("This app analyzes weather data and predicts weather History of Bangladesh.")

# Sidebar for user input
st.sidebar.title("User Input")
st.sidebar.markdown("Select the weather parameters to analyze and predict:")

# User input for analysis
analysis_options = st.sidebar.multiselect("Select parameters for analysis:", ["temperature_fahrenheit", "humidity_percentage", "wind_speed_mph", "pressure_in", "precip._in", "daylight_hours"], ["temperature_fahrenheit", "humidity_percentage"])
if "daylight_hours" in analysis_options:
    st.warning("Note: Daylight hours are only available for visualization, not for classification.")

# EDA
# 1. How does temperature vary over the years?
if "temperature_fahrenheit" in analysis_options:
    st.header("Temperature variation over the years")
    df["year"] = pd.DatetimeIndex(df["date"]).year
    sns.lineplot(x="year", y="temperature_fahrenheit", data=df)
    st.pyplot()

# 2. What is the distribution of humidity levels?
if "humidity_percentage" in analysis_options:
    st.header("Distribution of humidity levels")
    sns.histplot(df["humidity_percentage"], kde=True)
    plt.xticks(rotation=90, fontsize=10)
    st.pyplot()

# 3. Is there a correlation between wind speed and temperature?
if "wind_speed_mph" in analysis_options and "temperature_fahrenheit" in analysis_options:
    st.header("Correlation between wind speed and temperature")
    sns.scatterplot(x="wind_speed_mph", y="temperature_fahrenheit", data=df)
    st.pyplot()

# 4. How often does precipitation occur, and what is the average amount?
if "precip._in" in analysis_options:
    precipitation = df[df["precip._in"] > 0]
    st.header("Precipitation analysis")
    st.write(f"Number of days with precipitation: {len(precipitation)}")
    if len(precipitation) > 0:
        st.write(f"Average amount of precipitation: {precipitation['precip._in'].mean()} inches")
    else:
        st.write("No precipitation in the dataset.")

# 5. How does the amount of daylight vary throughout the year?
if "daylight_hours" in analysis_options:
    st.header("Daylight variation over the year")
    df["daylight_hours"] = df["time"].apply(lambda x: int(x.split(':')[0]))
    sns.lineplot(x="date", y="daylight_hours", data=df)
    plt.xticks(rotation=90, fontsize=10)
    st.pyplot()


# Classification
# Prepare the data
if "condition" in df.columns:
    X = df[["temperature_fahrenheit", "humidity_percentage", "wind_speed_mph", "pressure_in", "precip._in"]]
    y = df["condition"]

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

    # Train the model
    model = LogisticRegression(max_iter=10000)
    model.fit(X_train, y_train)

    # Predict on test data
    y_pred = model.predict(X_test)

    # Evaluate the model
    accuracy = accuracy_score(y_test, y_pred)
    print(f"Accuracy: {accuracy}")
