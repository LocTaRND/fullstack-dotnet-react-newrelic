# Build .NET backend
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copy project files for restore
COPY . .
RUN dotnet restore \
    && dotnet publish -c Release -o out

# Final image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# Install New Relic Agent
RUN apt-get update && apt-get install -y wget ca-certificates gnupg \
    && echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list \
    && wget https://download.newrelic.com/548C16BF.gpg \
    && apt-key add 548C16BF.gpg \
    && apt-get update \
    && apt-get install -y newrelic-dotnet-agent \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=build /app/out ./
ENV ASPNETCORE_URLS=http://+:9080
ENV ASPNETCORE_ENVIRONMENT=Production
EXPOSE 9080
ENTRYPOINT ["dotnet", "WebApi.dll"]
