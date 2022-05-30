using Azure.Identity;
using Bogus;
using Microsoft.Azure.CosmosRepository;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCosmosRepository(options =>
{
    options.AccountEndpoint = "https://cosmos-repository-sdk-identity-cosmos.documents.azure.com:443/";
    options.TokenCredential = new DefaultAzureCredential();
    options.ContainerBuilder.Configure<Book>(optionsBuilder => optionsBuilder
        .WithContainer("books")
        .WithPartitionKey("/partitionKey"));
});

var app = builder.Build();

app.MapGet("/", () => "Cosmos Repository SDK - Managed Identity Demo");

app.MapGet("/books", async (IRepository<Book> repository) =>
    await repository.GetAsync(x => x.PartitionKey == nameof(Book)));

app.MapGet("/seed", async (IWriteOnlyRepository<Book> repository) =>
{
    Faker<Book> booksFaker = new();
    booksFaker
        .RuleFor(p => p.Name, f => f.Company.CatchPhrase());

    List<Book> books = booksFaker.Generate(100);
    await repository.CreateAsync(books);
});

app.Run();

public class Book : EtagItem
{
    public string Name { get; set; } = null!;

    public string PartitionKey { get; set; }

    protected override string GetPartitionKeyValue() =>
        PartitionKey;

    public Book()
    {
        PartitionKey = nameof(Book);
    }
}