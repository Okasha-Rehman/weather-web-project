package com.mosamkahaal;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import com.google.gson.JsonParser;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/weather")
public class WeatherServlet extends HttpServlet {
    
    private static final String GEOCODING_API = "https://geocoding-api.open-meteo.com/v1/search";
    private static final String WEATHER_API = "https://api.open-meteo.com/v1/forecast";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String city = request.getParameter("city");
        
        if (city == null || city.trim().isEmpty()) {
            response.getWriter().write("{\"error\": \"Please enter a city name\"}");
            return;
        }
        
        try {
            // Step 1: Get coordinates for the city
            String[] coordinates = getCoordinates(city);
            if (coordinates == null) {
                response.getWriter().write("{\"error\": \"City not found. Please try another city.\"}");
                return;
            }
            
            String latitude = coordinates[0];
            String longitude = coordinates[1];
            String cityName = coordinates[2];
            
            // Step 2: Get weather forecast
            String weatherData = getWeatherForecast(latitude, longitude);
            
            // Step 3: Parse and format the data
            JsonObject weatherJson = JsonParser.parseString(weatherData).getAsJsonObject();
            JsonObject daily = weatherJson.getAsJsonObject("daily");
            
            JsonArray dates = daily.getAsJsonArray("time");
            JsonArray tempMax = daily.getAsJsonArray("temperature_2m_max");
            JsonArray tempMin = daily.getAsJsonArray("temperature_2m_min");
            JsonArray weatherCodes = daily.getAsJsonArray("weathercode");
            JsonArray precipitation = daily.getAsJsonArray("precipitation_sum");
            
            List<WeatherDay> forecast = new ArrayList<WeatherDay>();
            
            // Get 7 days forecast
            int days = Math.min(7, dates.size());
            for (int i = 0; i < days; i++) {
                WeatherDay day = new WeatherDay();
                day.date = dates.get(i).getAsString();
                day.tempMax = Math.round(tempMax.get(i).getAsDouble());
                day.tempMin = Math.round(tempMin.get(i).getAsDouble());
                day.weatherCode = weatherCodes.get(i).getAsInt();
                day.precipitation = Math.round(precipitation.get(i).getAsDouble() * 10.0) / 10.0;
                day.description = getWeatherDescription(day.weatherCode);
                day.icon = getWeatherIcon(day.weatherCode);
                forecast.add(day);
            }
            
            // Create response JSON
            JsonObject responseJson = new JsonObject();
            responseJson.addProperty("city", cityName);
            responseJson.add("forecast", new Gson().toJsonTree(forecast));
            
            String jsonResponse = new Gson().toJson(responseJson);
            System.out.println("Sending response: " + jsonResponse); // Debug log
            
            response.getWriter().write(jsonResponse);
            
        } catch (Exception e) {
            e.printStackTrace(); // Log the full error
            response.getWriter().write("{\"error\": \"Error fetching weather data: " + e.getMessage() + "\"}");
        }
    }
    
    private String[] getCoordinates(String city) throws IOException {
        String urlString = GEOCODING_API + "?name=" + URLEncoder.encode(city, "UTF-8") + "&count=1&language=en&format=json";
        String jsonResponse = makeHttpRequest(urlString);
        
        System.out.println("Geocoding response: " + jsonResponse); // Debug log
        
        JsonObject json = JsonParser.parseString(jsonResponse).getAsJsonObject();
        if (json.has("results") && json.getAsJsonArray("results").size() > 0) {
            JsonObject result = json.getAsJsonArray("results").get(0).getAsJsonObject();
            String lat = String.valueOf(result.get("latitude").getAsDouble());
            String lon = String.valueOf(result.get("longitude").getAsDouble());
            String name = result.get("name").getAsString();
            return new String[]{lat, lon, name};
        }
        return null;
    }
    
    private String getWeatherForecast(String latitude, String longitude) throws IOException {
        String urlString = WEATHER_API + 
            "?latitude=" + latitude + 
            "&longitude=" + longitude + 
            "&daily=temperature_2m_max,temperature_2m_min,weathercode,precipitation_sum" +
            "&timezone=auto";
        
        String response = makeHttpRequest(urlString);
        System.out.println("Weather API response: " + response); // Debug log
        return response;
    }
    
    private String makeHttpRequest(String urlString) throws IOException {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(10000);
        
        int responseCode = conn.getResponseCode();
        if (responseCode != 200) {
            throw new IOException("HTTP error code: " + responseCode);
        }
        
        BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        StringBuilder response = new StringBuilder();
        String line;
        
        while ((line = reader.readLine()) != null) {
            response.append(line);
        }
        reader.close();
        
        return response.toString();
    }
    
    private String getWeatherDescription(int code) {
        switch (code) {
            case 0: return "Clear sky";
            case 1: case 2: case 3: return "Partly cloudy";
            case 45: case 48: return "Foggy";
            case 51: case 53: case 55: return "Drizzle";
            case 61: case 63: case 65: return "Rain";
            case 71: case 73: case 75: return "Snow";
            case 77: return "Snow grains";
            case 80: case 81: case 82: return "Rain showers";
            case 85: case 86: return "Snow showers";
            case 95: return "Thunderstorm";
            case 96: case 99: return "Thunderstorm with hail";
            default: return "Unknown";
        }
    }
    
    private String getWeatherIcon(int code) {
        if (code == 0) return "☀️";
        if (code >= 1 && code <= 3) return "⛅";
        if (code >= 45 && code <= 48) return "🌫️";
        if (code >= 51 && code <= 55) return "🌦️";
        if (code >= 61 && code <= 65) return "🌧️";
        if (code >= 71 && code <= 77) return "❄️";
        if (code >= 80 && code <= 82) return "🌧️";
        if (code >= 85 && code <= 86) return "🌨️";
        if (code == 95) return "⛈️";
        if (code >= 96 && code <= 99) return "⛈️";
        return "🌡️";
    }
    
    // Inner class for weather data
    class WeatherDay {
        String date;
        double tempMax;
        double tempMin;
        int weatherCode;
        double precipitation;
        String description;
        String icon;
    }
}