using API.Application.Users.Commands;
using API.Application.Users.Queries;
using API.Persistence.Repositories;
using Microsoft.EntityFrameworkCore;

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

            builder.Services.AddScoped<QueryAllUsers>();
            builder.Services.AddScoped<QueryUserById>();
            builder.Services.AddScoped<CreateUser>();
            builder.Services.AddScoped<UpdateUser>();
            builder.Services.AddScoped<DeleteUser>();
            builder.Services.AddScoped<IUserRepository, UserRepository>();

            IConfiguration Configuration = builder.Configuration;

            var connectionString = Configuration.GetConnectionString("DefaultConnection") ?? Environment.GetEnvironmentVariable("DefaultConnection");
            builder.Services.AddDbContext<AppDBContext>(options => options.UseSqlite(connectionString));

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
