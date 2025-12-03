using EasyPC.API;
using EasyPC.API.Data;
using EasyPC.API.Hubs;
using EasyPC.Services;
using EasyPC.Services.Database;
using EasyPC.Services.Interfaces;
using EasyPC.Services.StateMachine.CaseStateMachine;
using EasyPC.Services.StateMachine.GraphicsCard;
using EasyPC.Services.StateMachine.GraphicsCardStateMachine;
using EasyPC.Services.StateMachine.MotherboardStateMachine;
using EasyPC.Services.StateMachine.PcStateMachine;
using EasyPC.Services.StateMachine.PowerSupplyStateMachine;
using EasyPC.Services.StateMachine.ProcessorStateMachine;
using EasyPC.Services.StateMachine.RamStateMachine;
using Mapster;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using EasyNetQ;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
    });

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutter", policy =>
    {
        policy.SetIsOriginAllowed(_ => true)
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

builder.Services.AddSignalR();

builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("basicAuth", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "basic",
        In = ParameterLocation.Header,
        Description = "Basic Authorization header using the Basic scheme."
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "basicAuth"
                }
            },
            Array.Empty<string>()
        }
    });
});

builder.Services.AddDbContext<DatabaseContext>(options =>
{
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
    options.ConfigureWarnings(w => w.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.RelationalEventId.PendingModelChangesWarning));
});

builder.Services.AddHttpContextAccessor();
builder.Services.AddMemoryCache();
builder.Services.AddMapster();

var rabbitMqHost = builder.Configuration["RabbitMQ:Host"];
var rabbitMqUsername = builder.Configuration["RabbitMQ:Username"];
var rabbitMqPassword = builder.Configuration["RabbitMQ:Password"];
var rabbitMqVirtualHost = builder.Configuration["RabbitMQ:VirtualHost"];
var rabbitMqConnectionString = $"host={rabbitMqHost};virtualHost={rabbitMqVirtualHost};username={rabbitMqUsername};password={rabbitMqPassword}";

builder.Services.AddSingleton<IBus>(RabbitHutch.CreateBus(rabbitMqConnectionString));

builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IRamService, RamService>();
builder.Services.AddTransient<IGraphicsCardService, GraphicsCardService>();
builder.Services.AddTransient<IMotherboardService, MotherboardService>();
builder.Services.AddTransient<ICaseService, CaseService>();
builder.Services.AddTransient<IProcessorService, ProcessorService>();
builder.Services.AddTransient<IPowerSupplyService, PowerSupplyService>();
builder.Services.AddTransient<IManufacturerService, ManufacturerService>();
builder.Services.AddTransient<IProductsService, ProductsService>();
builder.Services.AddTransient<IPcService, PcService>();
builder.Services.AddTransient<IOrderService, OrderService>();
builder.Services.AddTransient<IRatingService, RatingService>();

// New services for Build Wizard and Compatibility Checker
builder.Services.AddScoped<CompatibilityService>();
builder.Services.AddScoped<BuildWizardService>();

builder.Services.AddTransient<InitialCaseStateMachine>();
builder.Services.AddTransient<DraftCaseStateMachine>();
builder.Services.AddTransient<ActiveCaseStateMachine>();
builder.Services.AddTransient<HiddenCaseStateMachine>();
builder.Services.AddTransient<BaseCaseStateMachine>();

builder.Services.AddTransient<InitialRamStateMachine>();
builder.Services.AddTransient<DraftRamStateMachine>();
builder.Services.AddTransient<ActiveRamStateMachine>();
builder.Services.AddTransient<HiddenRamStateMachine>();
builder.Services.AddTransient<BaseRamStateMachine>();

builder.Services.AddTransient<InitialGraphicsCardStateMachine>();
builder.Services.AddTransient<DraftGraphicsCardStateMachine>();
builder.Services.AddTransient<ActiveGraphicsCardStateMachine>();
builder.Services.AddTransient<HiddenGraphicsCardStateMachine>();
builder.Services.AddTransient<BaseGraphicsCardStateMachine>();

builder.Services.AddTransient<InitialMotherboardStateMachine>();
builder.Services.AddTransient<DraftMotherboardStateMachine>();
builder.Services.AddTransient<ActiveMotherboardStateMachine>();
builder.Services.AddTransient<HiddenMotherboardStateMachine>();
builder.Services.AddTransient<BaseMotherboardStateMachine>();

builder.Services.AddTransient<InitialProcessorStateMachine>();
builder.Services.AddTransient<DraftProcessorStateMachine>();
builder.Services.AddTransient<ActiveProcessorStateMachine>();
builder.Services.AddTransient<HiddenProcessorStateMachine>();
builder.Services.AddTransient<BaseProcessorStateMachine>();

builder.Services.AddTransient<InitialPowerSupplyStateMachine>();
builder.Services.AddTransient<DraftPowerSupplyStateMachine>();
builder.Services.AddTransient<ActivePowerSupplyStateMachine>();
builder.Services.AddTransient<HiddenPowerSupplyStateMachine>();
builder.Services.AddTransient<BasePowerSupplyStateMachine>();

builder.Services.AddTransient<InitialPcStateMachine>();
builder.Services.AddTransient<DraftPcStateMachine>();
builder.Services.AddTransient<ActivePcStateMachine>();
builder.Services.AddTransient<HiddenPcStateMachine>();
builder.Services.AddTransient<BasePcStateMachine>();    

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<DatabaseContext>();
        
        // Apply migrations automatically
        await context.Database.MigrateAsync();
        
        var seeder = new DataSeeder(context);
        await seeder.SeedAsync();
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred while seeding the database.");
    }
}

app.UseSwagger();
app.UseSwaggerUI();

app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        context.Response.StatusCode = 500;
        context.Response.ContentType = "application/json";

        var exceptionHandlerPathFeature = context.Features.Get<Microsoft.AspNetCore.Diagnostics.IExceptionHandlerPathFeature>();
        var exception = exceptionHandlerPathFeature?.Error;

        var errorResponse = new
        {
            title = "Internal Server Error",
            status = 500,
            detail = exception?.Message ?? "An unexpected error occurred",
            errors = exception is Microsoft.EntityFrameworkCore.DbUpdateException dbEx && dbEx.InnerException != null
                ? new { Database = new[] { dbEx.InnerException.Message } }
                : null
        };

        await context.Response.WriteAsJsonAsync(errorResponse);
    });
});

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}
app.UseCors("AllowFlutter");

app.Use(async (context, next) =>
{
    var accessToken = context.Request.Query["access_token"];
    var path = context.Request.Path;

    if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/supportHub"))
    {
        context.Request.Headers["Authorization"] = $"Basic {accessToken}";
        app.Logger.LogInformation($"SignalR Auth: Added Authorization header for path {path}");
        app.Logger.LogInformation($"SignalR Auth: Token length: {accessToken.ToString().Length}");
    }
    await next();
});

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.MapHub<SupportHub>("/supportHub", options =>
{
    options.AllowStatefulReconnects = true;
});
app.Run();