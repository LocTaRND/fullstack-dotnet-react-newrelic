# Build .NET backend
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS backend-build
WORKDIR /app
COPY ./*.sln ./
COPY dotnet6-postgresql-crud-application/*.csproj ./dotnet6-postgresql-crud-application/
RUN dotnet restore
COPY dotnet6-postgresql-crud-application/. ./dotnet6-postgresql-crud-application/
WORKDIR /app/dotnet6-postgresql-crud-application
RUN dotnet publish -c Release -o out

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
    && rm -rf /var/lib/apt/lists/*
    
COPY --from=backend-build /app/dotnet6-postgresql-crud-application/out ./
COPY --from=frontend-build /app/client/build ./wwwroot
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80
ENTRYPOINT ["dotnet", "dotnet6-postgresql-crud-application.dll"]
