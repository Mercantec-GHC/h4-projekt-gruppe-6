import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class WeatherForecastPage extends StatefulWidget {
  @override
  _WeatherForecastPageState createState() => _WeatherForecastPageState();
}

class _WeatherForecastPageState extends State<WeatherForecastPage> {
  List<dynamic> forecasts = [];
  List<double> temperaturesC = [];
  List<String> dates = [];

  Future<void> fetchForecasts() async {
    final response =
        await http.get(Uri.parse('https://h4api.onrender.com/WeatherForecast'));

    if (response.statusCode == 200) {
      setState(() {
        temperaturesC.clear();
        dates.clear();
        forecasts = json.decode(response.body).map((f) {
          temperaturesC.add(f['temperatureC'].toDouble());
          dates.add(f['date']);
          return f;
        }).toList();
      });
    } else {
      throw Exception('Failed to load forecasts');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchForecasts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast Graph'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchForecasts,
          ),
        ],
      ),
      body: forecasts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        minY:
                            (temperaturesC.reduce((a, b) => a < b ? a : b) - 10)
                                .toDouble(),
                        maxY:
                            (temperaturesC.reduce((a, b) => a > b ? a : b) + 20)
                                .toDouble(),
                        gridData: FlGridData(show: true), // Grid
                        titlesData: FlTitlesData(
                          leftTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTextStyles: (context, value) => const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            interval: 10,
                            getTitles: (value) {
                              return '${value.toInt()}°C';
                            },
                          ),
                          bottomTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTextStyles: (context, value) => const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            getTitles: (value) {
                              int index = value.toInt();
                              if (index >= 0 && index < dates.length) {
                                return dates[index].substring(5); // MM-DD
                              }
                              return '';
                            },
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: temperaturesC.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value);
                            }).toList(),
                            isCurved: true,
                            colors: [Colors.blue],
                            barWidth: 4,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Weather Summaries',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: forecasts.length,
                      itemBuilder: (context, index) {
                        final forecast = forecasts[index];
                        return ListTile(
                          title: Text(
                            '${forecast['date']}: ${forecast['summary']}',
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: fetchForecasts,
                    child: Text('Refresh Data'),
                  ),
                ],
              ),
            ),
    );
  }
}
