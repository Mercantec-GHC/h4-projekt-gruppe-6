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
