using Amazon.Runtime;
using Amazon.S3.Model;
using Amazon.S3;

namespace API.Persistence.Services
{
    public class R2Service
    {
        private readonly IAmazonS3 _s3Client;
        public string AccessKey { get; }
        public string SecretKey { get; }

        public R2Service(string accessKey, string secretKey)
        {
            AccessKey = accessKey;
            SecretKey = secretKey;

            var credentials = new BasicAWSCredentials(accessKey, secretKey);
            var config = new AmazonS3Config
            {
                ServiceURL = "https://a6051dbbe0af70488aff47b9f4d9fc1c.r2.cloudflarestorage.com",
                ForcePathStyle = true
            };
            _s3Client = new AmazonS3Client(credentials, config);
        }

        public async Task<string> UploadToR2(Stream fileStream, string fileName)
        {
            var request = new PutObjectRequest
            {
                InputStream = fileStream,
                BucketName = "h4fil",
                Key = fileName,
                DisablePayloadSigning = true
            };

            var response = await _s3Client.PutObjectAsync(request);

            if (response.HttpStatusCode != System.Net.HttpStatusCode.OK)
            {
                throw new AmazonS3Exception($"Error uploading file to S3. HTTP Status Code: {response.HttpStatusCode}");
            }

            var imageUrl = $"https://h4file.magsapi.com/{fileName}";
            return imageUrl;
        }
    }
}
