# Build image
FROM mcr.microsoft.com/dotnet/core/sdk:3.1.401-alpine AS builder  
WORKDIR /sln  
COPY ./Sample.sln ./nuget.config  ./

# Copy all the csproj files and restore to cache the layer for faster builds
# The dotnet_build.sh script does this anyway, so superfluous, but docker can 
# cache the intermediate images so _much_ faster
COPY ./src/Sample/Sample.csproj ./src/Sample/Sample.csproj
COPY ./src/Sample.WebApp/Sample.WebApp.csproj ./src/Sample.WebApp/Sample.WebApp.csproj
RUN dotnet restore "./src/Sample.WebApp/Sample.WebApp.csproj"

#COPY ./test ./test  
COPY ./src ./src  

#RUN dotnet test "./test/AspNetCoreInDocker.Web.Tests/AspNetCoreInDocker.Web.Tests.csproj" -c Release --no-build --no-restore

RUN dotnet publish "./src/Sample.WebApp/Sample.WebApp.csproj" -c Release -o "/sln/dist" --no-restore

#WebApp image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1.7-alpine
WORKDIR /app  
ENV ASPNETCORE_ENVIRONMENT Local  
ENTRYPOINT ["dotnet", "Sample.WebApp.dll"]  
COPY --from=builder /sln/dist .
