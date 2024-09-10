async Task Post()
{
    //var lokiHost = Environment.GetEnvironmentVariable("GRAFANA_LOGS_HOST");
   // var lokiUser = Environment.GetEnvironmentVariable("GRAFANA_LOGS_USERNAME");
    //var lokiPwd = Environment.GetEnvironmentVariable("GRAFANA_LOGS_API_KEY");

    var lokiHost = "REQUIRED";
    var lokiUser = "REQUIRED";
    var lokiPwd = "REQUIRED";


    var authenticationString = $"{lokiUser}:{lokiPwd}";
    var lokiAuth = Convert.ToBase64String(System.Text.ASCIIEncoding.ASCII.GetBytes(authenticationString));

    TimeSpan t = DateTime.UtcNow - new DateTime(1970, 1, 1);
    int nowTimeSec = (int)t.TotalSeconds;

    var logMsg = new { v1 = 100, v2 = 200 };
    using StringContent logMsgStr = new(JsonSerializer.Serialize(logMsg), Encoding.UTF8, "application/json");
    var lokiStream = new
    {
        streams = new[] { new { stream = new { job = "status" }, values = new[] { new[] { $"{nowTimeSec}000000000", $"{logMsg}" } } } },
    };
    client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Basic", lokiAuth);
    using StringContent jsonContent = new( JsonSerializer.Serialize( lokiStream ), Encoding.UTF8, "application/json");
    var lokiUrl = $"https://{lokiHost}/loki/api/v1/push";
    Console.WriteLine($"lokiUrl = {lokiUrl}\n");
    using HttpResponseMessage response = await client.PostAsync( lokiUrl, jsonContent);


    var jsonResponse = await response.Content.ReadAsStringAsync();
    Console.WriteLine($"jsonResponse = {jsonResponse}\n");
    Console.WriteLine($"Content = {jsonContent}\n");
}
