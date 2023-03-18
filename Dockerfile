FROM tlnxvtlapps01.unix.regionh.top.local:9101/gitlab-instance-070be33c/dependencies/sdk:6.0 AS build
WORKDIR /src

COPY *.sln .
COPY ["poc-api/poc-api.csproj", "poc-api/"]
RUN dotnet nuget add source https://gitlab:9001/api/v4/projects/4/packages/nuget/index.json -n poc-api -u root -p glpat-4pwmvJcHxEs5X854cszF --store-password-in-clear-text
RUN dotnet nuget remove source nuget.org
RUN dotnet restore "poc-api/poc-api.csproj"

COPY . .
WORKDIR "/src/poc-api"
RUN dotnet build "poc-api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "poc-api.csproj" -c Release -o /app/publish 

FROM tlnxvtlapps01.unix.regionh.top.local:9101/gitlab-instance-070be33c/dependencies/aspnet:6.0
WORKDIR /app
COPY --from=publish /app/publish .
EXPOSE 80
ENTRYPOINT ["dotnet", "poc-api.dll"]