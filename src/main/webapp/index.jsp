<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Mosam Ka Haal - Weather Forecast</title>
    <style>
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }

      body {
        font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
        background: linear-gradient(
          135deg,
          #1e3c72 0%,
          #2a5298 50%,
          #1e3c72 100%
        );
        min-height: 100vh;
        padding: 20px;
        position: relative;
        overflow-x: hidden;
      }

      /* Animated rain effect */
      .rain {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        pointer-events: none;
        z-index: 1;
      }

      .raindrop {
        position: absolute;
        width: 2px;
        height: 50px;
        background: linear-gradient(transparent, rgba(255, 255, 255, 0.3));
        animation: fall linear infinite;
      }

      @keyframes fall {
        to {
          transform: translateY(100vh);
        }
      }

      .container {
        max-width: 1200px;
        margin: 0 auto;
        position: relative;
        z-index: 2;
      }

      .header {
        text-align: center;
        margin-bottom: 40px;
        animation: fadeInDown 1s ease;
      }

      .brand {
        font-size: 3.5em;
        font-weight: bold;
        color: #fff;
        text-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
        margin-bottom: 10px;
        letter-spacing: 2px;
      }

      .brand-urdu {
        font-size: 2em;
        color: #a8d8ff;
        margin-bottom: 20px;
        font-style: italic;
      }

      .search-box {
        background: rgba(255, 255, 255, 0.1);
        backdrop-filter: blur(10px);
        border-radius: 50px;
        padding: 10px 20px;
        display: flex;
        align-items: center;
        max-width: 600px;
        margin: 0 auto 20px;
        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
        border: 1px solid rgba(255, 255, 255, 0.2);
        animation: fadeIn 1.2s ease;
      }

      #cityInput {
        flex: 1;
        background: transparent;
        border: none;
        padding: 15px 20px;
        font-size: 1.1em;
        color: #fff;
        outline: none;
      }

      #cityInput::placeholder {
        color: rgba(255, 255, 255, 0.6);
      }

      #searchBtn {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: none;
        padding: 15px 30px;
        border-radius: 50px;
        font-size: 1em;
        cursor: pointer;
        transition: all 0.3s ease;
        font-weight: bold;
      }

      #searchBtn:hover {
        transform: scale(1.05);
        box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
      }

      .loading {
        display: none;
        text-align: center;
        color: #fff;
        font-size: 1.2em;
        margin: 20px 0;
      }

      .spinner {
        border: 4px solid rgba(255, 255, 255, 0.3);
        border-top: 4px solid #fff;
        border-radius: 50%;
        width: 40px;
        height: 40px;
        animation: spin 1s linear infinite;
        margin: 20px auto;
      }

      @keyframes spin {
        to {
          transform: rotate(360deg);
        }
      }

      .error {
        display: none;
        background: rgba(255, 59, 48, 0.2);
        backdrop-filter: blur(10px);
        color: #fff;
        padding: 20px;
        border-radius: 15px;
        text-align: center;
        margin: 20px auto;
        max-width: 600px;
        border: 1px solid rgba(255, 59, 48, 0.3);
      }

      .weather-result {
        display: none;
        animation: fadeInUp 0.8s ease;
      }

      .city-name {
        text-align: center;
        font-size: 2.5em;
        color: #fff;
        margin-bottom: 30px;
        text-shadow: 0 2px 10px rgba(0, 0, 0, 0.5);
      }

      .forecast-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
        gap: 20px;
        margin-top: 30px;
      }

      .day-card {
        background: rgba(255, 255, 255, 0.1);
        backdrop-filter: blur(10px);
        border-radius: 20px;
        padding: 25px;
        text-align: center;
        transition: all 0.3s ease;
        border: 1px solid rgba(255, 255, 255, 0.2);
        animation: fadeInUp 0.6s ease backwards;
      }

      .day-card:hover {
        transform: translateY(-10px);
        background: rgba(255, 255, 255, 0.15);
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
      }

      .day-card:nth-child(1) {
        animation-delay: 0.1s;
      }
      .day-card:nth-child(2) {
        animation-delay: 0.2s;
      }
      .day-card:nth-child(3) {
        animation-delay: 0.3s;
      }
      .day-card:nth-child(4) {
        animation-delay: 0.4s;
      }
      .day-card:nth-child(5) {
        animation-delay: 0.5s;
      }
      .day-card:nth-child(6) {
        animation-delay: 0.6s;
      }
      .day-card:nth-child(7) {
        animation-delay: 0.7s;
      }

      .day-date {
        font-size: 0.9em;
        color: #a8d8ff;
        margin-bottom: 10px;
        font-weight: 600;
      }

      .weather-icon {
        font-size: 3em;
        margin: 15px 0;
      }

      .temperature {
        font-size: 2em;
        font-weight: bold;
        color: #fff;
        margin: 10px 0;
      }

      .temp-range {
        font-size: 0.9em;
        color: #ccc;
        margin-bottom: 10px;
      }

      .description {
        color: #a8d8ff;
        font-size: 0.95em;
        margin-top: 10px;
      }

      .precipitation {
        color: #64b5f6;
        font-size: 0.85em;
        margin-top: 8px;
      }

      @keyframes fadeInDown {
        from {
          opacity: 0;
          transform: translateY(-30px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }

      @keyframes fadeInUp {
        from {
          opacity: 0;
          transform: translateY(30px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }

      @keyframes fadeIn {
        from {
          opacity: 0;
        }
        to {
          opacity: 1;
        }
      }

      @media (max-width: 768px) {
        .brand {
          font-size: 2.5em;
        }

        .brand-urdu {
          font-size: 1.5em;
        }

        .forecast-grid {
          grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
          gap: 15px;
        }

        .search-box {
          flex-direction: column;
          padding: 15px;
        }

        #cityInput,
        #searchBtn {
          width: 100%;
          margin: 5px 0;
        }
      }
    </style>
  </head>
  <body>
    <!-- Animated Rain Effect -->
    <div class="rain" id="rain"></div>

    <div class="container">
      <div class="header">
        <h1 class="brand">Weather Man</h1>
        <p class="brand-urdu">
          آپ کے شہر کا مکمل موسمی جائزہ جامع، معتبر، ہر لمحہ
        </p>
      </div>

      <div class="search-box">
        <input
          type="text"
          id="cityInput"
          placeholder="Enter city name (e.g., Karachi, Lahore, Islamabad...)"
          onkeypress="if(event.key === 'Enter') searchWeather()"
        />
        <button id="searchBtn" onclick="searchWeather()">Search</button>
      </div>

      <div class="loading" id="loading">
        <div class="spinner"></div>
        <p>Fetching weather data...</p>
      </div>

      <div class="error" id="error"></div>

      <div class="weather-result" id="weatherResult">
        <h2 class="city-name" id="cityName"></h2>
        <div class="forecast-grid" id="forecastGrid"></div>
      </div>
    </div>

    <script>
      // Create rain effect
      function createRain() {
        const rain = document.getElementById("rain");
        const numberOfDrops = 50;

        for (let i = 0; i < numberOfDrops; i++) {
          const drop = document.createElement("div");
          drop.className = "raindrop";
          drop.style.left = Math.random() * 100 + "%";
          drop.style.animationDuration = Math.random() * 1 + 0.5 + "s";
          drop.style.animationDelay = Math.random() * 2 + "s";
          rain.appendChild(drop);
        }
      }

      createRain();

      function searchWeather() {
        const city = document.getElementById("cityInput").value.trim();

        if (!city) {
          showError("Please enter a city name");
          return;
        }

        showLoading();
        hideError();
        hideWeather();

        fetch("weather?city=" + encodeURIComponent(city))
          .then((response) => response.json())
          .then((data) => {
            hideLoading();

            if (data.error) {
              showError(data.error);
            } else {
              displayWeather(data);
            }
          })
          .catch((error) => {
            hideLoading();
            showError("Error fetching weather data. Please try again.");
            console.error("Error:", error);
          });
      }

      function displayWeather(data) {
        document.getElementById("cityName").textContent = data.city;

        const grid = document.getElementById("forecastGrid");
        grid.innerHTML = "";

        data.forecast.forEach((day) => {
          const card = document.createElement("div");
          card.className = "day-card";

          const date = new Date(day.date);
          const dayName = date.toLocaleDateString("en-US", {
            weekday: "short",
          });
          const dateStr = date.toLocaleDateString("en-US", {
            month: "short",
            day: "numeric",
          });

          card.innerHTML = `
                    <div class="day-date">\${dayName}<br>\${dateStr}</div>
                   <div class="weather-icon">\${day.icon}</div>
                   <div class="temperature">\${Math.round(day.tempMax)}°C</div>
                   <div class="temp-range">↓ \${Math.round(day.tempMin)}°C</div>
                   <div class="description">\${day.description}</div>
                   <div class="precipitation">💧 \${day.precipitation}mm</div>
               `;

          grid.appendChild(card);
        });

        document.getElementById("weatherResult").style.display = "block";
      }

      function showLoading() {
        document.getElementById("loading").style.display = "block";
      }

      function hideLoading() {
        document.getElementById("loading").style.display = "none";
      }

      function showError(message) {
        const errorDiv = document.getElementById("error");
        errorDiv.textContent = message;
        errorDiv.style.display = "block";
      }

      function hideError() {
        document.getElementById("error").style.display = "none";
      }

      function hideWeather() {
        document.getElementById("weatherResult").style.display = "none";
      }
    </script>
  </body>
</html>
