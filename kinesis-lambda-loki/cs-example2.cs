// Example showing use of the Serilog.Sinks.Loki Library with Grafana Cloud
// Using https://github.com/josephwoodward/Serilog-Sinks-Loki

using Serilog;
using Serilog.Sinks.Loki;


// Grafana Cloud Credentials
var lokiHost = Environment.GetEnvironmentVariable("GRAFANA_LOGS_HOST");
var lokiUser = Environment.GetEnvironmentVariable("GRAFANA_LOGS_USERNAME");
var lokiPwd = Environment.GetEnvironmentVariable("GRAFANA_LOGS_API_KEY");

Console.WriteLine($"Host: {lokiHost}");
Console.WriteLine($"User: {lokiUser}");

var credentialsCloud = new BasicAuthCredentials($"https://{lokiHost}", lokiUser, lokiPwd );
var credentialsLocal = new NoAuthCredentials("http://grafana1:3100");

Log.Logger = new LoggerConfiguration()
        .MinimumLevel.Information()
        .Enrich.FromLogContext()
        .WriteTo.LokiHttp(credentialsCloud)
        .CreateLogger();

Log.Error("Example error message");

var position = new { Latitude = 25, Longitude = 134 };
var elapsedMs = 34;
Log.Information("Message processed {@Position} in {Elapsed:000} ms.", position, elapsedMs);

Log.CloseAndFlush();

Console.WriteLine("End");
