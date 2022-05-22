using Azure.Identity;
using Microsoft.Azure.CosmosRepository;
using Microsoft.Azure.CosmosRepository.Options;
using Microsoft.Extensions.Options;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCosmosRepository(options =>
{
    options.TokenCredential = new DefaultAzureCredential();
    options.ContainerBuilder.Configure<Book>(optionsBuilder => optionsBuilder
        .WithContainer("books")
        .WithPartitionKey("/partitionKey"));
});

var app = builder.Build();

app.MapGet("/", () => "Cosmos Repository SDK - Managed Identity Demo");

app.MapGet("/books", async (IRepository<Book> repository) =>
    await repository.GetAsync(x => x.Type == nameof(Book)));

app.MapGet("/config", (IOptionsMonitor<RepositoryOptions> options) =>
    new
    {
        dns = options.CurrentValue.AccountEndpoint,
        db = options.CurrentValue.DatabaseId
    });

app.Run();

public class Book : EtagItem
{
}