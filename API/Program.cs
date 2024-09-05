using API.Application.Users.Commands;
using API.Application.Users.Queries;
using API.Persistence.Repositories;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;
using Helpers;
using API.Persistence.Services;

namespace API
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var MyAllowSpecificOrigins = "_myAllowSpecificOrigins";
            var builder = WebApplication.CreateBuilder(args);
            builder.Services.AddCors(options =>
            {
                options.AddPolicy(
                    name: MyAllowSpecificOrigins,
                    policy =>
                    {
                        policy.WithOrigins("*").AllowAnyMethod().AllowAnyHeader();
                    }
                );
            });
            // Add services to the container.

            builder.Services.AddControllers();
            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            builder.Services.AddSingleton<TokenHelper>();

            builder.Services.AddScoped<QueryAllUsers>();
            builder.Services.AddScoped<QueryUserById>();
            builder.Services.AddScoped<CreateUser>();
            builder.Services.AddScoped<UpdateUser>();
            builder.Services.AddScoped<DeleteUser>();
            builder.Services.AddScoped<LoginUser>();
            builder.Services.AddScoped<IUserRepository, UserRepository>();


            IConfiguration Configuration = builder.Configuration;

            // Configure JWT Authentication
            builder.Services.AddAuthentication(x =>
            {
                x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
                x.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
            }).AddJwtBearer(x =>
            {
                x.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidIssuer = Configuration["JwtSettings:Issuer"],
                    ValidAudience = Configuration["JwtSettings:Audience"],
                    IssuerSigningKey = new SymmetricSecurityKey
                    (
                    Encoding.UTF8.GetBytes(Configuration["JwtSettings:Key"])
                    ),
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true
                };
            });



            // Swagger does not by default allow to use Bearer tokens
            // The method AddSwaggerGen with the following options grants access to address a Bearer token -
            // Simply by clicking the Lock icon and pasting the Bearer Token
            builder.Services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo { Title = "Your API", Version = "v1" });

                // Configure Swagger to use Bearer token authentication
                c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
                {
                    Description = "JWT Authorization header using the Bearer scheme",
                    Type = SecuritySchemeType.Http,
                    Scheme = "bearer"
                });

                c.AddSecurityRequirement(new OpenApiSecurityRequirement
                {
                    {
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference
                            {
                                Type = ReferenceType.SecurityScheme,
                                Id = "Bearer"
                            }
                        },
                        new string[] { }
                    }
                });
            });

            var connectionString = Configuration.GetConnectionString("DefaultConnection") ?? Environment.GetEnvironmentVariable("DEFAULT_CONNECTION");
            builder.Services.AddDbContext<AppDBContext>(options => options.UseSqlite(connectionString));

            Console.WriteLine("Connecting to database with connection string: " + connectionString);

            var accessKey = Configuration["AccessKey"] ?? Environment.GetEnvironmentVariable("ACCESS_KEY");
            var secretKey = Configuration["SecretKey"] ?? Environment.GetEnvironmentVariable("SECRET_KEY");

            builder.Services.AddSingleton(new AppConfiguration
            {
                AccessKey = accessKey,
                SecretKey = secretKey
            });

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            app.UseSwagger();
            app.UseSwaggerUI();

            app.UseHttpsRedirection();

            app.UseCors(MyAllowSpecificOrigins);
            app.UseAuthorization();

            app.MapControllers();

            app.Run();
        }
    }
}
