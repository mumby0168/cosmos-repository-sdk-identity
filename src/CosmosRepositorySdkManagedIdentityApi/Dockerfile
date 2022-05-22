FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
COPY ./ ./
RUN dotnet restore "CosmosRepositorySdkManagedIdentity.sln"

WORKDIR "src/CosmosRepositorySdkManagedIdentityApi"

FROM build AS publish
RUN dotnet publish "CosmosRepositorySdkManagedIdentityApi.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CosmosRepositorySdkManagedIdentityApi.dll"]