# php-mpos Docker image

## Usage

**Required**: Link volume php-mpos config directory to `/var/www/html/include/config`.

```
docker pull itochan/mpos
docker run --name mpos -d -p 80:80 -v /path/to/config/path:/var/www/html/include/config itochan/mpos
```
